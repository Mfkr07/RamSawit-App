import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/core/database/app_database.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_repository.dart';
import 'package:transaksi_sawit_app/features/penjual/penjual_repository.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    PenjualRepository.clearDemoData();
    TransaksiRepository.clearDemoData();
  });

  tearDown(() async {
    await db.close();
  });

  group('Uji Integrasi End-to-End Transaksi & Persistensi SQLite Mode Demo', () {
    test('1. Pembuatan Penjual baru tersimpan permanen di SQLite lokal', () async {
      final penjualRepo = PenjualRepository(null, db);

      // Pastikan awal kosong
      final initialList = await penjualRepo.getPenjualList();
      expect(initialList.isEmpty, isTrue);

      // Buat penjual baru
      final created = await penjualRepo.createPenjual(
        nama: 'Petani Sawit Budianto',
        noTelepon: '081299988877',
        alamat: 'Desa Jaya Makmur',
      );

      expect(created.id.startsWith('p-demo-'), isTrue);
      expect(created.nama, equals('Petani Sawit Budianto'));

      // Cek langsung ke database SQLite Drift
      final sqliteRows = await db.select(db.localPenjual).get();
      expect(sqliteRows.length, equals(1));
      expect(sqliteRows.first.nama, equals('Petani Sawit Budianto'));
      expect(sqliteRows.first.noTelepon, equals('081299988877'));

      // Buat instance baru dan clear RAM memory demo
      PenjualRepository.clearDemoData();
      final freshRepo = PenjualRepository(null, db);
      final reloadedList = await freshRepo.getPenjualList();
      expect(reloadedList.length, equals(1));
      expect(reloadedList.first.nama, equals('Petani Sawit Budianto'));
    });

    test('2. Pembuatan Transaksi baru, kalkulasi potongan, dan persistensi ke SQLite', () async {
      final penjualRepo = PenjualRepository(null, db);
      final seller = await penjualRepo.createPenjual(
        nama: 'Haji Rahmat',
        noTelepon: '081300011122',
      );

      final trxRepo = TransaksiRepository(null, db);

      final now = DateTime.now();
      final items = [
        TransaksiItemDraft(
          jenisBuahId: 1,
          jenisBuahNama: 'Tandan Besar',
          hargaPerKg: Decimal.parse('2500'),
          beratKotorKg: Decimal.parse('100'),
          persentasePotongan: Decimal.parse('2'), // 2 kg potong -> 98 kg bersih -> Rp 245.000
        ),
        TransaksiItemDraft(
          jenisBuahId: 3,
          jenisBuahNama: 'Berondolan',
          hargaPerKg: Decimal.parse('2800'),
          beratKotorKg: Decimal.parse('50'),
          persentasePotongan: Decimal.zero, // 0 potong -> 50 kg bersih -> Rp 140.000
        ),
      ];

      final createdTrx = await trxRepo.createTransaksi(
        penjualId: seller.id,
        namaPenjual: seller.nama,
        tanggalTransaksi: now,
        jenisPembayaran: 'tunai',
        catatan: 'Uji transaksi lapangan demo',
        items: items,
      );

      // Verifikasi kalkulasi
      expect(createdTrx.totalBeratKotorKg, equals(Decimal.parse('150')));
      expect(createdTrx.totalBeratBersihKg, equals(Decimal.parse('148.00')));
      expect(createdTrx.totalPotonganRp, equals(Decimal.parse('5000.00')));
      expect(createdTrx.totalNilai, equals(Decimal.parse('385000.00')));
      expect(createdTrx.status, equals('selesai'));

      // Verifikasi tersimpan di tabel SQLite
      final localTrxRows = await db.select(db.localTransaksi).get();
      expect(localTrxRows.length, equals(1));
      expect(localTrxRows.first.penjualId, equals(seller.id));
      expect(localTrxRows.first.status, equals('selesai'));

      final localItemRows = await db.select(db.localTransaksiItem).get();
      expect(localItemRows.length, equals(2));

      // Verifikasi reload dari SQLite setelah restart / RAM clear
      TransaksiRepository.clearDemoData();
      final freshTrxRepo = TransaksiRepository(null, db);

      await freshTrxRepo.ensureDemoLoaded();
      final paged = await freshTrxRepo.getFilteredRingkasanPaginated(page: 1, pageSize: 10);
      expect(paged.totalCount, equals(1));
      expect(paged.items.first.namaPenjual, equals('Haji Rahmat'));
      expect(paged.items.first.totalNilai, equals(Decimal.parse('385000.00')));

      // Verifikasi Dashboard membaca transaksi dari SQLite
      final dashboardRepo = DashboardRepository(null, 'admin', freshTrxRepo);
      final dailyList = await dashboardRepo.getTransaksiHarian(
        now.subtract(const Duration(days: 7)),
        now.add(const Duration(days: 1)),
      );

      expect(dailyList.isNotEmpty, isTrue);
      expect(dailyList.first.jumlahTransaksi, equals(1));
      expect(dailyList.first.totalNilai, equals(Decimal.parse('385000.00')));

      // Uji Pembatalan Transaksi
      await freshTrxRepo.cancelTransaksi(createdTrx.id, 'Salah input timbangan');

      // Verifikasi di SQLite status berubah jadi dibatalkan
      final updatedLocalTrx = await db.select(db.localTransaksi).get();
      expect(updatedLocalTrx.first.status, equals('dibatalkan'));
      expect(updatedLocalTrx.first.alasanBatal, equals('Salah input timbangan'));
    });
  });
}
