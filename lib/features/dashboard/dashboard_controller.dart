import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/dashboard_analytics.dart';
import '../../models/pengiriman_pabrik.dart';
import '../../models/transaksi.dart';
import '../auth/auth_controller.dart';
import 'dashboard_repository.dart';

// =========================================================================
// 1. STATE & PROVIDER FILTER PERIODE REUSABLE (FR-5.x)
// =========================================================================

/// StateNotifier untuk mengelola rentang waktu aktif seluruh grafik di dashboard
class DashboardPeriodeNotifier extends StateNotifier<DashboardPeriodeState> {
  final Ref _ref;

  DashboardPeriodeNotifier(this._ref)
      : super(DashboardPeriodeState.fromPreset(DashboardPeriodePreset.satuBulan));

  bool get _isKasir {
    final role = _ref.read(authControllerProvider).profile?.role;
    return role == 'kasir';
  }

  /// Memilih salah satu preset cepat (Hari Ini, 1W, 2W, 1M, 3M, 6M, 1Y)
  void setPreset(DashboardPeriodePreset preset) {
    if (_isKasir && !preset.isAllowedForKasir) {
      state = DashboardPeriodeState.fromPreset(DashboardPeriodePreset.satuBulan);
      return;
    }
    state = DashboardPeriodeState.fromPreset(preset);
  }

  /// Memilih tanggal manual kustom
  void setCustomRange(DateTime start, DateTime end) {
    if (_isKasir) {
      state = DashboardPeriodeState.fromPreset(DashboardPeriodePreset.satuBulan);
      return;
    }
    state = DashboardPeriodeState.fromPreset(
      DashboardPeriodePreset.kustom,
      customStart: start,
      customEnd: end,
    );
  }
}

/// Provider global rentang filter waktu aktif (update instan untuk tombol UI)
final dashboardPeriodeProvider =
    StateNotifierProvider<DashboardPeriodeNotifier, DashboardPeriodeState>((ref) {
  return DashboardPeriodeNotifier(ref);
});

/// Notifier debounced (300ms) untuk mencegah query berlebihan saat pengguna mengklik preset secara cepat
class DebouncedDashboardPeriodeNotifier extends StateNotifier<DashboardPeriodeState> {
  final Ref ref;
  Timer? _timer;

