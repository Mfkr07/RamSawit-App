import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/app_database.dart';
import '../../core/supabase_client.dart';
import '../../core/utils/app_exception_helper.dart';
import '../../models/paginated_result.dart';
import '../../models/pengeluaran.dart';

/// Repository untuk pencatatan dan riwayat pengeluaran operasional (`public.pengeluaran`).
class PengeluaranRepository {
  final SupabaseClient? _client;
  final AppDatabase? _db;

  // In-memory demo list untuk mode testing / offline (bersih tanpa dummy)
  static final List<Pengeluaran> _demoList = [];
  static List<Pengeluaran> get demoList => _demoList;

  static void seedDemoDataForTesting() {
    _demoList.clear();
    _demoList.addAll([
      Pengeluaran(
        id: 'pg-001',
        tanggalPengeluaran: DateTime.now(),
        jenisPengeluaranId: 1,
        jenisPengeluaranNama: 'BBM/Transportasi',
        keterangan: 'Beli solar truk pelangsir 50 liter',
        nominal: Decimal.parse('340000'),
        createdBy: 'admin-001',
        createdByName: 'Admin Sawit',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Pengeluaran(
        id: 'pg-002',
        tanggalPengeluaran: DateTime.now().subtract(const Duration(days: 1)),
        jenisPengeluaranId: 5,
        jenisPengeluaranNama: 'Lain-lain',
        keterangan: 'Beli air galon & konsumsi ramp',
        nominal: Decimal.parse('85000'),
        createdBy: 'kasir-001',
        createdByName: 'Kasir Utama',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      ),
      Pengeluaran(
        id: 'pg-003',
        tanggalPengeluaran: DateTime.now().subtract(const Duration(days: 3)),
        jenisPengeluaranId: 3,
        jenisPengeluaranNama: 'Perawatan Kendaraan',
        keterangan: 'Tambal ban dan ganti oli gardan dump truck',
        nominal: Decimal.parse('450000'),
        createdBy: 'admin-001',
        createdByName: 'Admin Sawit',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Pengeluaran(
        id: 'pg-004',
        tanggalPengeluaran: DateTime.now().subtract(const Duration(days: 6)),
        jenisPengeluaranId: 2,
        jenisPengeluaranNama: 'Gaji/Upah',
        keterangan: 'Upah mingguan kuli muat sawit (2 orang)',
        nominal: Decimal.parse('1200000'),
        createdBy: 'admin-001',
        createdByName: 'Admin Sawit',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ]);
  }

  static void clearDemoData() {
    _demoList.clear();
  }

  PengeluaranRepository([this._client, this._db]);

  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;

  /// Mengambil daftar pengeluaran terpaginasi dengan filter periode dan kategori
  Future<PaginatedResult<Pengeluaran>> fetchPengeluaran({
    DateTime? startDate,
    DateTime? endDate,
    int? jenisPengeluaranId,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (isDemoMode) {
      final db = _db;
      if (db != null && _demoList.isEmpty) {
        try {
          final localRows = await db.select(db.localPengeluaran).get();
          for (final row in localRows) {
            _demoList.add(Pengeluaran(
              id: row.id,
              tanggalPengeluaran: row.tanggal,
              jenisPengeluaranId: row.jenisPengeluaranId,
              nominal: Decimal.parse(row.nominal),
              keterangan: row.keterangan,
              metodePembayaran: row.metodePembayaran,
              createdBy: row.createdBy,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ));
          }
        } catch (_) {}
      }
      await Future.delayed(const Duration(milliseconds: 200));
      var filtered = List<Pengeluaran>.from(_demoList);

      if (startDate != null) {
        final startBoundary = DateTime(startDate.year, startDate.month, startDate.day);
        filtered = filtered
            .where((p) =>
                p.tanggalPengeluaran.isAtSameMomentAs(startBoundary) ||
                p.tanggalPengeluaran.isAfter(startBoundary))
            .toList();
      }

      if (endDate != null) {
        final endBoundary = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        filtered = filtered
            .where((p) =>
                p.tanggalPengeluaran.isAtSameMomentAs(endBoundary) ||
                p.tanggalPengeluaran.isBefore(endBoundary))
            .toList();
      }

      if (jenisPengeluaranId != null && jenisPengeluaranId > 0) {
        filtered = filtered
            .where((p) => p.jenisPengeluaranId == jenisPengeluaranId)
            .toList();
      }

      filtered.sort((a, b) => b.tanggalPengeluaran.compareTo(a.tanggalPengeluaran));

      final totalCount = filtered.length;
      final startIndex = (page - 1) * pageSize;
      final endIndex = (startIndex + pageSize) > totalCount
          ? totalCount
          : startIndex + pageSize;

      final items = startIndex < totalCount
          ? filtered.sublist(startIndex, endIndex)
          : <Pengeluaran>[];

      return PaginatedResult<Pengeluaran>(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    }

    try {
      var countQuery = _client!.from('pengeluaran').select('id');
      if (startDate != null) {
        countQuery = countQuery.gte(
          'tanggal_pengeluaran',
          startDate.toIso8601String().split('T').first,
        );
      }
      if (endDate != null) {
        countQuery = countQuery.lte(
          'tanggal_pengeluaran',
          endDate.toIso8601String().split('T').first,
        );
      }
      if (jenisPengeluaranId != null && jenisPengeluaranId > 0) {
        countQuery = countQuery.eq('jenis_pengeluaran_id', jenisPengeluaranId);
      }

      final countResponse = await countQuery;
      final totalCount = (countResponse as List).length;

      var query = _client
          .from('pengeluaran')
          .select('*, jenis_pengeluaran(nama)');

      if (startDate != null) {
        query = query.gte(
          'tanggal_pengeluaran',
          startDate.toIso8601String().split('T').first,
        );
      }
      if (endDate != null) {
        query = query.lte(
          'tanggal_pengeluaran',
          endDate.toIso8601String().split('T').first,
        );
      }
      if (jenisPengeluaranId != null && jenisPengeluaranId > 0) {
        query = query.eq('jenis_pengeluaran_id', jenisPengeluaranId);
      }

      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final response = await query
          .order('tanggal_pengeluaran', ascending: false)
          .order('created_at', ascending: false)
          .range(from, to);

      final items = (response as List<dynamic>)
          .map((json) => Pengeluaran.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedResult<Pengeluaran>(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      if (isDemoMode) {
        return PaginatedResult<Pengeluaran>(
          items: _demoList,
          totalCount: _demoList.length,
          page: 1,
          pageSize: pageSize,
        );
      }
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Mengambil semua pengeluaran dalam filter tanpa limit halaman (untuk Export Laporan)
  Future<List<Pengeluaran>> fetchAllPengeluaranForExport({
    DateTime? startDate,
    DateTime? endDate,
    int? jenisPengeluaranId,
  }) async {
    final paginated = await fetchPengeluaran(
      startDate: startDate,
      endDate: endDate,
      jenisPengeluaranId: jenisPengeluaranId,
      page: 1,
      pageSize: 10000,
    );
    return paginated.items;
  }

  /// Tambah catatan pengeluaran baru
  Future<Pengeluaran> createPengeluaran({
    required DateTime tanggal,
    required int jenisPengeluaranId,
    String? keterangan,
    required Decimal nominal,
    String? jenisPengeluaranNama,
    String metodePembayaran = 'tunai',
  }) async {
    if (nominal <= Decimal.zero) {
      throw const FormatException('Nominal pengeluaran harus lebih besar dari Rp 0.');
    }

    final userId = _client?.auth.currentUser?.id;
    final userName = _client?.auth.currentUser?.userMetadata?['nama'] as String? ?? 'User';

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      final newId = 'pg-${DateTime.now().millisecondsSinceEpoch}';
      final created = Pengeluaran(
        id: newId,
        tanggalPengeluaran: tanggal,
        jenisPengeluaranId: jenisPengeluaranId,
        jenisPengeluaranNama: jenisPengeluaranNama ?? 'Operasional',
        keterangan: keterangan?.trim(),
        nominal: nominal,
        metodePembayaran: metodePembayaran,
        createdBy: userId ?? 'demo-user',
        createdByName: userName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _demoList.insert(0, created);

      final db = _db;
      if (db != null) {
        try {
          await db.into(db.localPengeluaran).insert(
                LocalPengeluaranCompanion.insert(
                  id: newId,
                  jenisPengeluaranId: jenisPengeluaranId,
                  nominal: nominal.toString(),
                  tanggal: tanggal,
                  keterangan: keterangan?.trim() ?? '',
                  metodePembayaran: Value(metodePembayaran),
                  status: const Value('aktif'),
                  createdBy: Value(userId ?? 'demo-user'),
                  isSynced: const Value(false),
                ),
              );
        } catch (_) {}
      }

      return created;
    }

    try {
      final insertData = {
        'tanggal_pengeluaran': tanggal.toIso8601String().split('T').first,
        'jenis_pengeluaran_id': jenisPengeluaranId,
        'nominal': nominal.toString(),
        'metode_pembayaran': metodePembayaran,
        if (keterangan != null && keterangan.trim().isNotEmpty)
          'keterangan': keterangan.trim(),
        'created_by': ?userId,
      };

      final response = await _client!
          .from('pengeluaran')
          .insert(insertData)
          .select('*, jenis_pengeluaran(nama)')
          .single();

      return Pengeluaran.fromJson(response);
    } catch (e) {
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Edit catatan pengeluaran
  Future<Pengeluaran> updatePengeluaran(
    String id, {
    required DateTime tanggal,
    required int jenisPengeluaranId,
    String? keterangan,
    required Decimal nominal,
    String? jenisPengeluaranNama,
    String? metodePembayaran,
  }) async {
    if (nominal <= Decimal.zero) {
      throw const FormatException('Nominal pengeluaran harus lebih besar dari Rp 0.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      final idx = _demoList.indexWhere((p) => p.id == id);
      if (idx == -1) {
        throw const FormatException('Data pengeluaran tidak ditemukan.');
      }
      final current = _demoList[idx];
      final updated = current.copyWith(
        tanggalPengeluaran: tanggal,
        jenisPengeluaranId: jenisPengeluaranId,
        jenisPengeluaranNama: jenisPengeluaranNama ?? current.jenisPengeluaranNama,
        keterangan: keterangan?.trim(),
        nominal: nominal,
        metodePembayaran: metodePembayaran ?? current.metodePembayaran,
        updatedAt: DateTime.now(),
      );
      _demoList[idx] = updated;

      final db = _db;
      if (db != null) {
        try {
          await (db.update(db.localPengeluaran)
                ..where((p) => p.id.equals(id)))
              .write(
            LocalPengeluaranCompanion(
              jenisPengeluaranId: Value(jenisPengeluaranId),
              nominal: Value(nominal.toString()),
              tanggal: Value(tanggal),
              keterangan: Value(keterangan?.trim() ?? ''),
              metodePembayaran: metodePembayaran != null
                  ? Value(metodePembayaran)
                  : const Value.absent(),
              isSynced: const Value(false),
            ),
          );
        } catch (_) {}
      }

      return updated;
    }

    try {
      final updateData = {
        'tanggal_pengeluaran': tanggal.toIso8601String().split('T').first,
        'jenis_pengeluaran_id': jenisPengeluaranId,
        'nominal': nominal.toString(),
        'keterangan': keterangan?.trim(),
        'metode_pembayaran': ?metodePembayaran,
      };

      final response = await _client!
          .from('pengeluaran')
          .update(updateData)
          .eq('id', id)
          .select('*, jenis_pengeluaran(nama)')
          .single();

      return Pengeluaran.fromJson(response);
    } catch (e) {
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Hapus fisik catatan pengeluaran (bukan soft delete, FR-9.3)
  Future<void> deletePengeluaran(String id) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      _demoList.removeWhere((p) => p.id == id);
      final db = _db;
      if (db != null) {
        try {
          await (db.delete(db.localPengeluaran)
                ..where((p) => p.id.equals(id)))
              .go();
        } catch (_) {}
      }
      return;
    }

    try {
      await _client!.from('pengeluaran').delete().eq('id', id);
    } catch (e) {
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }
}

final pengeluaranRepositoryProvider = Provider<PengeluaranRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return PengeluaranRepository(client, db);
});
