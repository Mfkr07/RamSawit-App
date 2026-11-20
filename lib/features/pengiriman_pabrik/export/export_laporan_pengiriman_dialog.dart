import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_saver/file_saver.dart';
import '../../../models/pengiriman_pabrik.dart';
import '../pengiriman_pabrik_repository.dart';
import 'laporan_pengiriman_excel_generator.dart';
import 'laporan_pengiriman_pdf_generator.dart';

/// Modal dialog export laporan penjualan TBS ke pabrik (FR-7.7 & FR-8.9)
/// Hanya menyertakan status 'selesai'.
class ExportLaporanPengirimanDialog extends ConsumerStatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? pabrikId;

  const ExportLaporanPengirimanDialog({
    super.key,
    this.startDate,
    this.endDate,
    this.pabrikId,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    String? pabrikId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ExportLaporanPengirimanDialog(
        startDate: startDate,
        endDate: endDate,
        pabrikId: pabrikId,
      ),
    );
  }

  @override
  ConsumerState<ExportLaporanPengirimanDialog> createState() =>
      _ExportLaporanPengirimanDialogState();
}

class _ExportLaporanPengirimanDialogState
    extends ConsumerState<ExportLaporanPengirimanDialog> {
  String _selectedFormat = 'excel'; // 'excel' | 'pdf'
  bool _isExporting = false;
  bool _isLoading = true;
  List<PengirimanPabrik> _items = [];
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
      final repo = ref.read(pengirimanPabrikRepositoryProvider);
      // Filter ketat: status hanya 'selesai' sesuai FR-8.9
      final fetched = await repo.getPengirimanList(
        status: 'selesai',
        pabrikId: widget.pabrikId,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      if (mounted) {
        setState(() {
          _items = fetched.where((item) => item.isSelesai).toList();
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

  String _formatRange() {
    if (widget.startDate != null && widget.endDate != null) {
      final s = DateFormat('d MMM yyyy', 'id_ID').format(widget.startDate!);
      final e = DateFormat('d MMM yyyy', 'id_ID').format(widget.endDate!);
      return (s == e) ? s : '$s s/d $e';
    } else if (widget.startDate != null) {
      return 'Sejak ${DateFormat('d MMM yyyy', 'id_ID').format(widget.startDate!)}';
    } else if (widget.endDate != null) {
      return 'Hingga ${DateFormat('d MMM yyyy', 'id_ID').format(widget.endDate!)}';
    } else {
      return 'Semua Periode Tanggal';
    }
  }

  Future<void> _handleExport() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak ada data pengiriman berstatus selesai pada rentang tanggal yang dipilih.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      if (_selectedFormat == 'excel') {
        final fileName = LaporanPengirimanExcelGenerator.generateFileName(
          startDate: widget.startDate,
          endDate: widget.endDate,
          extension: 'xlsx',
        );

        final bytes = LaporanPengirimanExcelGenerator.generate(
          items: _items,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );

        await FileSaver.saveOrShareFile(
          bytes: bytes,
          fileName: fileName,
          mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
      } else {
        final fileName = LaporanPengirimanPdfGenerator.generateFileName(
          startDate: widget.startDate,
          endDate: widget.endDate,
        );

        final bytes = await LaporanPengirimanPdfGenerator.generate(
          items: _items,
          startDate: widget.startDate,
          endDate: widget.endDate,
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
                  ? 'Laporan penjualan pabrik berhasil diunduh ke browser.'
                  : 'Laporan penjualan pabrik berhasil diekspor.',
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
    final isEmpty = _items.isEmpty && !_isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      backgroundColor: AppColors.canvas,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
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
                          'Export Penjualan ke Pabrik',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Rekapitulasi pengiriman PKS status selesai (FR-7.7)',
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
              const Divider(height: 28),

              // Info Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          size: 16,
                          color: AppColors.inkMuted,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Rentang Laporan Aktif:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Text(
                            '${_items.length} Pengiriman Selesai',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isEmpty
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRange(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Peringatan: $_errorMessage',
                        style: const TextStyle(fontSize: 11, color: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'PILIH FORMAT DOKUMEN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 8),

              // Opsi Format: Excel
              InkWell(
                onTap: isEmpty || _isLoading
                    ? null
                    : () => setState(() => _selectedFormat = 'excel'),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedFormat == 'excel'
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.canvas,
                    border: Border.all(
                      color: _selectedFormat == 'excel'
                          ? AppColors.primary
                          : AppColors.hairline,
                      width: _selectedFormat == 'excel' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.table_chart_outlined,
                        color: Color(0xFF107C41),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Microsoft Excel (.xlsx)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Data rincian timbangan kotor, ditolak, diterima & nilai jual',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ignore: deprecated_member_use
                      Radio<String>(
                        value: 'excel',
                        // ignore: deprecated_member_use
                        groupValue: _selectedFormat,
                        // ignore: deprecated_member_use
                        onChanged: (isEmpty || _isLoading)
                            ? null
                            : (val) => setState(() => _selectedFormat = val!),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Opsi Format: PDF
              InkWell(
                onTap: isEmpty || _isLoading
                    ? null
                    : () => setState(() => _selectedFormat = 'pdf'),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedFormat == 'pdf'
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.canvas,
                    border: Border.all(
                      color: _selectedFormat == 'pdf'
                          ? AppColors.primary
                          : AppColors.hairline,
                      width: _selectedFormat == 'pdf' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Color(0xFFD9381E),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dokumen PDF Siap Cetak (.pdf)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Format landscape A4 lengkap dengan rekapitulasi total',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ignore: deprecated_member_use
                      Radio<String>(
                        value: 'pdf',
                        // ignore: deprecated_member_use
                        groupValue: _selectedFormat,
                        // ignore: deprecated_member_use
                        onChanged: (isEmpty || _isLoading)
                            ? null
                            : (val) => setState(() => _selectedFormat = val!),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tombol Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isExporting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.hairline),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                    onPressed: (isEmpty || _isExporting || _isLoading)
                        ? null
                        : _handleExport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.hairline,
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
                          : (kIsWeb ? 'Download Laporan' : 'Export / Bagikan'),
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
}
