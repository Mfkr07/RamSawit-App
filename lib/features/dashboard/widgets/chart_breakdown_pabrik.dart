import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../models/dashboard_analytics.dart';

/// Widget Grafik Breakdown Penjualan per Pabrik Tujuan (FR-5.8):
/// Menggunakan `fl_chart` Pie/Donut Chart dengan tema korporat IBM Carbon,
/// menampilkan proporsi volume bersih (kg) yang dikirim ke masing-masing pabrik tujuan.
class ChartBreakdownPabrikSection extends StatefulWidget {
  final List<BreakdownPabrik> data;
  final bool isLoading;

  const ChartBreakdownPabrikSection({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  State<ChartBreakdownPabrikSection> createState() =>
      _ChartBreakdownPabrikSectionState();
}

class _ChartBreakdownPabrikSectionState
    extends State<ChartBreakdownPabrikSection> {
  int _touchedIndex = -1;

  static const _palette = [
    Color(0xFF005D5D), // IBM Teal #005D5D
    Color(0xFF198038), // IBM Green #198038
    Color(0xFF0072C3), // IBM Cyan #0072C3
    Color(0xFF8A3FFC), // IBM Purple #8A3FFC
    Color(0xFFBA4E00), // IBM Orange #BA4E00
  ];

  Color _getColor(int index) => _palette[index % _palette.length];

  @override
  Widget build(BuildContext context) {
    // Agregasikan per nama pabrik
    final Map<String, Decimal> aggregatedMap = {};
    Decimal totalAllKg = Decimal.zero;

    for (final item in widget.data) {
      final cur = aggregatedMap[item.namaPabrik] ?? Decimal.zero;
      aggregatedMap[item.namaPabrik] = cur + item.totalBeratBersihKg;
      totalAllKg += item.totalBeratBersihKg;
    }

    final entries = aggregatedMap.entries.toList();

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'PROPORSI PENJUALAN PER PABRIK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Volume pengiriman per pabrik pada periode terpilih',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.inkSubtle,
                    ),
                  ),
                ],
              ),
              Text(
                'Total: ${WeightFormatter.format(totalAllKg)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 240,
            child: entries.isEmpty || totalAllKg == Decimal.zero
                ? const Center(
                    child: Text(
                      'Belum ada data pengiriman pabrik untuk periode ini.',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSubtle),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 450;
                      if (isCompact) {
                        return Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildPieChart(entries, totalAllKg),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              flex: 2,
                              child: _buildLegendList(entries, totalAllKg),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildPieChart(entries, totalAllKg),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: _buildLegendList(entries, totalAllKg),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    List<MapEntry<String, Decimal>> entries,
    Decimal totalAllKg,
  ) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(entries.length, (i) {
          final isTouched = i == _touchedIndex;
          final fontSize = isTouched ? 12.0 : 10.0;
          final radius = isTouched ? 54.0 : 46.0;
          final entry = entries[i];
          final percent = totalAllKg > Decimal.zero
              ? (entry.value.toDouble() / totalAllKg.toDouble() * 100)
              : 0.0;

          return PieChartSectionData(
            color: _getColor(i),
            value: entry.value.toDouble(),
            title: '${percent.toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLegendList(
    List<MapEntry<String, Decimal>> entries,
    Decimal totalAllKg,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final color = _getColor(index);
        final percent = totalAllKg > Decimal.zero
            ? (entry.value.toDouble() / totalAllKg.toDouble() * 100)
            : 0.0;
        final isSelected = index == _touchedIndex;

        return InkWell(
          onTap: () {
            setState(() {
              _touchedIndex = _touchedIndex == index ? -1 : index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(2.0)),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(1.0)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      WeightFormatter.format(entry.value),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.inkSubtle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
