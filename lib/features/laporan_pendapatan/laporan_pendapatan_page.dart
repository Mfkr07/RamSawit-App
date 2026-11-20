import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../dashboard/export/export_laporan_pendapatan_dialog.dart';
import 'laporan_pendapatan_controller.dart';
import 'laporan_pendapatan_state.dart';

/// Laman khusus monitoring Laporan Pendapatan & Laba Bersih Harian
/// Dilengkapi filter periode standar, kustom tanggal, KPI card, dan tabel harian.
class LaporanPendapatanPage extends ConsumerWidget {
  const LaporanPendapatanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(laporanPendapatanControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(laporanPendapatanControllerProvider.notifier).loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, ref, state),
              const SizedBox(height: 16),
              _buildFilterSection(context, ref, state),
              const SizedBox(height: 16),
              _buildSummaryCards(context, state),
              const SizedBox(height: 16),
              _buildDailyTableSection(context, ref, state),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. HEADER SECTION
  // ==========================================
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    LaporanPendapatanState state,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Laporan Pendapatan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Monitoring pendapatan harian, selisih margin jual-beli, beban operasional, dan laba bersih riil.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        );

        final actionButtons = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.file_download_outlined, size: 16),
              label: const Text('Ekspor Laporan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                ExportLaporanPendapatanDialog.show(
                  context,
                  startDate: state.startDate,
                  endDate: state.endDate,
                  presetLabel: state.periodLabel,
                  initialDailyData: state.dailyList,
                );
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Segarkan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.inkMuted,
                side: const BorderSide(color: AppColors.hairline),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () => ref
                  .read(laporanPendapatanControllerProvider.notifier)
                  .loadData(),
            ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              actionButtons,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            actionButtons,
          ],
        );
      },
    );
  }

  // ==========================================
  // 2. FILTER PERIODE SECTION
  // ==========================================
  Widget _buildFilterSection(
    BuildContext context,
    WidgetRef ref,
    LaporanPendapatanState state,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'id_ID');
    final longDateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    final presets = [
      ('hari_ini', 'Hari Ini (Default)'),
      ('1_minggu', '1 Minggu'),
      ('2_minggu', '2 Minggu'),
      ('1_bulan', '1 Bulan'),
      ('3_bulan', '3 Bulan'),
      ('6_bulan', '6 Bulan'),
      ('1_tahun', '1 Tahun'),
      ('semua', 'Semua'),
    ];

    final isCustomOrSingle = state.hasActiveFilter;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined,
                  size: 16, color: AppColors.inkMuted),
              const SizedBox(width: 6),
              const Text(
                'FILTER PERIODE PENDAPATAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (isCustomOrSingle)
                TextButton.icon(
                  icon: const Icon(Icons.restore, size: 14),
                  label: const Text('Reset ke Hari Ini',
                      style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    ref
                        .read(laporanPendapatanControllerProvider.notifier)
                        .resetToToday();
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Presets standar
              ...presets.map((p) {
                final isSelected = state.datePreset == p.$1;
                return ChoiceChip(
                  label: Text(p.$2),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(laporanPendapatanControllerProvider.notifier)
                          .applyPreset(p.$1);
                    }
                  },
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.ink,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),

              // Tombol Pilih Hari Spesifik (1 Tanggal)
              ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 13),
                label: Text(
                  state.datePreset == 'harian_spesifik'
                      ? 'Hari: ${dateFormat.format(state.startDate)}'
                      : 'Pilih Hari Spesifik',
                ),
                backgroundColor: state.datePreset == 'harian_spesifik'
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                  side: BorderSide(
                    color: state.datePreset == 'harian_spesifik'
                        ? AppColors.primary
                        : AppColors.hairline,
                  ),
                ),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: state.datePreset == 'harian_spesifik'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: state.datePreset == 'harian_spesifik'
                      ? AppColors.primary
                      : AppColors.ink,
                ),
                onPressed: () async {
                  final initialPickerDate = state.datePreset == 'harian_spesifik'
                      ? state.startDate
                      : (state.dailyList.isNotEmpty
                          ? state.dailyList.first.tanggal
                          : DateTime.now());
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initialPickerDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    helpText: 'Pilih Tanggal Pendapatan Harian',
                    cancelText: 'Batal',
                    confirmText: 'Pilih',
                  );
                  if (picked != null) {
                    ref
                        .read(laporanPendapatanControllerProvider.notifier)
                        .applySingleDate(picked);
                  }
                },
              ),

              // Tombol Rentang Kustom (Date Range)
              ActionChip(
                avatar: const Icon(Icons.date_range, size: 13),
                label: Text(
                  state.datePreset == 'kustom'
                      ? '${dateFormat.format(state.startDate)} - ${dateFormat.format(state.endDate)}'
                      : 'Rentang Kustom',
                ),
                backgroundColor: state.datePreset == 'kustom'
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                  side: BorderSide(
                    color: state.datePreset == 'kustom'
                        ? AppColors.primary
                        : AppColors.hairline,
                  ),
                ),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: state.datePreset == 'kustom'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: state.datePreset == 'kustom'
                      ? AppColors.primary
                      : AppColors.ink,
                ),
                onPressed: () async {
                  final initialStart = state.datePreset == 'kustom'
                      ? state.startDate
                      : (state.dailyList.isNotEmpty
                          ? state.dailyList.last.tanggal
                          : DateTime.now().subtract(const Duration(days: 7)));
                  final initialEnd = state.datePreset == 'kustom'
                      ? state.endDate
                      : DateTime.now();

                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: DateTimeRange(
                      start: initialStart.isBefore(initialEnd)
                          ? initialStart
                          : initialEnd,
                      end: initialEnd,
                    ),
                    helpText: 'Pilih Rentang Tanggal Kustom',
                    cancelText: 'Batal',
                    confirmText: 'Terapkan',
                  );
                  if (picked != null) {
                    ref
                        .read(laporanPendapatanControllerProvider.notifier)
                        .applyCustomRange(picked.start, picked.end);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Info rentang aktif
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline,
                    size: 13, color: AppColors.inkMuted),
                const SizedBox(width: 6),
                Text(
                  'Periode Aktif: ${longDateFormat.format(state.startDate)} s/d ${longDateFormat.format(state.endDate)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. KPI SUMMARY CARDS
  // ==========================================
  Widget _buildSummaryCards(
    BuildContext context,
    LaporanPendapatanState state,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        int crossAxisCount = 5;
        if (w < 600) {
          crossAxisCount = 1;
        } else if (w < 950) {
          crossAxisCount = 2;
        } else if (w < 1200) {
          crossAxisCount = 3;
        }

        final cards = [
          _SummaryMetricCard(
            title: 'TOTAL PENJUALAN',
            subtitle: 'Hasil jual ke pabrik (PKS)',
            value: CurrencyFormatter.format(state.totalPenjualan),
            icon: Icons.local_shipping_outlined,
            accentColor: const Color(0xFF0F62FE), // Blue
          ),
          _SummaryMetricCard(
            title: 'TOTAL PEMBELIAN',
            subtitle: 'Beli TBS dari petani',
            value: CurrencyFormatter.format(state.totalPembelian),
            icon: Icons.receipt_long,
            accentColor: const Color(0xFF8A3FFC), // Purple
          ),
          _SummaryMetricCard(
            title: 'MARGIN KOTOR',
            subtitle: '${state.marginPercentage.toStringAsFixed(1)}% dari penjualan',
            value: CurrencyFormatter.format(state.totalMargin),
            icon: Icons.trending_up,
            accentColor: state.isMarginSurplus
                ? const Color(0xFF007D79) // Teal
                : AppColors.error,
          ),
          _SummaryMetricCard(
            title: 'BIAYA OPERASIONAL',
            subtitle: 'Pengeluaran kas operasional',
            value: CurrencyFormatter.format(state.totalPengeluaran),
            icon: Icons.money_off,
            accentColor: const Color(0xFFFF832B), // Orange
          ),
          _SummaryMetricCard(
            title: 'LABA BERSIH RIIL',
            subtitle:
                '${state.labaBersihPercentage.toStringAsFixed(1)}% margin bersih',
            value: CurrencyFormatter.format(state.totalLabaBersih),
            icon: Icons.account_balance_wallet,
            accentColor: state.isLabaBersihSurplus
                ? AppColors.success
                : AppColors.error,
            isHighlighted: true,
          ),
        ];

        if (crossAxisCount == 1) {
          return Column(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: c,
                    ))
                .toList(),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards.map((c) {
            final cardWidth =
                (w - ((crossAxisCount - 1) * 12)) / crossAxisCount;
            return SizedBox(
              width: cardWidth,
              child: c,
            );
          }).toList(),
        );
      },
    );
  }

  // ==========================================
  // 4. DAILY BREAKDOWN TABLE SECTION
  // ==========================================
  Widget _buildDailyTableSection(
    BuildContext context,
    WidgetRef ref,
    LaporanPendapatanState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table header bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.table_chart_outlined,
                    size: 16, color: AppColors.inkMuted),
                const SizedBox(width: 8),
                const Text(
                  'RINCIAN PENDAPATAN PER HARI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Text(
                    '${state.dailyList.length} Hari Terdata',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: Icon(
                    state.sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 14,
                  ),
                  label: Text(
                    state.sortDescending
                        ? 'Urutan: Terbaru'
                        : 'Urutan: Terlama',
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.inkMuted,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () {
                    ref
                        .read(laporanPendapatanControllerProvider.notifier)
                        .toggleSortOrder();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.hairline),

          // Content body
          if (state.isLoading)
            Container(
              padding: const EdgeInsets.all(48),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(height: 12),
                  Text(
                    'Memuat rincian laporan pendapatan harian...',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                ],
              ),
            )
          else if (state.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onPressed: () => ref
                        .read(laporanPendapatanControllerProvider.notifier)
                        .loadData(),
                  ),
                ],
              ),
            )
          else if (state.dailyList.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.event_busy,
                      size: 40, color: AppColors.inkMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada rekaman pendapatan pada periode ini.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pastikan sudah ada data transaksi pembelian TBS atau pengiriman pabrik yang tersimpan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(laporanPendapatanControllerProvider.notifier)
                          .applyPreset('semua');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Lihat Seluruh Periode'),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 768) {
                  return _buildMobileDailyList(context, state);
                }
                return _buildDesktopTable(context, state);
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. DESKTOP / TABLET DATA TABLE
  // ==========================================
  Widget _buildDesktopTable(
    BuildContext context,
    LaporanPendapatanState state,
  ) {
    final dateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');
    final items = state.sortedDailyList;

    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2.2), // Tanggal
            1: FlexColumnWidth(1.8), // Pembelian
            2: FlexColumnWidth(1.8), // Penjualan
            3: FlexColumnWidth(1.8), // Margin
            4: FlexColumnWidth(1.6), // Biaya
            5: FlexColumnWidth(1.8), // Laba Bersih
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header Row
            TableRow(
              decoration: const BoxDecoration(
                color: AppColors.surface1,
                border: Border(
                  bottom: BorderSide(color: AppColors.hairline),
                ),
              ),
              children: [
                _th('TANGGAL', textAlign: TextAlign.left),
                _th('PEMBELIAN TBS', textAlign: TextAlign.right),
                _th('PENJUALAN PABRIK', textAlign: TextAlign.right),
                _th('MARGIN KOTOR', textAlign: TextAlign.right),
                _th('BIAYA OPERASIONAL', textAlign: TextAlign.right),
                _th('LABA BERSIH', textAlign: TextAlign.right),
              ],
            ),

            // Data Rows
            ...items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isEven = idx % 2 == 0;

              return TableRow(
                decoration: BoxDecoration(
                  color: isEven ? Colors.white : AppColors.canvas.withValues(alpha: 0.5),
                  border: const Border(
                    bottom: BorderSide(color: AppColors.hairline, width: 0.5),
                  ),
                ),
                children: [
                  // Tanggal
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(item.tanggal),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pembelian TBS
                  _td(
                    CurrencyFormatter.format(item.totalPembelian),
                    textAlign: TextAlign.right,
                    color: AppColors.ink,
                  ),

                  // Penjualan Pabrik
                  _td(
                    CurrencyFormatter.format(item.totalPenjualan),
                    textAlign: TextAlign.right,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),

                  // Margin Kotor
                  _td(
                    '${item.isMarginSurplus ? '+' : ''}${CurrencyFormatter.format(item.margin)}',
                    textAlign: TextAlign.right,
                    color: item.isMarginSurplus
                        ? const Color(0xFF007D79)
                        : AppColors.error,
                  ),

                  // Biaya Operasional
                  _td(
                    CurrencyFormatter.format(item.totalPengeluaran),
                    textAlign: TextAlign.right,
                    color: const Color(0xFFFF832B),
                  ),

                  // Laba Bersih
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.isLabaBersihSurplus
                              ? const Color(0xFFDEFBE6)
                              : const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${item.isLabaBersihSurplus ? '+' : ''}${CurrencyFormatter.format(item.labaBersih)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: item.isLabaBersihSurplus
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),

            // Grand Total Footer Row
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.surface1,
                border: const Border(
                  top: BorderSide(color: AppColors.hairline, width: 1.5),
                ),
              ),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL KESELURUHAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Akumulasi periode aktif',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _td(
                  CurrencyFormatter.format(state.totalPembelian),
                  textAlign: TextAlign.right,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
                _td(
                  CurrencyFormatter.format(state.totalPenjualan),
                  textAlign: TextAlign.right,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                _td(
                  '${state.isMarginSurplus ? '+' : ''}${CurrencyFormatter.format(state.totalMargin)}',
                  textAlign: TextAlign.right,
                  fontWeight: FontWeight.bold,
                  color: state.isMarginSurplus
                      ? const Color(0xFF007D79)
                      : AppColors.error,
                ),
                _td(
                  CurrencyFormatter.format(state.totalPengeluaran),
                  textAlign: TextAlign.right,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF832B),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: state.isLabaBersihSurplus
                            ? AppColors.success
                            : AppColors.error,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${state.isLabaBersihSurplus ? '+' : ''}${CurrencyFormatter.format(state.totalLabaBersih)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // 6. MOBILE CARD LIST VIEW
  // ==========================================
  Widget _buildMobileDailyList(
    BuildContext context,
    LaporanPendapatanState state,
  ) {
    final dateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');
    final items = state.sortedDailyList;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length + 1, // +1 untuk kartu grand total
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.hairline),
      itemBuilder: (context, index) {
        if (index == items.length) {
          // Kartu Grand Total di paling bawah
          return Container(
            color: AppColors.surface1,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL AKUMULASI PERIODE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(Icons.functions, size: 16, color: AppColors.inkMuted),
                  ],
                ),
                const SizedBox(height: 10),
                _buildMobileRow(
                    'Beli TBS:', CurrencyFormatter.format(state.totalPembelian)),
                const SizedBox(height: 4),
                _buildMobileRow(
                    'Jual Pabrik:', CurrencyFormatter.format(state.totalPenjualan),
                    valueColor: AppColors.primary),
                const SizedBox(height: 4),
                _buildMobileRow(
                  'Margin Kotor:',
                  '${state.isMarginSurplus ? '+' : ''}${CurrencyFormatter.format(state.totalMargin)}',
                  valueColor: state.isMarginSurplus
                      ? const Color(0xFF007D79)
                      : AppColors.error,
                ),
                const SizedBox(height: 4),
                _buildMobileRow('Biaya Operasional:',
                    CurrencyFormatter.format(state.totalPengeluaran),
                    valueColor: const Color(0xFFFF832B)),
                const Divider(height: 12, color: AppColors.hairline),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LABA BERSIH TOTAL:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${state.isLabaBersihSurplus ? '+' : ''}${CurrencyFormatter.format(state.totalLabaBersih)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: state.isLabaBersihSurplus
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final item = items[index];

        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(item.tanggal),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.isLabaBersihSurplus
                          ? const Color(0xFFDEFBE6)
                          : const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${item.isLabaBersihSurplus ? '+' : ''}${CurrencyFormatter.format(item.labaBersih)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.isLabaBersihSurplus
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  children: [
                    _buildMobileRow('Beli TBS:',
                        CurrencyFormatter.format(item.totalPembelian)),
                    const SizedBox(height: 4),
                    _buildMobileRow('Jual Pabrik:',
                        CurrencyFormatter.format(item.totalPenjualan),
                        valueColor: AppColors.primary),
                    const SizedBox(height: 4),
                    _buildMobileRow(
                      'Margin Kotor:',
                      '${item.isMarginSurplus ? '+' : ''}${CurrencyFormatter.format(item.margin)}',
                      valueColor: item.isMarginSurplus
                          ? const Color(0xFF007D79)
                          : AppColors.error,
                    ),
                    const SizedBox(height: 4),
                    _buildMobileRow(
                      'Biaya Operasional:',
                      CurrencyFormatter.format(item.totalPengeluaran),
                      valueColor: const Color(0xFFFF832B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TABLE HELPERS
  // ==========================================
  static Widget _th(String text, {TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        text,
        textAlign: textAlign,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.inkMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static Widget _td(
    String text, {
    TextAlign textAlign = TextAlign.left,
    Color color = AppColors.ink,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 12,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}

/// Kartu Ringkasan Metrik Finansial (KPI Card)
class _SummaryMetricCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool isHighlighted;

  const _SummaryMetricCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? accentColor.withValues(alpha: 0.05)
            : Colors.white,
        border: Border.all(
          color: isHighlighted
              ? accentColor.withValues(alpha: 0.4)
              : AppColors.hairline,
          width: isHighlighted ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? accentColor : AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
