import 'package:decimal/decimal.dart';

/// Model mewakili view agregasi `public.v_transaksi_non_tunai_harian` di Supabase.
/// Acuan: PRD §7.10 FR-10.10 & Database.md Bagian 13.
class TransaksiNonTunaiHarian {
  final DateTime tanggal;
  final int jumlahTransaksi;
  final Decimal totalNilai;

  const TransaksiNonTunaiHarian({
    required this.tanggal,
    required this.jumlahTransaksi,
    required this.totalNilai,
  });

  factory TransaksiNonTunaiHarian.fromJson(Map<String, dynamic> json) {
    final rawTanggal = json['tanggal'] ?? json['tanggal_transaksi'];
    final rawCount = json['jumlah_transaksi'] ?? json['count'] ?? 0;
    final rawTotal = json['total_nilai'] ?? '0';

    return TransaksiNonTunaiHarian(
      tanggal: rawTanggal is DateTime
          ? rawTanggal
          : DateTime.tryParse(rawTanggal.toString()) ?? DateTime.now(),
      jumlahTransaksi: int.tryParse(rawCount.toString()) ?? 0,
      totalNilai: Decimal.tryParse(rawTotal.toString()) ?? Decimal.zero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal.toIso8601String().split('T').first,
      'jumlah_transaksi': jumlahTransaksi,
      'total_nilai': totalNilai.toString(),
    };
  }
}
