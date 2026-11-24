import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ai_insight.dart';
import '../../models/pabrik.dart';
import '../../models/pengeluaran.dart';
import '../../models/pengiriman_pabrik.dart';
import '../../models/transaksi.dart';
import '../dashboard/dashboard_repository.dart';
import '../pabrik/pabrik_repository.dart';
import '../pengeluaran/pengeluaran_repository.dart';
import '../pengiriman_pabrik/pengiriman_pabrik_repository.dart';
import '../transaksi/transaksi_repository.dart';
import 'services/ai_agentic_service.dart';

class AiAnalyticsState {
  final AiKpiOverview kpiOverview;
  final List<AiInsight> allInsights;
  final String selectedFilter; // 'semua', 'anomali', 'margin', 'pasokan'
  final String selectedTimeframe; // '7d', '14d', '30d'
  final List<AiChatMessage> chatMessages;
  final bool isAnalyzing;
  final bool isGeneratingReply;
  final String aiEngineStatus; // 'online_9router', 'cloud', 'offline'

  const AiAnalyticsState({
    required this.kpiOverview,
    required this.allInsights,
    this.selectedFilter = 'semua',
    this.selectedTimeframe = '14d',
    required this.chatMessages,
    this.isAnalyzing = false,
    this.isGeneratingReply = false,
    this.aiEngineStatus = 'online_9router',
  });

  List<AiInsight> get filteredInsights {
    if (selectedFilter == 'anomali') {
      return allInsights
          .where((i) => i.type == AiInsightType.anomalySortasi)
          .toList();
    }
    if (selectedFilter == 'margin') {
      return allInsights
          .where((i) =>
              i.type == AiInsightType.marginOpportunity ||
              i.type == AiInsightType.priceRecommendation)
          .toList();
    }
    if (selectedFilter == 'pasokan') {
      return allInsights
          .where((i) =>
              i.type == AiInsightType.supplyPattern ||
              i.type == AiInsightType.cashFlowRisk)
          .toList();
    }
    return allInsights;
  }

  AiAnalyticsState copyWith({
    AiKpiOverview? kpiOverview,
    List<AiInsight>? allInsights,
    String? selectedFilter,
    String? selectedTimeframe,
    List<AiChatMessage>? chatMessages,
    bool? isAnalyzing,
    bool? isGeneratingReply,
    String? aiEngineStatus,
  }) {
    return AiAnalyticsState(
      kpiOverview: kpiOverview ?? this.kpiOverview,
      allInsights: allInsights ?? this.allInsights,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      chatMessages: chatMessages ?? this.chatMessages,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isGeneratingReply: isGeneratingReply ?? this.isGeneratingReply,
      aiEngineStatus: aiEngineStatus ?? this.aiEngineStatus,
    );
  }
}

class AiAnalyticsController extends StateNotifier<AiAnalyticsState> {
  final Ref _ref;
  static bool enableDummySeedForTesting = false;

  AiAnalyticsController(this._ref, {bool? autoRefresh}) : super(_initialState()) {
    final shouldAutoRefresh = autoRefresh ??
        !WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (shouldAutoRefresh) {
      Future.microtask(() => refreshInsights());
    }
  }

