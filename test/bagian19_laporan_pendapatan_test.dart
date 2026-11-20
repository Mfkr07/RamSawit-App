import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaksi_sawit_app/core/theme/app_theme.dart';
import 'package:transaksi_sawit_app/features/auth/auth_controller.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_page.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_repository.dart';
import 'package:transaksi_sawit_app/features/dashboard/export/export_laporan_pendapatan_dialog.dart';
import 'package:transaksi_sawit_app/features/dashboard/export/laporan_pendapatan_excel_generator.dart';
import 'package:transaksi_sawit_app/features/dashboard/export/laporan_pendapatan_pdf_generator.dart';
import 'package:transaksi_sawit_app/models/dashboard_analytics.dart';
import 'package:transaksi_sawit_app/models/laporan_pendapatan.dart';
import 'package:transaksi_sawit_app/models/profile.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_repository.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart';

class FakeAuthController extends StateNotifier<AppAuthState>
    implements AuthController {
  FakeAuthController(Profile profile)
      : super(AppAuthState(profile: profile, isInitialized: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('id_ID', null);
    DashboardRepository.enableDummySeedForTesting = true;
    TransaksiRepository.seedDemoDataForTesting();
    PengirimanPabrikRepository.seedDemoDataForTesting();
  });

  group('Tugas Bagian 19: Pengelompokan Data Laporan Pendapatan (FR-7.8)', () {
    test('1. Cakupan 1 Tahun: Dirangkum Kuartalan (4 baris kuartal)', () {
      final sampleDaily = [
        // Kuartal 1
        MarginHarian(
          tanggal: DateTime(2026, 1, 15),
          totalPembelian: Decimal.parse('10000000'),
          totalPenjualan: Decimal.parse('13000000'),
          margin: Decimal.parse('3000000'),
        ),
        MarginHarian(
          tanggal: DateTime(2026, 2, 20),
          totalPembelian: Decimal.parse('15000000'),
          totalPenjualan: Decimal.parse('18500000'),
          margin: Decimal.parse('3500000'),
        ),
        // Kuartal 2
        MarginHarian(
          tanggal: DateTime(2026, 4, 10),
          totalPembelian: Decimal.parse('20000000'),
          totalPenjualan: Decimal.parse('25000000'),
          margin: Decimal.parse('5000000'),
        ),
        // Kuartal 3
        MarginHarian(
          tanggal: DateTime(2026, 8, 5),
          totalPembelian: Decimal.parse('30000000'),
          totalPenjualan: Decimal.parse('38000000'),
          margin: Decimal.parse('8000000'),
        ),
        // Kuartal 4
        MarginHarian(
          tanggal: DateTime(2026, 11, 25),
          totalPembelian: Decimal.parse('12000000'),
          totalPenjualan: Decimal.parse('14000000'),
          margin: Decimal.parse('2000000'),
        ),
      ];

      final result = LaporanPendapatanAggregator.aggregate(
        dailyData: sampleDaily,
        cakupan: CakupanLaporanPendapatan.satuTahun,
        referenceDate: DateTime(2026, 9, 16),
      );

      expect(result.cakupan, CakupanLaporanPendapatan.satuTahun);
      expect(result.rows.length, 4);

      // Kuartal 1: 10jt + 15jt = 25jt beli; 13jt + 18.5jt = 31.5jt jual; margin = 6.5jt
      expect(result.rows[0].periodeLabel, contains('Kuartal 1'));
      expect(result.rows[0].totalPembelian, Decimal.parse('25000000'));
      expect(result.rows[0].totalPenjualan, Decimal.parse('31500000'));
      expect(result.rows[0].margin, Decimal.parse('6500000'));

      // Kuartal 2
      expect(result.rows[1].periodeLabel, contains('Kuartal 2'));
      expect(result.rows[1].totalPembelian, Decimal.parse('20000000'));
      expect(result.rows[1].totalPenjualan, Decimal.parse('25000000'));
      expect(result.rows[1].margin, Decimal.parse('5000000'));

      // Kuartal 3
      expect(result.rows[2].periodeLabel, contains('Kuartal 3'));
      expect(result.rows[2].totalPembelian, Decimal.parse('30000000'));
      expect(result.rows[2].totalPenjualan, Decimal.parse('38000000'));
      expect(result.rows[2].margin, Decimal.parse('8000000'));

      // Kuartal 4
      expect(result.rows[3].periodeLabel, contains('Kuartal 4'));
      expect(result.rows[3].totalPembelian, Decimal.parse('12000000'));
      expect(result.rows[3].totalPenjualan, Decimal.parse('14000000'));
      expect(result.rows[3].margin, Decimal.parse('2000000'));

      // Grand Total
      expect(result.grandTotalPembelian, Decimal.parse('87000000'));
      expect(result.grandTotalPenjualan, Decimal.parse('108500000'));
      expect(result.grandTotalMargin, Decimal.parse('21500000'));
      expect(result.isSurplus, true);
    });

    test('2. Cakupan 3 Bulan: Dirangkum Bulanan (3 baris bulan)', () {
      final sampleDaily = [
        // Juli 2026
        MarginHarian(
          tanggal: DateTime(2026, 7, 10),
          totalPembelian: Decimal.parse('10000000'),
          totalPenjualan: Decimal.parse('12500000'),
          margin: Decimal.parse('2500000'),
        ),
        // Agustus 2026
        MarginHarian(
          tanggal: DateTime(2026, 8, 1),
          totalPembelian: Decimal.parse('15000000'),
          totalPenjualan: Decimal.parse('19000000'),
          margin: Decimal.parse('4000000'),
        ),
        MarginHarian(
          tanggal: DateTime(2026, 8, 20),
          totalPembelian: Decimal.parse('5000000'),
          totalPenjualan: Decimal.parse('6200000'),
          margin: Decimal.parse('1200000'),
        ),
        // September 2026
        MarginHarian(
          tanggal: DateTime(2026, 9, 5),
          totalPembelian: Decimal.parse('8000000'),
          totalPenjualan: Decimal.parse('10000000'),
          margin: Decimal.parse('2000000'),
        ),
      ];

      final result = LaporanPendapatanAggregator.aggregate(
        dailyData: sampleDaily,
        cakupan: CakupanLaporanPendapatan.tigaBulan,
        referenceDate: DateTime(2026, 9, 16),
        selectedQuarter: 3, // Kuartal 3: Juli - September
      );

      expect(result.rows.length, 3);
      expect(result.rows[0].periodeLabel, 'Juli 2026');
      expect(result.rows[0].totalPembelian, Decimal.parse('10000000'));
      expect(result.rows[0].totalPenjualan, Decimal.parse('12500000'));
      expect(result.rows[0].margin, Decimal.parse('2500000'));

      expect(result.rows[1].periodeLabel, 'Agustus 2026');
      expect(result.rows[1].totalPembelian, Decimal.parse('20000000'));
      expect(result.rows[1].totalPenjualan, Decimal.parse('25200000'));
      expect(result.rows[1].margin, Decimal.parse('5200000'));

      expect(result.rows[2].periodeLabel, 'September 2026');
      expect(result.rows[2].totalPembelian, Decimal.parse('8000000'));
      expect(result.rows[2].totalPenjualan, Decimal.parse('10000000'));
      expect(result.rows[2].margin, Decimal.parse('2000000'));

      expect(result.grandTotalPembelian, Decimal.parse('38000000'));
      expect(result.grandTotalPenjualan, Decimal.parse('47700000'));
      expect(result.grandTotalMargin, Decimal.parse('9700000'));
    });

    test('3. Cakupan 1 Bulan: Dirangkum Mingguan (Minggu 1 s/d 5)', () {
      final sampleDaily = [
        // Minggu 1: 1 - 7 September
        MarginHarian(
          tanggal: DateTime(2026, 9, 2),
          totalPembelian: Decimal.parse('4000000'),
          totalPenjualan: Decimal.parse('5000000'),
          margin: Decimal.parse('1000000'),
        ),
        // Minggu 2: 8 - 14 September
        MarginHarian(
          tanggal: DateTime(2026, 9, 10),
          totalPembelian: Decimal.parse('6000000'),
          totalPenjualan: Decimal.parse('7500000'),
          margin: Decimal.parse('1500000'),
        ),
        // Minggu 3: 15 - 21 September
        MarginHarian(
          tanggal: DateTime(2026, 9, 18),
          totalPembelian: Decimal.parse('8000000'),
          totalPenjualan: Decimal.parse('10200000'),
          margin: Decimal.parse('2200000'),
        ),
        // Minggu 4: 22 - 28 September
        MarginHarian(
          tanggal: DateTime(2026, 9, 25),
          totalPembelian: Decimal.parse('5000000'),
          totalPenjualan: Decimal.parse('6300000'),
          margin: Decimal.parse('1300000'),
        ),
        // Minggu 5: 29 - 30 September (September ada 30 hari)
        MarginHarian(
          tanggal: DateTime(2026, 9, 30),
          totalPembelian: Decimal.parse('3000000'),
          totalPenjualan: Decimal.parse('3700000'),
          margin: Decimal.parse('700000'),
        ),
      ];

      final result = LaporanPendapatanAggregator.aggregate(
        dailyData: sampleDaily,
        cakupan: CakupanLaporanPendapatan.satuBulan,
        referenceDate: DateTime(2026, 9, 16),
      );

      // September 30 hari -> 5 baris minggu (1-7, 8-14, 15-21, 22-28, 29-30)
      expect(result.rows.length, 5);
      expect(result.rows[0].periodeLabel, contains('Minggu 1'));
      expect(result.rows[0].totalPembelian, Decimal.parse('4000000'));
      expect(result.rows[0].margin, Decimal.parse('1000000'));

      expect(result.rows[1].periodeLabel, contains('Minggu 2'));
      expect(result.rows[1].totalPembelian, Decimal.parse('6000000'));

      expect(result.rows[2].periodeLabel, contains('Minggu 3'));
      expect(result.rows[2].totalPembelian, Decimal.parse('8000000'));

      expect(result.rows[3].periodeLabel, contains('Minggu 4'));
      expect(result.rows[3].totalPembelian, Decimal.parse('5000000'));

      expect(result.rows[4].periodeLabel, contains('Minggu 5'));
      expect(result.rows[4].periodeLabel, contains('29 - 30'));
      expect(result.rows[4].totalPembelian, Decimal.parse('3000000'));

      // Verifikasi total
      expect(result.grandTotalPembelian, Decimal.parse('26000000'));
      expect(result.grandTotalPenjualan, Decimal.parse('32700000'));
      expect(result.grandTotalMargin, Decimal.parse('6700000'));
    });
  });

  group('Tugas Bagian 19: Generator File Excel & PDF (FR-7.8)', () {
    late LaporanPendapatanData testData;

    setUp(() {
      testData = LaporanPendapatanAggregator.aggregate(
        dailyData: [
          MarginHarian(
            tanggal: DateTime(2026, 9, 5),
            totalPembelian: Decimal.parse('10000000'),
            totalPenjualan: Decimal.parse('12500000'),
            margin: Decimal.parse('2500000'),
          ),
        ],
        cakupan: CakupanLaporanPendapatan.satuBulan,
        referenceDate: DateTime(2026, 9, 1),
      );
    });

    test('4. LaporanPendapatanExcelGenerator menghasilkan byte buffer valid', () {
      final bytes = LaporanPendapatanExcelGenerator.generate(data: testData);
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));

      final fileName = LaporanPendapatanExcelGenerator.generateFileName(
        cakupan: testData.cakupan,
        startDate: testData.startDate,
        endDate: testData.endDate,
      );
      expect(fileName, startsWith('Laporan-Pendapatan-satuBulan-'));
      expect(fileName, endsWith('.xlsx'));
    });

    test('5. LaporanPendapatanPdfGenerator menghasilkan byte buffer PDF valid', () async {
      final bytes = await LaporanPendapatanPdfGenerator.generate(data: testData);
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(200));

      final fileName = LaporanPendapatanPdfGenerator.generateFileName(
        cakupan: testData.cakupan,
        startDate: testData.startDate,
        endDate: testData.endDate,
      );
      expect(fileName, startsWith('Laporan-Pendapatan-satuBulan-'));
      expect(fileName, endsWith('.pdf'));
    });
  });

  group('Tugas Bagian 19: Hak Akses Role Admin vs Kasir (FR-5.11 & FR-7.8)', () {
    test('6. Kasir ditolak saat mencoba mengambil data margin di repository', () async {
      final kasirRepo = DashboardRepository(null, 'kasir');
      expect(
        () => kasirRepo.getMarginHarian(DateTime(2026, 1, 1), DateTime(2026, 1, 15)),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Kasir tidak memiliki hak akses ke data margin keuntungan'),
        )),
      );
    });

    test('7. Admin diizinkan mengambil data margin di repository', () async {
      final adminRepo = DashboardRepository(null, 'admin');
      final now = DateTime.now();
      final data = await adminRepo.getMarginHarian(
        now.subtract(const Duration(days: 30)),
        now,
      );
      expect(data, isNotEmpty);
    });

    testWidgets('8. Role Kasir: Tombol Laporan Pendapatan Disembunyikan di Dashboard',
        (WidgetTester tester) async {
      final kasirProfile = Profile(
        id: 'kasir-test-id',
        nama: 'Kasir Sawit',
        role: 'kasir',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              (ref) => FakeAuthController(kasirProfile),
            ),
            dashboardRepositoryProvider.overrideWithValue(
              DashboardRepository(null, 'kasir'),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('btn_export_laporan_pendapatan_dashboard')),
        findsNothing,
        reason: 'Kasir tidak boleh melihat tombol Laporan Pendapatan',
      );
    });

    testWidgets('9. Role Admin: Tombol Laporan Pendapatan Tampil di Dashboard',
        (WidgetTester tester) async {
      final adminProfile = Profile(
        id: 'admin-test-id',
        nama: 'Admin Sawit',
        role: 'admin',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              (ref) => FakeAuthController(adminProfile),
            ),
            dashboardRepositoryProvider.overrideWithValue(
              DashboardRepository(null, 'admin'),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('btn_export_laporan_pendapatan_dashboard')),
        findsOneWidget,
        reason: 'Admin harus melihat tombol Laporan Pendapatan',
      );
    });

    testWidgets('10. ExportLaporanPendapatanDialog me-render pratinjau data dan baris total',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardRepositoryProvider.overrideWithValue(
              DashboardRepository(null, 'admin'),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('id', 'ID')],
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: ExportLaporanPendapatanDialog(
                initialCakupan: CakupanLaporanPendapatan.satuBulan,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ekspor Laporan Pendapatan'), findsOneWidget);
      expect(find.text('Pilih Cakupan Periode:'), findsOneWidget);
      expect(find.text('1 Tahun'), findsOneWidget);
      expect(find.text('3 Bulan'), findsOneWidget);
      expect(find.text('1 Bulan'), findsOneWidget);
      expect(find.text('Total Keseluruhan'), findsOneWidget);
      expect(find.text('Microsoft Excel (.xlsx)'), findsOneWidget);
      expect(find.text('Dokumen PDF (.pdf)'), findsOneWidget);
    });
  });
}
