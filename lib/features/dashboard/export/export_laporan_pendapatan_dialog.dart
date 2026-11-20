import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/file_saver/file_saver.dart';
import '../../../models/dashboard_analytics.dart';
import '../../../models/laporan_pendapatan.dart';
import '../dashboard_repository.dart';
import 'laporan_pendapatan_excel_generator.dart';
import 'laporan_pendapatan_pdf_generator.dart';

/// Modal dialog pemilihan cakupan dan format export Laporan Pendapatan (FR-7.8)
/// Khusus untuk role Admin (berisi data sensitif margin & keuntungan).
class ExportLaporanPendapatanDialog extends ConsumerStatefulWidget {
  final CakupanLaporanPendapatan initialCakupan;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? presetLabel;
  final List<LabaBersihHarian>? initialDailyData;

  const ExportLaporanPendapatanDialog({
    super.key,
    this.initialCakupan = CakupanLaporanPendapatan.satuBulan,
    this.startDate,
    this.endDate,
    this.presetLabel,
    this.initialDailyData,
  });

  static Future<void> show(
    BuildContext context, {
    CakupanLaporanPendapatan initialCakupan =
        CakupanLaporanPendapatan.satuBulan,
    DateTime? startDate,
    DateTime? endDate,
    String? presetLabel,
    List<LabaBersihHarian>? initialDailyData,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ExportLaporanPendapatanDialog(
        initialCakupan: initialCakupan,
        startDate: startDate,
        endDate: endDate,
        presetLabel: presetLabel,
        initialDailyData: initialDailyData,
      ),
    );
  }

  @override
  ConsumerState<ExportLaporanPendapatanDialog> createState() =>
      _ExportLaporanPendapatanDialogState();
}

