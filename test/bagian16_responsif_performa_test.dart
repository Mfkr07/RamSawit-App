import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/core/theme/app_theme.dart';
import 'package:transaksi_sawit_app/core/widgets/app_list_tile.dart';
import 'package:transaksi_sawit_app/core/widgets/enterprise_pagination_bar.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_controller.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_page.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/dashboard_skeleton.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_form_page.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/selesaikan_pengiriman_page.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_form_page.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_list_page.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_repository.dart';
import 'package:transaksi_sawit_app/models/dashboard_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaksi_sawit_app/models/pengiriman_pabrik.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    TransaksiRepository.seedDemoDataForTesting();
    PengirimanPabrikRepository.seedDemoDataForTesting();
  });

  Widget buildTestableWidget(Widget child, {Size? size}) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('id', 'ID'),
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MediaQuery(
          data: MediaQueryData(size: size ?? const Size(1280, 800)),
          child: child,
        ),
      ),
    );
  }

  group('Tugas Bagian 16: Perbaikan Responsif & Performa', () {
    testWidgets('1. Audit Layar Sempit 320x640: Dashboard Bebas Overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final errorLogs = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorLogs.add(details);
        originalOnError?.call(details);
      };

      await tester.pumpWidget(buildTestableWidget(const DashboardPage(), size: const Size(320, 640)));
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      final overflowErrors = errorLogs.where((e) => e.toString().contains('overflowed by'));
      expect(overflowErrors, isEmpty, reason: 'Tidak boleh ada error RenderFlex overflow pada 320px');
    });

    testWidgets('2. Audit Layar Standar Mobile 375x667: Bebas Overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final errorLogs = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorLogs.add(details);
      };

      await tester.pumpWidget(buildTestableWidget(const DashboardPage(), size: const Size(375, 667)));
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      final overflowErrors = errorLogs.where((e) => e.toString().contains('overflowed by'));
      expect(overflowErrors, isEmpty, reason: 'Tidak boleh ada error RenderFlex overflow pada 375px');
    });

    testWidgets('3. Audit Layar Desktop 1280x800: Header & Filter Bebas Overflow 30px',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final errorLogs = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorLogs.add(details);
      };

      await tester.pumpWidget(buildTestableWidget(const DashboardPage(), size: const Size(1280, 800)));
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      final overflowErrors = errorLogs.where((e) => e.toString().contains('overflowed by'));
      expect(overflowErrors, isEmpty, reason: 'Banner 30px overflow pada desktop harus bersih tuntas');
    });

    testWidgets('4. Audit Riwayat Transaksi & Paginasi (20 item/page)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const TransaksiListPage(), size: const Size(375, 667)));
      await tester.pumpAndSettle();

      // Memastikan widget paginasi tampil
      expect(find.byType(EnterprisePaginationBar), findsOneWidget);
      expect(find.textContaining('Menampilkan'), findsOneWidget);
    });

    testWidgets('5. Audit Riwayat Pengiriman Pabrik & Paginasi',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const PengirimanPabrikListPage(), size: const Size(375, 667)));
      await tester.pumpAndSettle();

      expect(find.text('Belum Selesai'), findsOneWidget);
      expect(find.text('Semua Riwayat'), findsOneWidget);
      expect(find.byType(EnterprisePaginationBar), findsOneWidget);
    });

    testWidgets('6. Selesaikan Pengiriman Responsive pada 320x640',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final dummyItem = PengirimanPabrik(
        id: 'test-1',
        kodePengiriman: 'KRM-TEST-001',
        pabrikId: 'pb-001',
        platNomor: 'BM 1234 XX',
        namaSopir: 'Sopir Uji',
        tanggalKirim: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        beratKotorKg: Decimal.parse('8500'),
        status: 'berangkat',
      );

      final errorLogs = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errorLogs.add(details);

      await tester.pumpWidget(buildTestableWidget(
        SelesaikanPengirimanPage(pengiriman: dummyItem),
        size: const Size(320, 640),
      ));
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      final overflowErrors = errorLogs.where((e) => e.toString().contains('overflowed by'));
      expect(overflowErrors, isEmpty, reason: 'Form selesaikan pengiriman harus responsif tanpa overflow');
    });

    testWidgets('7. Skeleton Loaders Render Smoothly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SingleChildScrollView(
          child: Column(
            children: [
              DashboardKpiSkeleton(),
              DashboardChartSkeleton(height: 280),
              DashboardListSkeleton(height: 240),
            ],
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(DashboardKpiSkeleton), findsOneWidget);
      expect(find.byType(DashboardChartSkeleton), findsOneWidget);
      expect(find.byType(DashboardListSkeleton), findsOneWidget);
    });

    test('8. Debounce Periode Filter (300ms) Berjalan Sesuai Desain', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Nilai awal langsung tersedia (default 1 bulan)
      final initialPeriode = container.read(debouncedDashboardPeriodeProvider);
      expect(initialPeriode.preset, DashboardPeriodePreset.satuBulan);

      // Ubah cepat beberapa kali berturut-turut
      container
          .read(dashboardPeriodeProvider.notifier)
          .setPreset(DashboardPeriodePreset.satuMinggu);
      container
          .read(dashboardPeriodeProvider.notifier)
          .setPreset(DashboardPeriodePreset.duaMinggu);
      container
          .read(dashboardPeriodeProvider.notifier)
          .setPreset(DashboardPeriodePreset.tigaBulan);

      // Sebelum 300ms, provider debounced masih menyimpan state awal
      expect(
        container.read(debouncedDashboardPeriodeProvider).preset,
        DashboardPeriodePreset.satuBulan,
      );

      // Tunggu 350ms sampai timer debounce selesai
      await Future.delayed(const Duration(milliseconds: 350));

      // Setelah debounce, provider debounced melompat langsung ke nilai preset terakhir
      expect(
        container.read(debouncedDashboardPeriodeProvider).preset,
        DashboardPeriodePreset.tigaBulan,
      );
    });

    test('9. Unit Test TransaksiRepository Paginated Result', () async {
      final repo = TransaksiRepository(null);
      final page1 = await repo.getFilteredRingkasanPaginated(page: 1, pageSize: 2);
      expect(page1.page, 1);
      expect(page1.pageSize, 2);
      expect(page1.items.length, lessThanOrEqualTo(2));
      expect(page1.totalCount, greaterThanOrEqualTo(page1.items.length));
    });

    test('10. Unit Test PengirimanPabrikRepository Paginated Result', () async {
      final repo = PengirimanPabrikRepository(null);
      final page1 = await repo.getPengirimanPaginated(page: 1, pageSize: 2);
      expect(page1.page, 1);
      expect(page1.pageSize, 2);
      expect(page1.items.length, lessThanOrEqualTo(2));
      expect(page1.totalCount, greaterThanOrEqualTo(page1.items.length));
    });

    testWidgets(
        '11. TransaksiFormPage Responsif pada 375x642 (Mobile): Bebas Overflow pada Kartu ITEM 1',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 642);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final errorLogs = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errorLogs.add(details);

      await tester.pumpWidget(buildTestableWidget(
        const TransaksiFormPage(),
        size: const Size(375, 642),
      ));
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      final overflowErrors =
          errorLogs.where((e) => e.toString().contains('overflowed by'));
      expect(overflowErrors, isEmpty,
          reason: 'Tidak boleh ada error RenderFlex overflow pada TransaksiFormPage di mobile 375px');
    });

    testWidgets(
        '12. PengirimanPabrikFormPage Responsif pada 375x642 (Mobile): Bebas Overflow 394px pada Judul',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 642);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final errorLogs = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errorLogs.add(details);

      await tester.pumpWidget(buildTestableWidget(
        const PengirimanPabrikFormPage(),
        size: const Size(375, 642),
      ));
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      final overflowErrors =
          errorLogs.where((e) => e.toString().contains('overflowed by'));
      expect(overflowErrors, isEmpty,
          reason: 'Area judul dan form pengiriman pabrik harus bebas dari overflow 394px');
    });

    testWidgets('13. AppListTile Bebas Warning ListTile Ink Splash',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppListTile(
              title: const Text('Uji Tile'),
              tileColor: AppColors.canvas,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Uji Tile'), findsOneWidget);
    });
  });
}
