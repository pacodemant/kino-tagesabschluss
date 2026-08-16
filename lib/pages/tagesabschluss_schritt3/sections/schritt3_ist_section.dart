import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_info_card.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

class Schritt3IstSection extends StatelessWidget {
  const Schritt3IstSection({
    super.key,
    required this.ecIstCent,
    required this.barIstCent,
    required this.gesamtIstCent,
  });

  final int ecIstCent;
  final int barIstCent;
  final int gesamtIstCent;

  @override
  Widget build(BuildContext context) {
    return Schritt3InfoCard(
      zeilen: <Widget>[
        InfoZeile(
          label: '+ EC IST',
          wert: TagesabschlussFormatierung.formatiereEuro(ecIstCent),
          stil: InfoZeileStil.fuehrungslinie,
        ),
        InfoZeile(
          label: '+ bar IST',
          wert: TagesabschlussFormatierung.formatiereEuro(barIstCent),
          stil: InfoZeileStil.fuehrungslinie,
        ),
        InfoZeile(
          label: '= Gesamt IST',
          wert: TagesabschlussFormatierung.formatiereEuro(gesamtIstCent),
          fett: true,
          stil: InfoZeileStil.fuehrungslinie,
        ),
      ],
    );
  }
}
