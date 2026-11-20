import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/weight_formatter.dart';
import '../../core/widgets/enterprise_pagination_bar.dart';
import '../../models/pengiriman_pabrik.dart';
import 'export/export_laporan_pengiriman_dialog.dart';
import 'pengiriman_pabrik_controller.dart';
import 'selesaikan_pengiriman_page.dart';

/// Halaman Riwayat Pengiriman Penjualan ke Pabrik (FR-8.5 & FR-8.6).
/// Menyediakan tab "Belum Selesai" (status berangkat) dan "Semua Riwayat",
/// serta integrasi penyelesaian Fase 2.
class PengirimanPabrikListPage extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToForm;

  const PengirimanPabrikListPage({
    super.key,
    this.onNavigateToForm,
  });

  @override
  ConsumerState<PengirimanPabrikListPage> createState() =>
      _PengirimanPabrikListPageState();
}

class _PengirimanPabrikListPageState
    extends ConsumerState<PengirimanPabrikListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0: Belum Selesai (berangkat), 1: Semua Riwayat
  String _selectedDatePreset = 'semua'; // 'semua', 'hari_ini', '1_minggu', '2_minggu', '1_bulan', '3_bulan', '6_bulan', '1_tahun', 'kustom'
  DateTimeRange? _customDateRange;
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _isFilterExpanded = false;

  String _activePengirimanPresetLabel(String preset) {
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

  DateTimeRange? _getDateRangeForPreset(String preset) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (preset) {
      case 'kustom':
        return _customDateRange;
      case 'hari_ini':
        return DateTimeRange(start: todayStart, end: todayEnd);
      case '1_minggu':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 6)),
          end: todayEnd,
        );
      case '2_minggu':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 13)),
          end: todayEnd,
        );
      case '1_bulan':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 29)),
          end: todayEnd,
        );
      case '3_bulan':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 89)),
          end: todayEnd,
        );
      case '6_bulan':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 179)),
          end: todayEnd,
        );
      case '1_tahun':
        return DateTimeRange(
          start: todayStart.subtract(const Duration(days: 364)),
          end: todayEnd,
        );
      case 'semua':
      default:
        return null;
    }
  }

  Future<void> _handleCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'PILIH RENTANG TANGGAL PENGIRIMAN',
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
      setState(() {
        _customDateRange = DateTimeRange(start: start, end: end);
        _selectedDatePreset = 'kustom';
        _currentPage = 1;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSelesaikanPage(PengirimanPabrik item) async {
    final result = await Navigator.of(context).push<PengirimanPabrik>(
      MaterialPageRoute(
        builder: (_) => SelesaikanPengirimanPage(pengiriman: item),
      ),
    );
    if (result != null) {
      ref.read(pengirimanListProvider.notifier).refresh();
    }
  }

  void _showDetailModal(PengirimanPabrik item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        title: Row(
          children: [
            const Icon(Icons.receipt_outlined,
                color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Detail Nota: ${item.kodePengiriman}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModalRow(
                'Pabrik Tujuan:',
                item.pabrik?.nama ?? 'Pabrik ID: ${item.pabrikId}',
                isBold: true,
              ),
              _buildModalRow('Armada & Sopir:',
                  '${item.platNomor} (${item.namaSopir})'),
              _buildModalRow(
                'Tanggal Kirim:',
                DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                    .format(item.tanggalKirim),
              ),
              _buildModalRow(
                'Status Pengiriman:',
                item.isBerangkat
                    ? 'BERANGKAT (Truk Belum Kembali)'
                    : item.status.toUpperCase(),
                textColor: item.isBerangkat
                    ? Colors.orange.shade800
                    : item.isSelesai
                        ? AppColors.success
                        : AppColors.error,
                isBold: true,
              ),
              const Divider(color: AppColors.hairline, height: 16),
              _buildModalRow(
                'Berat Dikirim:',
                WeightFormatter.format(item.beratDikirimKg),
                isBold: true,
                textColor: AppColors.primary,
              ),
              _buildModalRow(
                'Berat Sampai:',
                item.beratSampaiKg != null
                    ? WeightFormatter.format(item.beratSampaiKg!)
                    : 'Belum diisi',
                textColor: item.beratSampaiKg != null ? AppColors.ink : Colors.orange.shade800,
                isItalic: item.beratSampaiKg == null,
              ),
              _buildModalRow(
                'Berat Ditolak:',
                item.beratDitolakKg != null
                    ? WeightFormatter.format(item.beratDitolakKg!)
                    : 'Belum diisi',
                textColor: item.beratDitolakKg != null ? AppColors.ink : Colors.orange.shade800,
                isItalic: item.beratDitolakKg == null,
              ),
              _buildModalRow(
                'Berat Diterima:',
                item.beratDiterimaKg != null
                    ? WeightFormatter.format(item.beratDiterimaKg!)
                    : 'Belum diisi',
                textColor: item.beratDiterimaKg != null ? AppColors.primary : Colors.orange.shade800,
                isBold: item.beratDiterimaKg != null,
                isItalic: item.beratDiterimaKg == null,
              ),
              _buildModalRow(
                'Potongan Pabrik:',
                item.persentasePotonganPabrik != null
                    ? '${item.persentasePotonganPabrik}%'
                    : 'Belum diisi',
                textColor: item.persentasePotonganPabrik != null ? AppColors.ink : Colors.orange.shade800,
                isItalic: item.persentasePotonganPabrik == null,
              ),
              _buildModalRow(
                'Berat Bersih (Netto):',
                item.beratBersihKg != null
                    ? WeightFormatter.format(item.beratBersihKg!)
                    : 'Belum diisi',
                textColor: item.beratBersihKg != null ? AppColors.success : Colors.orange.shade800,
                isBold: item.beratBersihKg != null,
                isItalic: item.beratBersihKg == null,
              ),
              _buildModalRow(
                'Susut Buah:',
                item.susutBuahKg != null
                    ? WeightFormatter.format(item.susutBuahKg!)
                    : 'Belum diisi',
                textColor: item.susutBuahKg != null
                    ? (item.susutBuahKg! > Decimal.zero ? Colors.orange.shade900 : AppColors.ink)
                    : Colors.orange.shade800,
                isItalic: item.susutBuahKg == null,
              ),
              _buildModalRow(
                'Harga Jual / kg:',
                item.hargaJualPerKg != null
                    ? '${CurrencyFormatter.format(item.hargaJualPerKg!)} / kg'
                    : 'Belum diisi',
                textColor: item.hargaJualPerKg != null ? AppColors.ink : Colors.orange.shade800,
                isItalic: item.hargaJualPerKg == null,
              ),
              if (item.nilaiPotonganRp != null && item.nilaiPotonganRp! > Decimal.zero)
                _buildModalRow(
                  'Potongan Berat Pabrik:',
                  CurrencyFormatter.format(item.nilaiPotonganRp!),
                  textColor: AppColors.error,
                ),
              _buildModalRow(
                'Potongan Lainnya:',
                item.isBerangkat
                    ? 'Belum diisi'
                    : (item.potonganLainnyaRp != null && item.potonganLainnyaRp! > Decimal.zero
                        ? CurrencyFormatter.format(item.potonganLainnyaRp!)
                        : 'Tidak ada'),
                textColor: item.isBerangkat
                    ? Colors.orange.shade800
                    : (item.potonganLainnyaRp != null && item.potonganLainnyaRp! > Decimal.zero
                        ? AppColors.ink
                        : AppColors.inkMuted),
                isItalic: item.isBerangkat ||
                    item.potonganLainnyaRp == null ||
                    item.potonganLainnyaRp == Decimal.zero,
              ),
              _buildModalRow(
                'Potongan Sortasi (Rp/kg):',
                item.isBerangkat
                    ? 'Belum diisi'
                    : (item.potonganSortasiPerKg != null && item.potonganSortasiPerKg! > Decimal.zero
                        ? '${CurrencyFormatter.format(item.potonganSortasiPerKg!)} / kg'
                        : 'Tidak ada'),
                textColor: item.isBerangkat
                    ? Colors.orange.shade800
                    : (item.potonganSortasiPerKg != null && item.potonganSortasiPerKg! > Decimal.zero
                        ? AppColors.ink
                        : AppColors.inkMuted),
                isItalic: item.isBerangkat ||
                    item.potonganSortasiPerKg == null ||
                    item.potonganSortasiPerKg == Decimal.zero,
              ),
              _buildModalRow(
                'Nilai Potongan Sortasi:',
                item.isBerangkat
                    ? 'Belum diisi'
                    : (item.nilaiPotonganSortasiRp != null && item.nilaiPotonganSortasiRp! > Decimal.zero
                        ? CurrencyFormatter.format(item.nilaiPotonganSortasiRp!)
                        : 'Tidak ada'),
                textColor: item.isBerangkat
                    ? Colors.orange.shade800
                    : (item.nilaiPotonganSortasiRp != null && item.nilaiPotonganSortasiRp! > Decimal.zero
                        ? AppColors.error
                        : AppColors.inkMuted),
                isItalic: item.isBerangkat ||
                    item.nilaiPotonganSortasiRp == null ||
                    item.nilaiPotonganSortasiRp == Decimal.zero,
              ),
              const Divider(color: AppColors.hairline, height: 16),
              _buildModalRow(
                'TOTAL NILAI JUAL:',
                item.totalNilaiJual != null
                    ? CurrencyFormatter.format(item.totalNilaiJual!)
                    : 'Belum diisi',
                fontSize: 16,
                isBold: true,
                textColor: item.totalNilaiJual != null ? AppColors.primary : Colors.orange.shade800,
                isItalic: item.totalNilaiJual == null,
              ),
              if (item.catatan != null && item.catatan!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Catatan: ${item.catatan}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
          if (item.isBerangkat)
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Selesaikan Pengiriman Sekarang'),
              onPressed: () {
                Navigator.of(ctx).pop();
                _openSelesaikanPage(item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildModalRow(
    String label,
    String value, {
    bool isBold = false,
    bool isItalic = false,
    double fontSize = 13,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                color: textColor ?? AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancel(PengirimanPabrik item) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        title: const Text(
          'Batalkan Pengiriman Ini?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengiriman ${item.kodePengiriman} ke ${item.pabrik?.nama ?? "pabrik"} akan ditandai sebagai DIBATALKAN.',
              style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Alasan Pembatalan',
                hintText: 'Contoh: Salah input armada / retur dari PKS',
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Batalkan Pengiriman'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(pengirimanListProvider.notifier)
          .cancelPengiriman(item.id, controller.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengiriman ${item.kodePengiriman} telah dibatalkan.'),
            backgroundColor: AppColors.ink,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(pengirimanListProvider);

    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: EdgeInsets.all(isNarrow ? 12.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            if (isNarrow)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Riwayat Penjualan ke Pabrik',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.file_download_outlined, size: 16),
                          label: const Text('Export', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: () {
                            final dateRange = _getDateRangeForPreset(_selectedDatePreset);
                            ExportLaporanPengirimanDialog.show(
                              context,
                              startDate: dateRange?.start,
                              endDate: dateRange?.end,
                            );
                          },
                        ),
                      ),
                      if (widget.onNavigateToForm != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: widget.onNavigateToForm,
                            icon: const Icon(Icons.local_shipping_outlined, size: 16),
                            label: const Text(
                              'Catat Truk (F1)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              )
            else
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Penjualan ke Pabrik',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kelola alur pengiriman 2-fase TBS sawit ke pabrik pengolahan kelapa sawit (PKS).',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.file_download_outlined, size: 18),
                        label: const Text('Export Laporan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.canvas,
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () {
                          final dateRange =
                              _getDateRangeForPreset(_selectedDatePreset);
                          ExportLaporanPengirimanDialog.show(
                            context,
                            startDate: dateRange?.start,
                            endDate: dateRange?.end,
                          );
                        },
                      ),
                      if (widget.onNavigateToForm != null)
                        ElevatedButton.icon(
                          onPressed: widget.onNavigateToForm,
                          icon: const Icon(Icons.local_shipping_outlined, size: 18),
                          label: const Text('Catat Truk Berangkat (Fase 1)'),
                        ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Tab Bar: Belum Selesai vs Semua Riwayat
            listAsync.maybeWhen(
              data: (allList) {
                final belumSelesaiCount =
                    allList.where((p) => p.isBerangkat).length;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTabButton(
                      label: 'Belum Selesai',
                      count: belumSelesaiCount,
                      isSelected: _selectedTabIndex == 0,
                      onTap: () => setState(() {
                        _selectedTabIndex = 0;
                        _currentPage = 1;
                      }),
                      highlightColor: Colors.orange.shade800,
                    ),
                    _buildTabButton(
                      label: 'Semua Riwayat',
                      count: allList.length,
                      isSelected: _selectedTabIndex == 1,
                      onTap: () => setState(() {
                        _selectedTabIndex = 1;
                        _currentPage = 1;
                      }),
                    ),
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),

            // Bilah Filter Periode Terstandarisasi (Desktop langsung tampil, Mobile lewat tombol toggle non-sticky)
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;
                final filterCard = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Wrap(
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
                          key: Key('filter_pengiriman_preset_${p.$1}'),
                          label: Text(p.$2),
                          selected: _selectedDatePreset == p.$1,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedDatePreset = p.$1;
                                _currentPage = 1;
                              });
                            }
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _selectedDatePreset == p.$1
                                ? Colors.white
                                : AppColors.ink,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(
                              color: _selectedDatePreset == p.$1
                                  ? AppColors.primary
                                  : AppColors.hairline,
                            ),
                          ),
                        ),
                      OutlinedButton.icon(
                        key: const Key('filter_pengiriman_preset_kustom'),
                        onPressed: () => _handleCustomDateRange(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          side: BorderSide(
                            color: _selectedDatePreset == 'kustom'
                                ? AppColors.primary
                                : AppColors.hairline,
                          ),
                          backgroundColor: _selectedDatePreset == 'kustom'
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
                          color: _selectedDatePreset == 'kustom'
                              ? AppColors.primary
                              : AppColors.inkMuted,
                        ),
                        label: Text(
                          _selectedDatePreset == 'kustom'
                              ? 'Kustom (Aktif)'
                              : 'Kustom Tanggal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _selectedDatePreset == 'kustom'
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
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
                      key: const Key('toggle_filter_pengiriman_btn'),
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
                                  ? 'Tutup Panel Filter Pengiriman'
                                  : 'Filter Pengiriman: ${_activePengirimanPresetLabel(_selectedDatePreset)}',
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
            const SizedBox(height: 12),

            // Search Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Cari berdasarkan kode pengiriman, pabrik, plat nomor, atau sopir...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _currentPage = 1;
                                  });
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Refresh Data',
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () =>
                        ref.read(pengirimanListProvider.notifier).refresh(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content List
            Expanded(
              child: listAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat riwayat pengiriman:\n$err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(pengirimanListProvider.notifier).refresh(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
                data: (list) {
                  // Filter berdasarkan Tab
                  final tabFiltered = _selectedTabIndex == 0
                      ? list.where((p) => p.isBerangkat).toList()
                      : list;

                  // Filter berdasarkan Periode Tanggal (FR-4.1)
                  final dateRange = _getDateRangeForPreset(_selectedDatePreset);
                  final dateFiltered = dateRange == null
                      ? tabFiltered
                      : tabFiltered.where((p) {
                          final tgl = p.tanggalKirim;
                          return (tgl.isAfter(dateRange.start) ||
                                  tgl.isAtSameMomentAs(dateRange.start)) &&
                              (tgl.isBefore(dateRange.end) ||
                                  tgl.isAtSameMomentAs(dateRange.end));
                        }).toList();

                  // Filter berdasarkan Pencarian
                  final filtered = dateFiltered.where((k) {
                    if (_searchQuery.isEmpty) return true;
                    final matchKode =
                        k.kodePengiriman.toLowerCase().contains(_searchQuery);
                    final matchPlat =
                        k.platNomor.toLowerCase().contains(_searchQuery);
                    final matchSopir =
                        k.namaSopir.toLowerCase().contains(_searchQuery);
                    final matchPabrik =
                        k.pabrik?.nama.toLowerCase().contains(_searchQuery) ??
                            false;
                    return matchKode || matchPlat || matchSopir || matchPabrik;
                  }).toList();

                  if (filtered.isEmpty) {
                    final emptyMessage = _selectedTabIndex == 0
                        ? 'Tidak ada pengiriman yang berstatus "Belum Selesai" (Berangkat).'
                        : 'Belum ada riwayat pengiriman ke pabrik.';
                    final emptySub = _selectedTabIndex == 0
                        ? 'Semua truk telah diselesaikan (Fase 2) atau belum ada truk yang diberangkatkan.'
                        : 'Silakan catat keberangkatan truk baru menggunakan tombol di atas.';

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _selectedTabIndex == 0
                                ? Icons.task_alt_outlined
                                : Icons.local_shipping_outlined,
                            size: 48,
                            color: AppColors.inkSubtle.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            emptyMessage,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emptySub,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.inkSubtle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final totalCount = filtered.length;
                  final totalPages = (totalCount / _pageSize).ceil().clamp(1, 999999);
                  final safePage = _currentPage.clamp(1, totalPages);
                  final startIndex = (safePage - 1) * _pageSize;
                  final endIndex = (startIndex + _pageSize).clamp(0, totalCount);
                  final pagedList = filtered.sublist(startIndex, endIndex);

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: pagedList.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = pagedList[index];
                            return _PengirimanItemCard(
                              item: item,
                              onTapDetail: () => _showDetailModal(item),
                              onCancel: () => _handleCancel(item),
                              onSelesaikan: () => _openSelesaikanPage(item),
                            );
                          },
                        ),
                      ),
                      EnterprisePaginationBar(
                        currentPage: safePage,
                        totalPages: totalPages,
                        totalItems: totalCount,
                        pageSize: _pageSize,
                        onPageChanged: (newPage) {
                          setState(() => _currentPage = newPage);
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

  Widget _buildTabButton({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color? highlightColor,
  }) {
    final activeColor = highlightColor ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : AppColors.surface1,
          border: Border.all(
            color: isSelected ? activeColor : AppColors.hairline,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : AppColors.ink,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PengirimanItemCard extends StatelessWidget {
  final PengirimanPabrik item;
  final VoidCallback onTapDetail;
  final VoidCallback onCancel;
  final VoidCallback onSelesaikan;

  const _PengirimanItemCard({
    required this.item,
    required this.onTapDetail,
    required this.onCancel,
    required this.onSelesaikan,
  });

  @override
  Widget build(BuildContext context) {
    final isBerangkat = item.isBerangkat;
    final isSelesai = item.isSelesai;

    return Container(
      decoration: BoxDecoration(
        color: isBerangkat
            ? Colors.orange.shade50.withValues(alpha: 0.3)
            : isSelesai
                ? AppColors.canvas
                : AppColors.surface2,
        border: Border.all(
          color: isBerangkat ? Colors.orange.shade300 : AppColors.hairline,
          width: isBerangkat ? 1.2 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTapDetail,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card: Kode Pengiriman, Tanggal, Status Badge
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      item.kodePengiriman,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('d MMM yyyy', 'id_ID')
                        .format(item.tanggalKirim),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isBerangkat
                          ? Colors.orange.shade100
                          : isSelesai
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                      border: Border.all(
                        color: isBerangkat
                            ? Colors.orange.shade700
                            : isSelesai
                                ? AppColors.success
                                : AppColors.error,
                      ),
                    ),
                    child: Text(
                      isBerangkat ? 'BERANGKAT' : item.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isBerangkat
                            ? Colors.orange.shade900
                            : isSelesai
                                ? AppColors.success
                                : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Pabrik, Sopir, Plat Nomor & Nilai Penjualan
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 320;

                  final infoColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.pabrik?.nama ?? 'Pabrik ID: ${item.pabrikId}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined,
                              size: 14, color: AppColors.inkMuted),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${item.platNomor} • Sopir: ${item.namaSopir}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.inkMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  final valueColumn = Column(
                    crossAxisAlignment: isCompact
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      if (isBerangkat) ...[
                        Text(
                          'Menunggu Truk',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Belum ada slip PKS',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ] else if (isSelesai) ...[
                        Text(
                          CurrencyFormatter.format(
                              item.totalNilaiJual ?? Decimal.zero),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${CurrencyFormatter.format(item.hargaJualPerKg ?? Decimal.zero)} / kg',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Dibatalkan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        infoColumn,
                        const SizedBox(height: 8),
                        valueColumn,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: infoColumn),
                      const SizedBox(width: 8),
                      valueColumn,
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.hairline, height: 1),
              const SizedBox(height: 10),

              // Rincian Berat & Tombol Aksi
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          isSelesai
                              ? 'Berat Sampai: ${WeightFormatter.format(item.beratSampaiKg ?? item.beratDikirimKg)}'
                              : 'Berat Dikirim: ${WeightFormatter.format(item.beratDikirimKg)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        if (isBerangkat) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              'Hasil PKS: Belum diisi (Fase 2)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ] else if (isSelesai) ...[
                          if ((item.beratDitolakKg ?? Decimal.zero) > Decimal.zero)
                            Text(
                              'Ditolak: ${WeightFormatter.format(item.beratDitolakKg ?? Decimal.zero)}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.error),
                            ),
                          Text(
                            'Diterima: ${WeightFormatter.format(item.beratDiterimaKg ?? Decimal.zero)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          if ((item.persentasePotonganPabrik ?? Decimal.zero) >
                              Decimal.zero)
                            Text(
                              'Pot: ${item.persentasePotonganPabrik}%',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.inkMuted),
                            ),
                          Text(
                            'Bersih: ${WeightFormatter.format(item.beratBersihKg ?? Decimal.zero)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Tombol Aksi
                  if (isBerangkat) ...[
                    ElevatedButton.icon(
                      key: Key('selesaikan_btn_${item.kodePengiriman}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.receipt_long, size: 14),
                      label: const Text(
                        'Selesaikan',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: onSelesaikan,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Batalkan Pengiriman',
                      icon: const Icon(Icons.cancel_outlined,
                          size: 18, color: AppColors.error),
                      onPressed: onCancel,
                    ),
                  ] else if (isSelesai) ...[
                    IconButton(
                      tooltip: 'Batalkan Pengiriman',
                      icon: const Icon(Icons.cancel_outlined,
                          size: 18, color: AppColors.error),
                      onPressed: onCancel,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

