import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../models/dashboard_analytics.dart';

/// Widget Grafik Breakdown Volume (kg) per Jenis Buah Bulan Berjalan (FR-5.3)
/// Menggunakan `fl_chart` Pie/Donut Chart dengan tema korporat IBM Carbon.
class ChartBreakdownSection extends StatefulWidget {
  final List<BreakdownJenisBuah> data;
  final bool isLoading;

  const ChartBreakdownSection({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  State<ChartBreakdownSection> createState() => _ChartBreakdownSectionState();
}

class _ChartBreakdownSectionState extends State<ChartBreakdownSection> {
  int _touchedIndex = -1;

  static const _fruitColors = {
    'Tandan Besar': AppColors.primary, // IBM Blue #0F62FE
    'Tandan Kecil': Color(0xFF0072C3), // IBM Teal/Cyan
    'Berondolan': Color(0xFF6929C4), // IBM Purple
  };

  Color _getColor(String fruitName, int index) {
    if (_fruitColors.containsKey(fruitName)) {
      return _fruitColors[fruitName]!;
    }
    const fallbacks = [
      Color(0xFF005D5D),
      Color(0xFF8A3FFC),
      Color(0xFF0043CE),
    ];
    return fallbacks[index % fallbacks.length];
  }

  @override
  Widget build(BuildContext context) {
    // Agregasikan data jika ada beberapa baris dengan jenis buah sama
    final Map<String, Decimal> aggregatedMap = {};
    Decimal totalAllKg = Decimal.zero;

    for (final item in widget.data) {
      final current = aggregatedMap[item.jenisBuah] ?? Decimal.zero;
      aggregatedMap[item.jenisBuah] = current + item.totalBeratKg;
      totalAllKg += item.totalBeratKg;
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
          // Header Card
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
                    'PROPORSI VOLUME JENIS BUAH',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Volume per jenis buah pada periode terpilih',
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

          // Area Donut Chart + Legend
          SizedBox(
            height: 240,
            child: entries.isEmpty || totalAllKg == Decimal.zero
                ? const Center(
                    child: Text(
                      'Belum ada data volume panen untuk periode ini.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.inkSubtle,
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 420;

                      if (isCompact) {
                        // Tampilan vertikal di layar sempit
                        return Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildPieChart(entries, totalAllKg),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              flex: 2,
                              child: _buildLegendList(entries, totalAllKg),
                            ),
                          ],
                        );
                      }

                      // Tampilan horizontal berdampingan di desktop/tablet
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
    final double totalDouble = totalAllKg.toDouble();

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (event, pieTouchResponse) {
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
        centerSpaceRadius: 42,
        sections: List.generate(entries.length, (i) {
          final isTouched = i == _touchedIndex;
          final fontSize = isTouched ? 13.0 : 11.0;
          final radius = isTouched ? 50.0 : 44.0;
          final entry = entries[i];
          final val = entry.value.toDouble();
          final percentage =
              totalDouble > 0 ? (val / totalDouble) * 100 : 0.0;
          final color = _getColor(entry.key, i);

          return PieChartSectionData(
            color: color,
            value: val,
            title: '${percentage.toStringAsFixed(0)}%',
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
    final double totalDouble = totalAllKg.toDouble();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final entry = entries[i];
        final color = _getColor(entry.key, i);
        final val = entry.value.toDouble();
        final percentage =
            totalDouble > 0 ? (val / totalDouble) * 100 : 0.0;

        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(Radius.circular(2.0)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  WeightFormatter.format(entry.value),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.inkSubtle,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
