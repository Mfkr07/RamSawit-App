import 'package:decimal/decimal.dart';

/// Kategori jenis analisis wawasan cerdas AI.
enum AiInsightType {
  anomalySortasi,
  marginOpportunity,
  cashFlowRisk,
  supplyPattern,
  priceRecommendation,
}

/// Tingkat urgensi atau keparahan wawasan AI.
enum AiInsightSeverity {
  info,
  recommendation,
  warning,
  critical,
}

/// Model Wawasan Analitik Cerdas AI (PRD Fase 2).
class AiInsight {
  final String id;
  final String title;
  final String summary;
  final String detailedExplanation;
  final AiInsightSeverity severity;
  final AiInsightType type;
  final String metricImpact;
  final String recommendedAction;
  final DateTime timestamp;
  final double confidenceScore;

  const AiInsight({
    required this.id,
    required this.title,
    required this.summary,
    required this.detailedExplanation,
    required this.severity,
    required this.type,
    required this.metricImpact,
    required this.recommendedAction,
    required this.timestamp,
    this.confidenceScore = 0.95,
  });

  String get typeLabel {
    switch (type) {
      case AiInsightType.anomalySortasi:
        return 'Anomali Sortasi Pabrik';
      case AiInsightType.marginOpportunity:
        return 'Optimasi Margin';
      case AiInsightType.cashFlowRisk:
        return 'Likuiditas & Arus Kas';
      case AiInsightType.supplyPattern:
        return 'Pola Pasokan Petani';
      case AiInsightType.priceRecommendation:
        return 'Rekomendasi Harga TBS';
    }
  }

  String get severityLabel {
    switch (severity) {
      case AiInsightSeverity.info:
        return 'INFORMASI';
      case AiInsightSeverity.recommendation:
        return 'REKOMENDASI';
      case AiInsightSeverity.warning:
        return 'PERINGATAN';
      case AiInsightSeverity.critical:
        return 'KRITIKAL';
    }
  }
}

/// Ringkasan Indikator KPI Utama Analitik AI.
class AiKpiOverview {
  final int marginHealthScore; // 0 - 100
  final int activeAnomaliesCount;
  final Decimal recommendedTbsPriceMin;
  final Decimal recommendedTbsPriceMax;
  final Decimal projectedWeeklyProfit;
  final double confidenceScore;
  final int totalAnalysedTransactions;
  final int totalAnalysedShipments;

  const AiKpiOverview({
    required this.marginHealthScore,
    required this.activeAnomaliesCount,
    required this.recommendedTbsPriceMin,
    required this.recommendedTbsPriceMax,
    required this.projectedWeeklyProfit,
    required this.confidenceScore,
    required this.totalAnalysedTransactions,
    required this.totalAnalysedShipments,
  });

  AiKpiOverview copyWith({
    int? marginHealthScore,
    int? activeAnomaliesCount,
    Decimal? recommendedTbsPriceMin,
    Decimal? recommendedTbsPriceMax,
    Decimal? projectedWeeklyProfit,
    double? confidenceScore,
    int? totalAnalysedTransactions,
    int? totalAnalysedShipments,
  }) {
    return AiKpiOverview(
      marginHealthScore: marginHealthScore ?? this.marginHealthScore,
      activeAnomaliesCount: activeAnomaliesCount ?? this.activeAnomaliesCount,
      recommendedTbsPriceMin: recommendedTbsPriceMin ?? this.recommendedTbsPriceMin,
      recommendedTbsPriceMax: recommendedTbsPriceMax ?? this.recommendedTbsPriceMax,
      projectedWeeklyProfit: projectedWeeklyProfit ?? this.projectedWeeklyProfit,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      totalAnalysedTransactions: totalAnalysedTransactions ?? this.totalAnalysedTransactions,
      totalAnalysedShipments: totalAnalysedShipments ?? this.totalAnalysedShipments,
    );
  }
}

/// Pesan Interaksi Konsultasi Asisten AI Bisnis.
class AiChatMessage {
  final String id;
  final String sender; // 'user' atau 'ai'
  final String text;
  final DateTime timestamp;
  final List<String> suggestions;
  final Map<String, String>? highlightMetrics;

  const AiChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.suggestions = const [],
    this.highlightMetrics,
  });

  bool get isUser => sender == 'user';
}
