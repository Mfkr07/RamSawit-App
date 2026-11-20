import 'package:decimal/decimal.dart';

/// Model data catatan pengeluaran operasional (tabel `public.pengeluaran`).
class Pengeluaran {
  final String id;
  final DateTime tanggalPengeluaran;
  final int jenisPengeluaranId;
  final String? jenisPengeluaranNama;
  final String? keterangan;
  final Decimal nominal;
  final String metodePembayaran; // 'tunai' | 'non_tunai'
  final String? createdBy;
  final String? createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Pengeluaran({
    required this.id,
    required this.tanggalPengeluaran,
    required this.jenisPengeluaranId,
    this.jenisPengeluaranNama,
    this.keterangan,
    required this.nominal,
    this.metodePembayaran = 'tunai',
    this.createdBy,
    this.createdByName,
    this.createdAt,
    this.updatedAt,
  });

  bool get isTunai => metodePembayaran == 'tunai';
  bool get isNonTunai => metodePembayaran == 'non_tunai';

  factory Pengeluaran.fromJson(Map<String, dynamic> json) {
    // Tangani join jenis_pengeluaran jika ada: jenis_pengeluaran: { nama: '...' }
    String? namaJenis;
    if (json['jenis_pengeluaran'] is Map) {
      namaJenis = (json['jenis_pengeluaran'] as Map)['nama'] as String?;
    } else if (json['jenis_pengeluaran_nama'] != null) {
      namaJenis = json['jenis_pengeluaran_nama'] as String?;
    }

    // Tangani join profiles jika ada: profiles: { nama: '...' }
    String? namaUser;
    if (json['profiles'] is Map) {
      namaUser = (json['profiles'] as Map)['nama'] as String?;
    } else if (json['created_by_name'] != null) {
      namaUser = json['created_by_name'] as String?;
    }

    final rawNominal = json['nominal'];
    final nominalDecimal = rawNominal != null
        ? Decimal.parse(rawNominal.toString())
        : Decimal.zero;

    final metode = (json['metode_pembayaran'] as String?) ??
        (json['jenis_pembayaran'] as String?) ??
        'tunai';

    return Pengeluaran(
      id: json['id'] as String,
      tanggalPengeluaran: json['tanggal_pengeluaran'] != null
          ? DateTime.parse(json['tanggal_pengeluaran'] as String)
          : DateTime.now(),
      jenisPengeluaranId: (json['jenis_pengeluaran_id'] as num).toInt(),
      jenisPengeluaranNama: namaJenis,
      keterangan: json['keterangan'] as String?,
      nominal: nominalDecimal,
      metodePembayaran: metode,
      createdBy: json['created_by'] as String?,
      createdByName: namaUser,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal_pengeluaran':
          tanggalPengeluaran.toIso8601String().split('T').first,
      'jenis_pengeluaran_id': jenisPengeluaranId,
      if (keterangan != null && keterangan!.trim().isNotEmpty)
        'keterangan': keterangan!.trim(),
      'nominal': nominal.toString(),
      'metode_pembayaran': metodePembayaran,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  Pengeluaran copyWith({
    String? id,
    DateTime? tanggalPengeluaran,
    int? jenisPengeluaranId,
    String? jenisPengeluaranNama,
    String? keterangan,
    Decimal? nominal,
    String? metodePembayaran,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pengeluaran(
      id: id ?? this.id,
      tanggalPengeluaran: tanggalPengeluaran ?? this.tanggalPengeluaran,
      jenisPengeluaranId: jenisPengeluaranId ?? this.jenisPengeluaranId,
      jenisPengeluaranNama: jenisPengeluaranNama ?? this.jenisPengeluaranNama,
      keterangan: keterangan ?? this.keterangan,
      nominal: nominal ?? this.nominal,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Memeriksa apakah user tertentu berhak mengedit atau menghapus catatan ini.
  /// Admin memiliki hak penuh; Kasir hanya boleh mengubah pengeluaran miliknya sendiri.
  bool canUserEditOrDelete({required String? userId, required bool isAdmin}) {
    if (isAdmin) return true;
    if (createdBy == null || userId == null) return false;
    return createdBy == userId;
  }
}
