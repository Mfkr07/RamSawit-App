import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/app_database.dart';
import '../../core/supabase_client.dart';
import '../../core/utils/app_exception_helper.dart';
import '../../models/penjual.dart';

/// Repository untuk mengelola data master penjual (tabel `public.penjual`).
/// Mendukung Supabase PostgREST dengan fallback demo data lokal.
class PenjualRepository {
  final SupabaseClient? _client;
  final AppDatabase? _db;

  // In-memory data penjual untuk demo lokal jika remote Supabase belum terhubung (bersih tanpa dummy)
  static final List<Penjual> _demoList = [];

  static void seedDemoDataForTesting() {
    _demoList.clear();
    _demoList.addAll([
      Penjual(
        id: 'p-001',
        nama: 'Haji Sukirman (Koperasi Sawit Makmur)',
        noTelepon: '081234567890',
        alamat: 'Desa Sawit Makmur RT 02 / RW 01',
        catatan: 'Petani plasma kebun inti blok A',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Penjual(
        id: 'p-002',
        nama: 'Pak Joko Sutrisno',
        noTelepon: '085298765432',
        alamat: 'Kebun Mandiri KM 14',
        catatan: 'Hasil panen TBS besar',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Penjual(
        id: 'p-003',
        nama: 'Bapak Ahmad Fadli',
        noTelepon: '082111223344',
        alamat: 'Dusun Harapan Baru',
        catatan: 'Petani swadaya',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }

  static void clearDemoData() {
    _demoList.clear();
  }

  PenjualRepository(this._client, [this._db]);

  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;

  /// Mengambil daftar penjual dengan pencarian nama dan filter status aktif
  Future<List<Penjual>> getPenjualList({
    String? searchQuery,
    bool includeInactive = false,
  }) async {
    if (isDemoMode) {
      if (_db != null && _demoList.isEmpty) {
        try {
          final localList = await _db.select(_db.localPenjual).get();
          for (final lp in localList) {
            if (!_demoList.any((p) => p.id == lp.id)) {
              _demoList.add(Penjual(
                id: lp.id,
                nama: lp.nama,
                noTelepon: lp.noTelepon,
                alamat: lp.alamat,
                catatan: lp.catatan,
                isActive: lp.isActive,
                createdAt: lp.createdAt,
                updatedAt: lp.updatedAt,
              ));
            }
          }
        } catch (_) {}
      }
      await Future.delayed(const Duration(milliseconds: 150));
      var list = List<Penjual>.from(_demoList);

      if (!includeInactive) {
        list = list.where((p) => p.isActive).toList();
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        list = list
            .where((p) =>
                p.nama.toLowerCase().contains(query) ||
                (p.noTelepon != null && p.noTelepon!.contains(query)))
            .toList();
      }

      list.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
      return list;
    }

    try {
      var queryBuilder = _client!.from('penjual').select();

      if (!includeInactive) {
        queryBuilder = queryBuilder.eq('is_active', true);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        queryBuilder = queryBuilder.ilike('nama', '%${searchQuery.trim()}%');
      }

      final response = await queryBuilder.order('nama', ascending: true);
      return (response as List<dynamic>)
          .map((item) => Penjual.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(
        'Gagal memuat data penjual: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Tambah data penjual baru
  Future<Penjual> createPenjual({
    required String nama,
    String? noTelepon,
    String? alamat,
    String? catatan,
    String? createdBy,
  }) async {
    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama penjual tidak boleh kosong.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      final newId = 'p-demo-${DateTime.now().millisecondsSinceEpoch}';
      final newPenjual = Penjual(
        id: newId,
        nama: cleanNama,
        noTelepon: noTelepon?.trim().isEmpty == true ? null : noTelepon?.trim(),
        alamat: alamat?.trim().isEmpty == true ? null : alamat?.trim(),
        catatan: catatan?.trim().isEmpty == true ? null : catatan?.trim(),
        isActive: true,
        createdBy: createdBy ?? 'demo-user-id-12345',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _demoList.insert(0, newPenjual);

      if (_db != null) {
        try {
          await _db.into(_db.localPenjual).insert(
                LocalPenjualCompanion.insert(
                  id: newId,
                  nama: cleanNama,
                  noTelepon: Value(noTelepon),
                  alamat: Value(alamat),
                  catatan: Value(catatan),
                  isActive: const Value(true),
                  createdBy: Value(createdBy ?? 'demo-user-id-12345'),
                ),
              );
        } catch (_) {}
      }

      return newPenjual;
    }

    try {
      final insertData = {
        'nama': cleanNama,
        'no_telepon': noTelepon?.trim().isEmpty == true ? null : noTelepon?.trim(),
        'alamat': alamat?.trim().isEmpty == true ? null : alamat?.trim(),
        'catatan': catatan?.trim().isEmpty == true ? null : catatan?.trim(),
        'is_active': true,
        'created_by': ?createdBy,
      };

      final response =
          await _client!.from('penjual').insert(insertData).select().single();
      return Penjual.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal menyimpan penjual baru: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Ubah data penjual
  Future<Penjual> updatePenjual({
    required String id,
    required String nama,
    String? noTelepon,
    String? alamat,
    String? catatan,
  }) async {
    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama penjual tidak boleh kosong.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _demoList.indexWhere((p) => p.id == id);
      if (index == -1) throw Exception('Penjual tidak ditemukan.');

      final updated = _demoList[index].copyWith(
        nama: cleanNama,
        noTelepon: noTelepon?.trim().isEmpty == true ? null : noTelepon?.trim(),
        alamat: alamat?.trim().isEmpty == true ? null : alamat?.trim(),
        catatan: catatan?.trim().isEmpty == true ? null : catatan?.trim(),
        updatedAt: DateTime.now(),
      );
      _demoList[index] = updated;
      return updated;
    }

    try {
      final updateData = {
        'nama': cleanNama,
        'no_telepon': noTelepon?.trim().isEmpty == true ? null : noTelepon?.trim(),
        'alamat': alamat?.trim().isEmpty == true ? null : alamat?.trim(),
        'catatan': catatan?.trim().isEmpty == true ? null : catatan?.trim(),
      };

      final response = await _client!
          .from('penjual')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();
      return Penjual.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal memperbarui data penjual: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Soft delete: Mengubah status aktif penjual (is_active = true / false)
  Future<void> toggleActiveStatus(String id, bool currentStatus) async {
    final newStatus = !currentStatus;

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _demoList.indexWhere((p) => p.id == id);
      if (index != -1) {
        _demoList[index] = _demoList[index].copyWith(
          isActive: newStatus,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }

    try {
      await _client!.from('penjual').update({
        'is_active': newStatus,
      }).eq('id', id);
    } catch (e) {
      throw Exception(
        'Gagal mengubah status penjual: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }
}

final penjualRepositoryProvider = Provider<PenjualRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return PenjualRepository(client, db);
});
