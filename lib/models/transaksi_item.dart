import 'package:decimal/decimal.dart';
import 'jenis_buah.dart';

/// Model mewakili tabel `public.transaksi_item` di Supabase.
/// Kolom DB: id, transaksi_id, jenis_buah_id, harga_per_kg, berat_kotor_kg,
/// persentase_potongan, berat_bersih_kg, nilai_potongan_rp, subtotal, created_at
class TransaksiItem {
  final String id;
  final String transaksiId;
  final int jenisBuahId;
  final Decimal hargaPerKg;
  final Decimal beratKotorKg;
  final Decimal persentasePotongan;
  final Decimal beratBersihKg;
  final Decimal nilaiPotonganRp;
  final Decimal subtotal;
  final DateTime createdAt;

  // Optional relations / joins
  final JenisBuah? jenisBuah;

  TransaksiItem({
    required this.id,
    required this.transaksiId,
    required this.jenisBuahId,
    required this.hargaPerKg,
    required this.beratKotorKg,
    Decimal? persentasePotongan,
    Decimal? beratBersihKg,
    Decimal? nilaiPotonganRp,
    Decimal? subtotal,
    required this.createdAt,
    this.jenisBuah,
  })  : persentasePotongan = persentasePotongan ?? Decimal.zero,
        beratBersihKg = beratBersihKg ?? beratKotorKg,
        nilaiPotonganRp = nilaiPotonganRp ?? Decimal.zero,
        subtotal = subtotal ?? (hargaPerKg * beratKotorKg);

  /// Getter kompatibilitas ke belakang (berat bersih)
  Decimal get beratKg => beratBersihKg;

  factory TransaksiItem.fromJson(Map<String, dynamic> json) {
    final harga = Decimal.parse(json['harga_per_kg'].toString());
    final kotor = Decimal.parse(
        (json['berat_kotor_kg'] ?? json['berat_kg'] ?? '0').toString());
    final pct = json['persentase_potongan'] != null
        ? Decimal.parse(json['persentase_potongan'].toString())
        : Decimal.zero;

    final bersih = json['berat_bersih_kg'] != null
        ? Decimal.parse(json['berat_bersih_kg'].toString())
        : (kotor * (Decimal.fromInt(100) - pct) / Decimal.fromInt(100))
            .toDecimal(scaleOnInfinitePrecision: 2);

    final potRp = json['nilai_potongan_rp'] != null
        ? Decimal.parse(json['nilai_potongan_rp'].toString())
        : (harga * kotor * pct / Decimal.fromInt(100))
            .toDecimal(scaleOnInfinitePrecision: 2);

    final sub = json['subtotal'] != null
        ? Decimal.parse(json['subtotal'].toString())
        : harga * bersih;

    return TransaksiItem(
      id: json['id'] as String,
      transaksiId: json['transaksi_id'] as String,
      jenisBuahId: json['jenis_buah_id'] as int,
      hargaPerKg: harga,
      beratKotorKg: kotor,
      persentasePotongan: pct,
      beratBersihKg: bersih,
      nilaiPotonganRp: potRp,
      subtotal: sub,
      createdAt: DateTime.parse(json['created_at'] as String),
      jenisBuah: json['jenis_buah'] != null
          ? JenisBuah.fromJson(json['jenis_buah'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaksi_id': transaksiId,
      'jenis_buah_id': jenisBuahId,
      'harga_per_kg': hargaPerKg.toString(),
      'berat_kotor_kg': beratKotorKg.toString(),
      'persentase_potongan': persentasePotongan.toString(),
      'berat_bersih_kg': beratBersihKg.toString(),
      'nilai_potongan_rp': nilaiPotonganRp.toString(),
      'subtotal': subtotal.toString(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Map untuk insert ke Supabase (berat_bersih_kg, nilai_potongan_rp, subtotal di-generate DB)
  Map<String, dynamic> toInsertMap() {
    return {
      'transaksi_id': transaksiId,
      'jenis_buah_id': jenisBuahId,
      'harga_per_kg': hargaPerKg.toDouble(),
      'berat_kotor_kg': beratKotorKg.toDouble(),
      'persentase_potongan': persentasePotongan.toDouble(),
    };
  }

  TransaksiItem copyWith({
    String? id,
    String? transaksiId,
    int? jenisBuahId,
    Decimal? hargaPerKg,
    Decimal? beratKotorKg,
    Decimal? persentasePotongan,
    Decimal? beratBersihKg,
    Decimal? nilaiPotonganRp,
    Decimal? subtotal,
    DateTime? createdAt,
    JenisBuah? jenisBuah,
  }) {
    return TransaksiItem(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      jenisBuahId: jenisBuahId ?? this.jenisBuahId,
      hargaPerKg: hargaPerKg ?? this.hargaPerKg,
      beratKotorKg: beratKotorKg ?? this.beratKotorKg,
      persentasePotongan: persentasePotongan ?? this.persentasePotongan,
      beratBersihKg: beratBersihKg ?? this.beratBersihKg,
      nilaiPotonganRp: nilaiPotonganRp ?? this.nilaiPotonganRp,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
      jenisBuah: jenisBuah ?? this.jenisBuah,
    );
  }
}