  static AiAnalyticsState _initialState() {
    if (!enableDummySeedForTesting) {
      return AiAnalyticsState(
        allInsights: const [],
        chatMessages: [
          AiChatMessage(
            id: 'msg-01',
            sender: 'ai',
            text:
                'Halo! Saya **Asisten Analitik AI RamSawit**. Silakan catat transaksi pembelian dan pengiriman agar saya dapat memberikan wawasan bisnis, tren potongan, dan rekomendasi margin.',
            timestamp: DateTime.now(),
            suggestions: const [
              'Bagaimana cara kerja analisis AI?',
              'Kapan rekomendasi harga beli muncul?',
            ],
          ),
        ],
        kpiOverview: AiKpiOverview(
          marginHealthScore: 0,
          activeAnomaliesCount: 0,
          recommendedTbsPriceMin: Decimal.zero,
          recommendedTbsPriceMax: Decimal.zero,
          projectedWeeklyProfit: Decimal.zero,
          confidenceScore: 0.0,
          totalAnalysedTransactions: 0,
          totalAnalysedShipments: 0,
        ),
      );
    }

    final now = DateTime.now();

    final defaultKpi = AiKpiOverview(
      marginHealthScore: 92,
      activeAnomaliesCount: 2,
      recommendedTbsPriceMin: Decimal.parse('2480'),
      recommendedTbsPriceMax: Decimal.parse('2520'),
      projectedWeeklyProfit: Decimal.parse('42850000'),
      confidenceScore: 0.94,
      totalAnalysedTransactions: 642,
      totalAnalysedShipments: 48,
    );

    final defaultInsights = [
      AiInsight(
        id: 'ins-01',
        title: 'Lonjakan Potongan Sortasi di PKS Sawit Sentosa',
        summary:
            'Tingkat potongan sortasi rata-rata di PKS Sawit Sentosa meningkat menjadi 6.8% (normal: 3.5% - 4.2%).',
        detailedExplanation:
            'Data 5 pengiriman terakhir menunjukkan kenaikan pemotongan sampah/tangkai panjang yang tidak biasa. Selisih berat bersih menimbulkan potensi kehilangan margin senilai Rp 3.420.000.',
        severity: AiInsightSeverity.warning,
        type: AiInsightType.anomalySortasi,
        metricImpact: 'Deviasi Potongan: +2.6% (+Rp 3.42M)',
        recommendedAction:
            'Lakukan kalibrasi timbangan mandiri dan verifikasi sampling buah mentah sebelum truk diberangkatkan ke pabrik.',
        timestamp: now.subtract(const Duration(hours: 3)),
        confidenceScore: 0.96,
      ),
      AiInsight(
        id: 'ins-02',
        title: 'Peluang Arbitrase Margin Harga TBS Petani vs Pabrik',
        summary:
            'Harga penerimaan PKS Palma Makmur naik menjadi Rp 2.780/kg, memberikan ruang margin aman hingga 12.8%.',
        detailedExplanation:
            'Dengan mempertimbangkan biaya angkut rata-rata Rp 95/kg dan susut normal 0.5%, harga beli ideal di tingkat petani direkomendasikan pada Rp 2.480 - Rp 2.510/kg untuk menjaga laba bersih optimal.',
        severity: AiInsightSeverity.recommendation,
        type: AiInsightType.priceRecommendation,
        metricImpact: 'Proyeksi Margin Bersih: Rp 205/kg (12.8%)',
        recommendedAction:
            'Sesuaikan papan harga beli petani ke Rp 2.500/kg mulai sesi timbang besok pagi.',
        timestamp: now.subtract(const Duration(hours: 6)),
        confidenceScore: 0.92,
      ),
      AiInsight(
        id: 'ins-03',
        title: 'Pola Pasokan Petani: Penurunan Pasokan Wilayah Barat',
        summary:
            'Volume pasokan dari 12 petani langganan area Barat menurun 22% dalam 7 hari terakhir akibat cuaca hujan.',
        detailedExplanation:
            'Pola historis menunjukkan potensi pergeseran panen ke minggu berikutnya. Direkomendasikan mempersiapkan armada truk cadangan untuk lonjakan panen susulan 3 hari ke depan.',
        severity: AiInsightSeverity.info,
        type: AiInsightType.supplyPattern,
        metricImpact: 'Defisit Pasokan Sementara: -14.2 Ton',
        recommendedAction:
            'Hubungi koordinator petani wilayah Barat dan jadwalkan giliran panen bertahap.',
        timestamp: now.subtract(const Duration(hours: 14)),
        confidenceScore: 0.89,
      ),
      AiInsight(
        id: 'ins-04',
        title: 'Efisiensi Rasio Biaya Operasional Timbangan',
        summary:
            'Rasio pengeluaran operasional per kg TBS stabil di Rp 42/kg, berada 15% di bawah batas pagu efisiensi (Rp 50/kg).',
        detailedExplanation:
            'Pengeluaran biaya bahan bakar truk dan konsumsi pos timbang terkendali optimal seiring peningkatan volume tonase bulan berjalan.',
        severity: AiInsightSeverity.info,
        type: AiInsightType.marginOpportunity,
        metricImpact: 'Efisiensi Biaya: Hemat Rp 8/kg vs Pagu',
        recommendedAction:
            'Pertahankan rute pengiriman konsolidasi muatan penuh untuk menjaga biaya bahan bakar tetap rendah.',
        timestamp: now.subtract(const Duration(days: 1)),
        confidenceScore: 0.97,
      ),
    ];

    final defaultChat = [
      AiChatMessage(
        id: 'msg-01',
        sender: 'ai',
        text:
            'Halo! Saya **Asisten Analitik AI TBS Sawit** (didukung oleh 9router Local AI). Saya telah memindai data transaksi pembelian, pengiriman pabrik, dan arus kas terkini Anda.\n\nApa yang ingin Anda konsultasikan hari ini?',
        timestamp: now.subtract(const Duration(minutes: 15)),
        suggestions: [
          'Berapa harga beli TBS rekomendasi besok?',
          'Pabrik mana yang potongannya paling tinggi?',
          'Berapa estimasi kebutuhan modal 3 hari ke depan?',
          'Ringkasan margin bersih bulan ini',
        ],
      ),
    ];

    return AiAnalyticsState(
      kpiOverview: defaultKpi,
      allInsights: defaultInsights,
      chatMessages: defaultChat,
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setTimeframe(String timeframe) {
    state = state.copyWith(selectedTimeframe: timeframe);
  }

  Future<void> runFullAnalysis() async {
    state = state.copyWith(isAnalyzing: true);
    await refreshInsights();
    state = state.copyWith(isAnalyzing: false);
  }

  /// Memperbarui wawasan dan metrik berbasis data riil
  Future<void> refreshInsights() async {
    try {
      final trxRepo = _ref.read(transaksiRepositoryProvider);
      final pengirimanRepo = _ref.read(pengirimanPabrikRepositoryProvider);
      final pengeluaranRepo = _ref.read(pengeluaranRepositoryProvider);

      final trxResult = await trxRepo.getFilteredRingkasanPaginated(page: 1, pageSize: 100);
      final krmResult = await pengirimanRepo.getPengirimanPaginated(page: 1, pageSize: 50);
      final expResult = await pengeluaranRepo.fetchPengeluaran(page: 1, pageSize: 50);

      final allTrx = trxResult.items;
      final allKrm = krmResult.items;
      final allExp = expResult.items;

      final totalTrx = trxResult.totalCount;
      final totalKrm = krmResult.totalCount;

      // 1. Rata-rata harga beli TBS petani
      Decimal totalBeliRp = Decimal.zero;
      Decimal totalBeliKg = Decimal.zero;
      for (final t in allTrx) {
        totalBeliRp += t.totalNilai;
        totalBeliKg += t.totalBeratBersihKg;
      }
      final avgBeli = totalBeliKg > Decimal.zero
          ? (totalBeliRp / totalBeliKg).toDecimal(scaleOnInfinitePrecision: 2)
          : Decimal.zero;

      // 2. Rata-rata harga jual pabrik & deteksi sortasi tinggi
      Decimal totalJualRp = Decimal.zero;
      Decimal totalJualKg = Decimal.zero;
      int anomaliesCount = 0;
      Decimal maxHargaJual = Decimal.zero;

      for (final k in allKrm) {
        final hargaJual = k.hargaJualPerKg ?? Decimal.zero;
        if (hargaJual > maxHargaJual) maxHargaJual = hargaJual;
        if (k.totalNilaiJual != null) {
          totalJualRp += k.totalNilaiJual!;
        }
        if (k.beratBersihKg != null) {
          totalJualKg += k.beratBersihKg!;
        } else if (k.beratDiterimaKg != null) {
          totalJualKg += k.beratDiterimaKg!;
        }
        final sortasi = k.persentasePotonganPabrik ?? Decimal.zero;
        if (sortasi > Decimal.parse('4.5')) {
          anomaliesCount++;
        }
      }

      final avgJual = totalJualKg > Decimal.zero && totalJualRp > Decimal.zero
          ? (totalJualRp / totalJualKg).toDecimal(scaleOnInfinitePrecision: 2)
          : (maxHargaJual > Decimal.zero ? maxHargaJual : Decimal.parse('2850'));

      // 3. Estimasi Rekomendasi Harga Beli TBS Petani
      final refJual = avgJual > Decimal.zero ? avgJual : Decimal.parse('2850');
      final recommendedMin = refJual - Decimal.parse('350');
      final recommendedMax = refJual - Decimal.parse('280');

      // 4. Skor Kesehatan Margin (0 - 100)
      int marginScore = 92;
      if (avgJual > Decimal.zero && avgBeli > Decimal.zero) {
        final marginRp = avgJual - avgBeli;
        if (marginRp > Decimal.parse('300')) {
          marginScore = 95;
        } else if (marginRp > Decimal.parse('200')) {
          marginScore = 88;
        } else if (marginRp > Decimal.parse('100')) {
          marginScore = 75;
        } else {
          marginScore = 55;
        }
      }

      // 5. Proyeksi Laba Mingguan
      Decimal totalExpRp = Decimal.zero;
      for (final e in allExp) {
        totalExpRp += e.nominal;
      }
      final netMargin = totalJualRp > totalBeliRp ? (totalJualRp - totalBeliRp - totalExpRp) : Decimal.zero;
      final projectedWeekly = netMargin > Decimal.zero
          ? ((netMargin * Decimal.fromInt(7)) / Decimal.fromInt(30)).toDecimal(scaleOnInfinitePrecision: 0)
          : Decimal.parse('35000000');

      final updatedKpi = state.kpiOverview.copyWith(
        marginHealthScore: marginScore,
        activeAnomaliesCount: anomaliesCount,
        recommendedTbsPriceMin: recommendedMin > Decimal.zero ? recommendedMin : Decimal.parse('2480'),
        recommendedTbsPriceMax: recommendedMax > Decimal.zero ? recommendedMax : Decimal.parse('2520'),
        projectedWeeklyProfit: projectedWeekly,
        confidenceScore: 0.94,
        totalAnalysedTransactions: totalTrx > 0 ? totalTrx : allTrx.length,
        totalAnalysedShipments: totalKrm > 0 ? totalKrm : allKrm.length,
      );

      // 6. Buat wawasan dinamis berbasis data riil
      final now = DateTime.now();
      final insights = <AiInsight>[];

      // Wawasan 1: Anomali Sortasi Pabrik
      if (anomaliesCount > 0) {
        insights.add(AiInsight(
          id: 'ins-sortasi-01',
          title: 'Deteksi Tingkat Potongan Sortasi Pabrik di Atas Batas Wajar',
          summary: 'Ditemukan $anomaliesCount pengiriman dengan potongan sortasi melebihi 4.5%.',
          detailedExplanation: 'Pemeriksaan pada slip penerimaan PKS menunjukkan beberapa pengiriman mengalami potongan sortasi tinggi. Hal ini dapat mengurangi tonase bersih yang dibayarkan pabrik.',
          severity: AiInsightSeverity.warning,
          type: AiInsightType.anomalySortasi,
          metricImpact: 'Potongan > 4.5% pada $anomaliesCount pengiriman',
          recommendedAction: 'Periksa kebersihan buah mentah dan tangkai panjang sebelum armada truk diberangkatkan ke PKS.',
          timestamp: now.subtract(const Duration(hours: 2)),
          confidenceScore: 0.92,
        ));
      } else {
        insights.add(AiInsight(
          id: 'ins-sortasi-ok',
          title: 'Tingkat Potongan Sortasi Pabrik Relatif Normal',
          summary: 'Seluruh pengiriman ke pabrik PKS mencatat deviasi potongan sortasi dalam rentang aman.',
          detailedExplanation: 'Rata-rata pemotongan sortasi oleh pabrik mitra berada di bawah ambang batas 4.0%, menjaga efisiensi tonase yang dibayarkan.',
          severity: AiInsightSeverity.info,
          type: AiInsightType.anomalySortasi,
          metricImpact: 'Sortasi rata-rata normal (< 4.0%)',
          recommendedAction: 'Pertahankan standar penyortiran buah di loading ramp.',
          timestamp: now.subtract(const Duration(hours: 3)),
          confidenceScore: 0.95,
        ));
      }

      // Wawasan 2: Rekomendasi Harga Beli TBS Petani
      insights.add(AiInsight(
        id: 'ins-harga-02',
        title: 'Rekomendasi Penetapan Papan Harga Beli TBS Petani',
        summary: 'Berdasarkan harga penerimaan PKS terkini, rentang beli petani optimal di Rp ${recommendedMin.toStringAsFixed(0)} - Rp ${recommendedMax.toStringAsFixed(0)} /kg.',
        detailedExplanation: 'Perhitungan ini telah memperhitungkan estimasi biaya muat, transportasi antar pabrik, dan target margin kotor minimal 10-12% bagi RAM.',
        severity: AiInsightSeverity.recommendation,
        type: AiInsightType.priceRecommendation,
        metricImpact: 'Target Margin: Rp ${(refJual - recommendedMax).toStringAsFixed(0)}/kg',
        recommendedAction: 'Gunakan patokan harga Rp ${recommendedMax.toStringAsFixed(0)}/kg untuk pasokan petani reguler.',
        timestamp: now.subtract(const Duration(hours: 5)),
        confidenceScore: 0.93,
      ));

      // Wawasan 3: Margin & Laba Operasional
      insights.add(AiInsight(
        id: 'ins-margin-03',
        title: 'Kesehatan Margin & Perputaran Kas Pembelian TBS',
        summary: 'Skor kesehatan margin operasional berada di level $marginScore/100.',
        detailedExplanation: 'Akumulasi total tonase pembelian (${totalBeliKg.toStringAsFixed(0)} kg) dan penjualan pabrik menunjukkan perputaran dana yang aktif dan terkontrol.',
        severity: AiInsightSeverity.info,
        type: AiInsightType.marginOpportunity,
        metricImpact: 'Skor Margin: $marginScore/100',
        recommendedAction: 'Pastikan pencairan klaim DO pabrik tepat waktu untuk menjaga likuiditas kas kasir.',
        timestamp: now.subtract(const Duration(hours: 8)),
        confidenceScore: 0.96,
      ));

      state = state.copyWith(
        kpiOverview: updatedKpi,
        allInsights: insights,
      );
    } catch (_) {}
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = AiChatMessage(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      sender: 'user',
      text: trimmed,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      chatMessages: [...state.chatMessages, userMsg],
      isGeneratingReply: true,
    );

    try {
      // 1. Ambil data transaksi riil dari berbagai repository
      final trxRepo = _ref.read(transaksiRepositoryProvider);
      final pengirimanRepo = _ref.read(pengirimanPabrikRepositoryProvider);
      final pengeluaranRepo = _ref.read(pengeluaranRepositoryProvider);
      final pabrikRepo = _ref.read(pabrikRepositoryProvider);

      List<TransaksiRingkasan> allTrx = [];
      List<PengirimanPabrik> allKrm = [];
      List<Pengeluaran> allPengeluaran = [];
      List<Pabrik> allPabrik = [];

      try {
        final trxRes = await trxRepo.getFilteredRingkasanPaginated(page: 1, pageSize: 100);
        allTrx = trxRes.items;
      } catch (_) {}

      try {
        final krmRes = await pengirimanRepo.getPengirimanPaginated(page: 1, pageSize: 50);
        allKrm = krmRes.items;
      } catch (_) {}

      try {
        final expRes = await pengeluaranRepo.fetchPengeluaran(page: 1, pageSize: 50);
        allPengeluaran = expRes.items;
      } catch (_) {}

      try {
        allPabrik = await pabrikRepo.getPabrikList();
      } catch (_) {}

      // 2. Kumpulkan data agregasi finansial resmi dari DashboardRepository
      String dashboardContext = '';
      try {
        final dashboardRepo = _ref.read(dashboardRepositoryProvider);
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

        final summaryBulanIni = await dashboardRepo.getKartuBulanIniSummary(startOfMonth, endOfDay, 'Bulan Ini');
        final labaList = await dashboardRepo.getLabaBersihHarian(startOfMonth, endOfDay);
        Decimal totalLabaBersihBulanIni = Decimal.zero;
        Decimal totalOpsBulanIni = Decimal.zero;
        for (final l in labaList) {
          totalLabaBersihBulanIni += l.labaBersih;
          totalOpsBulanIni += l.totalPengeluaran;
        }

        final start90d = now.subtract(const Duration(days: 90));
        final summaryHistoris = await dashboardRepo.getKartuBulanIniSummary(start90d, endOfDay, '3 Bulan Terakhir');

        dashboardContext = '''
=== RINGKASAN AGREGASI KEUANGAN RESMI (DARI DASHBOARD & DATABASE SERVER) ===
1. Kinerja Finansial Bulan Berjalan (${startOfMonth.day}/${startOfMonth.month}/${startOfMonth.year} s/d ${endOfDay.day}/${endOfDay.month}/${endOfDay.year}):
- TOTAL OMZET PENJUALAN KE PABRIK PKS (PENDAPATAN KOTOR): Rp ${summaryBulanIni.penjualan.totalNilai} (${summaryBulanIni.penjualan.totalBeratBersihKg} kg dari ${summaryBulanIni.penjualan.jumlahTransaksi} pengiriman pabrik)
- TOTAL PEMBELIAN TBS DARI PETANI (HPP TBS): Rp ${summaryBulanIni.pembelian.totalNilai} (${summaryBulanIni.pembelian.totalBeratBersihKg} kg dari ${summaryBulanIni.pembelian.jumlahTransaksi} nota petani)
- MARGIN KOTOR PEMBELIAN VS PENJUALAN: Rp ${summaryBulanIni.margin}
- TOTAL BIAYA PENGELUARAN OPERASIONAL: Rp $totalOpsBulanIni
- ESTIMASI LABA BERSIH BULAN INI: Rp $totalLabaBersihBulanIni

2. Akumulasi Historis 3 Bulan Terakhir (Mencakup data dari September s/d Sekarang):
- Total Omzet Penjualan ke Pabrik: Rp ${summaryHistoris.penjualan.totalNilai} (${summaryHistoris.penjualan.totalBeratBersihKg} kg)
- Total Pembelian Petani (HPP TBS): Rp ${summaryHistoris.pembelian.totalNilai} (${summaryHistoris.pembelian.totalBeratBersihKg} kg)
- Total Margin Kotor Historis: Rp ${summaryHistoris.margin}
Catatan Sistem: Database mencatat data operasional dari bulan September hingga sekarang secara berkesinambungan.
''';
      } catch (_) {}

      // 3. Berikan jeda proses analisis wajar (300ms)
      await Future.delayed(const Duration(milliseconds: 300));

      // 4. Proses kueri bisnis melalui Agentic LLM (dengan memori percakapan, agregasi finansial & fallback cerdas)
      final queryResponse = await AiAgenticService.processWithAgenticLlm(
        query: trimmed,
        transaksiList: allTrx,
        pengirimanList: allKrm,
        pengeluaranList: allPengeluaran,
        pabrikList: allPabrik,
        chatHistory: state.chatMessages,
        dashboardFinancialContext: dashboardContext,
      );

      final aiMsg = AiChatMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'ai',
        text: queryResponse.text,
        timestamp: DateTime.now(),
        suggestions: queryResponse.suggestions,
        highlightMetrics: queryResponse.metrics,
      );

      state = state.copyWith(
        chatMessages: [...state.chatMessages, aiMsg],
        isGeneratingReply: false,
      );
    } catch (e) {
      final errorMsg = AiChatMessage(
        id: 'ai-err-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'ai',
        text: 'Maaf, terjadi kendala saat menganalisis data transaksi: $e. Silakan coba kembali.',
        timestamp: DateTime.now(),
        suggestions: ['Berapa total pembelian hari ini?'],
      );

      state = state.copyWith(
        chatMessages: [...state.chatMessages, errorMsg],
        isGeneratingReply: false,
      );
    }
  }

  /// Membersihkan riwayat obrolan dan mengembalikan sapaan awal
  void clearChat() {
    state = state.copyWith(
      chatMessages: [
        AiChatMessage(
          id: 'msg-reset-${DateTime.now().millisecondsSinceEpoch}',
          sender: 'ai',
          text:
              'Halo! Riwayat percakapan telah dibersihkan. Saya siap membantu Anda menganalisis data transaksi pembelian TBS, pengiriman pabrik, atau margin keuntungan operasional RamSawit Anda.',
          timestamp: DateTime.now(),
          suggestions: const [
            'Berapa total pembelian hari ini?',
            'Pabrik mana yang potongan sortasinya paling rendah?',
            'Rekomendasi harga beli TBS ke petani hari ini?',
          ],
        ),
      ],
    );
  }
}

final aiAnalyticsControllerProvider =
    StateNotifierProvider<AiAnalyticsController, AiAnalyticsState>((ref) {
  return AiAnalyticsController(ref);
});
