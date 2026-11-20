import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import '../../core/utils/app_exception_helper.dart';
import '../../models/jenis_pengeluaran.dart';

/// Repository untuk mengelola master kategori pengeluaran (`public.jenis_pengeluaran`).
class JenisPengeluaranRepository {
  final SupabaseClient? _client;

  static final List<JenisPengeluaran> _demoList = [
    const JenisPengeluaran(id: 1, nama: 'BBM/Transportasi', isActive: true),
    const JenisPengeluaran(id: 2, nama: 'Gaji/Upah', isActive: true),
    const JenisPengeluaran(id: 3, nama: 'Perawatan Kendaraan', isActive: true),
    const JenisPengeluaran(id: 4, nama: 'Operasional Kantor', isActive: true),
    const JenisPengeluaran(id: 5, nama: 'Lain-lain', isActive: true),
  ];

  JenisPengeluaranRepository(this._client);

  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;

  /// Mengambil daftar kategori pengeluaran
  Future<List<JenisPengeluaran>> fetchJenisPengeluaran({
    bool onlyActive = false,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      var list = List<JenisPengeluaran>.from(_demoList);
      if (onlyActive) {
        list = list.where((item) => item.isActive).toList();
      }
      list.sort((a, b) => a.nama.compareTo(b.nama));
      return list;
    }

    try {
      var query = _client!.from('jenis_pengeluaran').select();
      if (onlyActive) {
        query = query.eq('is_active', true);
      }
      final response = await query.order('nama');
      return (response as List<dynamic>)
          .map((json) => JenisPengeluaran.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (isDemoMode) {
        return _demoList.where((item) => !onlyActive || item.isActive).toList();
      }
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Tambah jenis pengeluaran baru (Khusus Admin)
  Future<JenisPengeluaran> createJenisPengeluaran(String nama) async {
    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw const FormatException('Nama kategori pengeluaran tidak boleh kosong.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      final exists = _demoList.any(
        (e) => e.nama.toLowerCase() == cleanNama.toLowerCase(),
      );
      if (exists) {
        throw const FormatException('Kategori pengeluaran dengan nama tersebut sudah ada.');
      }
      final nextId = _demoList.isEmpty
          ? 1
          : _demoList.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      final created = JenisPengeluaran(
        id: nextId,
        nama: cleanNama,
        isActive: true,
      );
      _demoList.add(created);
      return created;
    }

    try {
      final response = await _client!
          .from('jenis_pengeluaran')
          .insert({'nama': cleanNama, 'is_active': true})
          .select()
          .single();

      return JenisPengeluaran.fromJson(response);
    } catch (e) {
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Ubah nama atau toggle aktif/nonaktif jenis pengeluaran (Khusus Admin, Soft-delete)
  Future<JenisPengeluaran> updateJenisPengeluaran(
    int id, {
    String? nama,
    bool? isActive,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      final idx = _demoList.indexWhere((e) => e.id == id);
      if (idx == -1) {
        throw const FormatException('Kategori pengeluaran tidak ditemukan.');
      }
      final current = _demoList[idx];
      final updated = current.copyWith(
        nama: nama?.trim().isNotEmpty == true ? nama!.trim() : current.nama,
        isActive: isActive ?? current.isActive,
      );
      _demoList[idx] = updated;
      return updated;
    }

    try {
      final updateData = <String, dynamic>{};
      if (nama != null && nama.trim().isNotEmpty) {
        updateData['nama'] = nama.trim();
      }
      if (isActive != null) {
        updateData['is_active'] = isActive;
      }

      if (updateData.isEmpty) {
        final current = await _client!
            .from('jenis_pengeluaran')
            .select()
            .eq('id', id)
            .single();
        return JenisPengeluaran.fromJson(current);
      }

      final response = await _client!
          .from('jenis_pengeluaran')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return JenisPengeluaran.fromJson(response);
    } catch (e) {
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }
}

final jenisPengeluaranRepositoryProvider =
    Provider<JenisPengeluaranRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return JenisPengeluaranRepository(client);
});
