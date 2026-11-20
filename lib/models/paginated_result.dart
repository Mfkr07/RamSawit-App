/// Model generik untuk hasil query dengan paginasi
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  /// Jumlah total halaman berdasarkan pageSize
  int get totalPages {
    if (pageSize <= 0) return 1;
    final pages = (totalCount / pageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  /// Indeks item awal pada halaman aktif (1-indexed untuk tampilan UI)
  int get itemStart {
    if (totalCount == 0) return 0;
    return (page - 1) * pageSize + 1;
  }

  /// Indeks item akhir pada halaman aktif (1-indexed untuk tampilan UI)
  int get itemEnd {
    final end = page * pageSize;
    return end > totalCount ? totalCount : end;
  }

  /// Apakah ada halaman sebelumnya
  bool get hasPrevious => page > 1;

  /// Apakah ada halaman selanjutnya
  bool get hasNext => page < totalPages;
}
