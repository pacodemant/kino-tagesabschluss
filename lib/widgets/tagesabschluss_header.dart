import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_header_section.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class TagesabschlussHeader extends StatelessWidget implements PreferredSizeWidget {
  const TagesabschlussHeader({
    super.key,
    required this.schrittNummer,
    required this.schrittTitel,
    this.kinoName = 'Schauburg',
    this.gesamtSchritte = 4,
    this.subtitle,
    this.actions,
    this.onTap,
    this.toolbarHeight = 48,
  });

  // Zweck: Einheitlicher Header/AppBar fuer alle Tagesabrechnung-Schritte.
  // Die Schrittzeile wird standardmaessig als "x/4 · Titel" aufgebaut.
  final int schrittNummer;
  final int gesamtSchritte;
  final String kinoName;
  final String schrittTitel;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final double toolbarHeight;

  // Obere Zeile (bold): nur der Titel ohne Schrittnummer.
  String get _standardUntertitel => schrittTitel;

  String get _kuerzel {
    for (final Kino kino in KinoRepository.kinos) {
      if (kino.name == kinoName) return kino.kuerzel;
    }
    return kinoName;
  }

  // Untere Zeile (klein): Kino-Kürzel + Schrittnummer wenn vorhanden.
  String get _titelUnten => schrittNummer == 0
      ? 'Kassenabrechnung ($_kuerzel)'
      : 'Kassenabrechnung ($_kuerzel) $schrittNummer/$gesamtSchritte';

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final String untertitel = subtitle ?? _standardUntertitel;
    return AppBar(
      centerTitle: false,
      backgroundColor: AppFarben.appBarRot,
      foregroundColor: Colors.white,
      toolbarHeight: toolbarHeight,
      titleSpacing: 8,
      title: Schritt1HeaderSection(
        onTap: onTap ?? () {},
        titel: _titelUnten,
        untertitel: untertitel,
      ),
      actions: actions,
    );
  }
}
