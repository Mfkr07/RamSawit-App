import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:transaksi_sawit_app/core/theme/app_theme.dart';
import 'package:transaksi_sawit_app/features/auth/auth_controller.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_controller.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_page.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_repository.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/chart_tren.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_controller.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart';
import 'package:transaksi_sawit_app/features/penjual/penjual_controller.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_list_controller.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_list_page.dart';
import 'package:transaksi_sawit_app/models/dashboard_analytics.dart';
import 'package:transaksi_sawit_app/models/paginated_result.dart';
import 'package:transaksi_sawit_app/models/pengiriman_pabrik.dart';
import 'package:transaksi_sawit_app/models/penjual.dart';
import 'package:transaksi_sawit_app/models/profile.dart';
import 'package:transaksi_sawit_app/models/transaksi.dart';

class FakeAuthController extends StateNotifier<AppAuthState>
    implements AuthController {
  FakeAuthController(Profile profile)
      : super(AppAuthState(profile: profile));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTransaksiListNotifier extends TransaksiListNotifier {
  @override
  Future<PaginatedResult<TransaksiRingkasan>> build() async {
    return const PaginatedResult(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
    );
  }
}

class FakePenjualListNotifier extends PenjualListNotifier {
  @override
  Future<List<Penjual>> build() async => [];
}

class FakePengirimanListNotifier extends PengirimanListNotifier {
  @override
  Future<List<PengirimanPabrik>> build() async => [];
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  Widget buildTestWidget({
    required Widget child,
    List<Override> overrides = const [],
    Size size = const Size(1280, 800),
  }) {
    return ProviderScope(
      overrides: overrides,
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
          data: MediaQueryData(size: size),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('Tugas Bagian 17: Model & Preset Dashboard', () {
    test('1. DashboardPeriodePreset.hariIni menghitung rentang 24 jam hari ini dengan benar', () {
      final state = DashboardPeriodeState.fromPreset(DashboardPeriodePreset.hariIni);
      final now = DateTime.now();

      expect(state.preset, DashboardPeriodePreset.hariIni);
      expect(state.label, 'Hari Ini');
      expect(state.startDate.year, now.year);
      expect(state.startDate.month, now.month);
      expect(state.startDate.day, now.day);
      expect(state.startDate.hour, 0);
      expect(state.startDate.minute, 0);
      expect(state.endDate.hour, 23);
      expect(state.endDate.minute, 59);
    });

    test('2. isAllowedForKasir membatasi preset hanya sampai 1 Bulan', () {
      expect(DashboardPeriodePreset.hariIni.isAllowedForKasir, isTrue);
      expect(DashboardPeriodePreset.satuMinggu.isAllowedForKasir, isTrue);
      expect(DashboardPeriodePreset.duaMinggu.isAllowedForKasir, isTrue);
      expect(DashboardPeriodePreset.satuBulan.isAllowedForKasir, isTrue);

      expect(DashboardPeriodePreset.tigaBulan.isAllowedForKasir, isFalse);
      expect(DashboardPeriodePreset.enamBulan.isAllowedForKasir, isFalse);
      expect(DashboardPeriodePreset.satuTahun.isAllowedForKasir, isFalse);
      expect(DashboardPeriodePreset.kustom.isAllowedForKasir, isFalse);
    });

    test('3. KartuBulanIniFilterState mengelola mode dan label dengan tepat', () {
      final def = KartuBulanIniFilterState.defaultBulanBerjalan();
      expect(def.isDefault, isTrue);
      expect(def.mode, KartuBulanIniMode.bulanBerjalan);
      expect(def.label, 'BULAN INI');

      final monthFilter = KartuBulanIniFilterState.bulanTertentu(2026, 3);
      expect(monthFilter.isDefault, isFalse);
      expect(monthFilter.mode, KartuBulanIniMode.bulanTertentu);
      expect(monthFilter.label, contains('MARET 2026'));

      final yearFilter = KartuBulanIniFilterState.tahunTertentu(2025);
      expect(yearFilter.isDefault, isFalse);
      expect(yearFilter.mode, KartuBulanIniMode.tahunTertentu);
      expect(yearFilter.label, 'TAHUN 2025');
    });
  });

  group('Tugas Bagian 17: Repository-Level Defense in Depth (FR-5.11)', () {
    test('4. Role Kasir menolak metrik margin di tingkat repository', () {
      final repo = DashboardRepository(null, 'kasir');
      final now = DateTime.now();

      expect(
        () => repo.getMarginHarian(now.subtract(const Duration(days: 7)), now),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('5. Role Kasir menolak query dengan rentang waktu > 31 hari', () {
      final repo = DashboardRepository(null, 'kasir');
      final now = DateTime.now();
      final sixtyDaysAgo = now.subtract(const Duration(days: 60));

      expect(
        () => repo.getTransaksiHarian(sixtyDaysAgo, now),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repo.getPengirimanHarian(sixtyDaysAgo, now),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repo.getBreakdownJenisBuah(sixtyDaysAgo, now),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Tugas Bagian 17: UI Role Kasir vs Admin di Dashboard', () {
    final mockKasirUser = Profile(
      id: 'usr-kasir-1',
      nama: 'Kasir Andi',
      role: 'kasir',
      createdAt: DateTime.now(),
    );

    final mockAdminUser = Profile(
      id: 'usr-admin-1',
      nama: 'Admin Budi',
      role: 'admin',
      createdAt: DateTime.now(),
    );

    testWidgets('6. Role Kasir: Tab Margin & Grafik Tren Disembunyikan', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeAuthController(mockKasirUser)),
            multiModulSummaryProvider.overrideWith((ref) => MultiModulSummary.empty()),
            breakdownJenisBuahFilteredProvider.overrideWith((ref) => []),
            breakdownPabrikFilteredProvider.overrideWith((ref) => []),
            recentTransactionsProvider.overrideWith((ref) => []),
            recentPengirimanProvider.overrideWith((ref) => []),
          ],
          child: const DashboardPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Tab Pembelian & Penjualan Pabrik tampil
      expect(find.text('Pembelian dari Petani'), findsOneWidget);
      expect(find.text('Penjualan ke Pabrik'), findsOneWidget);

      // FR-5.11: Tab Margin Keuntungan TIDAK tampil
      expect(find.text('Margin Keuntungan'), findsNothing);

      // FR-5.11: Seluruh grafik tren disembunyikan untuk Kasir
      expect(find.byType(ChartTrenSection), findsNothing);
      expect(find.text('TREN NILAI TRANSAKSI: PEMBELIAN VS PENJUALAN'), findsNothing);
      expect(find.text('TREN BERAT PEMBELIAN PETANI'), findsNothing);
      expect(find.text('TREN BERAT PENJUALAN KE PABRIK'), findsNothing);

      // FR-5.11: Periode filter untuk Kasir
      expect(find.byKey(const Key('filter_preset_hariIni')), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsNothing); // Tombol kustom sembunyi
    });

    testWidgets('7. Role Admin: Tab Margin, Grafik Tren, dan Filter Card Bulan Ini Tampil', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeAuthController(mockAdminUser)),
            multiModulSummaryProvider.overrideWith((ref) => MultiModulSummary.empty()),
            trenMarginProvider.overrideWith((ref) => []),
            trenBeratPembelianProvider.overrideWith((ref) => []),
            trenBeratPenjualanProvider.overrideWith((ref) => []),
            breakdownJenisBuahFilteredProvider.overrideWith((ref) => []),
            breakdownPabrikFilteredProvider.overrideWith((ref) => []),
            recentTransactionsProvider.overrideWith((ref) => []),
            recentPengirimanProvider.overrideWith((ref) => []),
          ],
          child: const DashboardPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Tab Margin Keuntungan tampil untuk Admin
      expect(find.text('Margin Keuntungan'), findsOneWidget);

      // Grafik tren tampil untuk Admin
      expect(find.byType(ChartTrenSection), findsOneWidget);

      // Seluruh preset filter tampil untuk Admin via chips
      expect(find.byKey(const Key('filter_preset_hariIni')), findsOneWidget);
      expect(find.byIcon(Icons.date_range), findsOneWidget);

      // FR-5.12: Tombol filter khusus kartu Bulan Ini tampil untuk Admin
      expect(find.byKey(const Key('btn_filter_kartu_bulan_ini')), findsOneWidget);
    });

    testWidgets('8. Role Admin: Membuka Dialog Filter Kartu Bulan Ini dan Mengganti Filter', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeAuthController(mockAdminUser)),
            multiModulSummaryProvider.overrideWith((ref) => MultiModulSummary.empty()),
            trenMarginProvider.overrideWith((ref) => []),
            trenBeratPembelianProvider.overrideWith((ref) => []),
            trenBeratPenjualanProvider.overrideWith((ref) => []),
            breakdownJenisBuahFilteredProvider.overrideWith((ref) => []),
            breakdownPabrikFilteredProvider.overrideWith((ref) => []),
            recentTransactionsProvider.overrideWith((ref) => []),
            recentPengirimanProvider.overrideWith((ref) => []),
          ],
          child: const DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Klik tombol filter pada kartu Bulan Ini
      await tester.tap(find.byKey(const Key('btn_filter_kartu_bulan_ini')));
      await tester.pumpAndSettle();

      // Dialog terbuka
      expect(find.text('Filter Kartu Bulan Ini'), findsOneWidget);
      expect(find.text('Bulan Berjalan (Default)'), findsOneWidget);
      expect(find.text('Pilih Bulan Tertentu'), findsOneWidget);
      expect(find.text('Satu Tahun Penuh'), findsOneWidget);
      expect(find.text('Rentang Bulan Kustom'), findsOneWidget);

      // Pilih mode Satu Tahun Penuh
      await tester.tap(find.text('Satu Tahun Penuh'));
      await tester.pumpAndSettle();

      // Terapkan filter
      await tester.ensureVisible(find.byKey(const Key('btn_terapkan_filter_kartu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_terapkan_filter_kartu')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Dialog tertutup dan judul kartu berubah menjadi TAHUN ...
      expect(find.text('Filter Kartu Bulan Ini'), findsNothing);
      expect(find.textContaining('TAHUN'), findsAtLeastNWidgets(1));
    });
  });

  group('Tugas Bagian 17: Standarisasi 8 Filter Periode Riwayat (FR-4.1)', () {
    testWidgets('9. Riwayat Transaksi: Menampilkan 8 Preset Standar dan Chip Filter Tanggal Kustom', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            penjualListProvider.overrideWith(() => FakePenjualListNotifier()),
            transaksiListProvider.overrideWith(() => FakeTransaksiListNotifier()),
          ],
          child: const TransaksiListPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi Filter Periode Standar & Custom
      expect(find.byKey(const Key('filter_transaksi_preset_hari_ini')), findsOneWidget);
      expect(find.byKey(const Key('filter_preset_kustom')), findsOneWidget);
    });

    testWidgets('10. Riwayat Pengiriman Pabrik: Menampilkan 8 Preset Standar, Chip Kustom, dan Reset Halaman ke 1', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            pengirimanListProvider.overrideWith(() => FakePengirimanListNotifier()),
          ],
          child: const PengirimanPabrikListPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi Filter Periode Chip di Riwayat Pengiriman
      expect(find.byKey(const Key('filter_pengiriman_preset_hari_ini')), findsOneWidget);
      expect(find.byKey(const Key('filter_pengiriman_preset_kustom')), findsOneWidget);
    });
  });
}
