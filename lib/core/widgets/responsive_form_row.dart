import 'package:flutter/material.dart';

/// Komponen baris formulir responsif berstandar enterprise.
///
/// Jika lebar kontainer >= [breakpoint] (default: 580px), widget anak akan
/// disusun secara horizontal dalam [Row] dengan fleksibilitas pembagian [flexes].
///
/// Jika lebar kontainer < [breakpoint] (layar ponsel atau kolom sempit),
/// widget anak akan secara otomatis disusun secara vertikal ([Column])
/// sehingga tidak terjadi pemaksaan ukuran (RenderFlex overflow) pada field input.
class ResponsiveFormRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double breakpoint;
  final List<int>? flexes;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveFormRow({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.breakpoint = 580.0,
    this.flexes,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < breakpoint;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) SizedBox(height: runSpacing),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(
                flex: flexes != null && i < flexes!.length ? flexes![i] : 1,
                child: children[i],
              ),
              if (i < children.length - 1) SizedBox(width: spacing),
            ],
          ],
        );
      },
    );
  }
}
