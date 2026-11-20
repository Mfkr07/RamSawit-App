import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'dashboard_analytics.dart';

/// Pilihan cakupan periode untuk Laporan Pendapatan (FR-7.8)
enum CakupanLaporanPendapatan {
  satuTahun,
  tigaBulan,
  satuBulan,
  kustom;

  String get label {
    switch (this) {
      case CakupanLaporanPendapatan.satuTahun:
        return '1 Tahun';
      case CakupanLaporanPendapatan.tigaBulan:
        return '3 Bulan';
      case CakupanLaporanPendapatan.satuBulan:
        return '1 Bulan';
      case CakupanLaporanPendapatan.kustom:
        return 'Periode Filter';
    }
  }

  String get deskripsiPengelompokan {
    switch (this) {
      case CakupanLaporanPendapatan.satuTahun:
        return 'Dikelompokkan per 3 bulan (Kuartalan)';
      case CakupanLaporanPendapatan.tigaBulan:
        return 'Dikelompokkan per 1 bulan';
      case CakupanLaporanPendapatan.satuBulan:
        return 'Dikelompokkan per minggu';
      case CakupanLaporanPendapatan.kustom:
        return 'Dikelompokkan per hari';
    }
  }
}

/// Baris data kelompok ringkasan pendapatan
class LaporanPendapatanRow {
  final String periodeLabel;
  final DateTime startDate;
  final DateTime endDate;
  final Decimal totalPembelian;
  final Decimal totalPenjualan;
  final Decimal margin;
  final Decimal totalPengeluaran;
  final Decimal labaBersih;

  LaporanPendapatanRow({
    required this.periodeLabel,
    required this.startDate,
    required this.endDate,
    required this.totalPembelian,
    required this.totalPenjualan,
    required this.margin,
    Decimal? totalPengeluaran,
    Decimal? labaBersih,
  })  : totalPengeluaran = totalPengeluaran ?? Decimal.zero,
        labaBersih = labaBersih ?? (margin - (totalPengeluaran ?? Decimal.zero));

  bool get isSurplus => margin >= Decimal.zero;
  bool get isLabaBersihSurplus => labaBersih >= Decimal.zero;
}

/// Struktur data lengkap hasil kalkulasi Laporan Pendapatan
class LaporanPendapatanData {
  final CakupanLaporanPendapatan cakupan;
  final String judulCakupan;
  final DateTime startDate;
  final DateTime endDate;
  final List<LaporanPendapatanRow> rows;
  final Decimal grandTotalPembelian;
  final Decimal grandTotalPenjualan;
  final Decimal grandTotalMargin;
  final Decimal grandTotalPengeluaran;
  final Decimal grandTotalLabaBersih;

  LaporanPendapatanData({
    required this.cakupan,
    required this.judulCakupan,
    required this.startDate,
    required this.endDate,
    required this.rows,
    required this.grandTotalPembelian,
    required this.grandTotalPenjualan,
    required this.grandTotalMargin,
    Decimal? grandTotalPengeluaran,
    Decimal? grandTotalLabaBersih,
  })  : grandTotalPengeluaran = grandTotalPengeluaran ?? Decimal.zero,
        grandTotalLabaBersih = grandTotalLabaBersih ??
            (grandTotalMargin - (grandTotalPengeluaran ?? Decimal.zero));

  bool get isSurplus => grandTotalMargin >= Decimal.zero;
  bool get isLabaBersihSurplus => grandTotalLabaBersih >= Decimal.zero;
}

