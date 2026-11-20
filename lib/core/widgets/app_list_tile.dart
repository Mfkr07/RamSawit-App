import 'package:flutter/material.dart';

/// Komponen ListTile standar aplikasi dengan pembungkus Material langsung.
///
/// Menyelesaikan secara permanen peringatan Flutter:
/// "ListTile background color or ink splashes may be invisible"
/// dengan menjamin bahwa setiap ListTile memiliki ancestor [Material] yang valid.
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final bool dense;
  final Color? tileColor;
  final bool selected;
  final ShapeBorder? shape;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.dense = false,
    this.tileColor,
    this.selected = false,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tileColor ?? Colors.transparent,
      shape: shape,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding: contentPadding,
        dense: dense,
        selected: selected,
      ),
    );
  }
}
