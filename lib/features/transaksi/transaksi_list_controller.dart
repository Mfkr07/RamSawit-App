import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/paginated_result.dart';
import '../../models/transaksi.dart';
import 'transaksi_filter_state.dart';
import 'transaksi_repository.dart';

/// State untuk halaman aktif riwayat transaksi (default: halaman 1)
final transaksiPageProvider = StateProvider<int>((ref) => 1);

/// Provider riwayat transaksi membaca langsung dari view `v_transaksi_ringkasan` dengan paginasi (20 item/halaman)
final transaksiListProvider =
    AsyncNotifierProvider<TransaksiListNotifier, PaginatedResult<TransaksiRingkasan>>(() {
  return TransaksiListNotifier();
});

class TransaksiListNotifier
    extends AsyncNotifier<PaginatedResult<TransaksiRingkasan>> {
  TransaksiFilterState? _lastFilter;

  @override
  Future<PaginatedResult<TransaksiRingkasan>> build() async {
    final filter = ref.watch(transaksiFilterProvider);
    final page = ref.watch(transaksiPageProvider);
    final repo = ref.watch(transaksiRepositoryProvider);

    // Jika filter berubah dan saat ini bukan di halaman 1, reset ke halaman 1
    if (_lastFilter != null && _lastFilter != filter) {
      if (page != 1) {
        Future.microtask(() {
          ref.read(transaksiPageProvider.notifier).state = 1;
        });
      }
    }
    _lastFilter = filter;

    return repo.getFilteredRingkasanPaginated(
      page: page,
      pageSize: 20,
      startDate: filter.startDate,
      endDate: filter.endDate,
      penjualId: filter.selectedPenjualId,
      status: filter.status,
      jenisPembayaran: filter.jenisPembayaran,
    );
  }

  /// Navigasi ke halaman tertentu
  void goToPage(int page) {
    ref.read(transaksiPageProvider.notifier).state = page;
  }

  /// Refresh manual data riwayat dari view
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Batalkan transaksi (soft cancel) dan refresh daftar
  Future<void> cancelTransaksi(String transaksiId, String alasan) async {
    final repo = ref.read(transaksiRepositoryProvider);
    await repo.cancelTransaksi(transaksiId, alasan);
    ref.invalidateSelf();
  }
}
