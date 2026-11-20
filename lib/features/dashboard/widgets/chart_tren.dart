import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/dashboard_analytics.dart';

/// Widget Grafik Tren Nilai Transaksi Harian 2 Garis (FR-5.4):
/// Membandingkan Total Nilai Pembelian (Petani) vs Total Nilai Penjualan (Pabrik)
/// bersumber dari `v_margin_harian`, mengikuti filter periode aktif.
class ChartTrenSection extends StatelessWidget {
  final List<MarginHarian> data;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;

  const ChartTrenSection({
    super.key,
    required this.data,
    this.startDate,
    this.endDate,
    this.isLoading = false,
  });

  List<MarginHarian> _prepareData() {
    if (data.isEmpty) return const [];
    final sortedData = List<MarginHarian>.from(data)
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    if (startDate == null || endDate == null) {
      return sortedData;
    }

    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    final totalDays = end.difference(start).inDays + 1;
    if (totalDays <= 0) return sortedData;

    final dataMap = <String, MarginHarian>{};
    for (final item in sortedData) {
      final key = item.tanggal.toIso8601String().split('T').first;
      dataMap[key] = item;
    }

    return List.generate(totalDays, (index) {
      final currentDay = start.add(Duration(days: index));
      final key = currentDay.toIso8601String().split('T').first;
      return dataMap[key] ??
          MarginHarian(
            tanggal: currentDay,
            totalPembelian: Decimal.zero,
            totalPenjualan: Decimal.zero,
            margin: Decimal.zero,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _prepareData();

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
          // Header Card & Legenda
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TREN NILAI: PEMBELIAN VS PENJUALAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Perbandingan omzet harian (Rp)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.inkSubtle,
                    ),
                  ),
                ],
              ),
              // Legenda 2 Garis
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildLegendBadge(
                    color: AppColors.primary,
                    label: 'Pembelian (Petani)',
                  ),
                  _buildLegendBadge(
                    color: const Color(0xFF198038), // IBM Green
                    label: 'Penjualan (Pabrik)',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Area LineChart
          SizedBox(
            height: 240,
            child: displayData.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data transaksi dalam periode yang dipilih.',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSubtle),
                    ),
                  )
                : _buildLineChart(displayData),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBadge({required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<MarginHarian> displayData) {
    double maxVal = 1000000;
    for (final item in displayData) {
      final b = item.totalPembelian.toDouble();
      final j = item.totalPenjualan.toDouble();
      if (b > maxVal) maxVal = b;
      if (j > maxVal) maxVal = j;
    }
    final maxY = maxVal * 1.15;

    final spotsPembelian = <FlSpot>[];
    final spotsPenjualan = <FlSpot>[];

    for (int i = 0; i < displayData.length; i++) {
      spotsPembelian.add(FlSpot(i.toDouble(), displayData[i].totalPembelian.toDouble()));
      spotsPenjualan.add(FlSpot(i.toDouble(), displayData[i].totalPenjualan.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: AppColors.hairline,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: maxY > 0 ? maxY / 4 : 1,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                String text;
                if (value >= 1000000) {
                  text = '${(value / 1000000).toStringAsFixed(1)}jt';
                } else if (value >= 1000) {
                  text = '${(value / 1000).toStringAsFixed(0)}rb';
                } else {
                  text = value.toStringAsFixed(0);
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.inkSubtle,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: _calculateBottomInterval(displayData.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= displayData.length) {
                  return const SizedBox.shrink();
                }
                final date = displayData[index].tanggal;
                final f = DateFormat('dd/MM', 'id_ID');
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    f.format(date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.inkSubtle,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: AppColors.hairline, width: 1),
            left: BorderSide(color: AppColors.hairline, width: 1),
          ),
        ),
        minX: 0,
        maxX: (displayData.length - 1).toDouble().clamp(0.0, double.infinity),
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.ink,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= displayData.length) return null;
                final item = displayData[index];
                final dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(item.tanggal);

                if (spot.barIndex == 0) {
                  // Pembelian
                  return LineTooltipItem(
                    '$dateStr\nBeli: ${CurrencyFormatter.format(item.totalPembelian)}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                } else {
                  // Penjualan
                  return LineTooltipItem(
                    'Jual: ${CurrencyFormatter.format(item.totalPenjualan)}',
                    const TextStyle(
                      color: Color(0xFF6FDC8C), // Light green
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // Garis 1: Pembelian (IBM Blue)
          LineChartBarData(
            spots: spotsPembelian,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: displayData.length <= 15,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: AppColors.primary,
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          // Garis 2: Penjualan (IBM Green)
          LineChartBarData(
            spots: spotsPenjualan,
            isCurved: true,
            curveSmoothness: 0.25,
            color: const Color(0xFF198038),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: displayData.length <= 15,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: const Color(0xFF198038),
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF198038).withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBottomInterval(int length) {
    if (length <= 7) return 1.0;
    if (length <= 14) return 2.0;
    if (length <= 31) return 5.0;
    if (length <= 90) return 15.0;
    if (length <= 180) return 30.0;
    return 60.0;
  }
}
