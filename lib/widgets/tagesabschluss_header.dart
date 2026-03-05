import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_header_section.dart';

class TagesabschlussHeader extends StatelessWidget implements PreferredSizeWidget {
  const TagesabschlussHeader({
    super.key,
    required this.stepLabel,
    required this.title,
    this.subtitle,
    this.actions,
    this.onTap,
    this.toolbarHeight = 48,
  });

  // Zweck: Einheitlicher Header/AppBar fuer alle Tagesabschluss-Schritte.
  // Parameter: stepLabel + title bilden die Unterzeile, subtitle/actions/onTap sind optional.
  final String stepLabel;
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final String untertitel = subtitle ?? '$stepLabel · $title';
    return AppBar(
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      toolbarHeight: toolbarHeight,
      titleSpacing: 8,
      title: Schritt1HeaderSection(
        onTap: onTap ?? () {},
        titel: 'Tagesabschluss',
        untertitel: untertitel,
      ),
      actions: actions,
    );
  }
}
