import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/weight_formatter.dart';
import '../../models/jenis_buah.dart';
import '../../models/penjual.dart';

/// State untuk 1 baris item buah dalam form transaksi
class TransaksiItemRowState {
  final String keyId;
  JenisBuah? selectedJenisBuah;
  final TextEditingController hargaController;
  final TextEditingController beratController; // Input Berat Kotor (kg)
  final TextEditingController potonganController; // Input Potongan (%) per item

  TransaksiItemRowState({
    required this.keyId,
    this.selectedJenisBuah,
    TextEditingController? hargaController,
    TextEditingController? beratController,
    TextEditingController? potonganController,
  })  : hargaController = hargaController ?? TextEditingController(),
        beratController = beratController ?? TextEditingController(),
        potonganController =
            potonganController ?? TextEditingController(text: '0');

  /// Parse harga per kg menjadi Decimal (Rupiah)
  Decimal? get hargaPerKg {
    return CurrencyFormatter.parse(hargaController.text);
  }

  /// Parse berat kotor kg menjadi Decimal
  Decimal? get beratKotorKg {
    return WeightFormatter.parse(beratController.text);
  }

  /// Kompatibilitas beratKg lama
  Decimal? get beratKg => beratKotorKg;

  /// Parse persentase potongan (%) menjadi Decimal (default 0 jika kosong)
  Decimal get persentasePotongan {
    final clean = potonganController.text.trim().replaceAll(',', '.');
    if (clean.isEmpty) return Decimal.zero;
    return Decimal.tryParse(clean) ?? Decimal.zero;
  }

  /// Validasi rentang potongan (0 - 100)
  bool get isPotonganValid {
    final clean = potonganController.text.trim().replaceAll(',', '.');
    if (clean.isEmpty) return true; // kosong diartikan 0%
    final parsed = Decimal.tryParse(clean);
    if (parsed == null) return false;
    return parsed >= Decimal.zero && parsed <= Decimal.fromInt(100);
  }

  /// Kalkulasi otomatis Berat Bersih (kg) = round(berat_kotor * (1 - potongan% / 100), 2)
  Decimal get beratBersihKg {
    final kotor = beratKotorKg;
    if (kotor == null || kotor <= Decimal.zero) return Decimal.zero;
    final pct = persentasePotongan;
    if (pct <= Decimal.zero) return kotor;
    return (kotor * (Decimal.fromInt(100) - pct) / Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 2);
  }

  /// Kalkulasi otomatis Nilai Potongan (Rp) = round(harga * berat_kotor * potongan% / 100, 2)
  Decimal get nilaiPotonganRp {
    final h = hargaPerKg;
    final kotor = beratKotorKg;
    final pct = persentasePotongan;
    if (h == null || kotor == null || pct <= Decimal.zero) return Decimal.zero;
    return (h * kotor * pct / Decimal.fromInt(100))
        .toDecimal(scaleOnInfinitePrecision: 2);
  }

  /// Subtotal (Rp) = harga_per_kg * berat_bersih_kg
  Decimal get subtotal {
    final h = hargaPerKg;
    final bersih = beratBersihKg;
    if (h != null && bersih > Decimal.zero) {
      return h * bersih;
    }
    return Decimal.zero;
  }

  /// Validasi kelengkapan baris item
  bool get isValid {
    final h = hargaPerKg;
    final b = beratKotorKg;
    return selectedJenisBuah != null &&
        h != null &&
        h >= Decimal.zero &&
        b != null &&
        b > Decimal.zero &&
        isPotonganValid;
  }

  void dispose() {
    hargaController.dispose();
    beratController.dispose();
    potonganController.dispose();
  }
}

/// State keseluruhan form Transaksi Baru (Bagian 10: Potongan per berat item & Bagian 24: Jenis Pembayaran)
class TransaksiFormState {
  final Penjual? selectedPenjual;
  final DateTime tanggalTransaksi;
  final String jenisPembayaran; // 'tunai' | 'non_tunai' (PRD §7.3 FR-3.8)
  final List<TransaksiItemRowState> itemRows;
  final bool isSaving;
  final String? errorMessage;

  TransaksiFormState({
    this.selectedPenjual,
    required this.tanggalTransaksi,
    this.jenisPembayaran = 'tunai',
    required this.itemRows,
    this.isSaving = false,
    this.errorMessage,
  });

  bool get isTunai => jenisPembayaran == 'tunai';
  bool get isNonTunai => jenisPembayaran == 'non_tunai';

  /// Akumulasi Total Berat Kotor Transaksi (kg)
  Decimal get totalBeratKotorKg {
    return itemRows.fold<Decimal>(
      Decimal.zero,
      (sum, row) => sum + (row.beratKotorKg ?? Decimal.zero),
    );
  }

  /// Akumulasi Total Berat Bersih Transaksi (kg)
  Decimal get totalBeratBersihKg {
    return itemRows.fold<Decimal>(
      Decimal.zero,
      (sum, row) => sum + row.beratBersihKg,
    );
  }

  /// Getter kompatibilitas
  Decimal get totalBeratKg => totalBeratBersihKg;

  /// Akumulasi Total Potongan Rupiah dari seluruh baris item
  Decimal get totalPotonganRp {
    return itemRows.fold<Decimal>(
      Decimal.zero,
      (sum, row) => sum + row.nilaiPotonganRp,
    );
  }

  /// Getter kompatibilitas nilaiPotongan
  Decimal get nilaiPotongan => totalPotonganRp;

  /// Akumulasi Total Nilai Transaksi (Rp) dari subtotal seluruh item
  Decimal get totalNilai {
    return itemRows.fold<Decimal>(
      Decimal.zero,
      (sum, row) => sum + row.subtotal,
    );
  }

  /// Getter kompatibilitas totalHarga & totalBersih
  Decimal get totalHarga => totalNilai;
  Decimal get totalBersih => totalNilai;

  /// Maksimal 3 baris item (sesuai jumlah master jenis buah)
  bool get canAddRow => itemRows.length < 3;

  /// Memeriksa apakah tidak ada jenis buah yang duplikat
  bool get hasDuplicateFruit {
    final selectedIds = itemRows
        .map((r) => r.selectedJenisBuah?.id)
        .whereType<int>()
        .toList();
    return selectedIds.toSet().length != selectedIds.length;
  }

  /// Validasi kelengkapan form sebelum disimpan
  bool get isFormValid {
    if (selectedPenjual == null) return false;
    if (itemRows.isEmpty) return false;
    if (hasDuplicateFruit) return false;
    return itemRows.every((row) => row.isValid);
  }

  TransaksiFormState copyWith({
    Penjual? selectedPenjual,
    bool clearPenjual = false,
    DateTime? tanggalTransaksi,
    String? jenisPembayaran,
    List<TransaksiItemRowState>? itemRows,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransaksiFormState(
      selectedPenjual:
          clearPenjual ? null : (selectedPenjual ?? this.selectedPenjual),
      tanggalTransaksi: tanggalTransaksi ?? this.tanggalTransaksi,
      jenisPembayaran: jenisPembayaran ?? this.jenisPembayaran,
      itemRows: itemRows ?? this.itemRows,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
