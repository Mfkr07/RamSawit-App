import 'package:decimal/decimal.dart';
import 'pabrik.dart';

/// Model mewakili tabel `public.pengiriman_pabrik` di Supabase.
/// Menyimpan data pengiriman TBS ke pabrik dan hasil kalkulasi berat & nilai penjualan (FR-8.x).
class PengirimanPabrik {
  final String id;
  final String kodePengiriman;
  final String pabrikId;
  final String platNomor;
  final String namaSopir;
  final DateTime tanggalKirim;
  final Decimal beratDikirimKg;
  final Decimal? beratSampaiKg;
  final Decimal? beratDitolakKg;
  final Decimal? beratDiterimaKg;
  final Decimal? persentasePotonganPabrik;
  final Decimal? beratBersihKg;
  final Decimal? susutBuahKg;
  final Decimal? hargaJualPerKg;
  final Decimal? nilaiPotonganRp;
  final Decimal? potonganLainnyaRp;
  final Decimal? potonganSortasiPerKg;
  final Decimal? nilaiPotonganSortasiRp;
  final Decimal? totalNilaiJual;
  final String status; // 'berangkat', 'selesai', 'dibatalkan', 'draft'
  final String? catatan;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi opsional
  final Pabrik? pabrik;

  PengirimanPabrik({
    required this.id,
    required this.kodePengiriman,
    required this.pabrikId,
    required this.platNomor,
    required this.namaSopir,
    required this.tanggalKirim,
    Decimal? beratDikirimKg,
    Decimal? beratKotorKg,
    this.beratSampaiKg,
    this.beratDitolakKg,
    this.beratDiterimaKg,
    this.persentasePotonganPabrik,
    this.beratBersihKg,
    this.susutBuahKg,
    this.hargaJualPerKg,
    this.nilaiPotonganRp,
    this.potonganLainnyaRp,
    this.potonganSortasiPerKg,
    this.nilaiPotonganSortasiRp,
    this.totalNilaiJual,
    this.status = 'berangkat',
    this.catatan,
    this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.pabrik,
  })  : beratDikirimKg = beratDikirimKg ?? beratKotorKg ?? Decimal.zero,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Getter alias untuk kompatibilitas ke belakang (sebelum rename ke beratDikirimKg)
  Decimal get beratKotorKg => beratDikirimKg;

  bool get isBerangkat => status == 'berangkat';
  bool get isSelesai => status == 'selesai';
  bool get isDibatalkan => status == 'dibatalkan';
  bool get isDraft => status == 'draft';

  /// Helper untuk parsing Decimal nullable dari dynamic (num, string, null)
  static Decimal? _parseDecimalNullable(dynamic value) {
    if (value == null) return null;
    if (value is Decimal) return value;
    return Decimal.tryParse(value.toString());
  }

  /// Helper untuk parsing Decimal non-nullable dengan fallback Decimal.zero
  static Decimal _parseDecimal(dynamic value, [Decimal? fallback]) {
    if (value == null) return fallback ?? Decimal.zero;
    if (value is Decimal) return value;
    return Decimal.tryParse(value.toString()) ?? (fallback ?? Decimal.zero);
  }

