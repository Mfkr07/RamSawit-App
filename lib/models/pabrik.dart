/// Model mewakili tabel `public.pabrik` di Supabase.
/// Kolom DB: id, nama, alamat, kontak, is_active, created_by, created_at, updated_at
class Pabrik {
  final String id;
  final String nama;
  final String? alamat;
  final String? kontak;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Pabrik({
    required this.id,
    required this.nama,
    this.alamat,
    this.kontak,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pabrik.fromJson(Map<String, dynamic> json) {
    return Pabrik(
      id: json['id'] as String,
      nama: json['nama'] as String,
      alamat: json['alamat'] as String?,
      kontak: json['kontak'] as String?,
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
      'alamat': alamat,
      'kontak': kontak,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map untuk insert data baru ke DB (id dan timestamp digenerate oleh database)
  Map<String, dynamic> toInsertMap() {
    return {
      'nama': nama,
      'alamat': alamat,
      'kontak': kontak,
      'is_active': isActive,
      'created_by': createdBy,
    };
  }

  Pabrik copyWith({
    String? id,
    String? nama,
    String? alamat,
    String? kontak,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pabrik(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      kontak: kontak ?? this.kontak,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pabrik && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