  DebouncedDashboardPeriodeNotifier(this.ref)
      : super(ref.read(dashboardPeriodeProvider)) {
    ref.listen<DashboardPeriodeState>(dashboardPeriodeProvider, (previous, next) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          state = next;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider filter periode ter-debounce (300ms) yang dibaca oleh penyedia data grafik
final debouncedDashboardPeriodeProvider = StateNotifierProvider.autoDispose<
    DebouncedDashboardPeriodeNotifier, DashboardPeriodeState>((ref) {
  return DebouncedDashboardPeriodeNotifier(ref);
});

// =========================================================================
// 2. PROVIDER GRAFIK REAKTIF (MENGIKUTI FILTER PERIODE TER-DEBOUNCE)
// =========================================================================

/// Provider tren perbandingan nilai pembelian vs penjualan & margin (FR-5.4)
final trenMarginProvider =
    FutureProvider.autoDispose<List<MarginHarian>>((ref) async {
  final isKasir = ref.watch(authControllerProvider).profile?.role == 'kasir';
  if (isKasir) return const [];
  final periode = ref.watch(debouncedDashboardPeriodeProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getMarginHarian(periode.startDate, periode.endDate);
});

/// Provider tren berat pembelian petani (Berat Kotor vs Bersih) (FR-5.5)
final trenBeratPembelianProvider =
    FutureProvider.autoDispose<List<TransaksiHarian>>((ref) async {
  final isKasir = ref.watch(authControllerProvider).profile?.role == 'kasir';
  if (isKasir) return const [];
  final periode = ref.watch(debouncedDashboardPeriodeProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getTransaksiHarian(periode.startDate, periode.endDate);
});

/// Provider tren berat penjualan pabrik (Berat Kotor vs Bersih) (FR-5.6)
final trenBeratPenjualanProvider =
    FutureProvider.autoDispose<List<PengirimanHarian>>((ref) async {
  final isKasir = ref.watch(authControllerProvider).profile?.role == 'kasir';
  if (isKasir) return const [];
  final periode = ref.watch(debouncedDashboardPeriodeProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getPengirimanHarian(periode.startDate, periode.endDate);
});

/// Provider breakdown volume per jenis buah dengan filter periode aktif (FR-5.7)
final breakdownJenisBuahFilteredProvider =
    FutureProvider.autoDispose<List<BreakdownJenisBuah>>((ref) async {
  final periode = ref.watch(debouncedDashboardPeriodeProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getBreakdownJenisBuah(periode.startDate, periode.endDate);
});

/// Provider breakdown penjualan per pabrik tujuan dengan filter periode aktif (FR-5.8)
final breakdownPabrikFilteredProvider =
    FutureProvider.autoDispose<List<BreakdownPabrik>>((ref) async {
  final periode = ref.watch(debouncedDashboardPeriodeProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getBreakdownPabrik(periode.startDate, periode.endDate);
});

/// Provider breakdown pengeluaran per kategori dengan filter periode aktif (FR-5.14, Admin only)
final breakdownPengeluaranFilteredProvider =
    FutureProvider.autoDispose<List<BreakdownJenisPengeluaran>>((ref) async {
  final isKasir = ref.watch(authControllerProvider).profile?.role == 'kasir';
  if (isKasir) return const [];
  final periode = ref.watch(debouncedDashboardPeriodeProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getBreakdownPengeluaran(periode.startDate, periode.endDate);
});

/// Provider breakdown nilai dan volume pembelian berdasarkan metode pembayaran (Tunai vs Non Tunai)
final breakdownPembayaranFilteredProvider =
    FutureProvider.autoDispose<List<BreakdownMetodePembayaran>>((ref) async {
  final periode = ref.watch(debouncedDashboardPeriodeProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getBreakdownMetodePembayaran(periode.startDate, periode.endDate);
});

// =========================================================================
// 3. PROVIDER KARTU RINGKASAN MULTI-MODUL (HARI INI, MINGGU INI, BULAN INI)
// =========================================================================

/// Provider data transaksi pembelian 30 hari untuk perhitungan kartu KPI
final _transaksi30HariProvider =
    FutureProvider.autoDispose<List<TransaksiHarian>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getTransaksiHarian30Hari();
});

/// Provider data pengiriman pabrik 30 hari untuk perhitungan kartu KPI
final _pengiriman30HariProvider =
    FutureProvider.autoDispose<List<PengirimanHarian>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 30));
  return repo.getPengirimanHarian(start, now);
});

/// Provider terintegrasi untuk Kartu Ringkasan Pembelian, Penjualan Pabrik, dan Margin.
/// Mengambil data secara paralel menggunakan Future.wait untuk kecepatan optimal.
final multiModulSummaryProvider =
    FutureProvider.autoDispose<MultiModulSummary>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 30));

  // Ambil data pembelian, pengiriman, dan pengeluaran 30 hari secara paralel
  final results = await Future.wait([
    repo.getTransaksiHarian30Hari(),
    repo.getPengirimanHarian(start, now),
    repo.getPengeluaranHarian(start, now),
  ]);

  final listTrx = results[0] as List<TransaksiHarian>;
  final listKrm = results[1] as List<PengirimanHarian>;
  final listPg = results[2] as List<PengeluaranHarian>;

  return _calculateMultiModulSummary(listTrx, listKrm, listPg);
});

