// ignore_for_file: deprecated_member_use

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../models/dashboard_analytics.dart';
import '../../auth/auth_controller.dart';
import '../dashboard_controller.dart';

/// Widget Kartu Ringkasan Multi-Modul (FR-5.1, FR-5.2, FR-5.3):
/// Menyajikan ringkasan untuk 3 modul utama:
/// 1. Pembelian dari Petani (Berat Kotor, Berat Bersih, Total Nilai Rp, Frekuensi TRX)
/// 2. Penjualan ke Pabrik (Berat Kotor, Berat Bersih, Total Nilai Jual Rp, Frekuensi KRM)
/// 3. Margin Keuntungan (Penjualan - Pembelian, Status Surplus/Defisit)
/// untuk periode Hari Ini, Minggu Ini, dan Bulan Ini.
/// - FR-5.11: Tab Margin Keuntungan disembunyikan sepenuhnya untuk role Kasir.
/// - FR-5.12: Filter khusus pada kartu "Bulan Ini" hanya untuk role Admin.
class KartuRingkasanSection extends ConsumerStatefulWidget {
  final MultiModulSummary? multiSummary;
  final DashboardSummary? summary; // Kompatibilitas
  final bool isLoading;

  const KartuRingkasanSection({
    super.key,
    this.multiSummary,
    this.summary,
    this.isLoading = false,
  });

  @override
  ConsumerState<KartuRingkasanSection> createState() =>
      _KartuRingkasanSectionState();
}

class _KartuRingkasanSectionState extends ConsumerState<KartuRingkasanSection> {
  int _activeModuleIndex = 0; // 0: Pembelian, 1: Penjualan Pabrik, 2: Margin

