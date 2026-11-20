import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/app_database.dart';
import '../../core/supabase_client.dart';
import '../../core/utils/app_exception_helper.dart';
import '../../models/paginated_result.dart';
import '../../models/pemakaian_saldo_harian.dart';
import '../../models/saldo_ringkasan.dart';
import '../../models/topup_saldo.dart';
import '../../models/transaksi.dart';
import '../../models/transaksi_non_tunai_harian.dart';

/// Item rincian transaksi pembelian yang mengurangi saldo untuk Laporan Saldo (FR-10.9)
class PembelianPengurangSaldo {
  final String id;
  final String kodeTransaksi;
  final DateTime tanggal;
  final String namaPenjual;
  final Decimal nominal;

  const PembelianPengurangSaldo({
    required this.id,
    required this.kodeTransaksi,
    required this.tanggal,
    required this.namaPenjual,
    required this.nominal,
  });

  factory PembelianPengurangSaldo.fromTransaksiRingkasan(TransaksiRingkasan tr) {
    return PembelianPengurangSaldo(
      id: tr.id,
      kodeTransaksi: tr.kodeTransaksi,
      tanggal: tr.tanggalTransaksi,
      namaPenjual: tr.namaPenjual,
      nominal: tr.totalNilai,
    );
  }
}

/// Repository untuk Modul Saldo / Dana Modal (PRD §7.10, Database.md §11)
class SaldoRepository {
  final SupabaseClient? _client;
  final AppDatabase? _db;

  SaldoRepository([this._client, this._db]);

  bool get isDemoMode => _client == null;

  // Demo state in-memory untuk offline/testing (bersih tanpa dummy)
  static final List<TopupSaldo> _demoTopupList = [];
  static final List<PembelianPengurangSaldo> _demoPembelianList = [];

