import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Oranger Pflicht-Hinweis zur Wechselgeldentnahme: Der MA, der die
/// Abrechnung macht, muss eine Notiz in die Wechselgeldkasse legen,
/// damit der MA des Folgetages Bescheid weiß. Zentral, damit Schritt 1 und
/// Wechselgeldprüfung denselben Wortlaut und dieselbe Optik nutzen.
class ZettelHinweis extends StatelessWidget {
  const ZettelHinweis({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppFarben.fokusFarbe,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Wechselgeldentnahme: Notiz mit Betrag und Grund gut sichtbar in die '
        'Wechselgeldkasse legen.',
        style: TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}
