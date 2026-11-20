import 'package:decimal/decimal.dart';

/// Model data baris laporan pembelian per jenis buah per transaksi (FR-7.2, FR-7.6, Tugas Bagian 14).
/// Bersumber dari join tabel `transaksi_item`, `transaksi`, dan `jenis_buah`.
class LaporanPembelianItem {
  final String kodeTransaksi;
  final DateTime tanggalTransaksi;
  final String namaPenjual;
  final String jenisBuah;
  final Decimal hargaPerKg;
  final Decimal beratKotorKg;
  final Decimal persentasePotongan;
  final Decimal potonganKg;
  final Decimal beratBersihKg;
  final Decimal subtotal;
  final String status;
  final String jenisPembayaran;

  bool get isTunai => jenisPembayaran.trim().toLowerCase().replaceAll(' ', '_') == 'tunai';
  bool get isNonTunai => !isTunai;
  String get jenisPembayaranLabel => isNonTunai ? 'Non Tunai' : 'Tunai';

  const LaporanPembelianItem({
    required this.kodeTransaksi,
    required this.tanggalTransaksi,
    required this.namaPenjual,
    required this.jenisBuah,
    required this.hargaPerKg,
    required this.beratKotorKg,
    required this.persentasePotongan,
    required this.potonganKg,
    required this.beratBersihKg,
    required this.subtotal,
    required this.status,
    this.jenisPembayaran = 'tunai',
  });

  /// Factory constructor untuk memetakan JSON join dari Supabase:
  /// `transaksi_item` join `transaksi` (join `penjual`) dan `jenis_buah`.
  factory LaporanPembelianItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> transaksi = {};
    if (json['transaksi'] is Map<String, dynamic>) {
      transaksi = json['transaksi'] as Map<String, dynamic>;
    } else if (json['transaksi'] is List && (json['transaksi'] as List).isNotEmpty) {
      final first = (json['transaksi'] as List).first;
      if (first is Map<String, dynamic>) {
        transaksi = first;
      }
    }

    Map<String, dynamic> penjual = {};
    if (transaksi['penjual'] is Map<String, dynamic>) {
      penjual = transaksi['penjual'] as Map<String, dynamic>;
    } else if (transaksi['penjual'] is List && (transaksi['penjual'] as List).isNotEmpty) {
      final first = (transaksi['penjual'] as List).first;
      if (first is Map<String, dynamic>) {
        penjual = first;
      }
    }

    Map<String, dynamic> jenisBuahMap = {};
    if (json['jenis_buah'] is Map<String, dynamic>) {
      jenisBuahMap = json['jenis_buah'] as Map<String, dynamic>;
    } else if (json['jenis_buah'] is List && (json['jenis_buah'] as List).isNotEmpty) {
      final first = (json['jenis_buah'] as List).first;
      if (first is Map<String, dynamic>) {
        jenisBuahMap = first;
      }
    }

    final kodeTrx = transaksi['kode_transaksi']?.toString() ?? '-';
    final tanggalStr = transaksi['tanggal_transaksi']?.toString();
    final tanggal = tanggalStr != null ? DateTime.parse(tanggalStr) : DateTime.now();
    final namaPenjual = penjual['nama']?.toString() ?? 'Penjual';
    final status = transaksi['status']?.toString() ?? 'selesai';
    final jenisPembayaran = (transaksi['jenis_pembayaran'] ?? json['jenis_pembayaran'])?.toString() ?? 'tunai';

    final namaBuah = jenisBuahMap['nama']?.toString() ??
        (json['jenis_buah_id'] == 1
            ? 'Tandan Besar'
            : json['jenis_buah_id'] == 2
                ? 'Tandan Kecil'
                : 'Berondolan');

    final harga = Decimal.tryParse(json['harga_per_kg']?.toString() ?? '0') ?? Decimal.zero;
    final beratKotor = Decimal.tryParse(json['berat_kotor_kg']?.toString() ??
            json['berat_kg']?.toString() ??
            '0') ??
        Decimal.zero;
    final potonganPct = Decimal.tryParse(json['persentase_potongan']?.toString() ?? '0') ?? Decimal.zero;

    // Hitung potongan kg: beratKotor * (potonganPct / 100)
    final potonganKg = (potonganPct > Decimal.zero && beratKotor > Decimal.zero)
        ? (beratKotor * potonganPct / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 2)
        : Decimal.zero;

    final beratBersih = Decimal.tryParse(json['berat_bersih_kg']?.toString() ?? '') ??
        (beratKotor - potonganKg);

    final subtotal = Decimal.tryParse(json['subtotal']?.toString() ?? '') ??
        (harga * beratBersih);

    return LaporanPembelianItem(
      kodeTransaksi: kodeTrx,
      tanggalTransaksi: tanggal,
      namaPenjual: namaPenjual,
      jenisBuah: namaBuah,
      hargaPerKg: harga,
      beratKotorKg: beratKotor,
      persentasePotongan: potonganPct,
      potonganKg: potonganKg,
      beratBersihKg: beratBersih,
      subtotal: subtotal,
      status: status,
      jenisPembayaran: jenisPembayaran,
    );
  }
}
