import 'dart:async';
import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/ai_endpoint_config_service.dart';
import '../../../models/ai_insight.dart';
import '../../../models/pabrik.dart';
import '../../../models/pengeluaran.dart';
import '../../../models/pengiriman_pabrik.dart';
import '../../../models/transaksi.dart';
import 'ai_business_query_service.dart';

/// Service Agentic AI untuk memanggil LLM (OpenAI-compatible, 9router, Ollama)
/// dengan kapabilitas Read-Only Data, Context Reasoning, dan Pure Text Output.
class AiAgenticService {
  /// Memanggil LLM dengan System Prompt cerdas berisi data operasional riil TBS sawit & memori percakapan
  static Future<AiQueryResponse> processWithAgenticLlm({
    required String query,
    required List<TransaksiRingkasan> transaksiList,
    required List<PengirimanPabrik> pengirimanList,
    required List<Pengeluaran> pengeluaranList,
    required List<Pabrik> pabrikList,
    List<AiChatMessage>? chatHistory,
    String? dashboardFinancialContext,
  }) async {
    final config = await AiEndpointConfigService.loadConfig();

    if (!config.isEnabled || !config.hasValidUrl) {
      // Jika AI external nonaktif, fallback ke mesin query deterministik lokal
      return AiBusinessQueryService.processQuery(
        query: query,
        transaksiList: transaksiList,
        pengirimanList: pengirimanList,
        pengeluaranList: pengeluaranList,
        pabrikList: pabrikList,
      );
    }

    try {
      // 1. Siapkan ringkasan data operasional riil (Read-Only context injection)
      final operationalContext = _buildOperationalContext(
        transaksiList: transaksiList,
        pengirimanList: pengirimanList,
        pengeluaranList: pengeluaranList,
        pabrikList: pabrikList,
        dashboardFinancialContext: dashboardFinancialContext,
      );

      final systemPrompt = '''
Anda adalah Asisten Agentic AI Bisnis untuk Sistem Manajemen Operasional Ram Timbangan Kelapa Sawit (TBS) bernama RamSawit AI.
Peran Anda: Membaca data operasional riil, melakukan reasoning dan analisis bisnis yang tajam, serta memberikan output teks yang ramah, profesional, dan solutif bagi Pemilik Bisnis (Owner) atau Kasir Timbangan.

DATA OPERASIONAL SAAT INI (READ-ONLY CONTEXT):
$operationalContext

PANDUAN INTERAKSI & REASONING:
1. AKURASI ANGKA & DATA OPERASIONAL:
   - Anda memiliki akses penuh ke ringkasan finansial resmi dan rincian transaksi di atas, termasuk Omzet Penjualan ke Pabrik PKS, Pembelian TBS dari Petani (HPP TBS), Biaya Operasional, Margin Kotor, dan Laba Bersih.
   - Jangan pernah menyatakan bahwa harga jual pabrik atau omzet tidak tercatat, karena rincian DO/SPK di atas sudah memuat harga jual per kg dan total nilai rupiah penjualan ke pabrik secara detail.
   - Jika ditanya mengenai pendapatan, laba kotor, atau laba bersih (misal 1 bulan ini atau rentang waktu tertentu), rujuk langsung data agregasi pada RINGKASAN FINANSIAL RESMI dan rincikan perhitungannya secara transparan.
2. JELASKAN SUMBER DATA:
   - Jika ditanya mengenai sumber data, jelaskan bahwa data bersumber langsung dari catatan nota timbangan pembelian petani, slip penerimaan dan klaim pembayaran pabrik PKS (termasuk audit potongan sortasi & susut), serta catatan pengeluaran operasional di sistem RamSawit.
3. KONSULTASI RAMAH:
   - Jika pengguna menyapa (halo, hai, selamat pagi, siapa kamu), jawab secara ramah, perkenalkan diri Anda sebagai Asisten AI RamSawit, dan tawarkan bantuan analitik berdasarkan status operasional terkini.
4. ANALISIS MENDALAM:
   - Berikan analisis tren, margin keuntungan, efisiensi sortasi pabrik, atau anomali jika relevan dengan pertanyaan.
5. FORMAT & GAYA BAHASA:
   - Gunakan Bahasa Indonesia yang lugas, profesional, dan mudah dipahami.
   - Format teks menggunakan poin-poin tebal (**teks**) dan format nominal Rupiah (**Rp ...**) / Kg (**... kg**) yang rapi.
''';

      final cleanBaseUrl = config.baseUrl.endsWith('/')
          ? config.baseUrl.substring(0, config.baseUrl.length - 1)
          : config.baseUrl;
      final endpoint = '$cleanBaseUrl/chat/completions';

      final headers = {
        'Content-Type': 'application/json',
        if (config.apiKey.trim().isNotEmpty)
          'Authorization': 'Bearer ${config.apiKey.trim()}',
      };

      // Siapkan payload percakapan multi-turn
      final messagesPayload = <Map<String, String>>[
        {'role': 'system', 'content': systemPrompt},
      ];

      // Sisipkan riwayat percakapan sebelumnya jika ada (hingga 6 pesan terakhir)
      if (chatHistory != null && chatHistory.isNotEmpty) {
        final recentHistory = chatHistory.length > 6
            ? chatHistory.sublist(chatHistory.length - 6)
            : chatHistory;
        for (final msg in recentHistory) {
          messagesPayload.add({
            'role': msg.isUser ? 'user' : 'assistant',
            'content': msg.text,
          });
        }
      }

      messagesPayload.add({'role': 'user', 'content': query});

      final body = jsonEncode({
        'model': config.modelName.trim().isNotEmpty
            ? config.modelName.trim()
            : 'ag/gemini-3.8-flash-medium',
        'messages': messagesPayload,
        'temperature': 0.3,
        'stream': false,
      });

      final response = await http
          .post(Uri.parse(endpoint), headers: headers, body: body)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String? ?? '';
          if (content.trim().isNotEmpty) {
            return AiQueryResponse(
              text: content.trim(),
              suggestions: [
                'Berapa laba bersih periode ini?',
                'Pabrik mana yang potongan sortasinya paling rendah?',
                'Rekomendasi harga beli TBS ke petani hari ini?',
              ],
            );
          }
        }
      }

