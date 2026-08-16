import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_info_card.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

class Schritt3SollSection extends StatelessWidget {
  const Schritt3SollSection({
    super.key,
    required this.kinoSollCent,
    required this.bistroSollCent,
    required this.zeigeBistroSoll,
    required this.ausgabenCent,
    required this.gesamtSollCent,
  });

  final int kinoSollCent;
  final int bistroSollCent;
  final bool zeigeBistroSoll;
  final int ausgabenCent;
  final int gesamtSollCent;

  @override
  Widget build(BuildContext context) {
    return Schritt3InfoCard(
      zeilen: <Widget>[
        InfoZeile(
          label: '+ Kino Soll',
          wert: TagesabschlussFormatierung.formatiereEuro(kinoSollCent),
          stil: InfoZeileStil.fuehrungslinie,
        ),
        if (zeigeBistroSoll)
          InfoZeile(
            label: '+ Bistro Soll',
            wert: TagesabschlussFormatierung.formatiereEuro(bistroSollCent),
            stil: InfoZeileStil.fuehrungslinie,
          ),
        InfoZeile(
          label: '- Ausgaben',
          wert: TagesabschlussFormatierung.formatiereEuro(ausgabenCent),
          stil: InfoZeileStil.fuehrungslinie,
        ),
        InfoZeile(
          label: '= Gesamt Soll',
          wert: TagesabschlussFormatierung.formatiereEuro(gesamtSollCent),
          fett: true,
          stil: InfoZeileStil.fuehrungslinie,
        ),
      ],
    );
  }
}
