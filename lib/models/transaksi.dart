import 'package:decimal/decimal.dart';
import 'penjual.dart';
import 'transaksi_item.dart';

/// Model mewakili tabel header `public.transaksi` di Supabase.
/// Kolom DB: id, kode_transaksi, penjual_id, tanggal_transaksi, status, catatan, alasan_pembatalan,
/// persentase_potongan (arsip header), created_by, created_at, updated_at
class Transaksi {
  final String id;
  final String kodeTransaksi;
  final String penjualId;
  final DateTime tanggalTransaksi;
  final String status; // 'draft', 'selesai', 'dibatalkan'
  final String? catatan;
  final String? alasanPembatalan;
  final Decimal persentasePotongan;
  final String jenisPembayaran; // 'tunai' | 'non_tunai' (PRD §7.3 FR-3.8)
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Nilai potongan & total eksplisit (jika dipassing dari view / kalkulasi tersimpan)
  final Decimal? _nilaiPotongan;
  final Decimal? _totalNilai;

  // Relasi opsional
  final Penjual? penjual;
  final List<TransaksiItem>? items;

  Transaksi({
    required this.id,
    required this.kodeTransaksi,
    required this.penjualId,
    required this.tanggalTransaksi,
    this.status = 'selesai',
    this.jenisPembayaran = 'tunai',
    this.catatan,
    this.alasanPembatalan,
    Decimal? persentasePotongan,
    Decimal? nilaiPotongan,
    Decimal? totalNilai,
    Decimal? totalBersih,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.penjual,
    this.items,
  })  : persentasePotongan = persentasePotongan ?? Decimal.zero,
        _nilaiPotongan = nilaiPotongan,
        _totalNilai = totalNilai ?? totalBersih;

  bool get isSelesai => status == 'selesai';
  bool get isDibatalkan => status == 'dibatalkan';
  bool get isDraft => status == 'draft';
  bool get isTunai => jenisPembayaran == 'tunai';
  bool get isNonTunai => jenisPembayaran == 'non_tunai';

  /// Akumulasi Total Berat Kotor TBS dari item transaksi
  Decimal get totalBeratKotorKg {
    if (items != null && items!.isNotEmpty) {
      return items!.fold<Decimal>(
        Decimal.zero,
        (sum, it) => sum + it.beratKotorKg,
      );
    }
    return Decimal.zero;
  }

  /// Akumulasi Total Berat Bersih TBS dari item transaksi
  Decimal get totalBeratBersihKg {
    if (items != null && items!.isNotEmpty) {
      return items!.fold<Decimal>(
        Decimal.zero,
        (sum, it) => sum + it.beratBersihKg,
      );
    }
    return Decimal.zero;
  }

  /// Getter kompatibilitas: total berat bersih
  Decimal get totalBeratKg => totalBeratBersihKg;

  /// Akumulasi Rupiah potongan dari seluruh item transaksi
  Decimal get totalPotonganRp {
    if (_nilaiPotongan != null) return _nilaiPotongan;
    if (items != null && items!.isNotEmpty) {
      return items!.fold<Decimal>(
        Decimal.zero,
        (sum, it) => sum + it.nilaiPotonganRp,
      );
    }
    return Decimal.zero;
  }

  /// Getter kompatibilitas nilaiPotongan
  Decimal get nilaiPotongan => totalPotonganRp;

  /// Akumulasi Total Nilai Transaksi (Rp) dari subtotal seluruh item
  Decimal get totalNilai {
    if (_totalNilai != null) return _totalNilai;
    if (items != null && items!.isNotEmpty) {
      return items!.fold<Decimal>(
        Decimal.zero,
        (sum, it) => sum + it.subtotal,
      );
    }
    return Decimal.zero;
  }

  /// Getter kompatibilitas totalHarga & totalBersih
  Decimal get totalHarga => totalNilai;
  Decimal get totalBersih => totalNilai;

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    final pct = json['persentase_potongan'] != null
        ? Decimal.parse(json['persentase_potongan'].toString())
        : Decimal.zero;

    final potRp = json['total_potongan_rp'] != null
        ? Decimal.parse(json['total_potongan_rp'].toString())
        : (json['nilai_potongan'] != null
            ? Decimal.parse(json['nilai_potongan'].toString())
            : null);

    final nilai = json['total_nilai'] != null
        ? Decimal.parse(json['total_nilai'].toString())
        : (json['total_bersih'] != null
            ? Decimal.parse(json['total_bersih'].toString())
            : (json['total_harga'] != null
                ? Decimal.parse(json['total_harga'].toString())
                : null));

