import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Pilihan cepat preset rentang periode untuk grafik analitik
enum DashboardPeriodePreset {
  hariIni, // Hari ini saja
  satuMinggu, // 7 hari terakhir
  duaMinggu, // 14 hari terakhir
  satuBulan, // 30 hari terakhir
  tigaBulan, // 90 hari terakhir
  enamBulan, // 180 hari terakhir
  satuTahun, // 365 hari terakhir
  kustom, // Dipilih manual lewat date range picker
}

extension DashboardPeriodePresetExt on DashboardPeriodePreset {
  /// Apakah preset ini diizinkan untuk role Kasir (FR-5.11 maksimal 1 bulan)
  bool get isAllowedForKasir {
    switch (this) {
      case DashboardPeriodePreset.hariIni:
      case DashboardPeriodePreset.satuMinggu:
      case DashboardPeriodePreset.duaMinggu:
      case DashboardPeriodePreset.satuBulan:
        return true;
      case DashboardPeriodePreset.tigaBulan:
      case DashboardPeriodePreset.enamBulan:
      case DashboardPeriodePreset.satuTahun:
      case DashboardPeriodePreset.kustom:
        return false;
    }
  }
}

/// State representasi rentang waktu aktif untuk seluruh grafik di dashboard
class DashboardPeriodeState {
  final DashboardPeriodePreset preset;
  final DateTime startDate;
  final DateTime endDate;

  const DashboardPeriodeState({
    required this.preset,
    required this.startDate,
    required this.endDate,
  });