MultiModulSummary _calculateMultiModulSummary(
  List<TransaksiHarian> listTrx,
  List<PengirimanHarian> listKrm, [
  List<PengeluaranHarian>? listPg,
]) {

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final sevenDaysAgo = today.subtract(const Duration(days: 6));
  final startOfMonth = DateTime(now.year, now.month, 1);

  // A. Pembelian (FR-5.1)
  int beliHariIniCount = 0;
  Decimal beliHariIniKotor = Decimal.zero;
  Decimal beliHariIniBersih = Decimal.zero;
  Decimal beliHariIniNilai = Decimal.zero;

  int beliMingguIniCount = 0;
  Decimal beliMingguIniKotor = Decimal.zero;
  Decimal beliMingguIniBersih = Decimal.zero;
  Decimal beliMingguIniNilai = Decimal.zero;

  int beliBulanIniCount = 0;
  Decimal beliBulanIniKotor = Decimal.zero;
  Decimal beliBulanIniBersih = Decimal.zero;
  Decimal beliBulanIniNilai = Decimal.zero;

  for (final item in listTrx) {
    final tgl = DateTime(
      item.tanggalTransaksi.year,
      item.tanggalTransaksi.month,
      item.tanggalTransaksi.day,
    );

    if (tgl.isAtSameMomentAs(today)) {
      beliHariIniCount += item.jumlahTransaksi;
      beliHariIniKotor += item.totalBeratKotorKg;
      beliHariIniBersih += item.totalBeratBersihKg;
      beliHariIniNilai += item.totalNilai;
    }
    if ((tgl.isAtSameMomentAs(sevenDaysAgo) || tgl.isAfter(sevenDaysAgo)) &&
        (tgl.isBefore(today) || tgl.isAtSameMomentAs(today))) {
      beliMingguIniCount += item.jumlahTransaksi;
      beliMingguIniKotor += item.totalBeratKotorKg;
      beliMingguIniBersih += item.totalBeratBersihKg;
      beliMingguIniNilai += item.totalNilai;
    }
    if ((tgl.isAtSameMomentAs(startOfMonth) || tgl.isAfter(startOfMonth)) &&
        tgl.year == now.year &&
        tgl.month == now.month) {
      beliBulanIniCount += item.jumlahTransaksi;
      beliBulanIniKotor += item.totalBeratKotorKg;
      beliBulanIniBersih += item.totalBeratBersihKg;
      beliBulanIniNilai += item.totalNilai;
    }
  }

  // B. Penjualan ke Pabrik (FR-5.2)
  int jualHariIniCount = 0;
  Decimal jualHariIniKotor = Decimal.zero;
  Decimal jualHariIniBersih = Decimal.zero;
  Decimal jualHariIniNilai = Decimal.zero;

  int jualMingguIniCount = 0;
  Decimal jualMingguIniKotor = Decimal.zero;
  Decimal jualMingguIniBersih = Decimal.zero;
  Decimal jualMingguIniNilai = Decimal.zero;

  int jualBulanIniCount = 0;
  Decimal jualBulanIniKotor = Decimal.zero;
  Decimal jualBulanIniBersih = Decimal.zero;
  Decimal jualBulanIniNilai = Decimal.zero;

  for (final item in listKrm) {
    final tgl = DateTime(
      item.tanggalKirim.year,
      item.tanggalKirim.month,
      item.tanggalKirim.day,
    );

    if (tgl.isAtSameMomentAs(today)) {
      jualHariIniCount += item.jumlahPengiriman;
      jualHariIniKotor += item.totalBeratKotorKg;
      jualHariIniBersih += item.totalBeratBersihKg;
      jualHariIniNilai += item.totalNilaiJual;
    }
    if ((tgl.isAtSameMomentAs(sevenDaysAgo) || tgl.isAfter(sevenDaysAgo)) &&
        (tgl.isBefore(today) || tgl.isAtSameMomentAs(today))) {
      jualMingguIniCount += item.jumlahPengiriman;
      jualMingguIniKotor += item.totalBeratKotorKg;
      jualMingguIniBersih += item.totalBeratBersihKg;
      jualMingguIniNilai += item.totalNilaiJual;
    }
    if ((tgl.isAtSameMomentAs(startOfMonth) || tgl.isAfter(startOfMonth)) &&
        tgl.year == now.year &&
        tgl.month == now.month) {
      jualBulanIniCount += item.jumlahPengiriman;
      jualBulanIniKotor += item.totalBeratKotorKg;
      jualBulanIniBersih += item.totalBeratBersihKg;
      jualBulanIniNilai += item.totalNilaiJual;
    }
  }

  // C. Pengeluaran Operasional (FR-9.2, FR-5.13)
  Decimal pgHariIni = Decimal.zero;
  Decimal pgMingguIni = Decimal.zero;
  Decimal pgBulanIni = Decimal.zero;

  if (listPg != null) {
    for (final item in listPg) {
      final tgl = DateTime(
        item.tanggalPengeluaran.year,
        item.tanggalPengeluaran.month,
        item.tanggalPengeluaran.day,
      );

      if (tgl.isAtSameMomentAs(today)) {
        pgHariIni += item.totalNominal;
      }
      if ((tgl.isAtSameMomentAs(sevenDaysAgo) || tgl.isAfter(sevenDaysAgo)) &&
          (tgl.isBefore(today) || tgl.isAtSameMomentAs(today))) {
        pgMingguIni += item.totalNominal;
      }
      if ((tgl.isAtSameMomentAs(startOfMonth) || tgl.isAfter(startOfMonth)) &&
          tgl.year == now.year &&
          tgl.month == now.month) {
        pgBulanIni += item.totalNominal;
      }
    }
  }

  final summaryPembelian = DashboardSummary(
    hariIni: RingkasanPeriodik(
      label: 'Hari Ini',
      jumlahTransaksi: beliHariIniCount,
      totalBeratKotorKg: beliHariIniKotor,
      totalBeratBersihKg: beliHariIniBersih,
      totalNilai: beliHariIniNilai,
    ),
    mingguIni: RingkasanPeriodik(
      label: 'Minggu Ini',
      jumlahTransaksi: beliMingguIniCount,
      totalBeratKotorKg: beliMingguIniKotor,
      totalBeratBersihKg: beliMingguIniBersih,
      totalNilai: beliMingguIniNilai,
    ),
    bulanIni: RingkasanPeriodik(
      label: 'Bulan Ini',
      jumlahTransaksi: beliBulanIniCount,
      totalBeratKotorKg: beliBulanIniKotor,
      totalBeratBersihKg: beliBulanIniBersih,
      totalNilai: beliBulanIniNilai,
    ),
  );

  final summaryPenjualan = DashboardSummary(
    hariIni: RingkasanPeriodik(
      label: 'Hari Ini',
      jumlahTransaksi: jualHariIniCount,
      totalBeratKotorKg: jualHariIniKotor,
      totalBeratBersihKg: jualHariIniBersih,
      totalNilai: jualHariIniNilai,
    ),
    mingguIni: RingkasanPeriodik(
      label: 'Minggu Ini',
      jumlahTransaksi: jualMingguIniCount,
      totalBeratKotorKg: jualMingguIniKotor,
      totalBeratBersihKg: jualMingguIniBersih,
      totalNilai: jualMingguIniNilai,
    ),
    bulanIni: RingkasanPeriodik(
      label: 'Bulan Ini',
      jumlahTransaksi: jualBulanIniCount,
      totalBeratKotorKg: jualBulanIniKotor,
      totalBeratBersihKg: jualBulanIniBersih,
      totalNilai: jualBulanIniNilai,
    ),
  );

  // D. Margin & Laba Bersih (FR-5.3 & FR-5.13)
  final marginHariIni = RingkasanMarginPeriodik(
    label: 'Hari Ini',
    totalPembelian: beliHariIniNilai,
    totalPenjualan: jualHariIniNilai,
    margin: jualHariIniNilai - beliHariIniNilai,
    totalPengeluaran: pgHariIni,
    labaBersih: (jualHariIniNilai - beliHariIniNilai) - pgHariIni,
  );

  final marginMingguIni = RingkasanMarginPeriodik(
    label: 'Minggu Ini',
    totalPembelian: beliMingguIniNilai,
    totalPenjualan: jualMingguIniNilai,
    margin: jualMingguIniNilai - beliMingguIniNilai,
    totalPengeluaran: pgMingguIni,
    labaBersih: (jualMingguIniNilai - beliMingguIniNilai) - pgMingguIni,
  );

  final marginBulanIni = RingkasanMarginPeriodik(
    label: 'Bulan Ini',
    totalPembelian: beliBulanIniNilai,
    totalPenjualan: jualBulanIniNilai,
    margin: jualBulanIniNilai - beliBulanIniNilai,
    totalPengeluaran: pgBulanIni,
    labaBersih: (jualBulanIniNilai - beliBulanIniNilai) - pgBulanIni,
  );

  return MultiModulSummary(
    pembelian: summaryPembelian,
    penjualan: summaryPenjualan,
    marginHariIni: marginHariIni,
    marginMingguIni: marginMingguIni,
    marginBulanIni: marginBulanIni,
  );
}

