import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_repository.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/chart_tren.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/chart_tren_berat_pembelian.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/chart_tren_berat_penjualan.dart';
import 'package:transaksi_sawit_app/models/dashboard_analytics.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_repository.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    DashboardRepository.enableDummySeedForTesting = true;
    TransaksiRepository.seedDemoDataForTesting();
    PengirimanPabrikRepository.seedDemoDataForTesting();
  });

  group('Verifikasi Fix: Arah Kronologis & Skala Periode Diagram Tren', () {
    test('DashboardRepository returns demo data sorted strictly ascending', () async {
      final repo = DashboardRepository(null, 'admin');
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 90));

      final trxList = await repo.getTransaksiHarian(start, now);
      for (int i = 0; i < trxList.length - 1; i++) {
        expect(
          trxList[i].tanggalTransaksi.isBefore(trxList[i + 1].tanggalTransaksi) ||
              trxList[i].tanggalTransaksi.isAtSameMomentAs(trxList[i + 1].tanggalTransaksi),
          isTrue,
        );
      }

      final krmList = await repo.getPengirimanHarian(start, now);
      for (int i = 0; i < krmList.length - 1; i++) {
        expect(
          krmList[i].tanggalKirim.isBefore(krmList[i + 1].tanggalKirim) ||
              krmList[i].tanggalKirim.isAtSameMomentAs(krmList[i + 1].tanggalKirim),
          isTrue,
        );
      }

      final marginList = await repo.getMarginHarian(start, now);
      for (int i = 0; i < marginList.length - 1; i++) {
        expect(
          marginList[i].tanggal.isBefore(marginList[i + 1].tanggal) ||
              marginList[i].tanggal.isAtSameMomentAs(marginList[i + 1].tanggal),
          isTrue,
        );
      }
    });

    testWidgets('ChartTrenSection scales to full period and places older dates on the left', (tester) async {
      final startDate = DateTime(2026, 6, 21);
      final endDate = DateTime(2026, 9, 20); // 92 days total

      // Data only exists for 2 days in September
      final sampleData = [
        MarginHarian(
          tanggal: DateTime(2026, 9, 1),
          totalPembelian: Decimal.parse('10000000.00'),
          totalPenjualan: Decimal.parse('12000000.00'),
          margin: Decimal.parse('2000000.00'),
        ),
        MarginHarian(
          tanggal: DateTime(2026, 9, 19),
          totalPembelian: Decimal.parse('15000000.00'),
          totalPenjualan: Decimal.parse('18000000.00'),
          margin: Decimal.parse('3000000.00'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartTrenSection(
              data: sampleData,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lineChartFinder = find.byType(LineChart);
      expect(lineChartFinder, findsOneWidget);

      final lineChart = tester.widget<LineChart>(lineChartFinder);
      // minX is 0, maxX is 91 (92 days - 1)
      expect(lineChart.data.minX, 0.0);
      expect(lineChart.data.maxX, 91.0);

      // Verify spot count covers the full 92 days
      expect(lineChart.data.lineBarsData.first.spots.length, 92);
      // First day (index 0) has 0 value (June 21)
      expect(lineChart.data.lineBarsData.first.spots[0].y, 0.0);
      // Sep 1 is day index 72, has 10,000,000
      final sep1Index = DateTime(2026, 9, 1).difference(startDate).inDays;
      expect(lineChart.data.lineBarsData.first.spots[sep1Index].y, 10000000.0);
    });

    testWidgets('ChartTrenBeratPembelianSection scales to period range', (tester) async {
      final startDate = DateTime(2026, 9, 14);
      final endDate = DateTime(2026, 9, 20); // 7 days (1 Minggu)

      final sampleData = [
        TransaksiHarian(
          tanggalTransaksi: DateTime(2026, 9, 15),
          jumlahTransaksi: 3,
          totalBeratKotorKg: Decimal.parse('3000.00'),
          totalBeratBersihKg: Decimal.parse('2900.00'),
          totalPotonganRp: Decimal.parse('150000.00'),
          totalNilai: Decimal.parse('6000000.00'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartTrenBeratPembelianSection(
              data: sampleData,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lineChartFinder = find.byType(LineChart);
      expect(lineChartFinder, findsOneWidget);

      final lineChart = tester.widget<LineChart>(lineChartFinder);
      expect(lineChart.data.minX, 0.0);
      expect(lineChart.data.maxX, 6.0); // 7 days - 1
      expect(lineChart.data.lineBarsData.first.spots.length, 7);
    });

    testWidgets('ChartTrenBeratPenjualanSection scales to period range', (tester) async {
      final startDate = DateTime(2026, 9, 14);
      final endDate = DateTime(2026, 9, 20); // 7 days (1 Minggu)

      final sampleData = [
        PengirimanHarian(
          tanggalKirim: DateTime(2026, 9, 17),
          jumlahPengiriman: 1,
          totalBeratKotorKg: Decimal.parse('8000.00'),
          totalBeratDitolakKg: Decimal.zero,
          totalBeratBersihKg: Decimal.parse('7900.00'),
          totalPotonganRp: Decimal.zero,
          totalNilaiJual: Decimal.parse('20000000.00'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartTrenBeratPenjualanSection(
              data: sampleData,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lineChartFinder = find.byType(LineChart);
      expect(lineChartFinder, findsOneWidget);

      final lineChart = tester.widget<LineChart>(lineChartFinder);
      expect(lineChart.data.minX, 0.0);
      expect(lineChart.data.maxX, 6.0); // 7 days - 1
      expect(lineChart.data.lineBarsData.first.spots.length, 7);
    });
  });
}
