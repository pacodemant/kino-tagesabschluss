import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';

class BelegScanGegenpruefDialog extends StatelessWidget {
  const BelegScanGegenpruefDialog({
    super.key,
    required this.ergebnis,
  });

  final BelegScanErgebnis ergebnis;

  static final NumberFormat _euroFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  bool get _hatUnleserlicheFelder {
    return ergebnis.terminalId == null ||
        ergebnis.gesamtBetragCent == null ||
        ergebnis.zahlungsarten.any(
          (ZahlungsartErgebnis z) => z.betragCent == null || z.anzahl == null,
        );
  }

  String _formatCent(int cent) => _euroFormat.format(cent / 100.0);

  Widget _baueMetadatenZeile(String label, String? wert) {
    final Widget wertWidget = wert != null
        ? Text(wert, style: const TextStyle(fontSize: 14))
        : Text(
            'nicht verfügbar',
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange.shade700,
              fontStyle: FontStyle.italic,
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(child: wertWidget),
        ],
      ),
    );
  }

  Widget _baueZahlungsartZeile(ZahlungsartErgebnis z) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              z.art.isEmpty ? '—' : z.art,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              z.anzahl != null ? '${z.anzahl}' : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: z.anzahl == null ? Colors.orange.shade700 : null,
              ),
            ),
          ),
          SizedBox(
            width: 104,
            child: Text(
              z.betragCent != null ? _formatCent(z.betragCent!) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: z.betragCent == null ? Colors.orange.shade700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueGesamtZeile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Gesamt',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              ergebnis.gesamtAnzahl?.toString() ?? '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: !ergebnis.anzahlPlausibel ? Colors.red.shade700 : null,
              ),
            ),
          ),
          SizedBox(
            width: 104,
            child: Text(
              ergebnis.gesamtBetragCent != null
                  ? _formatCent(ergebnis.gesamtBetragCent!)
                  : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color:
                    !ergebnis.betraegePlausibel ? Colors.red.shade700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: (MediaQuery.of(context).size.height * 0.85 -
                  MediaQuery.of(context).viewInsets.bottom)
              .clamp(200.0, double.infinity),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 4, 10),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.receipt_long_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'EC-Beleg-Scan prüfen',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Schließen',
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_hatUnleserlicheFelder ||
                        (ergebnis.hinweis != null && !ergebnis.istPlausibel))
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          border: Border.all(color: const Color(0xFFFFC107)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: Color(0xFFF57F17),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ergebnis.hinweis ??
                                    'Bitte die markierten Felder manuell prüfen.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _baueMetadatenZeile('Terminal-ID', ergebnis.terminalId),
                    _baueMetadatenZeile('Datum', ergebnis.datum),
                    _baueMetadatenZeile('Uhrzeit', ergebnis.uhrzeit),
                    _baueMetadatenZeile('Beleg-Nr. von', ergebnis.belegNrVon),
                    _baueMetadatenZeile('Beleg-Nr. bis', ergebnis.belegNrBis),
                    const SizedBox(height: 10),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, top: 2),
                      child: Row(
                        children: const <Widget>[
                          Expanded(
                            child: Text(
                              'Kartenart',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              'Anz.',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 104,
                            child: Text(
                              'Betrag',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final ZahlungsartErgebnis z in ergebnis.zahlungsarten)
                      _baueZahlungsartZeile(z),
                    const Divider(),
                    _baueGesamtZeile(),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                        children: const <InlineSpan>[
                          TextSpan(
                            text:
                                'Tipp: Wenn einige Werte nicht stimmen, kannst du sie später – nach dem Button ',
                          ),
                          TextSpan(
                            text: 'Übernehmen',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                ' – manuell korrigieren oder ergänzen. Wenn zu viele Werte nicht stimmen, mach das Foto einfach noch mal.',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(
                            const BelegScanDialogErgebnis.nochmalScannen(),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('nochmal'),
                              SizedBox(width: 6),
                              Icon(Icons.camera_alt_outlined, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(
                            BelegScanDialogErgebnis(
                              ergebnis: ergebnis,
                              kachelOeffnen: false,
                            ),
                          ),
                          child: const Text('Übernehmen'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
