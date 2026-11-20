import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/penjual.dart';
import '../auth/auth_controller.dart';
import 'penjual_repository.dart';

/// State untuk pencarian dan filter data penjual
class PenjualFilterState {
  final String searchQuery;
  final bool includeInactive;

  const PenjualFilterState({
    this.searchQuery = '',
    this.includeInactive = false,
  });

  PenjualFilterState copyWith({
    String? searchQuery,
    bool? includeInactive,
  }) {
    return PenjualFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      includeInactive: includeInactive ?? this.includeInactive,
    );
  }
}

final penjualFilterProvider =
    StateNotifierProvider<PenjualFilterNotifier, PenjualFilterState>((ref) {
  return PenjualFilterNotifier();
});

class PenjualFilterNotifier extends StateNotifier<PenjualFilterState> {
  PenjualFilterNotifier() : super(const PenjualFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleIncludeInactive() {
    state = state.copyWith(includeInactive: !state.includeInactive);
  }

  void reset() {
    state = const PenjualFilterState();
  }
}

/// Provider daftar penjual reaktif terhadap filter dan mutasi data
final penjualListProvider =
    AsyncNotifierProvider<PenjualListNotifier, List<Penjual>>(() {
  return PenjualListNotifier();
});

class PenjualListNotifier extends AsyncNotifier<List<Penjual>> {
  @override
  Future<List<Penjual>> build() async {
    final filter = ref.watch(penjualFilterProvider);
    final repo = ref.watch(penjualRepositoryProvider);
    return repo.getPenjualList(
      searchQuery: filter.searchQuery,
      includeInactive: filter.includeInactive,
    );
  }

  /// Refresh manual
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(penjualFilterProvider);
      final repo = ref.read(penjualRepositoryProvider);
      return repo.getPenjualList(
        searchQuery: filter.searchQuery,
        includeInactive: filter.includeInactive,
      );
    });
  }

  /// Tambah penjual baru
  Future<Penjual> createPenjual({
    required String nama,
    String? noTelepon,
    String? alamat,
    String? catatan,
  }) async {
    final repo = ref.read(penjualRepositoryProvider);
    final currentUser = ref.read(authControllerProvider).profile;

    final created = await repo.createPenjual(
      nama: nama,
      noTelepon: noTelepon,
      alamat: alamat,
      catatan: catatan,
      createdBy: currentUser?.id,
    );

    // Refresh daftar setelah mutasi
    ref.invalidateSelf();
    return created;
  }

  /// Ubah penjual
  Future<Penjual> updatePenjual({
    required String id,
    required String nama,
    String? noTelepon,
    String? alamat,
    String? catatan,
  }) async {
    final repo = ref.read(penjualRepositoryProvider);
    final updated = await repo.updatePenjual(
      id: id,
      nama: nama,
      noTelepon: noTelepon,
      alamat: alamat,
      catatan: catatan,
    );

    ref.invalidateSelf();
    return updated;
  }

  /// Soft delete: Aktifkan / Nonaktifkan penjual
  Future<void> toggleStatus(String id, bool currentStatus) async {
    final repo = ref.read(penjualRepositoryProvider);
    await repo.toggleActiveStatus(id, currentStatus);
    ref.invalidateSelf();
  }
}
