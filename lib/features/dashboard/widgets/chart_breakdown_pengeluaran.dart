import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/dashboard_analytics.dart';

/// Widget Grafik Donut/Pie Breakdown Pengeluaran per Jenis (FR-5.14):
/// Menampilkan proporsi pengeluaran operasional per kategori sesuai filter periode aktif.
/// Khusus untuk role Admin.
class ChartBreakdownPengeluaranSection extends StatefulWidget {
  final List<BreakdownJenisPengeluaran> data;
  final bool isLoading;

  const ChartBreakdownPengeluaranSection({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  State<ChartBreakdownPengeluaranSection> createState() =>
      _ChartBreakdownPengeluaranSectionState();
}

class _ChartBreakdownPengeluaranSectionState
    extends State<ChartBreakdownPengeluaranSection> {
  int _touchedIndex = -1;

  static const _palette = [
    Color(0xFFDA1E28), // IBM Red #DA1E28
    Color(0xFF0F62FE), // IBM Blue #0F62FE
    Color(0xFF8A3FFC), // IBM Purple #8A3FFC
    Color(0xFFBA4E00), // IBM Orange #BA4E00
    Color(0xFF005D5D), // IBM Teal #005D5D
    Color(0xFF198038), // IBM Green #198038
  ];

  Color _getColor(int index) => _palette[index % _palette.length];

  @override
  Widget build(BuildContext context) {
    // Agregasikan per nama jenis pengeluaran
    final Map<String, Decimal> aggregatedMap = {};
    Decimal totalAllNominal = Decimal.zero;

    for (final item in widget.data) {
      final cur = aggregatedMap[item.jenisPengeluaran] ?? Decimal.zero;
      aggregatedMap[item.jenisPengeluaran] = cur + item.totalNominal;
      totalAllNominal += item.totalNominal;
    }

    final entries = aggregatedMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.pie_chart_outline, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(
                    'BREAKDOWN PENGELUARAN PER JENIS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
              if (entries.isNotEmpty)
                Text(
                  'Total: ${CurrencyFormatter.format(totalAllNominal)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Proporsi nominal pengeluaran operasional menurut kategori',
            style: TextStyle(fontSize: 11, color: AppColors.inkSubtle),
          ),
          const SizedBox(height: 16),

          // Konten Utama: Donut Chart & Legend
          if (entries.isEmpty || totalAllNominal == Decimal.zero)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text(
                'Tidak ada catatan pengeluaran pada rentang periode ini.',
                style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 450;

                final chartWidget = SizedBox(
                  height: 190,
                  width: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
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
                                _touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 48,
                          sections: List.generate(entries.length, (i) {
                            final isTouched = i == _touchedIndex;
                            final radius = isTouched ? 36.0 : 30.0;
                            final color = _getColor(i);
                            final val = double.parse(entries[i].value.toString());

                            return PieChartSectionData(
                              color: color,
                              value: val,
                              title: '',
                              radius: radius,
                            );
                          }),
                        ),
                      ),
                      // Teks Nilai di Tengah Donut
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.format(totalAllNominal),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                final legendWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(entries.length, (i) {
                    final item = entries[i];
                    final color = _getColor(i);
                    final isTouched = i == _touchedIndex;
                    final pct = totalAllNominal > Decimal.zero
                        ? (double.parse(item.value.toString()) /
                                double.parse(totalAllNominal.toString()) *
                                100)
                            .toStringAsFixed(1)
                        : '0';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.5),
                      child: Row(
                        children: [
                          Container(
                            width: isTouched ? 12 : 9,
                            height: isTouched ? 12 : 9,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.all(Radius.circular(1)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.key,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isTouched
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$pct% • ${CurrencyFormatter.format(item.value)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isTouched ? color : AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      Center(child: chartWidget),
                      const SizedBox(height: 14),
                      legendWidget,
                    ],
                  );
                }

                return Row(
                  children: [
                    chartWidget,
                    const SizedBox(width: 20),
                    Expanded(child: legendWidget),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
