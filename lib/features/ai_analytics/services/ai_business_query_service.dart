import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import '../../../models/pabrik.dart';
import '../../../models/pengeluaran.dart';
import '../../../models/pengiriman_pabrik.dart';
import '../../../models/transaksi.dart';

/// Response hasil evaluasi kueri bisnis
class AiQueryResponse {
  final String text;
  final List<String> suggestions;
  final Map<String, String>? metrics;

  const AiQueryResponse({
    required this.text,
    this.suggestions = const [],
    this.metrics,
  });
}

/// Service lokal yang menganalisis data transaksi operasional riil TBS sawit
/// dan menyusun jawaban cerdas komprehensif untuk pertanyaan pemilik bisnis (owner).
class AiBusinessQueryService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _numberFormat = NumberFormat('#,###', 'id_ID');

  static String _formatRupiah(Decimal value) {
    return _currencyFormat.format(value.toDouble());
  }

  static String _formatKg(Decimal value) {
    return '${_numberFormat.format(value.toDouble())} kg';
  }

  /// Memproses pertanyaan owner dengan menganalisis dataset transaksi, pabrik, dan pengeluaran secara deterministik dan presisi
  static Future<AiQueryResponse> processQuery({
    required String query,
    required List<TransaksiRingkasan> transaksiList,
    required List<PengirimanPabrik> pengirimanList,
    required List<Pengeluaran> pengeluaranList,
    required List<Pabrik> pabrikList,
  }) async {
    final lower = query.toLowerCase().trim();

    // 0. Query: Perkenalan diri, Salam, Siapa Anda, Bantuan Umum
    if (lower.contains('perkenal') ||
        lower.contains('siapa kamu') ||
        lower.contains('siapa anda') ||
        lower.contains('halo') ||
        lower.contains('hai') ||
        lower.contains('selamat pagi') ||
        lower.contains('selamat siang') ||
        lower.contains('selamat sore') ||
        lower.contains('selamat malam') ||
        lower.contains('bisa apa') ||
        lower.contains('kemampuan') ||
        lower.contains('fitur')) {
      return _handleIntroductionAndGreeting(
        lower: lower,
        transaksiList: transaksiList,
        pengirimanList: pengirimanList,
        pengeluaranList: pengeluaranList,
      );
    }

    // 1. Query: Biaya / Pengeluaran / Pembelian berdasarkan tanggal tertentu
    final dateMatch = _extractDateFromQuery(lower);
    if (lower.contains('biaya') ||
        lower.contains('pembelian') ||
        lower.contains('beli') ||
        lower.contains('pengeluaran') ||
        dateMatch != null) {
      if (dateMatch != null || lower.contains('hari ini') || lower.contains('kemarin')) {
        return _handleDateSpecificCostQuery(
          query: lower,
          dateMatch: dateMatch,
          transaksiList: transaksiList,
          pengeluaranList: pengeluaranList,
        );
      }
    }

    // 2. Query: Performa / Sortasi Pabrik
    if (lower.contains('potongan') ||
        lower.contains('pabrik') ||
        lower.contains('sortasi') ||
        lower.contains('pks')) {
      return _handleFactoryPerformanceQuery(
        pengirimanList: pengirimanList,
        pabrikList: pabrikList,
      );
    }

    // 3. Query: Rekomendasi Harga Beli TBS Petani
    if (lower.contains('harga') ||
        lower.contains('rekomendasi') ||
        lower.contains('patokan')) {
      return _handlePriceRecommendationQuery(
        pengirimanList: pengirimanList,
        transaksiList: transaksiList,
      );
    }

    // 4. Query: Total Pengeluaran Operasional Ram Timbangan
    if (lower.contains('operasional') ||
        (lower.contains('keluar') && !lower.contains('beli'))) {
      return _handleOperationalExpenseQuery(
        pengeluaranList: pengeluaranList,
      );
    }

    // 5. Query: Performa Keseluruhan / Laba Rugi / Kas Ringkas
    if (lower.contains('laba') ||
        lower.contains('profit') ||
        lower.contains('ringkasan') ||
        lower.contains('kinerja')) {
      return _handleProfitSummaryQuery(
        transaksiList: transaksiList,
        pengirimanList: pengirimanList,
        pengeluaranList: pengeluaranList,
      );
    }

    // 6. Default Fallback Respons Cerdas Kontekstual
    return _handleDefaultAssistantOverview(
      transaksiList: transaksiList,
      pengirimanList: pengirimanList,
      pengeluaranList: pengeluaranList,
    );
  }

  /// Ekstraksi tanggal atau kata waktu dari input pertanyaan
  static DateTime? _extractDateFromQuery(String query) {
    final now = DateTime.now();

    if (query.contains('hari ini')) {
      return DateTime(now.year, now.month, now.day);
    }
    if (query.contains('kemarin')) {
      final kem = now.subtract(const Duration(days: 1));
      return DateTime(kem.year, kem.month, kem.day);
    }

    // Regex mencocokkan "tanggal 25", "tgl 25", "tgl 25/09", atau angka tanggal saja
    final regDate = RegExp(r'(?:tanggal|tgl)\s*(\d{1,2})(?:[\/\-\s](\d{1,2}))?(?:[\/\-\s](\d{2,4}))?');
    final match = regDate.firstMatch(query);
    if (match != null) {
      final day = int.tryParse(match.group(1) ?? '');
      final month = int.tryParse(match.group(2) ?? '') ?? now.month;
      var year = int.tryParse(match.group(3) ?? '') ?? now.year;
      if (year < 100) year += 2000;

      if (day != null && day >= 1 && day <= 31) {
        return DateTime(year, month, day);
      }
    }

    // Coba deteksi angka tanggal mandiri jika ada kata "tanggal"
    final regStandalone = RegExp(r'\btanggal\s*(\d{1,2})\b');
    final m2 = regStandalone.firstMatch(query);
    if (m2 != null) {
      final day = int.tryParse(m2.group(1) ?? '');
      if (day != null && day >= 1 && day <= 31) {
        return DateTime(now.year, now.month, day);
      }
    }

    return null;
  }

  /// Penanganan Kueri Biaya Pembelian & Pengeluaran berdasarkan Tanggal Spesifik
  static AiQueryResponse _handleDateSpecificCostQuery({
    required String query,
    required DateTime? dateMatch,
    required List<TransaksiRingkasan> transaksiList,
    required List<Pengeluaran> pengeluaranList,
  }) {
    final targetDate = dateMatch ?? DateTime.now();
    final dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(targetDate);

    // Filter transaksi pembelian pada tanggal yang diminta
    final trxMatched = transaksiList.where((t) {
      return t.tanggalTransaksi.year == targetDate.year &&
          t.tanggalTransaksi.month == targetDate.month &&
          t.tanggalTransaksi.day == targetDate.day &&
          !t.isDibatalkan;
    }).toList();

    // Filter pengeluaran operasional pada tanggal yang sama
    final expMatched = pengeluaranList.where((e) {
      return e.tanggalPengeluaran.year == targetDate.year &&
          e.tanggalPengeluaran.month == targetDate.month &&
          e.tanggalPengeluaran.day == targetDate.day;
    }).toList();

    Decimal totalBiayaBeli = Decimal.zero;
    Decimal totalBeratKotor = Decimal.zero;
    Decimal totalBeratBersih = Decimal.zero;
    Decimal totalPotonganBeli = Decimal.zero;

    for (final t in trxMatched) {
      totalBiayaBeli += t.totalNilai;
      totalBeratKotor += t.totalBeratKotorKg;
      totalBeratBersih += t.totalBeratBersihKg;
      totalPotonganBeli += t.totalPotonganRp;
    }

    Decimal totalBiayaOperasional = Decimal.zero;
    for (final e in expMatched) {
      totalBiayaOperasional += e.nominal;
    }

    final totalPengeluaranGabungan = totalBiayaBeli + totalBiayaOperasional;

    if (trxMatched.isEmpty && expMatched.isEmpty) {
      final sampleTrx = transaksiList.isNotEmpty ? transaksiList.first : null;
      final saranTanggal = sampleTrx != null
          ? DateFormat('dd MMMM yyyy', 'id_ID').format(sampleTrx.tanggalTransaksi)
          : 'tanggal aktif lainnya';

      return AiQueryResponse(
        text:
            '**Laporan Biaya & Transaksi untuk Tanggal $dateStr:**\n\n'
            'Tidak ditemukan catatan transaksi pembelian maupun pengeluaran kas pada tanggal **$dateStr**.\n\n'
            '💡 *Saran Pencarian:* Anda dapat menanyakan tanggal di mana terdapat catatan transaksi aktif, misalnya tanggal **$saranTanggal**, atau menanyakan total minggu ini.',
        suggestions: [
          'Berapa total pembelian pada tanggal $saranTanggal?',
          'Berapa total pembelian bulan berjalan?',
          'Pabrik mana yang potongannya paling tinggi?',
        ],
        metrics: {
          'Tanggal': dateStr,
          'Total Pembelian': 'Rp 0',
          'Status Data': 'Kosong / Nihil',
        },
      );
    }

    final rataRataHarga = totalBeratBersih > Decimal.zero
        ? (totalBiayaBeli / totalBeratBersih).toDecimal(scaleOnInfinitePrecision: 2)
        : Decimal.zero;

    final textBuffer = StringBuffer();
    textBuffer.writeln('**Rekapitulasi Biaya & Pembelian TBS — $dateStr**\n');
    textBuffer.writeln('Berikut rincian biaya yang tercatat pada sistem database:');
    textBuffer.writeln('• **Total Biaya Pembelian TBS:** **${_formatRupiah(totalBiayaBeli)}**');
    textBuffer.writeln('• **Jumlah Transaksi Selesai:** **${trxMatched.length} nota**');
    textBuffer.writeln('• **Total Tonase Buah Masuk:** **${_formatKg(totalBeratBersih)}** (Kotor: ${_formatKg(totalBeratKotor)})');
    if (rataRataHarga > Decimal.zero) {
      textBuffer.writeln('• **Rata-rata Harga Beli Petani:** **${_formatRupiah(rataRataHarga)} / kg**');
    }
    if (totalPotonganBeli > Decimal.zero) {
      textBuffer.writeln('• **Total Potongan Sortasi Timbangan:** ${_formatRupiah(totalPotonganBeli)}');
    }

    if (totalBiayaOperasional > Decimal.zero) {
      textBuffer.writeln('\n**Biaya Operasional Tambahan (Kas Keluar):**');
      textBuffer.writeln('• **Total Operasional:** **${_formatRupiah(totalBiayaOperasional)}** (${expMatched.length} pos pengeluaran)');
      textBuffer.writeln('• **Grand Total Biaya Dikeluarkan:** **${_formatRupiah(totalPengeluaranGabungan)}**');
    }

    textBuffer.writeln('\n💡 *Status Akuntabilitas:* Seluruh perhitungan dihitung presisi `Decimal` berdasarkan data nota riil di database.');

    return AiQueryResponse(
      text: textBuffer.toString(),
      suggestions: [
        'Pabrik mana yang potongannya paling tinggi?',
        'Berapa estimasi laba kotor hari ini?',
        'Berapa rekomendasi harga beli TBS besok?',
      ],
      metrics: {
        'Total Biaya Pembelian': _formatRupiah(totalBiayaBeli),
        'Tonase Bersih': _formatKg(totalBeratBersih),
        'Jumlah Nota': '${trxMatched.length} Transaksi',
      },
    );
  }

  /// Penanganan Kueri Performa Sortasi & Potongan Pabrik Kelapa Sawit (PKS)
  static AiQueryResponse _handleFactoryPerformanceQuery({
    required List<PengirimanPabrik> pengirimanList,
    required List<Pabrik> pabrikList,
  }) {
    if (pengirimanList.isEmpty) {
      return const AiQueryResponse(
        text:
            '**Analisis Potongan Sortasi Pabrik (PKS):**\n\n'
            'Belum ada riwayat pengiriman ke pabrik yang tercatat pada database saat ini. '
            'Setelah Anda mencatat nota timbangan pabrik di modul **Pengiriman Pabrik**, '
            'AI akan mengalkulasi persentase deviasi potongan sortasi tiap PKS secara otomatis.',
        suggestions: [
          'Berapa rekomendasi harga beli TBS besok?',
          'Berapa total pembelian hari ini?',
        ],
      );
    }

    // Kelompokkan data per pabrik
    final Map<String, List<PengirimanPabrik>> groupPerPabrik = {};
    for (final p in pengirimanList) {
      groupPerPabrik.putIfAbsent(p.pabrikId, () => []).add(p);
    }

    final pabrikMap = {for (final pb in pabrikList) pb.id: pb.nama};

    final List<Map<String, dynamic>> factoryStats = [];

    groupPerPabrik.forEach((pabrikId, listKirim) {
      final namaPabrik = pabrikMap[pabrikId] ?? listKirim.first.pabrikId;
      Decimal sumBruto = Decimal.zero;
      Decimal sumNetto = Decimal.zero;
      Decimal sumPotonganKg = Decimal.zero;

      for (final k in listKirim) {
        final bruto = k.beratDikirimKg;
        final netto = k.beratBersihKg ?? bruto;
        final potongan = bruto > netto ? (bruto - netto) : Decimal.zero;

        sumBruto += bruto;
        sumNetto += netto;
        sumPotonganKg += potongan;
      }

      final persentaseSortasi = sumBruto > Decimal.zero
          ? ((sumPotonganKg.toDouble() / sumBruto.toDouble()) * 100.0)
          : 0.0;

      factoryStats.add({
        'nama': namaPabrik,
        'persen': persentaseSortasi,
        'pengiriman': listKirim.length,
        'totalNetto': sumNetto,
        'potonganKg': sumPotonganKg,
      });
    });

    // Urutkan dari persentase potongan tertinggi ke terendah
    factoryStats.sort((a, b) => (b['persen'] as double).compareTo(a['persen'] as double));

    final highest = factoryStats.first;
    final lowest = factoryStats.last;

    final buffer = StringBuffer();
    buffer.writeln('**Analisis Kinerja Sortasi Pabrik (PKS):**\n');
    buffer.writeln('Berdasarkan rekapitulasi data riil pengiriman ke pabrik:\n');

    for (int i = 0; i < factoryStats.length; i++) {
      final f = factoryStats[i];
      final isHigh = i == 0 && (f['persen'] as double) > 5.0;
      final badge = isHigh ? '⚠️ *(Paling Tinggi)*' : '✅';
      buffer.writeln(
        '${i + 1}. **${f['nama']}**: Potongan Rata-rata **${(f['persen'] as double).toStringAsFixed(1)}%** $badge '
        '(${f['pengiriman']} trip, Potongan: ${_formatKg(f['potonganKg'] as Decimal)})',
      );
    }

    buffer.writeln('\n💡 **Rekomendasi Strategis AI:**');
    buffer.writeln(
      '• Pabrik dengan potongan tertinggi saat ini adalah **${highest['nama']}** (${(highest['persen'] as double).toStringAsFixed(1)}%). '
      'Jika memungkinkan, alihkan muatan dengan porsi buah mentah/tangkai panjang ke **${lowest['nama']}** '
      'yang memiliki rata-rata potongan lebih ramah (**${(lowest['persen'] as double).toStringAsFixed(1)}%**).',
    );

    return AiQueryResponse(
      text: buffer.toString(),
      suggestions: [
        'Berapa harga beli TBS rekomendasi besok?',
        'Berapa total pembelian hari ini?',
        'Berapa selisih timbangan kirim vs pabrik?',
      ],
      metrics: {
        'Potongan Tertinggi': '${highest['nama']} (${(highest['persen'] as double).toStringAsFixed(1)}%)',
        'Potongan Terendah': '${lowest['nama']} (${(lowest['persen'] as double).toStringAsFixed(1)}%)',
      },
    );
  }

  /// Penanganan Rekomendasi Harga Beli TBS Petani
  static AiQueryResponse _handlePriceRecommendationQuery({
    required List<PengirimanPabrik> pengirimanList,
    required List<TransaksiRingkasan> transaksiList,
  }) {
    Decimal hargaJualPabrik = Decimal.parse('2780'); // Baseline default industri
    if (pengirimanList.isNotEmpty) {
      final latest = pengirimanList.firstWhere(
        (p) => (p.hargaJualPerKg ?? Decimal.zero) > Decimal.zero,
        orElse: () => pengirimanList.first,
      );
      if ((latest.hargaJualPerKg ?? Decimal.zero) > Decimal.zero) {
        hargaJualPabrik = latest.hargaJualPerKg!;
      }
    }

    final biayaAngkut = Decimal.parse('95');
    final toleransiSusut = (hargaJualPabrik * Decimal.parse('0.015')).floor(); // 1.5%
    final targetMarginBersih = Decimal.parse('150'); // Rp 150 / kg

    final maxHargaBeli = hargaJualPabrik - biayaAngkut - toleransiSusut - targetMarginBersih;
    final idealHargaBeli = maxHargaBeli - Decimal.parse('30');

    final buffer = StringBuffer();
    buffer.writeln('**Rekomendasi Harga Beli TBS Tingkat Petani:**\n');
    buffer.writeln('Berdasarkan benchmark harga penerimaan pabrik dan pagu operasional ram timbangan Anda:\n');
    buffer.writeln('• **Harga Penerimaan PKS Terakhir:** **${_formatRupiah(hargaJualPabrik)} / kg**');
    buffer.writeln('• **Estimasi Biaya Angkut & Muat:** ${_formatRupiah(biayaAngkut)} / kg');
    buffer.writeln('• **Pencadangan Susut & Sortir Pabrik (1.5%):** ${_formatRupiah(toleransiSusut)} / kg');
    buffer.writeln('• **Target Margin Bersih:** ${_formatRupiah(targetMarginBersih)} / kg\n');
    buffer.writeln('🎯 **Rekomendasi Papan Harga Petani:** **${_formatRupiah(idealHargaBeli)} - ${_formatRupiah(maxHargaBeli)} / kg**\n');
    buffer.writeln('💡 *Analisis AI:* Memasang harga di angka **${_formatRupiah(idealHargaBeli)}/kg** memberikan daya saing tinggi untuk menarik petani sekitar dengan tetap mengunci margin aman minimal Rp 150/kg.');

    return AiQueryResponse(
      text: buffer.toString(),
      suggestions: [
        'Berapa total pembelian hari ini?',
        'Pabrik mana yang potongannya paling tinggi?',
        'Berapa proyeksi laba kotor minggu ini?',
      ],
      metrics: {
        'Harga Beli Ideal': '${_formatRupiah(idealHargaBeli)}/kg',
        'Harga Jual PKS': '${_formatRupiah(hargaJualPabrik)}/kg',
        'Target Margin': '${_formatRupiah(targetMarginBersih)}/kg',
      },
    );
  }

  /// Penanganan Kueri Pengeluaran Operasional Ram Timbangan
  static AiQueryResponse _handleOperationalExpenseQuery({
    required List<Pengeluaran> pengeluaranList,
  }) {
    if (pengeluaranList.isEmpty) {
      return const AiQueryResponse(
        text:
            '**Rekapitulasi Biaya Operasional:**\n\n'
            'Belum ada catatan pengeluaran operasional di database. '
            'Anda dapat mencatat biaya bensin armada, makan karyawan, maupun perawatan pos timbangan pada menu **Pengeluaran**.',
        suggestions: ['Berapa total pembelian hari ini?'],
      );
    }

    Decimal totalNominal = Decimal.zero;
    final Map<String, Decimal> perKategori = {};

    for (final exp in pengeluaranList) {
      totalNominal += exp.nominal;
      final kat = exp.jenisPengeluaranNama ?? 'Operasional Umum';
      perKategori[kat] = (perKategori[kat] ?? Decimal.zero) + exp.nominal;
    }

    final sorted = perKategori.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer();
    buffer.writeln('**Rekapitulasi Biaya Operasional Ram Timbangan:**\n');
    buffer.writeln('• **Total Pengeluaran:** **${_formatRupiah(totalNominal)}** (${pengeluaranList.length} pos catatan)\n');
    buffer.writeln('**Rincian Kategori Pengeluaran Terbesar:**');
    for (final entry in sorted.take(5)) {
      buffer.writeln('• **${entry.key}:** ${_formatRupiah(entry.value)}');
    }

    buffer.writeln('\n💡 *Efisiensi Biaya:* Beban operasional terbesar berasal dari **${sorted.first.key}**. Pastikan efisiensi rute armada dan pencatatan nota tetap disiplin.');

    return AiQueryResponse(
      text: buffer.toString(),
      suggestions: [
        'Berapa total pembelian hari ini?',
        'Berapa laba kotor bulan ini?',
      ],
      metrics: {
        'Total Operasional': _formatRupiah(totalNominal),
        'Kategori Dominan': sorted.first.key,
      },
    );
  }

  /// Penanganan Kueri Laba / Kinerja Finansial
  static AiQueryResponse _handleProfitSummaryQuery({
    required List<TransaksiRingkasan> transaksiList,
    required List<PengirimanPabrik> pengirimanList,
    required List<Pengeluaran> pengeluaranList,
  }) {
    Decimal totalBeli = Decimal.zero;
    Decimal totalKgBeli = Decimal.zero;
    for (final t in transaksiList.where((e) => !e.isDibatalkan)) {
      totalBeli += t.totalNilai;
      totalKgBeli += t.totalBeratBersihKg;
    }

    Decimal totalJual = Decimal.zero;
    Decimal totalKgJual = Decimal.zero;
    for (final p in pengirimanList) {
      totalJual += p.totalNilaiJual ?? Decimal.zero;
      totalKgJual += p.beratBersihKg ?? p.beratDikirimKg;
    }

    Decimal totalOperasional = Decimal.zero;
    for (final e in pengeluaranList) {
      totalOperasional += e.nominal;
    }

    final estimasiLabaKotor = totalJual - totalBeli - totalOperasional;

    return AiQueryResponse(
      text:
          '**Ringkasan Kinerja Keuangan & Margin Laba:**\n\n'
          '• **Total Pembelian Buah TBS:** ${_formatRupiah(totalBeli)} (${_formatKg(totalKgBeli)})\n'
          '• **Total Penjualan ke Pabrik:** ${_formatRupiah(totalJual)} (${_formatKg(totalKgJual)})\n'
          '• **Total Biaya Operasional:** ${_formatRupiah(totalOperasional)}\n'
          '• **Estimasi Laba Bersih Operasional:** **${_formatRupiah(estimasiLabaKotor)}**\n\n'
          '💡 *Catatan:* Perhitungan ini merefleksikan seluruh transaksi aktif yang terdata di sistem lokal.',
      suggestions: [
        'Berapa harga beli TBS rekomendasi besok?',
        'Pabrik mana yang potongannya paling tinggi?',
      ],
      metrics: {
        'Estimasi Laba': _formatRupiah(estimasiLabaKotor),
        'Tonase Beli': _formatKg(totalKgBeli),
      },
    );
  }

  /// Respon Cerdas Perkenalan Diri & Salam Natural
  static AiQueryResponse _handleIntroductionAndGreeting({
    required String lower,
    required List<TransaksiRingkasan> transaksiList,
    required List<PengirimanPabrik> pengirimanList,
    required List<Pengeluaran> pengeluaranList,
  }) {
    final activeTrx = transaksiList.where((t) => !t.isDibatalkan).length;
    
    String introHeading = 'Halo! Saya Asisten Analitik AI Ram Sawit.';
    if (lower.contains('selamat pagi')) {
      introHeading = 'Selamat pagi! Saya Asisten Analitik AI Ram Sawit Anda.';
    } else if (lower.contains('selamat siang')) {
      introHeading = 'Selamat siang! Saya Asisten Analitik AI Ram Sawit Anda.';
    } else if (lower.contains('selamat sore')) {
      introHeading = 'Selamat sore! Saya Asisten Analitik AI Ram Sawit Anda.';
    } else if (lower.contains('selamat malam')) {
      introHeading = 'Selamat malam! Saya Asisten Analitik AI Ram Sawit Anda.';
    }

    return AiQueryResponse(
      text:
          '**$introHeading**\n\n'
          'Saya adalah asisten cerdas yang dirancang khusus untuk membantu pemilik dan pengelola RAM Timbangan Kelapa Sawit dalam mengambil keputusan bisnis berbasis data riil secara akurat dan presisi.\n\n'
          '**Apa saja yang dapat saya bantu?**\n'
          '1. **Kalkulasi & Audit Pembelian TBS:** Cek total tonase dan pengeluaran modal pembelian dari petani pada hari ini, kemarin, atau tanggal tertentu.\n'
          '2. **Analisis Kinerja Pabrik (PKS):** Mengetahui pabrik mana yang memberikan potongan sortasi terendah/tertinggi atau harga netto paling menguntungkan.\n'
          '3. **Rekomendasi Harga Beli Petani:** Memberikan simulasi patokan harga beli aman agar RAM tetap memperoleh margin laba yang sehat setelah memperhitungkan biaya operasional dan sortasi.\n'
          '4. **Laba Rugi & Arus Kas:** Memantau estimasi selisih keuntungan antara penjualan ke PKS dikurangi pembelian dari petani dan pos pengeluaran operasional.\n\n'
          '📊 *Status Data Terkini:* Sistem mendeteksi **$activeTrx transaksi aktif**, **${pengirimanList.length} nota pabrik**, dan **${pengeluaranList.length} pos operasional**.',
      suggestions: [
        'Berapa total pembelian hari ini?',
        'Pabrik mana yang potongannya paling tinggi?',
        'Berapa harga beli TBS rekomendasi besok?',
        'Ringkasan estimasi laba kotor',
      ],
      metrics: {
        'Peran AI': 'Konsultan Bisnis RAM',
        'Data Siap': '$activeTrx Pembelian',
      },
    );
  }

  /// Tampilan Standar Asisten AI
  static AiQueryResponse _handleDefaultAssistantOverview({
    required List<TransaksiRingkasan> transaksiList,
    required List<PengirimanPabrik> pengirimanList,
    required List<Pengeluaran> pengeluaranList,
  }) {
    final activeTrx = transaksiList.where((t) => !t.isDibatalkan).length;

    return AiQueryResponse(
      text:
          'Saya siap membantu menganalisis seluruh data operasional timbangan Anda. '
          'Saat ini sistem terhubung dengan **$activeTrx transaksi pembelian**, **${pengirimanList.length} pengiriman pabrik**, '
          'dan **${pengeluaranList.length} pos pengeluaran**.\n\n'
          'Anda dapat menanyakan misalnya:\n'
          '• *"Berapa total biaya yang dikeluarkan untuk pembelian pada tanggal xx?"*\n'
          '• *"Pabrik mana yang potongannya paling tinggi?"*\n'
          '• *"Berapa harga beli TBS rekomendasi besok?"*\n'
          '• *"Berapa total pengeluaran operasional?"*',
      suggestions: [
        'Berapa total pembelian hari ini?',
        'Pabrik mana yang potongannya paling tinggi?',
        'Berapa harga beli TBS rekomendasi besok?',
      ],
      metrics: {
        'Status Data': 'Live Supabase Terhubung',
        'Engine': 'TBS Deterministic Math',
      },
    );
  }
}
