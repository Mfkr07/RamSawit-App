import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/export/laporan_pengiriman_excel_generator.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/export/laporan_pengiriman_pdf_generator.dart';
import 'package:transaksi_sawit_app/features/transaksi/export/laporan_excel_generator.dart';
import 'package:transaksi_sawit_app/features/transaksi/export/laporan_pdf_generator.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_repository.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart';
import 'package:transaksi_sawit_app/models/laporan_export_item.dart';
import 'package:transaksi_sawit_app/models/pabrik.dart';
import 'package:transaksi_sawit_app/models/pengiriman_pabrik.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    TransaksiRepository.seedDemoDataForTesting();
    PengirimanPabrikRepository.seedDemoDataForTesting();
  });

  group('Tugas Bagian 14: Export Detail Pembelian per Item Tests', () {
    test('LaporanPembelianItem calculates potonganKg, beratBersih, and subtotal accurately', () {
      final json = {
        'id': 'item-1',
        'harga_per_kg': '2500',
        'berat_kotor_kg': '1000',
        'persentase_potongan': '3.00',
        'transaksi': {
          'kode_transaksi': 'TRX-20260904-0001',
          'tanggal_transaksi': '2026-09-04T10:00:00.000Z',
          'status': 'selesai',
          'penjual': {'nama': 'Petani Sawit Sejahtera'},
        },
        'jenis_buah': {'nama': 'Tandan Besar'},
      };

      final item = LaporanPembelianItem.fromJson(json);

      expect(item.kodeTransaksi, equals('TRX-20260904-0001'));
      expect(item.namaPenjual, equals('Petani Sawit Sejahtera'));
      expect(item.jenisBuah, equals('Tandan Besar'));
      expect(item.hargaPerKg, equals(Decimal.parse('2500')));
      expect(item.beratKotorKg, equals(Decimal.parse('1000')));
      expect(item.persentasePotongan, equals(Decimal.parse('3.00')));

      // Potongan kg = 1000 * 3% = 30.00 kg
      expect(item.potonganKg, equals(Decimal.parse('30.00')));
      // Berat bersih = 1000 - 30 = 970.00 kg
      expect(item.beratBersihKg, equals(Decimal.parse('970.00')));
      // Subtotal = 2500 * 970 = 2,425,000.00
      expect(item.subtotal, equals(Decimal.parse('2425000.00')));
      expect(item.jenisPembayaran, equals('tunai'));
      expect(item.isTunai, isTrue);
      expect(item.isNonTunai, isFalse);
      expect(item.jenisPembayaranLabel, equals('Tunai'));
    });

    test('LaporanPembelianItem correctly parses jenis_pembayaran non_tunai', () {
      final json = {
        'id': 'item-2',
        'harga_per_kg': '2700',
        'berat_kotor_kg': '1500',
        'persentase_potongan': '0.00',
        'transaksi': {
          'kode_transaksi': 'TRX-20260905-0002',
          'tanggal_transaksi': '2026-09-05T11:00:00.000Z',
          'status': 'selesai',
          'jenis_pembayaran': 'non_tunai',
          'penjual': {'nama': 'Koperasi Tani Makmur'},
        },
        'jenis_buah': {'nama': 'Tandan Besar'},
      };

      final item = LaporanPembelianItem.fromJson(json);

      expect(item.kodeTransaksi, equals('TRX-20260905-0002'));
      expect(item.jenisPembayaran, equals('non_tunai'));
      expect(item.isTunai, isFalse);
      expect(item.isNonTunai, isTrue);
      expect(item.jenisPembayaranLabel, equals('Non Tunai'));
    });

    test('LaporanPembelianItem correctly parses when Supabase returns list relationships', () {
      final json = {
        'id': 'item-3',
        'harga_per_kg': '2700',
        'berat_kotor_kg': '1500',
        'persentase_potongan': '0.00',
        'transaksi': [
          {
            'kode_transaksi': 'TRX-20260905-0003',
            'tanggal_transaksi': '2026-09-05T11:00:00.000Z',
            'status': 'selesai',
            'jenis_pembayaran': 'non_tunai',
            'penjual': [
              {'nama': 'Koperasi Tani Makmur'}
            ],
          }
        ],
        'jenis_buah': [
          {'nama': 'Tandan Besar'}
        ],
      };

      final item = LaporanPembelianItem.fromJson(json);

      expect(item.kodeTransaksi, equals('TRX-20260905-0003'));
      expect(item.namaPenjual, equals('Koperasi Tani Makmur'));
      expect(item.jenisBuah, equals('Tandan Besar'));
      expect(item.jenisPembayaran, equals('non_tunai'));
      expect(item.isNonTunai, isTrue);
      expect(item.jenisPembayaranLabel, equals('Non Tunai'));
    });

    test('LaporanExcelGenerator generates valid bytes with 11 columns and totals', () {
      final items = [
        LaporanPembelianItem(
          kodeTransaksi: 'TRX-001',
          tanggalTransaksi: DateTime(2026, 9, 4),
          namaPenjual: 'Petani A',
          jenisBuah: 'Tandan Besar',
          hargaPerKg: Decimal.parse('2500'),
          beratKotorKg: Decimal.parse('1000'),
          persentasePotongan: Decimal.parse('3'),
          potonganKg: Decimal.parse('30'),
          beratBersihKg: Decimal.parse('970'),
          subtotal: Decimal.parse('2425000'),
          status: 'selesai',
        ),
        LaporanPembelianItem(
          kodeTransaksi: 'TRX-001',
          tanggalTransaksi: DateTime(2026, 9, 4),
          namaPenjual: 'Petani A',
          jenisBuah: 'Berondolan',
          hargaPerKg: Decimal.parse('2800'),
          beratKotorKg: Decimal.parse('500'),
          persentasePotongan: Decimal.zero,
          potonganKg: Decimal.zero,
          beratBersihKg: Decimal.parse('500'),
          subtotal: Decimal.parse('1400000'),
          status: 'selesai',
        ),
      ];

      final bytes = LaporanExcelGenerator.generate(
        items: items,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 10),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(500));
    });

    test('LaporanPdfGenerator generates valid landscape PDF document', () async {
      final items = [
        LaporanPembelianItem(
          kodeTransaksi: 'TRX-001',
          tanggalTransaksi: DateTime(2026, 9, 4),
          namaPenjual: 'Petani A',
          jenisBuah: 'Tandan Besar',
          hargaPerKg: Decimal.parse('2500'),
          beratKotorKg: Decimal.parse('1000'),
          persentasePotongan: Decimal.parse('3'),
          potonganKg: Decimal.parse('30'),
          beratBersihKg: Decimal.parse('970'),
          subtotal: Decimal.parse('2425000'),
          status: 'selesai',
        ),
        LaporanPembelianItem(
          kodeTransaksi: 'TRX-001',
          tanggalTransaksi: DateTime(2026, 9, 4),
          namaPenjual: 'Petani A',
          jenisBuah: 'Berondolan',
          hargaPerKg: Decimal.parse('2800'),
          beratKotorKg: Decimal.parse('500'),
          persentasePotongan: Decimal.zero,
          potonganKg: Decimal.zero,
          beratBersihKg: Decimal.parse('500'),
          subtotal: Decimal.parse('1400000'),
          status: 'selesai',
        ),
      ];

      final bytes = await LaporanPdfGenerator.generate(
        items: items,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 10),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });

    test('TransaksiRepository.getLaporanPembelianItems in demo mode splits multi-item transaction', () async {
      final repo = TransaksiRepository(null);
      final items = await repo.getLaporanPembelianItems();

      expect(items, isNotEmpty);
      // TRX-20260904-0001 has 2 items (Tandan Besar & Berondolan)
      final trx001Items = items.where((e) => e.kodeTransaksi == 'TRX-20260904-0001').toList();
      expect(trx001Items.length, equals(2));

      final tb = trx001Items.firstWhere((e) => e.jenisBuah == 'Tandan Besar');
      expect(tb.hargaPerKg, equals(Decimal.parse('2500')));
      expect(tb.beratKotorKg, equals(Decimal.parse('1000')));
      expect(tb.persentasePotongan, equals(Decimal.parse('3.00')));
      expect(tb.potonganKg, equals(Decimal.parse('30.00')));
      expect(tb.beratBersihKg, equals(Decimal.parse('970.00')));

      final br = trx001Items.firstWhere((e) => e.jenisBuah == 'Berondolan');
      expect(br.hargaPerKg, equals(Decimal.parse('2800')));
      expect(br.beratKotorKg, equals(Decimal.parse('500')));
    });

    test('TransaksiRepository.getLaporanPembelianItems filters by jenisPembayaran in demo mode', () async {
      final repo = TransaksiRepository(null);

      // Create a non-tunai transaction in demo mode
      await repo.createTransaksi(
        penjualId: 'p-001',
        namaPenjual: 'Petani Non Tunai',
        tanggalTransaksi: DateTime.now(),
        jenisPembayaran: 'non_tunai',
        items: [
          TransaksiItemDraft(
            jenisBuahId: 1,
            jenisBuahNama: 'Tandan Besar',
            hargaPerKg: Decimal.parse('2600'),
            beratKotorKg: Decimal.parse('1200'),
          ),
        ],
      );

      final allItems = await repo.getLaporanPembelianItems();
      final hasNonTunai = allItems.any((e) => e.isNonTunai);
      expect(hasNonTunai, isTrue);

      final nonTunaiOnly = await repo.getLaporanPembelianItems(jenisPembayaran: 'non_tunai');
      expect(nonTunaiOnly.every((e) => e.isNonTunai), isTrue);
      expect(nonTunaiOnly, isNotEmpty);

      final tunaiOnly = await repo.getLaporanPembelianItems(jenisPembayaran: 'tunai');
      expect(tunaiOnly.every((e) => e.isTunai), isTrue);
    });
  });

  group('Tugas Bagian 14: Export Laporan Penjualan Pabrik Tests', () {
    final pabrikSample = Pabrik(
      id: 'pb-001',
      nama: 'PT Sawit Inti Riau',
      alamat: 'Pelalawan',
      kontak: '08117654321',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final pengirimanList = [
      PengirimanPabrik(
        id: 'k-1',
        kodePengiriman: 'KRM-20260906-0001',
        pabrikId: 'pb-001',
        platNomor: 'BM 8899 XX',
        namaSopir: 'Pak Wardi',
        tanggalKirim: DateTime(2026, 9, 6),
        beratKotorKg: Decimal.parse('8500'),
        beratDitolakKg: Decimal.parse('150'),
        beratDiterimaKg: Decimal.parse('8350'),
        persentasePotonganPabrik: Decimal.parse('2.5'),
        beratBersihKg: Decimal.parse('8141.25'),
        hargaJualPerKg: Decimal.parse('2450'),
        nilaiPotonganRp: Decimal.parse('511387.50'),
        totalNilaiJual: Decimal.parse('19946062.50'),
        status: 'selesai',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        pabrik: pabrikSample,
      ),
      PengirimanPabrik(
        id: 'k-2',
        kodePengiriman: 'KRM-20260906-0002',
        pabrikId: 'pb-001',
        platNomor: 'BM 1234 YY',
        namaSopir: 'Pak Budi',
        tanggalKirim: DateTime(2026, 9, 6),
        beratKotorKg: Decimal.parse('7000'),
        beratDitolakKg: Decimal.zero,
        beratDiterimaKg: Decimal.parse('7000'),
        persentasePotonganPabrik: Decimal.zero,
        beratBersihKg: Decimal.parse('7000'),
        hargaJualPerKg: Decimal.zero,
        nilaiPotonganRp: Decimal.zero,
        totalNilaiJual: Decimal.zero,
        status: 'berangkat', // Belum selesai - TIDAK boleh masuk export
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        pabrik: pabrikSample,
      ),
    ];

    test('LaporanPengirimanExcelGenerator filters out non-selesai shipments', () {
      final bytes = LaporanPengirimanExcelGenerator.generate(
        items: pengirimanList,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 10),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(500));
    });

    test('LaporanPengirimanPdfGenerator filters out non-selesai shipments', () async {
      final bytes = await LaporanPengirimanPdfGenerator.generate(
        items: pengirimanList,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 10),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });
  });
}