/// Service aggregator client-side untuk memproses data harian dari `v_margin_harian`
/// dan `v_laba_bersih_harian` menjadi baris laporan pendapatan (FR-7.8 & Bagian 21).
class LaporanPendapatanAggregator {
  static const List<String> _namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _namaBulanSingkat = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Mengelompokkan data harian ke dalam model LaporanPendapatanData
  static LaporanPendapatanData aggregate({
    List<MarginHarian>? dailyData,
    List<LabaBersihHarian>? dailyLabaBersih,
    required CakupanLaporanPendapatan cakupan,
    required DateTime referenceDate,
    int? selectedQuarter, // 1, 2, 3, 4 (opsional untuk 3 Bulan)
  }) {
    switch (cakupan) {
      case CakupanLaporanPendapatan.satuTahun:
        return _aggregate1Tahun(
          dailyData: dailyData,
          dailyLabaBersih: dailyLabaBersih,
          year: referenceDate.year,
        );
      case CakupanLaporanPendapatan.tigaBulan:
        return _aggregate3Bulan(
          dailyData: dailyData,
          dailyLabaBersih: dailyLabaBersih,
          referenceDate: referenceDate,
          selectedQuarter: selectedQuarter,
        );
      case CakupanLaporanPendapatan.satuBulan:
        return _aggregate1Bulan(
          dailyData: dailyData,
          dailyLabaBersih: dailyLabaBersih,
          year: referenceDate.year,
          month: referenceDate.month,
        );
      case CakupanLaporanPendapatan.kustom:
        return aggregateFromDaily(
          dailyLabaBersih: dailyLabaBersih ?? [],
          startDate: referenceDate,
          endDate: referenceDate,
        );
    }
  }

  /// Mengelompokkan data harian dari filter periode aktif (LaporanPendapatanPage)
  static LaporanPendapatanData aggregateFromDaily({
    required List<LabaBersihHarian> dailyLabaBersih,
    required DateTime startDate,
    required DateTime endDate,
    String? judulCakupan,
  }) {
    final sorted = List<LabaBersihHarian>.from(dailyLabaBersih)
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    final rows = <LaporanPendapatanRow>[];
    var grandTotalBeli = Decimal.zero;
    var grandTotalJual = Decimal.zero;
    var grandTotalPengeluaran = Decimal.zero;

    final dateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');

    for (final item in sorted) {
      rows.add(
        LaporanPendapatanRow(
          periodeLabel: dateFormat.format(item.tanggal),
          startDate: item.tanggal,
          endDate: item.tanggal,
          totalPembelian: item.totalPembelian,
          totalPenjualan: item.totalPenjualan,
          margin: item.margin,
          totalPengeluaran: item.totalPengeluaran,
          labaBersih: item.labaBersih,
        ),
      );
      grandTotalBeli += item.totalPembelian;
      grandTotalJual += item.totalPenjualan;
      grandTotalPengeluaran += item.totalPengeluaran;
    }

    final grandTotalMargin = grandTotalJual - grandTotalBeli;

    return LaporanPendapatanData(
      cakupan: CakupanLaporanPendapatan.kustom,
      judulCakupan: judulCakupan ??
          '${DateFormat('d MMM yyyy', 'id_ID').format(startDate)} - ${DateFormat('d MMM yyyy', 'id_ID').format(endDate)}',
      startDate: startDate,
      endDate: endDate,
      rows: rows,
      grandTotalPembelian: grandTotalBeli,
      grandTotalPenjualan: grandTotalJual,
      grandTotalMargin: grandTotalMargin,
      grandTotalPengeluaran: grandTotalPengeluaran,
      grandTotalLabaBersih: grandTotalMargin - grandTotalPengeluaran,
    );
  }

  /// Cakupan 1 Tahun: Dirangkum per 3 bulan (Kuartal 1 s/d Kuartal 4)
  static LaporanPendapatanData _aggregate1Tahun({
    List<MarginHarian>? dailyData,
    List<LabaBersihHarian>? dailyLabaBersih,
    required int year,
  }) {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year, 12, 31, 23, 59, 59);

    final quarters = [
      (
        'Kuartal 1 (Jan - Mar $year)',
        DateTime(year, 1, 1),
        DateTime(year, 3, 31, 23, 59, 59),
      ),
      (
        'Kuartal 2 (Apr - Jun $year)',
        DateTime(year, 4, 1),
        DateTime(year, 6, 30, 23, 59, 59),
      ),
      (
        'Kuartal 3 (Jul - Sep $year)',
        DateTime(year, 7, 1),
        DateTime(year, 9, 30, 23, 59, 59),
      ),
      (
        'Kuartal 4 (Okt - Des $year)',
        DateTime(year, 10, 1),
        DateTime(year, 12, 31, 23, 59, 59),
      ),
    ];

