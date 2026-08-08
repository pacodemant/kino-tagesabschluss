import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

class Schritt3DifferenzSection extends StatelessWidget {
  const Schritt3DifferenzSection({
    super.key,
    required this.differenzCent,
    required this.differenzFarbe,
  });

  final int differenzCent;
  final Color differenzFarbe;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            InfoZeile(
              label: 'Differenz\nKassenabrechnung',
              wert: TagesabschlussFormatierung.formatiereEuroMitVorzeichen(
                differenzCent,
              ),
              fett: true,
              farbe: differenzFarbe,
              stil: InfoZeileStil.fuehrungslinie,
            ),
          ],
        ),
      ),
    );
  }
}