  @override
  Widget build(BuildContext context) {
    final isKasir =
        ref.watch(authControllerProvider).profile?.role == 'kasir';
    final isAdmin = !isKasir;

    // Jika bukan admin dan tab aktif sebelumnya adalah Margin, kembalikan ke Pembelian (FR-5.11)
    if (!isAdmin && _activeModuleIndex == 2) {
      _activeModuleIndex = 0;
    }

    final kartuBulanIniFilter = ref.watch(kartuBulanIniFilterProvider);
    final isCustomCard3 = !kartuBulanIniFilter.isDefault;
    final customSummary = isCustomCard3
        ? ref.watch(kartuBulanIniSummaryProvider).value
        : null;

    final multi = widget.multiSummary ??
        (widget.summary != null
            ? MultiModulSummary(
                pembelian: widget.summary!,
                penjualan: DashboardSummary.empty(),
                marginHariIni: RingkasanMarginPeriodik.empty('Hari Ini'),
                marginMingguIni: RingkasanMarginPeriodik.empty('Minggu Ini'),
                marginBulanIni: RingkasanMarginPeriodik.empty('Bulan Ini'),
              )
            : MultiModulSummary.empty());

    final card3Title = kartuBulanIniFilter.label;

    // Nilai Pembelian Card 3
    final beliCard3Nilai = customSummary?.pembelian.totalNilai ??
        multi.pembelian.bulanIni.totalNilai;
    final beliCard3Kotor = customSummary?.pembelian.totalBeratKotorKg ??
        multi.pembelian.bulanIni.totalBeratKotorKg;
    final beliCard3Bersih = customSummary?.pembelian.totalBeratBersihKg ??
        multi.pembelian.bulanIni.totalBeratBersihKg;
    final beliCard3Count = customSummary?.pembelian.jumlahTransaksi ??
        multi.pembelian.bulanIni.jumlahTransaksi;

    // Nilai Penjualan Card 3
    final jualCard3Nilai = customSummary?.penjualan.totalNilai ??
        multi.penjualan.bulanIni.totalNilai;
    final jualCard3Kotor = customSummary?.penjualan.totalBeratKotorKg ??
        multi.penjualan.bulanIni.totalBeratKotorKg;
    final jualCard3Bersih = customSummary?.penjualan.totalBeratBersihKg ??
        multi.penjualan.bulanIni.totalBeratBersihKg;
    final jualCard3Count = customSummary?.penjualan.jumlahTransaksi ??
        multi.penjualan.bulanIni.jumlahTransaksi;

    // Nilai Margin Card 3
    final marginCard3 =
        customSummary?.margin ?? multi.marginBulanIni;

    final card3Action = isAdmin ? _buildCard3ActionButton(isCustomCard3) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tab Pemilih Modul KPI (IBM Carbon Segmented Bar)
        _buildModuleSelector(isAdmin: isAdmin),
        const SizedBox(height: 12),

        // 3 Kartu Periodik (Hari Ini, Minggu Ini, Bulan Ini)
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 750;

            if (_activeModuleIndex == 0) {
              return _buildPeriodCards(
                isCompact: isCompact,
                hariIni: _buildMetricCard(
                  title: 'HARI INI',
                  nilaiRp: multi.pembelian.hariIni.totalNilai,
                  kotorKg: multi.pembelian.hariIni.totalBeratKotorKg,
                  bersihKg: multi.pembelian.hariIni.totalBeratBersihKg,
                  count: multi.pembelian.hariIni.jumlahTransaksi,
                  countSuffix: 'TRX',
                  accentColor: AppColors.primary,
                  icon: Icons.today_outlined,
                  metricLabel: 'Pembelian TBS Petani',
                ),
                mingguIni: _buildMetricCard(
                  title: 'MINGGU INI',
                  nilaiRp: multi.pembelian.mingguIni.totalNilai,
                  kotorKg: multi.pembelian.mingguIni.totalBeratKotorKg,
                  bersihKg: multi.pembelian.mingguIni.totalBeratBersihKg,
                  count: multi.pembelian.mingguIni.jumlahTransaksi,
                  countSuffix: 'TRX',
                  accentColor: const Color(0xFF0072C3),
                  icon: Icons.date_range_outlined,
                  metricLabel: 'Pembelian TBS Petani',
                ),
                bulanIni: _buildMetricCard(
                  title: card3Title,
                  nilaiRp: beliCard3Nilai,
                  kotorKg: beliCard3Kotor,
                  bersihKg: beliCard3Bersih,
                  count: beliCard3Count,
                  countSuffix: 'TRX',
                  accentColor: const Color(0xFF6929C4),
                  icon: Icons.calendar_month_outlined,
                  metricLabel: 'Pembelian TBS Petani',
                  action: card3Action,
                ),
              );
            } else if (_activeModuleIndex == 1) {
              return _buildPeriodCards(
                isCompact: isCompact,
                hariIni: _buildMetricCard(
                  title: 'HARI INI',
                  nilaiRp: multi.penjualan.hariIni.totalNilai,
                  kotorKg: multi.penjualan.hariIni.totalBeratKotorKg,
                  bersihKg: multi.penjualan.hariIni.totalBeratBersihKg,
                  count: multi.penjualan.hariIni.jumlahTransaksi,
                  countSuffix: 'KRM',
                  accentColor: const Color(0xFF198038), // IBM Green
                  icon: Icons.local_shipping_outlined,
                  metricLabel: 'Penjualan ke Pabrik',
                  kotorLabel: 'Berat Dikirim',
                ),
                mingguIni: _buildMetricCard(
                  title: 'MINGGU INI',
                  nilaiRp: multi.penjualan.mingguIni.totalNilai,
                  kotorKg: multi.penjualan.mingguIni.totalBeratKotorKg,
                  bersihKg: multi.penjualan.mingguIni.totalBeratBersihKg,
                  count: multi.penjualan.mingguIni.jumlahTransaksi,
                  countSuffix: 'KRM',
                  accentColor: const Color(0xFF005D5D), // IBM Teal
                  icon: Icons.date_range_outlined,
                  metricLabel: 'Penjualan ke Pabrik',
                  kotorLabel: 'Berat Dikirim',
                ),
                bulanIni: _buildMetricCard(
                  title: card3Title,
                  nilaiRp: jualCard3Nilai,
                  kotorKg: jualCard3Kotor,
                  bersihKg: jualCard3Bersih,
                  count: jualCard3Count,
                  countSuffix: 'KRM',
                  accentColor: const Color(0xFF1192E8), // IBM Cyan
                  icon: Icons.calendar_month_outlined,
                  metricLabel: 'Penjualan ke Pabrik',
                  kotorLabel: 'Berat Dikirim',
                  action: card3Action,
                ),
              );
            } else {
              // Modul Margin (Hanya tampil untuk role Admin FR-5.11)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPeriodCards(
                    isCompact: isCompact,
                    hariIni: _buildMarginCard(
                      title: 'MARGIN HARI INI',
                      margin: multi.marginHariIni,
                      icon: Icons.today_outlined,
                    ),
                    mingguIni: _buildMarginCard(
                      title: 'MARGIN MINGGU INI',
                      margin: multi.marginMingguIni,
                      icon: Icons.date_range_outlined,
                    ),
                    bulanIni: _buildMarginCard(
                      title: card3Title,
                      margin: marginCard3,
                      icon: Icons.calendar_month_outlined,
                      action: card3Action,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPeriodCards(
                    isCompact: isCompact,
                    hariIni: _buildLabaBersihCard(
                      title: 'LABA BERSIH HARI INI',
                      margin: multi.marginHariIni,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    mingguIni: _buildLabaBersihCard(
                      title: 'LABA BERSIH MINGGU INI',
                      margin: multi.marginMingguIni,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    bulanIni: _buildLabaBersihCard(
                      title: 'LABA BERSIH $card3Title',
                      margin: marginCard3,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildCard3ActionButton(bool isCustom) {
    return InkWell(
      key: const Key('btn_filter_kartu_bulan_ini'),
      onTap: () => _showFilterBulanIniDialog(context),
      borderRadius: BorderRadius.circular(2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isCustom ? AppColors.primary : AppColors.surface1,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isCustom ? AppColors.primary : AppColors.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCustom ? Icons.filter_alt : Icons.tune,
              size: 12,
              color: isCustom ? Colors.white : AppColors.ink,
            ),
            const SizedBox(width: 4),
            Text(
              isCustom ? 'Reset' : 'Filter',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isCustom ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBulanIniDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => _DialogFilterBulanIni(
        initialFilter: ref.read(kartuBulanIniFilterProvider),
        onApply: (newFilter) {
          ref.read(kartuBulanIniFilterProvider.notifier).setFilter(newFilter);
        },
      ),
    );
  }

  Widget _buildModuleSelector({required bool isAdmin}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          final buttons = [
            _ModuleTabButton(
              index: 0,
              label: 'Pembelian dari Petani',
              icon: Icons.shopping_basket_outlined,
              isSelected: _activeModuleIndex == 0,
              accentColor: AppColors.primary,
              onTap: () => setState(() => _activeModuleIndex = 0),
            ),
            _ModuleTabButton(
              index: 1,
              label: 'Penjualan ke Pabrik',
              icon: Icons.factory_outlined,
              isSelected: _activeModuleIndex == 1,
              accentColor: const Color(0xFF198038),
              onTap: () => setState(() => _activeModuleIndex = 1),
            ),
            if (isAdmin)
              _ModuleTabButton(
                index: 2,
                label: 'Margin Keuntungan',
                icon: Icons.trending_up,
                isSelected: _activeModuleIndex == 2,
                accentColor: const Color(0xFF6929C4),
                onTap: () => setState(() => _activeModuleIndex = 2),
              ),
          ];

          if (isNarrow) {
            return Column(
              children: buttons
                  .map((b) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: b,
                      ))
                  .toList(),
            );
          }

          return Row(
            children: buttons
                .map((b) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: b,
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildPeriodCards({
    required bool isCompact,
    required Widget hariIni,
    required Widget mingguIni,
    required Widget bulanIni,
  }) {
    if (isCompact) {
      return Column(
        children: [
          hariIni,
          const SizedBox(height: 12),
          mingguIni,
          const SizedBox(height: 12),
          bulanIni,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: hariIni),
        const SizedBox(width: 14),
        Expanded(child: mingguIni),
        const SizedBox(width: 14),
        Expanded(child: bulanIni),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required Decimal nilaiRp,
    required Decimal kotorKg,
    required Decimal bersihKg,
    required int count,
    required String countSuffix,
    required Color accentColor,
    required IconData icon,
    required String metricLabel,
    String? kotorLabel,
    Widget? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: accentColor),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.inkMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(width: 4),
                      action,
                      const SizedBox(width: 6),
                    ],
                    Icon(icon, size: 16, color: accentColor),
                  ],
                ),
                const SizedBox(height: 10),

                // Nilai Rupiah (JANGAN diubah format atau perhitungannya)
                Text(
                  CurrencyFormatter.format(nilaiRp),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.hairline, height: 1),
                const SizedBox(height: 10),

                // Berat Kotor (kg) & Berat Bersih (kg)
                LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final isNarrow = cardConstraints.maxWidth < 220;

                    final kotorCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kotorLabel ?? 'Berat Kotor',
                          style: const TextStyle(fontSize: 10.5, color: AppColors.inkSubtle),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          WeightFormatter.format(kotorKg),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );

                    final bersihCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Berat Bersih',
                          style: TextStyle(fontSize: 10.5, color: AppColors.inkSubtle),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          WeightFormatter.format(bersihKg),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          kotorCol,
                          const SizedBox(height: 6),
                          bersihCol,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: kotorCol),
                        const SizedBox(width: 8),
                        Expanded(child: bersihCol),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Footer Jumlah Transaksi / Pengiriman
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        metricLabel,
                        style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$count $countSuffix',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginCard({
    required String title,
    required RingkasanMarginPeriodik margin,
    required IconData icon,
    Widget? action,
  }) {
    final isSurplus = margin.isSurplus;
    final accentColor = isSurplus ? const Color(0xFF198038) : AppColors.error;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: accentColor),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.inkMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(width: 4),
                      action,
                      const SizedBox(width: 6),
                    ],
                    Icon(icon, size: 16, color: accentColor),
                  ],
                ),
                const SizedBox(height: 10),

                // Nilai Margin Bersih
                Text(
                  CurrencyFormatter.format(margin.margin),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.hairline, height: 1),
                const SizedBox(height: 10),

                // Rincian Penjualan vs Pembelian
                LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final isNarrow = cardConstraints.maxWidth < 220;

                    final jualCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Penjualan (Pabrik)',
                          style: TextStyle(fontSize: 10.5, color: AppColors.inkSubtle),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(margin.totalPenjualan),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );

                    final beliCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pembelian (Petani)',
                          style: TextStyle(fontSize: 10.5, color: AppColors.inkSubtle),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(margin.totalPembelian),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          jualCol,
                          const SizedBox(height: 6),
                          beliCol,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: jualCol),
                        const SizedBox(width: 8),
                        Expanded(child: beliCol),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Badge Surplus/Defisit
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                    ),
                    child: Text(
                      isSurplus ? 'SURPLUS' : 'DEFISIT',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabaBersihCard({
    required String title,
    required RingkasanMarginPeriodik margin,
    required IconData icon,
    Widget? action,
  }) {
    final isSurplus = margin.isLabaBersihSurplus;
    final accentColor = isSurplus ? const Color(0xFF0F62FE) : AppColors.error;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: accentColor),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.inkMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(width: 4),
                      action,
                      const SizedBox(width: 6),
                    ],
                    Icon(icon, size: 16, color: accentColor),
                  ],
                ),
                const SizedBox(height: 10),

                // Nilai Laba Bersih
                Text(
                  CurrencyFormatter.format(margin.labaBersih),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.hairline, height: 1),
                const SizedBox(height: 10),

                // Rincian Margin vs Total Pengeluaran
                LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final isNarrow = cardConstraints.maxWidth < 220;

                    final marginCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Margin Kotor',
                          style: TextStyle(fontSize: 10.5, color: AppColors.inkSubtle),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(margin.margin),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );

                    final pengeluaranCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengeluaran Kas',
                          style: TextStyle(fontSize: 10.5, color: AppColors.inkSubtle),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(margin.totalPengeluaran),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          marginCol,
                          const SizedBox(height: 6),
                          pengeluaranCol,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: marginCol),
                        const SizedBox(width: 8),
                        Expanded(child: pengeluaranCol),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Badge Surplus / Defisit Bersih
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                    ),
                    child: Text(
                      isSurplus ? 'LABA BERSIH (+)' : 'DEFISIT BERSIH (-)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleTabButton extends StatelessWidget {
  final int index;
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ModuleTabButton({
    required this.index,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? accentColor : Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.onPrimary : AppColors.inkMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.onPrimary : AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog Filter Khusus Kartu "Bulan Ini" (FR-5.12 - Hanya Admin)
class _DialogFilterBulanIni extends StatefulWidget {
  final KartuBulanIniFilterState initialFilter;
  final ValueChanged<KartuBulanIniFilterState> onApply;

  const _DialogFilterBulanIni({
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<_DialogFilterBulanIni> createState() => _DialogFilterBulanIniState();
}

class _DialogFilterBulanIniState extends State<_DialogFilterBulanIni> {
  late KartuBulanIniMode _mode;
  late int _selectedYear;
  late int _selectedMonth;
  late int _startYear;
  late int _startMonth;
  late int _endYear;
  late int _endMonth;

  final List<String> _namaBulan = const [
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

  late final List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _availableYears = List.generate(7, (i) => now.year - 4 + i);

    _mode = widget.initialFilter.mode;
    _selectedYear = widget.initialFilter.selectedYear ?? now.year;
    _selectedMonth = widget.initialFilter.selectedMonth ?? now.month;
    _startYear = widget.initialFilter.selectedYear ?? now.year;
    _startMonth = widget.initialFilter.selectedMonth ?? 1;
    _endYear = widget.initialFilter.endYear ?? now.year;
    _endMonth = widget.initialFilter.endMonth ?? now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      backgroundColor: AppColors.canvas,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.filter_alt, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Filter Kartu Bulan Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Filter ini hanya berlaku untuk kartu ke-3 dan tidak mengubah grafik atau data lainnya (FR-5.12).',
                style: TextStyle(fontSize: 12, color: AppColors.inkSubtle),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.hairline),
              const SizedBox(height: 12),

              // Opsi Mode
              _buildModeRadio(
                title: 'Bulan Berjalan (Default)',
                subtitle: 'Menampilkan data bulan ini sesuai kalender saat ini',
                value: KartuBulanIniMode.bulanBerjalan,
              ),
              _buildModeRadio(
                title: 'Pilih Bulan Tertentu',
                subtitle: 'Menampilkan data satu bulan spesifik di masa lalu/depan',
                value: KartuBulanIniMode.bulanTertentu,
              ),
              if (_mode == KartuBulanIniMode.bulanTertentu)
                _buildBulanTertentuInputs(),

              _buildModeRadio(
                title: 'Satu Tahun Penuh',
                subtitle: 'Menampilkan akumulasi seluruh data dalam 1 tahun kalender',
                value: KartuBulanIniMode.tahunTertentu,
              ),
              if (_mode == KartuBulanIniMode.tahunTertentu)
                _buildTahunTertentuInputs(),

              _buildModeRadio(
                title: 'Rentang Bulan Kustom',
                subtitle: 'Menampilkan akumulasi beberapa bulan tertentu',
                value: KartuBulanIniMode.rentangKustom,
              ),
              if (_mode == KartuBulanIniMode.rentangKustom)
                _buildRentangBulanInputs(),

              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.hairline),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_mode != KartuBulanIniMode.bulanBerjalan) ...[
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _mode = KartuBulanIniMode.bulanBerjalan;
                        });
                        widget.onApply(KartuBulanIniFilterState.defaultBulanBerjalan());
                        Navigator.of(context).pop();
                      },
                      child: const Text('Reset', style: TextStyle(color: AppColors.error)),
                    ),
                    const Spacer(),
                  ],
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal', style: TextStyle(color: AppColors.inkMuted)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    key: const Key('btn_terapkan_filter_kartu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    onPressed: _onApplyPressed,
                    child: const Text('Terapkan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeRadio({
    required String title,
    required String subtitle,
    required KartuBulanIniMode value,
  }) {
    final isSelected = _mode == value;
    return InkWell(
      onTap: () => setState(() => _mode = value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<KartuBulanIniMode>(
              value: value,
              groupValue: _mode,
              onChanged: (val) {
                if (val != null) setState(() => _mode = val);
              },
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.inkSubtle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulanTertentuInputs() {
    return Padding(
      padding: const EdgeInsets.only(left: 36, bottom: 8, top: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(
                labelText: 'Bulan',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: List.generate(12, (i) {
                return DropdownMenuItem(
                  value: i + 1,
                  child: Text(_namaBulan[i], style: const TextStyle(fontSize: 13)),
                );
              }),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMonth = val);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Tahun',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: _availableYears.map((y) {
                return DropdownMenuItem(
                  value: y,
                  child: Text(y.toString(), style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedYear = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTahunTertentuInputs() {
    return Padding(
      padding: const EdgeInsets.only(left: 36, bottom: 8, top: 4),
      child: DropdownButtonFormField<int>(
        value: _selectedYear,
        decoration: const InputDecoration(
          labelText: 'Tahun',
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items: _availableYears.map((y) {
          return DropdownMenuItem(
            value: y,
            child: Text('Tahun $y', style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) setState(() => _selectedYear = val);
        },
      ),
    );
  }

  Widget _buildRentangBulanInputs() {
    return Padding(
      padding: const EdgeInsets.only(left: 36, bottom: 8, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<int>(
                  value: _startMonth,
                  decoration: const InputDecoration(
                    labelText: 'Dari Bulan',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(12, (i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text(_namaBulan[i], style: const TextStyle(fontSize: 12)),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) setState(() => _startMonth = val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  value: _startYear,
                  decoration: const InputDecoration(
                    labelText: 'Tahun',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: _availableYears.map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text(y.toString(), style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _startYear = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<int>(
                  value: _endMonth,
                  decoration: const InputDecoration(
                    labelText: 'Sampai Bulan',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(12, (i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text(_namaBulan[i], style: const TextStyle(fontSize: 12)),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) setState(() => _endMonth = val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  value: _endYear,
                  decoration: const InputDecoration(
                    labelText: 'Tahun',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: _availableYears.map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text(y.toString(), style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _endYear = val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onApplyPressed() {
    switch (_mode) {
      case KartuBulanIniMode.bulanBerjalan:
        widget.onApply(KartuBulanIniFilterState.defaultBulanBerjalan());
        break;
      case KartuBulanIniMode.bulanTertentu:
        widget.onApply(KartuBulanIniFilterState.bulanTertentu(
          _selectedYear,
          _selectedMonth,
        ));
        break;
      case KartuBulanIniMode.tahunTertentu:
        widget.onApply(KartuBulanIniFilterState.tahunTertentu(
          _selectedYear,
        ));
        break;
      case KartuBulanIniMode.rentangKustom:
        // Validasi urutan tanggal: start <= end
        final startDt = DateTime(_startYear, _startMonth, 1);
        final endDt = DateTime(_endYear, _endMonth, 1);
        if (startDt.isAfter(endDt)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bulan awal tidak boleh setelah bulan akhir.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        widget.onApply(KartuBulanIniFilterState.rentangKustom(
          startYear: _startYear,
          startMonth: _startMonth,
          endYear: _endYear,
          endMonth: _endMonth,
        ));
        break;
    }
    Navigator.of(context).pop();
  }
}
