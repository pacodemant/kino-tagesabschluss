import 'package:flutter/material.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';

/// Fragt vor dem Verlassen einer Kassenabrechnung-Schritt-Seite nach, wenn
/// dort bereits mindestens ein Feld ausgefüllt ist (Wert ungleich 0/leer)
/// — unabhängig davon, auf welchem Weg die Seite verlassen wird
/// (Zurück-Geste, Haus-Button, AppBar-Schritt-Slider). Ist nichts
/// ausgefüllt, keine Rückfrage. Der reguläre "Weiter"-Button unten auf der
/// Seite ist bewusst ausgenommen — der hat eigene, spezifischere Prüfungen.
Future<bool> bestaetigeSeitenwechselFallsNoetig(
  BuildContext context, {
  required bool hatAusgefuellteFelder,
}) async {
  if (!hatAusgefuellteFelder) {
    return true;
  }
  final bool? bestaetigt = await zeigeBestaetigungsDialog(
    context,
    titel: 'Seite verlassen?',
    inhalt:
        'Deine Eingaben bleiben zwar gespeichert, aber du verlässt diesen '
        'Schritt.',
    bestaetigenText: 'Verlassen',
  );
  return bestaetigt == true;
}
