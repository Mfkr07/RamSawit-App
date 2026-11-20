import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pemakaian_saldo_harian.dart';
import '../../models/saldo_ringkasan.dart';
import '../../models/topup_saldo.dart';
import '../../models/transaksi_non_tunai_harian.dart';
import 'saldo_filter_state.dart';
import 'saldo_repository.dart';

/// State komprehensif untuk Modul Saldo / Dana Modal
class SaldoState {
  final SaldoRingkasan ringkasan;
  final List<TopupSaldo> topupList;
  final List<PemakaianSaldoHarian> pemakaianHarianList;
  final List<TransaksiNonTunaiHarian> nonTunaiHarianList; // PRD §7.10 FR-10.10
  final List<MutasiSaldoItem> mutasiList;
  final String activeTab; // 'semua', 'topup', 'pemakaian', 'non_tunai'
  final int totalCount;
  final bool isLoading;
  final String? errorMessage;

  const SaldoState({
    required this.ringkasan,
    required this.topupList,
    this.pemakaianHarianList = const [],
    this.nonTunaiHarianList = const [],
    this.mutasiList = const [],
    this.activeTab = 'semua',
    this.totalCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Akumulasi total nilai transaksi non tunai pada periode filter
  Decimal get totalNilaiNonTunai {
    return nonTunaiHarianList.fold<Decimal>(
      Decimal.zero,
      (sum, it) => sum + it.totalNilai,
    );
  }

  factory SaldoState.initial() {
    return SaldoState(
      ringkasan: SaldoRingkasan.zero(),
      topupList: const [],
      pemakaianHarianList: const [],
      nonTunaiHarianList: const [],
      mutasiList: const [],
      activeTab: 'semua',
      totalCount: 0,
      isLoading: true,
      errorMessage: null,
    );
  }

  SaldoState copyWith({
    SaldoRingkasan? ringkasan,
    List<TopupSaldo>? topupList,
    List<PemakaianSaldoHarian>? pemakaianHarianList,
    List<TransaksiNonTunaiHarian>? nonTunaiHarianList,
    List<MutasiSaldoItem>? mutasiList,
    String? activeTab,
    int? totalCount,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SaldoState(
      ringkasan: ringkasan ?? this.ringkasan,
      topupList: topupList ?? this.topupList,
      pemakaianHarianList: pemakaianHarianList ?? this.pemakaianHarianList,
      nonTunaiHarianList: nonTunaiHarianList ?? this.nonTunaiHarianList,
      mutasiList: mutasiList ?? this.mutasiList,
      activeTab: activeTab ?? this.activeTab,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SaldoController extends StateNotifier<SaldoState> {
  final SaldoRepository _repository;
  final Ref _ref;

  SaldoController(this._repository, this._ref) : super(SaldoState.initial()) {
    loadData();

    // Dengarkan perubahan filter agar otomatis reload data & ringkasan sesuai periode
    _ref.listen<SaldoFilterState>(saldoFilterProvider, (_, _) {
      loadData(refreshRingkasan: true);
    });
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  /// Memuat data ringkasan saldo, top up per aksi, dan total pemakaian per hari
  Future<void> loadData({bool refreshRingkasan = true}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final filter = _ref.read(saldoFilterProvider);

    try {
      final ringkasan = await _repository.getSaldoRingkasan(
        startDate: filter.startDate,
        endDate: filter.endDate,
      );

      final paginatedTopup = await _repository.fetchTopupPaginated(
        startDate: filter.startDate,
        endDate: filter.endDate,
        page: filter.page,
        pageSize: filter.pageSize,
      );

      final pemakaianHarian = await _repository.fetchPemakaianHarian(
        startDate: filter.startDate,
        endDate: filter.endDate,
      );

      final mutasiLinimasa = await _repository.fetchMutasiLinimasa(
        startDate: filter.startDate,
        endDate: filter.endDate,
      );

      final nonTunaiHarian = await _repository.fetchTransaksiNonTunaiHarian(
        startDate: filter.startDate,
        endDate: filter.endDate,
      );

      state = state.copyWith(
        ringkasan: ringkasan,
        topupList: paginatedTopup.items,
        pemakaianHarianList: pemakaianHarian,
        nonTunaiHarianList: nonTunaiHarian,
        mutasiList: mutasiLinimasa,
        totalCount: paginatedTopup.totalCount,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Menambah Top Up baru dan menyegarkan sisa saldo secara langsung (FR-10.1, FR-10.2)
  Future<bool> createTopup({
    required DateTime tanggal,
    required Decimal nominal,
    String? keterangan,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.createTopup(
        tanggal: tanggal,
        nominal: nominal,
        keterangan: keterangan,
      );

      // Selalu refresh ringkasan saldo dan daftar riwayat
      await loadData(refreshRingkasan: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Menghapus top up jika diperlukan
  Future<bool> deleteTopup(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteTopup(id);
      await loadData(refreshRingkasan: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final saldoControllerProvider =
    StateNotifierProvider<SaldoController, SaldoState>((ref) {
  final repository = ref.watch(saldoRepositoryProvider);
  return SaldoController(repository, ref);
});
