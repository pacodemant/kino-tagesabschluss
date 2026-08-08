import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

class Schritt3DifferenzAnfangsbestandSection extends StatelessWidget {
  const Schritt3DifferenzAnfangsbestandSection({
    super.key,
    required this.differenzAnfangsbestandCent,
  });

  final int differenzAnfangsbestandCent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            InfoZeile(
              label: 'Differenz Anfangsbestand',
              wert: TagesabschlussFormatierung.formatiereEuro(
                differenzAnfangsbestandCent,
              ),
              stil: InfoZeileStil.fuehrungslinie,
            ),
          ],
        ),
      ),
    );
  }
}
