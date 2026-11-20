import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State kriteria filter riwayat pengeluaran operasional (FR-9.3)
class PengeluaranFilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? selectedJenisId;
  final String datePreset; // 'semua', 'hari_ini', '1_minggu', '2_minggu', '1_bulan', '3_bulan', '6_bulan', '1_tahun', 'kustom'
  final int page;
  final int pageSize;

  const PengeluaranFilterState({
    this.startDate,
    this.endDate,
    this.selectedJenisId,
    this.datePreset = 'semua',
    this.page = 1,
    this.pageSize = 20,
  });

  bool get hasActiveFilter {
    return startDate != null ||
        endDate != null ||
        (selectedJenisId != null && selectedJenisId! > 0) ||
        datePreset != 'semua';
  }

  int get activeFilterCount {
    int count = 0;
    if (startDate != null || endDate != null || datePreset != 'semua') count++;
    if (selectedJenisId != null && selectedJenisId! > 0) count++;
    return count;
  }

  PengeluaranFilterState copyWith({
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    int? selectedJenisId,
    bool clearJenis = false,
    String? datePreset,
    int? page,
    int? pageSize,
  }) {
    return PengeluaranFilterState(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      selectedJenisId:
          clearJenis ? null : (selectedJenisId ?? this.selectedJenisId),
      datePreset: datePreset ?? this.datePreset,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class PengeluaranFilterNotifier extends StateNotifier<PengeluaranFilterState> {
  PengeluaranFilterNotifier() : super(const PengeluaranFilterState());

  /// Terapkan preset tanggal terstandarisasi (FR-4.1 / FR-9.3)
  void applyDatePreset(String preset) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (preset) {
      case 'hari_ini':
        state = state.copyWith(
          startDate: todayStart,
          endDate: todayEnd,
          datePreset: 'hari_ini',
          page: 1,
        );
        break;
      case '1_minggu':
      case '7_hari':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 6)),
          endDate: todayEnd,
          datePreset: '1_minggu',
          page: 1,
        );
        break;
      case '2_minggu':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 13)),
          endDate: todayEnd,
          datePreset: '2_minggu',
          page: 1,
        );
        break;
      case '1_bulan':
      case 'bulan_ini':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 29)),
          endDate: todayEnd,
          datePreset: '1_bulan',
          page: 1,
        );
        break;
      case '3_bulan':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 89)),
          endDate: todayEnd,
          datePreset: '3_bulan',
          page: 1,
        );
        break;
      case '6_bulan':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 179)),
          endDate: todayEnd,
          datePreset: '6_bulan',
          page: 1,
        );
        break;
      case '1_tahun':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 364)),
          endDate: todayEnd,
          datePreset: '1_tahun',
          page: 1,
        );
        break;
      case 'semua':
      default:
        state = state.copyWith(
          clearStartDate: true,
          clearEndDate: true,
          datePreset: 'semua',
          page: 1,
        );
        break;
    }
  }

  /// Terapkan filter rentang tanggal kustom manual
  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(
      startDate: DateTime(start.year, start.month, start.day),
      endDate: DateTime(end.year, end.month, end.day, 23, 59, 59),
      datePreset: 'kustom',
      page: 1,
    );
  }

  /// Filter berdasarkan ID jenis pengeluaran
  void setJenisFilter(int? jenisId) {
    if (jenisId == null || jenisId <= 0) {
      state = state.copyWith(clearJenis: true, page: 1);
    } else {
      state = state.copyWith(selectedJenisId: jenisId, page: 1);
    }
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void resetFilter() {
    state = const PengeluaranFilterState();
  }
}

final pengeluaranFilterProvider =
    StateNotifierProvider<PengeluaranFilterNotifier, PengeluaranFilterState>((ref) {
  return PengeluaranFilterNotifier();
});
