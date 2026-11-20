import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Komponen Bar Paginasi Bergaya IBM Carbon Design System.
/// Mendukung layar desktop dan mobile (< 450px) dengan tata letak responsif.
class EnterprisePaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  const EnterprisePaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.pageSize = 20,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();

    final itemStart = (currentPage - 1) * pageSize + 1;
    final itemEnd = (currentPage * pageSize).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(
          top: BorderSide(color: AppColors.hairline, width: 1.0),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 460;

          final infoText = Text(
            'Menampilkan $itemStart-$itemEnd dari $totalItems data (Hal $currentPage/$totalPages)',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

          final prevButton = OutlinedButton.icon(
            key: const Key('pagination_prev_button'),
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left, size: 16),
            label: const Text(
              'Sebelumnya',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              disabledForegroundColor: AppColors.inkSubtle,
              side: BorderSide(
                color: currentPage > 1
                    ? AppColors.hairlineStrong
                    : AppColors.hairline,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2.0)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
            ),
          );

          final nextButton = OutlinedButton.icon(
            key: const Key('pagination_next_button'),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right, size: 16),
            label: const Text(
              'Selanjutnya',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              disabledForegroundColor: AppColors.inkSubtle,
              side: BorderSide(
                color: currentPage < totalPages
                    ? AppColors.hairlineStrong
                    : AppColors.hairline,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2.0)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
            ),
          );

          if (isNarrow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: infoText),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: prevButton),
                    const SizedBox(width: 8),
                    Expanded(child: nextButton),
                  ],
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: infoText),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  prevButton,
                  const SizedBox(width: 8),
                  nextButton,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
