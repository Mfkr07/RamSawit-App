import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/core/database/app_database.dart';
import 'package:transaksi_sawit_app/core/sync/sync_engine.dart';
import 'package:transaksi_sawit_app/core/sync/sync_status_bar.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Tugas Bagian 28: Sync Engine & SyncStatusBar Tests', () {
    test('SyncEngine initializes in idle/offline and counts unsynced records', () async {
      final engine = SyncEngine(db);

      // Awalnya 0 unsynced
      expect(engine.state.unsyncedCount, equals(0));

      // Tambahkan data transaksi lokal
      await db.into(db.localTransaksi).insert(
            LocalTransaksiCompanion.insert(
              id: 'trx-sync-01',
              kodeTransaksi: 'TRX-SYNC-001',
              penjualId: 'penjual-uuid-1',
              tanggalTransaksi: DateTime.now(),
            ),
          );

      // Refresh count
      final count = await engine.refreshUnsyncedCount();
      expect(count, equals(1));
      expect(engine.state.unsyncedCount, equals(1));

      // Eksekusi syncNow tanpa supabase client aktual -> beralih ke state offline dengan data tersimpan lokal
      await engine.syncNow();
      expect(engine.state.status, equals(SyncStatus.offline));
      expect(engine.state.isOnline, isFalse);
      expect(engine.state.unsyncedCount, equals(1));

      engine.dispose();
    });

    testWidgets('SyncStatusBar renders correctly based on sync engine states', (tester) async {
      final engine = SyncEngine(db);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            syncEngineProvider.overrideWith((ref) => engine),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncStatusBar(),
            ),
          ),
        ),
      );

      // 1. Kondisi Idle / Tersinkron
      expect(find.text('Data tersinkron sempurna'), findsOneWidget);
      expect(find.text('Sinkron'), findsOneWidget);

      // 2. Tambah data lokal dan refresh
      await db.into(db.localTransaksi).insert(
            LocalTransaksiCompanion.insert(
              id: 'trx-sync-02',
              kodeTransaksi: 'TRX-SYNC-002',
              penjualId: 'penjual-uuid-2',
              tanggalTransaksi: DateTime.now(),
            ),
          );
      await engine.refreshUnsyncedCount();
      await tester.pump();

      expect(find.text('1 transaksi tersimpan lokal (menunggu koneksi)'), findsOneWidget);
    });
  });
}