// =========================================================================
// 4. BACKWARD COMPATIBILITY & RECENT LISTS (FR-5.9)
// =========================================================================

/// Provider kompatibilitas lama
final transaksiHarianProvider = _transaksi30HariProvider;

/// Provider kompatibilitas lama
final dashboardSummaryProvider =
    Provider.autoDispose<AsyncValue<DashboardSummary>>((ref) {
  final multi = ref.watch(multiModulSummaryProvider);
  return multi.whenData((data) => data.pembelian);
});

/// Provider kompatibilitas lama
final breakdownJenisBuahProvider = breakdownJenisBuahFilteredProvider;

/// Provider daftar 10 transaksi pembelian terakhir (FR-5.9)
final recentTransactionsProvider =
    FutureProvider.autoDispose<List<TransaksiRingkasan>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getRecentTransactions(limit: 10);
});

/// Provider daftar 10 pengiriman penjualan ke pabrik terakhir (FR-5.9)
final recentPengirimanProvider =
    FutureProvider.autoDispose<List<PengirimanPabrik>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getRecentPengiriman(limit: 10);
});

// =========================================================================
// 5. PROVIDER KHUSUS FILTER KARTU BULAN INI ADMIN (FR-5.12)
// =========================================================================

class KartuBulanIniFilterNotifier extends StateNotifier<KartuBulanIniFilterState> {
  KartuBulanIniFilterNotifier()
      : super(KartuBulanIniFilterState.defaultBulanBerjalan());

