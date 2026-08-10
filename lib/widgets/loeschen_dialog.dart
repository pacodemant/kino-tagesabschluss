import 'package:flutter/material.dart';

/// Generischer Abbrechen/Löschen-Bestätigungsdialog. Zentral, damit
/// Titel/Text pro Aufrufstelle variieren, Aufbau und Button-Stil aber
/// überall gleich bleiben.
Future<bool?> zeigeBestaetigungsDialog(
  BuildContext context, {
  required String titel,
  required String inhalt,
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
          child: const Text('Abbrechen'),
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
