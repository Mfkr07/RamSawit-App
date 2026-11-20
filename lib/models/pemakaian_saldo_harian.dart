import 'package:decimal/decimal.dart';
import 'topup_saldo.dart';

/// Model untuk total pemakaian saldo oleh kasir per hari (tanda minus -)
class PemakaianSaldoHarian {
  final DateTime tanggal;
  final Decimal totalPemakaian;
  final int jumlahTransaksi;

  const PemakaianSaldoHarian({
    required this.tanggal,
    required this.totalPemakaian,
    required this.jumlahTransaksi,
  });

  factory PemakaianSaldoHarian.fromJson(Map<String, dynamic> json) {
    final rawTanggal = json['tanggal'] ?? json['tanggal_transaksi'];
    final rawTotal = json['total_pemakaian'] ?? json['total_nilai'] ?? '0';
    final rawCount = json['jumlah_transaksi'] ?? json['count'] ?? 1;

    return PemakaianSaldoHarian(
      tanggal: rawTanggal is DateTime
          ? rawTanggal
          : DateTime.tryParse(rawTanggal.toString()) ?? DateTime.now(),
      totalPemakaian: Decimal.tryParse(rawTotal.toString()) ?? Decimal.zero,
      jumlahTransaksi: int.tryParse(rawCount.toString()) ?? 1,
    );
  }
}

enum JenisMutasiSaldo {
  topup, // Plus (+) per aksi top up
  pemakaianHarian, // Minus (-) total pemakaian per hari
}

/// Item linimasa aktivitas mutasi saldo (+ Top Up per aksi, - Pemakaian per hari)
class MutasiSaldoItem {
  final JenisMutasiSaldo jenis;
  final DateTime tanggal;
  final Decimal nominal;
  final String? keterangan;
  final TopupSaldo? topupData;
  final PemakaianSaldoHarian? pemakaianData;

  MutasiSaldoItem.topup(TopupSaldo topup)
      : jenis = JenisMutasiSaldo.topup,
        tanggal = topup.tanggal,
        nominal = topup.nominal,
        keterangan = topup.keterangan,
        topupData = topup,
        pemakaianData = null;

  MutasiSaldoItem.pemakaian(PemakaianSaldoHarian pemakaian)
      : jenis = JenisMutasiSaldo.pemakaianHarian,
        tanggal = pemakaian.tanggal,
        nominal = pemakaian.totalPemakaian,
        keterangan = '${pemakaian.jumlahTransaksi} transaksi pembelian selesai',
        topupData = null,
        pemakaianData = pemakaian;

  bool get isTopup => jenis == JenisMutasiSaldo.topup;
  bool get isPemakaian => jenis == JenisMutasiSaldo.pemakaianHarian;
}