    return Transaksi(
      id: json['id'] as String,
      kodeTransaksi: json['kode_transaksi'] as String,
      penjualId: json['penjual_id'] as String,
      tanggalTransaksi: DateTime.parse(json['tanggal_transaksi'] as String),
      status: json['status'] as String? ?? 'selesai',
      jenisPembayaran: json['jenis_pembayaran'] as String? ?? 'tunai',
      catatan: json['catatan'] as String?,
      alasanPembatalan: json['alasan_pembatalan'] as String?,
      persentasePotongan: pct,
      nilaiPotongan: potRp,
      totalNilai: nilai,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      penjual: json['penjual'] != null
          ? Penjual.fromJson(json['penjual'] as Map<String, dynamic>)
          : null,
      items: json['transaksi_item'] != null
          ? (json['transaksi_item'] as List<dynamic>)
              .map((item) => TransaksiItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_transaksi': kodeTransaksi,
      'penjual_id': penjualId,
      'tanggal_transaksi': tanggalTransaksi.toIso8601String().split('T').first,
      'status': status,
      'jenis_pembayaran': jenisPembayaran,
      'catatan': catatan,
      'alasan_pembatalan': alasanPembatalan,
      'persentase_potongan': persentasePotongan.toString(),
      'total_potongan_rp': totalPotonganRp.toString(),
      'total_nilai': totalNilai.toString(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map untuk insert transaksi baru (id, kode_transaksi, dan timestamp digenerate oleh DB)
  Map<String, dynamic> toInsertMap() {
    return {
      'penjual_id': penjualId,
      'tanggal_transaksi': tanggalTransaksi.toIso8601String().split('T').first,
      'status': status,
      'jenis_pembayaran': jenisPembayaran,
      'catatan': catatan,
      'persentase_potongan': persentasePotongan.toString(),
      'created_by': createdBy,
    };
  }

  Transaksi copyWith({
    String? id,
    String? kodeTransaksi,
    String? penjualId,
    DateTime? tanggalTransaksi,
    String? status,
    String? jenisPembayaran,
    String? catatan,
    String? alasanPembatalan,
    Decimal? persentasePotongan,
    Decimal? nilaiPotongan,
    Decimal? totalNilai,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Penjual? penjual,
    List<TransaksiItem>? items,
  }) {
    return Transaksi(
      id: id ?? this.id,
      kodeTransaksi: kodeTransaksi ?? this.kodeTransaksi,
      penjualId: penjualId ?? this.penjualId,
      tanggalTransaksi: tanggalTransaksi ?? this.tanggalTransaksi,
      status: status ?? this.status,
      jenisPembayaran: jenisPembayaran ?? this.jenisPembayaran,
      catatan: catatan ?? this.catatan,
      alasanPembatalan: alasanPembatalan ?? this.alasanPembatalan,
      persentasePotongan: persentasePotongan ?? this.persentasePotongan,
      nilaiPotongan: nilaiPotongan ?? this.nilaiPotongan,
      totalNilai: totalNilai ?? this.totalNilai,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      penjual: penjual ?? this.penjual,
      items: items ?? this.items,
    );
  }
}

/// Model mewakili view agregasi `public.v_transaksi_ringkasan` di Supabase.
/// Sumber kebenaran utama total berat kotor, total berat bersih, potongan rp, & total nilai transaksi.
class TransaksiRingkasan {
  final String id;
  final String kodeTransaksi;
  final DateTime tanggalTransaksi;
  final String status;
  final String jenisPembayaran; // 'tunai' | 'non_tunai' (PRD §7.3 FR-3.8)
  final String penjualId;
  final String namaPenjual;
  final Decimal totalBeratKotorKg;
  final Decimal totalBeratBersihKg;
  final Decimal totalPotonganRp;
  final Decimal totalNilai; // Total nilai transaksi (Rp)
  final String? catatan;
  final String? alasanPembatalan;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Decimal persentasePotongan;

  TransaksiRingkasan({
    required this.id,
    required this.kodeTransaksi,
    required this.tanggalTransaksi,
    required this.status,
    this.jenisPembayaran = 'tunai',
    required this.penjualId,
    required this.namaPenjual,
    required this.totalBeratKotorKg,
    required this.totalBeratBersihKg,
    required this.totalPotonganRp,
    required this.totalNilai,
    this.catatan,
    this.alasanPembatalan,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    Decimal? persentasePotongan,
  }) : persentasePotongan = persentasePotongan ?? Decimal.zero;

  bool get isSelesai => status == 'selesai';
  bool get isDibatalkan => status == 'dibatalkan';
  bool get isDraft => status == 'draft';
  bool get isTunai => jenisPembayaran == 'tunai';
  bool get isNonTunai => jenisPembayaran == 'non_tunai';

  // Compatibility getters:
  Decimal get totalBeratKg => totalBeratBersihKg;
  Decimal get totalHarga => totalNilai;
  Decimal get totalBersih => totalNilai;
  Decimal get nilaiPotongan => totalPotonganRp;

  factory TransaksiRingkasan.fromJson(Map<String, dynamic> json) {
    final kotor = json['total_berat_kotor_kg'] != null
        ? Decimal.parse(json['total_berat_kotor_kg'].toString())
        : Decimal.parse((json['total_berat_kg'] ?? '0').toString());

    final bersih = json['total_berat_bersih_kg'] != null
        ? Decimal.parse(json['total_berat_bersih_kg'].toString())
        : Decimal.parse((json['total_berat_kg'] ?? '0').toString());

    final potRp = json['total_potongan_rp'] != null
        ? Decimal.parse(json['total_potongan_rp'].toString())
        : (json['nilai_potongan'] != null
            ? Decimal.parse(json['nilai_potongan'].toString())
            : Decimal.zero);

    final nilai = json['total_nilai'] != null
        ? Decimal.parse(json['total_nilai'].toString())
        : (json['total_bersih'] != null
            ? Decimal.parse(json['total_bersih'].toString())
            : Decimal.parse((json['total_harga'] ?? '0').toString()));

    final pct = json['persentase_potongan'] != null
        ? Decimal.parse(json['persentase_potongan'].toString())
        : Decimal.zero;

    return TransaksiRingkasan(
      id: json['id'] as String,
      kodeTransaksi: json['kode_transaksi'] as String,
      tanggalTransaksi: DateTime.parse(json['tanggal_transaksi'] as String),
      status: json['status'] as String? ?? 'selesai',
      jenisPembayaran: json['jenis_pembayaran'] as String? ?? 'tunai',
      penjualId: json['penjual_id'] as String,
      namaPenjual: json['nama_penjual'] as String,
      totalBeratKotorKg: kotor,
      totalBeratBersihKg: bersih,
      totalPotonganRp: potRp,
      totalNilai: nilai,
      catatan: json['catatan'] as String?,
      alasanPembatalan: json['alasan_pembatalan'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      persentasePotongan: pct,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_transaksi': kodeTransaksi,
      'tanggal_transaksi': tanggalTransaksi.toIso8601String().split('T').first,
      'status': status,
      'jenis_pembayaran': jenisPembayaran,
      'penjual_id': penjualId,
      'nama_penjual': namaPenjual,
      'total_berat_kotor_kg': totalBeratKotorKg.toString(),
      'total_berat_bersih_kg': totalBeratBersihKg.toString(),
      'total_potongan_rp': totalPotonganRp.toString(),
      'total_nilai': totalNilai.toString(),
      'persentase_potongan': persentasePotongan.toString(),
      'catatan': catatan,
      'alasan_pembatalan': alasanPembatalan,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  TransaksiRingkasan copyWith({
    String? id,
    String? kodeTransaksi,
    DateTime? tanggalTransaksi,
    String? status,
    String? jenisPembayaran,
    String? penjualId,
    String? namaPenjual,
    Decimal? totalBeratKotorKg,
    Decimal? totalBeratBersihKg,
    Decimal? totalPotonganRp,
    Decimal? totalNilai,
    String? catatan,
    String? alasanPembatalan,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Decimal? persentasePotongan,
  }) {
    return TransaksiRingkasan(
      id: id ?? this.id,
      kodeTransaksi: kodeTransaksi ?? this.kodeTransaksi,
      tanggalTransaksi: tanggalTransaksi ?? this.tanggalTransaksi,
      status: status ?? this.status,
      jenisPembayaran: jenisPembayaran ?? this.jenisPembayaran,
      penjualId: penjualId ?? this.penjualId,
      namaPenjual: namaPenjual ?? this.namaPenjual,
      totalBeratKotorKg: totalBeratKotorKg ?? this.totalBeratKotorKg,
      totalBeratBersihKg: totalBeratBersihKg ?? this.totalBeratBersihKg,
      totalPotonganRp: totalPotonganRp ?? this.totalPotonganRp,
      totalNilai: totalNilai ?? this.totalNilai,
      catatan: catatan ?? this.catatan,
      alasanPembatalan: alasanPembatalan ?? this.alasanPembatalan,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      persentasePotongan: persentasePotongan ?? this.persentasePotongan,
    );
  }
}
