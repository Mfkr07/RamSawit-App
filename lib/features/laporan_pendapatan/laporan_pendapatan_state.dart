import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import '../../models/dashboard_analytics.dart';

/// State untuk modul Laporan Pendapatan & Laba Bersih Harian
class LaporanPendapatanState {
  /// Preset filter tanggal standar aplikasi:
  /// - 'hari_ini': Hari Ini (Default)
  /// - '1_minggu': 1 Minggu Terakhir
  /// - '2_minggu': 2 Minggu Terakhir
  /// - '1_bulan': 1 Bulan Terakhir
  /// - '3_bulan': 3 Bulan Terakhir
  /// - '6_bulan': 6 Bulan Terakhir
  /// - '1_tahun': 1 Tahun Terakhir
  /// - 'semua': Seluruh periode
  /// - 'harian_spesifik': 1 hari tertentu
  /// - 'kustom': Rentang tanggal kustom (start s/d end)
  final String datePreset;
  final DateTime startDate;
  final DateTime endDate;
  final List<LabaBersihHarian> dailyList;
  final bool isLoading;
  final String? errorMessage;
  final bool sortDescending; // true: tanggal terbaru di atas

  const LaporanPendapatanState({
    required this.datePreset,
    required this.startDate,
    required this.endDate,
    this.dailyList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.sortDescending = true,
  });

  /// Akumulasi Total Pembelian TBS Petani
  Decimal get totalPembelian => dailyList.fold<Decimal>(
        Decimal.zero,
        (sum, item) => sum + item.totalPembelian,
      );

  /// Akumulasi Total Penjualan ke Pabrik PKS
  Decimal get totalPenjualan => dailyList.fold<Decimal>(
        Decimal.zero,
        (sum, item) => sum + item.totalPenjualan,
      );

  /// Akumulasi Margin Kotor (Penjualan - Pembelian)
  Decimal get totalMargin => totalPenjualan - totalPembelian;

  /// Akumulasi Total Pengeluaran / Biaya Operasional
  Decimal get totalPengeluaran => dailyList.fold<Decimal>(
        Decimal.zero,
        (sum, item) => sum + item.totalPengeluaran,
      );

  /// Akumulasi Laba Bersih Riil (Margin - Biaya Operasional)
  Decimal get totalLabaBersih => totalMargin - totalPengeluaran;

  bool get isMarginSurplus => totalMargin >= Decimal.zero;
  bool get isLabaBersihSurplus => totalLabaBersih >= Decimal.zero;

  /// Persentase margin kotor terhadap total penjualan
  double get marginPercentage {
    if (totalPenjualan <= Decimal.zero) return 0.0;
    try {
      final marginD = double.tryParse(totalMargin.toString()) ?? 0.0;
      final penjualanD = double.tryParse(totalPenjualan.toString()) ?? 1.0;
      return (marginD / penjualanD) * 100.0;
    } catch (_) {
      return 0.0;
    }
  }

  /// Persentase laba bersih terhadap total penjualan
  double get labaBersihPercentage {
    if (totalPenjualan <= Decimal.zero) return 0.0;
    try {
      final labaD = double.tryParse(totalLabaBersih.toString()) ?? 0.0;
      final penjualanD = double.tryParse(totalPenjualan.toString()) ?? 1.0;
      return (labaD / penjualanD) * 100.0;
    } catch (_) {
      return 0.0;
    }
  }

  /// Daftar baris harian terurut sesuai preferensi sortDescending
  List<LabaBersihHarian> get sortedDailyList {
    final list = List<LabaBersihHarian>.from(dailyList);
    if (sortDescending) {
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    } else {
      list.sort((a, b) => a.tanggal.compareTo(b.tanggal));
    }
    return list;
  }

  /// Mengecek apakah filter saat ini bukan default (hari_ini)
  bool get hasActiveFilter => datePreset != 'hari_ini';
  bool get isCustom => datePreset == 'kustom';
  bool get isSingleDate => datePreset == 'harian_spesifik';

  /// Format teks ringkas periode aktif untuk header, chip, dan dialog ekspor
  String get periodLabel {
    final dateFormat = DateFormat('dd/MM/yyyy');
    if (datePreset == 'hari_ini') {
      return 'Hari Ini (${dateFormat.format(DateTime.now())})';
    } else if (datePreset == '1_minggu') {
      return '1 Minggu Terakhir';
    } else if (datePreset == '2_minggu') {
      return '2 Minggu Terakhir';
    } else if (datePreset == '1_bulan') {
      return '1 Bulan Terakhir';
    } else if (datePreset == '3_bulan') {
      return '3 Bulan Terakhir';
    } else if (datePreset == '6_bulan') {
      return '6 Bulan Terakhir';
    } else if (datePreset == '1_tahun') {
      return '1 Tahun Terakhir';
    } else if (datePreset == 'semua') {
      return 'Semua Periode Data';
    } else if (datePreset == 'harian_spesifik') {
      return 'Hari: ${dateFormat.format(startDate)}';
    } else if (datePreset == 'kustom') {
      return '${dateFormat.format(startDate)} – ${dateFormat.format(endDate)}';
    } else {
      return '${dateFormat.format(startDate)} – ${dateFormat.format(endDate)}';
    }
  }

  factory LaporanPendapatanState.initial() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return LaporanPendapatanState(
      datePreset: 'hari_ini',
      startDate: todayStart,
      endDate: todayEnd,
      dailyList: const [],
      isLoading: true,
      errorMessage: null,
      sortDescending: true,
    );
  }

  LaporanPendapatanState copyWith({
    String? datePreset,
    DateTime? startDate,
    DateTime? endDate,
    List<LabaBersihHarian>? dailyList,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? sortDescending,
  }) {
    return LaporanPendapatanState(
      datePreset: datePreset ?? this.datePreset,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dailyList: dailyList ?? this.dailyList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}
