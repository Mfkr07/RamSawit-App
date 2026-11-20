import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import '../../models/dashboard_analytics.dart';
import '../../models/pengiriman_pabrik.dart';
import '../../models/transaksi.dart';
import '../auth/auth_controller.dart';
import '../pengiriman_pabrik/pengiriman_pabrik_repository.dart';
import '../pengeluaran/pengeluaran_repository.dart';
import '../transaksi/transaksi_repository.dart';

/// Repository untuk membaca view analitik pelaporan dashboard:
/// - `public.v_transaksi_harian`
/// - `public.v_pengiriman_harian`
/// - `public.v_margin_harian`
/// - `public.v_breakdown_jenis_buah`
/// - `public.v_breakdown_pabrik`
/// - `public.v_transaksi_ringkasan` & `public.v_pengiriman_ringkasan`
class DashboardRepository {
  final SupabaseClient? _client;
  final String userRole;
  final TransaksiRepository? _transaksiRepo;

  DashboardRepository([this._client, this.userRole = 'admin', this._transaksiRepo]);

  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;

  /// Memvalidasi keamanan role Kasir (FR-5.11):
  /// - Kasir tidak boleh mengakses margin
  /// - Kasir tidak boleh mengakses data dengan rentang > 31 hari
  void _validateAccess(DateTime startDate, DateTime endDate, {bool isMargin = false}) {
    if (userRole == 'kasir') {
      if (isMargin) {
        throw ArgumentError('Akses ditolak: Kasir tidak memiliki hak akses ke data margin keuntungan.');
      }
      final differenceInDays = endDate.difference(startDate).inDays.abs();
      if (differenceInDays > 31) {
        throw ArgumentError(
          'Akses ditolak: Kasir hanya diizinkan melihat data maksimal rentang 1 bulan (31 hari).',
        );
      }
    }
  }

  /// Mengambil data agregasi transaksi harian untuk rentang tanggal tertentu
  Future<List<TransaksiHarian>> getTransaksiHarian(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _validateAccess(startDate, endDate);

    if (isDemoMode) {
      if (_transaksiRepo != null) {
        try {
          await _transaksiRepo.ensureDemoLoaded();
        } catch (_) {}
      }
      await Future.delayed(const Duration(milliseconds: 200));
      return _generateDemoTransaksiHarian(startDate, endDate);
    }

    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client!
          .from('v_transaksi_harian')
          .select()
          .gte('tanggal_transaksi', startStr)
          .lte('tanggal_transaksi', endStr)
          .order('tanggal_transaksi', ascending: true);

      final list = (response as List<dynamic>)
          .map((json) =>
              TransaksiHarian.fromJson(json as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => a.tanggalTransaksi.compareTo(b.tanggalTransaksi));
      return list;
    } catch (e) {
      if (isDemoMode) {
        return _generateDemoTransaksiHarian(startDate, endDate);
      }
      rethrow;
    }
  }

