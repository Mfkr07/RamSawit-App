import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/dashboard_analytics.dart';
import '../../auth/auth_controller.dart';
import '../dashboard_controller.dart';

/// Komponen Bar Filter Periode Reusable untuk seluruh grafik di Dashboard (PRD §7.5).
/// Menawarkan pilihan cepat: Hari Ini, 1 Minggu, 2 Minggu, 1 Bulan, 3 Bulan, 6 Bulan, 1 Tahun,
/// serta Date Range Picker untuk pemilihan rentang tanggal manual (kustom).
/// Untuk role Kasir, opsi dibatasi maksimal 1 Bulan tanpa tombol kustom (FR-5.11).
class DashboardPeriodeBar extends StatefulWidget {
  const DashboardPeriodeBar({super.key});

  @override
  State<DashboardPeriodeBar> createState() => _DashboardPeriodeBarState();
}

class _DashboardPeriodeBarState extends State<DashboardPeriodeBar> {
  bool _isExpanded = false;

  Future<void> _handleCustomDateRange(
    BuildContext context,
    WidgetRef ref,
    DashboardPeriodeState current,
  ) async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: current.startDate,
        end: current.endDate.isAfter(now) ? now : current.endDate,
      ),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'PILIH RENTANG TANGGAL GRAFIK',
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
      ref.read(dashboardPeriodeProvider.notifier).setCustomRange(
            pickedRange.start,
            pickedRange.end,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final periode = ref.watch(dashboardPeriodeProvider);
        final isKasir =
            ref.watch(authControllerProvider).profile?.role == 'kasir';

        final allPresets = [
          DashboardPeriodePreset.hariIni,
          DashboardPeriodePreset.satuMinggu,
          DashboardPeriodePreset.duaMinggu,
          DashboardPeriodePreset.satuBulan,
          DashboardPeriodePreset.tigaBulan,
          DashboardPeriodePreset.enamBulan,
          DashboardPeriodePreset.satuTahun,
        ];

        final presets = isKasir
            ? allPresets.where((p) => p.isAllowedForKasir).toList()
            : allPresets;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;

            final cardContent = Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.hairline, width: 1.0),
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info bar
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: const [
                          Icon(
                            Icons.tune,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          Text(
                            'FILTER PERIODE GRAFIK & ANALITIK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.surface1,
                          borderRadius: BorderRadius.all(Radius.circular(2.0)),
                        ),
                        child: Text(
                          'Rentang: ${periode.formattedRange}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Deretan Tombol Chip Preset Waktu Asli
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in presets)
                        ChoiceChip(
                          key: Key('filter_preset_${p.name}'),
                          label: Text(_presetLabel(p)),
                          selected: periode.preset == p,
                          onSelected: (selected) {
                            if (selected) {
                              ref
                                  .read(dashboardPeriodeProvider.notifier)
                                  .setPreset(p);
                            }
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: periode.preset == p
                                ? Colors.white
                                : AppColors.ink,
                          ),
                          backgroundColor: AppColors.surface1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(
                              color: periode.preset == p
                                  ? AppColors.primary
                                  : AppColors.hairline,
                            ),
                          ),
                        ),
                      if (!isKasir)
                        OutlinedButton.icon(
                          key: const Key('filter_preset_kustom'),
                          onPressed: () => _handleCustomDateRange(
                            context,
                            ref,
                            periode,
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            side: BorderSide(
                              color:
                                  periode.preset == DashboardPeriodePreset.kustom
                                      ? AppColors.primary
                                      : AppColors.hairline,
                            ),
                            backgroundColor:
                                periode.preset == DashboardPeriodePreset.kustom
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
                            color:
                                periode.preset == DashboardPeriodePreset.kustom
                                    ? AppColors.primary
                                    : AppColors.inkMuted,
                          ),
                          label: Text(
                            periode.preset == DashboardPeriodePreset.kustom
                                ? 'Kustom (Aktif)'
                                : 'Kustom Tanggal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: periode.preset ==
                                      DashboardPeriodePreset.kustom
                                  ? AppColors.primary
                                  : AppColors.ink,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );

            // Pada Desktop / Tablet: Tampilkan Card Filter langsung
            if (!isMobile) {
              return cardContent;
            }

            // Pada Mobile: 1 Tombol Khusus 'Buka/Tutup Filter' (Non-Sticky)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  key: const Key('toggle_filter_dashboard_btn'),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.tune : Icons.filter_alt_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isExpanded
                              ? 'Tutup Panel Filter'
                              : 'Filter Periode: ${_presetLabel(periode.preset)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _isExpanded
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
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  cardContent,
                ],
              ],
            );
          },
        );
      },
    );
  }

  String _presetLabel(DashboardPeriodePreset p) {
    switch (p) {
      case DashboardPeriodePreset.hariIni:
        return 'Hari Ini';
      case DashboardPeriodePreset.satuMinggu:
        return '1 Minggu';
      case DashboardPeriodePreset.duaMinggu:
        return '2 Minggu';
      case DashboardPeriodePreset.satuBulan:
        return '1 Bulan';
      case DashboardPeriodePreset.tigaBulan:
        return '3 Bulan';
      case DashboardPeriodePreset.enamBulan:
        return '6 Bulan';
      case DashboardPeriodePreset.satuTahun:
        return '1 Tahun';
      case DashboardPeriodePreset.kustom:
        return 'Kustom';
    }
  }
}
