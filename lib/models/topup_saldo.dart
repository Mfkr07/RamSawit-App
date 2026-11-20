import 'package:decimal/decimal.dart';

/// Model data catatan Top Up Saldo Modal dari tabel `public.topup_saldo` (PRD §7.10, Database.md §11)
class TopupSaldo {
  final String id;
  final DateTime tanggal;
  final Decimal nominal;
  final String? keterangan;
  final String? createdBy;
  final String? createdByName;
  final DateTime createdAt;

  const TopupSaldo({
    required this.id,
    required this.tanggal,
    required this.nominal,
    this.keterangan,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
  });

  factory TopupSaldo.fromJson(Map<String, dynamic> json) {
    // Penanganan user profile join jika ada
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

    return TopupSaldo(
      id: json['id'] as String,
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'] as String)
          : DateTime.now(),
      nominal: nominalDecimal,
      keterangan: json['keterangan'] as String?,
      createdBy: json['created_by'] as String?,
      createdByName: namaUser,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String().split('T').first,
      'nominal': nominal.toString(),
      'keterangan': keterangan,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TopupSaldo copyWith({
    String? id,
    DateTime? tanggal,
    Decimal? nominal,
    String? keterangan,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
  }) {
    return TopupSaldo(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      nominal: nominal ?? this.nominal,
      keterangan: keterangan ?? this.keterangan,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
