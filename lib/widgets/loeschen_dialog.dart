import 'package:flutter/material.dart';

Future<bool?> zeigeLoeschenDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Eintrag löschen?'),
      content: const Text('Diese Kassenabrechnung wirklich löschen?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Löschen'),
        ),
      ],
    ),
  );
}
