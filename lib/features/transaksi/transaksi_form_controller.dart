import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/jenis_buah.dart';
import '../../models/penjual.dart';
import '../../models/transaksi.dart';
import '../auth/auth_controller.dart';
import 'jenis_buah_repository.dart';
import 'transaksi_form_state.dart';
import 'transaksi_repository.dart';

/// Notifier untuk mengelola alur form input transaksi baru (Bagian 10: Potongan per item)
class TransaksiFormNotifier extends StateNotifier<TransaksiFormState> {
  final TransaksiRepository _repository;
  final Ref _ref;

  TransaksiFormNotifier(this._repository, this._ref)
      : super(
          TransaksiFormState(
            tanggalTransaksi: DateTime.now(),
            itemRows: [],
          ),
        ) {
    _initInitialRow();
  }

  void _initInitialRow() {
    final initialRow = _createNewRow();
    state = state.copyWith(itemRows: [initialRow]);
  }

  TransaksiItemRowState _createNewRow({JenisBuah? fruit}) {
    final row = TransaksiItemRowState(
      keyId: 'row-${DateTime.now().microsecondsSinceEpoch}',
      selectedJenisBuah: fruit,
    );

    // Pasang listener reaktif agar subtotal dan total terhitung otomatis saat user mengetik
    row.hargaController.addListener(_onRowInputChanged);
    row.beratController.addListener(_onRowInputChanged);
    row.potonganController.addListener(_onRowInputChanged);
    return row;
  }

  void _onRowInputChanged() {
    // Trigger rebuild state untuk recalculate subtotal dan totals
    state = state.copyWith(itemRows: List.from(state.itemRows));
  }

  /// Pilih penjual transaksi
  void setPenjual(Penjual? penjual) {
    state = state.copyWith(
      selectedPenjual: penjual,
      clearPenjual: penjual == null,
    );
  }

  /// Ubah tanggal transaksi
  void setTanggal(DateTime tanggal) {
    state = state.copyWith(tanggalTransaksi: tanggal);
  }

  /// Ubah jenis pembayaran ('tunai' | 'non_tunai') (PRD §7.3 FR-3.8)
  void setJenisPembayaran(String jenis) {
    state = state.copyWith(jenisPembayaran: jenis);
  }

  /// Tambah baris jenis buah baru (maksimal 3)
  void addRow() {
    if (!state.canAddRow) return;

    // Cari jenis buah yang belum dipilih
    final activeFruitsAsync = _ref.read(activeJenisBuahProvider);
    final allFruits = activeFruitsAsync.asData?.value ?? [];
    final usedFruitIds = state.itemRows
        .map((r) => r.selectedJenisBuah?.id)
        .whereType<int>()
        .toSet();

    JenisBuah? availableFruit;
    for (final f in allFruits) {
      if (!usedFruitIds.contains(f.id)) {
        availableFruit = f;
        break;
      }
    }

    final newRow = _createNewRow(fruit: availableFruit);
    state = state.copyWith(itemRows: [...state.itemRows, newRow]);
  }

  /// Hapus baris jenis buah
  void removeRow(int index) {
    if (state.itemRows.length <= 1) return; // Minimal 1 baris
    final updated = List<TransaksiItemRowState>.from(state.itemRows);
    final removed = updated.removeAt(index);
    removed.dispose();
    state = state.copyWith(itemRows: updated);
  }

  /// Ubah jenis buah pada baris tertentu
  void setRowJenisBuah(int index, JenisBuah? fruit) {
    if (index < 0 || index >= state.itemRows.length) return;
    state.itemRows[index].selectedJenisBuah = fruit;
    state = state.copyWith(itemRows: List.from(state.itemRows));
  }

  /// Simpan transaksi ke database
  Future<TransaksiRingkasan?> submitTransaksi({String? catatan}) async {
    if (!state.isFormValid) {
      String message = 'Mohon lengkapi seluruh isian dengan benar.';
      if (state.selectedPenjual == null) {
        message = 'Pilih penjual terlebih dahulu.';
      } else if (state.hasDuplicateFruit) {
        message = 'Jenis buah tidak boleh duplikat dalam satu transaksi.';
      } else if (state.itemRows.isEmpty) {
        message = 'Minimal harus ada 1 jenis buah.';
      } else if (state.itemRows.any((r) => !r.isPotonganValid)) {
        message = 'Potongan tiap jenis buah harus bernilai antara 0 dan 100%.';
      } else {
        message = 'Pastikan harga >= 0 dan berat kotor > 0 untuk semua baris.';
      }
      state = state.copyWith(errorMessage: message);
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final currentUser = _ref.read(authControllerProvider).profile;

      final itemsDraft = state.itemRows.map((row) {
        return TransaksiItemDraft(
          jenisBuahId: row.selectedJenisBuah!.id,
          jenisBuahNama: row.selectedJenisBuah!.nama,
          hargaPerKg: row.hargaPerKg!,
          beratKotorKg: row.beratKotorKg!,
          persentasePotongan: row.persentasePotongan,
        );
      }).toList();

      final result = await _repository.createTransaksi(
        penjualId: state.selectedPenjual!.id,
        namaPenjual: state.selectedPenjual!.nama,
        tanggalTransaksi: state.tanggalTransaksi,
        jenisPembayaran: state.jenisPembayaran,
        catatan: catatan,
        createdBy: currentUser?.id,
        items: itemsDraft,
      );

      state = state.copyWith(isSaving: false, clearError: true);
      return result;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  /// Reset form kembali ke kondisi awal
  void resetForm() {
    for (final r in state.itemRows) {
      r.dispose();
    }
    state = TransaksiFormState(
      tanggalTransaksi: DateTime.now(),
      itemRows: [],
    );
    _initInitialRow();
  }

  @override
  void dispose() {
    for (final r in state.itemRows) {
      r.dispose();
    }
    super.dispose();
  }
}

final transaksiFormProvider =
    StateNotifierProvider.autoDispose<TransaksiFormNotifier, TransaksiFormState>(
        (ref) {
  final repo = ref.watch(transaksiRepositoryProvider);
  return TransaksiFormNotifier(repo, ref);
});
