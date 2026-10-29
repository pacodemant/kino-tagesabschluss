import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_info_card.dart';
import 'package:kino_bar_app/widgets/uebertrag_umschlag_inhalt.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

class Schritt3DifferenzSection extends StatelessWidget {
  const Schritt3DifferenzSection({
    super.key,
    required this.differenzCent,
    required this.differenzFarbe,
    this.hinweis,
  });

  final int differenzCent;
  final Color differenzFarbe;

  /// Hinweis unter der Differenz, z. B. bei "Kein Beleg möglich" (Run 498).
  final String? hinweis;

  @override
  Widget build(BuildContext context) {
    return Schritt3InfoCard(
      zeilen: <Widget>[
        InfoZeile(
          label: 'Differenz\nKassenabrechnung',
          wert: TagesabschlussFormatierung.formatiereEuroMitVorzeichen(
            differenzCent,
          ),
          fett: true,
          farbe: differenzFarbe,
          stil: InfoZeileStil.fuehrungslinie,
        ),
        if (hinweis != null) UebertragUmschlagInhalt.hinweisText(hinweis!),
      ],
    );
  }
}
