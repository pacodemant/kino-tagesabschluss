import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Oranger Pflicht-Hinweis zur Wechselgeldentnahme: Der MA, der die
/// Abrechnung macht, muss eine Notiz in die Wechselgeldkasse legen,
/// damit der MA des Folgetages Bescheid weiß. Zentral, damit Schritt 1 und
/// Wechselgeldprüfung denselben Wortlaut und dieselbe Optik nutzen.
class ZettelHinweis extends StatelessWidget {
  const ZettelHinweis({super.key, this.nachDerAbrechnung = false});

  /// In Schritt 1 (Bargeldzählung) steht die Abrechnung noch bevor, dort
  /// heißt es "... nach der Abrechnung ...". In der Wechselgeldprüfung
  /// ist sie schon erfolgt, dort entfällt der Zusatz.
  final bool nachDerAbrechnung;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppFarben.fokusFarbe,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Wechselgeldentnahme: Notiz mit Betrag und Grund '
        '${nachDerAbrechnung ? 'nach der Abrechnung ' : ''}'
        'gut sichtbar in die Wechselgeldkasse legen.',
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}
