import 'package:flutter/material.dart';

/// Generischer Abbrechen/Löschen-Bestätigungsdialog. Zentral, damit
/// Titel/Text pro Aufrufstelle variieren, Aufbau und Button-Stil aber
/// überall gleich bleiben.
Future<bool?> zeigeBestaetigungsDialog(
  BuildContext context, {
  required String titel,
  required String inhalt,
  String abbrechenText = 'Abbrechen',
  String bestaetigenText = 'Löschen',
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(titel),
      content: Text(inhalt),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(abbrechenText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(bestaetigenText),
        ),
      ],
    ),
  );
}

Future<bool?> zeigeLoeschenDialog(BuildContext context) {
  return zeigeBestaetigungsDialog(
    context,
    titel: 'Eintrag löschen?',
    inhalt: 'Diese Kassenabrechnung wirklich löschen?',
  );
}

/// Generischer Ein-Button-Hinweisdialog ("zur Kenntnis nehmen"). Zentral,
/// damit Titel/Inhalt/Button-Text pro Aufrufstelle variieren, Aufbau und
/// Button-Stil aber überall gleich bleiben.
Future<void> zeigeInfoDialog(
  BuildContext context, {
  required String titel,
  required Widget inhalt,
  String buttonText = 'Verstanden',
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(titel),
      content: inhalt,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(buttonText),
        ),
      ],
    ),
  );
}
