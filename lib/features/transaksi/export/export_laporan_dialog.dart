import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_saver/file_saver.dart';
import '../../../models/laporan_export_item.dart';
import '../transaksi_repository.dart';
import 'laporan_excel_generator.dart';
import 'laporan_pdf_generator.dart';

/// Modal dialog pemilihan format export laporan pembelian (Excel atau PDF)
/// Mengambil data detail per jenis buah dari `transaksi_item` (FR-7.2, FR-7.6, Tugas Bagian 14).
class ExportLaporanDialog extends ConsumerStatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? penjualId;
  final String status;
  final String jenisPembayaran;
  final List<LaporanPembelianItem>? preloadedItems;

  const ExportLaporanDialog({
    super.key,
    this.startDate,
    this.endDate,
    this.penjualId,
    this.status = 'semua',
    this.jenisPembayaran = 'semua',
    this.preloadedItems,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    String? penjualId,
    String status = 'semua',
    String jenisPembayaran = 'semua',
    List<LaporanPembelianItem>? items,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ExportLaporanDialog(
        startDate: startDate,
        endDate: endDate,
        penjualId: penjualId,
        status: status,
        jenisPembayaran: jenisPembayaran,
        preloadedItems: items,
      ),
    );
  }

  @override
  ConsumerState<ExportLaporanDialog> createState() => _ExportLaporanDialogState();
}

class _ExportLaporanDialogState extends ConsumerState<ExportLaporanDialog> {
  String _selectedFormat = 'excel'; // 'excel' | 'pdf'
  bool _isExporting = false;
  bool _isLoading = true;
  List<LaporanPembelianItem> _items = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedItems != null) {
      _items = widget.preloadedItems!;
      _isLoading = false;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(transaksiRepositoryProvider);
      final fetched = await repo.getLaporanPembelianItems(
        startDate: widget.startDate,
        endDate: widget.endDate,
        penjualId: widget.penjualId,
        status: widget.status,
        jenisPembayaran: widget.jenisPembayaran,
      );

      if (mounted) {
        setState(() {
          _items = fetched;
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

  int _getUniqueTransactionsCount() {
    final codes = _items.map((e) => e.kodeTransaksi).toSet();
    return codes.length;
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
    if (_isExporting) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak ada data transaksi pada rentang tanggal yang dipilih untuk diekspor.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      if (_selectedFormat == 'excel') {
        final fileName = LaporanExcelGenerator.generateFileName(
          startDate: widget.startDate,
          endDate: widget.endDate,
          extension: 'xlsx',
        );

        final bytes = LaporanExcelGenerator.generate(
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
        final fileName = LaporanPdfGenerator.generateFileName(
          startDate: widget.startDate,
          endDate: widget.endDate,
        );

        final bytes = await LaporanPdfGenerator.generate(
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
                  ? 'Laporan berhasil diunduh ke browser.'
                  : 'Laporan berhasil diekspor.',
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

    final isDemo = ref.watch(transaksiRepositoryProvider).isDemoMode;

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
                      Icons.file_download_outlined,
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
                          'Export Laporan Pembelian TBS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Laporan detail per jenis buah per transaksi (FR-7.2)',
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

              // Indikator Mode Demo (jika tidak terhubung ke Supabase)
              if (isDemo) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1C5),
                    border: Border.all(color: const Color(0xFFF1C21B)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Color(0xFF8D6B00)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mode Demo: Menampilkan data simulasi lokal (tidak terhubung ke Supabase).',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8D6B00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Banner Pesan Error Query Database
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    border: Border.all(color: AppColors.error),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gagal Memuat Data dari Database',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18, color: AppColors.error),
                        tooltip: 'Coba Lagi',
                        onPressed: _loadData,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Info Banner Rentang Filter & Status
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
                            '${_items.length} Baris (${_getUniqueTransactionsCount()} Trx)',
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
                    if (widget.jenisPembayaran != 'semua') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Metode Pembayaran: ${widget.jenisPembayaran == 'non_tunai' ? 'Non Tunai (Transfer)' : 'Tunai (Cash)'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
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
                        color: Color(0xFF107C41), // Excel Green
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
                              'Tabel per jenis buah, potongan kg, berat bersih & subtotal',
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
                        color: Color(0xFFD9381E), // PDF Red
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
                              'Layout landscape 11 kolom, baris zebra & total keseluruhan',
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
                    onPressed: (isEmpty || _isExporting || _isLoading || _errorMessage != null)
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
