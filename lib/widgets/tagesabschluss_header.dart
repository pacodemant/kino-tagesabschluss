import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_header_section.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class TagesabschlussHeader extends StatelessWidget implements PreferredSizeWidget {
  const TagesabschlussHeader({
    super.key,
    required this.schrittNummer,
    required this.schrittTitel,
    this.gesamtSchritte = 4,
    this.subtitle,
    this.actions,
    this.onTap,
    this.toolbarHeight = 48,
  });

  // Zweck: Einheitlicher Header/AppBar fuer alle Tagesabschluss-Schritte.
  // Die Schrittzeile wird standardmaessig als "x/4 · Titel" aufgebaut.
  final int schrittNummer;
  final int gesamtSchritte;
  final String schrittTitel;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final double toolbarHeight;

  // Ermöglicht bei Bedarf ein explizites Ueberschreiben der Unterzeile.
  String get _standardUntertitel => '$schrittNummer/$gesamtSchritte · $schrittTitel';

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final String untertitel = subtitle ?? _standardUntertitel;
    return AppBar(
      backgroundColor: AppFarben.appBarRot,
      foregroundColor: Colors.white,
      toolbarHeight: toolbarHeight,
      titleSpacing: 8,
      title: Schritt1HeaderSection(
        onTap: onTap ?? () {},
        titel: 'Tagesabschluss SCHAUBURG',
        untertitel: untertitel,
      ),
      actions: actions,
    );
  }
}