    final rows = <LaporanPendapatanRow>[];
    var grandTotalBeli = Decimal.zero;
    var grandTotalJual = Decimal.zero;
    var grandTotalPengeluaran = Decimal.zero;

    for (final q in quarters) {
      final qStart = q.$2;
      final qEnd = q.$3;

      var qBeli = Decimal.zero;
      var qJual = Decimal.zero;
      var qPengeluaran = Decimal.zero;

      if (dailyLabaBersih != null) {
        for (final item in dailyLabaBersih) {
          if (!item.tanggal.isBefore(qStart) && !item.tanggal.isAfter(qEnd)) {
            qBeli += item.totalPembelian;
            qJual += item.totalPenjualan;
            qPengeluaran += item.totalPengeluaran;
          }
        }
      } else if (dailyData != null) {
        for (final item in dailyData) {
          if (!item.tanggal.isBefore(qStart) && !item.tanggal.isAfter(qEnd)) {
            qBeli += item.totalPembelian;
            qJual += item.totalPenjualan;
          }
        }
      }

      final qMargin = qJual - qBeli;
      final qLabaBersih = qMargin - qPengeluaran;
      rows.add(
        LaporanPendapatanRow(
          periodeLabel: q.$1,
          startDate: qStart,
          endDate: qEnd,
          totalPembelian: qBeli,
          totalPenjualan: qJual,
          margin: qMargin,
          totalPengeluaran: qPengeluaran,
          labaBersih: qLabaBersih,
        ),
      );

      grandTotalBeli += qBeli;
      grandTotalJual += qJual;
      grandTotalPengeluaran += qPengeluaran;
    }

    final grandMargin = grandTotalJual - grandTotalBeli;
    final grandLabaBersih = grandMargin - grandTotalPengeluaran;

