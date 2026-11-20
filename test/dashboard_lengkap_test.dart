import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_repository.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/chart_breakdown_pabrik.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/chart_tren.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/chart_tren_berat_pembelian.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/chart_tren_berat_penjualan.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/dashboard_periode_bar.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/kartu_ringkasan.dart';
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

  group('Tugas Bagian 13: Dashboard Multi-Modul & Filter Periode Tests', () {
    test('DashboardPeriodeState calculates start and end dates correctly for all presets', () {
      final now = DateTime.now();

      // 1 Minggu (7 hari)
      final w1 = DashboardPeriodeState.fromPreset(DashboardPeriodePreset.satuMinggu);
      expect(w1.label, '1 Minggu');
      expect(w1.endDate.difference(w1.startDate).inDays, inInclusiveRange(6, 7));

      // 2 Minggu (14 hari)
      final w2 = DashboardPeriodeState.fromPreset(DashboardPeriodePreset.duaMinggu);
      expect(w2.label, '2 Minggu');
      expect(w2.endDate.difference(w2.startDate).inDays, inInclusiveRange(13, 14));

      // 1 Bulan (30 hari)
      final m1 = DashboardPeriodeState.fromPreset(DashboardPeriodePreset.satuBulan);
      expect(m1.label, '1 Bulan');
      expect(m1.endDate.difference(m1.startDate).inDays, inInclusiveRange(29, 30));

      // 3 Bulan (90 hari)
      final m3 = DashboardPeriodeState.fromPreset(DashboardPeriodePreset.tigaBulan);
      expect(m3.label, '3 Bulan');
      expect(m3.endDate.difference(m3.startDate).inDays, inInclusiveRange(89, 90));

      // 6 Bulan (180 hari)
      final m6 = DashboardPeriodeState.fromPreset(DashboardPeriodePreset.enamBulan);
      expect(m6.label, '6 Bulan');
      expect(m6.endDate.difference(m6.startDate).inDays, inInclusiveRange(179, 180));

      // 1 Tahun (365 hari)
      final y1 = DashboardPeriodeState.fromPreset(DashboardPeriodePreset.satuTahun);
      expect(y1.label, '1 Tahun');
      expect(y1.endDate.difference(y1.startDate).inDays, inInclusiveRange(364, 365));

      // Kustom
      final customStart = DateTime(now.year, 1, 1);
      final customEnd = DateTime(now.year, 1, 15);
      final custom = DashboardPeriodeState.fromPreset(
        DashboardPeriodePreset.kustom,
        customStart: customStart,
        customEnd: customEnd,
      );
      expect(custom.label, 'Kustom');
      expect(custom.startDate.day, 1);
      expect(custom.endDate.day, 15);
      expect(custom.startDateStr, contains('-01-01'));
    });

    test('Model Parsing & Serialization: PengirimanHarian, MarginHarian, BreakdownPabrik', () {
      // 1. PengirimanHarian
      final jsonKrm = {
        'tanggal_kirim': '2026-09-05',
        'jumlah_pengiriman': 2,
        'total_berat_kotor_kg': '17000.00',
        'total_berat_ditolak_kg': '300.00',
        'total_berat_bersih_kg': '16282.50',
        'total_potongan_rp': '1022625.00',
        'total_nilai_jual': '39892125.00',
      };
      final krm = PengirimanHarian.fromJson(jsonKrm);
      expect(krm.jumlahPengiriman, 2);
      expect(krm.totalBeratKotorKg, Decimal.parse('17000.00'));
      expect(krm.totalBeratBersihKg, Decimal.parse('16282.50'));
      expect(krm.totalNilaiJual, Decimal.parse('39892125.00'));

      final jsonKrmOut = krm.toJson();
      expect(jsonKrmOut['tanggal_kirim'], '2026-09-05');
      expect(jsonKrmOut['jumlah_pengiriman'], 2);

      // 2. MarginHarian
      final jsonMargin = {
        'tanggal': '2026-09-05',
        'total_pembelian': '35000000.00',
        'total_penjualan': '39892125.00',
        'margin': '4892125.00',
      };
      final margin = MarginHarian.fromJson(jsonMargin);
      expect(margin.totalPembelian, Decimal.parse('35000000.00'));
      expect(margin.totalPenjualan, Decimal.parse('39892125.00'));
      expect(margin.margin, Decimal.parse('4892125.00'));
      expect(margin.isSurplus, isTrue);

      // 3. BreakdownPabrik
      final jsonBreakdown = {
        'nama_pabrik': 'PT Sawit Inti Riau',
        'tanggal': '2026-09-05T00:00:00.000',
        'total_berat_kotor_kg': '16500.00',
        'total_berat_bersih_kg': '16000.00',
        'total_nilai_jual': '40800000.00',
      };
      final bp = BreakdownPabrik.fromJson(jsonBreakdown);
      expect(bp.namaPabrik, 'PT Sawit Inti Riau');
      expect(bp.totalBeratBersihKg, Decimal.parse('16000.00'));
      expect(bp.totalNilaiJual, Decimal.parse('40800000.00'));
    });

    test('DashboardRepository Demo Mode returns rich data for all views', () async {
      final repo = DashboardRepository(null);
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 30));

      final trxList = await repo.getTransaksiHarian(start, now);
      expect(trxList, isNotEmpty);
      expect(trxList.first.totalBeratKotorKg, greaterThan(Decimal.zero));
      expect(trxList.first.totalBeratBersihKg, greaterThan(Decimal.zero));

      final krmList = await repo.getPengirimanHarian(start, now);
      expect(krmList, isNotEmpty);
      expect(krmList.first.totalNilaiJual, greaterThan(Decimal.zero));

      final marginList = await repo.getMarginHarian(start, now);
      expect(marginList, isNotEmpty);

      final breakdownBuah = await repo.getBreakdownJenisBuah(start, now);
      expect(breakdownBuah.length, 3); // TB, TK, BR

      final breakdownPabrik = await repo.getBreakdownPabrik(start, now);
      expect(breakdownPabrik.length, 3); // 3 pabrik demo

      final recentKrm = await repo.getRecentPengiriman(limit: 5);
      expect(recentKrm, isNotEmpty);
    });

    testWidgets('DashboardPeriodeBar renders all presets and switches active preset', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('id', 'ID'),
            supportedLocales: [Locale('id', 'ID')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: DashboardPeriodeBar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('FILTER PERIODE GRAFIK & ANALITIK'), findsOneWidget);
      expect(find.byKey(const Key('filter_preset_hariIni')), findsOneWidget);
      expect(find.byIcon(Icons.date_range), findsOneWidget);
    });

    testWidgets('KartuRingkasanSection toggles between Pembelian, Penjualan, and Margin', (WidgetTester tester) async {
      final multi = MultiModulSummary(
        pembelian: DashboardSummary(
          hariIni: RingkasanPeriodik(
            label: 'Hari Ini',
            jumlahTransaksi: 3,
            totalBeratKotorKg: Decimal.parse('3150.00'),
            totalBeratBersihKg: Decimal.parse('3000.00'),
            totalNilai: Decimal.parse('7500000.00'),
          ),
          mingguIni: RingkasanPeriodik(
            label: 'Minggu Ini',
            jumlahTransaksi: 12,
            totalBeratKotorKg: Decimal.parse('12600.00'),
            totalBeratBersihKg: Decimal.parse('12000.00'),
            totalNilai: Decimal.parse('30000000.00'),
          ),
          bulanIni: RingkasanPeriodik(
            label: 'Bulan Ini',
            jumlahTransaksi: 45,
            totalBeratKotorKg: Decimal.parse('47250.00'),
            totalBeratBersihKg: Decimal.parse('45000.00'),
            totalNilai: Decimal.parse('112500000.00'),
          ),
        ),
        penjualan: DashboardSummary(
          hariIni: RingkasanPeriodik(
            label: 'Hari Ini',
            jumlahTransaksi: 1,
            totalBeratKotorKg: Decimal.parse('8500.00'),
            totalBeratBersihKg: Decimal.parse('8141.25'),
            totalNilai: Decimal.parse('19946062.50'),
          ),
          mingguIni: RingkasanPeriodik(
            label: 'Minggu Ini',
            jumlahTransaksi: 4,
            totalBeratKotorKg: Decimal.parse('34000.00'),
            totalBeratBersihKg: Decimal.parse('32565.00'),
            totalNilai: Decimal.parse('79784250.00'),
          ),
          bulanIni: RingkasanPeriodik(
            label: 'Bulan Ini',
            jumlahTransaksi: 15,
            totalBeratKotorKg: Decimal.parse('127500.00'),
            totalBeratBersihKg: Decimal.parse('122118.75'),
            totalNilai: Decimal.parse('299190937.50'),
          ),
        ),
        marginHariIni: RingkasanMarginPeriodik(
          label: 'Hari Ini',
          totalPembelian: Decimal.parse('7500000.00'),
          totalPenjualan: Decimal.parse('19946062.50'),
          margin: Decimal.parse('12446062.50'),
        ),
        marginMingguIni: RingkasanMarginPeriodik(
          label: 'Minggu Ini',
          totalPembelian: Decimal.parse('30000000.00'),
          totalPenjualan: Decimal.parse('79784250.00'),
          margin: Decimal.parse('49784250.00'),
        ),
        marginBulanIni: RingkasanMarginPeriodik(
          label: 'Bulan Ini',
          totalPembelian: Decimal.parse('112500000.00'),
          totalPenjualan: Decimal.parse('299190937.50'),
          margin: Decimal.parse('186690937.50'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('id', 'ID'),
            home: Scaffold(
              body: KartuRingkasanSection(multiSummary: multi),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tab default: Pembelian dari Petani
      expect(find.text('Pembelian dari Petani'), findsOneWidget);
      expect(find.text('Penjualan ke Pabrik'), findsOneWidget);
      expect(find.text('Margin Keuntungan'), findsOneWidget);

      expect(find.text('Rp 7.500.000'), findsOneWidget);
      expect(find.text('3 TRX'), findsOneWidget);
      expect(find.text('3.150,00 kg'), findsOneWidget); // Kotor
      expect(find.text('3.000,00 kg'), findsOneWidget); // Bersih

      // Pindah ke Tab Penjualan ke Pabrik
      await tester.tap(find.text('Penjualan ke Pabrik'));
      await tester.pumpAndSettle();

      expect(find.text('Rp 19.946.062'), findsOneWidget);
      expect(find.text('1 KRM'), findsOneWidget);
      expect(find.text('8.500,00 kg'), findsOneWidget); // Kotor

      // Pindah ke Tab Margin Keuntungan
      await tester.tap(find.text('Margin Keuntungan'));
      await tester.pumpAndSettle();

      expect(find.text('Rp 12.446.062'), findsWidgets);
      expect(find.text('SURPLUS'), findsWidgets);
    });

    testWidgets('Chart sections render without throwing exception', (WidgetTester tester) async {
      final now = DateTime.now();

      // Chart Tren Nilai (2 Garis)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartTrenSection(
              data: [
                MarginHarian(
                  tanggal: now.subtract(const Duration(days: 2)),
                  totalPembelian: Decimal.parse('5000000.00'),
                  totalPenjualan: Decimal.parse('7000000.00'),
                  margin: Decimal.parse('2000000.00'),
                ),
                MarginHarian(
                  tanggal: now,
                  totalPembelian: Decimal.parse('8000000.00'),
                  totalPenjualan: Decimal.parse('11000000.00'),
                  margin: Decimal.parse('3000000.00'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TREN NILAI: PEMBELIAN VS PENJUALAN'), findsOneWidget);

      // Chart Tren Berat Pembelian (2 Garis)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartTrenBeratPembelianSection(
              data: [
                TransaksiHarian(
                  tanggalTransaksi: now,
                  jumlahTransaksi: 2,
                  totalBeratKotorKg: Decimal.parse('2100.00'),
                  totalBeratBersihKg: Decimal.parse('2000.00'),
                  totalNilai: Decimal.parse('5000000.00'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TREN BERAT PEMBELIAN (PETANI)'), findsOneWidget);

      // Chart Tren Berat Penjualan (2 Garis)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartTrenBeratPenjualanSection(
              data: [
                PengirimanHarian(
                  tanggalKirim: now,
                  jumlahPengiriman: 1,
                  totalBeratKotorKg: Decimal.parse('8500.00'),
                  totalBeratDitolakKg: Decimal.parse('150.00'),
                  totalBeratBersihKg: Decimal.parse('8141.25'),
                  totalPotonganRp: Decimal.parse('511387.50'),
                  totalNilaiJual: Decimal.parse('19946062.50'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TREN BERAT PENJUALAN (PABRIK)'), findsOneWidget);

      // Chart Breakdown Pabrik
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartBreakdownPabrikSection(
              data: [
                BreakdownPabrik(
                  namaPabrik: 'PT Sawit Inti Riau',
                  tanggal: now,
                  totalBeratKotorKg: Decimal.parse('10000.00'),
                  totalBeratBersihKg: Decimal.parse('9800.00'),
                  totalNilaiJual: Decimal.parse('24000000.00'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('PROPORSI PENJUALAN PER PABRIK'), findsOneWidget);
    });
  });
}