  static void seedDemoDataForTesting() {
    _demoTopupList.clear();
    _demoPembelianList.clear();
    _demoTopupList.addAll([
      TopupSaldo(
        id: 'tp-today',
        tanggal: DateTime.now(),
        nominal: Decimal.parse('15000000'),
        keterangan: 'Top up kas modal operasional pagi ini',
        createdBy: 'demo-admin',
        createdByName: 'Administrator Sawit',
        createdAt: DateTime.now(),
      ),
      TopupSaldo(
        id: 'tp-1',
        tanggal: DateTime.now().subtract(const Duration(days: 15)),
        nominal: Decimal.parse('50000000'),
        keterangan: 'Modal awal operasional pembelian sawit',
        createdBy: 'demo-admin',
        createdByName: 'Administrator Sawit',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      TopupSaldo(
        id: 'tp-2',
        tanggal: DateTime.now().subtract(const Duration(days: 5)),
        nominal: Decimal.parse('25000000'),
        keterangan: 'Penambahan kas modal panen puncak',
        createdBy: 'demo-admin',
        createdByName: 'Administrator Sawit',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
    _demoPembelianList.addAll([
      PembelianPengurangSaldo(
        id: 'trx-today-1',
        kodeTransaksi: 'TRX-20260920-001',
        tanggal: DateTime.now(),
        namaPenjual: 'Pak Budi Hartono',
        nominal: Decimal.parse('5200000'),
      ),
      PembelianPengurangSaldo(
        id: 'trx-today-2',
        kodeTransaksi: 'TRX-20260920-002',
        tanggal: DateTime.now(),
        namaPenjual: 'Haji Mansur',
        nominal: Decimal.parse('4800000'),
      ),
      PembelianPengurangSaldo(
        id: 'trx-past-1',
        kodeTransaksi: 'TRX-20260915-001',
        tanggal: DateTime.now().subtract(const Duration(days: 5)),
        namaPenjual: 'Siti Rahma',
        nominal: Decimal.parse('18500000'),
      ),
      PembelianPengurangSaldo(
        id: 'trx-past-2',
        kodeTransaksi: 'TRX-20260910-001',
        tanggal: DateTime.now().subtract(const Duration(days: 10)),
        namaPenjual: 'Wayan Sudirta',
        nominal: Decimal.parse('14000000'),
      ),
    ]);
  }

  static void clearDemoData() {
    _demoTopupList.clear();
    _demoPembelianList.clear();
  }

  /// Mengambil data ringkasan saldo saat ini beserta total top up & pemakaian sesuai filter periode (FR-10.2, FR-10.3)
  Future<SaldoRingkasan> getSaldoRingkasan({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      final totalTopupAll = _demoTopupList.fold<Decimal>(
        Decimal.zero,
        (sum, item) => sum + item.nominal,
      );
      final totalPemakaianAll = _demoPembelianList.fold<Decimal>(
        Decimal.zero,
        (sum, item) => sum + item.nominal,
      );

      Decimal totalTopupPeriode = totalTopupAll;
      Decimal totalPemakaianPeriode = totalPemakaianAll;

      if (startDate != null || endDate != null) {
        final startDay = startDate != null
            ? DateTime(startDate.year, startDate.month, startDate.day)
            : null;
        final endDay = endDate != null
            ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
            : null;

        totalTopupPeriode = _demoTopupList
            .where((t) =>
                (startDay == null || !t.tanggal.isBefore(startDay)) &&
                (endDay == null || !t.tanggal.isAfter(endDay)))
            .fold<Decimal>(Decimal.zero, (sum, item) => sum + item.nominal);

        totalPemakaianPeriode = _demoPembelianList
            .where((t) =>
                (startDay == null || !t.tanggal.isBefore(startDay)) &&
                (endDay == null || !t.tanggal.isAfter(endDay)))
            .fold<Decimal>(Decimal.zero, (sum, item) => sum + item.nominal);
      }

      return SaldoRingkasan(
        totalTopup: totalTopupAll,
        totalPemakaian: totalPemakaianAll,
        sisaSaldo: totalTopupAll - totalPemakaianAll,
        totalTopupPeriode: totalTopupPeriode,
        totalPemakaianPeriode: totalPemakaianPeriode,
      );
    }

    try {
      final client = _client!;

      // 1. Ambil sisa saldo riil saat ini (seluruh waktu)
      SaldoRingkasan baseRingkasan;
      try {
        final viewRes = await client
            .from('v_saldo_ringkasan')
            .select()
            .maybeSingle();
        if (viewRes != null) {
          baseRingkasan = SaldoRingkasan.fromJson(viewRes);
        } else {
          baseRingkasan = SaldoRingkasan.zero();
        }
      } catch (_) {
        // Fallback akumulasi total
        final topupList = await client.from('topup_saldo').select('nominal');
        final trxList = await client
            .from('v_transaksi_ringkasan')
            .select('total_nilai')
            .eq('status', 'selesai')
            .eq('jenis_pembayaran', 'tunai');

        var sumTopup = Decimal.zero;
        for (final item in (topupList as List)) {
          sumTopup += Decimal.tryParse(item['nominal']?.toString() ?? '0') ?? Decimal.zero;
        }
        var sumTrx = Decimal.zero;
        for (final item in (trxList as List)) {
          sumTrx += Decimal.tryParse(item['total_nilai']?.toString() ?? '0') ?? Decimal.zero;
        }

        baseRingkasan = SaldoRingkasan(
          totalTopup: sumTopup,
          totalPemakaian: sumTrx,
          sisaSaldo: sumTopup - sumTrx,
        );
      }

      // 2. Hitung total top up dan total pemakaian dalam periode filter
      Decimal totalTopupPeriode = baseRingkasan.totalTopup;
      Decimal totalPemakaianPeriode = baseRingkasan.totalPemakaian;

      if (startDate != null || endDate != null) {
        var topupQuery = client.from('topup_saldo').select('nominal');
        var trxQuery = client
            .from('v_transaksi_ringkasan')
            .select('total_nilai')
            .eq('status', 'selesai')
            .eq('jenis_pembayaran', 'tunai');

        if (startDate != null) {
          final sStr = startDate.toIso8601String().split('T').first;
          topupQuery = topupQuery.gte('tanggal', sStr);
          trxQuery = trxQuery.gte('tanggal_transaksi', sStr);
        }
        if (endDate != null) {
          final eStr = endDate.toIso8601String().split('T').first;
          topupQuery = topupQuery.lte('tanggal', eStr);
          trxQuery = trxQuery.lte('tanggal_transaksi', eStr);
        }

        final topupPeriodeRes = await topupQuery;
        totalTopupPeriode = Decimal.zero;
        for (final item in (topupPeriodeRes as List)) {
          totalTopupPeriode +=
              Decimal.tryParse(item['nominal']?.toString() ?? '0') ?? Decimal.zero;
        }

        final trxPeriodeRes = await trxQuery;
        totalPemakaianPeriode = Decimal.zero;
        for (final item in (trxPeriodeRes as List)) {
          totalPemakaianPeriode +=
              Decimal.tryParse(item['total_nilai']?.toString() ?? '0') ?? Decimal.zero;
        }
      }

      return baseRingkasan.copyWith(
        totalTopupPeriode: totalTopupPeriode,
        totalPemakaianPeriode: totalPemakaianPeriode,
      );
    } catch (e) {
      if (isDemoMode) {
        return SaldoRingkasan.zero();
      }
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Mengambil daftar riwayat top up dengan paginasi dan filter tanggal (FR-10.4)
  Future<PaginatedResult<TopupSaldo>> fetchTopupPaginated({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 15,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      var filtered = List<TopupSaldo>.from(_demoTopupList);

      if (startDate != null) {
        final startDay = DateTime(startDate.year, startDate.month, startDate.day);
        filtered = filtered.where((t) => !t.tanggal.isBefore(startDay)).toList();
      }
      if (endDate != null) {
        final endDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        filtered = filtered.where((t) => !t.tanggal.isAfter(endDay)).toList();
      }

      filtered.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      final totalCount = filtered.length;
      final from = (page - 1) * pageSize;
      final to = (from + pageSize).clamp(0, totalCount);
      final items = from < totalCount ? filtered.sublist(from, to) : <TopupSaldo>[];

      return PaginatedResult<TopupSaldo>(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    }

    try {
      var countQuery = _client!.from('topup_saldo').select('id');
      if (startDate != null) {
        countQuery = countQuery.gte(
          'tanggal',
          startDate.toIso8601String().split('T').first,
        );
      }
      if (endDate != null) {
        countQuery = countQuery.lte(
          'tanggal',
          endDate.toIso8601String().split('T').first,
        );
      }

      final countResponse = await countQuery;
      final totalCount = (countResponse as List).length;

      var query = _client.from('topup_saldo').select('*');

      if (startDate != null) {
        query = query.gte(
          'tanggal',
          startDate.toIso8601String().split('T').first,
        );
      }
      if (endDate != null) {
        query = query.lte(
          'tanggal',
          endDate.toIso8601String().split('T').first,
        );
      }

      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final response = await query
          .order('tanggal', ascending: false)
          .order('created_at', ascending: false)
          .range(from, to);

      final items = (response as List<dynamic>)
          .map((json) => TopupSaldo.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedResult<TopupSaldo>(
        items: items,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      if (isDemoMode) {
        return PaginatedResult<TopupSaldo>(
          items: _demoTopupList,
          totalCount: _demoTopupList.length,
          page: 1,
          pageSize: pageSize,
        );
      }
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Mengambil semua entri top up dalam periode (untuk Export Laporan Saldo Bagian 2)
  Future<List<TopupSaldo>> fetchAllTopupForPeriod({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final paginated = await fetchTopupPaginated(
      startDate: startDate,
      endDate: endDate,
      page: 1,
      pageSize: 10000,
    );
    return paginated.items;
  }

  /// Mengambil rincian transaksi pembelian berstatus 'selesai' dalam rentang tanggal
  /// untuk Export Laporan Saldo Bagian 3 (FR-10.9)
  Future<List<PembelianPengurangSaldo>> fetchTransaksiPembelianRingkasForPeriod({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      return [
        PembelianPengurangSaldo(
          id: 'trx-1',
          kodeTransaksi: 'TRX-20260919-001',
          tanggal: DateTime.now().subtract(const Duration(days: 1)),
          namaPenjual: 'Pak Budi Hartono',
          nominal: Decimal.parse('18500000'),
        ),
        PembelianPengurangSaldo(
          id: 'trx-2',
          kodeTransaksi: 'TRX-20260919-002',
          tanggal: DateTime.now(),
          namaPenjual: 'Haji Mansur',
          nominal: Decimal.parse('24000000'),
        ),
      ];
    }

    try {
      var query = _client!
          .from('v_transaksi_ringkasan')
          .select('id, kode_transaksi, tanggal_transaksi, status, nama_penjual, total_nilai, jenis_pembayaran')
          .eq('status', 'selesai')
          .eq('jenis_pembayaran', 'tunai');

      if (startDate != null) {
        query = query.gte(
          'tanggal_transaksi',
          startDate.toIso8601String().split('T').first,
        );
      }
      if (endDate != null) {
        query = query.lte(
          'tanggal_transaksi',
          endDate.toIso8601String().split('T').first,
        );
      }

      final response = await query
          .order('tanggal_transaksi', ascending: false)
          .limit(10000);

      return (response as List<dynamic>).map((json) {
        final rawNilai = json['total_nilai'] ?? '0';
        return PembelianPengurangSaldo(
          id: json['id'] as String,
          kodeTransaksi: json['kode_transaksi'] as String? ?? '-',
          tanggal: json['tanggal_transaksi'] != null
              ? DateTime.parse(json['tanggal_transaksi'] as String)
              : DateTime.now(),
          namaPenjual: json['nama_penjual'] as String? ?? 'Penjual',
          nominal: Decimal.parse(rawNilai.toString()),
        );
      }).toList();
    } catch (e) {
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Mencatat Top Up dana modal baru (FR-10.1)
  Future<TopupSaldo> createTopup({
    required DateTime tanggal,
    required Decimal nominal,
    String? keterangan,
  }) async {
    if (nominal <= Decimal.zero) {
      throw const FormatException('Nominal top up harus lebih besar dari Rp 0.');
    }

    final userId = _client?.auth.currentUser?.id;
    final userName = _client?.auth.currentUser?.userMetadata?['nama'] as String? ?? 'Administrator';

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      final newId = 'tp-${DateTime.now().millisecondsSinceEpoch}';
      final created = TopupSaldo(
        id: newId,
        tanggal: tanggal,
        nominal: nominal,
        keterangan: keterangan?.trim(),
        createdBy: userId ?? 'demo-admin',
        createdByName: userName,
        createdAt: DateTime.now(),
      );
      _demoTopupList.insert(0, created);

      final db = _db;
      if (db != null) {
        try {
          await db.into(db.localTopupSaldo).insert(
                LocalTopupSaldoCompanion.insert(
                  id: newId,
                  nominal: nominal.toString(),
                  tanggal: tanggal,
                  keterangan: Value(keterangan?.trim()),
                  status: const Value('aktif'),
                  createdBy: Value(userId ?? 'demo-admin'),
                  isSynced: const Value(false),
                ),
              );
        } catch (_) {}
      }

      return created;
    }

    try {
      final insertData = {
        'tanggal': tanggal.toIso8601String().split('T').first,
        'nominal': nominal.toString(),
        if (keterangan != null && keterangan.trim().isNotEmpty)
          'keterangan': keterangan.trim(),
        'created_by': ?userId,
      };

      final response = await _client!
          .from('topup_saldo')
          .insert(insertData)
          .select('*')
          .single();

      return TopupSaldo.fromJson(response);
    } catch (e) {
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Menghapus catatan top up jika diperlukan
  Future<void> deleteTopup(String id) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      _demoTopupList.removeWhere((t) => t.id == id);
      return;
    }

    try {
      await _client!.from('topup_saldo').delete().eq('id', id);
    } catch (e) {
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Mengambil data total pemakaian saldo oleh kasir per hari (minus -)
  Future<List<PemakaianSaldoHarian>> fetchPemakaianHarian({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      var filtered = List<PembelianPengurangSaldo>.from(_demoPembelianList);

      if (startDate != null) {
        final startDay = DateTime(startDate.year, startDate.month, startDate.day);
        filtered = filtered.where((t) => !t.tanggal.isBefore(startDay)).toList();
      }
      if (endDate != null) {
        final endDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        filtered = filtered.where((t) => !t.tanggal.isAfter(endDay)).toList();
      }

      final Map<String, (DateTime, Decimal, int)> groups = {};
      for (final item in filtered) {
        final dateKey = '${item.tanggal.year}-${item.tanggal.month.toString().padLeft(2, '0')}-${item.tanggal.day.toString().padLeft(2, '0')}';
        final prev = groups[dateKey];
        if (prev != null) {
          groups[dateKey] = (prev.$1, prev.$2 + item.nominal, prev.$3 + 1);
        } else {
          groups[dateKey] = (DateTime(item.tanggal.year, item.tanggal.month, item.tanggal.day), item.nominal, 1);
        }
      }

      final result = groups.values.map((g) => PemakaianSaldoHarian(
        tanggal: g.$1,
        totalPemakaian: g.$2,
        jumlahTransaksi: g.$3,
      )).toList();
      result.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return result;
    }

    try {
      final client = _client!;
      var query = client
          .from('v_transaksi_ringkasan')
          .select('tanggal_transaksi, total_nilai')
          .eq('status', 'selesai')
          .eq('jenis_pembayaran', 'tunai');

      if (startDate != null) {
        query = query.gte(
          'tanggal_transaksi',
          startDate.toIso8601String().split('T').first,
        );
      }
      if (endDate != null) {
        query = query.lte(
          'tanggal_transaksi',
          endDate.toIso8601String().split('T').first,
        );
      }

      final response = await query.order('tanggal_transaksi', ascending: false).limit(5000);
      final Map<String, (DateTime, Decimal, int)> groups = {};

      for (final row in (response as List)) {
        final rawDate = row['tanggal_transaksi']?.toString();
        if (rawDate == null) continue;
        final dateKey = rawDate.split('T').first;
        final dt = DateTime.tryParse(dateKey) ?? DateTime.now();
        final val = Decimal.tryParse(row['total_nilai']?.toString() ?? '0') ?? Decimal.zero;

        final prev = groups[dateKey];
        if (prev != null) {
          groups[dateKey] = (prev.$1, prev.$2 + val, prev.$3 + 1);
        } else {
          groups[dateKey] = (dt, val, 1);
        }
      }

      final result = groups.values.map((g) => PemakaianSaldoHarian(
        tanggal: g.$1,
        totalPemakaian: g.$2,
        jumlahTransaksi: g.$3,
      )).toList();
      result.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return result;
    } catch (e) {
      throw Exception(AppExceptionHelper.toUserFriendlyMessage(e));
    }
  }

  /// Mengambil daftar agregasi transaksi non tunai per hari dari view `v_transaksi_non_tunai_harian` (PRD §7.10 FR-10.10)
  Future<List<TransaksiNonTunaiHarian>> fetchTransaksiNonTunaiHarian({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isDemoMode) {
      return [];
    }

    try {
      var query = _client!.from('v_transaksi_non_tunai_harian').select();

      if (startDate != null) {
        query = query.gte(
          'tanggal',
          startDate.toIso8601String().split('T').first,
        );
      }
      if (endDate != null) {
        query = query.lte(
          'tanggal',
          endDate.toIso8601String().split('T').first,
        );
      }

      final response = await query.order('tanggal', ascending: false);
      return (response as List<dynamic>)
          .map((json) =>
              TransaksiNonTunaiHarian.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Mengambil linimasa aktivitas mutasi saldo (+ Top Up per aksi, - Pemakaian per hari)
  Future<List<MutasiSaldoItem>> fetchMutasiLinimasa({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final topups = await fetchAllTopupForPeriod(startDate: startDate, endDate: endDate);
    final pemakaians = await fetchPemakaianHarian(startDate: startDate, endDate: endDate);

    final List<MutasiSaldoItem> list = [
      ...topups.map((t) => MutasiSaldoItem.topup(t)),
      ...pemakaians.map((p) => MutasiSaldoItem.pemakaian(p)),
    ];

    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }
}

final saldoRepositoryProvider = Provider<SaldoRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return SaldoRepository(client, db);
});
