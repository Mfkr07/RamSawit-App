import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/ai_endpoint_config_service.dart';
import '../../../models/pabrik.dart';
import '../../../models/pengeluaran.dart';
import '../../../models/pengiriman_pabrik.dart';
import '../../../models/transaksi.dart';
import 'ai_business_query_service.dart';

/// Service Agentic AI untuk memanggil LLM (OpenAI-compatible, 9router, Ollama)
/// dengan kapabilitas Read-Only Data, Context Reasoning, dan Pure Text Output.
class AiAgenticService {
  /// Memanggil LLM dengan System Prompt cerdas berisi data operasional riil TBS sawit
  static Future<AiQueryResponse> processWithAgenticLlm({
    required String query,
    required List<TransaksiRingkasan> transaksiList,
    required List<PengirimanPabrik> pengirimanList,
    required List<Pengeluaran> pengeluaranList,
    required List<Pabrik> pabrikList,
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
      );

      final systemPrompt = '''
Anda adalah Asisten Agentic AI Bisnis untuk Sistem Manajemen Operasional Ram Timbangan Kelapa Sawit (TBS).
Peran Anda: Membaca data operasional riil, melakukan reasoning/analisis bisnis yang tajam, dan memberikan output teks yang ramah, profesional, serta solutif bagi Pemilik Bisnis (Owner) atau Kasir.

DATA OPERASIONAL SAAT INI (READ-ONLY CONTEXT):
$operationalContext

PANDUAN INTERAKSI & REASONING:
1. Anda memiliki akses penuh membaca data di atas. Gunakan angka riil tersebut untuk menjawab dan berargumentasi.
2. Jika pengguna menyapa (halo, hai, selamat pagi, siapa kamu), jawab secara ramah, perkenalkan diri Anda sebagai AI Bisnis Ram Sawit, dan rangkumkan sekilas status operasional terkini.
3. Berikan analisis tren, margin keuntungan, efisiensi sortasi pabrik, atau anomali jika relevan dengan pertanyaan.
4. Gunakan Bahasa Indonesia yang lugas, profesional, dan mudah dipahami.
5. Format teks menggunakan poin-poin tebal dan nominal Rupiah / Kg yang rapi.
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

      final body = jsonEncode({
        'model': config.modelName.trim().isNotEmpty
            ? config.modelName.trim()
            : 'ag/gemini-3.8-flash-medium',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': query},
        ],
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

      // Jika response gagal/error kode HTTP selain 200, fallback ke internal processor
      return await AiBusinessQueryService.processQuery(
        query: query,
        transaksiList: transaksiList,
        pengirimanList: pengirimanList,
        pengeluaranList: pengeluaranList,
        pabrikList: pabrikList,
      );
    } catch (_) {
      // Jika terjadi kendala jaringan (timeout, offline, endpoint salah), fallback ke internal processor
      return await AiBusinessQueryService.processQuery(
        query: query,
        transaksiList: transaksiList,
        pengirimanList: pengirimanList,
        pengeluaranList: pengeluaranList,
        pabrikList: pabrikList,
      );
    }
  }

  /// Membuat representasi teks ringkas dari dataset aktif untuk System Prompt
  static String _buildOperationalContext({
    required List<TransaksiRingkasan> transaksiList,
    required List<PengirimanPabrik> pengirimanList,
    required List<Pengeluaran> pengeluaranList,
    required List<Pabrik> pabrikList,
  }) {
    final sb = StringBuffer();

    // 1. Data Transaksi Pembelian TBS
    sb.writeln('=== 1. DATA PEMBELIAN TBS DARI PETANI/PENJUAL ===');
    sb.writeln('Total Transaksi Tercatat: ${transaksiList.length}');
    double totalKgBeli = 0;
    double totalRpBeli = 0;
    for (final t in transaksiList.take(30)) {
      totalKgBeli += t.totalBeratBersihKg.toDouble();
      totalRpBeli += t.totalNilai.toDouble();
      sb.writeln(
          '- Nota: ${t.kodeTransaksi} | Petani: ${t.namaPenjual} | Berat: ${t.totalBeratBersihKg} kg | Bayar: Rp ${t.totalNilai} | Status: ${t.status} | Tanggal: ${t.tanggalTransaksi}');
    }
    sb.writeln('Total Berat Bersih Beli (Sample 30): $totalKgBeli kg');
    sb.writeln('Total Biaya Pembelian TBS (Sample 30): Rp $totalRpBeli\n');

    // 2. Data Pengiriman Penjualan ke Pabrik PKS
    sb.writeln('=== 2. DATA PENGIRIMAN & PENJUALAN KE PABRIK (PKS) ===');
    sb.writeln('Total Pengiriman Tercatat: ${pengirimanList.length}');
    for (final k in pengirimanList.take(20)) {
      sb.writeln(
          '- DO/SPK: ${k.kodePengiriman} | Pabrik ID: ${k.pabrikId} | Sopir: ${k.namaSopir} (${k.platNomor}) | Berat Kirim: ${k.beratDikirimKg} kg | Berat Diterima PKS: ${k.beratDiterimaKg ?? 0} kg | Potongan Sortasi: ${k.persentasePotonganPabrik ?? 0}% | Status: ${k.status}');
    }
    sb.writeln('');

    // 3. Data Master Pabrik
    sb.writeln('=== 3. DATA MASTER PABRIK (PKS) REKANAN ===');
    for (final p in pabrikList) {
      sb.writeln(
          '- Pabrik: ${p.nama} | Alamat: ${p.alamat ?? '-'} | Kontak: ${p.kontak ?? '-'} | Aktif: ${p.isActive}');
    }
    sb.writeln('');

    // 4. Data Biaya Operasional Ram
    sb.writeln('=== 4. DATA PENGELUARAN BIAYA OPERASIONAL RAM ===');
    sb.writeln('Total Biaya Operasional Tercatat: ${pengeluaranList.length}');
    double totalBiayaOps = 0;
    for (final o in pengeluaranList.take(20)) {
      totalBiayaOps += o.nominal.toDouble();
      sb.writeln(
          '- Biaya: ${o.jenisPengeluaranNama ?? 'Operasional'} | Keterangan: ${o.keterangan ?? '-'} | Nominal: Rp ${o.nominal} | Tanggal: ${o.tanggalPengeluaran}');
    }
    sb.writeln('Total Biaya Operasional (Sample 20): Rp $totalBiayaOps');

    return sb.toString();
  }
}