  /// Backward compatibility: Mengambil data agregasi 30 hari terakhir
  Future<List<TransaksiHarian>> getTransaksiHarian30Hari() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return getTransaksiHarian(start, now);
  }

  /// Mengambil data agregasi pengiriman harian ke pabrik untuk rentang tanggal tertentu (status selesai)
  Future<List<PengirimanHarian>> getPengirimanHarian(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _validateAccess(startDate, endDate);

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _generateDemoPengirimanHarian(startDate, endDate);
    }

    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client!
          .from('v_pengiriman_harian')
          .select()
          .gte('tanggal_kirim', startStr)
          .lte('tanggal_kirim', endStr)
          .order('tanggal_kirim', ascending: true);

      final list = (response as List<dynamic>)
          .map((json) =>
              PengirimanHarian.fromJson(json as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => a.tanggalKirim.compareTo(b.tanggalKirim));
      return list;
    } catch (e) {
      if (isDemoMode) {
        return _generateDemoPengirimanHarian(startDate, endDate);
      }
      rethrow;
    }
  }

  /// Mengambil data perbandingan nilai harian & margin dari view `v_margin_harian`
  Future<List<MarginHarian>> getMarginHarian(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _validateAccess(startDate, endDate, isMargin: true);

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _generateDemoMarginHarian(startDate, endDate);
    }

    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client!
          .from('v_margin_harian')
          .select()
          .gte('tanggal', startStr)
          .lte('tanggal', endStr)
          .order('tanggal', ascending: true);

      final list = (response as List<dynamic>)
          .map((json) =>
              MarginHarian.fromJson(json as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => a.tanggal.compareTo(b.tanggal));
      return list;
    } catch (e) {
      if (isDemoMode) {
        return _generateDemoMarginHarian(startDate, endDate);
      }
      rethrow;
    }
  }

  /// Mengambil data agregasi laba bersih harian dari view `v_laba_bersih_harian` (Admin only)
  Future<List<LabaBersihHarian>> getLabaBersihHarian(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _validateAccess(startDate, endDate, isMargin: true);

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _generateDemoLabaBersihHarian(startDate, endDate);
    }

    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client!
          .from('v_laba_bersih_harian')
          .select()
          .gte('tanggal', startStr)
          .lte('tanggal', endStr)
          .order('tanggal', ascending: true);

      final list = (response as List<dynamic>)
          .map((json) =>
              LabaBersihHarian.fromJson(json as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => a.tanggal.compareTo(b.tanggal));
      return list;
    } catch (e) {
      if (isDemoMode) {
        return _generateDemoLabaBersihHarian(startDate, endDate);
      }
      rethrow;
    }
  }

  /// Mengambil breakdown pengeluaran per jenis dari view `v_breakdown_jenis_pengeluaran` (Admin only)
  Future<List<BreakdownJenisPengeluaran>> getBreakdownPengeluaran(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _validateAccess(startDate, endDate, isMargin: true);

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      return _generateDemoBreakdownPengeluaran(startDate, endDate);
    }

    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client!
          .from('v_breakdown_jenis_pengeluaran')
          .select()
          .gte('tanggal', startStr)
          .lte('tanggal', endStr);

      return (response as List<dynamic>)
          .map((json) =>
              BreakdownJenisPengeluaran.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (isDemoMode) {
        return _generateDemoBreakdownPengeluaran(startDate, endDate);
      }
      rethrow;
    }
  }

  /// Mengambil breakdown nilai dan volume pembelian berdasarkan metode pembayaran (Tunai vs Non Tunai)
  Future<List<BreakdownMetodePembayaran>> getBreakdownMetodePembayaran(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _validateAccess(startDate, endDate);

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      return _generateDemoBreakdownMetodePembayaran(startDate, endDate);
    }

    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client!
          .from('v_transaksi_ringkasan')
          .select('jenis_pembayaran, total_nilai, total_berat_bersih_kg')
          .eq('status', 'selesai')
          .gte('tanggal_transaksi', startStr)
          .lte('tanggal_transaksi', endStr);

      final rows = response as List<dynamic>;
      Decimal totalTunai = Decimal.zero;
      Decimal beratTunai = Decimal.zero;
      int countTunai = 0;

      Decimal totalNonTunai = Decimal.zero;
      Decimal beratNonTunai = Decimal.zero;
      int countNonTunai = 0;

      for (final r in rows) {
        final jn = r['jenis_pembayaran'] as String? ?? 'tunai';
        final val = r['total_nilai'] != null
            ? Decimal.parse(r['total_nilai'].toString())
            : Decimal.zero;
        final brt = r['total_berat_bersih_kg'] != null
            ? Decimal.parse(r['total_berat_bersih_kg'].toString())
            : Decimal.zero;

        if (jn == 'non_tunai') {
          totalNonTunai += val;
          beratNonTunai += brt;
          countNonTunai++;
        } else {
          totalTunai += val;
          beratTunai += brt;
          countTunai++;
        }
      }

      return [
        BreakdownMetodePembayaran(
          metode: 'tunai',
          jumlahTransaksi: countTunai,
          totalNilai: totalTunai,
          totalBeratBersihKg: beratTunai,
        ),
        BreakdownMetodePembayaran(
          metode: 'non_tunai',
          jumlahTransaksi: countNonTunai,
          totalNilai: totalNonTunai,
          totalBeratBersihKg: beratNonTunai,
        ),
      ];
    } catch (e) {
      if (isDemoMode) {
        return _generateDemoBreakdownMetodePembayaran(startDate, endDate);
      }
      rethrow;
    }
  }

  /// Mengambil agregasi pengeluaran harian dari view `v_pengeluaran_harian`
  Future<List<PengeluaranHarian>> getPengeluaranHarian(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      return _generateDemoPengeluaranHarian(startDate, endDate);
    }

    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client!
          .from('v_pengeluaran_harian')
          .select()
          .gte('tanggal', startStr)
          .lte('tanggal', endStr)
          .order('tanggal', ascending: true);

      final list = (response as List<dynamic>)
          .map((json) =>
              PengeluaranHarian.fromJson(json as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => a.tanggalPengeluaran.compareTo(b.tanggalPengeluaran));
      return list;
    } catch (e) {
      if (isDemoMode) {
        return _generateDemoPengeluaranHarian(startDate, endDate);
      }
      rethrow;
    }
  }

  /// Mengambil breakdown volume per jenis buah untuk rentang tanggal tertentu
  Future<List<BreakdownJenisBuah>> getBreakdownJenisBuah(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _validateAccess(startDate, endDate);

    if (isDemoMode) {
      if (_transaksiRepo != null) {
        try {
          await _transaksiRepo.ensureDemoLoaded();
        } catch (_) {}
      }
      await Future.delayed(const Duration(milliseconds: 150));
      return _generateDemoBreakdownJenisBuah(startDate, endDate);
    }

    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client!
          .from('v_breakdown_jenis_buah')
          .select()
          .gte('tanggal', startStr)
          .lte('tanggal', endStr);

      return (response as List<dynamic>)
          .map((json) =>
              BreakdownJenisBuah.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (isDemoMode) {
        return _generateDemoBreakdownJenisBuah(startDate, endDate);
      }
      rethrow;
    }
  }

  /// Backward compatibility: breakdown jenis buah bulan berjalan
  Future<List<BreakdownJenisBuah>> getBreakdownJenisBuahBulanIni() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return getBreakdownJenisBuah(start, now);
  }

  /// Mengambil breakdown per pabrik tujuan dari view `v_breakdown_pabrik`
  Future<List<BreakdownPabrik>> getBreakdownPabrik(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _validateAccess(startDate, endDate);

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      return _generateDemoBreakdownPabrik(startDate, endDate);
    }

    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client!
          .from('v_breakdown_pabrik')
          .select()
          .gte('tanggal', startStr)
          .lte('tanggal', endStr);

      return (response as List<dynamic>)
          .map((json) =>
              BreakdownPabrik.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (isDemoMode) {
        return _generateDemoBreakdownPabrik(startDate, endDate);
      }
      rethrow;
    }
  }

  /// Mengambil data ringkasan khusus untuk kartu Bulan Ini (atau periode terpilih Admin FR-5.12)
  Future<KartuBulanIniSummary> getKartuBulanIniSummary(
    DateTime startDate,
    DateTime endDate,
    String label,
  ) async {
    final results = await Future.wait([
      getTransaksiHarian(startDate, endDate),
      getPengirimanHarian(startDate, endDate),
    ]);

    final listTrx = results[0] as List<TransaksiHarian>;
    final listKrm = results[1] as List<PengirimanHarian>;

    Decimal beliKotor = Decimal.zero;
    Decimal beliBersih = Decimal.zero;
    Decimal beliNilai = Decimal.zero;
    int beliCount = 0;

    for (final item in listTrx) {
      beliCount += item.jumlahTransaksi;
      beliKotor += item.totalBeratKotorKg;
      beliBersih += item.totalBeratBersihKg;
      beliNilai += item.totalNilai;
    }

    Decimal jualKotor = Decimal.zero;
    Decimal jualBersih = Decimal.zero;
    Decimal jualNilai = Decimal.zero;
    int jualCount = 0;

    for (final item in listKrm) {
      jualCount += item.jumlahPengiriman;
      jualKotor += item.totalBeratKotorKg;
      jualBersih += item.totalBeratBersihKg;
      jualNilai += item.totalNilaiJual;
    }

    final marginNominal = jualNilai - beliNilai;

    return KartuBulanIniSummary(
      pembelian: RingkasanPeriodik(
        label: label,
        jumlahTransaksi: beliCount,
        totalBeratKotorKg: beliKotor,
        totalBeratBersihKg: beliBersih,
        totalNilai: beliNilai,
      ),
      penjualan: RingkasanPeriodik(
        label: label,
        jumlahTransaksi: jualCount,
        totalBeratKotorKg: jualKotor,
        totalBeratBersihKg: jualBersih,
        totalNilai: jualNilai,
      ),
      margin: RingkasanMarginPeriodik(
        label: label,
        totalPembelian: beliNilai,
        totalPenjualan: jualNilai,
        margin: marginNominal,
      ),
      label: label,
    );
  }

  /// Mengambil 10 transaksi terakhir dari `v_transaksi_ringkasan`
  Future<List<TransaksiRingkasan>> getRecentTransactions({
    int limit = 10,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      final all = List<TransaksiRingkasan>.from(
        TransaksiRepository.demoRingkasanList,
      );
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all.take(limit).toList();
    }

    try {
      final response = await _client!
          .from('v_transaksi_ringkasan')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) =>
              TransaksiRingkasan.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (isDemoMode) {
        final all = List<TransaksiRingkasan>.from(
          TransaksiRepository.demoRingkasanList,
        );
        all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return all.take(limit).toList();
      }
      rethrow;
    }
  }

  /// Mengambil 10 pengiriman pabrik terakhir dari `v_pengiriman_ringkasan`
  Future<List<PengirimanPabrik>> getRecentPengiriman({
    int limit = 10,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      final all = List<PengirimanPabrik>.from(
        PengirimanPabrikRepository.demoList,
      );
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all.take(limit).toList();
    }

    try {
      final response = await _client!
          .from('v_pengiriman_ringkasan')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) =>
              PengirimanPabrik.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      try {
        final fallback = await _client!
            .from('pengiriman_pabrik')
            .select('*, pabrik:pabrik_id(*)')
            .order('created_at', ascending: false)
            .limit(limit);

        return (fallback as List<dynamic>)
            .map((json) =>
                PengirimanPabrik.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        if (isDemoMode) {
          final all = List<PengirimanPabrik>.from(
            PengirimanPabrikRepository.demoList,
          );
          all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return all.take(limit).toList();
        }
        rethrow;
      }
    }
  }

  // ==========================================
  // METODE DEMO DATA LOKAL TANPA DUMMY
  // ==========================================

  /// Kontrol seed dummy historis hanya untuk test suite (default FALSE = bersih kosong)
  static bool enableDummySeedForTesting = false;

  List<TransaksiHarian> _generateDemoTransaksiHarian(
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<String, TransaksiHarian> dayMap = {};
    final now = DateTime.now();

    if (enableDummySeedForTesting) {
      final seedDays = [
        (1, 4, '3800.00', '3610.00', '190.00', '8844500.00'),
        (2, 3, '3100.00', '2945.00', '155.00', '7215250.00'),
        (3, 5, '4900.00', '4655.00', '245.00', '11404750.00'),
        (5, 2, '2300.00', '2185.00', '115.00', '5353250.00'),
        (7, 4, '4100.00', '3895.00', '205.00', '9542750.00'),
        (10, 3, '3200.00', '3040.00', '160.00', '7448000.00'),
        (14, 6, '5800.00', '5510.00', '290.00', '13499500.00'),
        (18, 3, '3400.00', '3230.00', '170.00', '7913500.00'),
        (22, 5, '4600.00', '4370.00', '230.00', '10706500.00'),
        (28, 4, '3900.00', '3705.00', '195.00', '9077250.00'),
        (35, 3, '3300.00', '3135.00', '165.00', '7680750.00'),
        (45, 5, '5100.00', '4845.00', '255.00', '11870250.00'),
        (60, 4, '4200.00', '3990.00', '210.00', '9775500.00'),
        (80, 3, '3500.00', '3325.00', '175.00', '8146250.00'),
        (110, 6, '6200.00', '5890.00', '310.00', '14430500.00'),
        (150, 4, '4400.00', '4180.00', '220.00', '10241000.00'),
        (200, 5, '4800.00', '4560.00', '240.00', '11172000.00'),
        (280, 3, '3600.00', '3420.00', '180.00', '8379000.00'),
        (340, 4, '4000.00', '3800.00', '200.00', '9310000.00'),
      ];

      for (final item in seedDays) {
        final date = now.subtract(Duration(days: item.$1));
        if ((date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
            (date.isBefore(endDate) || date.isAtSameMomentAs(endDate))) {
          final key = date.toIso8601String().split('T').first;
          dayMap[key] = TransaksiHarian(
            tanggalTransaksi: DateTime(date.year, date.month, date.day),
            jumlahTransaksi: item.$2,
            totalBeratKotorKg: Decimal.parse(item.$3),
            totalBeratBersihKg: Decimal.parse(item.$4),
            totalPotonganRp: Decimal.parse(item.$5),
            totalNilai: Decimal.parse(item.$6),
          );
        }
      }
    }

    // Gabungkan data dari TransaksiRepository demo (status selesai)
    for (final trx in TransaksiRepository.demoRingkasanList.where((t) => t.status == 'selesai')) {
      final tgl = trx.tanggalTransaksi;
      if ((tgl.isAfter(startDate) || tgl.isAtSameMomentAs(startDate)) &&
          (tgl.isBefore(endDate) || tgl.isAtSameMomentAs(endDate))) {
        final key = tgl.toIso8601String().split('T').first;
        if (dayMap.containsKey(key)) {
          final existing = dayMap[key]!;
          dayMap[key] = TransaksiHarian(
            tanggalTransaksi: existing.tanggalTransaksi,
            jumlahTransaksi: existing.jumlahTransaksi + 1,
            totalBeratKotorKg: existing.totalBeratKotorKg + trx.totalBeratKotorKg,
            totalBeratBersihKg: existing.totalBeratBersihKg + trx.totalBeratBersihKg,
            totalPotonganRp: existing.totalPotonganRp + trx.totalPotonganRp,
            totalNilai: existing.totalNilai + trx.totalNilai,
          );
        } else {
          dayMap[key] = TransaksiHarian(
            tanggalTransaksi: DateTime(tgl.year, tgl.month, tgl.day),
            jumlahTransaksi: 1,
            totalBeratKotorKg: trx.totalBeratKotorKg,
            totalBeratBersihKg: trx.totalBeratBersihKg,
            totalPotonganRp: trx.totalPotonganRp,
            totalNilai: trx.totalNilai,
          );
        }
      }
    }

    final list = dayMap.values.toList()
      ..sort((a, b) => a.tanggalTransaksi.compareTo(b.tanggalTransaksi));
    return list;
  }

  List<PengirimanHarian> _generateDemoPengirimanHarian(
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<String, PengirimanHarian> dayMap = {};
    final now = DateTime.now();

    if (enableDummySeedForTesting) {
      final seedDays = [
        (1, 1, '8500.00', '150.00', '8141.25', '511387.50', '19946062.50'),
        (3, 1, '9200.00', '200.00', '8820.00', '540000.00', '21609000.00'),
        (7, 2, '17600.00', '350.00', '16905.00', '1035000.00', '41417250.00'),
        (14, 1, '8800.00', '180.00', '8447.60', '520000.00', '20696620.00'),
        (22, 2, '18200.00', '400.00', '17444.00', '1080000.00', '42737800.00'),
        (35, 1, '9000.00', '150.00', '8673.00', '531000.00', '21248850.00'),
        (60, 2, '17800.00', '300.00', '17150.00', '1050000.00', '42017500.00'),
        (110, 1, '9400.00', '200.00', '9016.00', '552000.00', '22089200.00'),
        (200, 2, '18500.00', '350.00', '17787.00', '1090000.00', '43578150.00'),
        (300, 1, '8900.00', '180.00', '8545.60', '525000.00', '20936720.00'),
      ];

      for (final item in seedDays) {
        final date = now.subtract(Duration(days: item.$1));
        if ((date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
            (date.isBefore(endDate) || date.isAtSameMomentAs(endDate))) {
          final key = date.toIso8601String().split('T').first;
          dayMap[key] = PengirimanHarian(
            tanggalKirim: DateTime(date.year, date.month, date.day),
            jumlahPengiriman: item.$2,
            totalBeratKotorKg: Decimal.parse(item.$3),
            totalBeratDitolakKg: Decimal.parse(item.$4),
            totalBeratBersihKg: Decimal.parse(item.$5),
            totalPotonganRp: Decimal.parse(item.$6),
            totalNilaiJual: Decimal.parse(item.$7),
          );
        }
      }
    }

    // Gabungkan dari demoList pengiriman (status selesai)
    for (final krm in PengirimanPabrikRepository.demoList.where((k) => k.status == 'selesai')) {
      final tgl = krm.tanggalKirim;
      if ((tgl.isAfter(startDate) || tgl.isAtSameMomentAs(startDate)) &&
          (tgl.isBefore(endDate) || tgl.isAtSameMomentAs(endDate))) {
        final key = tgl.toIso8601String().split('T').first;
        if (dayMap.containsKey(key)) {
          final ex = dayMap[key]!;
          dayMap[key] = PengirimanHarian(
            tanggalKirim: ex.tanggalKirim,
            jumlahPengiriman: ex.jumlahPengiriman + 1,
            totalBeratKotorKg: ex.totalBeratKotorKg + krm.beratKotorKg,
            totalBeratDitolakKg: ex.totalBeratDitolakKg + (krm.beratDitolakKg ?? Decimal.zero),
            totalBeratBersihKg: ex.totalBeratBersihKg + (krm.beratBersihKg ?? Decimal.zero),
            totalPotonganRp: ex.totalPotonganRp + (krm.nilaiPotonganRp ?? Decimal.zero),
            totalNilaiJual: ex.totalNilaiJual + (krm.totalNilaiJual ?? Decimal.zero),
          );
        } else {
          dayMap[key] = PengirimanHarian(
            tanggalKirim: DateTime(tgl.year, tgl.month, tgl.day),
            jumlahPengiriman: 1,
            totalBeratKotorKg: krm.beratKotorKg,
            totalBeratDitolakKg: krm.beratDitolakKg ?? Decimal.zero,
            totalBeratBersihKg: krm.beratBersihKg ?? Decimal.zero,
            totalPotonganRp: krm.nilaiPotonganRp ?? Decimal.zero,
            totalNilaiJual: krm.totalNilaiJual ?? Decimal.zero,
          );
        }
      }
    }

    final list = dayMap.values.toList()
      ..sort((a, b) => a.tanggalKirim.compareTo(b.tanggalKirim));
    return list;
  }

  List<MarginHarian> _generateDemoMarginHarian(
    DateTime startDate,
    DateTime endDate,
  ) {
    final pembelianList = _generateDemoTransaksiHarian(startDate, endDate);
    final penjualanList = _generateDemoPengirimanHarian(startDate, endDate);

    final Map<String, (Decimal, Decimal)> dateMap = {};

    for (final p in pembelianList) {
      final key = p.tanggalTransaksi.toIso8601String().split('T').first;
      final existing = dateMap[key] ?? (Decimal.zero, Decimal.zero);
      dateMap[key] = (existing.$1 + p.totalNilai, existing.$2);
    }

    for (final j in penjualanList) {
      final key = j.tanggalKirim.toIso8601String().split('T').first;
      final existing = dateMap[key] ?? (Decimal.zero, Decimal.zero);
      dateMap[key] = (existing.$1, existing.$2 + j.totalNilaiJual);
    }

    final list = dateMap.entries.map((e) {
      final tgl = DateTime.parse(e.key);
      final beli = e.value.$1;
      final jual = e.value.$2;
      return MarginHarian(
        tanggal: tgl,
        totalPembelian: beli,
        totalPenjualan: jual,
        margin: jual - beli,
      );
    }).toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    return list;
  }

  List<BreakdownJenisBuah> _generateDemoBreakdownJenisBuah(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (enableDummySeedForTesting) {
      final days = endDate.difference(startDate).inDays.clamp(1, 365);
      final factor = (days / 30.0).clamp(0.2, 12.0);

      final tbKg = (18450.0 * factor).roundToDouble();
      final tkKg = (7200.0 * factor).roundToDouble();
      final brKg = (4350.0 * factor).roundToDouble();

      return [
        BreakdownJenisBuah(
          jenisBuah: 'Tandan Besar',
          tanggal: startDate,
          totalBeratKotorKg: Decimal.parse('${tbKg * 1.05}'),
          totalBeratBersihKg: Decimal.parse('$tbKg'),
          totalNilai: Decimal.parse('${tbKg * 2450}'),
        ),
        BreakdownJenisBuah(
          jenisBuah: 'Tandan Kecil',
          tanggal: startDate,
          totalBeratKotorKg: Decimal.parse('${tkKg * 1.05}'),
          totalBeratBersihKg: Decimal.parse('$tkKg'),
          totalNilai: Decimal.parse('${tkKg * 2250}'),
        ),
        BreakdownJenisBuah(
          jenisBuah: 'Berondolan',
          tanggal: startDate,
          totalBeratKotorKg: Decimal.parse('${brKg * 1.05}'),
          totalBeratBersihKg: Decimal.parse('$brKg'),
          totalNilai: Decimal.parse('${brKg * 2800}'),
        ),
      ];
    }

    final Map<String, (Decimal, Decimal, Decimal)> map = {};
    for (final trx in TransaksiRepository.demoDetailMap.values) {
      if (trx.status != 'selesai') continue;
      final tgl = trx.tanggalTransaksi;
      if (tgl.isBefore(startDate) || tgl.isAfter(endDate)) continue;
      for (final item in trx.items ?? []) {
        final nama = item.jenisBuah?.nama ?? 'Lainnya';
        final ex = map[nama] ?? (Decimal.zero, Decimal.zero, Decimal.zero);
        map[nama] = (
          ex.$1 + item.beratKotorKg,
          ex.$2 + item.beratBersihKg,
          ex.$3 + item.subtotal,
        );
      }
    }

    return map.entries.map((e) => BreakdownJenisBuah(
      jenisBuah: e.key,
      tanggal: startDate,
      totalBeratKotorKg: e.value.$1,
      totalBeratBersihKg: e.value.$2,
      totalNilai: e.value.$3,
    )).toList();
  }

  List<BreakdownPabrik> _generateDemoBreakdownPabrik(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (enableDummySeedForTesting) {
      final days = endDate.difference(startDate).inDays.clamp(1, 365);
      final factor = (days / 30.0).clamp(0.2, 12.0);

      final sirKg = (16500.0 * factor).roundToDouble();
      final masKg = (9800.0 * factor).roundToDouble();
      final bpsKg = (5400.0 * factor).roundToDouble();

      return [
        BreakdownPabrik(
          namaPabrik: 'PT Sawit Inti Riau',
          tanggal: startDate,
          totalBeratKotorKg: Decimal.parse('${sirKg * 1.03}'),
          totalBeratBersihKg: Decimal.parse('$sirKg'),
          totalNilaiJual: Decimal.parse('${sirKg * 2550}'),
        ),
        BreakdownPabrik(
          namaPabrik: 'PT Mitra Agro Sawit',
          tanggal: startDate,
          totalBeratKotorKg: Decimal.parse('${masKg * 1.03}'),
          totalBeratBersihKg: Decimal.parse('$masKg'),
          totalNilaiJual: Decimal.parse('${masKg * 2520}'),
        ),
        BreakdownPabrik(
          namaPabrik: 'PT Bumi Pratama Sawit',
          tanggal: startDate,
          totalBeratKotorKg: Decimal.parse('${bpsKg * 1.03}'),
          totalBeratBersihKg: Decimal.parse('$bpsKg'),
          totalNilaiJual: Decimal.parse('${bpsKg * 2480}'),
        ),
      ];
    }

    final Map<String, (Decimal, Decimal, Decimal)> map = {};
    for (final k in PengirimanPabrikRepository.demoList) {
      if (k.status != 'selesai') continue;
      final tgl = k.tanggalKirim;
      if (tgl.isBefore(startDate) || tgl.isAfter(endDate)) continue;
      final nama = k.pabrik?.nama ?? 'Pabrik Lain';
      final ex = map[nama] ?? (Decimal.zero, Decimal.zero, Decimal.zero);
      map[nama] = (
        ex.$1 + k.beratKotorKg,
        ex.$2 + (k.beratBersihKg ?? Decimal.zero),
        ex.$3 + (k.totalNilaiJual ?? Decimal.zero),
      );
    }

    return map.entries.map((e) => BreakdownPabrik(
      namaPabrik: e.key,
      tanggal: startDate,
      totalBeratKotorKg: e.value.$1,
      totalBeratBersihKg: e.value.$2,
      totalNilaiJual: e.value.$3,
    )).toList();
  }

  List<LabaBersihHarian> _generateDemoLabaBersihHarian(
    DateTime startDate,
    DateTime endDate,
  ) {
    final marginList = _generateDemoMarginHarian(startDate, endDate);
    final pengeluaranList = _generateDemoPengeluaranHarian(startDate, endDate);

    final Map<String, (Decimal, Decimal, Decimal, Decimal)> map = {};

    for (final m in marginList) {
      final key = m.tanggal.toIso8601String().split('T').first;
      map[key] = (m.totalPembelian, m.totalPenjualan, m.margin, Decimal.zero);
    }

    for (final p in pengeluaranList) {
      final key = p.tanggalPengeluaran.toIso8601String().split('T').first;
      if (map.containsKey(key)) {
        final ex = map[key]!;
        map[key] = (ex.$1, ex.$2, ex.$3, p.totalNominal);
      } else {
        map[key] = (Decimal.zero, Decimal.zero, Decimal.zero, p.totalNominal);
      }
    }

    final list = map.entries.map((e) {
      final tgl = DateTime.parse(e.key);
      final beli = e.value.$1;
      final jual = e.value.$2;
      final margin = e.value.$3;
      final pengeluaran = e.value.$4;
      return LabaBersihHarian(
        tanggal: tgl,
        totalPembelian: beli,
        totalPenjualan: jual,
        margin: margin,
        totalPengeluaran: pengeluaran,
        labaBersih: margin - pengeluaran,
      );
    }).toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    return list;
  }

  List<PengeluaranHarian> _generateDemoPengeluaranHarian(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (enableDummySeedForTesting) {
      final now = DateTime.now();
      final seeds = [
        (0, '340000'),
        (1, '85000'),
        (3, '450000'),
        (6, '1200000'),
        (12, '500000'),
        (20, '1500000'),
      ];

      final list = <PengeluaranHarian>[];
      for (final s in seeds) {
        final tgl = now.subtract(Duration(days: s.$1));
        if ((tgl.isAfter(startDate) || tgl.isAtSameMomentAs(startDate)) &&
            (tgl.isBefore(endDate) || tgl.isAtSameMomentAs(endDate))) {
          list.add(
            PengeluaranHarian(
              tanggalPengeluaran: DateTime(tgl.year, tgl.month, tgl.day),
              totalNominal: Decimal.parse(s.$2),
            ),
          );
        }
      }
      list.sort((a, b) => a.tanggalPengeluaran.compareTo(b.tanggalPengeluaran));
      return list;
    }

    final Map<String, Decimal> map = {};
    for (final p in PengeluaranRepository.demoList) {
      final tgl = p.tanggalPengeluaran;
      if (tgl.isBefore(startDate) || tgl.isAfter(endDate)) continue;
      final key = tgl.toIso8601String().split('T').first;
      map[key] = (map[key] ?? Decimal.zero) + p.nominal;
    }

    final list = map.entries.map((e) => PengeluaranHarian(
      tanggalPengeluaran: DateTime.parse(e.key),
      totalNominal: e.value,
    )).toList()..sort((a, b) => a.tanggalPengeluaran.compareTo(b.tanggalPengeluaran));
    return list;
  }

  List<BreakdownJenisPengeluaran> _generateDemoBreakdownPengeluaran(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (enableDummySeedForTesting) {
      final days = endDate.difference(startDate).inDays.clamp(1, 365);
      final factor = (days / 30).clamp(0.2, 12.0);

      return [
        BreakdownJenisPengeluaran(
          jenisPengeluaran: 'Gaji/Upah',
          tanggal: endDate,
          totalNominal: Decimal.parse((3200000 * factor).round().toString()),
        ),
        BreakdownJenisPengeluaran(
          jenisPengeluaran: 'BBM/Transportasi',
          tanggal: endDate,
          totalNominal: Decimal.parse((1800000 * factor).round().toString()),
        ),
        BreakdownJenisPengeluaran(
          jenisPengeluaran: 'Perawatan Kendaraan',
          tanggal: endDate,
          totalNominal: Decimal.parse((950000 * factor).round().toString()),
        ),
        BreakdownJenisPengeluaran(
          jenisPengeluaran: 'Operasional Kantor',
          tanggal: endDate,
          totalNominal: Decimal.parse((400000 * factor).round().toString()),
        ),
        BreakdownJenisPengeluaran(
          jenisPengeluaran: 'Lain-lain',
          tanggal: endDate,
          totalNominal: Decimal.parse((250000 * factor).round().toString()),
        ),
      ];
    }

    final Map<String, Decimal> map = {};
    for (final p in PengeluaranRepository.demoList) {
      final tgl = p.tanggalPengeluaran;
      if (tgl.isBefore(startDate) || tgl.isAfter(endDate)) continue;
      final nama = p.jenisPengeluaranNama ?? 'Lain-lain';
      map[nama] = (map[nama] ?? Decimal.zero) + p.nominal;
    }

    return map.entries.map((e) => BreakdownJenisPengeluaran(
      jenisPengeluaran: e.key,
      tanggal: endDate,
      totalNominal: e.value,
    )).toList();
  }

  List<BreakdownMetodePembayaran> _generateDemoBreakdownMetodePembayaran(
    DateTime startDate,
    DateTime endDate,
  ) {
    // 1. Ambil data transaksi harian demo untuk mendapatkan baseline nilai & volume
    final harianList = _generateDemoTransaksiHarian(startDate, endDate);
    Decimal totalNilaiBaseline = Decimal.zero;
    Decimal totalBeratBaseline = Decimal.zero;
    int totalCountBaseline = 0;

    for (final h in harianList) {
      totalNilaiBaseline += h.totalNilai;
      totalBeratBaseline += h.totalBeratBersihKg;
      totalCountBaseline += h.jumlahTransaksi;
    }

    // Baseline estimasi: ~70% Tunai, ~30% Non Tunai
    final tunaiCountBase = (totalCountBaseline * 0.7).round();
    final nonTunaiCountBase = totalCountBaseline - tunaiCountBase;

    final tunaiNilaiBase = Decimal.parse(
        (double.parse(totalNilaiBaseline.toString()) * 0.7).round().toString());
    final nonTunaiNilaiBase = totalNilaiBaseline - tunaiNilaiBase;

    final tunaiBeratBase = Decimal.parse(
        (double.parse(totalBeratBaseline.toString()) * 0.7).round().toString());
    final nonTunaiBeratBase = totalBeratBaseline - tunaiBeratBase;

    Decimal totalTunai = tunaiNilaiBase;
    Decimal beratTunai = tunaiBeratBase;
    int countTunai = tunaiCountBase;

    Decimal totalNonTunai = nonTunaiNilaiBase;
    Decimal beratNonTunai = nonTunaiBeratBase;
    int countNonTunai = nonTunaiCountBase;

    // 2. Tambahkan transaksi dinamis yang baru dibuat di sesi demo ini
    for (final trx in TransaksiRepository.demoRingkasanList
        .where((t) => t.status == 'selesai')) {
      final tgl = trx.tanggalTransaksi;
      final startNorm =
          DateTime(startDate.year, startDate.month, startDate.day);
      final endNorm =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      if ((tgl.isAfter(startNorm) || tgl.isAtSameMomentAs(startNorm)) &&
          (tgl.isBefore(endNorm) || tgl.isAtSameMomentAs(endNorm))) {
        if (trx.jenisPembayaran == 'non_tunai') {
          totalNonTunai += trx.totalNilai;
          beratNonTunai += trx.totalBeratBersihKg;
          countNonTunai++;
        } else {
          totalTunai += trx.totalNilai;
          beratTunai += trx.totalBeratBersihKg;
          countTunai++;
        }
      }
    }

    return [
      BreakdownMetodePembayaran(
        metode: 'tunai',
        jumlahTransaksi: countTunai,
        totalNilai: totalTunai,
        totalBeratBersihKg: beratTunai,
      ),
      BreakdownMetodePembayaran(
        metode: 'non_tunai',
        jumlahTransaksi: countNonTunai,
        totalNilai: totalNonTunai,
        totalBeratBersihKg: beratNonTunai,
      ),
    ];
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userRole = ref.watch(authControllerProvider).profile?.role ?? 'kasir';
  final trxRepo = ref.watch(transaksiRepositoryProvider);
  return DashboardRepository(client, userRole, trxRepo);
});
