import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
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
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            InfoZeile(
              label: '+ Kino Soll',
              wert: TagesabschlussFormatierung.formatiereEuro(kinoSollCent),
              stil: InfoZeileStil.fuehrungslinie,
            ),
            if (zeigeBistroSoll)
              InfoZeile(
                label: '+ Bistro Soll',
                wert:
                    TagesabschlussFormatierung.formatiereEuro(bistroSollCent),
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
        ),
      ),
    );
  }
}
