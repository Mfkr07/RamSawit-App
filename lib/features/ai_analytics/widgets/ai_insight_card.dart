import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ai_insight.dart';

/// Kartu Wawasan Cerdas AI (Carbon Design System)
class AiInsightCard extends StatefulWidget {
  final AiInsight insight;
  final VoidCallback? onApplyAction;

  const AiInsightCard({
    super.key,
    required this.insight,
    this.onApplyAction,
  });

  @override
  State<AiInsightCard> createState() => _AiInsightCardState();
}

class _AiInsightCardState extends State<AiInsightCard> {
  bool _isExpanded = false;

  Color get _accentColor {
    switch (widget.insight.severity) {
      case AiInsightSeverity.critical:
        return AppColors.error;
      case AiInsightSeverity.warning:
        return AppColors.warning;
      case AiInsightSeverity.recommendation:
        return AppColors.primary;
      case AiInsightSeverity.info:
        return AppColors.info;
    }
  }

  IconData get _typeIcon {
    switch (widget.insight.type) {
      case AiInsightType.anomalySortasi:
        return Icons.search_off_outlined;
      case AiInsightType.marginOpportunity:
        return Icons.auto_graph_outlined;
      case AiInsightType.cashFlowRisk:
        return Icons.account_balance_wallet_outlined;
      case AiInsightType.supplyPattern:
        return Icons.agriculture_outlined;
      case AiInsightType.priceRecommendation:
        return Icons.sell_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Accent Border Strip (Carbon Pattern)
            Container(
              width: 5,
              color: _accentColor,
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Tag, Title, Timestamp
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_typeIcon, size: 18, color: _accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.insight.typeLabel.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: _accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _accentColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                    child: Text(
                                      widget.insight.severityLabel,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: _accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.insight.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatTimeAgo(widget.insight.timestamp),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.inkSubtle,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Summary
                    Text(
                      widget.insight.summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Metric Impact Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface1,
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.insights,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.insight.metricImpact,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Collapsible Details
                    if (_isExpanded) ...[
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.hairline, height: 1),
                      const SizedBox(height: 12),
                      const Text(
                        'ANALISIS MENDALAM:',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.insight.detailedExplanation,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.ink,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'LANGKAH TINDAKAN YANG DISARANKAN:',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• ${widget.insight.recommendedAction}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                          height: 1.4,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Footer Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          icon: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            _isExpanded ? 'Tutup Detail' : 'Pelajari Detail Analisis',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: widget.onApplyAction ??
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Rekomendasi diterapkan: ${widget.insight.title}',
                                    ),
                                    backgroundColor: AppColors.ink,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(2.0)),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Terapkan Tindakan',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m lalu';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}j lalu';
    }
    return '${diff.inDays}h lalu';
  }
}
