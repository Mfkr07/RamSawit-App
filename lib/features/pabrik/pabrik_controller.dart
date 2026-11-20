import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pabrik.dart';
import '../auth/auth_controller.dart';
import 'pabrik_repository.dart';

/// State untuk pencarian dan filter data pabrik
class PabrikFilterState {
  final String searchQuery;
  final bool includeInactive;

  const PabrikFilterState({
    this.searchQuery = '',
    this.includeInactive = false,
  });

  PabrikFilterState copyWith({
    String? searchQuery,
    bool? includeInactive,
  }) {
    return PabrikFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      includeInactive: includeInactive ?? this.includeInactive,
    );
  }
}

final pabrikFilterProvider =
    StateNotifierProvider<PabrikFilterNotifier, PabrikFilterState>((ref) {
  return PabrikFilterNotifier();
});

class PabrikFilterNotifier extends StateNotifier<PabrikFilterState> {
  PabrikFilterNotifier() : super(const PabrikFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleIncludeInactive() {
    state = state.copyWith(includeInactive: !state.includeInactive);
  }

  void reset() {
    state = const PabrikFilterState();
  }
}

/// Provider daftar pabrik reaktif terhadap filter dan mutasi data
final pabrikListProvider =
    AsyncNotifierProvider<PabrikListNotifier, List<Pabrik>>(() {
  return PabrikListNotifier();
});

class PabrikListNotifier extends AsyncNotifier<List<Pabrik>> {
  @override
  Future<List<Pabrik>> build() async {
    final filter = ref.watch(pabrikFilterProvider);
    final repo = ref.watch(pabrikRepositoryProvider);
    return repo.getPabrikList(
      searchQuery: filter.searchQuery,
      includeInactive: filter.includeInactive,
    );
  }

  /// Refresh manual
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(pabrikFilterProvider);
      final repo = ref.read(pabrikRepositoryProvider);
      return repo.getPabrikList(
        searchQuery: filter.searchQuery,
        includeInactive: filter.includeInactive,
      );
    });
  }

  /// Tambah pabrik baru
  Future<Pabrik> createPabrik({
    required String nama,
    String? alamat,
    String? kontak,
  }) async {
    final repo = ref.read(pabrikRepositoryProvider);
    final currentUser = ref.read(authControllerProvider).profile;

    final created = await repo.createPabrik(
      nama: nama,
      alamat: alamat,
      kontak: kontak,
      createdBy: currentUser?.id,
    );

    // Refresh daftar setelah mutasi
    ref.invalidateSelf();
    return created;
  }

  /// Ubah pabrik
  Future<Pabrik> updatePabrik({
    required String id,
    required String nama,
    String? alamat,
    String? kontak,
  }) async {
    final repo = ref.read(pabrikRepositoryProvider);
    final updated = await repo.updatePabrik(
      id: id,
      nama: nama,
      alamat: alamat,
      kontak: kontak,
    );

    ref.invalidateSelf();
    return updated;
  }

  /// Ubah status aktif / nonaktif (soft delete)
  Future<void> toggleActiveStatus(String id, bool currentStatus) async {
    final repo = ref.read(pabrikRepositoryProvider);
    await repo.toggleActiveStatus(id, currentStatus);
    ref.invalidateSelf();
  }

  /// Alias untuk toggleActiveStatus
  Future<void> toggleStatus(String id, bool currentStatus) async {
    await toggleActiveStatus(id, currentStatus);
  }
}
