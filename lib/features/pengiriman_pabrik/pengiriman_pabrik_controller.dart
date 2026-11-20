import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pabrik.dart';
import '../../models/pengiriman_pabrik.dart';
import '../auth/auth_controller.dart';
import 'pengiriman_pabrik_repository.dart';

/// State formulir pengiriman ke pabrik (Fase 1: Keberangkatan)
class PengirimanFormState {
  final Pabrik? pabrik;
  final String platNomor;
  final String namaSopir;
  final DateTime tanggalKirim;
  final Decimal? beratDikirim;
  final String catatan;
  final bool isSubmitting;
  final String? errorMessage;

  PengirimanFormState({
    this.pabrik,
    this.platNomor = '',
    this.namaSopir = '',
    DateTime? tanggalKirim,
    Decimal? beratDikirim,
    Decimal? beratKotor,
    this.catatan = '',
    this.isSubmitting = false,
    this.errorMessage,
  })  : beratDikirim = beratDikirim ?? beratKotor,
        tanggalKirim = tanggalKirim ?? DateTime.now();

  /// Alias getter untuk backward compatibility
  Decimal? get beratKotor => beratDikirim;

  PengirimanFormState copyWith({
    Pabrik? pabrik,
    bool clearPabrik = false,
    String? platNomor,
    String? namaSopir,
    DateTime? tanggalKirim,
    Decimal? beratDikirim,
    Decimal? beratKotor,
    bool clearBeratDikirim = false,
    String? catatan,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PengirimanFormState(
      pabrik: clearPabrik ? null : (pabrik ?? this.pabrik),
      platNomor: platNomor ?? this.platNomor,
      namaSopir: namaSopir ?? this.namaSopir,
      tanggalKirim: tanggalKirim ?? this.tanggalKirim,
      beratDikirim: clearBeratDikirim
          ? null
          : (beratDikirim ?? beratKotor ?? this.beratDikirim),
      catatan: catatan ?? this.catatan,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final pengirimanFormProvider =
    StateNotifierProvider<PengirimanFormNotifier, PengirimanFormState>((ref) {
  return PengirimanFormNotifier(ref);
});

class PengirimanFormNotifier extends StateNotifier<PengirimanFormState> {
  final Ref _ref;

  PengirimanFormNotifier(this._ref) : super(PengirimanFormState());

  void setPabrik(Pabrik? pabrik) {
    state = state.copyWith(pabrik: pabrik, clearPabrik: pabrik == null);
  }

  void setPlatNomor(String plat) {
    state = state.copyWith(platNomor: plat);
  }

  void setNamaSopir(String sopir) {
    state = state.copyWith(namaSopir: sopir);
  }

  void setTanggalKirim(DateTime tanggal) {
    state = state.copyWith(tanggalKirim: tanggal);
  }

  void setBeratDikirim(Decimal? val) {
    state = state.copyWith(beratDikirim: val, clearBeratDikirim: val == null);
  }

  /// Alias untuk backward compatibility
  void setBeratKotor(Decimal? val) => setBeratDikirim(val);

  void setCatatan(String val) {
    state = state.copyWith(catatan: val);
  }

  void resetForm() {
    state = PengirimanFormState();
  }

  Future<PengirimanPabrik?> submit() async {
    if (state.pabrik == null) {
      state = state.copyWith(errorMessage: 'Pabrik tujuan wajib dipilih.');
      return null;
    }
    if (state.platNomor.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Nomor plat truk wajib diisi.');
      return null;
    }
    if (state.namaSopir.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Nama sopir truk wajib diisi.');
      return null;
    }
    if (state.beratDikirim == null || state.beratDikirim! <= Decimal.zero) {
      state = state.copyWith(
        errorMessage: 'Berat Dikirim wajib diisi dan lebih besar dari 0 kg.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    try {
      final repo = _ref.read(pengirimanPabrikRepositoryProvider);
      final currentUserId = _ref.read(authControllerProvider).profile?.id;

      final saved = await repo.createPengiriman(
        pabrikId: state.pabrik!.id,
        platNomor: state.platNomor,
        namaSopir: state.namaSopir,
        tanggalKirim: state.tanggalKirim,
        beratDikirimKg: state.beratDikirim!,
        catatan: state.catatan,
        createdBy: currentUserId,
        pabrikModel: state.pabrik,
      );

      _ref.invalidate(pengirimanListProvider);
      state = state.copyWith(isSubmitting: false);
      return saved;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }
}

/// State untuk formulir Fase 2: Penyelesaian Nota Hasil Pabrik
class SelesaikanFormState {
  final PengirimanPabrik pengiriman;
  final Decimal? beratSampai;
  final Decimal? beratDitolak;
  final Decimal? persentasePotongan;
  final Decimal? hargaJualPerKg;
  final Decimal? potonganLainnya;
  final Decimal? potonganSortasiPerKg;
  final String catatan;
  final bool isSubmitting;
  final String? errorMessage;

  SelesaikanFormState({
    PengirimanPabrik? pengiriman,
    Decimal? beratDikirim,
    this.beratSampai,
    Decimal? beratDitolak,
    Decimal? persentasePotongan,
    this.hargaJualPerKg,
    this.potonganLainnya,
    this.potonganSortasiPerKg,
    this.catatan = '',
    this.isSubmitting = false,
    this.errorMessage,
  })  : pengiriman = pengiriman ??
            PengirimanPabrik(
              id: '',
              kodePengiriman: '',
              pabrikId: '',
              platNomor: '',
              namaSopir: '',
              tanggalKirim: DateTime.now(),
              beratDikirimKg: beratDikirim ?? Decimal.zero,
            ),
        beratDitolak = beratDitolak ?? Decimal.zero,
        persentasePotongan = persentasePotongan ?? Decimal.zero;

  Decimal get safeBeratSampai => beratSampai ?? pengiriman.beratDikirimKg;
  Decimal get safeBeratDitolak => beratDitolak ?? Decimal.zero;
  Decimal get safePersentasePotongan => persentasePotongan ?? Decimal.zero;
  Decimal get safePotonganLainnya => potonganLainnya ?? Decimal.zero;
  Decimal get safePotonganSortasiPerKg => potonganSortasiPerKg ?? Decimal.zero;

  /// Susut Buah = Berat Dikirim - Berat Sampai
  Decimal get susutBuah {
    final dikirim = pengiriman.beratDikirimKg;
    if (safeBeratSampai <= Decimal.zero) return Decimal.zero;
    return dikirim - safeBeratSampai;
  }

  /// Berat Diterima = Berat Sampai - Berat Ditolak
  Decimal get beratDiterima {
    if (safeBeratSampai <= Decimal.zero) return Decimal.zero;
    final res = safeBeratSampai - safeBeratDitolak;
    return res > Decimal.zero ? res : Decimal.zero;
  }

  /// Berat Bersih = Berat Diterima * (1 - Potongan% / 100)
  Decimal get beratBersih {
    final diterima = beratDiterima;
    if (diterima <= Decimal.zero) return Decimal.zero;
    if (safePersentasePotongan <= Decimal.zero) return diterima;
    return (diterima *
            (Decimal.fromInt(100) - safePersentasePotongan) /
            Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 2);
  }

  /// Nilai Potongan Pabrik (%) (Rp) = Harga Jual * Berat Diterima * Potongan% / 100
  Decimal get nilaiPotonganRp {
    if (hargaJualPerKg == null || hargaJualPerKg! <= Decimal.zero) {
      return Decimal.zero;
    }
    final diterima = beratDiterima;
    if (diterima <= Decimal.zero || safePersentasePotongan <= Decimal.zero) {
      return Decimal.zero;
    }
    return (hargaJualPerKg! *
            diterima *
            safePersentasePotongan /
            Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 2);
  }

  /// Nilai Potongan Sortasi (Rp) = Potongan Sortasi (Rp/kg) x Berat Sampai (kg)
  Decimal get nilaiPotonganSortasi {
    if (safePotonganSortasiPerKg <= Decimal.zero || safeBeratSampai <= Decimal.zero) {
      return Decimal.zero;
    }
    return safePotonganSortasiPerKg * safeBeratSampai;
  }

  /// Total Nilai Jual (Formula baru PRD 7.8 poin 9):
  /// (Harga Jual/kg x Berat Bersih) - Potongan Lainnya - Nilai Potongan Sortasi
  Decimal get totalNilaiJual {
    if (hargaJualPerKg == null || hargaJualPerKg! <= Decimal.zero) {
      return Decimal.zero;
    }
    final dasar = hargaJualPerKg! * beratBersih;
    final total = dasar - safePotonganLainnya - nilaiPotonganSortasi;
    return total;
  }

  /// Validasi form Fase 2
  bool get isValid {
    if (beratSampai == null || beratSampai! <= Decimal.zero) return false;
    if (safeBeratDitolak < Decimal.zero || safeBeratDitolak > beratSampai!) return false;
    if (safePersentasePotongan < Decimal.zero || safePersentasePotongan > Decimal.fromInt(100)) return false;
    if (hargaJualPerKg == null || hargaJualPerKg! <= Decimal.zero) return false;
    if (potonganLainnya != null && potonganLainnya! < Decimal.zero) return false;
    if (potonganSortasiPerKg != null && potonganSortasiPerKg! < Decimal.zero) return false;
    return true;
  }

  SelesaikanFormState copyWith({
    PengirimanPabrik? pengiriman,
    Decimal? beratSampai,
    bool clearBeratSampai = false,
    Decimal? beratDitolak,
    bool clearBeratDitolak = false,
    Decimal? persentasePotongan,
    bool clearPersentasePotongan = false,
    Decimal? hargaJualPerKg,
    bool clearHargaJualPerKg = false,
    Decimal? potonganLainnya,
    bool clearPotonganLainnya = false,
    Decimal? potonganSortasiPerKg,
    bool clearPotonganSortasiPerKg = false,
    String? catatan,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SelesaikanFormState(
      pengiriman: pengiriman ?? this.pengiriman,
      beratSampai:
          clearBeratSampai ? null : (beratSampai ?? this.beratSampai),
      beratDitolak:
          clearBeratDitolak ? null : (beratDitolak ?? this.beratDitolak),
      persentasePotongan: clearPersentasePotongan
          ? null
          : (persentasePotongan ?? this.persentasePotongan),
      hargaJualPerKg: clearHargaJualPerKg
          ? null
          : (hargaJualPerKg ?? this.hargaJualPerKg),
      potonganLainnya: clearPotonganLainnya
          ? null
          : (potonganLainnya ?? this.potonganLainnya),
      potonganSortasiPerKg: clearPotonganSortasiPerKg
          ? null
          : (potonganSortasiPerKg ?? this.potonganSortasiPerKg),
      catatan: catatan ?? this.catatan,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SelesaikanFormNotifier extends StateNotifier<SelesaikanFormState> {
  final Ref _ref;

  SelesaikanFormNotifier(this._ref, PengirimanPabrik initialPengiriman)
      : super(SelesaikanFormState(pengiriman: initialPengiriman));

  void setBeratSampai(Decimal? val) {
    state = state.copyWith(beratSampai: val, clearBeratSampai: val == null);
  }

  void setBeratDitolak(Decimal? val) {
    state = state.copyWith(beratDitolak: val, clearBeratDitolak: val == null);
  }

  void setPersentasePotongan(Decimal? val) {
    state = state.copyWith(
      persentasePotongan: val,
      clearPersentasePotongan: val == null,
    );
  }

  void setHargaJualPerKg(Decimal? val) {
    state = state.copyWith(
      hargaJualPerKg: val,
      clearHargaJualPerKg: val == null,
    );
  }

  void setPotonganLainnya(Decimal? val) {
    state = state.copyWith(
      potonganLainnya: val,
      clearPotonganLainnya: val == null,
    );
  }

  void setPotonganSortasiPerKg(Decimal? val) {
    state = state.copyWith(
      potonganSortasiPerKg: val,
      clearPotonganSortasiPerKg: val == null,
    );
  }

  void setCatatan(String val) {
    state = state.copyWith(catatan: val);
  }

  Future<PengirimanPabrik?> submit() async {
    if (state.beratSampai == null || state.beratSampai! <= Decimal.zero) {
      state = state.copyWith(
        errorMessage: 'Berat Sampai (kg) wajib diisi dan lebih besar dari 0 kg.',
      );
      return null;
    }

    final ditolak = state.safeBeratDitolak;
    if (ditolak < Decimal.zero) {
      state = state.copyWith(
        errorMessage: 'Berat ditolak tidak boleh bernilai negatif.',
      );
      return null;
    }
    if (ditolak > state.beratSampai!) {
      state = state.copyWith(
        errorMessage:
            'Berat ditolak tidak boleh lebih besar dari Berat Sampai (${state.beratSampai!} kg).',
      );
      return null;
    }

    final pot = state.safePersentasePotongan;
    if (pot < Decimal.zero || pot > Decimal.fromInt(100)) {
      state = state.copyWith(
        errorMessage: 'Potongan pabrik harus di rentang 0% - 100%.',
      );
      return null;
    }

    if (state.hargaJualPerKg == null || state.hargaJualPerKg! <= Decimal.zero) {
      state = state.copyWith(
        errorMessage: 'Harga jual per kg wajib diisi dan lebih dari Rp 0.',
      );
      return null;
    }

    if (state.potonganLainnya != null && state.potonganLainnya! < Decimal.zero) {
      state = state.copyWith(
        errorMessage: 'Potongan Lainnya tidak boleh bernilai negatif.',
      );
      return null;
    }

    if (state.potonganSortasiPerKg != null && state.potonganSortasiPerKg! < Decimal.zero) {
      state = state.copyWith(
        errorMessage: 'Potongan Sortasi per kg tidak boleh bernilai negatif.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    try {
      final repo = _ref.read(pengirimanPabrikRepositoryProvider);
      final completed = await repo.selesaikanPengirimanFase2(
        id: state.pengiriman.id,
        beratSampaiKg: state.beratSampai!,
        beratDitolakKg: ditolak,
        persentasePotonganPabrik: pot,
        hargaJualPerKg: state.hargaJualPerKg!,
        potonganLainnyaRp: state.potonganLainnya,
        potonganSortasiPerKg: state.potonganSortasiPerKg,
        catatan: state.catatan,
      );

      _ref.invalidate(pengirimanListProvider);
      return completed;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }
}

/// Provider formulir Fase 2 penyelesaian nota hasil pabrik
final selesaikanFormProvider = StateNotifierProvider.autoDispose
    .family<SelesaikanFormNotifier, SelesaikanFormState, PengirimanPabrik>(
        (ref, pengiriman) {
  return SelesaikanFormNotifier(ref, pengiriman);
});

/// Provider riwayat pengiriman ke pabrik
final pengirimanListProvider =
    AsyncNotifierProvider<PengirimanListNotifier, List<PengirimanPabrik>>(() {
  return PengirimanListNotifier();
});

class PengirimanListNotifier extends AsyncNotifier<List<PengirimanPabrik>> {
  @override
  Future<List<PengirimanPabrik>> build() async {
    final repo = ref.watch(pengirimanPabrikRepositoryProvider);
    return repo.getPengirimanList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(pengirimanPabrikRepositoryProvider);
      return repo.getPengirimanList();
    });
  }

  Future<void> cancelPengiriman(String id, String? alasan) async {
    final repo = ref.read(pengirimanPabrikRepositoryProvider);
    await repo.cancelPengiriman(id, alasan);
    ref.invalidateSelf();
  }
}
