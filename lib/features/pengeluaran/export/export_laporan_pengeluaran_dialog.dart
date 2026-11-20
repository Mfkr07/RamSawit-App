import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/file_saver/file_saver.dart';
import '../../../models/pengeluaran.dart';
import '../pengeluaran_repository.dart';
import 'laporan_pengeluaran_excel_generator.dart';
import 'laporan_pengeluaran_pdf_generator.dart';

/// Modal dialog export laporan pencatatan pengeluaran (FR-9.6)
/// Tersedia untuk semua role (Admin & Kasir).
class ExportLaporanPengeluaranDialog extends ConsumerStatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? jenisPengeluaranId;
  final String? jenisPengeluaranNama;

  const ExportLaporanPengeluaranDialog({
    super.key,
    this.startDate,
    this.endDate,
    this.jenisPengeluaranId,
    this.jenisPengeluaranNama,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    int? jenisPengeluaranId,
    String? jenisPengeluaranNama,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ExportLaporanPengeluaranDialog(
        startDate: startDate,
        endDate: endDate,
        jenisPengeluaranId: jenisPengeluaranId,
        jenisPengeluaranNama: jenisPengeluaranNama,
      ),
    );
  }

  @override
  ConsumerState<ExportLaporanPengeluaranDialog> createState() =>
      _ExportLaporanPengeluaranDialogState();
}

class _ExportLaporanPengeluaranDialogState
    extends ConsumerState<ExportLaporanPengeluaranDialog> {
  String _selectedFormat = 'excel'; // 'excel' | 'pdf'
  bool _isExporting = false;
  bool _isLoading = true;
  List<Pengeluaran> _items = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(pengeluaranRepositoryProvider);
      final list = await repo.fetchAllPengeluaranForExport(
        startDate: widget.startDate,
        endDate: widget.endDate,
        jenisPengeluaranId: widget.jenisPengeluaranId,
      );

      if (mounted) {
        setState(() {
          _items = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleExport() async {
    if (_items.isEmpty) return;

    setState(() => _isExporting = true);

    try {
      Uint8List bytes;
      String fileName;
      String mimeType;

      if (_selectedFormat == 'excel') {
        bytes = LaporanPengeluaranExcelGenerator.generate(
          items: _items,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
        fileName = LaporanPengeluaranExcelGenerator.generateFileName(
          startDate: widget.startDate,
          endDate: widget.endDate,
          extension: 'xlsx',
        );
        mimeType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else {
        bytes = await LaporanPengeluaranPdfGenerator.generate(
          items: _items,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
        fileName = LaporanPengeluaranPdfGenerator.generateFileName(
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
        mimeType = 'application/pdf';
      }

      await FileSaver.saveOrShareFile(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan berhasil diekspor ($fileName)'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor laporan: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    String periodeText;
    if (widget.startDate != null && widget.endDate != null) {
      periodeText =
          '${dateFormat.format(widget.startDate!)} – ${dateFormat.format(widget.endDate!)}';
    } else if (widget.startDate != null) {
      periodeText = 'Sejak ${dateFormat.format(widget.startDate!)}';
    } else if (widget.endDate != null) {
      periodeText = 'Hingga ${dateFormat.format(widget.endDate!)}';
    } else {
      periodeText = 'Semua Riwayat Transaksi';
    }

    final totalNominal = _items.fold<dynamic>(
      0,
      (sum, item) => sum + item.nominal,
    );

    return Dialog(
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.file_download_outlined,
                        color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Export Laporan Pengeluaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.inkMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 16),

            // Metadata Filter Aktif
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                border: Border.all(color: AppColors.hairline),
                borderRadius: const BorderRadius.all(Radius.circular(2.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 14, color: AppColors.inkMuted),
                      const SizedBox(width: 6),
                      const Text(
                        'Filter Periode: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        periodeText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (widget.jenisPengeluaranNama != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined,
                            size: 14, color: AppColors.inkMuted),
                        const SizedBox(width: 6),
                        const Text(
                          'Kategori: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.jenisPengeluaranNama!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ringkasan Data
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: AppColors.error.withValues(alpha: 0.1),
                child: Text(
                  'Gagal memuat data: $_errorMessage',
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL TRANSAKSI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_items.length} Catatan',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'TOTAL PENGELUARAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(totalNominal),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Pilihan Format Export
              const Text(
                'FORMAT FILE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _FormatOptionCard(
                      title: 'Excel (.xlsx)',
                      description: 'Tabel spreadsheet lengkap',
                      icon: Icons.table_chart_outlined,
                      isSelected: _selectedFormat == 'excel',
                      onTap: () => setState(() => _selectedFormat = 'excel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormatOptionCard(
                      title: 'PDF (.pdf)',
                      description: 'Dokumen siap cetak',
                      icon: Icons.picture_as_pdf_outlined,
                      isSelected: _selectedFormat == 'pdf',
                      onTap: () => setState(() => _selectedFormat = 'pdf'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.hairline),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: (_isLoading || _items.isEmpty || _isExporting)
                      ? null
                      : _handleExport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                      : const Icon(Icons.download, size: 16),
                  label: Text(_isExporting ? 'Mengekspor...' : 'Unduh Laporan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(2)),
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
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : AppColors.inkMuted,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
