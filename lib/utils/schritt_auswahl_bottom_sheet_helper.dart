import 'package:flutter/material.dart';

/// Gemeinsames BottomSheet "Schritt X/4 · ..." — genutzt von allen vier
/// Tagesabschluss-Seiten (Bargeld zählen, Belege, Übertrag auf Umschlag,
/// Stückelung Barumsatz). Frühere Schritte sind per Zurück-Navigation immer
/// erreichbar, der aktuelle Schritt ist fett/deaktiviert markiert, alle
/// weiter vorne liegenden Schritte sind per springeZuSchritt-Callback
/// direkt ansteuerbar (auch unausgefüllt) — falls kein Callback übergeben
/// wurde (z.B. Schritt 4, letzter Schritt), bleiben sie deaktiviert.
class SchrittAuswahlBottomSheetHelper {
  const SchrittAuswahlBottomSheetHelper();

  static const List<String> _routenNamen = <String>[
    '/closure-step-1',
    '/closure-step-2',
    '/closure-step-3',
    '/closure-step-4',
  ];

  static const List<String> _labels = <String>[
    '1/4 · Bargeld zählen',
    '2/4 · Belege',
    '3/4 · Übertrag auf Umschlag',
    '4/4 · Stückelung Barumsatz',
  ];

  Future<void> zeigeSchrittAuswahlBottomSheet({
    required BuildContext context,
    required int aktuellerSchritt,
    void Function(int zielSchrittNr)? springeZuSchritt,
    /// Optionale Rückfrage vor dem eigentlichen Sprung (vor/zurück) — z.B.
    /// wenn die aktuelle Seite bereits ausgefüllte Felder hat. Liefert
    /// false, wird nicht navigiert.
    Future<bool> Function()? bestaetigeVerlassen,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(_labels.length, (int index) {
              final int schrittNr = index + 1;
              if (schrittNr == aktuellerSchritt) {
                return ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: Text(
                    _labels[index],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Aktueller Schritt'),
                  enabled: false,
                );
              }
              if (schrittNr < aktuellerSchritt) {
                return ListTile(
                  leading: const Icon(Icons.arrow_back),
                  title: Text(_labels[index]),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    if (bestaetigeVerlassen != null &&
                        !await bestaetigeVerlassen()) {
                      return;
                    }
                    if (!context.mounted) return;
                    Navigator.of(
                      context,
                    ).popUntil(ModalRoute.withName(_routenNamen[index]));
                  },
                );
              }
              if (springeZuSchritt != null) {
                return ListTile(
                  leading: const Icon(Icons.arrow_forward),
                  title: Text(_labels[index]),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    if (bestaetigeVerlassen != null &&
                        !await bestaetigeVerlassen()) {
                      return;
                    }
                    if (!context.mounted) return;
                    springeZuSchritt(schrittNr);
                  },
                );
              }
              return ListTile(title: Text(_labels[index]), enabled: false);
            }),
          ),
        );
      },
    );
  }
}