  /// Factory untuk membuat state berbasis preset dengan kalkulasi tanggal otomatis
  factory DashboardPeriodeState.fromPreset(
    DashboardPeriodePreset preset, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    DateTime start;

    switch (preset) {
      case DashboardPeriodePreset.hariIni:
        start = DateTime(now.year, now.month, now.day);
        break;
      case DashboardPeriodePreset.satuMinggu:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        break;
      case DashboardPeriodePreset.duaMinggu:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 13));
        break;
      case DashboardPeriodePreset.satuBulan:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        break;
      case DashboardPeriodePreset.tigaBulan:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 89));
        break;
      case DashboardPeriodePreset.enamBulan:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 179));
        break;
      case DashboardPeriodePreset.satuTahun:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 364));
        break;
      case DashboardPeriodePreset.kustom:
        start = customStart ??
            DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        break;
    }

    return DashboardPeriodeState(
      preset: preset,
      startDate: DateTime(start.year, start.month, start.day),
      endDate: customEnd != null
          ? DateTime(customEnd.year, customEnd.month, customEnd.day, 23, 59, 59)
          : end,
    );
  }

  /// Label ringkas preset
  String get label {
    switch (preset) {
      case DashboardPeriodePreset.hariIni:
        return 'Hari Ini';
      case DashboardPeriodePreset.satuMinggu:
        return '1 Minggu';
      case DashboardPeriodePreset.duaMinggu:
        return '2 Minggu';
      case DashboardPeriodePreset.satuBulan:
        return '1 Bulan';
      case DashboardPeriodePreset.tigaBulan:
        return '3 Bulan';
      case DashboardPeriodePreset.enamBulan:
        return '6 Bulan';
      case DashboardPeriodePreset.satuTahun:
        return '1 Tahun';
      case DashboardPeriodePreset.kustom:
        return 'Kustom';
    }
  }

  /// Tampilan teks rentang tanggal terformat rapi (contoh: 10 Feb 2026 – 10 Mar 2026)
  String get formattedRange {
    final f = DateFormat('dd MMM yyyy', 'id_ID');
    if (preset == DashboardPeriodePreset.hariIni ||
        (startDate.year == endDate.year &&
            startDate.month == endDate.month &&
            startDate.day == endDate.day)) {
      return f.format(startDate);
    }
    return '${f.format(startDate)} – ${f.format(endDate)}';
  }

  /// String ISO untuk query filter Supabase PostgREST
  String get startDateStr => startDate.toIso8601String().split('T').first;
  String get endDateStr => endDate.toIso8601String().split('T').first;

  DashboardPeriodeState copyWith({
    DashboardPeriodePreset? preset,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DashboardPeriodeState(
      preset: preset ?? this.preset,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Model baris agregasi harian dari view `public.v_transaksi_harian` (Pembelian Petani)
class TransaksiHarian {
  final DateTime tanggalTransaksi;
  final int jumlahTransaksi;
  final Decimal totalBeratKotorKg;
  final Decimal totalBeratBersihKg;
  final Decimal totalPotonganRp;
  final Decimal totalNilai; // Bersumber dari sum(total_nilai)

  TransaksiHarian({
    required this.tanggalTransaksi,
    required this.jumlahTransaksi,
    Decimal? totalBeratKotorKg,
    Decimal? totalBeratBersihKg,
    Decimal? totalBeratKg,
    Decimal? totalPotonganRp,
    Decimal? totalPotongan,
    required this.totalNilai,
  })  : totalBeratKotorKg = totalBeratKotorKg ?? totalBeratKg ?? Decimal.zero,
        totalBeratBersihKg = totalBeratBersihKg ?? totalBeratKg ?? Decimal.zero,
        totalPotonganRp = totalPotonganRp ?? totalPotongan ?? Decimal.zero;

  // Getter kompatibilitas
  Decimal get totalBeratKg => totalBeratBersihKg;
  Decimal get totalKotor => totalNilai + totalPotonganRp;
  Decimal get totalPotongan => totalPotonganRp;

  factory TransaksiHarian.fromJson(Map<String, dynamic> json) {
    final nilai = Decimal.parse((json['total_nilai'] ?? '0').toString());
    final kotor = json['total_berat_kotor_kg'] != null
        ? Decimal.parse(json['total_berat_kotor_kg'].toString())
        : Decimal.parse((json['total_berat_kg'] ?? '0').toString());
    final bersih = json['total_berat_bersih_kg'] != null
        ? Decimal.parse(json['total_berat_bersih_kg'].toString())
        : Decimal.parse((json['total_berat_kg'] ?? '0').toString());
    final potRp = json['total_potongan_rp'] != null
        ? Decimal.parse(json['total_potongan_rp'].toString())
        : (json['total_potongan'] != null
            ? Decimal.parse(json['total_potongan'].toString())
            : Decimal.zero);

    return TransaksiHarian(
      tanggalTransaksi: DateTime.parse(json['tanggal_transaksi'] as String),
      jumlahTransaksi: json['jumlah_transaksi'] is int
          ? json['jumlah_transaksi'] as int
          : int.parse(json['jumlah_transaksi'].toString()),
      totalBeratKotorKg: kotor,
      totalBeratBersihKg: bersih,
      totalPotonganRp: potRp,
      totalNilai: nilai,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal_transaksi': tanggalTransaksi.toIso8601String().split('T').first,
      'jumlah_transaksi': jumlahTransaksi,
      'total_berat_kotor_kg': totalBeratKotorKg.toString(),
      'total_berat_bersih_kg': totalBeratBersihKg.toString(),
      'total_potongan_rp': totalPotonganRp.toString(),
      'total_nilai': totalNilai.toString(),
    };
  }
}

/// Model baris agregasi harian dari view `public.v_pengiriman_harian` (Penjualan Pabrik)
class PengirimanHarian {
  final DateTime tanggalKirim;
  final int jumlahPengiriman;
  final Decimal totalBeratKotorKg;
  final Decimal totalBeratDitolakKg;
  final Decimal totalBeratBersihKg;
  final Decimal? totalSusutBuahKg;
  final Decimal totalPotonganRp;
  final Decimal totalNilaiJual;

  PengirimanHarian({
    required this.tanggalKirim,
    required this.jumlahPengiriman,
    required this.totalBeratKotorKg,
    required this.totalBeratDitolakKg,
    required this.totalBeratBersihKg,
    this.totalSusutBuahKg,
    required this.totalPotonganRp,
    required this.totalNilaiJual,
  });

  Decimal get totalBeratDikirimKg => totalBeratKotorKg;

  factory PengirimanHarian.fromJson(Map<String, dynamic> json) {
    return PengirimanHarian(
      tanggalKirim: DateTime.parse(json['tanggal_kirim'] as String),
      jumlahPengiriman: json['jumlah_pengiriman'] is int
          ? json['jumlah_pengiriman'] as int
          : int.parse(json['jumlah_pengiriman'].toString()),
      totalBeratKotorKg: Decimal.parse(
          (json['total_berat_dikirim_kg'] ?? json['total_berat_kotor_kg'] ?? '0')
              .toString()),
      totalBeratDitolakKg:
          Decimal.parse((json['total_berat_ditolak_kg'] ?? '0').toString()),
      totalBeratBersihKg:
          Decimal.parse((json['total_berat_bersih_kg'] ?? '0').toString()),
      totalSusutBuahKg: json['total_susut_buah_kg'] != null
          ? Decimal.tryParse(json['total_susut_buah_kg'].toString())
          : null,
      totalPotonganRp:
          Decimal.parse((json['total_potongan_rp'] ?? '0').toString()),
      totalNilaiJual:
          Decimal.parse((json['total_nilai_jual'] ?? '0').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal_kirim': tanggalKirim.toIso8601String().split('T').first,
      'jumlah_pengiriman': jumlahPengiriman,
      'total_berat_dikirim_kg': totalBeratKotorKg.toString(),
      'total_berat_kotor_kg': totalBeratKotorKg.toString(),
      'total_berat_ditolak_kg': totalBeratDitolakKg.toString(),
      'total_berat_bersih_kg': totalBeratBersihKg.toString(),
      'total_susut_buah_kg': totalSusutBuahKg?.toString(),
      'total_potongan_rp': totalPotonganRp.toString(),
      'total_nilai_jual': totalNilaiJual.toString(),
    };
  }
}

/// Model baris perbandingan nilai dan margin harian dari view `public.v_margin_harian`
class MarginHarian {
  final DateTime tanggal;
  final Decimal totalPembelian;
  final Decimal totalPenjualan;
  final Decimal margin;

  MarginHarian({
    required this.tanggal,
    required this.totalPembelian,
    required this.totalPenjualan,
    required this.margin,
  });

  bool get isSurplus => margin >= Decimal.zero;

  factory MarginHarian.fromJson(Map<String, dynamic> json) {
    return MarginHarian(
      tanggal: DateTime.parse(json['tanggal'] as String),
      totalPembelian: Decimal.parse((json['total_pembelian'] ?? '0').toString()),
      totalPenjualan: Decimal.parse((json['total_penjualan'] ?? '0').toString()),
      margin: Decimal.parse((json['margin'] ?? '0').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal.toIso8601String().split('T').first,
      'total_pembelian': totalPembelian.toString(),
      'total_penjualan': totalPenjualan.toString(),
      'margin': margin.toString(),
    };
  }
}

/// Model breakdown volume per jenis buah dari view `public.v_breakdown_jenis_buah`
class BreakdownJenisBuah {
  final String jenisBuah;
  final DateTime tanggal;
  final Decimal totalBeratKotorKg;
  final Decimal totalBeratBersihKg;
  final Decimal totalNilai;

  BreakdownJenisBuah({
    required this.jenisBuah,
    required this.tanggal,
    Decimal? totalBeratKotorKg,
    Decimal? totalBeratBersihKg,
    Decimal? totalBeratKg,
    required this.totalNilai,
  })  : totalBeratKotorKg = totalBeratKotorKg ?? totalBeratKg ?? Decimal.zero,
        totalBeratBersihKg = totalBeratBersihKg ?? totalBeratKg ?? Decimal.zero;

  Decimal get totalBeratKg => totalBeratBersihKg;

  factory BreakdownJenisBuah.fromJson(Map<String, dynamic> json) {
    final kotor = json['total_berat_kotor_kg'] != null
        ? Decimal.parse(json['total_berat_kotor_kg'].toString())
        : Decimal.parse((json['total_berat_kg'] ?? '0').toString());
    final bersih = json['total_berat_bersih_kg'] != null
        ? Decimal.parse(json['total_berat_bersih_kg'].toString())
        : Decimal.parse((json['total_berat_kg'] ?? '0').toString());

    return BreakdownJenisBuah(
      jenisBuah: json['jenis_buah'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      totalBeratKotorKg: kotor,
      totalBeratBersihKg: bersih,
      totalNilai: Decimal.parse((json['total_nilai'] ?? '0').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenis_buah': jenisBuah,
      'tanggal': tanggal.toIso8601String(),
      'total_berat_kotor_kg': totalBeratKotorKg.toString(),
      'total_berat_bersih_kg': totalBeratBersihKg.toString(),
      'total_nilai': totalNilai.toString(),
    };
  }
}

/// Model breakdown per pabrik tujuan dari view `public.v_breakdown_pabrik` (Database.md §8.1)
class BreakdownPabrik {
  final String namaPabrik;
  final DateTime tanggal;
  final Decimal totalBeratKotorKg;
  final Decimal totalBeratBersihKg;
  final Decimal totalNilaiJual;

  BreakdownPabrik({
    required this.namaPabrik,
    required this.tanggal,
    required this.totalBeratKotorKg,
    required this.totalBeratBersihKg,
    required this.totalNilaiJual,
  });

  Decimal get totalBeratKg => totalBeratBersihKg;

  factory BreakdownPabrik.fromJson(Map<String, dynamic> json) {
    return BreakdownPabrik(
      namaPabrik: json['nama_pabrik'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      totalBeratKotorKg: Decimal.parse((json['total_berat_kotor_kg'] ?? '0').toString()),
      totalBeratBersihKg: Decimal.parse((json['total_berat_bersih_kg'] ?? '0').toString()),
      totalNilaiJual: Decimal.parse((json['total_nilai_jual'] ?? '0').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_pabrik': namaPabrik,
      'tanggal': tanggal.toIso8601String(),
      'total_berat_kotor_kg': totalBeratKotorKg.toString(),
      'total_berat_bersih_kg': totalBeratBersihKg.toString(),
      'total_nilai_jual': totalNilaiJual.toString(),
    };
  }
}

/// Model akumulasi metrik ringkasan untuk satu periode waktu (Hari Ini, Minggu Ini, Bulan Ini)
class RingkasanPeriodik {
  final String label;
  final int jumlahTransaksi;
  final Decimal totalBeratKotorKg;
  final Decimal totalBeratBersihKg;
  final Decimal totalPotonganRp;
  final Decimal totalNilai;

  RingkasanPeriodik({
    required this.label,
    required this.jumlahTransaksi,
    Decimal? totalBeratKotorKg,
    Decimal? totalBeratBersihKg,
    Decimal? totalBeratKg,
    Decimal? totalPotonganRp,
    required this.totalNilai,
  })  : totalBeratKotorKg = totalBeratKotorKg ?? totalBeratKg ?? Decimal.zero,
        totalBeratBersihKg = totalBeratBersihKg ?? totalBeratKg ?? Decimal.zero,
        totalPotonganRp = totalPotonganRp ?? Decimal.zero;

  Decimal get totalBeratKg => totalBeratBersihKg;

  static RingkasanPeriodik empty(String label) {
    return RingkasanPeriodik(
      label: label,
      jumlahTransaksi: 0,
      totalBeratKotorKg: Decimal.zero,
      totalBeratBersihKg: Decimal.zero,
      totalPotonganRp: Decimal.zero,
      totalNilai: Decimal.zero,
    );
  }

  RingkasanPeriodik operator +(RingkasanPeriodik other) {
    return RingkasanPeriodik(
      label: label,
      jumlahTransaksi: jumlahTransaksi + other.jumlahTransaksi,
      totalBeratKotorKg: totalBeratKotorKg + other.totalBeratKotorKg,
      totalBeratBersihKg: totalBeratBersihKg + other.totalBeratBersihKg,
      totalPotonganRp: totalPotonganRp + other.totalPotonganRp,
      totalNilai: totalNilai + other.totalNilai,
    );
  }
}

/// Model ringkasan margin periodik (Penjualan - Pembelian) dan Laba Bersih
class RingkasanMarginPeriodik {
  final String label;
  final Decimal totalPembelian;
  final Decimal totalPenjualan;
  final Decimal margin;
  final Decimal totalPengeluaran;
  final Decimal labaBersih;

  RingkasanMarginPeriodik({
    required this.label,
    required this.totalPembelian,
    required this.totalPenjualan,
    required this.margin,
    Decimal? totalPengeluaran,
    Decimal? labaBersih,
  })  : totalPengeluaran = totalPengeluaran ?? Decimal.zero,
        labaBersih = labaBersih ?? (margin - (totalPengeluaran ?? Decimal.zero));

  bool get isSurplus => margin >= Decimal.zero;
  bool get isLabaBersihSurplus => labaBersih >= Decimal.zero;

  static RingkasanMarginPeriodik empty(String label) {
    return RingkasanMarginPeriodik(
      label: label,
      totalPembelian: Decimal.zero,
      totalPenjualan: Decimal.zero,
      margin: Decimal.zero,
      totalPengeluaran: Decimal.zero,
      labaBersih: Decimal.zero,
    );
  }
}

/// Model ringkasan KPI untuk tiga periode utama (Hari ini, Minggu ini, Bulan ini)
class DashboardSummary {
  final RingkasanPeriodik hariIni;
  final RingkasanPeriodik mingguIni;
  final RingkasanPeriodik bulanIni;

  const DashboardSummary({
    required this.hariIni,
    required this.mingguIni,
    required this.bulanIni,
  });

  static DashboardSummary empty() {
    return DashboardSummary(
      hariIni: RingkasanPeriodik.empty('Hari Ini'),
      mingguIni: RingkasanPeriodik.empty('Minggu Ini'),
      bulanIni: RingkasanPeriodik.empty('Bulan Ini'),
    );
  }
}

/// Ringkasan terintegrasi multi-modul untuk Pembelian Petani, Penjualan Pabrik, dan Margin
class MultiModulSummary {
  final DashboardSummary pembelian;
  final DashboardSummary penjualan;
  final RingkasanMarginPeriodik marginHariIni;
  final RingkasanMarginPeriodik marginMingguIni;
  final RingkasanMarginPeriodik marginBulanIni;

  const MultiModulSummary({
    required this.pembelian,
    required this.penjualan,
    required this.marginHariIni,
    required this.marginMingguIni,
    required this.marginBulanIni,
  });

  static MultiModulSummary empty() {
    return MultiModulSummary(
      pembelian: DashboardSummary.empty(),
      penjualan: DashboardSummary.empty(),
      marginHariIni: RingkasanMarginPeriodik.empty('Hari Ini'),
      marginMingguIni: RingkasanMarginPeriodik.empty('Minggu Ini'),
      marginBulanIni: RingkasanMarginPeriodik.empty('Bulan Ini'),
    );
  }
}

/// Agregasi lengkap seluruh metrik dashboard
class DashboardData {
  final RingkasanPeriodik hariIni;
  final RingkasanPeriodik mingguIni;
  final RingkasanPeriodik bulanIni;
  final List<TransaksiHarian> trenHarian;
  final List<BreakdownJenisBuah> breakdownBulanIni;
  final List<dynamic> transaksiTerbaru;

  const DashboardData({
    required this.hariIni,
    required this.mingguIni,
    required this.bulanIni,
    required this.trenHarian,
    required this.breakdownBulanIni,
    required this.transaksiTerbaru,
  });
}

/// Mode filter kartu Bulan Ini khusus Admin (FR-5.12)
enum KartuBulanIniMode {
  bulanBerjalan, // Default: Bulan berjalan saat ini
  bulanTertentu, // Bulan & Tahun tertentu (misal: Maret 2026)
  tahunTertentu, // Sepanjang tahun tertentu (misal: 2026)
  rentangKustom, // Rentang bulan custom (misal: Jan 2026 - Mar 2026)
}

/// State filter khusus kartu Bulan Ini (FR-5.12)
class KartuBulanIniFilterState {
  final KartuBulanIniMode mode;
  final DateTime startDate;
  final DateTime endDate;
  final String label;
  final int? selectedMonth;
  final int? selectedYear;
  final int? endMonth;
  final int? endYear;

  const KartuBulanIniFilterState({
    required this.mode,
    required this.startDate,
    required this.endDate,
    required this.label,
    this.selectedMonth,
    this.selectedYear,
    this.endMonth,
    this.endYear,
  });

  bool get isDefault => mode == KartuBulanIniMode.bulanBerjalan;

  factory KartuBulanIniFilterState.defaultBulanBerjalan() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
    final end = nextMonth.subtract(const Duration(seconds: 1));
    return KartuBulanIniFilterState(
      mode: KartuBulanIniMode.bulanBerjalan,
      startDate: start,
      endDate: end,
      label: 'BULAN INI',
      selectedMonth: now.month,
      selectedYear: now.year,
    );
  }

  factory KartuBulanIniFilterState.bulanTertentu(int year, int month) {
    final start = DateTime(year, month, 1);
    final nextMonth = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final end = nextMonth.subtract(const Duration(seconds: 1));
    final f = DateFormat('MMMM yyyy', 'id_ID');
    return KartuBulanIniFilterState(
      mode: KartuBulanIniMode.bulanTertentu,
      startDate: start,
      endDate: end,
      label: f.format(start).toUpperCase(),
      selectedMonth: month,
      selectedYear: year,
    );
  }

  factory KartuBulanIniFilterState.tahunTertentu(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);
    return KartuBulanIniFilterState(
      mode: KartuBulanIniMode.tahunTertentu,
      startDate: start,
      endDate: end,
      label: 'TAHUN $year',
      selectedYear: year,
    );
  }

  factory KartuBulanIniFilterState.rentangKustom({
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
  }) {
    final start = DateTime(startYear, startMonth, 1);
    final nextMonth = endMonth == 12 ? DateTime(endYear + 1, 1, 1) : DateTime(endYear, endMonth + 1, 1);
    final end = nextMonth.subtract(const Duration(seconds: 1));
    final f = DateFormat('MMM yyyy', 'id_ID');
    final label = '${f.format(start)} – ${f.format(DateTime(endYear, endMonth, 1))}'.toUpperCase();
    return KartuBulanIniFilterState(
      mode: KartuBulanIniMode.rentangKustom,
      startDate: start,
      endDate: end,
      label: label,
      selectedMonth: startMonth,
      selectedYear: startYear,
      endMonth: endMonth,
      endYear: endYear,
    );
  }
}

/// Ringkasan khusus metrik kartu Bulan Ini (atau periode terpilih admin)
class KartuBulanIniSummary {
  final RingkasanPeriodik pembelian;
  final RingkasanPeriodik penjualan;
  final RingkasanMarginPeriodik margin;
  final String label;

  const KartuBulanIniSummary({
    required this.pembelian,
    required this.penjualan,
    required this.margin,
    required this.label,
  });

  static KartuBulanIniSummary empty(String label) {
    return KartuBulanIniSummary(
      pembelian: RingkasanPeriodik.empty(label),
      penjualan: RingkasanPeriodik.empty(label),
      margin: RingkasanMarginPeriodik.empty(label),
      label: label,
    );
  }
}

/// Model baris agregasi laba bersih harian dari view `public.v_laba_bersih_harian`
class LabaBersihHarian {
  final DateTime tanggal;
  final Decimal totalPembelian;
  final Decimal totalPenjualan;
  final Decimal margin;
  final Decimal totalPengeluaran;
  final Decimal labaBersih;

  const LabaBersihHarian({
    required this.tanggal,
    required this.totalPembelian,
    required this.totalPenjualan,
    required this.margin,
    required this.totalPengeluaran,
    required this.labaBersih,
  });

  bool get isMarginSurplus => margin >= Decimal.zero;
  bool get isLabaBersihSurplus => labaBersih >= Decimal.zero;

  factory LabaBersihHarian.fromJson(Map<String, dynamic> json) {
    return LabaBersihHarian(
      tanggal: DateTime.parse(json['tanggal'] as String),
      totalPembelian: Decimal.parse((json['total_pembelian'] ?? '0').toString()),
      totalPenjualan: Decimal.parse((json['total_penjualan'] ?? '0').toString()),
      margin: Decimal.parse((json['margin'] ?? '0').toString()),
      totalPengeluaran:
          Decimal.parse((json['total_pengeluaran'] ?? '0').toString()),
      labaBersih: Decimal.parse((json['laba_bersih'] ?? '0').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal.toIso8601String().split('T').first,
      'total_pembelian': totalPembelian.toString(),
      'total_penjualan': totalPenjualan.toString(),
      'margin': margin.toString(),
      'total_pengeluaran': totalPengeluaran.toString(),
      'laba_bersih': labaBersih.toString(),
    };
  }
}

/// Model baris breakdown pengeluaran per jenis dari view `public.v_breakdown_jenis_pengeluaran`
class BreakdownJenisPengeluaran {
  final String jenisPengeluaran;
  final DateTime tanggal;
  final Decimal totalNominal;

  const BreakdownJenisPengeluaran({
    required this.jenisPengeluaran,
    required this.tanggal,
    required this.totalNominal,
  });

  factory BreakdownJenisPengeluaran.fromJson(Map<String, dynamic> json) {
    return BreakdownJenisPengeluaran(
      jenisPengeluaran: (json['jenis_pengeluaran'] as String?)?.trim() ?? 'Lain-lain',
      tanggal: DateTime.parse(json['tanggal'] as String),
      totalNominal: Decimal.parse((json['total_nominal'] ?? '0').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenis_pengeluaran': jenisPengeluaran,
      'tanggal': tanggal.toIso8601String().split('T').first,
      'total_nominal': totalNominal.toString(),
    };
  }
}

/// Model baris agregasi pengeluaran harian dari view `public.v_pengeluaran_harian`
class PengeluaranHarian {
  final DateTime tanggalPengeluaran;
  final Decimal totalNominal;

  const PengeluaranHarian({
    required this.tanggalPengeluaran,
    required this.totalNominal,
  });

  factory PengeluaranHarian.fromJson(Map<String, dynamic> json) {
    final rawDate = json['tanggal'] ?? json['tanggal_pengeluaran'];
    final rawNominal = json['total_pengeluaran'] ?? json['total_nominal'] ?? '0';
    return PengeluaranHarian(
      tanggalPengeluaran: DateTime.parse(rawDate as String),
      totalNominal: Decimal.parse(rawNominal.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal_pengeluaran':
          tanggalPengeluaran.toIso8601String().split('T').first,
      'total_nominal': totalNominal.toString(),
    };
  }
}

/// Model breakdown nilai dan volume pembelian berdasarkan metode pembayaran (Tunai vs Non Tunai)
class BreakdownMetodePembayaran {
  final String metode; // 'tunai' | 'non_tunai'
  final int jumlahTransaksi;
  final Decimal totalNilai;
  final Decimal totalBeratBersihKg;

  const BreakdownMetodePembayaran({
    required this.metode,
    required this.jumlahTransaksi,
    required this.totalNilai,
    required this.totalBeratBersihKg,
  });

  String get label =>
      metode == 'tunai' ? 'Tunai (Cash)' : 'Non Tunai (Transfer)';
  bool get isTunai => metode == 'tunai';
  bool get isNonTunai => metode == 'non_tunai';

  factory BreakdownMetodePembayaran.fromJson(Map<String, dynamic> json) {
    return BreakdownMetodePembayaran(
      metode: (json['metode'] ?? json['jenis_pembayaran'] ?? 'tunai') as String,
      jumlahTransaksi: (json['jumlah_transaksi'] as num?)?.toInt() ?? 0,
      totalNilai: json['total_nilai'] != null
          ? Decimal.parse(json['total_nilai'].toString())
          : Decimal.zero,
      totalBeratBersihKg: json['total_berat_bersih_kg'] != null
          ? Decimal.parse(json['total_berat_bersih_kg'].toString())
          : Decimal.zero,
    );
  }

  Map<String, dynamic> toJson() => {
        'metode': metode,
        'jumlah_transaksi': jumlahTransaksi,
        'total_nilai': totalNilai.toString(),
        'total_berat_bersih_kg': totalBeratBersihKg.toString(),
      };
}

