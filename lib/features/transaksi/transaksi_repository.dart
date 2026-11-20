import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/app_database.dart';
import '../../core/supabase_client.dart';
import '../../core/utils/app_exception_helper.dart';
import '../../models/jenis_buah.dart';
import '../../models/penjual.dart';
import '../../models/transaksi.dart';
import '../../models/transaksi_item.dart';
import '../../models/laporan_export_item.dart';
import '../../models/paginated_result.dart';

/// Draft item transaksi sebelum disimpan ke database (Bagian 10: Potongan per berat item)
class TransaksiItemDraft {
  final int jenisBuahId;
  final String jenisBuahNama;
  final Decimal hargaPerKg;
  final Decimal beratKotorKg;
  final Decimal persentasePotongan;

  TransaksiItemDraft({
    required this.jenisBuahId,
    required this.jenisBuahNama,
    required this.hargaPerKg,
    required this.beratKotorKg,
    Decimal? persentasePotongan,
  }) : persentasePotongan = persentasePotongan ?? Decimal.zero;

  // Compatibility getter
  Decimal get beratKg => beratKotorKg;

  /// Berat Bersih (kg) = round(berat_kotor * (1 - potongan% / 100), 2)
  Decimal get beratBersihKg {
    if (persentasePotongan <= Decimal.zero) return beratKotorKg;
    return (beratKotorKg * (Decimal.fromInt(100) - persentasePotongan) / Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 2);
  }

  /// Nilai Potongan (Rp) = round(harga * berat_kotor * potongan% / 100, 2)
  Decimal get nilaiPotonganRp {
    if (persentasePotongan <= Decimal.zero) return Decimal.zero;
    return (hargaPerKg * beratKotorKg * persentasePotongan / Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 2);
  }

  /// Subtotal (Rp) = harga_per_kg * berat_bersih_kg
  Decimal get subtotal => hargaPerKg * beratBersihKg;
}

/// Repository untuk mengelola transaksi jual beli sawit (tabel `public.transaksi` dan `public.transaksi_item`).
class TransaksiRepository {
  final SupabaseClient? _client;
  final AppDatabase? _db;

  static List<TransaksiRingkasan> get demoRingkasanList => _demoRingkasanList;
  static Map<String, Transaksi> get demoDetailMap => _demoDetailMap;

  // In-memory list transaksi untuk demo / testing (bersih tanpa data dummy)
  static final List<TransaksiRingkasan> _demoRingkasanList = [];

  static final Map<String, Transaksi> _demoDetailMap = {};

  static int _demoSequence = 1;

