import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/percentage_formatter.dart';
import '../../core/utils/weight_formatter.dart';
import '../../models/transaksi.dart';
import 'transaksi_list_controller.dart';
import 'transaksi_repository.dart';

/// Provider detail transaksi lengkap
final transaksiDetailProvider =
    FutureProvider.family<Transaksi, String>((ref, id) async {
  final repo = ref.watch(transaksiRepositoryProvider);
  return repo.getTransaksiDetail(id);
});

/// Halaman Detail Nota Transaksi & Aksi Pembatalan (FR-4.2 & FR-4.3)
class TransaksiDetailPage extends ConsumerStatefulWidget {
  final String transaksiId;

  const TransaksiDetailPage({
    super.key,
    required this.transaksiId,
  });

  @override
  ConsumerState<TransaksiDetailPage> createState() =>
      _TransaksiDetailPageState();
}

class _TransaksiDetailPageState extends ConsumerState<TransaksiDetailPage> {
  final _alasanController = TextEditingController();
  bool _isCancelling = false;

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime date) {
    try {
      return DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    }
  }

  Future<void> _handleCancelTransaction(Transaksi transaksi) async {
    _alasanController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.canvas,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2.0)),
              ),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.error, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Batalkan Transaksi?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaksi ${transaksi.kodeTransaksi} akan ditandai sebagai "dibatalkan". Data tidak akan dihapus fisik untuk kebutuhan audit trail.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Alasan Pembatalan *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    key: const Key('alasan_pembatalan_input'),
                    controller: _alasanController,
                    autofocus: true,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Salah input timbangan bruto kebun',
                      errorText: errorText,
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
                  key: const Key('konfirmasi_batalkan_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: () {
                    if (_alasanController.text.trim().isEmpty) {
                      setModalState(() {
                        errorText = 'Alasan pembatalan wajib diisi';
                      });
                      return;
                    }
                    Navigator.of(ctx).pop(true);
                  },
                  child: const Text('Konfirmasi Batalkan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isCancelling = true);

      try {
        await ref.read(transaksiListProvider.notifier).cancelTransaksi(
              transaksi.id,
              _alasanController.text.trim(),
            );

        // Invalidate detail agar UI re-fetch status baru
        ref.invalidate(transaksiDetailProvider(widget.transaksiId));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Transaksi ${transaksi.kodeTransaksi} berhasil dibatalkan.',
              ),
              backgroundColor: AppColors.ink,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membatalkan transaksi: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isCancelling = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(transaksiDetailProvider(widget.transaksiId));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Nota Transaksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: detailAsync.when(
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
                'Terjadi kesalahan memuat detail: $err',
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.refresh(
                  transaksiDetailProvider(widget.transaksiId),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (trx) {
          final isDibatalkan = trx.isDibatalkan;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner Pembatalan (Jika dibatalkan)
                    if (isDibatalkan) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          border: Border.all(color: AppColors.error, width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.cancel_outlined,
                              color: AppColors.error,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TRANSAKSI DIBATALKAN (VOID)',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    trx.catatan != null &&
                                            trx.catatan!.isNotEmpty
                                        ? trx.catatan!
                                        : 'Transaksi ini telah dibatalkan oleh petugas dan tidak dihitung pada omset dashboard.',
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Card Nota Utama
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface1,
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Nota: Kode Transaksi & Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'KODE TRANSAKSI',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkSubtle,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    trx.kodeTransaksi,
                                    key: const Key('detail_kode_transaksi_text'),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDateTime(trx.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),

                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  // Badge Jenis Pembayaran (PRD §7.4 FR-4.2)
                                  Container(
                                    key: const Key('detail_jenis_pembayaran_badge'),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: trx.isTunai
                                          ? AppColors.inkSubtle.withValues(alpha: 0.1)
                                          : AppColors.primary.withValues(alpha: 0.12),
                                      border: Border.all(
                                        color: trx.isTunai
                                            ? AppColors.inkSubtle
                                            : AppColors.primary,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      trx.isTunai ? 'TUNAI (KAS)' : 'NON TUNAI',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: trx.isTunai
                                            ? AppColors.inkMuted
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),

                                  // Badge Status
                                  Container(
                                    key: const Key('detail_status_badge'),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDibatalkan
                                          ? AppColors.error.withValues(alpha: 0.1)
                                          : AppColors.success
                                              .withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: isDibatalkan
                                            ? AppColors.error
                                            : AppColors.success,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      trx.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
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
                          const Divider(height: 32, color: AppColors.hairline),

                          // Identitas Penjual
                          const Text(
                            'INFORMASI PENJUAL / PETANI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkSubtle,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trx.penjual?.nama ?? 'Penjual',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          if (trx.penjual?.noTelepon != null &&
                              trx.penjual!.noTelepon!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Telepon: ${trx.penjual!.noTelepon!}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                          if (trx.penjual?.alamat != null &&
                              trx.penjual!.alamat!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Alamat: ${trx.penjual!.alamat!}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                          const Divider(height: 32, color: AppColors.hairline),

                          // Tabel Rincian Item Buah
                          const Text(
                            'RINCIAN JENIS BUAH (TBS)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkSubtle,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),

                          LayoutBuilder(
                            builder: (context, itemConstraints) {
                              final isCompact = itemConstraints.maxWidth < 640;

                              if (isCompact) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.canvas,
                                    border: Border.all(color: AppColors.hairline),
                                  ),
                                  child: Column(
                                    children: [
                                      if (trx.items != null && trx.items!.isNotEmpty)
                                        ...trx.items!.map((item) {
                                          return Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: AppColors.hairline,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item.jenisBuah?.nama ??
                                                            'TBS #${item.jenisBuahId}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      CurrencyFormatter.format(item.subtotal),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Wrap(
                                                  alignment: WrapAlignment.spaceBetween,
                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                  spacing: 8,
                                                  runSpacing: 4,
                                                  children: [
                                                    Text(
                                                      'Kotor: ${WeightFormatter.format(item.beratKotorKg)} • Pot: ${PercentageFormatter.format(item.persentasePotongan)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.inkMuted,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Bersih: ${WeightFormatter.format(item.beratBersihKg)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.ink,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Wrap(
                                                  alignment: WrapAlignment.spaceBetween,
                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                  spacing: 8,
                                                  runSpacing: 4,
                                                  children: [
                                                    Text(
                                                      'Harga: ${CurrencyFormatter.format(item.hargaPerKg)}/kg',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.inkMuted,
                                                      ),
                                                    ),
                                                    if (item.nilaiPotonganRp > Decimal.zero)
                                                      Text(
                                                        'Pot. Rp: -${CurrencyFormatter.format(item.nilaiPotonganRp)}',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color: AppColors.error,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                      else
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'Tidak ada detail item tersedia.',
                                            style: TextStyle(
                                              color: AppColors.inkMuted,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.canvas,
                                  border: Border.all(color: AppColors.hairline),
                                ),
                                child: Column(
                                  children: [
                                    // Table Header
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      color: AppColors.surface2,
                                      child: const Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Jenis Buah',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Berat Kotor',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Potongan',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Berat Bersih',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Harga / kg',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Subtotal',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Table Rows
                                    if (trx.items != null && trx.items!.isNotEmpty)
                                      ...trx.items!.map((item) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: AppColors.hairline,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  item.jenisBuah?.nama ??
                                                      'TBS #${item.jenisBuahId}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  WeightFormatter.format(item.beratKotorKg),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  PercentageFormatter.format(item.persentasePotongan),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: item.persentasePotongan > Decimal.zero
                                                        ? AppColors.error
                                                        : AppColors.inkMuted,
                                                    fontWeight: item.persentasePotongan > Decimal.zero
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  WeightFormatter.format(item.beratBersihKg),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  CurrencyFormatter.format(item.hargaPerKg),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  CurrencyFormatter.format(item.subtotal),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                    else
                                      const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          'Tidak ada detail item tersedia.',
                                          style: TextStyle(
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Box Ringkasan Total & Potongan Transaksi
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'TOTAL BERAT KOTOR',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          WeightFormatter.format(trx.totalBeratKotorKg),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'TOTAL BERAT BERSIH',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          WeightFormatter.format(trx.totalBeratBersihKg),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(color: AppColors.hairline, height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'NILAI POTONGAN BERAT',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.error,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          trx.totalPotonganRp > Decimal.zero
                                              ? '- ${CurrencyFormatter.format(trx.totalPotonganRp)}'
                                              : 'Rp 0',
                                          key: const Key('detail_nilai_potongan_text'),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'TOTAL NILAI TRANSAKSI',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyFormatter.format(trx.totalNilai),
                                          key: const Key('detail_total_bersih_text'),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: trx.isTunai
                                        ? AppColors.inkSubtle.withValues(alpha: 0.06)
                                        : AppColors.primary.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: trx.isTunai
                                          ? AppColors.hairline
                                          : AppColors.primary.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        trx.isTunai ? Icons.payments_outlined : Icons.account_balance_outlined,
                                        size: 16,
                                        color: trx.isTunai ? AppColors.inkMuted : AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          trx.isTunai
                                              ? 'Pembayaran Tunai: Mengurangi kas saldo modal operasional.'
                                              : 'Pembayaran Non Tunai: Transaksi informasional, tidak mengurangi saldo modal.',
                                          key: const Key('detail_pembayaran_info_note'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: trx.isTunai ? AppColors.inkMuted : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Aksi Pembatalan (Hanya jika status 'selesai' atau 'draft')
                    if (!isDibatalkan) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          key: const Key('batalkan_transaksi_button'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(
                              color: AppColors.error,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          onPressed: _isCancelling
                              ? null
                              : () => _handleCancelTransaction(trx),
                          icon: _isCancelling
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.error,
                                  ),
                                )
                              : const Icon(Icons.cancel_outlined, size: 18),
                          label: Text(
                            _isCancelling
                                ? 'Membatalkan Transaksi...'
                                : 'Batalkan Transaksi',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
