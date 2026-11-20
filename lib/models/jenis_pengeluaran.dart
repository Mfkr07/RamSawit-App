/// Model data master jenis pengeluaran (tabel `public.jenis_pengeluaran`).
class JenisPengeluaran {
  final int id;
  final String nama;
  final bool isActive;

  const JenisPengeluaran({
    required this.id,
    required this.nama,
    this.isActive = true,
  });

  factory JenisPengeluaran.fromJson(Map<String, dynamic> json) {
    return JenisPengeluaran(
      id: json['id'] as int,
      nama: (json['nama'] as String?)?.trim() ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'is_active': isActive,
    };
  }

  JenisPengeluaran copyWith({
    int? id,
    String? nama,
    bool? isActive,
  }) {
    return JenisPengeluaran(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JenisPengeluaran &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
