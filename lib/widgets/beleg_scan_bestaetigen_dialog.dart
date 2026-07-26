import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class BelegScanZeilenVorschau {
  BelegScanZeilenVorschau({
    required this.name,
    required this.betragCent,
    this.nichtLesbar = false,
    this.nameNichtLesbar = false,
  });

  final String name;
  final int? betragCent;
  final bool nichtLesbar;

  /// true, wenn die Kartenart selbst nicht zuverlässig lesbar war
  /// (z.B. "Unbekannte Kartenart") — Name wird dann rot hervorgehoben.
  final bool nameNichtLesbar;
}

/// true, wenn im Scan mindestens ein Wert (Kartenart, Betrag oder TID)
/// nicht zuverlässig lesbar war – also alles, was im Prüf-Popup rot
/// hervorgehoben wird.
bool belegScanHatUnlesbareDaten(
  BelegScanErgebnis ergebnis,
  List<BelegScanZeilenVorschau> zeilen,
) {
  return ergebnis.terminalId == null ||
      zeilen.any((BelegScanZeilenVorschau z) =>
          z.nichtLesbar || z.nameNichtLesbar);
}

Future<bool> zeigeBelegScanBestaetigenDialog(
  BuildContext context, {
  required BelegScanErgebnis ergebnis,
  required List<BelegScanZeilenVorschau> zeilen,
}) async {
  final bool? uebernehmen = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Scan-Ergebnis prüfen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (ergebnis.datum != null) _metaZeile('Datum', ergebnis.datum!),
            _metaZeileTid(ergebnis.terminalId),
            const Divider(height: 20),
            if (zeilen.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Keine Kartenposten erkannt.',
                  style: TextStyle(fontSize: 13, color: AppFarben.subtilerText),
                ),
              )
            else
              for (final BelegScanZeilenVorschau zeile in zeilen)
                _betragZeile(zeile),
            const Divider(height: 20),
            _summeZeile('Gesamt laut Beleg', ergebnis.gesamtBetragCent),
            if (belegScanHatUnlesbareDaten(ergebnis, zeilen)) ...<Widget>[
              const SizedBox(height: 8),
              const Text(
                'Rot markierte Werte können nach der Übernahme direkt '
                'in den Feldern nachgetragen oder korrigiert werden – '
                'oder du scannst den Beleg noch einmal.',
                style: TextStyle(fontSize: 12, color: AppFarben.subtilerText),
              ),
            ],
            if (ergebnis.hinweis != null) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ergebnis.hinweis!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('nochmal'),
              SizedBox(width: 6),
              Icon(Icons.camera_alt_outlined, size: 18),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppFarben.appBarRot,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('übernehmen'),
        ),
      ],
    ),
  );
  return uebernehmen ?? false;
}

Widget _metaZeileTid(String? terminalId) {
  if (terminalId != null) {
    return _metaZeile('TID', terminalId);
  }
  return const Padding(
    padding: EdgeInsets.only(bottom: 4),
    child: Row(
      children: <Widget>[
        SizedBox(
          width: 60,
          child: Text(
            'TID',
            style: TextStyle(fontSize: 13, color: AppFarben.subtilerText),
          ),
        ),
        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
        SizedBox(width: 4),
        Text(
          'nicht lesbar',
          style: TextStyle(fontSize: 13, color: Colors.red),
        ),
      ],
    ),
  );
}

Widget _metaZeile(String label, String wert) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: <Widget>[
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppFarben.subtilerText),
          ),
        ),
        Text(wert, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}

Widget _betragZeile(BelegScanZeilenVorschau zeile) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: <Widget>[
        Expanded(
          child: zeile.nameNichtLesbar
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.warning_amber_rounded,
                        size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        zeile.name,
                        style: const TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ),
                  ],
                )
              : Text(zeile.name, style: const TextStyle(fontSize: 13)),
        ),
        if (zeile.nichtLesbar)
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
              SizedBox(width: 4),
              Text(
                'nicht lesbar',
                style: TextStyle(fontSize: 13, color: Colors.red),
              ),
            ],
          )
        else
          SizedBox(
            width: 104,
            child: Text(
              TagesabschlussFormatierung.formatiereEuro(zeile.betragCent!),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
      ],
    ),
  );
}

Widget _summeZeile(String label, int? cent) {
  return Row(
    children: <Widget>[
      Expanded(
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      SizedBox(
        width: 104,
        child: Text(
          cent != null ? TagesabschlussFormatierung.formatiereEuro(cent) : '—',
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
