import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import '../../models/jenis_buah.dart';

/// Repository untuk membaca master jenis buah (tabel `public.jenis_buah`).
class JenisBuahRepository {
  final SupabaseClient? _client;

  // Master jenis buah bawaan untuk mode offline/demo
  static const List<JenisBuah> _defaultList = [
    JenisBuah(id: 1, kode: 'TB', nama: 'Tandan Besar', isActive: true),
    JenisBuah(id: 2, kode: 'TK', nama: 'Tandan Kecil', isActive: true),
    JenisBuah(id: 3, kode: 'BR', nama: 'Berondolan', isActive: true),
  ];

  JenisBuahRepository(this._client);

  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;

  /// Mengambil daftar master jenis buah yang aktif
  Future<List<JenisBuah>> getActiveJenisBuah() async {
    if (isDemoMode) {
      return _defaultList.where((item) => item.isActive).toList();
    }

    try {
      final response = await _client!
          .from('jenis_buah')
          .select()
          .eq('is_active', true)
          .order('id', ascending: true);

      return (response as List<dynamic>)
          .map((json) => JenisBuah.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback ke list bawaan jika ada gangguan jaringan
      return _defaultList;
    }
  }
}

final jenisBuahRepositoryProvider = Provider<JenisBuahRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return JenisBuahRepository(client);
});

final activeJenisBuahProvider = FutureProvider<List<JenisBuah>>((ref) async {
  final repo = ref.watch(jenisBuahRepositoryProvider);
  return repo.getActiveJenisBuah();
});
