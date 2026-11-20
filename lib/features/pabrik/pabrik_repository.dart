import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/app_database.dart';
import '../../core/supabase_client.dart';
import '../../core/utils/app_exception_helper.dart';
import '../../models/pabrik.dart';

/// Repository untuk mengelola master data pabrik tujuan (tabel `public.pabrik`).
/// Mendukung Supabase PostgREST dengan fallback demo data lokal.
class PabrikRepository {
  final SupabaseClient? _client;
  final AppDatabase? _db;

  // In-memory data pabrik untuk demo lokal jika remote Supabase belum terhubung (bersih tanpa dummy)
  static final List<Pabrik> _demoList = [];

  static void seedDemoDataForTesting() {
    _demoList.clear();
    _demoList.addAll([
      Pabrik(
        id: 'pb-001',
        nama: 'PT Sawit Inti Riau',
        alamat: 'Jl. Raya Lintas Timur KM 45, Pelalawan',
        kontak: '08117654321 (Bpk. Hendra - Bagian Timbangan)',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Pabrik(
        id: 'pb-002',
        nama: 'PT Agro Palindo Sejahtera',
        alamat: 'Kawasan Industri Sawit Blok C2, Siak',
        kontak: '08129871234 (Ibu Dewi - Kasir PKS)',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Pabrik(
        id: 'pb-003',
        nama: 'PKS Makmur Sentosa',
        alamat: 'Desa Lubuk Dalam KM 12',
        kontak: '081377889900',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  static void clearDemoData() {
    _demoList.clear();
  }

  PabrikRepository([this._client, this._db]);

  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;

  /// Mengambil daftar pabrik dengan pencarian nama dan filter status aktif
  Future<List<Pabrik>> getPabrikList({
    String? searchQuery,
    bool includeInactive = false,
  }) async {
    if (isDemoMode) {
      final db = _db;
      if (db != null && _demoList.isEmpty) {
        try {
          final localRows = await db.select(db.localPabrik).get();
          for (final row in localRows) {
            _demoList.add(Pabrik(
              id: row.id,
              nama: row.nama,
              alamat: row.lokasi,
              kontak: row.kontak,
              isActive: row.isActive,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ));
          }
        } catch (_) {}
      }
      await Future.delayed(const Duration(milliseconds: 250));
      var list = List<Pabrik>.from(_demoList);

      if (!includeInactive) {
        list = list.where((p) => p.isActive).toList();
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        list = list
            .where((p) =>
                p.nama.toLowerCase().contains(query) ||
                (p.alamat != null && p.alamat!.toLowerCase().contains(query)) ||
                (p.kontak != null && p.kontak!.toLowerCase().contains(query)))
            .toList();
      }

      list.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
      return list;
    }

    try {
      var queryBuilder = _client!.from('pabrik').select();

      if (!includeInactive) {
        queryBuilder = queryBuilder.eq('is_active', true);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        queryBuilder = queryBuilder.ilike('nama', '%${searchQuery.trim()}%');
      }

      final response = await queryBuilder.order('nama', ascending: true);
      return (response as List<dynamic>)
          .map((item) => Pabrik.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(
        'Gagal memuat data pabrik: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Tambah data pabrik baru
  Future<Pabrik> createPabrik({
    required String nama,
    String? alamat,
    String? kontak,
    String? createdBy,
  }) async {
    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama pabrik tidak boleh kosong.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final newPabrik = Pabrik(
        id: 'pb-demo-${DateTime.now().millisecondsSinceEpoch}',
        nama: cleanNama,
        alamat: alamat?.trim().isEmpty == true ? null : alamat?.trim(),
        kontak: kontak?.trim().isEmpty == true ? null : kontak?.trim(),
        isActive: true,
        createdBy: createdBy ?? 'demo-user-id-12345',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _demoList.insert(0, newPabrik);

      final db = _db;
      if (db != null) {
        try {
          await db.into(db.localPabrik).insert(
                LocalPabrikCompanion.insert(
                  id: newPabrik.id,
                  nama: cleanNama,
                  lokasi: Value(alamat?.trim()),
                  kontak: Value(kontak?.trim()),
                  isActive: const Value(true),
                  isSynced: const Value(false),
                ),
              );
        } catch (_) {}
      }

      return newPabrik;
    }

    try {
      final insertData = {
        'nama': cleanNama,
        'alamat': alamat?.trim().isEmpty == true ? null : alamat?.trim(),
        'kontak': kontak?.trim().isEmpty == true ? null : kontak?.trim(),
        'is_active': true,
        'created_by': ?createdBy,
      };

      final response =
          await _client!.from('pabrik').insert(insertData).select().single();
      return Pabrik.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal menyimpan pabrik baru: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Ubah data pabrik
  Future<Pabrik> updatePabrik({
    required String id,
    required String nama,
    String? alamat,
    String? kontak,
  }) async {
    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama pabrik tidak boleh kosong.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 250));
      final index = _demoList.indexWhere((p) => p.id == id);
      if (index == -1) throw Exception('Pabrik tidak ditemukan.');

      final updated = _demoList[index].copyWith(
        nama: cleanNama,
        alamat: alamat?.trim().isEmpty == true ? null : alamat?.trim(),
        kontak: kontak?.trim().isEmpty == true ? null : kontak?.trim(),
        updatedAt: DateTime.now(),
      );
      _demoList[index] = updated;

      final db = _db;
      if (db != null) {
        try {
          await (db.update(db.localPabrik)..where((p) => p.id.equals(id)))
              .write(
            LocalPabrikCompanion(
              nama: Value(cleanNama),
              lokasi: Value(alamat?.trim()),
              kontak: Value(kontak?.trim()),
              isSynced: const Value(false),
            ),
          );
        } catch (_) {}
      }

      return updated;
    }

    try {
      final updateData = {
        'nama': cleanNama,
        'alamat': alamat?.trim().isEmpty == true ? null : alamat?.trim(),
        'kontak': kontak?.trim().isEmpty == true ? null : kontak?.trim(),
      };

      final response = await _client!
          .from('pabrik')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();
      return Pabrik.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal memperbarui data pabrik: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Soft delete: Mengubah status aktif pabrik (is_active = true / false)
  Future<void> toggleActiveStatus(String id, bool currentStatus) async {
    final newStatus = !currentStatus;

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _demoList.indexWhere((p) => p.id == id);
      if (index != -1) {
        _demoList[index] = _demoList[index].copyWith(
          isActive: newStatus,
          updatedAt: DateTime.now(),
        );
        final db = _db;
        if (db != null) {
          try {
            await (db.update(db.localPabrik)..where((p) => p.id.equals(id)))
                .write(
              LocalPabrikCompanion(
                isActive: Value(newStatus),
                isSynced: const Value(false),
              ),
            );
          } catch (_) {}
        }
      }
      return;
    }

    try {
      await _client!.from('pabrik').update({
        'is_active': newStatus,
      }).eq('id', id);
    } catch (e) {
      throw Exception(
        'Gagal mengubah status pabrik: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }
}

final pabrikRepositoryProvider = Provider<PabrikRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return PabrikRepository(client, db);
});
