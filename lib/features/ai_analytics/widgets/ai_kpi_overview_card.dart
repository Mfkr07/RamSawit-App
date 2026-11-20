import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/ai_insight.dart';

/// Kartu Ringkasan Indikator Cerdas AI (Carbon Design System)
class AiKpiOverviewCards extends StatelessWidget {
  final AiKpiOverview overview;

  const AiKpiOverviewCards({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        final cardHealth = _buildKpiCard(
          context: context,
          icon: Icons.health_and_safety_outlined,
          iconColor: AppColors.success,
          title: 'SKOR KESEHATAN MARGIN',
          value: '${overview.marginHealthScore}/100',
          subtitle: 'Kondisi operasional prima (92% confidence)',
          badgeText: 'OPTIMAL',
          badgeColor: AppColors.success,
          progressValue: overview.marginHealthScore / 100.0,
        );

        final cardPrice = _buildKpiCard(
          context: context,
          icon: Icons.price_change_outlined,
          iconColor: AppColors.primary,
          title: 'REKOMENDASI BELI TBS',
          value:
              '${CurrencyFormatter.format(overview.recommendedTbsPriceMin)} - ${CurrencyFormatter.format(overview.recommendedTbsPriceMax)}',
          subtitle: 'Per kg tingkat petani untuk target margin 12.5%',
          badgeText: 'TARGET MARGIN',
          badgeColor: AppColors.primary,
        );

        final cardAnomaly = _buildKpiCard(
          context: context,
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          title: 'DETEKSI ANOMALI SORTASI',
          value: '${overview.activeAnomaliesCount} Pabrik',
          subtitle: 'Deviasi potongan > 2.5% di atas batas normal',
          badgeText: overview.activeAnomaliesCount > 0 ? 'PERHATIAN' : 'AMAN',
          badgeColor: overview.activeAnomaliesCount > 0
              ? AppColors.warning
              : AppColors.success,
        );

        final cardProfit = _buildKpiCard(
          context: context,
          icon: Icons.trending_up,
          iconColor: AppColors.primary,
          title: 'ESTIMASI LABA MINGGU INI',
          value: CurrencyFormatter.format(overview.projectedWeeklyProfit),
          subtitle: 'Berdasarkan rata-rata throughput 22 ton/hari',
          badgeText: 'PROYEKSI',
          badgeColor: AppColors.info,
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cardHealth),
              const SizedBox(width: 14),
              Expanded(child: cardPrice),
              const SizedBox(width: 14),
              Expanded(child: cardAnomaly),
              const SizedBox(width: 14),
              Expanded(child: cardProfit),
            ],
          );
        } else if (isTablet) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cardHealth),
                  const SizedBox(width: 14),
                  Expanded(child: cardPrice),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: cardAnomaly),
                  const SizedBox(width: 14),
                  Expanded(child: cardProfit),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              cardHealth,
              const SizedBox(height: 12),
              cardPrice,
              const SizedBox(height: 12),
              cardAnomaly,
              const SizedBox(height: 12),
              cardProfit,
            ],
          );
        }
      },
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    double? progressValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: iconColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2.0),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.inkSubtle,
            ),
          ),
          if (progressValue != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: AppColors.surface2,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }
}
