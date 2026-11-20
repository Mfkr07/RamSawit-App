import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State kriteria filter riwayat transaksi
class TransaksiFilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedPenjualId;
  final String status; // 'semua', 'selesai', 'dibatalkan', 'draft'
  final String jenisPembayaran; // 'semua', 'tunai', 'non_tunai' (PRD §7.4 FR-4.1)
  final String datePreset; // 'semua', 'hari_ini', '7_hari', 'bulan_ini', 'kustom'

  const TransaksiFilterState({
    this.startDate,
    this.endDate,
    this.selectedPenjualId,
    this.status = 'semua',
    this.jenisPembayaran = 'semua',
    this.datePreset = 'semua',
  });

  bool get hasActiveFilter {
    return startDate != null ||
        endDate != null ||
        (selectedPenjualId != null && selectedPenjualId!.isNotEmpty) ||
        status != 'semua' ||
        jenisPembayaran != 'semua' ||
        datePreset != 'semua';
  }

  bool get hasActiveFilters => hasActiveFilter;

  int get activeFilterCount {
    int count = 0;
    if (startDate != null || endDate != null || datePreset != 'semua') count++;
    if (selectedPenjualId != null && selectedPenjualId!.isNotEmpty) count++;
    if (status != 'semua') count++;
    if (jenisPembayaran != 'semua') count++;
    return count;
  }

  TransaksiFilterState copyWith({
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? selectedPenjualId,
    bool clearPenjual = false,
    String? status,
    String? jenisPembayaran,
    String? datePreset,
  }) {
    return TransaksiFilterState(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      selectedPenjualId:
          clearPenjual ? null : (selectedPenjualId ?? this.selectedPenjualId),
      status: status ?? this.status,
      jenisPembayaran: jenisPembayaran ?? this.jenisPembayaran,
      datePreset: datePreset ?? this.datePreset,
    );
  }
}

class TransaksiFilterNotifier extends StateNotifier<TransaksiFilterState> {
  TransaksiFilterNotifier() : super(const TransaksiFilterState());

  /// Terapkan preset tanggal cepat terstandarisasi (FR-4.1)
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
        );
        break;
      case '1_minggu':
      case '7_hari': // backwards-compatibility
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 6)),
          endDate: todayEnd,
          datePreset: '1_minggu',
        );
        break;
      case '2_minggu':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 13)),
          endDate: todayEnd,
          datePreset: '2_minggu',
        );
        break;
      case '1_bulan':
      case 'bulan_ini': // backwards-compatibility
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 29)),
          endDate: todayEnd,
          datePreset: '1_bulan',
        );
        break;
      case '3_bulan':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 89)),
          endDate: todayEnd,
          datePreset: '3_bulan',
        );
        break;
      case '6_bulan':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 179)),
          endDate: todayEnd,
          datePreset: '6_bulan',
        );
        break;
      case '1_tahun':
        state = state.copyWith(
          startDate: todayStart.subtract(const Duration(days: 364)),
          endDate: todayEnd,
          datePreset: '1_tahun',
        );
        break;
      case 'semua':
      default:
        state = state.copyWith(
          clearStartDate: true,
          clearEndDate: true,
          datePreset: 'semua',
        );
        break;
    }
  }

  /// Tentukan rentang tanggal manual / kustom
  void setCustomDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      datePreset: 'kustom',
      clearStartDate: start == null,
      clearEndDate: end == null,
    );
  }

  /// Filter penjual
  void setPenjual(String? penjualId) {
    state = state.copyWith(
      selectedPenjualId: penjualId,
      clearPenjual: penjualId == null || penjualId.isEmpty,
    );
  }

  /// Filter status
  void setStatus(String status) {
    state = state.copyWith(status: status);
  }

  /// Filter jenis pembayaran ('semua', 'tunai', 'non_tunai') (PRD §7.4 FR-4.1)
  void setJenisPembayaran(String jenis) {
    state = state.copyWith(jenisPembayaran: jenis);
  }

  /// Reset semua filter
  void reset() {
    state = const TransaksiFilterState();
  }
}

final transaksiFilterProvider =
    StateNotifierProvider<TransaksiFilterNotifier, TransaksiFilterState>((ref) {
  return TransaksiFilterNotifier();
});