  /// Metode pengisian data dummy untuk keperluan test suite
  static void seedDemoDataForTesting() {
    _demoRingkasanList.clear();
    _demoDetailMap.clear();
    _demoSequence = 3;

    final trx1 = TransaksiRingkasan(
      id: 'trx-demo-001',
      kodeTransaksi: 'TRX-20260904-0001',
      tanggalTransaksi: DateTime.now(),
      status: 'selesai',
      penjualId: 'p-001',
      namaPenjual: 'Haji Sukirman (Koperasi Sawit Makmur)',
      totalBeratKotorKg: Decimal.parse('1500.00'),
      totalBeratBersihKg: Decimal.parse('1500.00'),
      totalPotonganRp: Decimal.zero,
      totalNilai: Decimal.parse('3900000.00'),
      catatan: 'Armada Colt Diesel BM 8899 XX',
      createdBy: 'demo-user-id-12345',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    );

    final trx2 = TransaksiRingkasan(
      id: 'trx-demo-002',
      kodeTransaksi: 'TRX-20260903-0001',
      tanggalTransaksi: DateTime.now().subtract(const Duration(days: 1)),
      status: 'selesai',
      penjualId: 'p-002',
      namaPenjual: 'Pak Joko Sutrisno',
      totalBeratKotorKg: Decimal.parse('850.50'),
      totalBeratBersihKg: Decimal.parse('850.50'),
      totalPotonganRp: Decimal.zero,
      totalNilai: Decimal.parse('2126250.00'),
      catatan: 'Kebun KM 14',
      createdBy: 'demo-user-id-12345',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    );

    _demoRingkasanList.addAll([trx1, trx2]);

    _demoDetailMap['trx-demo-001'] = Transaksi(
      id: 'trx-demo-001',
      kodeTransaksi: 'TRX-20260904-0001',
      penjualId: 'p-001',
      tanggalTransaksi: DateTime.now(),
      status: 'selesai',
      catatan: 'Armada Colt Diesel BM 8899 XX',
      createdBy: 'demo-user-id-12345',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      penjual: Penjual(
        id: 'p-001',
        nama: 'Haji Sukirman (Koperasi Sawit Makmur)',
        noTelepon: '081234567890',
        alamat: 'Desa Sawit Makmur RT 02 / RW 01',
        catatan: 'Petani plasma kebun inti blok A',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      items: [
        TransaksiItem(
          id: 'item-001',
          transaksiId: 'trx-demo-001',
          jenisBuahId: 1,
          hargaPerKg: Decimal.parse('2500'),
          beratKotorKg: Decimal.parse('1000'),
          persentasePotongan: Decimal.parse('3.00'),
          beratBersihKg: Decimal.parse('970.00'),
          nilaiPotonganRp: Decimal.parse('75000.00'),
          subtotal: Decimal.parse('2425000.00'),
          createdAt: DateTime.now(),
          jenisBuah: const JenisBuah(id: 1, kode: 'TB', nama: 'Tandan Besar'),
        ),
        TransaksiItem(
          id: 'item-002',
          transaksiId: 'trx-demo-001',
          jenisBuahId: 3,
          hargaPerKg: Decimal.parse('2800'),
          beratKotorKg: Decimal.parse('500'),
          persentasePotongan: Decimal.zero,
          beratBersihKg: Decimal.parse('500'),
          nilaiPotonganRp: Decimal.zero,
          subtotal: Decimal.parse('1400000'),
          createdAt: DateTime.now(),
          jenisBuah: const JenisBuah(id: 3, kode: 'BR', nama: 'Berondolan'),
        ),
      ],
    );

    _demoDetailMap['trx-demo-002'] = Transaksi(
      id: 'trx-demo-002',
      kodeTransaksi: 'TRX-20260903-0001',
      penjualId: 'p-002',
      tanggalTransaksi: DateTime.now().subtract(const Duration(days: 1)),
      status: 'selesai',
      catatan: 'Kebun KM 14',
      createdBy: 'demo-user-id-12345',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      penjual: Penjual(
        id: 'p-002',
        nama: 'Pak Joko Sutrisno',
        noTelepon: '085298765432',
        alamat: 'Kebun Mandiri KM 14',
        catatan: 'Hasil panen TBS besar',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      items: [
        TransaksiItem(
          id: 'item-003',
          transaksiId: 'trx-demo-002',
          jenisBuahId: 1,
          hargaPerKg: Decimal.parse('2500'),
          beratKotorKg: Decimal.parse('850.50'),
          persentasePotongan: Decimal.zero,
          beratBersihKg: Decimal.parse('850.50'),
          nilaiPotonganRp: Decimal.zero,
          subtotal: Decimal.parse('2126250.00'),
          createdAt: DateTime.now(),
          jenisBuah: const JenisBuah(id: 1, kode: 'TB', nama: 'Tandan Besar'),
        ),
      ],
    );
  }

  static void clearDemoData() {
    _demoRingkasanList.clear();
    _demoDetailMap.clear();
    _demoSequence = 1;
  }

  TransaksiRepository([this._client, this._db]);

  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;

  /// Simpan transaksi baru multi-item (Bagian 24: jenisPembayaran 'tunai' | 'non_tunai')
  Future<TransaksiRingkasan> createTransaksi({
    required String penjualId,
    required String namaPenjual,
    required DateTime tanggalTransaksi,
    String jenisPembayaran = 'tunai',
    String? catatan,
    String? createdBy,
    required List<TransaksiItemDraft> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('Transaksi harus memiliki minimal 1 item jenis buah.');
    }

    final fruitIds = items.map((e) => e.jenisBuahId).toSet();
    if (fruitIds.length != items.length) {
      throw Exception('Jenis buah tidak boleh duplikat dalam satu transaksi.');
    }

    final tanggalStr = tanggalTransaksi.toIso8601String().split('T').first;

    final totalBeratKotor = items.fold<Decimal>(
      Decimal.zero,
      (sum, item) => sum + item.beratKotorKg,
    );
    final totalBeratBersih = items.fold<Decimal>(
      Decimal.zero,
      (sum, item) => sum + item.beratBersihKg,
    );
    final totalPotonganRp = items.fold<Decimal>(
      Decimal.zero,
      (sum, item) => sum + item.nilaiPotonganRp,
    );
    final totalNilai = items.fold<Decimal>(
      Decimal.zero,
      (sum, item) => sum + item.subtotal,
    );

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final dateCompact = tanggalStr.replaceAll('-', '');
      final seqStr = _demoSequence.toString().padLeft(4, '0');
      final autoKodeTransaksi = 'TRX-$dateCompact-$seqStr';
      _demoSequence++;

      final newId = 'trx-demo-${DateTime.now().millisecondsSinceEpoch}';

      final ringkasan = TransaksiRingkasan(
        id: newId,
        kodeTransaksi: autoKodeTransaksi,
        tanggalTransaksi: tanggalTransaksi,
        status: 'selesai',
        jenisPembayaran: jenisPembayaran,
        penjualId: penjualId,
        namaPenjual: namaPenjual,
        totalBeratKotorKg: totalBeratKotor,
        totalBeratBersihKg: totalBeratBersih,
        totalPotonganRp: totalPotonganRp,
        totalNilai: totalNilai,
        catatan: catatan?.trim().isEmpty == true ? null : catatan?.trim(),
        createdBy: createdBy ?? 'demo-user-id-12345',
        createdAt: DateTime.now(),
      );

      _demoRingkasanList.insert(0, ringkasan);

      // Simpan detail demo
      _demoDetailMap[newId] = Transaksi(
        id: newId,
        kodeTransaksi: autoKodeTransaksi,
        penjualId: penjualId,
        tanggalTransaksi: tanggalTransaksi,
        status: 'selesai',
        jenisPembayaran: jenisPembayaran,
        catatan: catatan,
        totalNilai: totalNilai,
        createdBy: createdBy ?? 'demo-user-id-12345',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        penjual: Penjual(
          id: penjualId,
          nama: namaPenjual,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        items: items.map((it) {
          return TransaksiItem(
            id: 'item-${DateTime.now().millisecondsSinceEpoch}-${it.jenisBuahId}',
            transaksiId: newId,
            jenisBuahId: it.jenisBuahId,
            hargaPerKg: it.hargaPerKg,
            beratKotorKg: it.beratKotorKg,
            persentasePotongan: it.persentasePotongan,
            beratBersihKg: it.beratBersihKg,
            nilaiPotonganRp: it.nilaiPotonganRp,
            subtotal: it.subtotal,
            createdAt: DateTime.now(),
            jenisBuah: JenisBuah(
              id: it.jenisBuahId,
              kode: it.jenisBuahId == 1
                  ? 'TB'
                  : (it.jenisBuahId == 2 ? 'TK' : 'BR'),
              nama: it.jenisBuahNama,
            ),
          );
        }).toList(),
      );

      if (_db != null) {
        try {
          await _db.into(_db.localTransaksi).insert(
                LocalTransaksiCompanion.insert(
                  id: newId,
                  kodeTransaksi: autoKodeTransaksi,
                  penjualId: penjualId,
                  tanggalTransaksi: tanggalTransaksi,
                  status: const Value('selesai'),
                  jenisPembayaran: Value(jenisPembayaran),
                  catatan: Value(catatan),
                  createdBy: Value(createdBy ?? 'demo-user-id-12345'),
                ),
              );

          for (final it in items) {
            await _db.into(_db.localTransaksiItem).insert(
                  LocalTransaksiItemCompanion.insert(
                    id: 'item-${DateTime.now().millisecondsSinceEpoch}-${it.jenisBuahId}',
                    transaksiId: newId,
                    jenisBuahId: it.jenisBuahId,
                    hargaPerKg: it.hargaPerKg.toString(),
                    beratKg: it.beratBersihKg.toString(),
                    beratKotorKg: Value(it.beratKotorKg.toString()),
                    persenPotongan: Value(it.persentasePotongan.toString()),
                    nilaiPotonganKg: Value(it.nilaiPotonganRp.toString()),
                    subtotal: it.subtotal.toString(),
                  ),
                );
          }
        } catch (_) {}
      }

      return ringkasan;
    }

    try {
      // 1. Insert header transaksi
      final headerInsert = {
        'penjual_id': penjualId,
        'tanggal_transaksi': tanggalStr,
        'status': 'selesai',
        'jenis_pembayaran': jenisPembayaran,
        'catatan': catatan?.trim().isEmpty == true ? null : catatan?.trim(),
        'created_by': createdBy,
      };

      final headerResponse = await _client!
          .from('transaksi')
          .insert(headerInsert)
          .select('id, kode_transaksi, created_at')
          .single();

      final transaksiId = headerResponse['id'] as String;
      final autoKodeTransaksi = headerResponse['kode_transaksi'] as String;

      // 2. Insert items dengan kolom berat_kotor_kg dan persentase_potongan
      final itemsInsert = items.map((item) {
        return {
          'transaksi_id': transaksiId,
          'jenis_buah_id': item.jenisBuahId,
          'harga_per_kg': item.hargaPerKg.toString(),
          'berat_kotor_kg': item.beratKotorKg.toString(),
          'persentase_potongan': item.persentasePotongan.toString(),
        };
      }).toList();

      try {
        await _client.from('transaksi_item').insert(itemsInsert);
      } catch (itemErr) {
        if (itemErr.toString().contains('berat_kotor_kg') ||
            itemErr.toString().contains('persentase_potongan')) {
          // Fallback jika migration belum dieksekusi di database
          final fallbackItems = items.map((item) {
            return {
              'transaksi_id': transaksiId,
              'jenis_buah_id': item.jenisBuahId,
              'harga_per_kg': item.hargaPerKg.toString(),
              'berat_kg': item.beratKotorKg.toString(),
            };
          }).toList();
          await _client.from('transaksi_item').insert(fallbackItems);
        } else {
          rethrow;
        }
      }

      // 3. Ambil data ringkasan teragregasi dari view DB
      final ringkasanResponse = await _client
          .from('v_transaksi_ringkasan')
          .select()
          .eq('id', transaksiId)
          .maybeSingle();

      if (ringkasanResponse != null) {
        return TransaksiRingkasan.fromJson(ringkasanResponse);
      }

      return TransaksiRingkasan(
        id: transaksiId,
        kodeTransaksi: autoKodeTransaksi,
        tanggalTransaksi: tanggalTransaksi,
        status: 'selesai',
        penjualId: penjualId,
        namaPenjual: namaPenjual,
        totalBeratKotorKg: totalBeratKotor,
        totalBeratBersihKg: totalBeratBersih,
        totalPotonganRp: totalPotonganRp,
        totalNilai: totalNilai,
        catatan: catatan,
        createdBy: createdBy,
        createdAt: DateTime.parse(headerResponse['created_at'] as String),
      );
    } catch (e) {
      throw Exception(
        'Gagal menyimpan transaksi: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Mengambil daftar riwayat ringkasan transaksi langsung dari view `v_transaksi_ringkasan`
  /// Mendukung filter rentang tanggal, penjual, status transaksi, dan jenis pembayaran.
  Future<List<TransaksiRingkasan>> getFilteredRingkasanList({
    DateTime? startDate,
    DateTime? endDate,
    String? penjualId,
    String? status,
    String? jenisPembayaran,
  }) async {
    if (isDemoMode) {
      if (_db != null && _demoRingkasanList.isEmpty) {
        try {
          await _loadDemoFromDatabase();
        } catch (_) {}
      }
      await Future.delayed(const Duration(milliseconds: 150));
      return _demoRingkasanList.where((item) {
        if (status != null && status.isNotEmpty && status != 'semua') {
          if (item.status != status) return false;
        }
        if (jenisPembayaran != null &&
            jenisPembayaran.isNotEmpty &&
            jenisPembayaran != 'semua') {
          if (item.jenisPembayaran != jenisPembayaran) return false;
        }
        if (penjualId != null && penjualId.isNotEmpty) {
          if (item.penjualId != penjualId) return false;
        }
        if (startDate != null) {
          final itemDate = DateTime(
            item.tanggalTransaksi.year,
            item.tanggalTransaksi.month,
            item.tanggalTransaksi.day,
          );
          final filterStart = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          if (itemDate.isBefore(filterStart)) return false;
        }
        if (endDate != null) {
          final itemDate = DateTime(
            item.tanggalTransaksi.year,
            item.tanggalTransaksi.month,
            item.tanggalTransaksi.day,
          );
          final filterEnd = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
          );
          if (itemDate.isAfter(filterEnd)) return false;
        }
        return true;
      }).toList();
    }

    try {
      var query = _client!.from('v_transaksi_ringkasan').select();

      if (status != null && status.isNotEmpty && status != 'semua') {
        query = query.eq('status', status);
      }
      if (jenisPembayaran != null &&
          jenisPembayaran.isNotEmpty &&
          jenisPembayaran != 'semua') {
        query = query.eq('jenis_pembayaran', jenisPembayaran);
      }
      if (penjualId != null && penjualId.isNotEmpty) {
        query = query.eq('penjual_id', penjualId);
      }
      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T').first;
        query = query.gte('tanggal_transaksi', startStr);
      }
      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T').first;
        query = query.lte('tanggal_transaksi', endStr);
      }

      final response =
          await query.order('tanggal_transaksi', ascending: false).order('created_at', ascending: false);

      final list = (response as List<dynamic>)
          .map((json) => TransaksiRingkasan.fromJson(json as Map<String, dynamic>))
          .toList();

      return list;
    } catch (e) {
      throw Exception(
        'Gagal memuat riwayat transaksi: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Mengambil riwayat ringkasan transaksi dengan paginasi server-side (.range)
  Future<PaginatedResult<TransaksiRingkasan>> getFilteredRingkasanPaginated({
    int page = 1,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? penjualId,
    String? status,
    String? jenisPembayaran,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      final allFiltered = await getFilteredRingkasanList(
        startDate: startDate,
        endDate: endDate,
        penjualId: penjualId,
        status: status,
        jenisPembayaran: jenisPembayaran,
      );
      final totalCount = allFiltered.length;
      final fromIndex = (page - 1) * pageSize;
      if (fromIndex >= totalCount) {
        return PaginatedResult(
          items: [],
          totalCount: totalCount,
          page: page,
          pageSize: pageSize,
        );
      }
      final toIndex = (fromIndex + pageSize) > totalCount
          ? totalCount
          : (fromIndex + pageSize);
      final pagedItems = allFiltered.sublist(fromIndex, toIndex);
      return PaginatedResult(
        items: pagedItems,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    }

    try {
      var query = _client!.from('v_transaksi_ringkasan').select();

      if (status != null && status.isNotEmpty && status != 'semua') {
        query = query.eq('status', status);
      }
      if (jenisPembayaran != null &&
          jenisPembayaran.isNotEmpty &&
          jenisPembayaran != 'semua') {
        query = query.eq('jenis_pembayaran', jenisPembayaran);
      }
      if (penjualId != null && penjualId.isNotEmpty) {
        query = query.eq('penjual_id', penjualId);
      }
      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T').first;
        query = query.gte('tanggal_transaksi', startStr);
      }
      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T').first;
        query = query.lte('tanggal_transaksi', endStr);
      }

      // Ambil total count sesuai filter
      var countQuery = _client.from('v_transaksi_ringkasan').select('id');
      if (status != null && status.isNotEmpty && status != 'semua') {
        countQuery = countQuery.eq('status', status);
      }
      if (jenisPembayaran != null &&
          jenisPembayaran.isNotEmpty &&
          jenisPembayaran != 'semua') {
        countQuery = countQuery.eq('jenis_pembayaran', jenisPembayaran);
      }
      if (penjualId != null && penjualId.isNotEmpty) {
        countQuery = countQuery.eq('penjual_id', penjualId);
      }
      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T').first;
        countQuery = countQuery.gte('tanggal_transaksi', startStr);
      }
      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T').first;
        countQuery = countQuery.lte('tanggal_transaksi', endStr);
      }

      final countResponse = await countQuery;
      final totalCount = (countResponse as List).length;

      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final response = await query
          .order('tanggal_transaksi', ascending: false)
          .order('created_at', ascending: false)
          .range(from, to);

      final list = (response as List<dynamic>)
          .map((json) =>
              TransaksiRingkasan.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedResult(
        items: list,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw Exception(
        'Gagal memuat riwayat transaksi: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Mengambil detail lengkap transaksi (beserta seluruh baris jenis buah dan penjual)
  Future<Transaksi> getTransaksiDetail(String transaksiId) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      // Cari berdasar ID atau Kode Transaksi
      if (_demoDetailMap.containsKey(transaksiId)) {
        return _demoDetailMap[transaksiId]!;
      }
      for (final trx in _demoDetailMap.values) {
        if (trx.kodeTransaksi == transaksiId) {
          return trx;
        }
      }
      throw Exception('Transaksi dengan ID "$transaksiId" tidak ditemukan.');
    }

    try {
      final response = await _client!
          .from('transaksi')
          .select('''
            id,
            kode_transaksi,
            penjual_id,
            tanggal_transaksi,
            status,
            jenis_pembayaran,
            catatan,
            created_by,
            created_at,
            updated_at,
            penjual:penjual_id (
              id,
              nama,
              no_telepon,
              alamat,
              catatan,
              is_active,
              created_at,
              updated_at
            ),
            transaksi_item (
              id,
              transaksi_id,
              jenis_buah_id,
              harga_per_kg,
              berat_kotor_kg,
              persentase_potongan,
              berat_bersih_kg,
              nilai_potongan_rp,
              subtotal,
              created_at,
              jenis_buah:jenis_buah_id (
                id,
                kode,
                nama
              )
            )
          ''')
          .or('id.eq.$transaksiId,kode_transaksi.eq.$transaksiId')
          .single();

      return Transaksi.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal memuat detail transaksi: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Pembatalan transaksi (soft-delete): Mengubah status menjadi 'dibatalkan' disertai alasan.
  Future<void> cancelTransaksi(
    String transaksiId,
    String alasan,
  ) async {
    final cleanAlasan = alasan.trim();
    if (cleanAlasan.isEmpty) {
      throw Exception('Alasan pembatalan transaksi wajib diisi.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final rIndex = _demoRingkasanList.indexWhere(
        (t) => t.id == transaksiId || t.kodeTransaksi == transaksiId,
      );
      if (rIndex != -1) {
        final current = _demoRingkasanList[rIndex];
        final currentCatatan = current.catatan ?? '';
        final newCatatan = currentCatatan.isEmpty
            ? '[Dibatalkan: $cleanAlasan]'
            : '$currentCatatan [Dibatalkan: $cleanAlasan]';

        _demoRingkasanList[rIndex] = TransaksiRingkasan(
          id: current.id,
          kodeTransaksi: current.kodeTransaksi,
          tanggalTransaksi: current.tanggalTransaksi,
          status: 'dibatalkan',
          penjualId: current.penjualId,
          namaPenjual: current.namaPenjual,
          totalBeratKotorKg: current.totalBeratKotorKg,
          totalBeratBersihKg: current.totalBeratBersihKg,
          totalPotonganRp: current.totalPotonganRp,
          totalNilai: current.totalNilai,
          catatan: newCatatan,
          alasanPembatalan: cleanAlasan,
          createdBy: current.createdBy,
          createdAt: current.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      var targetKey = _demoDetailMap.containsKey(transaksiId) ? transaksiId : null;
      if (targetKey == null) {
        for (final entry in _demoDetailMap.entries) {
          if (entry.value.kodeTransaksi == transaksiId) {
            targetKey = entry.key;
            break;
          }
        }
      }

      if (targetKey != null) {
        final detail = _demoDetailMap[targetKey]!;
        final currentCatatan = detail.catatan ?? '';
        final newCatatan = currentCatatan.isEmpty
            ? '[Dibatalkan: $cleanAlasan]'
            : '$currentCatatan [Dibatalkan: $cleanAlasan]';

        _demoDetailMap[targetKey] = detail.copyWith(
          status: 'dibatalkan',
          catatan: newCatatan,
          alasanPembatalan: cleanAlasan,
          updatedAt: DateTime.now(),
        );
      }

      if (_db != null) {
        try {
          await (_db.update(_db.localTransaksi)
                ..where((t) => t.id.equals(transaksiId) | t.kodeTransaksi.equals(transaksiId)))
              .write(
            LocalTransaksiCompanion(
              status: const Value('dibatalkan'),
              alasanBatal: Value(cleanAlasan),
              localUpdatedAt: Value(DateTime.now()),
            ),
          );
        } catch (_) {}
      }

      return;
    }

    try {
      await _client!
          .from('transaksi')
          .update({
            'status': 'dibatalkan',
            'catatan': '[Dibatalkan: $cleanAlasan]',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .or('id.eq.$transaksiId,kode_transaksi.eq.$transaksiId');
    } catch (e) {
      throw Exception(
        'Gagal membatalkan transaksi: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Mengambil data laporan pembelian detail per jenis buah per transaksi (FR-7.2, FR-7.6, Tugas Bagian 14)
  /// Mengambil langsung dari tabel `transaksi_item` dengan join `transaksi` dan `jenis_buah`.
  Future<List<LaporanPembelianItem>> getLaporanPembelianItems({
    DateTime? startDate,
    DateTime? endDate,
    String? penjualId,
    String status = 'semua',
    String? jenisPembayaran,
  }) async {
    // 1. Fallback demo HANYA aktif jika memang tidak ada koneksi/kredensial Supabase (isDemoMode)
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      return _getDemoLaporanPembelianItems(
        startDate: startDate,
        endDate: endDate,
        penjualId: penjualId,
        status: status,
        jenisPembayaran: jenisPembayaran,
      );
    }

    // 2. Query langsung ke database Supabase production
    try {
      var query = _client!.from('transaksi_item').select('''
        id,
        transaksi_id,
        jenis_buah_id,
        berat_kotor_kg,
        persentase_potongan,
        berat_bersih_kg,
        harga_per_kg,
        subtotal,
        nilai_potongan_rp,
        transaksi!inner (
          id,
          kode_transaksi,
          tanggal_transaksi,
          status,
          jenis_pembayaran,
          penjual:penjual_id (
            id,
            nama
          )
        ),
        jenis_buah:jenis_buah_id (
          id,
          kode,
          nama
        )
      ''');

      if (status != 'semua') {
        query = query.eq('transaksi.status', status);
      }
      if (jenisPembayaran != null &&
          jenisPembayaran.isNotEmpty &&
          jenisPembayaran != 'semua') {
        query = query.eq('transaksi.jenis_pembayaran', jenisPembayaran);
      }
      if (penjualId != null && penjualId.isNotEmpty) {
        query = query.eq('transaksi.penjual_id', penjualId);
      }
      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T').first;
        query = query.gte('transaksi.tanggal_transaksi', startStr);
      }
      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T').first;
        query = query.lte('transaksi.tanggal_transaksi', endStr);
      }

      final response = await query.order('id', ascending: true);
      final rawList = response as List<dynamic>;

      final items = rawList
          .map((item) => LaporanPembelianItem.fromJson(item as Map<String, dynamic>))
          .toList();

      items.sort((a, b) {
        final dateCmp = b.tanggalTransaksi.compareTo(a.tanggalTransaksi);
        if (dateCmp != 0) return dateCmp;
        return b.kodeTransaksi.compareTo(a.kodeTransaksi);
      });
      return items;
    } catch (e) {
      // PENTING (Fix Bug 2): JANGAN tutupi kegagalan query dengan fallback mock diam-diam.
      // Lempar error agar pengguna mendapat notifikasi yang jelas dan transparan.
      throw Exception(
        'Gagal memuat data laporan pembelian dari database: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Data simulasi lokal yang HANYA digunakan saat offline / demo mode
  List<LaporanPembelianItem> _getDemoLaporanPembelianItems({
    DateTime? startDate,
    DateTime? endDate,
    String? penjualId,
    String status = 'semua',
    String? jenisPembayaran,
  }) {
    final result = <LaporanPembelianItem>[];

    for (final trx in _demoDetailMap.values) {
      // Filter status
      if (status != 'semua' && trx.status.toLowerCase() != status.toLowerCase()) {
        continue;
      }
      // Filter jenis pembayaran
      if (jenisPembayaran != null &&
          jenisPembayaran.isNotEmpty &&
          jenisPembayaran != 'semua' &&
          trx.jenisPembayaran != jenisPembayaran) {
        continue;
      }
      // Filter penjual
      if (penjualId != null && penjualId.isNotEmpty && trx.penjualId != penjualId) {
        continue;
      }
      // Filter tanggal
      if (startDate != null) {
        final s = DateTime(startDate.year, startDate.month, startDate.day);
        final t = DateTime(trx.tanggalTransaksi.year, trx.tanggalTransaksi.month, trx.tanggalTransaksi.day);
        if (t.isBefore(s)) continue;
      }
      if (endDate != null) {
        final e = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        if (trx.tanggalTransaksi.isAfter(e)) continue;
      }

      for (final item in trx.items ?? <TransaksiItem>[]) {
        final potonganPct = item.persentasePotongan;
        final beratKotor = item.beratKotorKg;
        final potonganKg = (potonganPct > Decimal.zero && beratKotor > Decimal.zero)
            ? (beratKotor * potonganPct / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 2)
            : Decimal.zero;

        result.add(LaporanPembelianItem(
          kodeTransaksi: trx.kodeTransaksi,
          tanggalTransaksi: trx.tanggalTransaksi,
          namaPenjual: trx.penjual?.nama ?? 'Penjual',
          jenisBuah: item.jenisBuah?.nama ??
              (item.jenisBuahId == 1
                  ? 'Tandan Besar'
                  : item.jenisBuahId == 2
                      ? 'Tandan Kecil'
                      : 'Berondolan'),
          hargaPerKg: item.hargaPerKg,
          beratKotorKg: item.beratKotorKg,
          persentasePotongan: item.persentasePotongan,
          potonganKg: potonganKg,
          beratBersihKg: item.beratBersihKg,
          subtotal: item.subtotal,
          status: trx.status,
          jenisPembayaran: trx.jenisPembayaran,
        ));
      }
    }

    result.sort((a, b) {
      final dateCmp = b.tanggalTransaksi.compareTo(a.tanggalTransaksi);
      if (dateCmp != 0) return dateCmp;
      return b.kodeTransaksi.compareTo(a.kodeTransaksi);
    });
    return result;
  }

  /// Memastikan data lokal SQLite termuat ke in-memory demo list jika list masih kosong
  Future<void> ensureDemoLoaded() async {
    if (isDemoMode && _db != null && _demoRingkasanList.isEmpty) {
      await _loadDemoFromDatabase();
    }
  }

  Future<void> _loadDemoFromDatabase() async {
    final db = _db;
    if (db == null) return;
    final localList = await (db.select(db.localTransaksi)
          ..orderBy([(t) => OrderingTerm.desc(t.tanggalTransaksi)]))
        .get();

    for (final lt in localList) {
      if (_demoRingkasanList.any((t) => t.id == lt.id)) continue;
      final items = await (db.select(db.localTransaksiItem)
            ..where((i) => i.transaksiId.equals(lt.id)))
          .get();

      final totalKotor = items.fold<Decimal>(
        Decimal.zero,
        (sum, it) =>
            sum + (Decimal.tryParse(it.beratKotorKg ?? '0') ?? Decimal.zero),
      );
      final totalBersih = items.fold<Decimal>(
        Decimal.zero,
        (sum, it) => sum + (Decimal.tryParse(it.beratKg) ?? Decimal.zero),
      );
      final totalNilai = items.fold<Decimal>(
        Decimal.zero,
        (sum, it) => sum + (Decimal.tryParse(it.subtotal) ?? Decimal.zero),
      );
      final totalPotongan = items.fold<Decimal>(
        Decimal.zero,
        (sum, it) =>
            sum + (Decimal.tryParse(it.nilaiPotonganKg ?? '0') ?? Decimal.zero),
      );

      String namaPenjual = 'Petani Sawit';
      try {
        final p = await (db.select(db.localPenjual)
              ..where((p) => p.id.equals(lt.penjualId)))
            .getSingleOrNull();
        if (p != null) namaPenjual = p.nama;
      } catch (_) {}

      final ringkasan = TransaksiRingkasan(
        id: lt.id,
        kodeTransaksi: lt.kodeTransaksi,
        tanggalTransaksi: lt.tanggalTransaksi,
        status: lt.status,
        jenisPembayaran: lt.jenisPembayaran,
        penjualId: lt.penjualId,
        namaPenjual: namaPenjual,
        totalBeratKotorKg: totalKotor,
        totalBeratBersihKg: totalBersih,
        totalPotonganRp: totalPotongan,
        totalNilai: totalNilai,
        catatan: lt.catatan,
        alasanPembatalan: lt.alasanBatal,
        createdBy: lt.createdBy ?? 'demo-user-id-12345',
        createdAt: lt.createdAt,
      );

      _demoRingkasanList.add(ringkasan);

      _demoDetailMap[lt.id] = Transaksi(
        id: lt.id,
        kodeTransaksi: lt.kodeTransaksi,
        penjualId: lt.penjualId,
        tanggalTransaksi: lt.tanggalTransaksi,
        status: lt.status,
        jenisPembayaran: lt.jenisPembayaran,
        catatan: lt.catatan,
        totalNilai: totalNilai,
        alasanPembatalan: lt.alasanBatal,
        createdBy: lt.createdBy ?? 'demo-user-id-12345',
        createdAt: lt.createdAt,
        updatedAt: lt.updatedAt,
        penjual: Penjual(
          id: lt.penjualId,
          nama: namaPenjual,
          createdAt: lt.createdAt,
          updatedAt: lt.updatedAt,
        ),
        items: items.map((it) {
          final hg = Decimal.tryParse(it.hargaPerKg) ?? Decimal.zero;
          final bk = Decimal.tryParse(it.beratKotorKg ?? '0') ?? Decimal.zero;
          final bb = Decimal.tryParse(it.beratKg) ?? Decimal.zero;
          final pot = Decimal.tryParse(it.persenPotongan ?? '0') ?? Decimal.zero;
          final np = Decimal.tryParse(it.nilaiPotonganKg ?? '0') ?? Decimal.zero;
          final sub = Decimal.tryParse(it.subtotal) ?? Decimal.zero;

          return TransaksiItem(
            id: it.id,
            transaksiId: lt.id,
            jenisBuahId: it.jenisBuahId,
            hargaPerKg: hg,
            beratKotorKg: bk,
            persentasePotongan: pot,
            beratBersihKg: bb,
            nilaiPotonganRp: np,
            subtotal: sub,
            createdAt: it.createdAt,
            jenisBuah: JenisBuah(
              id: it.jenisBuahId,
              kode: it.jenisBuahId == 1
                  ? 'TB'
                  : (it.jenisBuahId == 2 ? 'TK' : 'BR'),
              nama: it.jenisBuahId == 1
                  ? 'TBS Normal'
                  : (it.jenisBuahId == 2 ? 'TBS Kecil' : 'TBS Brondolan'),
            ),
          );
        }).toList(),
      );
    }
  }
}

final transaksiRepositoryProvider = Provider<TransaksiRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return TransaksiRepository(client, db);
});
