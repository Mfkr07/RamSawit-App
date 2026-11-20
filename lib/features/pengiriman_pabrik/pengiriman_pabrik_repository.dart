import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/app_database.dart';
import '../../core/supabase_client.dart';
import '../../core/utils/app_exception_helper.dart';
import '../../models/pabrik.dart';
import '../../models/pengiriman_pabrik.dart';
import '../../models/paginated_result.dart';

/// Repository untuk mengelola data pengiriman penjualan ke pabrik (tabel `public.pengiriman_pabrik`).
class PengirimanPabrikRepository {
  final SupabaseClient? _client;
  final AppDatabase? _db;

  // In-memory demo data untuk pengujian lokal / offline
  // In-memory data pengiriman pabrik untuk demo lokal (bersih tanpa dummy)
  static final List<PengirimanPabrik> _demoList = [];

  static void seedDemoDataForTesting() {
    _demoList.clear();
    _demoList.addAll([
      PengirimanPabrik(
        id: 'krm-demo-001',
        kodePengiriman: 'KRM-20260906-0001',
        pabrikId: 'pb-001',
        platNomor: 'BM 8899 XX',
        namaSopir: 'Pak Wardi',
        tanggalKirim: DateTime.now().subtract(const Duration(days: 1)),
        beratDikirimKg: Decimal.parse('8500.00'),
        beratSampaiKg: Decimal.parse('8500.00'),
        beratDitolakKg: Decimal.parse('150.00'),
        beratDiterimaKg: Decimal.parse('8350.00'),
        persentasePotonganPabrik: Decimal.parse('2.50'),
        beratBersihKg: Decimal.parse('8141.25'),
        susutBuahKg: Decimal.zero,
        hargaJualPerKg: Decimal.parse('2450.00'),
        nilaiPotonganRp: Decimal.parse('511387.50'),
        totalNilaiJual: Decimal.parse('19946062.50'),
        status: 'selesai',
        catatan: 'Pengiriman TBS kebun plasma blok B',
        createdBy: 'demo-user-id-12345',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        pabrik: Pabrik(
          id: 'pb-001',
          nama: 'PT Sawit Inti Riau',
          alamat: 'Jl. Raya Lintas Timur KM 45, Pelalawan',
          kontak: '08117654321',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ),
      PengirimanPabrik(
        id: 'krm-demo-002',
        kodePengiriman: 'KRM-20260907-0002',
        pabrikId: 'pb-001',
        platNomor: 'BM 1234 YZ',
        namaSopir: 'Pak Joko',
        tanggalKirim: DateTime.now(),
        beratDikirimKg: Decimal.parse('9200.00'),
        status: 'berangkat',
        catatan: 'Truk dalam perjalanan ke PKS',
        createdBy: 'demo-user-id-12345',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        pabrik: Pabrik(
          id: 'pb-001',
          nama: 'PT Sawit Inti Riau',
          alamat: 'Jl. Raya Lintas Timur KM 45, Pelalawan',
          kontak: '08117654321',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ),
    ]);
  }

  static void clearDemoData() {
    _demoList.clear();
  }

  static List<PengirimanPabrik> get demoList => _demoList;

  PengirimanPabrikRepository([this._client, this._db]);

  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;

  /// Mengambil daftar riwayat pengiriman ke pabrik
  Future<List<PengirimanPabrik>> getPengirimanList({
    String? searchQuery,
    String? pabrikId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isDemoMode) {
      final db = _db;
      if (db != null && _demoList.isEmpty) {
        try {
          final localRows =
              await db.select(db.localPengirimanPabrik).get();
          for (final row in localRows) {
            _demoList.add(PengirimanPabrik(
              id: row.id,
              kodePengiriman: row.noSpb,
              pabrikId: row.pabrikId,
              platNomor: row.noKendaraan,
              namaSopir: row.namaSupir,
              tanggalKirim: row.tanggalKirim,
              beratDikirimKg: Decimal.parse(row.beratKirimKg),
              beratSampaiKg: row.beratTimbangPabrikKg != null
                  ? Decimal.parse(row.beratTimbangPabrikKg!)
                  : Decimal.parse(row.beratKirimKg),
              beratDitolakKg: Decimal.zero,
              hargaJualPerKg: row.hargaPerKg != null
                  ? Decimal.parse(row.hargaPerKg!)
                  : Decimal.zero,
              totalNilaiJual: row.totalNilaiPenjualan != null
                  ? Decimal.parse(row.totalNilaiPenjualan!)
                  : Decimal.zero,
              status: row.status,
              createdAt: row.createdAt,
            ));
          }
        } catch (_) {}
      }
      await Future.delayed(const Duration(milliseconds: 300));
      var list = List<PengirimanPabrik>.from(_demoList);

      if (pabrikId != null && pabrikId.isNotEmpty) {
        list = list.where((k) => k.pabrikId == pabrikId).toList();
      }

      if (status != null && status.isNotEmpty) {
        list = list.where((k) => k.status == status).toList();
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        list = list.where((k) {
          final matchKode = k.kodePengiriman.toLowerCase().contains(query);
          final matchPlat = k.platNomor.toLowerCase().contains(query);
          final matchSopir = k.namaSopir.toLowerCase().contains(query);
          final matchPabrik =
              k.pabrik?.nama.toLowerCase().contains(query) ?? false;
          return matchKode || matchPlat || matchSopir || matchPabrik;
        }).toList();
      }

      list.sort((a, b) => b.tanggalKirim.compareTo(a.tanggalKirim));
      return list;
    }

    try {
      // Baca dari v_pengiriman_ringkasan atau tabel pengiriman_pabrik dengan join pabrik
      var queryBuilder = _client!
          .from('pengiriman_pabrik')
          .select('*, pabrik:pabrik_id(*)');

      if (pabrikId != null && pabrikId.isNotEmpty) {
        queryBuilder = queryBuilder.eq('pabrik_id', pabrikId);
      }

      if (status != null && status.isNotEmpty) {
        queryBuilder = queryBuilder.eq('status', status);
      }

      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T').first;
        queryBuilder = queryBuilder.gte('tanggal_kirim', startStr);
      }

      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T').first;
        queryBuilder = queryBuilder.lte('tanggal_kirim', endStr);
      }

      final response =
          await queryBuilder.order('tanggal_kirim', ascending: false);
      return (response as List<dynamic>)
          .map((item) =>
              PengirimanPabrik.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(
        'Gagal memuat daftar pengiriman: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Mengambil daftar riwayat pengiriman ke pabrik dengan paginasi server-side
  Future<PaginatedResult<PengirimanPabrik>> getPengirimanPaginated({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? pabrikId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      final all = await getPengirimanList(
        searchQuery: searchQuery,
        pabrikId: pabrikId,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      final totalCount = all.length;
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
      return PaginatedResult(
        items: all.sublist(fromIndex, toIndex),
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    }

    try {
      var queryBuilder = _client!
          .from('pengiriman_pabrik')
          .select('*, pabrik:pabrik_id(*)');

      if (pabrikId != null && pabrikId.isNotEmpty) {
        queryBuilder = queryBuilder.eq('pabrik_id', pabrikId);
      }
      if (status != null && status.isNotEmpty) {
        queryBuilder = queryBuilder.eq('status', status);
      }
      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T').first;
        queryBuilder = queryBuilder.gte('tanggal_kirim', startStr);
      }
      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T').first;
        queryBuilder = queryBuilder.lte('tanggal_kirim', endStr);
      }

      // Hitung total data
      var countQuery = _client.from('pengiriman_pabrik').select('id');
      if (pabrikId != null && pabrikId.isNotEmpty) {
        countQuery = countQuery.eq('pabrik_id', pabrikId);
      }
      if (status != null && status.isNotEmpty) {
        countQuery = countQuery.eq('status', status);
      }
      if (startDate != null) {
        final startStr = startDate.toIso8601String().split('T').first;
        countQuery = countQuery.gte('tanggal_kirim', startStr);
      }
      if (endDate != null) {
        final endStr = endDate.toIso8601String().split('T').first;
        countQuery = countQuery.lte('tanggal_kirim', endStr);
      }

      final countResponse = await countQuery;
      final totalCount = (countResponse as List).length;

      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final response = await queryBuilder
          .order('tanggal_kirim', ascending: false)
          .range(from, to);

      final list = (response as List<dynamic>)
          .map((item) =>
              PengirimanPabrik.fromJson(item as Map<String, dynamic>))
          .toList();

      return PaginatedResult(
        items: list,
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw Exception(
        'Gagal memuat daftar pengiriman: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Simpan Pengiriman Baru ke Pabrik (Fase 1: Keberangkatan Truk)
  /// Mencatat armada awal dan berat dikirim dengan status awal 'berangkat'.
  Future<PengirimanPabrik> createPengiriman({
    required String pabrikId,
    required String platNomor,
    required String namaSopir,
    required DateTime tanggalKirim,
    Decimal? beratDikirimKg,
    Decimal? beratKotorKg,
    String? catatan,
    String? createdBy,
    Pabrik? pabrikModel,
  }) async {
    final beratKirim = beratDikirimKg ?? beratKotorKg ?? Decimal.zero;
    // Validasi aturan bisnis Fase 1
    if (beratKirim <= Decimal.zero) {
      throw Exception('Berat Dikirim harus lebih besar dari 0 kg.');
    }
    if (platNomor.trim().isEmpty) {
      throw Exception('Plat nomor truk wajib diisi.');
    }
    if (namaSopir.trim().isEmpty) {
      throw Exception('Nama sopir truk wajib diisi.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));

      final tanggalStr =
          '${tanggalKirim.year}${tanggalKirim.month.toString().padLeft(2, '0')}${tanggalKirim.day.toString().padLeft(2, '0')}';
      final seq = (_demoList.length + 1).toString().padLeft(4, '0');
      final kodeOtomatis = 'KRM-$tanggalStr-$seq';

      final newPengiriman = PengirimanPabrik(
        id: 'krm-demo-${DateTime.now().millisecondsSinceEpoch}',
        kodePengiriman: kodeOtomatis,
        pabrikId: pabrikId,
        platNomor: platNomor.trim().toUpperCase(),
        namaSopir: namaSopir.trim(),
        tanggalKirim: tanggalKirim,
        beratDikirimKg: beratKirim,
        status: 'berangkat',
        catatan: catatan?.trim().isEmpty == true ? null : catatan?.trim(),
        createdBy: createdBy ?? 'demo-user-id-12345',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        pabrik: pabrikModel,
      );

      _demoList.insert(0, newPengiriman);

      final db = _db;
      if (db != null) {
        try {
          await db.into(db.localPengirimanPabrik).insert(
                LocalPengirimanPabrikCompanion.insert(
                  id: newPengiriman.id,
                  noSpb: kodeOtomatis,
                  pabrikId: pabrikId,
                  tanggalKirim: tanggalKirim,
                  noKendaraan: platNomor.trim().toUpperCase(),
                  namaSupir: namaSopir.trim(),
                  status: const Value('berangkat'),
                  beratKirimKg: beratKirim.toString(),
                  isSynced: const Value(false),
                ),
              );
        } catch (_) {}
      }

      return newPengiriman;
    }

    try {
      final insertData = {
        'pabrik_id': pabrikId,
        'plat_nomor': platNomor.trim().toUpperCase(),
        'nama_sopir': namaSopir.trim(),
        'tanggal_kirim': tanggalKirim.toIso8601String().split('T').first,
        'berat_dikirim_kg': beratKirim.toDouble(),
        'status': 'berangkat',
        'catatan': catatan?.trim().isEmpty == true ? null : catatan?.trim(),
        'created_by': createdBy,
      };

      final response = await _client!
          .from('pengiriman_pabrik')
          .insert(insertData)
          .select('*, pabrik:pabrik_id(*)')
          .single();

      return PengirimanPabrik.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal mencatat keberangkatan truk ke pabrik: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Selesaikan Pengiriman ke Pabrik (Fase 2: Penyelesaian Nota Hasil Pabrik)
  /// Mengisi berat sampai, berat ditolak, potongan pabrik, harga jual/kg, serta potongan lainnya & sortasi opsional.
  Future<PengirimanPabrik> selesaikanPengirimanFase2({
    required String id,
    required Decimal beratSampaiKg,
    Decimal? beratDitolakKg,
    Decimal? persentasePotonganPabrik,
    required Decimal hargaJualPerKg,
    Decimal? potonganLainnyaRp,
    Decimal? potonganSortasiPerKg,
    String? catatan,
  }) async {
    final ditolak = beratDitolakKg ?? Decimal.zero;
    final potongan = persentasePotonganPabrik ?? Decimal.zero;

    if (beratSampaiKg <= Decimal.zero) {
      throw Exception('Berat Sampai wajib diisi dan lebih besar dari 0 kg.');
    }
    if (ditolak < Decimal.zero) {
      throw Exception('Berat Ditolak tidak boleh bernilai negatif.');
    }
    if (ditolak > beratSampaiKg) {
      throw Exception('Berat Ditolak tidak boleh lebih besar dari Berat Sampai ($beratSampaiKg kg).');
    }
    if (potongan < Decimal.zero || potongan > Decimal.fromInt(100)) {
      throw Exception('Potongan Pabrik harus berada di rentang 0% hingga 100%.');
    }
    if (hargaJualPerKg <= Decimal.zero) {
      throw Exception('Harga Jual per kg wajib diisi dan lebih besar dari Rp 0.');
    }
    if (potonganLainnyaRp != null && potonganLainnyaRp < Decimal.zero) {
      throw Exception('Potongan Lainnya tidak boleh bernilai negatif.');
    }
    if (potonganSortasiPerKg != null && potonganSortasiPerKg < Decimal.zero) {
      throw Exception('Potongan Sortasi per kg tidak boleh bernilai negatif.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 350));
      final idx = _demoList.indexWhere((k) => k.id == id);
      if (idx == -1) {
        throw Exception('Pengiriman dengan ID "$id" tidak ditemukan.');
      }

      final existing = _demoList[idx];

      final susutBuah = existing.beratDikirimKg - beratSampaiKg;
      final beratDiterima = beratSampaiKg - ditolak;
      final beratBersih = (beratDiterima *
              (Decimal.fromInt(100) - potongan) /
              Decimal.fromInt(100))
          .toDecimal(scaleOnInfinitePrecision: 2);
      final nilaiPotongan = (hargaJualPerKg *
              beratDiterima *
              potongan /
              Decimal.fromInt(100))
          .toDecimal(scaleOnInfinitePrecision: 2);

      final nilaiSortasi = (potonganSortasiPerKg ?? Decimal.zero) * beratSampaiKg;

      // Total Nilai Jual formula baru (PRD 7.8 poin 9):
      // (Harga Jual/kg x Berat Bersih) - Potongan Lainnya - Nilai Potongan Sortasi
      final totalNilai = (hargaJualPerKg * beratBersih) -
          (potonganLainnyaRp ?? Decimal.zero) -
          nilaiSortasi;

      final updatedCatatan = catatan != null && catatan.trim().isNotEmpty
          ? (existing.catatan != null && existing.catatan!.isNotEmpty
              ? '${existing.catatan}\n${catatan.trim()}'
              : catatan.trim())
          : existing.catatan;

      final completed = existing.copyWith(
        beratSampaiKg: beratSampaiKg,
        beratDitolakKg: ditolak,
        beratDiterimaKg: beratDiterima,
        persentasePotonganPabrik: potongan,
        beratBersihKg: beratBersih,
        susutBuahKg: susutBuah,
        hargaJualPerKg: hargaJualPerKg,
        nilaiPotonganRp: nilaiPotongan,
        potonganLainnyaRp: potonganLainnyaRp,
        potonganSortasiPerKg: potonganSortasiPerKg,
        nilaiPotonganSortasiRp: nilaiSortasi,
        totalNilaiJual: totalNilai,
        status: 'selesai',
        catatan: updatedCatatan,
        updatedAt: DateTime.now(),
      );

      _demoList[idx] = completed;
      return completed;
    }

    try {
      final updateData = {
        'berat_sampai_kg': beratSampaiKg.toDouble(),
        'berat_ditolak_kg': ditolak.toDouble(),
        'persentase_potongan_pabrik': potongan.toDouble(),
        'harga_jual_per_kg': hargaJualPerKg.toDouble(),
        'potongan_lainnya_rp': potonganLainnyaRp?.toDouble(),
        'potongan_sortasi_per_kg': potonganSortasiPerKg?.toDouble(),
        'status': 'selesai',
        if (catatan != null && catatan.trim().isNotEmpty) 'catatan': catatan.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client!
          .from('pengiriman_pabrik')
          .update(updateData)
          .eq('id', id)
          .select('*, pabrik:pabrik_id(*)')
          .single();

      return PengirimanPabrik.fromJson(response);
    } catch (e) {
      throw Exception(
        'Gagal menyelesaikan pengiriman ke pabrik: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }

  /// Membatalkan pengiriman (status -> dibatalkan), dapat dilakukan dari status 'berangkat' maupun 'selesai'.
  Future<void> cancelPengiriman(String id, String? alasan) async {
    final cleanAlasan = alasan?.trim();
    if (cleanAlasan == null || cleanAlasan.isEmpty) {
      throw Exception('Alasan pembatalan pengiriman wajib diisi.');
    }

    if (isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 250));
      final idx = _demoList.indexWhere((k) => k.id == id);
      if (idx != -1) {
        final cur = _demoList[idx];
        final newCatatan = cur.catatan != null && cur.catatan!.isNotEmpty
            ? '${cur.catatan}\n[Dibatalkan: $cleanAlasan]'
            : '[Dibatalkan: $cleanAlasan]';

        _demoList[idx] = cur.copyWith(
          status: 'dibatalkan',
          catatan: newCatatan,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }

    try {
      final cur = await _client!
          .from('pengiriman_pabrik')
          .select('catatan')
          .eq('id', id)
          .single();

      final existingCatatan = cur['catatan'] as String?;
      final newCatatan = existingCatatan != null && existingCatatan.isNotEmpty
          ? '$existingCatatan\n[Dibatalkan: $cleanAlasan]'
          : '[Dibatalkan: $cleanAlasan]';

      await _client.from('pengiriman_pabrik').update({
        'status': 'dibatalkan',
        'catatan': newCatatan,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception(
        'Gagal membatalkan pengiriman: ${AppExceptionHelper.toUserFriendlyMessage(e)}',
      );
    }
  }
}

final pengirimanPabrikRepositoryProvider =
    Provider<PengirimanPabrikRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return PengirimanPabrikRepository(client, db);
});