  factory PengirimanPabrik.fromJson(Map<String, dynamic> json) {
    final dikirim = _parseDecimal(
      json['berat_dikirim_kg'] ?? json['berat_kotor_kg'],
    );
    final sampai = _parseDecimalNullable(json['berat_sampai_kg']);
    final ditolak = _parseDecimalNullable(json['berat_ditolak_kg']);
    
    // Hitung fallback susut buah jika belum tersedia dari DB
    final susut = _parseDecimalNullable(json['susut_buah_kg']) ??
        (sampai != null ? dikirim - sampai : null);

    // Hitung fallback berat diterima jika belum diisi DB
    final diterima = _parseDecimalNullable(json['berat_diterima_kg']) ??
        (sampai != null && ditolak != null ? sampai - ditolak : null);

    return PengirimanPabrik(
      id: json['id'] as String,
      kodePengiriman: json['kode_pengiriman'] as String,
      pabrikId: json['pabrik_id'] as String,
      platNomor: json['plat_nomor'] as String,
      namaSopir: json['nama_sopir'] as String,
      tanggalKirim: DateTime.parse(json['tanggal_kirim'] as String),
      beratDikirimKg: dikirim,
      beratSampaiKg: sampai,
      beratDitolakKg: ditolak,
      beratDiterimaKg: diterima,
      persentasePotonganPabrik:
          _parseDecimalNullable(json['persentase_potongan_pabrik']),
      beratBersihKg: _parseDecimalNullable(json['berat_bersih_kg']),
      susutBuahKg: susut,
      hargaJualPerKg: _parseDecimalNullable(json['harga_jual_per_kg']),
      nilaiPotonganRp: _parseDecimalNullable(json['nilai_potongan_rp']),
      potonganLainnyaRp: _parseDecimalNullable(json['potongan_lainnya_rp']),
      potonganSortasiPerKg: _parseDecimalNullable(json['potongan_sortasi_per_kg']),
      nilaiPotonganSortasiRp: _parseDecimalNullable(json['nilai_potongan_sortasi_rp']),
      totalNilaiJual: _parseDecimalNullable(json['total_nilai_jual']),
      status: json['status'] as String? ?? 'berangkat',
      catatan: json['catatan'] as String?,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      pabrik: json['pabrik'] != null
          ? Pabrik.fromJson(json['pabrik'] as Map<String, dynamic>)
          : (json['nama_pabrik'] != null
              ? Pabrik(
                  id: json['pabrik_id'] as String,
                  nama: json['nama_pabrik'] as String,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                )
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_pengiriman': kodePengiriman,
      'pabrik_id': pabrikId,
      'plat_nomor': platNomor,
      'nama_sopir': namaSopir,
      'tanggal_kirim': tanggalKirim.toIso8601String().split('T').first,
      'berat_dikirim_kg': beratDikirimKg.toString(),
      'berat_kotor_kg': beratDikirimKg.toString(),
      'berat_sampai_kg': beratSampaiKg?.toString(),
      'berat_ditolak_kg': beratDitolakKg?.toString(),
      'berat_diterima_kg': beratDiterimaKg?.toString(),
      'persentase_potongan_pabrik': persentasePotonganPabrik?.toString(),
      'berat_bersih_kg': beratBersihKg?.toString(),
      'susut_buah_kg': susutBuahKg?.toString(),
      'harga_jual_per_kg': hargaJualPerKg?.toString(),
      'nilai_potongan_rp': nilaiPotonganRp?.toString(),
      'potongan_lainnya_rp': potonganLainnyaRp?.toString(),
      'potongan_sortasi_per_kg': potonganSortasiPerKg?.toString(),
      'nilai_potongan_sortasi_rp': nilaiPotonganSortasiRp?.toString(),
      'total_nilai_jual': totalNilaiJual?.toString(),
      'status': status,
      'catatan': catatan,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map input untuk insert ke tabel `public.pengiriman_pabrik` (Fase 1).
  Map<String, dynamic> toInsertMap() {
    return {
      'pabrik_id': pabrikId,
      'plat_nomor': platNomor,
      'nama_sopir': namaSopir,
      'tanggal_kirim': tanggalKirim.toIso8601String().split('T').first,
      'berat_dikirim_kg': beratDikirimKg.toDouble(),
      'status': status,
      if (catatan != null) 'catatan': catatan,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  /// Map payload untuk update status selesai (Fase 2).
  Map<String, dynamic> toSelesaikanMap() {
    return {
      'berat_sampai_kg': beratSampaiKg?.toDouble(),
      'berat_ditolak_kg': beratDitolakKg?.toDouble() ?? 0.0,
      'persentase_potongan_pabrik': persentasePotonganPabrik?.toDouble() ?? 0.0,
      'harga_jual_per_kg': hargaJualPerKg?.toDouble(),
      if (potonganLainnyaRp != null) 'potongan_lainnya_rp': potonganLainnyaRp!.toDouble(),
      if (potonganSortasiPerKg != null) 'potongan_sortasi_per_kg': potonganSortasiPerKg!.toDouble(),
      'status': 'selesai',
      if (catatan != null) 'catatan': catatan,
    };
  }

  PengirimanPabrik copyWith({
    String? id,
    String? kodePengiriman,
    String? pabrikId,
    String? platNomor,
    String? namaSopir,
    DateTime? tanggalKirim,
    Decimal? beratDikirimKg,
    Decimal? beratKotorKg,
    Decimal? beratSampaiKg,
    bool clearBeratSampaiKg = false,
    Decimal? beratDitolakKg,
    bool clearBeratDitolakKg = false,
    Decimal? beratDiterimaKg,
    bool clearBeratDiterimaKg = false,
    Decimal? persentasePotonganPabrik,
    bool clearPersentasePotonganPabrik = false,
    Decimal? beratBersihKg,
    bool clearBeratBersihKg = false,
    Decimal? susutBuahKg,
    bool clearSusutBuahKg = false,
    Decimal? hargaJualPerKg,
    bool clearHargaJualPerKg = false,
    Decimal? nilaiPotonganRp,
    bool clearNilaiPotonganRp = false,
    Decimal? potonganLainnyaRp,
    bool clearPotonganLainnyaRp = false,
    Decimal? potonganSortasiPerKg,
    bool clearPotonganSortasiPerKg = false,
    Decimal? nilaiPotonganSortasiRp,
    bool clearNilaiPotonganSortasiRp = false,
    Decimal? totalNilaiJual,
    bool clearTotalNilaiJual = false,
    String? status,
    String? catatan,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Pabrik? pabrik,
  }) {
    return PengirimanPabrik(
      id: id ?? this.id,
      kodePengiriman: kodePengiriman ?? this.kodePengiriman,
      pabrikId: pabrikId ?? this.pabrikId,
      platNomor: platNomor ?? this.platNomor,
      namaSopir: namaSopir ?? this.namaSopir,
      tanggalKirim: tanggalKirim ?? this.tanggalKirim,
      beratDikirimKg: beratDikirimKg ?? beratKotorKg ?? this.beratDikirimKg,
      beratSampaiKg:
          clearBeratSampaiKg ? null : (beratSampaiKg ?? this.beratSampaiKg),
      beratDitolakKg:
          clearBeratDitolakKg ? null : (beratDitolakKg ?? this.beratDitolakKg),
      beratDiterimaKg: clearBeratDiterimaKg
          ? null
          : (beratDiterimaKg ?? this.beratDiterimaKg),
      persentasePotonganPabrik: clearPersentasePotonganPabrik
          ? null
          : (persentasePotonganPabrik ?? this.persentasePotonganPabrik),
      beratBersihKg:
          clearBeratBersihKg ? null : (beratBersihKg ?? this.beratBersihKg),
      susutBuahKg:
          clearSusutBuahKg ? null : (susutBuahKg ?? this.susutBuahKg),
      hargaJualPerKg:
          clearHargaJualPerKg ? null : (hargaJualPerKg ?? this.hargaJualPerKg),
      nilaiPotonganRp: clearNilaiPotonganRp
          ? null
          : (nilaiPotonganRp ?? this.nilaiPotonganRp),
      potonganLainnyaRp: clearPotonganLainnyaRp
          ? null
          : (potonganLainnyaRp ?? this.potonganLainnyaRp),
      potonganSortasiPerKg: clearPotonganSortasiPerKg
          ? null
          : (potonganSortasiPerKg ?? this.potonganSortasiPerKg),
      nilaiPotonganSortasiRp: clearNilaiPotonganSortasiRp
          ? null
          : (nilaiPotonganSortasiRp ?? this.nilaiPotonganSortasiRp),
      totalNilaiJual:
          clearTotalNilaiJual ? null : (totalNilaiJual ?? this.totalNilaiJual),
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pabrik: pabrik ?? this.pabrik,
    );
  }
}
