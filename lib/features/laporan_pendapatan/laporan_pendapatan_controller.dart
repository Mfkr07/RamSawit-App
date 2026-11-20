import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_repository.dart';
import 'laporan_pendapatan_state.dart';

/// Notifier untuk mengelola filter, status loading, dan data pendapatan harian
class LaporanPendapatanController
    extends StateNotifier<LaporanPendapatanState> {
  final DashboardRepository _repository;

  LaporanPendapatanController(this._repository)
      : super(LaporanPendapatanState.initial()) {
    loadData();
  }

  /// Memuat data laba bersih harian dari repository berdasarkan filter aktif
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getLabaBersihHarian(
        state.startDate,
        state.endDate,
      );
      state = state.copyWith(
        dailyList: list,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Mengubah urutan sortir tanggal (Terbaru <-> Terlama)
  void toggleSortOrder() {
    state = state.copyWith(sortDescending: !state.sortDescending);
  }

  /// Menerapkan preset periode standar aplikasi
  void applyPreset(String preset) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    DateTime start;
    DateTime end = todayEnd;

    switch (preset) {
      case 'hari_ini':
        start = todayStart;
        break;
      case '1_minggu':
        start = todayStart.subtract(const Duration(days: 6));
        break;
      case '2_minggu':
        start = todayStart.subtract(const Duration(days: 13));
        break;
      case '1_bulan':
        start = todayStart.subtract(const Duration(days: 29));
        break;
      case '3_bulan':
        start = todayStart.subtract(const Duration(days: 89));
        break;
      case '6_bulan':
        start = todayStart.subtract(const Duration(days: 179));
        break;
      case '1_tahun':
        start = todayStart.subtract(const Duration(days: 364));
        break;
      case 'semua':
        start = DateTime(2020, 1, 1);
        break;
      default:
        start = todayStart;
    }

    state = state.copyWith(
      datePreset: preset,
      startDate: start,
      endDate: end,
    );
    loadData();
  }

  /// Reset filter ke preset default 'hari_ini'
  void resetToToday() {
    applyPreset('hari_ini');
  }

  /// Menerapkan filter spesifik 1 hari
  void applySingleDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    state = state.copyWith(
      datePreset: 'harian_spesifik',
      startDate: dayStart,
      endDate: dayEnd,
    );
    loadData();
  }

  /// Menerapkan filter kustom dengan rentang tanggal bebas
  void applyCustomRange(DateTime start, DateTime end) {
    final rangeStart = DateTime(start.year, start.month, start.day);
    final rangeEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    state = state.copyWith(
      datePreset: 'kustom',
      startDate: rangeStart,
      endDate: rangeEnd,
    );
    loadData();
  }
}

/// Provider global untuk controller laporan pendapatan
final laporanPendapatanControllerProvider = StateNotifierProvider<
    LaporanPendapatanController, LaporanPendapatanState>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return LaporanPendapatanController(repo);
});
