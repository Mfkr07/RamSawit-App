import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State filter riwayat Top Up Saldo / Dana Modal (FR-10.4)
class SaldoFilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final String datePreset; // 'hari_ini', '1_minggu', '2_minggu', '1_bulan', '3_bulan', '6_bulan', '1_tahun', 'kustom', 'semua'
  final int page;
  final int pageSize;

  const SaldoFilterState({
    this.startDate,
    this.endDate,
    this.datePreset = 'hari_ini',
    this.page = 1,
    this.pageSize = 15,
  });

  bool get hasActiveFilter {
    return datePreset != 'hari_ini';
  }

  SaldoFilterState copyWith({
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? datePreset,
    int? page,
    int? pageSize,
  }) {
    return SaldoFilterState(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      datePreset: datePreset ?? this.datePreset,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class SaldoFilterNotifier extends StateNotifier<SaldoFilterState> {
  static SaldoFilterState _initialState() {
    final now = DateTime.now();
    return SaldoFilterState(
      startDate: DateTime(now.year, now.month, now.day),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      datePreset: 'hari_ini',
      page: 1,
      pageSize: 15,
    );
  }

  SaldoFilterNotifier() : super(_initialState());

  /// Terapkan preset tanggal terstandarisasi (FR-10.4)
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

  /// Terapkan rentang tanggal kustom
  void setCustomDateRange(DateTime start, DateTime end) {
    state = state.copyWith(
      startDate: DateTime(start.year, start.month, start.day),
      endDate: DateTime(end.year, end.month, end.day, 23, 59, 59),
      datePreset: 'kustom',
      page: 1,
    );
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void reset() {
    state = _initialState();
  }
}

final saldoFilterProvider =
    StateNotifierProvider<SaldoFilterNotifier, SaldoFilterState>((ref) {
  return SaldoFilterNotifier();
});
