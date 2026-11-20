import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../models/pengiriman_pabrik.dart';
import '../../../models/transaksi.dart';
import '../../transaksi/transaksi_detail_page.dart';

/// Widget Daftar 10 Transaksi Terakhir (FR-5.9)
/// Mendukung tab switcher antara:
/// 1. 10 Transaksi Pembelian Terakhir (Petani)
/// 2. 10 Pengiriman Penjualan Terakhir (Pabrik)
class ListTransaksiTerakhirSection extends StatefulWidget {
  final List<TransaksiRingkasan> items;
  final List<PengirimanPabrik> pengirimanItems;
  final bool isLoading;
  final VoidCallback? onLihatSemuaPressed;
  final VoidCallback? onLihatSemuaPengirimanPressed;

  const ListTransaksiTerakhirSection({
    super.key,
    required this.items,
    this.pengirimanItems = const [],
    this.isLoading = false,
    this.onLihatSemuaPressed,
    this.onLihatSemuaPengirimanPressed,
  });

  @override
  State<ListTransaksiTerakhirSection> createState() =>
      _ListTransaksiTerakhirSectionState();
}

class _ListTransaksiTerakhirSectionState
    extends State<ListTransaksiTerakhirSection> {
  int _tabIndex = 0; // 0: Pembelian Petani, 1: Penjualan Pabrik

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bagian & Tab Switcher
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 14.0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 850;

                final tabButtons = Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildTabChip(
                      label: 'Pembelian (${widget.items.length})',
                      isSelected: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    _buildTabChip(
                      label: 'Penjualan Pabrik (${widget.pengirimanItems.length})',
                      isSelected: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ],
                );

                final actionButton = _tabIndex == 0
                    ? (widget.onLihatSemuaPressed != null
                        ? TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.arrow_forward, size: 14),
                            label: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: widget.onLihatSemuaPressed,
                          )
                        : const SizedBox.shrink())
                    : (widget.onLihatSemuaPengirimanPressed != null
                        ? TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF198038),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.arrow_forward, size: 14),
                            label: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: widget.onLihatSemuaPengirimanPressed,
                          )
                        : const SizedBox.shrink());

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '10 TRANSAKSI & PENGIRIMAN TERAKHIR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          tabButtons,
                          actionButton,
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '10 TRANSAKSI & PENGIRIMAN TERAKHIR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _tabIndex == 0
                                ? 'Ketuk baris transaksi pembelian untuk melihat nota lengkap'
                                : 'Daftar pengiriman TBS ke pabrik pengolahan kelapa sawit',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.inkSubtle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        tabButtons,
                        const SizedBox(width: 8),
                        actionButton,
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(color: AppColors.hairline, height: 1),

          // Konten List
          if (_tabIndex == 0)
            _buildPembelianList()
          else
            _buildPengirimanList(),
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.ink : AppColors.surface1,
      borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.ink : AppColors.hairline,
              width: 1.0,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(2.0)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.onPrimary : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPembelianList() {
    if (widget.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'Belum ada transaksi pembelian yang tercatat.',
            style: TextStyle(fontSize: 13, color: AppColors.inkSubtle),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.hairline, height: 1),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isDibatalkan = item.isDibatalkan;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TransaksiDetailPage(transaksiId: item.id),
              ),
            );
          },
          hoverColor: AppColors.surface1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: LayoutBuilder(
              builder: (context, rowConstraints) {
                final isCompact = rowConstraints.maxWidth < 450;

                final avatar = Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDibatalkan
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                  ),
                  child: Icon(
                    isDibatalkan
                        ? Icons.cancel_outlined
                        : Icons.receipt_long_outlined,
                    size: 18,
                    color: isDibatalkan ? AppColors.error : AppColors.primary,
                  ),
                );

                final valueCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.format(item.totalNilai),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDibatalkan ? AppColors.inkMuted : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      WeightFormatter.format(item.totalBeratBersihKg),
                      style: const TextStyle(fontSize: 11, color: AppColors.inkSubtle),
                    ),
                  ],
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          avatar,
                          const SizedBox(width: 10),
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  item.kodeTransaksi,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: isDibatalkan ? AppColors.inkMuted : AppColors.ink,
                                    decoration: isDibatalkan
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                _buildStatusBadge(item.status),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.inkSubtle),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.namaPenjual} • ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(item.createdAt.toLocal())}',
                              style: const TextStyle(fontSize: 11, color: AppColors.inkSubtle),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          valueCol,
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    avatar,
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                item.kodeTransaksi,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: isDibatalkan ? AppColors.inkMuted : AppColors.ink,
                                  decoration: isDibatalkan
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              _buildStatusBadge(item.status),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${item.namaPenjual} • ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(item.createdAt.toLocal())}',
                            style: const TextStyle(fontSize: 11, color: AppColors.inkSubtle),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    valueCol,
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 18, color: AppColors.inkSubtle),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPengirimanList() {
    if (widget.pengirimanItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'Belum ada riwayat pengiriman ke pabrik.',
            style: TextStyle(fontSize: 13, color: AppColors.inkSubtle),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.pengirimanItems.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.hairline, height: 1),
      itemBuilder: (context, index) {
        final item = widget.pengirimanItems[index];
        final isDibatalkan = item.isDibatalkan;
        final pabrikNama = item.pabrik?.nama ?? 'Pabrik';

        return InkWell(
          onTap: () {
            if (widget.onLihatSemuaPengirimanPressed != null) {
              widget.onLihatSemuaPengirimanPressed!();
            }
          },
          hoverColor: AppColors.surface1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: LayoutBuilder(
              builder: (context, rowConstraints) {
                final isCompact = rowConstraints.maxWidth < 450;

                final avatar = Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDibatalkan
                        ? AppColors.error.withValues(alpha: 0.1)
                        : const Color(0xFF198038).withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                  ),
                  child: Icon(
                    isDibatalkan
                        ? Icons.cancel_outlined
                        : Icons.local_shipping_outlined,
                    size: 18,
                    color: isDibatalkan
                        ? AppColors.error
                        : const Color(0xFF198038),
                  ),
                );

                final valueCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.isBerangkat) ...[
                      Text(
                        'Menunggu Truk',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kotor: ${WeightFormatter.format(item.beratKotorKg)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.inkSubtle),
                      ),
                    ] else ...[
                      Text(
                        CurrencyFormatter.format(item.totalNilaiJual),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDibatalkan
                              ? AppColors.inkMuted
                              : const Color(0xFF198038),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Netto: ${WeightFormatter.format(item.beratBersihKg)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.inkSubtle),
                      ),
                    ],
                  ],
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          avatar,
                          const SizedBox(width: 10),
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  item.kodePengiriman,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: isDibatalkan ? AppColors.inkMuted : AppColors.ink,
                                    decoration: isDibatalkan
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                _buildStatusBadge(item.status),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.inkSubtle),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              '$pabrikNama • ${item.platNomor} (${item.namaSopir}) • ${DateFormat('dd MMM yyyy', 'id_ID').format(item.tanggalKirim)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.inkSubtle),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          valueCol,
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    avatar,
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                item.kodePengiriman,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: isDibatalkan ? AppColors.inkMuted : AppColors.ink,
                                  decoration: isDibatalkan
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              _buildStatusBadge(item.status),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$pabrikNama • ${item.platNomor} (${item.namaSopir}) • ${DateFormat('dd MMM yyyy', 'id_ID').format(item.tanggalKirim)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.inkSubtle),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    valueCol,
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 18, color: AppColors.inkSubtle),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'berangkat':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        label = 'Berangkat';
        break;
      case 'selesai':
        bg = AppColors.success.withValues(alpha: 0.1);
        fg = AppColors.success;
        label = 'Selesai';
        break;
      case 'dibatalkan':
        bg = AppColors.error.withValues(alpha: 0.1);
        fg = AppColors.error;
        label = 'Dibatalkan';
        break;
      default:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = const Color(0xFF8A6D00);
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
