/// Model mewakili tabel `public.penjual` di Supabase.
/// Kolom DB: id, nama, no_telepon, alamat, catatan, is_active, created_by, created_at, updated_at
class Penjual {
  final String id;
  final String nama;
  final String? noTelepon;
  final String? alamat;
  final String? catatan;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Penjual({
    required this.id,
    required this.nama,
    this.noTelepon,
    this.alamat,
    this.catatan,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Penjual.fromJson(Map<String, dynamic> json) {
    return Penjual(
      id: json['id'] as String,
      nama: json['nama'] as String,
      noTelepon: json['no_telepon'] as String?,
      alamat: json['alamat'] as String?,
      catatan: json['catatan'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'catatan': catatan,
      'is_active': isActive,
      'created_by': ?createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map untuk insert data baru (id dan timestamp digenerate oleh DB)
  Map<String, dynamic> toInsertMap() {
    return {
      'nama': nama,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'catatan': catatan,
      'is_active': isActive,
      'created_by': ?createdBy,
    };
  }

  Penjual copyWith({
    String? id,
    String? nama,
    String? noTelepon,
    String? alamat,
    String? catatan,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Penjual(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      noTelepon: noTelepon ?? this.noTelepon,
      alamat: alamat ?? this.alamat,
      catatan: catatan ?? this.catatan,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
