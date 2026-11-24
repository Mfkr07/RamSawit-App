import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:transaksi_sawit_app/core/database/app_database.dart';
import 'package:transaksi_sawit_app/core/supabase_client.dart';

/// Status koneksi & sinkronisasi
enum SyncStatus {
  idle,
  syncing,
  offline,
  error,
}

/// State sinkronisasi untuk UI
class SyncEngineState {
  final SyncStatus status;
  final int unsyncedCount;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final bool isOnline;

  const SyncEngineState({
    this.status = SyncStatus.idle,
    this.unsyncedCount = 0,
    this.lastSyncTime,
    this.errorMessage,
    this.isOnline = true,
  });

  SyncEngineState copyWith({
    SyncStatus? status,
    int? unsyncedCount,
    DateTime? lastSyncTime,
    String? errorMessage,
    bool? isOnline,
  }) {
    return SyncEngineState(
      status: status ?? this.status,
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// Sync Engine untuk mengelola sinkronisasi dua arah antara Drift SQLite dan Supabase
class SyncEngine extends StateNotifier<SyncEngineState> {
  final AppDatabase _db;
  final SupabaseClient? _supabase;
  Timer? _periodicTimer;

  SyncEngine(this._db, [this._supabase]) : super(const SyncEngineState()) {
    refreshUnsyncedCount();
  }

  /// Menghitung ulang jumlah data lokal yang belum terkirim ke cloud
  Future<int> refreshUnsyncedCount() async {
    try {
      final count = await _db.getTotalUnsyncedCount();
      state = state.copyWith(unsyncedCount: count);
      return count;
    } catch (_) {
      return state.unsyncedCount;
    }
  }

  /// Memulai pengecekan periodik otomatis (misal setiap 30 detik)
  void startPeriodicSync({Duration interval = const Duration(seconds: 30)}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) => syncNow());
  }

  /// Menghentikan timer sinkronisasi
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Eksekusi sinkronisasi sekarang
  Future<void> syncNow() async {
    if (state.status == SyncStatus.syncing) return;

    SupabaseClient? client = _supabase;
    if (client == null) {
      try {
        if (SupabaseConfig.isConfigured && Supabase.instance.isInitialized) {
          client = Supabase.instance.client;
        }
      } catch (_) {
        client = null;
      }
    }

    // Periksa apakah koneksi Supabase siap DAN memiliki sesi pengguna terautentikasi
    final hasAuthSession = client?.auth.currentSession != null;

    if (client == null || !SupabaseConfig.isConfigured || !hasAuthSession) {
      final count = await refreshUnsyncedCount();
      state = state.copyWith(
        status: SyncStatus.offline,
        errorMessage: !hasAuthSession && SupabaseConfig.isConfigured
            ? 'Sinkronisasi dijeda: Akun belum terautentikasi di Supabase. Silakan login terlebih dahulu.'
            : 'Sinkronisasi dijeda: Mode Demo aktif. Data transaksi hanya tersimpan di database lokal.',
        isOnline: false,
        unsyncedCount: count,
      );
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing);

    try {
      // 1. PUSH: Kirim transaksi lokal yang belum disinkronkan ke Supabase
      final unsyncedTrx = await _db.getUnsyncedTransaksi();
      for (final trx in unsyncedTrx) {
        // Ambil item transaksi
        final items = await _db.getItemsByTransaksiId(trx.id);

        try {
          // Push header transaksi
          await client.from('transaksi').upsert({
            'id': trx.id,
            'kode_transaksi': trx.kodeTransaksi,
            'penjual_id': trx.penjualId,
            'tanggal_transaksi': trx.tanggalTransaksi.toIso8601String(),
            'status': trx.status,
            'alasan_batal': trx.alasanBatal,
            'jenis_pembayaran': trx.jenisPembayaran,
            'catatan': trx.catatan,
            'created_by': trx.createdBy,
          });

          // Push detail item transaksi
          if (items.isNotEmpty) {
            final itemsData = items
                .map((i) => {
                      'id': i.id,
                      'transaksi_id': i.transaksiId,
                      'jenis_buah_id': i.jenisBuahId,
                      'harga_per_kg': double.tryParse(i.hargaPerKg) ?? 0,
                      'berat_kg': double.tryParse(i.beratKg) ?? 0,
                      'berat_kotor_kg': i.beratKotorKg != null ? double.tryParse(i.beratKotorKg!) : null,
                      'persen_potongan': i.persenPotongan != null ? double.tryParse(i.persenPotongan!) : null,
                      'nilai_potongan_kg': i.nilaiPotonganKg != null ? double.tryParse(i.nilaiPotonganKg!) : null,
                      'subtotal': double.tryParse(i.subtotal) ?? 0,
                    })
                .toList();

            await client.from('transaksi_item').upsert(itemsData);
          }

          // Tandai transaksi sebagai tersinkron
          await _db.markTransaksiSynced(trx.id);
        } catch (e) {
          debugPrint('Sync individual transaction failed for ${trx.id}: $e');
        }
      }

      // 2. Refresh total antrean tersisa
      final remaining = await _db.getTotalUnsyncedCount();

      state = state.copyWith(
        status: SyncStatus.idle,
        isOnline: true,
        unsyncedCount: remaining,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      debugPrint('SyncEngine error: $e');
      final remaining = await _db.getTotalUnsyncedCount();
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
        unsyncedCount: remaining,
      );
    }
  }

  @override
  void dispose() {
    stopPeriodicSync();
    super.dispose();
  }
}

/// Provider Riverpod untuk SyncEngine
final syncEngineProvider = StateNotifierProvider<SyncEngine, SyncEngineState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final client = ref.watch(supabaseClientProvider);
  return SyncEngine(db, client);
});
