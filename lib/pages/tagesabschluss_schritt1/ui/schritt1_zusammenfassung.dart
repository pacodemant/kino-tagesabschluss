import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_uebersicht_section.dart';

class Schritt1Zusammenfassung extends StatelessWidget {
  const Schritt1Zusammenfassung({
    super.key,
    required this.kassenbestandGesamt,
    required this.wechselgeldSollwert,
    required this.barumsatzBereinigt,
    required this.kartenzahlungen,
    required this.gesamtInklKarte,
    required this.barumsatzNegativ,
  });

  final String kassenbestandGesamt;
  final String wechselgeldSollwert;
  final String barumsatzBereinigt;
  final String kartenzahlungen;
  final String gesamtInklKarte;
  final bool barumsatzNegativ;

  @override
  Widget build(BuildContext context) {
    return Schritt1UebersichtSection(
      kassenbestandGesamt: kassenbestandGesamt,
      wechselgeldSollwert: wechselgeldSollwert,
      barumsatzBereinigt: barumsatzBereinigt,
      kartenzahlungen: kartenzahlungen,
      gesamtInklKarte: gesamtInklKarte,
      barumsatzNegativ: barumsatzNegativ,
    );
  }
}
