import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/sync/sync_status_bar.dart';
import '../auth/auth_controller.dart';
import '../transaksi/transaksi_form_page.dart';
import 'dashboard_controller.dart';
import 'export/export_laporan_pendapatan_dialog.dart';
import 'widgets/chart_breakdown.dart';
import 'widgets/chart_breakdown_pabrik.dart';
import 'widgets/chart_breakdown_pembayaran.dart';
import 'widgets/chart_breakdown_pengeluaran.dart';
import 'widgets/chart_tren.dart';
import 'widgets/chart_tren_berat_pembelian.dart';
import 'widgets/chart_tren_berat_penjualan.dart';
import 'widgets/dashboard_periode_bar.dart';
import 'widgets/dashboard_skeleton.dart';
import 'widgets/kartu_ringkasan.dart';
import 'widgets/list_transaksi_terakhir.dart';
import 'widgets/ai_quick_insight_banner.dart';

/// Halaman Utama Dashboard Analitik Terpadu (PRD §7.5 FR-5.1 s/d FR-5.10)
/// Menggabungkan modul Pembelian Petani, Penjualan ke Pabrik, dan Margin,
/// dengan satu komponen filter periode terpadu (reusable).
class DashboardPage extends ConsumerWidget {
  final VoidCallback? onNavigateToRiwayat;
  final VoidCallback? onNavigateToTransaksiBaru;
  final VoidCallback? onNavigateToPengiriman;
  final VoidCallback? onNavigateToAiAnalytics;
  final VoidCallback? onNavigateToLaporanPendapatan;

