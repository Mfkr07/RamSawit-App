import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // Gunakan in-memory database native SQLite untuk testing
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Tugas Bagian 27: Drift SQLite Offline-First Database Tests', () {
    test('Schema version is 2 and all tables exist', () {
      expect(db.schemaVersion, equals(2));
      expect(db.allTables.length, equals(9));
    });

    test('Insert and query offline LocalTransaksi with sync metadata', () async {
      final now = DateTime.now();

      // Masukkan transaksi offline
      await db.into(db.localTransaksi).insert(
            LocalTransaksiCompanion.insert(
              id: 'trx-offline-001',
              kodeTransaksi: 'TRX-20260930-MOB-0001',
              penjualId: 'penjual-uuid-123',
              tanggalTransaksi: now,
              jenisPembayaran: const Value('tunai'),
              deviceId: const Value('MOB-KASIR-01'),
            ),
          );

      // Masukkan detail item
      await db.into(db.localTransaksiItem).insert(
            LocalTransaksiItemCompanion.insert(
              id: 'item-offline-001',
              transaksiId: 'trx-offline-001',
              jenisBuahId: 1,
              hargaPerKg: '2500',
              beratKg: '1200.50',
              subtotal: '3001250',
            ),
          );

      // Verifikasi query unsynced data
      final unsynced = await db.getUnsyncedTransaksi();
      expect(unsynced.length, equals(1));
      expect(unsynced.first.kodeTransaksi, equals('TRX-20260930-MOB-0001'));
      expect(unsynced.first.isSynced, isFalse);
      expect(unsynced.first.deviceId, equals('MOB-KASIR-01'));

      // Verifikasi query item
      final items = await db.getItemsByTransaksiId('trx-offline-001');
      expect(items.length, equals(1));
      expect(items.first.subtotal, equals('3001250'));

      // Verifikasi hitung total unsynced count
      final totalUnsynced = await db.getTotalUnsyncedCount();
      expect(totalUnsynced, equals(1));

      // Tandai sudah tersinkron
      await db.markTransaksiSynced('trx-offline-001');
      final unsyncedAfter = await db.getUnsyncedTransaksi();
      expect(unsyncedAfter, isEmpty);

      final totalUnsyncedAfter = await db.getTotalUnsyncedCount();
      expect(totalUnsyncedAfter, equals(0));
    });

    test('Insert and query LocalPengirimanPabrik and LocalPengeluaran', () async {
      final now = DateTime.now();

      // Insert Pengiriman
      await db.into(db.localPengirimanPabrik).insert(
            LocalPengirimanPabrikCompanion.insert(
              id: 'spb-uuid-001',
              noSpb: 'SPB-20260930-001',
              pabrikId: 'pabrik-uuid-1',
              tanggalKirim: now,
              noKendaraan: 'BK 1234 AA',
              namaSupir: 'Budi Santoso',
              beratKirimKg: '8500',
            ),
          );

      // Insert Pengeluaran
      await db.into(db.localPengeluaran).insert(
            LocalPengeluaranCompanion.insert(
              id: 'out-uuid-001',
              jenisPengeluaranId: 1,
              nominal: '150000',
              tanggal: now,
              keterangan: 'Makan siang supir',
            ),
          );

      final totalUnsynced = await db.getTotalUnsyncedCount();
      expect(totalUnsynced, equals(2));
    });
  });
}
