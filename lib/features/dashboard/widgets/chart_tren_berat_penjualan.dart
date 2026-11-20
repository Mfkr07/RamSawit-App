import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../models/dashboard_analytics.dart';

/// Widget Grafik Tren Berat Penjualan ke Pabrik 2 Garis (FR-5.6):
/// Menampilkan perbandingan Berat Kotor (kg) dan Berat Bersih (kg) dari `v_pengiriman_harian`.
class ChartTrenBeratPenjualanSection extends StatelessWidget {
  final List<PengirimanHarian> data;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;

  const ChartTrenBeratPenjualanSection({
    super.key,
    required this.data,
    this.startDate,
    this.endDate,
    this.isLoading = false,
  });

  List<PengirimanHarian> _prepareData() {
    if (data.isEmpty) return const [];
    final sortedData = List<PengirimanHarian>.from(data)
      ..sort((a, b) => a.tanggalKirim.compareTo(b.tanggalKirim));

    if (startDate == null || endDate == null) {
      return sortedData;
    }

    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    final totalDays = end.difference(start).inDays + 1;
    if (totalDays <= 0) return sortedData;

    final dataMap = <String, PengirimanHarian>{};
    for (final item in sortedData) {
      final key = item.tanggalKirim.toIso8601String().split('T').first;
      dataMap[key] = item;
    }

    return List.generate(totalDays, (index) {
      final currentDay = start.add(Duration(days: index));
      final key = currentDay.toIso8601String().split('T').first;
      return dataMap[key] ??
          PengirimanHarian(
            tanggalKirim: currentDay,
            jumlahPengiriman: 0,
            totalBeratKotorKg: Decimal.zero,
            totalBeratDitolakKg: Decimal.zero,
            totalBeratBersihKg: Decimal.zero,
            totalPotonganRp: Decimal.zero,
            totalNilaiJual: Decimal.zero,
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
                    'TREN BERAT PENJUALAN (PABRIK)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Volume pengiriman armada (kg)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.inkSubtle,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildLegend(
                    color: const Color(0xFF0072C3), // IBM Teal/Cyan (Dikirim)
                    label: 'Berat Dikirim',
                  ),
                  _buildLegend(
                    color: const Color(0xFF198038), // IBM Green (Bersih)
                    label: 'Berat Bersih',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: displayData.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data pengiriman dalam periode yang dipilih.',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSubtle),
                    ),
                  )
                : _buildLineChart(displayData),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

  Widget _buildLineChart(List<PengirimanHarian> displayData) {
    double maxVal = 1000;
    for (final item in displayData) {
      final k = item.totalBeratKotorKg.toDouble();
      final b = item.totalBeratBersihKg.toDouble();
      if (k > maxVal) maxVal = k;
      if (b > maxVal) maxVal = b;
    }
    final maxY = maxVal * 1.15;

    final spotsKotor = <FlSpot>[];
    final spotsBersih = <FlSpot>[];

    for (int i = 0; i < displayData.length; i++) {
      spotsKotor.add(FlSpot(i.toDouble(), displayData[i].totalBeratKotorKg.toDouble()));
      spotsBersih.add(FlSpot(i.toDouble(), displayData[i].totalBeratBersihKg.toDouble()));
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
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value >= 1000
                        ? '${(value / 1000).toStringAsFixed(1)}t'
                        : '${value.toStringAsFixed(0)}kg',
                    style: const TextStyle(fontSize: 10, color: AppColors.inkSubtle),
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
                if (index < 0 || index >= displayData.length) return const SizedBox.shrink();
                final date = displayData[index].tanggalKirim;
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    DateFormat('dd/MM', 'id_ID').format(date),
                    style: const TextStyle(fontSize: 10, color: AppColors.inkSubtle),
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
                final dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(item.tanggalKirim);

                if (spot.barIndex == 0) {
                  return LineTooltipItem(
                    '$dateStr\nDikirim: ${WeightFormatter.format(item.totalBeratKotorKg)}',
                    const TextStyle(color: Color(0xFF82CFFF), fontSize: 11, fontWeight: FontWeight.w600),
                  );
                } else {
                  return LineTooltipItem(
                    'Bersih: ${WeightFormatter.format(item.totalBeratBersihKg)}',
                    const TextStyle(color: Color(0xFF6FDC8C), fontSize: 11, fontWeight: FontWeight.w600),
                  );
                }
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // Garis Kotor
          LineChartBarData(
            spots: spotsKotor,
            isCurved: true,
            curveSmoothness: 0.25,
            color: const Color(0xFF0072C3),
            barWidth: 2.0,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          // Garis Bersih
          LineChartBarData(
            spots: spotsBersih,
            isCurved: true,
            curveSmoothness: 0.25,
            color: const Color(0xFF198038),
            barWidth: 2.5,
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