class _ExportLaporanPendapatanDialogState
    extends ConsumerState<ExportLaporanPendapatanDialog> {
  late CakupanLaporanPendapatan _selectedCakupan;
  late int _selectedYear;
  late int _selectedQuarter;
  late int _selectedMonth;

  String _selectedFormat = 'excel'; // 'excel' | 'pdf'
  bool _isLoading = true;
  bool _isExporting = false;
  String? _errorMessage;
  LaporanPendapatanData? _data;

  bool get _isFilterMode =>
      widget.startDate != null || widget.initialDailyData != null;

  String get _periodeFilterText {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final s = widget.startDate ?? (_data?.startDate);
    final e = widget.endDate ?? (_data?.endDate);
    if (s != null && e != null) {
      if (s.year == e.year && s.month == e.month && s.day == e.day) {
        return dateFormat.format(s);
      }
      return '${dateFormat.format(s)} – ${dateFormat.format(e)}';
    } else if (s != null) {
      return 'Sejak ${dateFormat.format(s)}';
    }
    return 'Semua Periode Data';
  }

  final List<int> _availableYears = [
    DateTime.now().year - 2,
    DateTime.now().year - 1,
    DateTime.now().year,
    DateTime.now().year + 1,
  ];

  static const List<String> _namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedCakupan =
        _isFilterMode ? CakupanLaporanPendapatan.kustom : widget.initialCakupan;
    _selectedYear = now.year;
    _selectedQuarter = ((now.month - 1) ~/ 3) + 1;
    _selectedMonth = now.month;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isFilterMode) {
        final start = widget.startDate ??
            (widget.initialDailyData != null &&
                    widget.initialDailyData!.isNotEmpty
                ? widget.initialDailyData!.first.tanggal
                : DateTime.now());
        final end = widget.endDate ?? start;

        if (widget.initialDailyData != null &&
            widget.initialDailyData!.isNotEmpty) {
          final aggregated = LaporanPendapatanAggregator.aggregateFromDaily(
            dailyLabaBersih: widget.initialDailyData!,
            startDate: start,
            endDate: end,
            judulCakupan: widget.presetLabel,
          );
          if (mounted) {
            setState(() {
              _data = aggregated;
              _isLoading = false;
            });
          }
          return;
        }

        final repo = ref.read(dashboardRepositoryProvider);
        final dailyLabaBersih = await repo.getLabaBersihHarian(start, end);
        final aggregated = LaporanPendapatanAggregator.aggregateFromDaily(
          dailyLabaBersih: dailyLabaBersih,
          startDate: start,
          endDate: end,
          judulCakupan: widget.presetLabel,
        );
        if (mounted) {
          setState(() {
            _data = aggregated;
            _isLoading = false;
          });
        }
        return;
      }

      final repo = ref.read(dashboardRepositoryProvider);
      final refDate = DateTime(_selectedYear, _selectedMonth, 1);

      final dateRange = LaporanPendapatanAggregator.getDateRange(
        cakupan: _selectedCakupan,
        referenceDate: refDate,
        selectedQuarter: _selectedQuarter,
      );

      final dailyLabaBersih = await repo.getLabaBersihHarian(
        dateRange.$1,
        dateRange.$2,
      );

      final aggregated = LaporanPendapatanAggregator.aggregate(
        dailyLabaBersih: dailyLabaBersih,
        cakupan: _selectedCakupan,
        referenceDate: refDate,
        selectedQuarter: _selectedQuarter,
      );

      if (mounted) {
        setState(() {
          _data = aggregated;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleExport() async {
    if (_data == null || _data!.rows.isEmpty) return;

    setState(() => _isExporting = true);

    try {
      if (_selectedFormat == 'excel') {
        final fileName = LaporanPendapatanExcelGenerator.generateFileName(
          cakupan: _data!.cakupan,
          startDate: _data!.startDate,
          endDate: _data!.endDate,
        );

        final bytes = LaporanPendapatanExcelGenerator.generate(
          data: _data!,
        );

        await FileSaver.saveOrShareFile(
          bytes: bytes,
          fileName: fileName,
          mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
      } else {
        final fileName = LaporanPendapatanPdfGenerator.generateFileName(
          cakupan: _data!.cakupan,
          startDate: _data!.startDate,
          endDate: _data!.endDate,
        );

        final bytes = await LaporanPendapatanPdfGenerator.generate(
          data: _data!,
        );

        await FileSaver.saveOrShareFile(
          bytes: bytes,
          fileName: fileName,
          mimeType: 'application/pdf',
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb
                  ? 'Laporan Pendapatan berhasil diunduh ke browser.'
                  : 'Laporan Pendapatan berhasil diekspor.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor laporan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      backgroundColor: AppColors.canvas,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header
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
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ekspor Laporan Pendapatan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Rangkuman Total Pembelian, Penjualan, dan Margin Keuntungan (FR-7.8)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              if (_isFilterMode) ...[
                // Periode yang diterapkan dari filter halaman aktif
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.date_range,
                              size: 16, color: AppColors.inkMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Periode: $_periodeFilterText',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.presetLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.presetLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.error),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_data?.rows.length ?? 0} Hari Data Tercatat',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.inkMuted,
                              ),
                            ),
                            Text(
                              'Laba Bersih: ${CurrencyFormatter.format(_data?.grandTotalLabaBersih ?? Decimal.zero)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: (_data?.isLabaBersihSurplus ?? true)
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // 2. Pemilihan Cakupan Periode (1 Tahun, 3 Bulan, 1 Bulan)
                const Text(
                  'Pilih Cakupan Periode:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CakupanLaporanPendapatan.satuBulan,
                    CakupanLaporanPendapatan.tigaBulan,
                    CakupanLaporanPendapatan.satuTahun,
                  ].map((cakupan) {
                    final isSelected = _selectedCakupan == cakupan;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            if (_selectedCakupan != cakupan) {
                              setState(() => _selectedCakupan = cakupan);
                              _loadData();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : AppColors.surface1,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.hairline,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  cakupan.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cakupan == CakupanLaporanPendapatan.satuTahun
                                      ? 'Per Kuartal'
                                      : cakupan == CakupanLaporanPendapatan.tigaBulan
                                          ? 'Per Bulan'
                                          : 'Per Minggu',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 3. Filter Parameter Spesifik (Tahun / Kuartal / Bulan)
                _buildSpecificPeriodSelectors(),
                const SizedBox(height: 16),
              ],

              // 4. Live Preview Tabel Rangkuman
              const Text(
                'Pratinjau Data Laporan:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              _buildDataPreviewTable(),
              const SizedBox(height: 20),

              // 5. Pilihan Format Export (Excel / PDF)
              const Text(
                'Pilih Format Dokumen:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildFormatCard(
                      format: 'excel',
                      title: 'Microsoft Excel (.xlsx)',
                      subtitle: 'Cocok untuk rekapitulasi data & spreadsheet',
                      icon: Icons.table_chart_outlined,
                      isSelected: _selectedFormat == 'excel',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormatCard(
                      format: 'pdf',
                      title: 'Dokumen PDF (.pdf)',
                      subtitle: 'Format resmi cetak & arsip pemilik usaha',
                      icon: Icons.picture_as_pdf_outlined,
                      isSelected: _selectedFormat == 'pdf',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Tombol Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isExporting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: (_isExporting ||
                            _isLoading ||
                            _data == null ||
                            _data!.rows.isEmpty)
                        ? null
                        : _handleExport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download, size: 18),
                    label: Text(
                      _isExporting
                          ? 'Mengekspor...'
                          : 'Unduh ${_selectedFormat.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Selector spesifik berdasarkan cakupan yang aktif
  Widget _buildSpecificPeriodSelectors() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          const Text(
            'Periode:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 12),

          // Parameter untuk 1 Tahun
          if (_selectedCakupan == CakupanLaporanPendapatan.satuTahun) ...[
            DropdownButton<int>(
              value: _selectedYear,
              underline: const SizedBox(),
              items: _availableYears.map((y) {
                return DropdownMenuItem<int>(
                  value: y,
                  child: Text('Tahun $y', style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (newYear) {
                if (newYear != null && newYear != _selectedYear) {
                  setState(() => _selectedYear = newYear);
                  _loadData();
                }
              },
            ),
          ],

          // Parameter untuk 3 Bulan
          if (_selectedCakupan == CakupanLaporanPendapatan.tigaBulan) ...[
            DropdownButton<int>(
              value: _selectedQuarter,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('Kuartal 1 (Jan - Mar)', style: TextStyle(fontSize: 13)),
                ),
                DropdownMenuItem<int>(
                  value: 2,
                  child: Text('Kuartal 2 (Apr - Jun)', style: TextStyle(fontSize: 13)),
                ),
                DropdownMenuItem<int>(
                  value: 3,
                  child: Text('Kuartal 3 (Jul - Sep)', style: TextStyle(fontSize: 13)),
                ),
                DropdownMenuItem<int>(
                  value: 4,
                  child: Text('Kuartal 4 (Okt - Des)', style: TextStyle(fontSize: 13)),
                ),
              ],
              onChanged: (newQuarter) {
                if (newQuarter != null && newQuarter != _selectedQuarter) {
                  setState(() => _selectedQuarter = newQuarter);
                  _loadData();
                }
              },
            ),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: _selectedYear,
              underline: const SizedBox(),
              items: _availableYears.map((y) {
                return DropdownMenuItem<int>(
                  value: y,
                  child: Text('$y', style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (newYear) {
                if (newYear != null && newYear != _selectedYear) {
                  setState(() => _selectedYear = newYear);
                  _loadData();
                }
              },
            ),
          ],

          // Parameter untuk 1 Bulan
          if (_selectedCakupan == CakupanLaporanPendapatan.satuBulan) ...[
            DropdownButton<int>(
              value: _selectedMonth,
              underline: const SizedBox(),
              items: List.generate(12, (i) {
                final m = i + 1;
                return DropdownMenuItem<int>(
                  value: m,
                  child: Text(_namaBulan[m], style: const TextStyle(fontSize: 13)),
                );
              }),
              onChanged: (newMonth) {
                if (newMonth != null && newMonth != _selectedMonth) {
                  setState(() => _selectedMonth = newMonth);
                  _loadData();
                }
              },
            ),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: _selectedYear,
              underline: const SizedBox(),
              items: _availableYears.map((y) {
                return DropdownMenuItem<int>(
                  value: y,
                  child: Text('$y', style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (newYear) {
                if (newYear != null && newYear != _selectedYear) {
                  setState(() => _selectedYear = newYear);
                  _loadData();
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Live preview tabel ringkasan pendapatan
  Widget _buildDataPreviewTable() {
    if (_isLoading) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            SizedBox(height: 12),
            Text(
              'Menghitung ringkasan pendapatan...',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          border: Border.all(color: AppColors.error),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    }

    final data = _data;
    if (data == null || data.rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Tidak ada data transaksi atau penjualan pada rentang periode ini.',
          style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.0),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.4),
          4: FlexColumnWidth(1.4),
          5: FlexColumnWidth(1.5),
        },
        children: [
          // Header tabel
          TableRow(
            decoration: const BoxDecoration(
              color: AppColors.surface2,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'Periode',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'Beli (Rp)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'Jual (Rp)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'Margin (Rp)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'Biaya (Rp)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'Laba Bersih (Rp)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),

          // Baris data
          ...data.rows.map((row) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.hairline, width: 0.5),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    row.periodeLabel,
                    style: const TextStyle(fontSize: 11, color: AppColors.ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    CurrencyFormatter.format(row.totalPembelian),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: AppColors.ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    CurrencyFormatter.format(row.totalPenjualan),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: AppColors.ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    CurrencyFormatter.format(row.margin),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: AppColors.ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    CurrencyFormatter.format(row.totalPengeluaran),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: AppColors.ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    CurrencyFormatter.format(row.labaBersih),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: row.isLabaBersihSurplus
                          ? AppColors.primary
                          : AppColors.error,
                    ),
                  ),
                ),
              ],
            );
          }),

          // Baris Total Keseluruhan
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              border: const Border(
                top: BorderSide(color: AppColors.hairline, width: 1.5),
              ),
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                child: Text(
                  'Total Keseluruhan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                child: Text(
                  CurrencyFormatter.format(data.grandTotalPembelian),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                child: Text(
                  CurrencyFormatter.format(data.grandTotalPenjualan),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                child: Text(
                  CurrencyFormatter.format(data.grandTotalMargin),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                child: Text(
                  CurrencyFormatter.format(data.grandTotalPengeluaran),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                child: Text(
                  CurrencyFormatter.format(data.grandTotalLabaBersih),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: data.isLabaBersihSurplus
                        ? AppColors.primary
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Kartu pilihan format export
  Widget _buildFormatCard({
    required String format,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.canvas,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.hairline,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.inkMuted,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
