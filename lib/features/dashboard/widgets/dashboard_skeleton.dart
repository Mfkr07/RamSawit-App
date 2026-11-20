import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Komponen animasi shimmer/pulse halus bergaya IBM Carbon Design System.
/// Menghindari layout shift saat data analitik dimuat.
class CarbonSkeletonPulse extends StatefulWidget {
  final Widget child;

  const CarbonSkeletonPulse({super.key, required this.child});

  @override
  State<CarbonSkeletonPulse> createState() => _CarbonSkeletonPulseState();
}

class _CarbonSkeletonPulseState extends State<CarbonSkeletonPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Balok dasar skeleton IBM Carbon
class CarbonSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;

  const CarbonSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 2.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface2,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
    );
  }
}

/// Skeleton untuk 3 Kartu Ringkasan KPI (Pembelian, Penjualan, Margin)
class DashboardKpiSkeleton extends StatelessWidget {
  const DashboardKpiSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CarbonSkeletonPulse(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final cards = [
            _buildCardSkeleton(),
            _buildCardSkeleton(),
            _buildCardSkeleton(),
          ];

          if (isDesktop) {
            return Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 14),
                Expanded(child: cards[1]),
                const SizedBox(width: 14),
                Expanded(child: cards[2]),
              ],
            );
          }

          return Column(
            children: [
              cards[0],
              const SizedBox(height: 12),
              cards[1],
              const SizedBox(height: 12),
              cards[2],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CarbonSkeletonBox(width: 100, height: 12),
              CarbonSkeletonBox(width: 40, height: 12),
            ],
          ),
          SizedBox(height: 12),
          CarbonSkeletonBox(width: 140, height: 22),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: CarbonSkeletonBox(height: 10)),
              SizedBox(width: 8),
              Expanded(child: CarbonSkeletonBox(height: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton untuk Grafik (Tren Nilai, Tren Berat, Breakdown)
class DashboardChartSkeleton extends StatelessWidget {
  final double height;

  const DashboardChartSkeleton({super.key, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return CarbonSkeletonPulse(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          border: Border.all(color: AppColors.hairline),
          borderRadius: const BorderRadius.all(Radius.circular(2.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CarbonSkeletonBox(width: 160, height: 14),
                CarbonSkeletonBox(width: 80, height: 12),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final barHeightFraction = (index % 3 + 1) * 0.25;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: FractionallySizedBox(
                        heightFactor: barHeightFraction,
                        alignment: Alignment.bottomCenter,
                        child: const CarbonSkeletonBox(height: double.infinity),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CarbonSkeletonBox(width: 30, height: 10),
                CarbonSkeletonBox(width: 30, height: 10),
                CarbonSkeletonBox(width: 30, height: 10),
                CarbonSkeletonBox(width: 30, height: 10),
                CarbonSkeletonBox(width: 30, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton untuk Bagian Riwayat Transaksi & Pengiriman Terakhir
class DashboardListSkeleton extends StatelessWidget {
  final double height;

  const DashboardListSkeleton({super.key, this.height = 240});

  @override
  Widget build(BuildContext context) {
    return CarbonSkeletonPulse(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          border: Border.all(color: AppColors.hairline),
          borderRadius: const BorderRadius.all(Radius.circular(2.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CarbonSkeletonBox(width: 140, height: 14),
                CarbonSkeletonBox(width: 60, height: 12),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    const CarbonSkeletonBox(width: 36, height: 36),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CarbonSkeletonBox(width: 120, height: 12),
                          SizedBox(height: 6),
                          CarbonSkeletonBox(width: 80, height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const CarbonSkeletonBox(width: 70, height: 14),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
