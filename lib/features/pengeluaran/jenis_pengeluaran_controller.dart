import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/jenis_pengeluaran.dart';
import 'jenis_pengeluaran_repository.dart';

/// Provider semua kategori jenis pengeluaran (untuk halaman kelola Admin)
final jenisPengeluaranListProvider =
    FutureProvider.autoDispose<List<JenisPengeluaran>>((ref) async {
  final repo = ref.watch(jenisPengeluaranRepositoryProvider);
  return repo.fetchJenisPengeluaran(onlyActive: false);
});

/// Provider kategori jenis pengeluaran aktif saja (untuk dropdown form input pengeluaran)
final jenisPengeluaranActiveListProvider =
    FutureProvider.autoDispose<List<JenisPengeluaran>>((ref) async {
  final repo = ref.watch(jenisPengeluaranRepositoryProvider);
  return repo.fetchJenisPengeluaran(onlyActive: true);
});

/// Controller untuk aksi mutasi master kategori pengeluaran (Khusus Admin)
class JenisPengeluaranController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  JenisPengeluaranController(this._ref) : super(const AsyncValue.data(null));

  JenisPengeluaranRepository get _repo =>
      _ref.read(jenisPengeluaranRepositoryProvider);

  Future<bool> createJenis(String nama) async {
    state = const AsyncValue.loading();
    try {
      await _repo.createJenisPengeluaran(nama);
      state = const AsyncValue.data(null);
      _ref.invalidate(jenisPengeluaranListProvider);
      _ref.invalidate(jenisPengeluaranActiveListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateNama(int id, String namaBaru) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateJenisPengeluaran(id, nama: namaBaru);
      state = const AsyncValue.data(null);
      _ref.invalidate(jenisPengeluaranListProvider);
      _ref.invalidate(jenisPengeluaranActiveListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> toggleStatus(int id, bool currentStatus) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateJenisPengeluaran(id, isActive: !currentStatus);
      state = const AsyncValue.data(null);
      _ref.invalidate(jenisPengeluaranListProvider);
      _ref.invalidate(jenisPengeluaranActiveListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final jenisPengeluaranControllerProvider =
    StateNotifierProvider<JenisPengeluaranController, AsyncValue<void>>((ref) {
  return JenisPengeluaranController(ref);
});
