import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class BelegScanZeilenVorschau {
  BelegScanZeilenVorschau({
    required this.name,
    required this.betragCent,
    this.nichtLesbar = false,
  });

  final String name;
  final int? betragCent;
  final bool nichtLesbar;
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
            if (ergebnis.terminalId != null)
              _metaZeile('TID', ergebnis.terminalId!),
            const Divider(height: 20),
            if (zeilen.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Keine Kartenposten erkannt.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              )
            else
              for (final BelegScanZeilenVorschau zeile in zeilen)
                _betragZeile(zeile),
            const Divider(height: 20),
            _summeZeile('Gesamt laut Beleg', ergebnis.gesamtBetragCent),
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

Widget _metaZeile(String label, String wert) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: <Widget>[
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
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
          child: Text(zeile.name, style: const TextStyle(fontSize: 13)),
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
