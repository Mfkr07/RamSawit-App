import 'dart:async';
import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/ai_endpoint_config_service.dart';
import '../../../models/ai_insight.dart';
import '../../../models/jenis_buah.dart';
import '../../../models/pabrik.dart';
import '../../../models/pengeluaran.dart';
import '../../../models/pengiriman_pabrik.dart';
import '../../../models/penjual.dart';
import '../../../models/saldo_ringkasan.dart';
import '../../../models/transaksi.dart';
import 'ai_business_query_service.dart';

/// Callback eksekutor tool ke database lokal / Supabase untuk Agentic Tool Calling
typedef AiToolExecutor = Future<String> Function(String toolName, Map<String, dynamic> arguments);

/// Service Agentic AI untuk memanggil LLM (OpenAI-compatible, 9router, Ollama)
/// dengan kapabilitas Read-Only Data, Context Reasoning, Agentic Tool Calling, dan Pure Text Output.
class AiAgenticService {
  /// Skema definisi Agentic Tools (OpenAI-compatible function definitions)
  static final List<Map<String, dynamic>> _databaseTools = [
    {
      'type': 'function',
      'function': {
        'name': 'query_transaksi_pembelian',
        'description':
            'Mencari data transaksi pembelian TBS petani dari database secara langsung berdasarkan nama petani, nomor nota (misal: TRX-20261015-0003), rentang tanggal (YYYY-MM-DD), status (selesai/dibatalkan), atau limit baris.',
        'parameters': {
          'type': 'object',
          'properties': {
            'nama_petani': {
              'type': 'string',
              'description': 'Nama petani atau kata kunci nama pemasok buah TBS',
            },
            'kode_transaksi': {
              'type': 'string',
              'description': 'Nomor nota transaksi timbangan pembelian',
            },
            'tanggal_mulai': {
              'type': 'string',
              'description': 'Format tanggal awal YYYY-MM-DD (contoh: 2026-10-01)',
            },
            'tanggal_akhir': {
              'type': 'string',
              'description': 'Format tanggal akhir YYYY-MM-DD (contoh: 2026-10-31)',
            },
            'status': {
              'type': 'string',
              'description': 'Status nota: selesai atau dibatalkan',
            },
            'urutan': {
              'type': 'string',
              'enum': ['terbaru', 'terlama'],
              'description': 'Urutan data berdasarkan tanggal transaksi: terbaru (descending) atau terlama (ascending). Gunakan terlama untuk mencari pembelian pertama.',
            },
            'limit': {
              'type': 'integer',
              'description': 'Jumlah maksimal baris data (default 20)',
            },
          },
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'query_pengiriman_pabrik',
        'description':
            'Mencari data pengiriman dan penjualan buah ke pabrik PKS dari database berdasarkan nama pabrik rekanan, kode DO/SPK, rentang tanggal (YYYY-MM-DD), status, atau limit baris.',
        'parameters': {
          'type': 'object',
          'properties': {
            'nama_pabrik': {
              'type': 'string',
              'description': 'Nama pabrik rekanan PKS',
            },
            'kode_pengiriman': {
              'type': 'string',
              'description': 'Nomor DO/SPK pengiriman pabrik',
            },
            'tanggal_mulai': {
              'type': 'string',
              'description': 'Format tanggal awal YYYY-MM-DD',
            },
            'tanggal_akhir': {
              'type': 'string',
              'description': 'Format tanggal akhir YYYY-MM-DD',
            },
            'urutan': {
              'type': 'string',
              'enum': ['terbaru', 'terlama'],
              'description': 'Urutan berdasarkan tanggal pengiriman: terbaru atau terlama.',
            },
            'limit': {
              'type': 'integer',
              'description': 'Jumlah maksimal baris data (default 20)',
            },
          },
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'get_rekap_finansial_periode',
        'description':
            'Mengambil rekapitulasi finansial agregasi resmi database (Omzet penjualan PKS, HPP pembelian petani, margin kotor, beban operasional, dan estimasi laba bersih) untuk rentang tanggal tertentu (YYYY-MM-DD).',
        'parameters': {
          'type': 'object',
          'properties': {
            'tanggal_mulai': {
              'type': 'string',
              'description': 'Format tanggal mulai YYYY-MM-DD (wajib)',
            },
            'tanggal_akhir': {
              'type': 'string',
              'description': 'Format tanggal akhir YYYY-MM-DD (wajib)',
            },
            'label_periode': {
              'type': 'string',
              'description': 'Label nama periode (contoh: 1-15 Oktober 2026)',
            },
          },
          'required': ['tanggal_mulai', 'tanggal_akhir'],
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'query_pengeluaran_operasional',
        'description':
            'Mencari catatan beban biaya operasional ram dari database berdasarkan kategori/jenis biaya, keterangan, atau rentang tanggal (YYYY-MM-DD).',
        'parameters': {
          'type': 'object',
          'properties': {
            'kategori': {
              'type': 'string',
              'description': 'Nama jenis kategori pengeluaran atau kata kunci',
            },
            'tanggal_mulai': {
              'type': 'string',
              'description': 'Format YYYY-MM-DD',
            },
            'tanggal_akhir': {
              'type': 'string',
              'description': 'Format YYYY-MM-DD',
            },
            'limit': {
              'type': 'integer',
              'description': 'Jumlah maksimal baris (default 20)',
            },
          },
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'get_status_saldo_kas',
        'description':
            'Mengambil status saldo modal kas operasional saat ini, modal awal disetor, dan total modal terpakai belanja TBS.',
        'parameters': {
          'type': 'object',
          'properties': {},
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'cari_petani_penjual',
        'description':
            'Mencari daftar profil petani/pemasok sawit dari tabel penjual berdasarkan nama atau kata kunci.',
        'parameters': {
          'type': 'object',
          'properties': {
            'nama': {
              'type': 'string',
              'description': 'Nama petani yang dicari',
            },
          },
        },
      },
    },
  ];

  /// Membersihkan teks dari notasi LaTeX / KaTeX / MathJax ke teks polos yang rapi dan mudah dibaca
  static String sanitizeAiText(String text) {
    var result = text;

    // 1. Konversi operator matematika
    result = result.replaceAll(RegExp(r'\\approx'), '≈');
    result = result.replaceAll(RegExp(r'\\times'), '×');
    result = result.replaceAll(RegExp(r'\\cdot'), '·');
    result = result.replaceAll(RegExp(r'\\le(q)?\b'), '≤');
    result = result.replaceAll(RegExp(r'\\ge(q)?\b'), '≥');
    result = result.replaceAll(RegExp(r'\\pm\b'), '±');
    result = result.replaceAll(RegExp(r'\\div\b'), '÷');
    result = result.replaceAll(RegExp(r'\\sum\b'), 'Σ');
    result = result.replaceAll(RegExp(r'\\quad'), ' ');
    result = result.replaceAll(RegExp(r'\\qquad'), '  ');

    // 2. Konversi pecahan \frac{a}{b} menjadi (a / b)
    result = result.replaceAllMapped(
      RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'),
      (match) => '(${match.group(1)} / ${match.group(2)})',
    );

    // 3. Konversi \text{...} dan \mathrm{...} ke teks polos
    result = result.replaceAllMapped(
      RegExp(r'\\(text|mathrm)\{([^}]+)\}'),
      (m) => m.group(2) ?? '',
    );

    // 4. Konversi \mathbf{...} dan \textbf{...} ke bold markdown **...**
    result = result.replaceAllMapped(
      RegExp(r'\\(mathbf|textbf)\{([^}]+)\}'),
      (m) => '**${m.group(2)}**',
    );

    // 5. Hapus pembungkus display math $$...$$
    result = result.replaceAllMapped(
      RegExp(r'\$\$([^\$]+)\$\$'),
      (match) => match.group(1)?.trim() ?? '',
    );

    // 6. Hapus pembungkus inline math $...$
    result = result.replaceAllMapped(
      RegExp(r'\$([^\$\n]+)\$'),
      (match) => match.group(1)?.trim() ?? '',
    );

    // 7. Bersihkan backslash escape yang tertinggal
    result = result.replaceAll(r'\_', '_');
    result = result.replaceAll(r'\%', '%');

    // 8. Rapikan spasi ganda hasil konversi \text
    result = result.replaceAll(RegExp(r' {2,}'), ' ');

    return result;
  }

  /// Memanggil LLM dengan System Prompt cerdas berisi data operasional riil TBS sawit & memori percakapan
  static Future<AiQueryResponse> processWithAgenticLlm({
    required String query,
    required List<TransaksiRingkasan> transaksiList,
    required List<PengirimanPabrik> pengirimanList,
    required List<Pengeluaran> pengeluaranList,
    required List<Pabrik> pabrikList,
    List<Penjual>? penjualList,
    List<JenisBuah>? jenisBuahList,
    SaldoRingkasan? saldoRingkasan,
    List<AiChatMessage>? chatHistory,
    String? dashboardFinancialContext,
    AiToolExecutor? toolExecutor,
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
        penjualList: penjualList,
        jenisBuahList: jenisBuahList,
        saldoRingkasan: saldoRingkasan,
        dashboardFinancialContext: dashboardFinancialContext,
      );

      final systemPrompt = '''
Anda adalah Asisten Agentic AI Bisnis untuk Sistem Manajemen Operasional Ram Timbangan Kelapa Sawit (TBS) bernama RamSawit AI.
Peran Anda: Membaca seluruh data operasional riil dari semua tabel database, melakukan reasoning dan analisis bisnis yang tajam, serta memberikan output teks yang ramah, profesional, dan solutif bagi Pemilik Bisnis (Owner) atau Kasir Timbangan.

DATA OPERASIONAL LENGKAP DARI SELURUH TABEL DATABASE (READ-ONLY CONTEXT):
$operationalContext

PANDUAN INTERAKSI & REASONING (WAJIB DIPATUHI):
1. KEMAMPUAN MEMBACA SELURUH TABEL DATABASE & DATA MULTI-PERIODE:
   - Anda memiliki akses penuh dan langsung ke SELURUH DATA DARI SEMUA TABEL DATABASE RamSawit yang diinjeksi di atas:
     • Tabel Transaksi & Transaksi Item (Pembelian TBS Petani, tonase kotor/bersih, potongan sortasi, harga beli, subtotal)
     • Tabel Pengiriman Pabrik & Pabrik (DO/SPK penjualan ke PKS, tonase kirim vs diterima, susut, potongan sortasi pabrik, harga jual per kg, total omzet)
     • Tabel Master Penjual / Petani (Daftar petani penyuplai buah)
     • Tabel Master Jenis Buah (Tandan Besar, Tandan Kecil, Berondolan dan porsi persentasenya)
     • Tabel Pengeluaran & Jenis Pengeluaran (Beban operasional timbangan, armada, gaji, dll.)
     • Tabel Saldo Modal & Arus Kas (Modal disetor, pemakaian belanja TBS, dan sisa saldo kas)
     • Rekapitulasi Multi-Bulan & Komparasi Periodik (Data November berjalan, komparasi setara 1 s/d hari ini di bulan Oktober, data Oktober penuh, September, dan historis 3 bulan).
   - JANGAN PERNAH menyatakan bahwa data sistem terbatas, data harga tidak tercatat, atau data historis Oktober/September tidak terurai, karena SELURUH RINCIAN MULTI-BULAN DAN PERBANDINGAN PERIODE SUDAH TERSEDIA SECARA LENGKAP PADA KONTEKS DI ATAS.
   - Jika pengguna meminta perbandingan periode tertentu (contoh: "1-24 Oktober dibandingkan 1-24 November"), bandingkan data dari bagian 'B. BULAN LALU — PERIODE SETARA' dengan 'A. BULAN BERJALAN' secara presisi angka per angka (Omzet, HPP Beli TBS, Tonase, Margin, Beban Ops, dan Laba Bersih) beserta persentase kenaikan/penurunannya.

2. ATURAN FORMAT PENULISAN (SANGAT PENTING - ANTI-LATEX):
   - DILARANG KERAS menggunakan notasi LaTeX / MathJax / KaTeX (seperti '\$', '\$\$', '\\text{...}', '\\mathbf{...}', '\\approx', '\\times', '\\frac{...}{...}', dll.).
   - Seluruh teks, angka mata uang Rupiah, berat kg, persentase, dan rumus hitungan WAJIB ditulis dalam format TEKS BIASA (Plain Text) yang rapi.
   - Format nominal uang: "Rp 1.500.000" (gunakan titik sebagai pemisah ribuan).
   - Format perhitungan: "Rp 2.000.000 - Rp 500.000 = Rp 1.500.000" atau "Rp 1.000.000 / 30 hari ≈ Rp 33.333 / hari".
   - Format perkalian: gunakan tanda silang biasa "×" atau "x", bukan "\\times".
   - Format perkiraan: gunakan tanda "≈" atau "~", bukan "\\approx".

3. KEMAMPUAN AGENTIC DATABASE TOOLS (FUNCTION CALLING):
   - Anda dibekali fungsi/tools untuk membaca database secara langsung:
     • query_transaksi_pembelian: untuk mencari nota atau setoran petani tertentu (bisa filter nama, nomor nota, rentang tanggal).
     • query_pengiriman_pabrik: untuk mencari DO/SPK penjualan ke PKS rekanan.
     • get_rekap_finansial_periode: untuk mengambil rekap omzet, HPP, margin, biaya ops, dan laba bersih rentang tanggal tertentu.
     • query_pengeluaran_operasional: untuk mencari beban operasional tertentu.
     • get_status_saldo_kas: untuk melihat kondisi kas modal terkini.
     • cari_petani_penjual: untuk mencari data profil petani.
   - Jika pengguna menanyakan data spesifik (misal nama petani, nota tertentu, tanggal tertentu yang butuh rincian), GUNAKAN tool yang sesuai untuk membaca database riil sebelum memberikan jawaban!

4. KONSULTASI RAMAH & PROFESIONAL:
   - Jika pengguna menyapa (halo, hai, selamat pagi, siapa kamu), jawab secara ramah, perkenalkan diri Anda sebagai Asisten AI RamSawit, dan tawarkan bantuan analitik berdasarkan status operasional terkini.
   - Gunakan Bahasa Indonesia yang lugas, komunikatif, dan mudah dipahami oleh pemilik usaha sawit.
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
      final messagesPayload = <Map<String, dynamic>>[
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

      final modelName = config.modelName.trim().isNotEmpty
          ? config.modelName.trim()
          : 'ag/gemini-3.8-flash-medium';

      int step = 0;
      const maxSteps = 4;
      int lastStatusCode = 200;

      while (step < maxSteps) {
        step++;
        final requestBodyMap = <String, dynamic>{
          'model': modelName,
          'messages': messagesPayload,
          'temperature': 0.2,
          'stream': false,
        };

        if (toolExecutor != null && step < maxSteps) {
          requestBodyMap['tools'] = _databaseTools;
          requestBodyMap['tool_choice'] = 'auto';
        }

        var response = await http
            .post(Uri.parse(endpoint), headers: headers, body: jsonEncode(requestBodyMap))
            .timeout(const Duration(seconds: 35));

        lastStatusCode = response.statusCode;

        // Jika endpoint mengembalikan HTTP 400 di turn 1 (misal proxy tidak support tools parameter), retry tanpa tools
        if (step == 1 && response.statusCode == 400 && requestBodyMap.containsKey('tools')) {
          requestBodyMap.remove('tools');
          requestBodyMap.remove('tool_choice');
          response = await http
              .post(Uri.parse(endpoint), headers: headers, body: jsonEncode(requestBodyMap))
              .timeout(const Duration(seconds: 35));
          lastStatusCode = response.statusCode;
        }

        if (response.statusCode != 200) {
          break;
        }

        final Map<String, dynamic> data = jsonDecode(response.body);
        final choices = data['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) {
          break;
        }

        final choiceMsg = choices[0]['message'] as Map<String, dynamic>?;
        final toolCalls = choiceMsg?['tool_calls'] as List<dynamic>?;

        // JIKA LLM MEMANGGIL ALAT DATABASE (AGENTIC TOOL CALLING):
        if (toolCalls != null && toolCalls.isNotEmpty && toolExecutor != null) {
          messagesPayload.add({
            'role': 'assistant',
            'content': choiceMsg?['content'] ?? '',
            'tool_calls': toolCalls,
          });

          for (final tc in toolCalls) {
            final toolCallId = tc['id'] as String? ?? 'call_${DateTime.now().millisecondsSinceEpoch}';
            final fn = tc['function'] as Map<String, dynamic>? ?? {};
            final toolName = fn['name'] as String? ?? '';
            final argsRaw = fn['arguments'];
            Map<String, dynamic> args = {};
            if (argsRaw is String && argsRaw.trim().isNotEmpty) {
              try {
                args = jsonDecode(argsRaw) as Map<String, dynamic>;
              } catch (_) {}
            } else if (argsRaw is Map<String, dynamic>) {
              args = argsRaw;
            }

            final toolResultJson = await toolExecutor(toolName, args);

            messagesPayload.add({
              'role': 'tool',
              'tool_call_id': toolCallId,
              'content': toolResultJson,
            });
          }
          // Lanjut ke langkah penalaran berikutnya dengan hasil tool
          continue;
        }

        // JIKA LLM MENGHASILKAN TEKS JAWABAN AKHIR:
        final rawContent = choiceMsg?['content'] as String? ?? choiceMsg?['reasoning_content'] as String? ?? '';
        if (rawContent.trim().isNotEmpty) {
          final cleanedText = sanitizeAiText(rawContent.trim());
          return AiQueryResponse(
            text: cleanedText,
            suggestions: [
              'Berapa laba bersih periode ini?',
              'Pabrik mana yang potongan sortasinya paling rendah?',
              'Rekomendasi harga beli TBS ke petani hari ini?',
            ],
          );
        }
      }

      // Jika response gagal/error kode HTTP selain 200 atau gagal menghasilkan teks setelah loop tools
      final localRes = await AiBusinessQueryService.processQuery(
        query: query,
        transaksiList: transaksiList,
        pengirimanList: pengirimanList,
        pengeluaranList: pengeluaranList,
        pabrikList: pabrikList,
      );

      return AiQueryResponse(
        text: '${localRes.text}\n\n> *⚠️ Catatan Sistem: Layanan AI eksternal merespons dengan kode $lastStatusCode. Menampilkan analisis aturan bisnis cadangan lokal.*',
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
    List<Penjual>? penjualList,
    List<JenisBuah>? jenisBuahList,
    SaldoRingkasan? saldoRingkasan,
    String? dashboardFinancialContext,
  }) {
    final sb = StringBuffer();

    // 0. Ringkasan Eksekutif & Finansial Resmi (Dashboard)
    if (dashboardFinancialContext != null &&
        dashboardFinancialContext.trim().isNotEmpty) {
      sb.writeln(dashboardFinancialContext.trim());
      sb.writeln('');
    }

    // 1. Data Tabel Saldo Kas & Modal
    if (saldoRingkasan != null) {
      sb.writeln('=== TABEL SALDO MODAL & KAS OPERASIONAL (saldo_modal, mutasi_saldo) ===');
      sb.writeln('Modal Awal / Total Top Up Masuk: Rp ${saldoRingkasan.totalTopup}');
      sb.writeln('Total Pemakaian Belanja TBS Petani: Rp ${saldoRingkasan.totalPemakaian}');
      sb.writeln('Sisa Saldo Kas Operasional Saat Ini: Rp ${saldoRingkasan.sisaSaldo}');
      sb.writeln('');
    }

    // 2. Data Tabel Master Penjual / Petani
    if (penjualList != null && penjualList.isNotEmpty) {
      sb.writeln('=== TABEL MASTER PENJUAL / PETANI SAWIT (penjual) ===');
      sb.writeln('Total Petani Terdaftar: ${penjualList.length} orang');
      final namaPetani = penjualList.take(25).map((p) => '${p.nama} (${p.isActive ? "Aktif" : "Nonaktif"})').join(', ');
      sb.writeln('Daftar Petani Pemasok: $namaPetani');
      sb.writeln('');
    }

    // 3. Data Tabel Master Jenis Buah TBS
    if (jenisBuahList != null && jenisBuahList.isNotEmpty) {
      sb.writeln('=== TABEL MASTER JENIS BUAH KELAPA SAWIT (jenis_buah) ===');
      final jbStr = jenisBuahList.map((j) => '${j.nama} (${j.kode})').join(', ');
      sb.writeln('Jenis TBS Diterima: $jbStr');
      sb.writeln('');
    }

    // 4. Data Transaksi Pembelian TBS
    sb.writeln('=== TABEL TRANSAKSI PEMBELIAN TBS DARI PETANI (transaksi, transaksi_item) ===');
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
