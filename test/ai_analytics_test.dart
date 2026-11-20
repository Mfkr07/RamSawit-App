import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/features/ai_analytics/ai_analytics_controller.dart';
import 'package:transaksi_sawit_app/features/ai_analytics/widgets/ai_insight_card.dart';
import 'package:transaksi_sawit_app/features/ai_analytics/widgets/ai_kpi_overview_card.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/ai_quick_insight_banner.dart';
import 'package:transaksi_sawit_app/models/ai_insight.dart';

void main() {
  setUpAll(() {
    AiAnalyticsController.enableDummySeedForTesting = true;
  });

  group('Fase 2: Analytic AI - Model & Controller Tests', () {
    test('1. Model AiInsight & AiKpiOverview inisialisasi dengan benar', () {
      final now = DateTime.now();
      final insight = AiInsight(
        id: 'test-1',
        title: 'Test Anomali',
        summary: 'Ringkasan test anomali sortasi',
        detailedExplanation: 'Penjelasan mendalam',
        severity: AiInsightSeverity.warning,
        type: AiInsightType.anomalySortasi,
        metricImpact: '+2.5% potongan',
        recommendedAction: 'Lakukan kalibrasi timbangan',
        timestamp: now,
      );

      expect(insight.typeLabel, equals('Anomali Sortasi Pabrik'));
      expect(insight.severityLabel, equals('PERINGATAN'));
      expect(insight.confidenceScore, equals(0.95));

      final kpi = AiKpiOverview(
        marginHealthScore: 90,
        activeAnomaliesCount: 2,
        recommendedTbsPriceMin: Decimal.parse('2400'),
        recommendedTbsPriceMax: Decimal.parse('2500'),
        projectedWeeklyProfit: Decimal.parse('35000000'),
        confidenceScore: 0.93,
        totalAnalysedTransactions: 500,
        totalAnalysedShipments: 40,
      );

      expect(kpi.marginHealthScore, equals(90));
      expect(kpi.recommendedTbsPriceMin, equals(Decimal.parse('2400')));
    });

    test('2. AiAnalyticsController memfilter wawasan dan merespons pertanyaan chat',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller =
          container.read(aiAnalyticsControllerProvider.notifier);
      var state = container.read(aiAnalyticsControllerProvider);

      expect(state.allInsights.isNotEmpty, isTrue);
      expect(state.selectedFilter, equals('semua'));
      expect(state.filteredInsights.length, equals(state.allInsights.length));

      // Test Filter
      controller.setFilter('anomali');
      state = container.read(aiAnalyticsControllerProvider);
      expect(state.selectedFilter, equals('anomali'));
      expect(
        state.filteredInsights
            .every((i) => i.type == AiInsightType.anomalySortasi),
        isTrue,
      );

      // Test Chat Interaction
      await controller.sendMessage('Berapa harga beli TBS rekomendasi besok?');
      state = container.read(aiAnalyticsControllerProvider);

      expect(state.chatMessages.length, greaterThanOrEqualTo(2));
      final lastMsg = state.chatMessages.last;
      expect(lastMsg.sender, equals('ai'));
      expect(lastMsg.text.contains('Rekomendasi Harga Beli'), isTrue);
    });
  });

  group('Fase 2: Analytic AI - Widget Tests', () {
    testWidgets('3. AiKpiOverviewCards merender 4 kartu KPI utama',
        (tester) async {
      final kpi = AiKpiOverview(
        marginHealthScore: 92,
        activeAnomaliesCount: 1,
        recommendedTbsPriceMin: Decimal.parse('2480'),
        recommendedTbsPriceMax: Decimal.parse('2520'),
        projectedWeeklyProfit: Decimal.parse('42850000'),
        confidenceScore: 0.94,
        totalAnalysedTransactions: 642,
        totalAnalysedShipments: 48,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiKpiOverviewCards(overview: kpi),
          ),
        ),
      );

      expect(find.text('SKOR KESEHATAN MARGIN'), findsOneWidget);
      expect(find.text('92/100'), findsOneWidget);
      expect(find.text('REKOMENDASI BELI TBS'), findsOneWidget);
      expect(find.text('DETEKSI ANOMALI SORTASI'), findsOneWidget);
      expect(find.text('ESTIMASI LABA MINGGU INI'), findsOneWidget);
    });

    testWidgets('4. AiInsightCard menampilkan aksen dan aksi ekspansi detail',
        (tester) async {
      final insight = AiInsight(
        id: 'test-card',
        title: 'Uji Kartu Anomali',
        summary: 'Ringkasan uji coba kartu anomali',
        detailedExplanation: 'Detail penjelasan mendalam dari AI',
        severity: AiInsightSeverity.critical,
        type: AiInsightType.anomalySortasi,
        metricImpact: 'Dampak: +5% potongan',
        recommendedAction: 'Segera periksa kendaraan',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiInsightCard(insight: insight),
          ),
        ),
      );

      expect(find.text('Uji Kartu Anomali'), findsOneWidget);
      expect(find.text('Dampak: +5% potongan'), findsOneWidget);
      expect(find.text('Pelajari Detail Analisis'), findsOneWidget);

      // Tap tombol pelajari detail
      await tester.tap(find.text('Pelajari Detail Analisis'));
      await tester.pumpAndSettle();

      expect(find.text('ANALISIS MENDALAM:'), findsOneWidget);
      expect(find.text('Detail penjelasan mendalam dari AI'), findsOneWidget);
    });

    testWidgets('5. AiQuickInsightBanner merender pintasan wawasan di dashboard',
        (tester) async {
      bool opened = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AiQuickInsightBanner(
                onOpenAiAnalytics: () {
                  opened = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('ASISTEN ANALITIK AI'), findsOneWidget);
      expect(find.text('Buka Analitik AI'), findsOneWidget);

      await tester.tap(find.text('Buka Analitik AI'));
      await tester.pump();
      expect(opened, isTrue);
    });
  });
}
