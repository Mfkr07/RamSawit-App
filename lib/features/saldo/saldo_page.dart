import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/pemakaian_saldo_harian.dart';
import '../../models/topup_saldo.dart';
import '../auth/auth_controller.dart';
import 'export/export_laporan_saldo_dialog.dart';
import 'saldo_controller.dart';
import 'saldo_filter_state.dart';
import 'widgets/topup_form_modal.dart';

/// Halaman utama Saldo / Dana Modal (PRD §7.10, Database.md §11)
/// Khusus role Administrator (FR-10.8).
class SaldoPage extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToRiwayatTransaksi;

  const SaldoPage({
    super.key,
    this.onNavigateToRiwayatTransaksi,
  });

  @override
  ConsumerState<SaldoPage> createState() => _SaldoPageState();
}

class _SaldoPageState extends ConsumerState<SaldoPage> {
  bool _isFilterExpanded = false;

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(authControllerProvider).profile;

    // RBAC: Hanya role Admin yang dapat mengakses modul ini (FR-10.8)
    if (userProfile?.isAdmin != true) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gpp_bad_outlined, size: 48, color: AppColors.error),
                SizedBox(height: 16),
                Text(
                  'Akses Ditolak',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Halaman Saldo / Dana Modal hanya dapat diakses oleh Administrator.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final saldoState = ref.watch(saldoControllerProvider);
    final filterState = ref.watch(saldoFilterProvider);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(saldoControllerProvider.notifier).loadData(refreshRingkasan: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Halaman & Tombol Aksi Utama
              _buildPageHeader(context, isMobile, filterState),
              const SizedBox(height: 16),

              // Error Banner jika ada kendala
              if (saldoState.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    border: Border.all(color: AppColors.error),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 20, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          saldoState.errorMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: () => ref
                            .read(saldoControllerProvider.notifier)
                            .loadData(refreshRingkasan: true),
                      ),
                    ],
                  ),
                ),

              // 2. Filter Periode & Kategori Saldo (Default: Hari Ini) (FR-10.4)
              if (isMobile) ...[
                OutlinedButton.icon(
                  key: const Key('toggle_filter_saldo_btn'),
                  onPressed: () {
                    setState(() {
                      _isFilterExpanded = !_isFilterExpanded;
                    });
                  },
                  icon: Icon(
                    _isFilterExpanded
                        ? Icons.tune
                        : Icons.filter_alt_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isFilterExpanded
                              ? 'Tutup Panel Filter Saldo'
                              : 'Filter Saldo: ${_activePresetLabel(filterState.datePreset)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _isFilterExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.inkMuted,
                      ),
                    ],
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(0, 38),
                    side: const BorderSide(color: AppColors.hairline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (_isFilterExpanded) ...[
                  const SizedBox(height: 8),
                  _buildFilterSection(context, ref, filterState, saldoState),
                ],
              ] else
                _buildFilterSection(context, ref, filterState, saldoState),
              const SizedBox(height: 16),

              // 3. Kartu KPI Ringkasan Saldo Berdasarkan Filter Periode (FR-10.2, FR-10.6)
              _buildKpiSummaryCards(saldoState, filterState, isMobile),
              const SizedBox(height: 24),

              // 4. Riwayat Aktivitas & Penggunaan Saldo (+ Top Up per aksi, - Pemakaian per hari)
              _buildRiwayatMutasiSection(context, saldoState, filterState, ref),
            ],
          ),
        ),
      ),
    );
  }

  String _activePresetLabel(String preset) {
    switch (preset) {
      case 'hari_ini':
        return 'Hari Ini';
      case '1_minggu':
        return '1 Minggu';
      case '2_minggu':
        return '2 Minggu';
      case '1_bulan':
        return '1 Bulan';
      case '3_bulan':
        return '3 Bulan';
      case '6_bulan':
        return '6 Bulan';
      case '1_tahun':
        return '1 Tahun';
      case 'semua':
        return 'Semua';
      case 'kustom':
        return 'Kustom';
      default:
        return preset;
    }
  }

  Widget _buildPageHeader(
    BuildContext context,
    bool isMobile,
    SaldoFilterState filterState,
  ) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SALDO / DANA MODAL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pemantauan kas modal pembelian kelapa sawit dari petani.',
            style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('shortcut_riwayat_pembelian_button'),
                icon: const Icon(Icons.history, size: 16),
                label: const Text('Riwayat Pembelian', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.hairline),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onPressed: widget.onNavigateToRiwayatTransaksi,
              ),
              OutlinedButton.icon(
                key: const Key('export_laporan_saldo_button'),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export Laporan', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onPressed: () {
                  ExportLaporanSaldoDialog.show(
                    context,
                    startDate: filterState.startDate,
                    endDate: filterState.endDate,
                  );
                },
              ),
              ElevatedButton.icon(
                key: const Key('top_up_saldo_button'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Top Up Kas / Modal', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onPressed: () => TopupFormModal.show(context),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'SALDO / DANA MODAL',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Pemantauan kas modal pembelian kelapa sawit dari petani (monitoring saja, tanpa pemblokiran).',
                style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            // Tombol Lihat Riwayat Transaksi Pembelian (FR-10.5)
            OutlinedButton.icon(
              key: const Key('shortcut_riwayat_pembelian_button'),
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Riwayat Pembelian'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.hairline),
              ),
              onPressed: widget.onNavigateToRiwayatTransaksi,
            ),
            // Tombol Export Laporan (FR-10.9)
            OutlinedButton.icon(
              key: const Key('export_laporan_saldo_button'),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export Laporan'),
              onPressed: () {
                ExportLaporanSaldoDialog.show(
                  context,
                  startDate: filterState.startDate,
                  endDate: filterState.endDate,
                );
              },
            ),
            // Tombol Catat Top Up Baru (FR-10.1)
            ElevatedButton.icon(
              key: const Key('tambah_topup_button'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Top Up Saldo'),
              onPressed: () => TopupFormModal.show(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    WidgetRef ref,
    SaldoFilterState filterState,
    SaldoState saldoState,
  ) {
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

    final activeTab = saldoState.activeTab;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              const Icon(Icons.filter_list, size: 16, color: AppColors.inkMuted),
              const SizedBox(width: 6),
              const Text(
                'FILTER & KATEGORI SALDO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (filterState.hasActiveFilter)
                TextButton(
                  onPressed: () {
                    ref.read(saldoFilterProvider.notifier).reset();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Kembali ke Hari Ini', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 12),
            // Filter Baris 1: Preset Waktu Asli
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final p in presets)
                  ChoiceChip(
                    key: Key('filter_saldo_preset_${p.$1}'),
                    label: Text(p.$2),
                    selected: filterState.datePreset == p.$1,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(saldoFilterProvider.notifier)
                            .applyDatePreset(p.$1);
                      }
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: filterState.datePreset == p.$1
                          ? Colors.white
                          : AppColors.ink,
                    ),
                    backgroundColor: AppColors.surface1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: filterState.datePreset == p.$1
                            ? AppColors.primary
                            : AppColors.hairline,
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: now,
                      initialDateRange: filterState.startDate != null &&
                              filterState.endDate != null
                          ? DateTimeRange(
                              start: filterState.startDate!,
                              end: filterState.endDate!,
                            )
                          : DateTimeRange(
                              start: now.subtract(const Duration(days: 7)),
                              end: now,
                            ),
                    );
                    if (picked != null) {
                      ref
                          .read(saldoFilterProvider.notifier)
                          .setCustomDateRange(picked.start, picked.end);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    side: BorderSide(
                      color: filterState.datePreset == 'kustom'
                          ? AppColors.primary
                          : AppColors.hairline,
                    ),
                    backgroundColor: filterState.datePreset == 'kustom'
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  icon: Icon(
                    Icons.date_range,
                    size: 14,
                    color: filterState.datePreset == 'kustom'
                        ? AppColors.primary
                        : AppColors.inkMuted,
                  ),
                  label: Text(
                    filterState.datePreset == 'kustom'
                        ? 'Kustom (Aktif)'
                        : 'Kustom Tanggal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: filterState.datePreset == 'kustom'
                          ? AppColors.primary
                          : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.hairline),
          const SizedBox(height: 10),
          // Filter Baris 2: Dropdown Kategori Mutasi Saldo
          Row(
            children: [
              const Text(
                'Kategori Aktivitas:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: activeTab,
                      items: [
                        DropdownMenuItem(
                          value: 'semua',
                          child: Text(
                            'Semua Aktivitas (${saldoState.mutasiList.length})',
                            style: const TextStyle(fontSize: 12, color: AppColors.ink),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'topup',
                          child: Text(
                            'Top Up Saja (+) (${saldoState.topupList.length})',
                            style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'pemakaian',
                          child: Text(
                            'Pemakaian Harian (-) (${saldoState.pemakaianHarianList.length} Hari)',
                            style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'non_tunai',
                          child: Text(
                            'Non Tunai (${saldoState.nonTunaiHarianList.length} Hari)',
                            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(saldoControllerProvider.notifier).setActiveTab(val);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(SaldoFilterState filter) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    switch (filter.datePreset) {
      case 'hari_ini':
        return 'Hari Ini (${dateFormat.format(DateTime.now())})';
      case '1_minggu':
        return '1 Minggu Terakhir';
      case '2_minggu':
        return '2 Minggu Terakhir';
      case '1_bulan':
        return '1 Bulan Terakhir';
      case '3_bulan':
        return '3 Bulan Terakhir';
      case '6_bulan':
        return '6 Bulan Terakhir';
      case '1_tahun':
        return '1 Tahun Terakhir';
      case 'kustom':
        if (filter.startDate != null && filter.endDate != null) {
          return '${dateFormat.format(filter.startDate!)} - ${dateFormat.format(filter.endDate!)}';
        }
        return 'Rentang Kustom';
      case 'semua':
      default:
        return 'Seluruh Periode';
    }
  }

  Widget _buildKpiSummaryCards(
    SaldoState state,
    SaldoFilterState filterState,
    bool isMobile,
  ) {
    final ringkasan = state.ringkasan;
    final isLowOrExhausted = ringkasan.isLowOrExhausted;
    final periodLabel = _getPeriodLabel(filterState);

    final cards = [
      // KARTU 1: Sisa Saldo Kas Modal (Kumulatif Riil Saat Ini) (FR-10.2, FR-10.6)
      Expanded(
        flex: isMobile ? 0 : 4,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isLowOrExhausted ? const Color(0xFFFFF1F1) : Colors.white,
            border: Border.all(
              color: isLowOrExhausted ? AppColors.error : AppColors.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: (isLowOrExhausted ? AppColors.error : AppColors.primary)
                    .withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SISA SALDO KAS MODAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isLowOrExhausted
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                  if (isLowOrExhausted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'Saldo Menipis atau Habis',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.account_balance_wallet,
                        size: 20, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                CurrencyFormatter.format(ringkasan.sisaSaldo),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isLowOrExhausted ? AppColors.error : AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isLowOrExhausted
                    ? 'Perhatian: Dana modal kas telah mencapai batas menipis/habis.'
                    : 'Sisa kas aktif saat ini tersedia di tangan/kasir.',
                style: TextStyle(
                  fontSize: 11,
                  color: isLowOrExhausted
                      ? AppColors.error
                      : AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),

      if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 16),

      // KARTU 2: Total Top Up Saldo (Mengikuti Filter Periode)
      Expanded(
        flex: isMobile ? 0 : 3,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.hairline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'TOTAL TOP UP SALDO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  Icon(Icons.arrow_downward, size: 18, color: AppColors.success),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                CurrencyFormatter.format(ringkasan.effectiveTotalTopup),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Periode: $periodLabel',
                style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),

      if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 16),

      // KARTU 3: Total Pemakaian Pembelian (Mengikuti Filter Periode)
      Expanded(
        flex: isMobile ? 0 : 3,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.hairline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'TOTAL PEMAKAIAN SALDO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  Icon(Icons.arrow_upward, size: 18, color: AppColors.error),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                CurrencyFormatter.format(ringkasan.effectiveTotalPemakaian),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Periode: $periodLabel',
                style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ];

    if (isMobile) {
      return Column(children: cards);
    }
    return Row(children: cards);
  }

  Widget _buildRiwayatMutasiSection(
    BuildContext context,
    SaldoState state,
    SaldoFilterState filter,
    WidgetRef ref,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final activeTab = state.activeTab;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section & Tab Filter (Semua Aktivitas, Top Up Saja, Pemakaian Harian)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.swap_vert, size: 18, color: AppColors.inkMuted),
                    SizedBox(width: 8),
                    Text(
                      'Riwayat Mutasi Saldo Kas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                if (state.isLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.hairline),

          // Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.history, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'DAFTAR RIWAYAT MUTASI SALDO',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.hairline),

          // Body List sesuai Tab yang Aktif
          _buildActiveTabContent(context, state, activeTab, dateFormat, ref),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(
    BuildContext context,
    SaldoState state,
    String activeTab,
    DateFormat dateFormat,
    WidgetRef ref,
  ) {
    if (activeTab == 'topup') {
      return _buildTopupOnlyList(context, state.topupList, dateFormat, ref);
    } else if (activeTab == 'pemakaian') {
      return _buildPemakaianOnlyList(context, state.pemakaianHarianList, dateFormat);
    } else if (activeTab == 'non_tunai') {
      return _buildNonTunaiHarianList(context, state, dateFormat);
    } else {
      return _buildUnifiedMutasiList(context, state.mutasiList, dateFormat, ref);
    }
  }

  /// Tampilan Linimasa Terpadu (+ Top Up per aksi dan - Pemakaian per hari)
  Widget _buildUnifiedMutasiList(
    BuildContext context,
    List<MutasiSaldoItem> items,
    DateFormat dateFormat,
    WidgetRef ref,
  ) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          children: const [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.inkMuted),
            SizedBox(height: 8),
            Text(
              'Tidak ada riwayat aktivitas saldo pada periode ini.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Gunakan tombol "+ Top Up Saldo" di atas untuk menambah dana kas.',
              style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.hairline),
      itemBuilder: (context, index) {
        final item = items[index];

        if (item.isTopup) {
          final topup = item.topupData!;
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFDEFBE6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.arrow_downward,
                color: AppColors.success,
                size: 18,
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEFBE6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    '+ TOP UP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(topup.tanggal),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '+ ${CurrencyFormatter.format(topup.nominal)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                topup.keterangan != null && topup.keterangan!.isNotEmpty
                    ? topup.keterangan!
                    : 'Penambahan kas modal operasional',
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              tooltip: 'Hapus Catatan Top Up',
              onPressed: () => _confirmDeleteTopup(context, topup, ref),
            ),
          );
        } else {
          final pemakaian = item.pemakaianData!;
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: AppColors.error,
                size: 18,
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    '- PEMAKAIAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(pemakaian.tanggal),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '- ${CurrencyFormatter.format(pemakaian.totalPemakaian)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Total penggunaan kas oleh kasir (${pemakaian.jumlahTransaksi} transaksi pembelian)',
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ),
            trailing: TextButton.icon(
              icon: const Icon(Icons.arrow_forward, size: 14),
              label: const Text('Detail', style: TextStyle(fontSize: 11)),
              onPressed: widget.onNavigateToRiwayatTransaksi,
            ),
          );
        }
      },
    );
  }

  /// Tampilan Khusus Tab Top Up (+ saja)
  Widget _buildTopupOnlyList(
    BuildContext context,
    List<TopupSaldo> items,
    DateFormat dateFormat,
    WidgetRef ref,
  ) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        alignment: Alignment.center,
        child: const Text('Tidak ada entri Top Up pada periode ini.',
            style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.hairline),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFDEFBE6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.success,
              size: 18,
            ),
          ),
          title: Row(
            children: [
              Text(
                dateFormat.format(item.tanggal),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+ ${CurrencyFormatter.format(item.nominal)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              item.keterangan != null && item.keterangan!.isNotEmpty
                  ? item.keterangan!
                  : 'Penambahan kas modal operasional',
              style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            tooltip: 'Hapus Catatan Top Up',
            onPressed: () => _confirmDeleteTopup(context, item, ref),
          ),
        );
      },
    );
  }

  /// Tampilan Khusus Tab Pemakaian Harian (- saja)
  Widget _buildPemakaianOnlyList(
    BuildContext context,
    List<PemakaianSaldoHarian> items,
    DateFormat dateFormat,
  ) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        alignment: Alignment.center,
        child: const Text('Tidak ada pemakaian saldo pada periode ini.',
            style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.hairline),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.remove,
              color: AppColors.error,
              size: 18,
            ),
          ),
          title: Row(
            children: [
              Text(
                dateFormat.format(item.tanggal),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '- ${CurrencyFormatter.format(item.totalPemakaian)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Total pembelian sawit oleh kasir (${item.jumlahTransaksi} transaksi)',
              style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
          ),
          trailing: TextButton.icon(
            icon: const Icon(Icons.arrow_forward, size: 14),
            label: const Text('Riwayat', style: TextStyle(fontSize: 11)),
            onPressed: widget.onNavigateToRiwayatTransaksi,
          ),
        );
      },
    );
  }

  /// Tampilan Khusus Tab Non Tunai (Informasional) (PRD §7.10 FR-10.10)
  Widget _buildNonTunaiHarianList(
    BuildContext context,
    SaldoState state,
    DateFormat dateFormat,
  ) {
    final items = state.nonTunaiHarianList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner Informasional
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INFORMASI TRANSAKSI NON TUNAI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tab ini mencatat transaksi yang diselesaikan secara non tunai (transfer/tunda). '
                      'Data ini bersifat informasional dan TIDAK mempengaruhi atau mengurangi Sisa Saldo Kas Modal.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.ink,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Total Non Tunai Periode Ini: ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(state.totalNilaiNonTunai),
                          key: const Key('total_nilai_non_tunai_text'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            alignment: Alignment.center,
            child: const Text(
              'Tidak ada transaksi pembelian Non Tunai pada periode ini.',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.hairline),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      dateFormat.format(item.tanggal),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(item.totalNilai),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${item.jumlahTransaksi} transaksi non tunai diselesaikan',
                    style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                ),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('Riwayat', style: TextStyle(fontSize: 11)),
                  onPressed: widget.onNavigateToRiwayatTransaksi,
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _confirmDeleteTopup(
    BuildContext context,
    TopupSaldo item,
    WidgetRef ref,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan Top Up?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan top up sebesar ${CurrencyFormatter.format(item.nominal)}? Sisa saldo akan otomatis berkurang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(saldoControllerProvider.notifier).deleteTopup(item.id);
    }
  }
}
