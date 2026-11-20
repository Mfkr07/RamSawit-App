/// Model mewakili tabel `public.jenis_buah` di Supabase.
/// Kolom DB: id, kode, nama, is_active
class JenisBuah {
  final int id;
  final String kode;
  final String nama;
  final bool isActive;

  const JenisBuah({
    required this.id,
    required this.kode,
    required this.nama,
    this.isActive = true,
  });

  factory JenisBuah.fromJson(Map<String, dynamic> json) {
    return JenisBuah(
      id: json['id'] as int,
      kode: json['kode'] as String,
      nama: json['nama'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'nama': nama,
      'is_active': isActive,
    };
  }

  JenisBuah copyWith({
    int? id,
    String? kode,
    String? nama,
    bool? isActive,
  }) {
    return JenisBuah(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      isActive: isActive ?? this.isActive,
    );
  }
}
