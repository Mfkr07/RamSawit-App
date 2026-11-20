import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sync/sync_status_bar.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_insight.dart';
import 'ai_analytics_controller.dart';
import 'widgets/dialogs/ai_endpoint_settings_dialog.dart';
import 'widgets/ai_chat_advisor_widget.dart';
import 'widgets/ai_insight_card.dart';
import 'widgets/ai_kpi_overview_card.dart';

/// Halaman Modul Analitik AI & Asisten Keputusan Bisnis.
/// Mengimplementasikan prinsip IBM Carbon Design System:
/// - Tata letak monokromatik enterprise dengan aksen warna semantik
/// - Kartu KPI cerdas, deteksi anomali sortasi, rekomendasi harga TBS
/// - Asisten konsultasi interaktif berbasis konteks data riil TBS Sawit
class AiAnalyticsPage extends ConsumerWidget {
  const AiAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiAnalyticsControllerProvider);
    final controller = ref.read(aiAnalyticsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface1,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: SafeArea(
          bottom: false,
          child: SyncStatusBar(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideDesktop = constraints.maxWidth >= 1050;
          final isMobile = constraints.maxWidth < 650;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Analitik AI & Asisten Bisnis (Hanya tampil di Desktop/Tablet luas)
                if (!isMobile) ...[
                  _buildHeader(context, ref, state),
                  const SizedBox(height: 16),
                ] else ...[
                  // Header Mini 1 Baris di Mobile agar Chatbox Maksimal
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      border: Border.all(color: AppColors.hairline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'KONSULTASI AI BISNIS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, size: 18, color: AppColors.inkMuted),
                          tooltip: 'Pengaturan Endpoint AI (Ollama/9router/OpenAI)',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const AiEndpointSettingsDialog(),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showKpiBottomSheet(context, state, controller),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.analytics_outlined, size: 14, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Wawasan & Info',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 2. Konten Chatbot Utama
                if (isWideDesktop)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Panel Kiri: Chatbot Interaktif Owner (Pusat Konsultasi Utama)
                        const Expanded(
                          flex: 7,
                          child: AiChatAdvisorWidget(),
                        ),
                        const SizedBox(width: 16),
                        // Panel Kanan: Sidebar Ringkasan KPI & Temuan Wawasan
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AiKpiOverviewCards(overview: state.kpiOverview),
                                const SizedBox(height: 14),
                                _buildFilterBar(state, controller),
                                const SizedBox(height: 10),
                                _buildInsightsList(state, controller),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: const AiChatAdvisorWidget(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showKpiBottomSheet(
    BuildContext context,
    AiAnalyticsState state,
    AiAnalyticsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final currentState = ref.watch(aiAnalyticsControllerProvider);
            final currentController = ref.read(aiAnalyticsControllerProvider.notifier);

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'METRIK & WAWASAN OPERASIONAL',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.hairline),
                      const SizedBox(height: 12),
                      AiKpiOverviewCards(overview: currentState.kpiOverview),
                      const SizedBox(height: 16),
                      _buildFilterBar(currentState, currentController),
                      const SizedBox(height: 12),
                      _buildInsightsList(currentState, currentController),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AiAnalyticsState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 36,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'ANALITIK AI & ASISTEN BISNIS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.0),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Prediksi Tren Panen, Deteksi Anomali Sortasi & Rekomendasi Penetapan Harga TBS',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Koneksi 9router Local AI
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  border: Border.all(color: AppColors.hairline),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 14, color: AppColors.success),
                    SizedBox(width: 6),
                    Text(
                      '9router :20128 (Claude & Gemini)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Tombol Jalankan Analisis Ulang
              ElevatedButton.icon(
                onPressed: state.isAnalyzing
                    ? null
                    : () {
                        ref
                            .read(aiAnalyticsControllerProvider.notifier)
                            .runFullAnalysis();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Analisis AI selesai diperbarui dengan data transaksi terbaru.',
                            ),
                            backgroundColor: AppColors.ink,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  elevation: 0,
                ),
                icon: state.isAnalyzing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, size: 16),
                label: Text(
                  state.isAnalyzing ? 'Menganalisis...' : 'Analisis Ulang',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    AiAnalyticsState state,
    AiAnalyticsController controller,
  ) {
    final filters = [
      {'id': 'semua', 'label': 'Semua Wawasan (${state.allInsights.length})'},
      {
        'id': 'anomali',
        'label': 'Anomali Sortasi (${state.allInsights.where((i) => i.type == AiInsightType.anomalySortasi).length})'
      },
      {
        'id': 'margin',
        'label': 'Margin & Harga (${state.allInsights.where((i) => i.type == AiInsightType.marginOpportunity || i.type == AiInsightType.priceRecommendation).length})'
      },
      {
        'id': 'pasokan',
        'label': 'Pola Pasokan (${state.allInsights.where((i) => i.type == AiInsightType.supplyPattern || i.type == AiInsightType.cashFlowRisk).length})'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = state.selectedFilter == f['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.onPrimary : AppColors.ink,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.ink,
                backgroundColor: AppColors.surface1,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  side: BorderSide(color: AppColors.hairline),
                ),
                onSelected: (_) {
                  controller.setFilter(f['id']!);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInsightsList(
    AiAnalyticsState state,
    AiAnalyticsController controller,
  ) {
    final list = state.filteredInsights;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          border: Border.all(color: AppColors.hairline),
        ),
        child: const Center(
          child: Text(
            'Tidak ada wawasan AI pada kategori yang dipilih.',
            style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
          ),
        ),
      );
    }

    return Column(
      children: list.map((insight) {
        return AiInsightCard(insight: insight);
      }).toList(),
    );
  }
}
