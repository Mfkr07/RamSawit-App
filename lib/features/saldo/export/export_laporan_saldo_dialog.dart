import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/file_saver/file_saver.dart';
import '../../../models/saldo_ringkasan.dart';
import '../../../models/topup_saldo.dart';
import '../saldo_repository.dart';
import 'laporan_saldo_excel_generator.dart';
import 'laporan_saldo_pdf_generator.dart';

/// Modal dialog export Laporan Saldo / Dana Modal (FR-10.9)
/// Khusus role Administrator.
class ExportLaporanSaldoDialog extends ConsumerStatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportLaporanSaldoDialog({
    super.key,
    this.startDate,
    this.endDate,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ExportLaporanSaldoDialog(
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  ConsumerState<ExportLaporanSaldoDialog> createState() =>
      _ExportLaporanSaldoDialogState();
}

class _ExportLaporanSaldoDialogState
    extends ConsumerState<ExportLaporanSaldoDialog> {
  String _selectedFormat = 'excel'; // 'excel' | 'pdf'
  bool _isExporting = false;
  bool _isLoading = true;
  SaldoRingkasan _ringkasan = SaldoRingkasan.zero();
  List<TopupSaldo> _topupItems = [];
  List<PembelianPengurangSaldo> _pembelianItems = [];
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
      final repo = ref.read(saldoRepositoryProvider);
      final ringkasan = await repo.getSaldoRingkasan();
      final topups = await repo.fetchAllTopupForPeriod(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
      final pembelians = await repo.fetchTransaksiPembelianRingkasForPeriod(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      if (mounted) {
        setState(() {
          _ringkasan = ringkasan;
          _topupItems = topups;
          _pembelianItems = pembelians;
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
    setState(() => _isExporting = true);

    try {
      Uint8List bytes;
      String fileName;
      String mimeType;

      if (_selectedFormat == 'excel') {
        bytes = LaporanSaldoExcelGenerator.generate(
          ringkasan: _ringkasan,
          topupItems: _topupItems,
          pembelianItems: _pembelianItems,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
        fileName = LaporanSaldoExcelGenerator.generateFileName(
          startDate: widget.startDate,
          endDate: widget.endDate,
          extension: 'xlsx',
        );
        mimeType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else {
        bytes = await LaporanSaldoPdfGenerator.generate(
          ringkasan: _ringkasan,
          topupItems: _topupItems,
          pembelianItems: _pembelianItems,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
        fileName = LaporanSaldoPdfGenerator.generateFileName(
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan berhasil diekspor ($fileName)'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
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
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    String periodeText;
    if (widget.startDate != null && widget.endDate != null) {
      periodeText =
          '${dateFormat.format(widget.startDate!)} – ${dateFormat.format(widget.endDate!)}';
    } else if (widget.startDate != null) {
      periodeText = 'Sejak ${dateFormat.format(widget.startDate!)}';
    } else if (widget.endDate != null) {
      periodeText = 'Hingga ${dateFormat.format(widget.endDate!)}';
    } else {
      periodeText = 'Semua Periode Data';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Export Laporan Saldo Modal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter periode aktif info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.date_range,
                            size: 16, color: AppColors.inkMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Periode: $periodeText',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
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
                        style: const TextStyle(fontSize: 11, color: AppColors.error),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_topupItems.length} Top Up | ${_pembelianItems.length} Pembelian',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          Text(
                            'Sisa: ${CurrencyFormatter.format(_ringkasan.sisaSaldo)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _ringkasan.isLowOrExhausted
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Pilihan Format
              const Text(
                'Pilih Format Dokumen:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _FormatOptionCard(
                      icon: Icons.table_chart_outlined,
                      title: 'Excel (.xlsx)',
                      subtitle: 'Ringkasan & rincian tabel',
                      isSelected: _selectedFormat == 'excel',
                      onTap: () => setState(() => _selectedFormat = 'excel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormatOptionCard(
                      icon: Icons.picture_as_pdf_outlined,
                      title: 'PDF (.pdf)',
                      subtitle: 'Dokumen cetak resmi',
                      isSelected: _selectedFormat == 'pdf',
                      onTap: () => setState(() => _selectedFormat = 'pdf'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isExporting ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
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
                    label: Text(_isExporting ? 'Mengekspor...' : 'Unduh Laporan'),
                    onPressed: (_isExporting || _isLoading) ? null : _handleExport,
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

class _FormatOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface1 : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.hairline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.inkMuted,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.ink,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
