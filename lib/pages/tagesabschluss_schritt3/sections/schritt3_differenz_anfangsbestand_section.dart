import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_info_card.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

class Schritt3DifferenzAnfangsbestandSection extends StatelessWidget {
  const Schritt3DifferenzAnfangsbestandSection({
    super.key,
    required this.differenzAnfangsbestandCent,
  });

  final int differenzAnfangsbestandCent;

  @override
  Widget build(BuildContext context) {
    return Schritt3InfoCard(
      zeilen: <Widget>[
        InfoZeile(
          label: 'Differenz Anfangsbestand',
          wert: TagesabschlussFormatierung.formatiereEuro(
            differenzAnfangsbestandCent,
          ),
          stil: InfoZeileStil.fuehrungslinie,
        ),
      ],
    );
  }
}
