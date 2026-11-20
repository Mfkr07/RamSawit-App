/// Model mewakili tabel `public.profiles` di Supabase.
/// Kolom DB: id, nama, role, created_at
class Profile {
  final String id;
  final String nama;
  final String role; // 'admin' atau 'kasir'
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.nama,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isKasir => role == 'kasir';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      nama: json['nama'] as String,
      role: json['role'] as String? ?? 'kasir',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? nama,
    String? role,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