  void setFilter(KartuBulanIniFilterState filter) {
    state = filter;
  }

  void setBulanBerjalan() {
    state = KartuBulanIniFilterState.defaultBulanBerjalan();
  }

  void setBulanTertentu(int year, int month) {
    state = KartuBulanIniFilterState.bulanTertentu(year, month);
  }

  void setTahunTertentu(int year) {
    state = KartuBulanIniFilterState.tahunTertentu(year);
  }

  void setRentangKustom({
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
  }) {
    state = KartuBulanIniFilterState.rentangKustom(
      startYear: startYear,
      startMonth: startMonth,
      endYear: endYear,
      endMonth: endMonth,
    );
  }
}

/// Provider state konfigurasi filter kartu Bulan Ini khusus Admin
final kartuBulanIniFilterProvider = StateNotifierProvider<
    KartuBulanIniFilterNotifier, KartuBulanIniFilterState>((ref) {
  return KartuBulanIniFilterNotifier();
});

/// Provider data agregasi khusus untuk kartu Bulan Ini yang mengikuti kartuBulanIniFilterProvider
final kartuBulanIniSummaryProvider =
    FutureProvider.autoDispose<KartuBulanIniSummary?>((ref) async {
  final filter = ref.watch(kartuBulanIniFilterProvider);
  if (filter.isDefault) return null;
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getKartuBulanIniSummary(filter.startDate, filter.endDate, filter.label);
});

/// Helper untuk me-refresh seluruh data analitik dashboard
void refreshDashboard(WidgetRef ref) {
  ref.invalidate(dashboardPeriodeProvider);
  ref.invalidate(debouncedDashboardPeriodeProvider);
  ref.invalidate(multiModulSummaryProvider);
  ref.invalidate(kartuBulanIniSummaryProvider);
  ref.invalidate(_transaksi30HariProvider);
  ref.invalidate(_pengiriman30HariProvider);
  ref.invalidate(trenMarginProvider);
  ref.invalidate(trenBeratPembelianProvider);
  ref.invalidate(trenBeratPenjualanProvider);
  ref.invalidate(breakdownJenisBuahFilteredProvider);
  ref.invalidate(breakdownPabrikFilteredProvider);
  ref.invalidate(recentTransactionsProvider);
  ref.invalidate(recentPengirimanProvider);
}
