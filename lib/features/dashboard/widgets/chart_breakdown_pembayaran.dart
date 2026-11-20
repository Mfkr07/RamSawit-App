import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/dashboard_analytics.dart';

/// Widget visualisasi proporsi Pembelian Tunai vs Non Tunai menggunakan Pie/Donut Chart.
/// Mengikuti standar IBM Carbon Design System.
class ChartBreakdownPembayaranSection extends StatefulWidget {
  final List<BreakdownMetodePembayaran> data;

  const ChartBreakdownPembayaranSection({
    super.key,
    required this.data,
  });

  @override
  State<ChartBreakdownPembayaranSection> createState() =>
      _ChartBreakdownPembayaranSectionState();
}

class _ChartBreakdownPembayaranSectionState
    extends State<ChartBreakdownPembayaranSection> {
  int _touchedIndex = -1;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getColor(String metode) {
    if (metode == 'tunai') {
      return AppColors.success; // Kas / Tunai (Hijau Carbon)
    }
    return AppColors.primary; // Non Tunai / Transfer (Biru Carbon)
  }

  @override
  Widget build(BuildContext context) {
    Decimal totalAllNilai = Decimal.zero;
    int totalAllTrx = 0;

    BreakdownMetodePembayaran? tunaiItem;
    BreakdownMetodePembayaran? nonTunaiItem;

    for (final item in widget.data) {
      totalAllNilai += item.totalNilai;
      totalAllTrx += item.jumlahTransaksi;

      if (item.isTunai) {
        tunaiItem = item;
      } else if (item.isNonTunai) {
        nonTunaiItem = item;
      }
    }

    final items = [
      tunaiItem ??
          BreakdownMetodePembayaran(
            metode: 'tunai',
            jumlahTransaksi: 0,
            totalNilai: Decimal.zero,
            totalBeratBersihKg: Decimal.zero,
          ),
      nonTunaiItem ??
          BreakdownMetodePembayaran(
            metode: 'non_tunai',
            jumlahTransaksi: 0,
            totalNilai: Decimal.zero,
            totalBeratBersihKg: Decimal.zero,
          ),
    ];

    final hasData = totalAllNilai > Decimal.zero || totalAllTrx > 0;

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
                    'METODE PEMBAYARAN PEMBELIAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Proporsi Pembelian TBS: Tunai vs Non Tunai',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.inkSubtle,
                    ),
                  ),
                ],
              ),
              Text(
                'Total: ${CurrencyFormatter.format(totalAllNilai)}',
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
          !hasData
              ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'Belum ada data pembelian untuk periode ini.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.inkSubtle,
                      ),
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 450;

                    if (isCompact) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 155,
                            child: _buildPieChart(items, totalAllNilai),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120,
                            child: _buildLegendList(items, totalAllNilai),
                          ),
                        ],
                      );
                    }

                    return SizedBox(
                      height: 240,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildPieChart(items, totalAllNilai),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: _buildLegendList(items, totalAllNilai),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    List<BreakdownMetodePembayaran> items,
    Decimal totalAllNilai,
  ) {
    final double totalDouble = double.parse(totalAllNilai.toString());
    final hasTouch = _touchedIndex >= 0 && _touchedIndex < items.length;
    final touchedItem = hasTouch ? items[_touchedIndex] : null;
    final touchedColor = hasTouch ? _getColor(touchedItem!.metode) : null;
    final touchedPct = hasTouch && totalDouble > 0
        ? (double.parse(touchedItem!.totalNilai.toString()) / totalDouble * 100)
        : 0.0;

    final pie = PieChart(
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
        sections: List.generate(items.length, (i) {
          final isTouched = i == _touchedIndex;
          final fontSize = isTouched ? 12.0 : 10.5;
          final radius = isTouched ? 52.0 : 44.0;
          final item = items[i];
          final val = double.parse(item.totalNilai.toString());
          final percentage = totalAllNilai > Decimal.zero
              ? (val / double.parse(totalAllNilai.toString())) * 100
              : 0.0;
          final color = _getColor(item.metode);

          final titleText = isTouched
              ? '${percentage.toStringAsFixed(1)}%'
              : (percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '');

          return PieChartSectionData(
            color: color,
            value: val > 0 ? val : 0.0001,
            title: titleText,
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

    if (!hasTouch) return pie;

    return Stack(
      alignment: Alignment.center,
      children: [
        pie,
        IgnorePointer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 72),
                child: Text(
                  touchedItem!.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '${touchedPct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: touchedColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendList(
    List<BreakdownMetodePembayaran> items,
    Decimal totalAllNilai,
  ) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: items.length > 3,
      child: ListView.separated(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(right: 6, bottom: 4),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, i) {
          final item = items[i];
          final color = _getColor(item.metode);
          final val = double.parse(item.totalNilai.toString());
          final percentage = totalAllNilai > Decimal.zero
              ? (val / double.parse(totalAllNilai.toString())) * 100
              : 0.0;
          final isSelected = i == _touchedIndex;

          return InkWell(
            onTap: () {
              setState(() {
                _touchedIndex = _touchedIndex == i ? -1 : i;
              });
            },
            borderRadius: const BorderRadius.all(Radius.circular(2.0)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
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
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(2.0)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.format(item.totalNilai),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${percentage.toStringAsFixed(1)}% (${item.jumlahTransaksi} TRX)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? color : AppColors.inkSubtle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