    return LaporanPendapatanData(
      cakupan: CakupanLaporanPendapatan.satuTahun,
      judulCakupan: 'Tahun $year',
      startDate: startOfYear,
      endDate: endOfYear,
      rows: rows,
      grandTotalPembelian: grandTotalBeli,
      grandTotalPenjualan: grandTotalJual,
      grandTotalMargin: grandMargin,
      grandTotalPengeluaran: grandTotalPengeluaran,
      grandTotalLabaBersih: grandLabaBersih,
    );
  }

  /// Cakupan 3 Bulan: Dirangkum per 1 bulan (3 baris bulan)
  static LaporanPendapatanData _aggregate3Bulan({
    List<MarginHarian>? dailyData,
    List<LabaBersihHarian>? dailyLabaBersih,
    required DateTime referenceDate,
    int? selectedQuarter,
  }) {
    int startMonth;
    int year = referenceDate.year;

    if (selectedQuarter != null && selectedQuarter >= 1 && selectedQuarter <= 4) {
      startMonth = (selectedQuarter - 1) * 3 + 1;
    } else {
      final currentQuarter = ((referenceDate.month - 1) ~/ 3) + 1;
      startMonth = (currentQuarter - 1) * 3 + 1;
    }

    final month1 = startMonth;
    final month2 = startMonth + 1;
    final month3 = startMonth + 2;

    final startDate = DateTime(year, month1, 1);
    final lastDayMonth3 = DateTime(year, month3 + 1, 0).day;
    final endDate = DateTime(year, month3, lastDayMonth3, 23, 59, 59);

    final monthsConfig = [
      (
        '${_namaBulan[month1]} $year',
        DateTime(year, month1, 1),
        DateTime(year, month1 + 1, 0, 23, 59, 59),
      ),
      (
        '${_namaBulan[month2]} $year',
        DateTime(year, month2, 1),
        DateTime(year, month2 + 1, 0, 23, 59, 59),
      ),
      (
        '${_namaBulan[month3]} $year',
        DateTime(year, month3, 1),
        DateTime(year, month3 + 1, 0, 23, 59, 59),
      ),
    ];

    final rows = <LaporanPendapatanRow>[];
    var grandTotalBeli = Decimal.zero;
    var grandTotalJual = Decimal.zero;
    var grandTotalPengeluaran = Decimal.zero;

    for (final m in monthsConfig) {
      final mStart = m.$2;
      final mEnd = m.$3;

      var mBeli = Decimal.zero;
      var mJual = Decimal.zero;
      var mPengeluaran = Decimal.zero;

      if (dailyLabaBersih != null) {
        for (final item in dailyLabaBersih) {
          if (!item.tanggal.isBefore(mStart) && !item.tanggal.isAfter(mEnd)) {
            mBeli += item.totalPembelian;
            mJual += item.totalPenjualan;
            mPengeluaran += item.totalPengeluaran;
          }
        }
      } else if (dailyData != null) {
        for (final item in dailyData) {
          if (!item.tanggal.isBefore(mStart) && !item.tanggal.isAfter(mEnd)) {
            mBeli += item.totalPembelian;
            mJual += item.totalPenjualan;
          }
        }
      }

      final mMargin = mJual - mBeli;
      final mLabaBersih = mMargin - mPengeluaran;
      rows.add(
        LaporanPendapatanRow(
          periodeLabel: m.$1,
          startDate: mStart,
          endDate: mEnd,
          totalPembelian: mBeli,
          totalPenjualan: mJual,
          margin: mMargin,
          totalPengeluaran: mPengeluaran,
          labaBersih: mLabaBersih,
        ),
      );

      grandTotalBeli += mBeli;
      grandTotalJual += mJual;
      grandTotalPengeluaran += mPengeluaran;
    }

    final grandMargin = grandTotalJual - grandTotalBeli;
    final grandLabaBersih = grandMargin - grandTotalPengeluaran;
    final judul = '${_namaBulan[month1]} - ${_namaBulan[month3]} $year';

    return LaporanPendapatanData(
      cakupan: CakupanLaporanPendapatan.tigaBulan,
      judulCakupan: judul,
      startDate: startDate,
      endDate: endDate,
      rows: rows,
      grandTotalPembelian: grandTotalBeli,
      grandTotalPenjualan: grandTotalJual,
      grandTotalMargin: grandMargin,
      grandTotalPengeluaran: grandTotalPengeluaran,
      grandTotalLabaBersih: grandLabaBersih,
    );
  }

  /// Cakupan 1 Bulan: Dirangkum per minggu
  static LaporanPendapatanData _aggregate1Bulan({
    List<MarginHarian>? dailyData,
    List<LabaBersihHarian>? dailyLabaBersih,
    required int year,
    required int month,
  }) {
    final startDate = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final endDate = DateTime(year, month, daysInMonth, 23, 59, 59);

    final namaBulan = _namaBulanSingkat[month];

    final weeksConfig = <(String, DateTime, DateTime)>[
      (
        'Minggu 1 (1 - 7 $namaBulan $year)',
        DateTime(year, month, 1),
        DateTime(year, month, 7, 23, 59, 59),
      ),
      (
        'Minggu 2 (8 - 14 $namaBulan $year)',
        DateTime(year, month, 8),
        DateTime(year, month, 14, 23, 59, 59),
      ),
      (
        'Minggu 3 (15 - 21 $namaBulan $year)',
        DateTime(year, month, 15),
        DateTime(year, month, 21, 23, 59, 59),
      ),
      (
        'Minggu 4 (22 - 28 $namaBulan $year)',
        DateTime(year, month, 22),
        DateTime(year, month, 28, 23, 59, 59),
      ),
    ];

    if (daysInMonth > 28) {
      weeksConfig.add((
        'Minggu 5 (29 - $daysInMonth $namaBulan $year)',
        DateTime(year, month, 29),
        DateTime(year, month, daysInMonth, 23, 59, 59),
      ));
    }

    final rows = <LaporanPendapatanRow>[];
    var grandTotalBeli = Decimal.zero;
    var grandTotalJual = Decimal.zero;
    var grandTotalPengeluaran = Decimal.zero;

    for (final w in weeksConfig) {
      final wStart = w.$2;
      final wEnd = w.$3;

      var wBeli = Decimal.zero;
      var wJual = Decimal.zero;
      var wPengeluaran = Decimal.zero;

      if (dailyLabaBersih != null) {
        for (final item in dailyLabaBersih) {
          if (!item.tanggal.isBefore(wStart) && !item.tanggal.isAfter(wEnd)) {
            wBeli += item.totalPembelian;
            wJual += item.totalPenjualan;
            wPengeluaran += item.totalPengeluaran;
          }
        }
      } else if (dailyData != null) {
        for (final item in dailyData) {
          if (!item.tanggal.isBefore(wStart) && !item.tanggal.isAfter(wEnd)) {
            wBeli += item.totalPembelian;
            wJual += item.totalPenjualan;
          }
        }
      }

      final wMargin = wJual - wBeli;
      final wLabaBersih = wMargin - wPengeluaran;
      rows.add(
        LaporanPendapatanRow(
          periodeLabel: w.$1,
          startDate: wStart,
          endDate: wEnd,
          totalPembelian: wBeli,
          totalPenjualan: wJual,
          margin: wMargin,
          totalPengeluaran: wPengeluaran,
          labaBersih: wLabaBersih,
        ),
      );

      grandTotalBeli += wBeli;
      grandTotalJual += wJual;
      grandTotalPengeluaran += wPengeluaran;
    }

    final grandMargin = grandTotalJual - grandTotalBeli;
    final grandLabaBersih = grandMargin - grandTotalPengeluaran;

    return LaporanPendapatanData(
      cakupan: CakupanLaporanPendapatan.satuBulan,
      judulCakupan: '${_namaBulan[month]} $year',
      startDate: startDate,
      endDate: endDate,
      rows: rows,
      grandTotalPembelian: grandTotalBeli,
      grandTotalPenjualan: grandTotalJual,
      grandTotalMargin: grandMargin,
      grandTotalPengeluaran: grandTotalPengeluaran,
      grandTotalLabaBersih: grandLabaBersih,
    );
  }

  /// Menghitung tanggal mulai dan tanggal selesai untuk cakupan yang dipilih
  static (DateTime, DateTime) getDateRange({
    required CakupanLaporanPendapatan cakupan,
    required DateTime referenceDate,
    int? selectedQuarter,
  }) {
    final year = referenceDate.year;
    switch (cakupan) {
      case CakupanLaporanPendapatan.satuTahun:
        return (DateTime(year, 1, 1), DateTime(year, 12, 31, 23, 59, 59));
      case CakupanLaporanPendapatan.tigaBulan:
        int startMonth;
        if (selectedQuarter != null && selectedQuarter >= 1 && selectedQuarter <= 4) {
          startMonth = (selectedQuarter - 1) * 3 + 1;
        } else {
          final currentQuarter = ((referenceDate.month - 1) ~/ 3) + 1;
          startMonth = (currentQuarter - 1) * 3 + 1;
        }
        final month3 = startMonth + 2;
        final lastDay = DateTime(year, month3 + 1, 0).day;
        return (
          DateTime(year, startMonth, 1),
          DateTime(year, month3, lastDay, 23, 59, 59),
        );
      case CakupanLaporanPendapatan.satuBulan:
        final month = referenceDate.month;
        final lastDay = DateTime(year, month + 1, 0).day;
        return (
          DateTime(year, month, 1),
          DateTime(year, month, lastDay, 23, 59, 59),
        );
      case CakupanLaporanPendapatan.kustom:
        return (
          DateTime(year, referenceDate.month, referenceDate.day),
          DateTime(year, referenceDate.month, referenceDate.day, 23, 59, 59),
        );
    }
  }
}
