import 'package:decimal/decimal.dart';

/// Model data ringkasan saldo dari view `public.v_saldo_ringkasan` (PRD §7.10, Database.md §11)
class SaldoRingkasan {
  final Decimal totalTopup;
  final Decimal totalPemakaian;
  final Decimal sisaSaldo;
  final Decimal? totalTopupPeriode;
  final Decimal? totalPemakaianPeriode;

  const SaldoRingkasan({
    required this.totalTopup,
    required this.totalPemakaian,
    required this.sisaSaldo,
    this.totalTopupPeriode,
    this.totalPemakaianPeriode,
  });

  /// Total Top Up efektif sesuai filter periode yang aktif
  Decimal get effectiveTotalTopup => totalTopupPeriode ?? totalTopup;

  /// Total Pemakaian efektif sesuai filter periode yang aktif
  Decimal get effectiveTotalPemakaian => totalPemakaianPeriode ?? totalPemakaian;

  /// Indikator visual peringatan jika saldo <= 0 (FR-10.6)
  bool get isLowOrExhausted => sisaSaldo <= Decimal.zero;

  factory SaldoRingkasan.fromJson(Map<String, dynamic> json) {
    final rawTopup = json['total_topup'] ?? '0';
    final rawPemakaian = json['total_pemakaian'] ?? '0';
    final rawSisa = json['sisa_saldo'] ?? '0';

    final rawTopupPeriode = json['total_topup_periode'];
    final rawPemakaianPeriode = json['total_pemakaian_periode'];

    return SaldoRingkasan(
      totalTopup: Decimal.parse(rawTopup.toString()),
      totalPemakaian: Decimal.parse(rawPemakaian.toString()),
      sisaSaldo: Decimal.parse(rawSisa.toString()),
      totalTopupPeriode: rawTopupPeriode != null
          ? Decimal.tryParse(rawTopupPeriode.toString())
          : null,
      totalPemakaianPeriode: rawPemakaianPeriode != null
          ? Decimal.tryParse(rawPemakaianPeriode.toString())
          : null,
    );
  }

  factory SaldoRingkasan.zero() {
    return SaldoRingkasan(
      totalTopup: Decimal.zero,
      totalPemakaian: Decimal.zero,
      sisaSaldo: Decimal.zero,
      totalTopupPeriode: Decimal.zero,
      totalPemakaianPeriode: Decimal.zero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_topup': totalTopup.toString(),
      'total_pemakaian': totalPemakaian.toString(),
      'sisa_saldo': sisaSaldo.toString(),
      if (totalTopupPeriode != null)
        'total_topup_periode': totalTopupPeriode.toString(),
      if (totalPemakaianPeriode != null)
        'total_pemakaian_periode': totalPemakaianPeriode.toString(),
    };
  }

  SaldoRingkasan copyWith({
    Decimal? totalTopup,
    Decimal? totalPemakaian,
    Decimal? sisaSaldo,
    Decimal? totalTopupPeriode,
    Decimal? totalPemakaianPeriode,
  }) {
    return SaldoRingkasan(
      totalTopup: totalTopup ?? this.totalTopup,
      totalPemakaian: totalPemakaian ?? this.totalPemakaian,
      sisaSaldo: sisaSaldo ?? this.sisaSaldo,
      totalTopupPeriode: totalTopupPeriode ?? this.totalTopupPeriode,
      totalPemakaianPeriode: totalPemakaianPeriode ?? this.totalPemakaianPeriode,
    );
  }
}