  const DashboardPage({
    super.key,
    this.onNavigateToRiwayat,
    this.onNavigateToTransaksiBaru,
    this.onNavigateToPengiriman,
    this.onNavigateToAiAnalytics,
    this.onNavigateToLaporanPendapatan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole =
        ref.watch(authControllerProvider).profile?.role ?? 'kasir';
    final isAdmin = userRole == 'admin';

    // 1. Kartu Multi-Modul (Hari Ini, Minggu Ini, Bulan Ini)
    final multiSummaryAsync = ref.watch(multiModulSummaryProvider);

    // 2. Grafik Tren & Breakdown (Reaktif mengikuti dashboardPeriodeProvider)
    final periode = ref.watch(debouncedDashboardPeriodeProvider);
    final trenMarginAsync = ref.watch(trenMarginProvider);
    final trenBeratBeliAsync = ref.watch(trenBeratPembelianProvider);
    final trenBeratJualAsync = ref.watch(trenBeratPenjualanProvider);
    final breakdownBuahAsync = ref.watch(breakdownJenisBuahFilteredProvider);
    final breakdownPabrikAsync = ref.watch(breakdownPabrikFilteredProvider);
    final breakdownPengeluaranAsync =
        ref.watch(breakdownPengeluaranFilteredProvider);
    final breakdownPembayaranAsync =
        ref.watch(breakdownPembayaranFilteredProvider);

    // 3. List 10 Transaksi & Pengiriman Terakhir
    final recentTrxAsync = ref.watch(recentTransactionsProvider);
    final recentKrmAsync = ref.watch(recentPengirimanProvider);

    return Scaffold(
      backgroundColor: AppColors.surface1,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: SafeArea(
          bottom: false,
          child: SyncStatusBar(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshDashboard(ref);
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Dashboard Enterprise
              _buildHeader(context, ref, isAdmin),
              const SizedBox(height: 18),

              // 1. Kartu Ringkasan KPI Multi-Modul (Hari Ini, Minggu Ini, Bulan Ini)
              multiSummaryAsync.when(
                loading: () => const DashboardKpiSkeleton(),
                error: (err, _) =>
                    _buildErrorCard('Gagal memuat ringkasan KPI: $err'),
                data: (multi) => KartuRingkasanSection(multiSummary: multi),
              ),
              const SizedBox(height: 18),

              // 1b. Banner Cepat Asisten Analitik AI (Fase 2)
              AiQuickInsightBanner(
                onOpenAiAnalytics: onNavigateToAiAnalytics,
              ),

              // 2. Komponen Filter Periode Reusable (1W, 2W, 1M, 3M, 6M, 1Y, Kustom)
              const DashboardPeriodeBar(),
              const SizedBox(height: 16),

              // 3 & 4. Grafik Tren (FR-5.11: Hanya tampil untuk Admin, sembunyikan untuk Kasir)
              if (isAdmin) ...[
                // 3. Grafik Tren Nilai Transaksi: Pembelian vs Penjualan (FR-5.4)
                trenMarginAsync.when(
                  loading: () => const DashboardChartSkeleton(height: 290),
                  error: (err, _) => _buildErrorCard(
                      'Gagal memuat tren perbandingan nilai: $err'),
                  data: (marginList) => ChartTrenSection(
                    data: marginList,
                    startDate: periode.startDate,
                    endDate: periode.endDate,
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Baris Grafik Tren Berat: Pembelian vs Penjualan (FR-5.5 & FR-5.6)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 950;

                    final widgetBeratBeli = trenBeratBeliAsync.when(
                      loading: () => const DashboardChartSkeleton(height: 280),
                      error: (err, _) => _buildErrorCard(
                          'Gagal memuat tren berat pembelian: $err'),
                      data: (dataBeli) => ChartTrenBeratPembelianSection(
                        data: dataBeli,
                        startDate: periode.startDate,
                        endDate: periode.endDate,
                      ),
                    );

                    final widgetBeratJual = trenBeratJualAsync.when(
                      loading: () => const DashboardChartSkeleton(height: 280),
                      error: (err, _) => _buildErrorCard(
                          'Gagal memuat tren berat penjualan: $err'),
                      data: (dataJual) => ChartTrenBeratPenjualanSection(
                        data: dataJual,
                        startDate: periode.startDate,
                        endDate: periode.endDate,
                      ),
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: widgetBeratBeli),
                          const SizedBox(width: 16),
                          Expanded(child: widgetBeratJual),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        widgetBeratBeli,
                        const SizedBox(height: 16),
                        widgetBeratJual,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // 5. Baris Grafik Breakdown: Jenis Buah & Pabrik Tujuan (FR-5.7 & FR-5.8)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 950;

                  final widgetBreakdownBuah = breakdownBuahAsync.when(
                    loading: () => const DashboardChartSkeleton(height: 300),
                    error: (err, _) => _buildErrorCard(
                        'Gagal memuat breakdown jenis buah: $err'),
                    data: (dataBuah) => ChartBreakdownSection(data: dataBuah),
                  );

                  final widgetBreakdownPabrik = breakdownPabrikAsync.when(
                    loading: () => const DashboardChartSkeleton(height: 300),
                    error: (err, _) => _buildErrorCard(
                        'Gagal memuat breakdown pabrik tujuan: $err'),
                    data: (dataPabrik) =>
                        ChartBreakdownPabrikSection(data: dataPabrik),
                  );

                  final widgetBreakdownPengeluaran = breakdownPengeluaranAsync.when(
                    loading: () => const DashboardChartSkeleton(height: 300),
                    error: (err, _) => _buildErrorCard(
                        'Gagal memuat breakdown pengeluaran: $err'),
                    data: (dataPengeluaran) =>
                        ChartBreakdownPengeluaranSection(data: dataPengeluaran),
                  );

                  final widgetBreakdownPembayaran = breakdownPembayaranAsync.when(
                    loading: () => const DashboardChartSkeleton(height: 300),
                    error: (err, _) => _buildErrorCard(
                        'Gagal memuat metode pembayaran pembelian: $err'),
                    data: (dataPembayaran) =>
                        ChartBreakdownPembayaranSection(data: dataPembayaran),
                  );

                  if (isDesktop) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: widgetBreakdownBuah),
                            const SizedBox(width: 16),
                            Expanded(child: widgetBreakdownPabrik),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: widgetBreakdownPembayaran),
                            if (isAdmin) ...[
                              const SizedBox(width: 16),
                              Expanded(child: widgetBreakdownPengeluaran),
                            ],
                          ],
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      widgetBreakdownBuah,
                      const SizedBox(height: 16),
                      widgetBreakdownPabrik,
                      const SizedBox(height: 16),
                      widgetBreakdownPembayaran,
                      if (isAdmin) ...[
                        const SizedBox(height: 16),
                        widgetBreakdownPengeluaran,
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // 6. List 10 Transaksi Pembelian & Pengiriman Pabrik Terakhir (FR-5.9)
              recentTrxAsync.when(
                loading: () => const DashboardListSkeleton(height: 250),
                error: (err, _) => _buildErrorCard(
                    'Gagal memuat daftar transaksi terakhir: $err'),
                data: (recentList) {
                  final recentKrmList = recentKrmAsync.value ?? [];
                  return ListTransaksiTerakhirSection(
                    items: recentList,
                    pengirimanItems: recentKrmList,
                    onLihatSemuaPressed: onNavigateToRiwayat,
                    onLihatSemuaPengirimanPressed: onNavigateToPengiriman,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isAdmin) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 750;

        final titleColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'DASHBOARD ANALITIK TERPADU',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Pemantauan terintegrasi: Pembelian Petani, Penjualan Pabrik, dan Margin Usaha',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        );

        final actionButtons = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Tombol Refresh Data
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.canvas,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                side: const BorderSide(color: AppColors.hairline),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text(
                'Segarkan',
                style: TextStyle(fontSize: 12),
              ),
              onPressed: () => refreshDashboard(ref),
            ),

            // Tombol Pintas Transaksi Baru
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Transaksi Baru',
                style: TextStyle(fontSize: 12),
              ),
              onPressed: () {
                if (onNavigateToTransaksiBaru != null) {
                  onNavigateToTransaksiBaru!();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TransaksiFormPage(),
                    ),
                  );
                }
              },
            ),

            // Tombol Ekspor Laporan Pendapatan (Khusus Admin)
            if (isAdmin)
              ElevatedButton.icon(
                key: const Key('btn_export_laporan_pendapatan_dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.canvas,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  side: const BorderSide(color: AppColors.primary),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
                icon: const Icon(Icons.trending_up, size: 16),
                label: const Text(
                  'Laporan Pendapatan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  if (onNavigateToLaporanPendapatan != null) {
                    onNavigateToLaporanPendapatan!();
                  } else {
                    ExportLaporanPendapatanDialog.show(context);
                  }
                },
              ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleColumn,
              const SizedBox(height: 12),
              actionButtons,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleColumn),
            const SizedBox(width: 16),
            actionButtons,
          ],
        );
      },
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
