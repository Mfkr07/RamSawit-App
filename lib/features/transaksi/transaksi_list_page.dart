import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/weight_formatter.dart';
import '../../core/widgets/enterprise_pagination_bar.dart';
import '../../models/transaksi.dart';
import '../penjual/penjual_controller.dart';
import 'export/export_laporan_dialog.dart';
import 'transaksi_detail_page.dart';
import 'transaksi_filter_state.dart';
import 'transaksi_list_controller.dart';

/// Halaman Riwayat Transaksi (FR-4.1).
/// Membaca data langsung dari view agregasi `public.v_transaksi_ringkasan`
/// dengan filter rentang tanggal, penjual, dan status transaksi.
class TransaksiListPage extends ConsumerStatefulWidget {
  const TransaksiListPage({super.key});

  @override
  ConsumerState<TransaksiListPage> createState() => _TransaksiListPageState();
}

class _TransaksiListPageState extends ConsumerState<TransaksiListPage> {
  bool _isFilterExpanded = false;

  String _activeTransaksiPresetLabel(String preset) {
    switch (preset) {
      case 'semua':
        return 'Semua';
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
      case 'kustom':
        return 'Kustom';
      default:
        return preset;
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _handleCustomDateRange(
    BuildContext context,
    TransaksiFilterState filterState,
  ) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: filterState.startDate != null && filterState.endDate != null
          ? DateTimeRange(
              start: filterState.startDate!,
              end: filterState.endDate!.isAfter(now) ? now : filterState.endDate!,
            )
          : DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            ),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'PILIH RENTANG TANGGAL TRANSAKSI',
      cancelText: 'BATAL',
      confirmText: 'TERAPKAN',
      saveText: 'TERAPKAN',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.canvas,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final start = DateTime(picked.start.year, picked.start.month, picked.start.day);
      final end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      ref.read(transaksiFilterProvider.notifier).setCustomDateRange(start, end);
      ref.read(transaksiPageProvider.notifier).state = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(transaksiFilterProvider);
    final filterNotifier = ref.read(transaksiFilterProvider.notifier);
    final listAsync = ref.watch(transaksiListProvider);
    final penjualAsync = ref.watch(penjualListProvider);

    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: EdgeInsets.all(isNarrow ? 12.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Data transaksi pembelian TBS sawit bersumber dari view database',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('Export Laporan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        ExportLaporanDialog.show(
                          context,
                          startDate: filterState.startDate,
                          endDate: filterState.endDate,
                          penjualId: filterState.selectedPenjualId,
                          status: filterState.status,
                          jenisPembayaran: filterState.jenisPembayaran,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Segarkan data',
                      icon: const Icon(Icons.refresh, color: AppColors.primary),
                      onPressed: () =>
                          ref.read(transaksiListProvider.notifier).refresh(),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isNarrow ? 10 : 16),

            // Bilah Filter Dinamis (Desktop langsung tampil, Mobile lewat tombol toggle non-sticky)
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;
                final filterCard = Container(
                  padding: EdgeInsets.all(isNarrow ? 10 : 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris 1: Preset Tanggal
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final p in [
                            ('semua', 'Semua'),
                            ('hari_ini', 'Hari Ini'),
                            ('1_minggu', '1 Minggu'),
                            ('2_minggu', '2 Minggu'),
                            ('1_bulan', '1 Bulan'),
                            ('3_bulan', '3 Bulan'),
                            ('6_bulan', '6 Bulan'),
                            ('1_tahun', '1 Tahun'),
                          ])
                            ChoiceChip(
                              key: Key('filter_transaksi_preset_${p.$1}'),
                              label: Text(p.$2),
                              selected: filterState.datePreset == p.$1,
                              onSelected: (selected) {
                                if (selected) {
                                  filterNotifier.applyDatePreset(p.$1);
                                  ref.read(transaksiPageProvider.notifier).state = 1;
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
                              backgroundColor: Colors.white,
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
                            key: const Key('filter_preset_kustom'),
                            onPressed: () => _handleCustomDateRange(context, filterState),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 32),
                              side: BorderSide(
                                color: filterState.datePreset == 'kustom'
                                    ? AppColors.primary
                                    : AppColors.hairline,
                              ),
                              backgroundColor: filterState.datePreset == 'kustom'
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
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
                              filterState.datePreset == 'kustom' ? 'Kustom (Aktif)' : 'Kustom Tanggal',
                              style: TextStyle(
                                fontSize: 11,
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

                      // Baris 2: Filter Penjual & Filter Status
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 650;

                          final penjualDropdown = penjualAsync.when(
                            loading: () => const SizedBox(
                              height: 38,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            error: (err, stack) => const SizedBox(),
                            data: (penjualList) {
                              return DropdownButtonFormField<String>(
                                key: const Key('filter_penjual_dropdown'),
                                initialValue: filterState.selectedPenjualId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Filter Penjual',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Semua Penjual'),
                                  ),
                                  ...penjualList.map((p) {
                                    return DropdownMenuItem<String>(
                                      value: p.id,
                                      child: Text(p.nama),
                                    );
                                  }),
                                ],
                                onChanged: filterNotifier.setPenjual,
                              );
                            },
                          );

                          final statusDropdown = DropdownButtonFormField<String>(
                            key: const Key('filter_status_dropdown'),
                            initialValue: filterState.status,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Status Transaksi',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'semua',
                                child: Text('Semua Status'),
                              ),
                              DropdownMenuItem(
                                value: 'selesai',
                                child: Text('Selesai'),
                              ),
                              DropdownMenuItem(
                                value: 'dibatalkan',
                                child: Text('Dibatalkan'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) filterNotifier.setStatus(val);
                            },
                          );

                          final jenisPembayaranDropdown = DropdownButtonFormField<String>(
                            key: const Key('filter_jenis_pembayaran_dropdown'),
                            initialValue: filterState.jenisPembayaran,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Jenis Pembayaran',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'semua',
                                child: Text('Semua Pembayaran'),
                              ),
                              DropdownMenuItem(
                                value: 'tunai',
                                child: Text('Tunai'),
                              ),
                              DropdownMenuItem(
                                value: 'non_tunai',
                                child: Text('Non Tunai'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                filterNotifier.setJenisPembayaran(val);
                                ref.read(transaksiPageProvider.notifier).state = 1;
                              }
                            },
                          );

                          final resetButton = filterState.hasActiveFilter
                              ? OutlinedButton.icon(
                                  key: const Key('reset_filter_button'),
                                  onPressed: filterNotifier.reset,
                                  icon: const Icon(Icons.filter_alt_off, size: 16),
                                  label: const Text('Reset Filter'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                )
                              : const SizedBox();

                          if (isWide) {
                            return Row(
                              children: [
                                Expanded(flex: 3, child: penjualDropdown),
                                const SizedBox(width: 12),
                                Expanded(flex: 2, child: statusDropdown),
                                const SizedBox(width: 12),
                                Expanded(flex: 2, child: jenisPembayaranDropdown),
                                if (filterState.hasActiveFilter) ...[
                                  const SizedBox(width: 12),
                                  resetButton,
                                ],
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              penjualDropdown,
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: statusDropdown),
                                  const SizedBox(width: 8),
                                  Expanded(child: jenisPembayaranDropdown),
                                ],
                              ),
                              if (filterState.hasActiveFilter) ...[
                                const SizedBox(height: 10),
                                resetButton,
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );

                if (!isMobile) {
                  return filterCard;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('toggle_filter_transaksi_btn'),
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
                                  ? 'Tutup Panel Filter Transaksi'
                                  : 'Filter Transaksi: ${_activeTransaksiPresetLabel(filterState.datePreset)}',
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
                        backgroundColor: AppColors.surface1,
                        minimumSize: const Size(0, 38),
                        side: const BorderSide(color: AppColors.hairline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    if (_isFilterExpanded) ...[
                      const SizedBox(height: 8),
                      filterCard,
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Daftar Ringkasan Transaksi
            Expanded(
              child: listAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat riwayat: $err',
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(transaksiListProvider.notifier).refresh(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
                data: (paginated) {
                  final transactions = paginated.items;
                  if (paginated.totalCount == 0) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppColors.inkSubtle,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak ada transaksi yang sesuai kriteria filter.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          if (filterState.hasActiveFilter) ...[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: filterNotifier.reset,
                              child: const Text('Tampilkan Semua Transaksi'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () =>
                              ref.read(transaksiListProvider.notifier).refresh(),
                          child: ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final trx = transactions[index];
                              return _TransaksiCardItem(
                                key: Key('trx_card_${trx.kodeTransaksi}'),
                                transaksi: trx,
                                formatDate: _formatDate,
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TransaksiDetailPage(
                                        transaksiId: trx.id,
                                      ),
                                    ),
                                  );
                                  // Refresh daftar setelah kembali dari detail
                                  ref
                                      .read(transaksiListProvider.notifier)
                                      .refresh();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      EnterprisePaginationBar(
                        currentPage: paginated.page,
                        totalPages: paginated.totalPages,
                        totalItems: paginated.totalCount,
                        pageSize: paginated.pageSize,
                        onPageChanged: (newPage) {
                          ref
                              .read(transaksiListProvider.notifier)
                              .goToPage(newPage);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransaksiCardItem extends StatelessWidget {
  final TransaksiRingkasan transaksi;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const _TransaksiCardItem({
    super.key,
    required this.transaksi,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDibatalkan = transaksi.isDibatalkan;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(
          color: isDibatalkan ? AppColors.error.withValues(alpha: 0.3) : AppColors.hairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Kode Transaksi, Tanggal, & Status Badge
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      Text(
                        transaksi.kodeTransaksi,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDibatalkan
                              ? AppColors.inkMuted
                              : AppColors.primary,
                          letterSpacing: 0.8,
                          decoration:
                              isDibatalkan ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        '• ${formatDate(transaksi.tanggalTransaksi)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),

                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Badge Jenis Pembayaran (PRD §7.4 FR-4.2)
                      Container(
                        key: Key('badge_pembayaran_${transaksi.id}'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: transaksi.isTunai
                              ? AppColors.inkSubtle.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.12),
                          border: Border.all(
                            color: transaksi.isTunai
                                ? AppColors.inkSubtle
                                : AppColors.primary,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          transaksi.isTunai ? 'TUNAI' : 'NON TUNAI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: transaksi.isTunai
                                ? AppColors.inkMuted
                                : AppColors.primary,
                          ),
                        ),
                      ),

                      // Badge Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDibatalkan
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.success.withValues(alpha: 0.1),
                          border: Border.all(
                            color: isDibatalkan
                                ? AppColors.error
                                : AppColors.success,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          transaksi.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDibatalkan
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 2: Nama Penjual, Total Berat & Total Pembayaran
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 340;
                  final leftCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaksi.namaPenjual,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDibatalkan
                              ? AppColors.inkMuted
                              : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          const Text(
                            'Berat: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          Text(
                            '${WeightFormatter.format(transaksi.totalBeratBersihKg)} (Kotor: ${WeightFormatter.format(transaksi.totalBeratKotorKg)})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  final rightCol = Column(
                    crossAxisAlignment: isCompact
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Nilai:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(transaksi.totalNilai),
                        key: Key('trx_total_bersih_${transaksi.kodeTransaksi}'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDibatalkan
                              ? AppColors.inkMuted
                              : AppColors.primary,
                          decoration:
                              isDibatalkan ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaksi.totalPotonganRp > Decimal.zero
                            ? 'Pot. Berat: ${CurrencyFormatter.format(transaksi.totalPotonganRp)}'
                            : 'Tanpa Potongan',
                        key: Key('trx_info_potongan_${transaksi.kodeTransaksi}'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.inkSubtle,
                        ),
                      ),
                    ],
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leftCol,
                        const SizedBox(height: 10),
                        rightCol,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: leftCol),
                      const SizedBox(width: 8),
                      rightCol,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
