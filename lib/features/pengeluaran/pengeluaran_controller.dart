import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/paginated_result.dart';
import '../../models/pengeluaran.dart';
import 'pengeluaran_filter_state.dart';
import 'pengeluaran_repository.dart';

/// Provider data daftar riwayat pengeluaran terpaginasi
final pengeluaranListProvider =
    FutureProvider.autoDispose<PaginatedResult<Pengeluaran>>((ref) async {
  final filter = ref.watch(pengeluaranFilterProvider);
  final repo = ref.watch(pengeluaranRepositoryProvider);

  return repo.fetchPengeluaran(
    startDate: filter.startDate,
    endDate: filter.endDate,
    jenisPengeluaranId: filter.selectedJenisId,
    page: filter.page,
    pageSize: filter.pageSize,
  );
});

/// Controller untuk operasi mutasi data Pengeluaran
class PengeluaranController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  PengeluaranController(this._ref) : super(const AsyncValue.data(null));

  PengeluaranRepository get _repo => _ref.read(pengeluaranRepositoryProvider);

  Future<bool> createPengeluaran({
    required DateTime tanggal,
    required int jenisPengeluaranId,
    String? keterangan,
    required Decimal nominal,
    String? jenisPengeluaranNama,
    String metodePembayaran = 'tunai',
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.createPengeluaran(
        tanggal: tanggal,
        jenisPengeluaranId: jenisPengeluaranId,
        keterangan: keterangan,
        nominal: nominal,
        jenisPengeluaranNama: jenisPengeluaranNama,
        metodePembayaran: metodePembayaran,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(pengeluaranListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updatePengeluaran(
    String id, {
    required DateTime tanggal,
    required int jenisPengeluaranId,
    String? keterangan,
    required Decimal nominal,
    String? jenisPengeluaranNama,
    String? metodePembayaran,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updatePengeluaran(
        id,
        tanggal: tanggal,
        jenisPengeluaranId: jenisPengeluaranId,
        keterangan: keterangan,
        nominal: nominal,
        jenisPengeluaranNama: jenisPengeluaranNama,
        metodePembayaran: metodePembayaran,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(pengeluaranListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deletePengeluaran(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deletePengeluaran(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(pengeluaranListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final pengeluaranControllerProvider =
    StateNotifierProvider<PengeluaranController, AsyncValue<void>>((ref) {
  return PengeluaranController(ref);
});
