import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  LocalPenjual,
  LocalJenisBuah,
  LocalTransaksi,
  LocalTransaksiItem,
  LocalPabrik,
  LocalPengirimanPabrik,
  LocalJenisPengeluaran,
  LocalPengeluaran,
  LocalTopupSaldo,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(
                localPengeluaran, localPengeluaran.metodePembayaran);
          }
        },
      );

  static QueryExecutor _openConnection() {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return NativeDatabase.memory();
    }

    return driftDatabase(
      name: 'sawit_offline_db',
      native: const DriftNativeOptions(
        shareAcrossIsolates: true,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (result) {
          if (result.missingFeatures.isNotEmpty) {
            // ignore: avoid_print
            print('Drift Web warning: missing features: ${result.missingFeatures}');
          }
        },
      ),
    );
  }

  // --- QUERY HELPER TRANSAKSI OFFLINE ---

  /// Mengambil semua transaksi lokal yang belum disinkronkan ke cloud
  Future<List<LocalTransaksiData>> getUnsyncedTransaksi() {
    return (select(localTransaksi)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Menandai transaksi lokal sebagai telah tersinkron
  Future<int> markTransaksiSynced(String id) {
    return (update(localTransaksi)..where((t) => t.id.equals(id))).write(
      const LocalTransaksiCompanion(
        isSynced: Value(true),
      ),
    );
  }

  /// Mengambil item transaksi berdasarkan transaksiId
  Future<List<LocalTransaksiItemData>> getItemsByTransaksiId(String transaksiId) {
    return (select(localTransaksiItem)..where((t) => t.transaksiId.equals(transaksiId))).get();
  }

  /// Menghitung total data yang belum tersinkron di semua modul
  Future<int> getTotalUnsyncedCount() async {
    final tCount = await (select(localTransaksi)..where((t) => t.isSynced.equals(false))).get().then((l) => l.length);
    final pCount = await (select(localPengirimanPabrik)..where((p) => p.isSynced.equals(false))).get().then((l) => l.length);
    final oCount = await (select(localPengeluaran)..where((o) => o.isSynced.equals(false))).get().then((l) => l.length);
    final sCount = await (select(localTopupSaldo)..where((s) => s.isSynced.equals(false))).get().then((l) => l.length);
    return tCount + pCount + oCount + sCount;
  }
}

/// Riverpod provider untuk instance AppDatabase singleton
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
