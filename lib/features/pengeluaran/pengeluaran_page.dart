import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/enterprise_pagination_bar.dart';
import '../../models/pengeluaran.dart';
import '../auth/auth_controller.dart';
import 'export/export_laporan_pengeluaran_dialog.dart';
import 'jenis_pengeluaran_controller.dart';
import 'pengeluaran_controller.dart';
import 'pengeluaran_filter_state.dart';
import 'widgets/pengeluaran_form_modal.dart';

/// Halaman Pencatatan & Riwayat Pengeluaran Operasional (FR-9.1, FR-9.3, FR-9.5).
/// Terbuka untuk SEMUA role (Admin & Kasir).
class PengeluaranPage extends ConsumerStatefulWidget {
  const PengeluaranPage({super.key});

  @override
  ConsumerState<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends ConsumerState<PengeluaranPage> {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isFilterExpanded = false;

  Future<void> _handleCustomDateRange(
    BuildContext context,
    PengeluaranFilterState current,
  ) async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: current.startDate ?? now.subtract(const Duration(days: 7)),
        end: current.endDate ?? now,
      ),
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'PILIH RENTANG TANGGAL PENGELUARAN',
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

    if (pickedRange != null) {
      ref.read(pengeluaranFilterProvider.notifier).setCustomRange(
            pickedRange.start,
            pickedRange.end,
          );
    }
  }

  Future<void> _confirmDelete(Pengeluaran item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        title: const Text(
          'Hapus Catatan Pengeluaran?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin ingin menghapus catatan pengeluaran ini secara permanen?',
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                border: Border.all(color: AppColors.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori: ${item.jenisPengeluaranNama ?? '-'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nominal: ${CurrencyFormatter.format(item.nominal)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  if (item.keterangan?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Keterangan: ${item.keterangan}',
                      style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(pengeluaranControllerProvider.notifier)
          .deletePengeluaran(item.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Catatan pengeluaran berhasil dihapus.'
                  : 'Gagal menghapus pengeluaran.',
            ),
            backgroundColor: success ? AppColors.primary : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(pengeluaranFilterProvider);
    final filterNotifier = ref.read(pengeluaranFilterProvider.notifier);
    final pengeluaranAsync = ref.watch(pengeluaranListProvider);
    final jenisAsync = ref.watch(jenisPengeluaranListProvider);
    final userProfile = ref.watch(authControllerProvider).profile;
    final isAdmin = userProfile?.isAdmin == true;
    final currentUserId = userProfile?.id;

    return Scaffold(
      backgroundColor: AppColors.surface1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Halaman
            _buildHeader(context, filter),
            const SizedBox(height: 18),

            // 2. Bar Filter Periode & Kategori (Standar Final Lengkap)
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;
                if (!isMobile) {
                  return _buildFilterBar(filter, filterNotifier, jenisAsync);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('toggle_filter_pengeluaran_btn'),
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
                                  ? 'Tutup Panel Filter Biaya'
                                  : 'Filter Biaya: ${_activePengeluaranPresetLabel(filter.datePreset)}',
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
                      _buildFilterBar(filter, filterNotifier, jenisAsync),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. Konten Tabel / List Data Pengeluaran
            pengeluaranAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.error.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gagal memuat data pengeluaran: $err',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(pengeluaranListProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (paginated) {
                final items = paginated.items;

                // Hitung total nominal pada halaman saat ini
                final totalHalamanIni = items.fold<Decimal>(
                  Decimal.zero,
                  (sum, item) => sum + item.nominal,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kartu Ringkasan Cepat
                    _buildSummaryCard(paginated.totalCount, totalHalamanIni),
                    const SizedBox(height: 12),

                    if (items.isEmpty)
                      _buildEmptyState()
                    else ...[
                      // Daftar Entri Pengeluaran
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final canEditOrDelete = isAdmin ||
                              (currentUserId != null &&
                                  item.createdBy == currentUserId) ||
                              item.createdBy == null;

                          return _PengeluaranCardItem(
                            key: Key('pg_card_${item.id}'),
                            item: item,
                            dateFormat: _dateFormat,
                            canEditOrDelete: canEditOrDelete,
                            onEdit: () => PengeluaranFormModal.show(
                              context,
                              initialPengeluaran: item,
                            ),
                            onDelete: () => _confirmDelete(item),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Pagination Bar
                      EnterprisePaginationBar(
                        currentPage: paginated.page,
                        totalPages: paginated.totalPages,
                        totalItems: paginated.totalCount,
                        pageSize: paginated.pageSize,
                        onPageChanged: (newPage) {
                          ref
                              .read(pengeluaranFilterProvider.notifier)
                              .setPage(newPage);
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _activePengeluaranPresetLabel(String preset) {
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

  Widget _buildHeader(BuildContext context, PengeluaranFilterState filter) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        final titleCol = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'PENCATATAN PENGELUARAN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Pencatatan biaya operasional, BBM, upah, perawatan armada, dan logistik ramp sawit',
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Tombol Export Laporan Pengeluaran (FR-9.6)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.canvas,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                side: const BorderSide(color: AppColors.hairline),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
              ),
              icon: const Icon(Icons.file_download_outlined,
                  size: 16, color: AppColors.primary),
              label: const Text(
                'Export Laporan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              onPressed: () {
                ExportLaporanPengeluaranDialog.show(
                  context,
                  startDate: filter.startDate,
                  endDate: filter.endDate,
                  jenisPengeluaranId: filter.selectedJenisId,
                );
              },
            ),

            // Tombol Catat Pengeluaran Baru (CTA)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Catat Pengeluaran',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              onPressed: () => PengeluaranFormModal.show(context),
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleCol,
              const SizedBox(height: 12),
              actions,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleCol),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(
    PengeluaranFilterState filter,
    PengeluaranFilterNotifier notifier,
    AsyncValue<List<dynamic>> jenisAsync,
  ) {
    final presets = [
      {'label': 'Semua', 'value': 'semua'},
      {'label': 'Hari Ini', 'value': 'hari_ini'},
      {'label': '1 Minggu', 'value': '1_minggu'},
      {'label': '2 Minggu', 'value': '2_minggu'},
      {'label': '1 Bulan', 'value': '1_bulan'},
      {'label': '3 Bulan', 'value': '3_bulan'},
      {'label': '6 Bulan', 'value': '6_bulan'},
      {'label': '1 Tahun', 'value': '1_tahun'},
    ];

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'FILTER PERIODE & KATEGORI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
              if (filter.hasActiveFilter)
                InkWell(
                  onTap: notifier.resetFilter,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Reset Filter',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Baris Tombol Preset Waktu Asli
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final p in presets)
                ChoiceChip(
                  key: Key('filter_pengeluaran_preset_${p['value']}'),
                  label: Text(p['label']!),
                  selected: filter.datePreset == p['value'],
                  onSelected: (selected) {
                    if (selected) {
                      notifier.applyDatePreset(p['value']!);
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: filter.datePreset == p['value']
                        ? Colors.white
                        : AppColors.ink,
                  ),
                  backgroundColor: AppColors.surface1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(
                      color: filter.datePreset == p['value']
                          ? AppColors.primary
                          : AppColors.hairline,
                    ),
                  ),
                ),
              OutlinedButton.icon(
                key: const Key('filter_preset_kustom'),
                onPressed: () => _handleCustomDateRange(context, filter),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  side: BorderSide(
                    color: filter.datePreset == 'kustom'
                        ? AppColors.primary
                        : AppColors.hairline,
                  ),
                  backgroundColor: filter.datePreset == 'kustom'
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
                  color: filter.datePreset == 'kustom'
                      ? AppColors.primary
                      : AppColors.inkMuted,
                ),
                label: Text(
                  filter.datePreset == 'kustom'
                      ? 'Kustom (Aktif)'
                      : 'Kustom Tanggal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: filter.datePreset == 'kustom'
                        ? AppColors.primary
                        : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.hairline, height: 1),
          const SizedBox(height: 12),

          // Dropdown Filter Kategori
          Row(
            children: [
              const Text(
                'Kategori: ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(width: 8),
              jenisAsync.when(
                loading: () => const SizedBox(
                  width: 120,
                  height: 24,
                  child: LinearProgressIndicator(),
                ),
                error: (_, _) => const Text('Gagal memuat kategori'),
                data: (kategoriList) {
                  return Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface1,
                      border: Border.all(color: AppColors.hairline),
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: filter.selectedJenisId,
                        hint: const Text(
                          'Semua Kategori',
                          style: TextStyle(fontSize: 12, color: AppColors.ink),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              'Semua Kategori',
                              style: TextStyle(fontSize: 12, color: AppColors.ink),
                            ),
                          ),
                          ...kategoriList.map((k) {
                            return DropdownMenuItem<int?>(
                              value: k.id,
                              child: Text(
                                k.nama,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.ink),
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) => notifier.setJenisFilter(val),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalCount, Decimal totalNominal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 18, color: AppColors.inkMuted),
              const SizedBox(width: 8),
              Text(
                'Total: $totalCount Catatan',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                'Akumulasi: ',
                style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
              Text(
                CurrencyFormatter.format(totalNominal),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline),
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.inkSubtle),
            SizedBox(height: 12),
            Text(
              'Belum ada catatan pengeluaran',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMuted,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Klik "Catat Pengeluaran" untuk menambahkan pengeluaran baru.',
              style: TextStyle(fontSize: 12, color: AppColors.inkSubtle),
            ),
          ],
        ),
      ),
    );
  }
}

class _PengeluaranCardItem extends StatelessWidget {
  final Pengeluaran item;
  final DateFormat dateFormat;
  final bool canEditOrDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PengeluaranCardItem({
    super.key,
    required this.item,
    required this.dateFormat,
    required this.canEditOrDelete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tanggal & Kategori Badge
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2)),
                      ),
                      child: Text(
                        item.jenisPengeluaranNama ?? 'Operasional',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.isNonTunai
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.success.withValues(alpha: 0.08),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(
                          color: item.isNonTunai
                              ? AppColors.primary.withValues(alpha: 0.25)
                              : AppColors.success.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        item.isNonTunai ? 'Non Tunai' : 'Tunai',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: item.isNonTunai
                              ? AppColors.primary
                              : AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(item.tanggalPengeluaran),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.keterangan?.isNotEmpty == true
                      ? item.keterangan!
                      : 'Tanpa keterangan tambahan',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.keterangan?.isNotEmpty == true
                        ? AppColors.ink
                        : AppColors.inkSubtle,
                    fontStyle: item.keterangan?.isNotEmpty == true
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.createdByName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Dicatat oleh: ${item.createdByName}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Nominal
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(item.nominal),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.isTunai ? 'Pengeluaran Kas' : 'Transfer Bank',
                  style: const TextStyle(fontSize: 10, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Tombol Aksi: Edit & Hapus (FR-9.3)
          if (canEditOrDelete) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.primary),
              tooltip: 'Edit Pengeluaran',
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.error),
              tooltip: 'Hapus Pengeluaran',
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ] else
            Tooltip(
              message: 'Hanya pembuat atau Admin yang dapat mengubah entri ini',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.lock_outline,
                    size: 16, color: AppColors.inkSubtle.withValues(alpha: 0.5)),
              ),
            ),
        ],
      ),
    );
  }
}