      // Jika response gagal/error kode HTTP selain 200, fallback ke internal processor dengan catatan transparan
      final localRes = await AiBusinessQueryService.processQuery(
        query: query,
        transaksiList: transaksiList,
        pengirimanList: pengirimanList,
        pengeluaranList: pengeluaranList,
        pabrikList: pabrikList,
      );

      return AiQueryResponse(
        text: '${localRes.text}\n\n> *⚠️ Catatan Sistem: Layanan AI eksternal merespons dengan kode ${response.statusCode}. Menampilkan analisis aturan bisnis cadangan lokal.*',
        suggestions: localRes.suggestions,
        metrics: localRes.metrics,
      );
    } catch (e) {
      // Jika terjadi kendala jaringan (timeout, offline, endpoint salah), fallback ke internal processor
      final localRes = await AiBusinessQueryService.processQuery(
        query: query,
        transaksiList: transaksiList,
        pengirimanList: pengirimanList,
        pengeluaranList: pengeluaranList,
        pabrikList: pabrikList,
      );

      final isLocalhost = config.baseUrl.contains('localhost') || config.baseUrl.contains('127.0.0.1');
      final mobileTip = isLocalhost
          ? '\n\n> *💡 Catatan: Aplikasi dijalankan pada perangkat Android / jaringan eksternal sehingga alamat `localhost` tidak dapat dijangkau. Buka Pengaturan AI (ikon ⚙️) dan gunakan provider Cloud resmi seperti Google Gemini atau Groq dengan API Key gratis.*'
          : '';

      return AiQueryResponse(
        text: '${localRes.text}\n\n> *⚠️ Catatan Sistem: Tidak dapat menghubungi endpoint AI ($e). Menampilkan analisis cadangan lokal.*$mobileTip',
        suggestions: localRes.suggestions,
        metrics: localRes.metrics,
      );
    }
  }

  /// Membuat representasi teks ringkas dari dataset aktif untuk System Prompt
  static String _buildOperationalContext({
    required List<TransaksiRingkasan> transaksiList,
    required List<PengirimanPabrik> pengirimanList,
    required List<Pengeluaran> pengeluaranList,
    required List<Pabrik> pabrikList,
    String? dashboardFinancialContext,
  }) {
    final sb = StringBuffer();

    // 0. Ringkasan Eksekutif & Finansial Resmi (Dashboard)
    if (dashboardFinancialContext != null &&
        dashboardFinancialContext.trim().isNotEmpty) {
      sb.writeln(dashboardFinancialContext.trim());
      sb.writeln('');
    }

    // 1. Data Transaksi Pembelian TBS
    sb.writeln('=== 1. DATA PEMBELIAN TBS DARI PETANI/PENJUAL ===');
    sb.writeln('Total Transaksi di Database: ${transaksiList.length}');
    Decimal totalKgBeliSemua = Decimal.zero;
    Decimal totalRpBeliSemua = Decimal.zero;
    DateTime? tglTerlama;
    DateTime? tglTerbaru;

    for (final t in transaksiList) {
      totalKgBeliSemua += t.totalBeratBersihKg;
      totalRpBeliSemua += t.totalNilai;
      if (tglTerlama == null || t.tanggalTransaksi.isBefore(tglTerlama)) {
        tglTerlama = t.tanggalTransaksi;
      }
      if (tglTerbaru == null || t.tanggalTransaksi.isAfter(tglTerbaru)) {
        tglTerbaru = t.tanggalTransaksi;
      }
    }

    final avgHargaBeli = totalKgBeliSemua > Decimal.zero
        ? (totalRpBeliSemua / totalKgBeliSemua).toDecimal(scaleOnInfinitePrecision: 2)
        : Decimal.zero;

    sb.writeln('Total Akumulasi Tonase Beli Petani: $totalKgBeliSemua kg');
    sb.writeln('Total Akumulasi Beban Pembelian (HPP TBS): Rp $totalRpBeliSemua');
    sb.writeln('Rata-rata Harga Beli Petani: Rp $avgHargaBeli /kg');
    if (tglTerlama != null && tglTerbaru != null) {
      sb.writeln(
          'Rentang Waktu Database: ${tglTerlama.toIso8601String().split("T").first} s/d ${tglTerbaru.toIso8601String().split("T").first}');
    }
    sb.writeln('\nRincian Sampel 30 Transaksi Pembelian Terbaru:');
    for (final t in transaksiList.take(30)) {
      sb.writeln(
          '- Nota: ${t.kodeTransaksi} | Petani: ${t.namaPenjual} | Berat Bersih: ${t.totalBeratBersihKg} kg | Bayar: Rp ${t.totalNilai} | Status: ${t.status} | Tanggal: ${t.tanggalTransaksi.toIso8601String().split("T").first}');
    }
    sb.writeln('');

    // 2. Data Pengiriman Penjualan ke Pabrik PKS
    sb.writeln('=== 2. DATA PENGIRIMAN & PENJUALAN KE PABRIK (PKS) ===');
    sb.writeln('Total Pengiriman Tercatat: ${pengirimanList.length}');
    Decimal totalKgKirimSemua = Decimal.zero;
    Decimal totalKgBersihPksSemua = Decimal.zero;
    Decimal totalRpJualSemua = Decimal.zero;
    int selesaiCount = 0;

    for (final k in pengirimanList) {
      totalKgKirimSemua += k.beratDikirimKg;
      final bersih = k.beratBersihKg ?? k.beratDiterimaKg ?? Decimal.zero;
      totalKgBersihPksSemua += bersih;
      final nilaiJual = k.totalNilaiJual ?? Decimal.zero;
      totalRpJualSemua += nilaiJual;
      if (k.isSelesai) selesaiCount++;
    }

    final avgHargaJualPks = totalKgBersihPksSemua > Decimal.zero && totalRpJualSemua > Decimal.zero
        ? (totalRpJualSemua / totalKgBersihPksSemua).toDecimal(scaleOnInfinitePrecision: 2)
        : Decimal.zero;

    sb.writeln('Total Pengiriman Selesai: $selesaiCount dari ${pengirimanList.length} pengiriman');
    sb.writeln('Total Tonase Kirim: $totalKgKirimSemua kg');
    sb.writeln('Total Tonase Bersih Diterima PKS: $totalKgBersihPksSemua kg');
    sb.writeln('Total Nilai Omzet Penjualan ke Pabrik: Rp $totalRpJualSemua');
    if (avgHargaJualPks > Decimal.zero) {
      sb.writeln('Rata-rata Harga Jual ke Pabrik PKS: Rp $avgHargaJualPks /kg');
    }
    sb.writeln('\nRincian Lengkap Pengiriman Pabrik (Termasuk Harga Jual & Nilai Jual):');
    for (final k in pengirimanList.take(30)) {
      final pabrikName = k.pabrik?.nama ?? k.pabrikId;
      final tgl = k.tanggalKirim.toIso8601String().split('T').first;
      final hargaStr = k.hargaJualPerKg != null ? 'Rp ${k.hargaJualPerKg}/kg' : 'Belum diisi';
      final nilaiStr = k.totalNilaiJual != null ? 'Rp ${k.totalNilaiJual}' : 'Rp 0';
      sb.writeln(
          '- DO/SPK: ${k.kodePengiriman} | Pabrik: $pabrikName | Tanggal: $tgl | Kirim: ${k.beratDikirimKg} kg | Diterima PKS: ${k.beratDiterimaKg ?? 0} kg | Sortasi: ${k.persentasePotonganPabrik ?? 0}% | Bersih PKS: ${k.beratBersihKg ?? 0} kg | Harga Jual PKS: $hargaStr | Total Nilai Jual: $nilaiStr | Status: ${k.status}');
    }
    sb.writeln('');

    // 3. Data Master Pabrik Rekanan
    sb.writeln('=== 3. DATA MASTER PABRIK (PKS) REKANAN ===');
    for (final p in pabrikList) {
      sb.writeln(
          '- Pabrik: ${p.nama} | Alamat: ${p.alamat ?? '-'} | Kontak: ${p.kontak ?? '-'} | Aktif: ${p.isActive}');
    }
    sb.writeln('');

    // 4. Data Biaya Operasional Ram
    sb.writeln('=== 4. DATA PENGELUARAN BIAYA OPERASIONAL RAM ===');
    sb.writeln('Total Pengeluaran Tercatat: ${pengeluaranList.length}');
    Decimal totalBiayaOpsSemua = Decimal.zero;
    for (final o in pengeluaranList) {
      totalBiayaOpsSemua += o.nominal;
    }
    sb.writeln('Total Akumulasi Biaya Operasional: Rp $totalBiayaOpsSemua\n');
    sb.writeln('Sampel 25 Pengeluaran Terbaru:');
    for (final o in pengeluaranList.take(25)) {
      final tgl = o.tanggalPengeluaran.toIso8601String().split('T').first;
      sb.writeln(
          '- Biaya: ${o.jenisPengeluaranNama ?? 'Operasional'} | Keterangan: ${o.keterangan ?? '-'} | Nominal: Rp ${o.nominal} | Tanggal: $tgl');
    }

    return sb.toString();
  }
}
