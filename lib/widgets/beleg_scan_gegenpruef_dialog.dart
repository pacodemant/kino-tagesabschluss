import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';

class BelegScanGegenpruefDialog extends StatefulWidget {
  const BelegScanGegenpruefDialog({
    super.key,
    required this.ergebnis,
  });

  final BelegScanErgebnis ergebnis;

  @override
  State<BelegScanGegenpruefDialog> createState() =>
      _BelegScanGegenpruefDialogState();
}

class _BelegScanGegenpruefDialogState
    extends State<BelegScanGegenpruefDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _zeigeScrollPfeil = false;

  static final NumberFormat _euroFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_aktualisiereScrollPfeil);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aktualisiereScrollPfeil();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _aktualisiereScrollPfeil() {
    if (!mounted || !_scrollController.hasClients) return;
    final bool zeige =
        _scrollController.position.maxScrollExtent > _scrollController.offset + 1.0;
    if (zeige != _zeigeScrollPfeil) {
      setState(() => _zeigeScrollPfeil = zeige);
    }
  }

  bool _istUnleserlich(String? wert) =>
      wert == null || wert.trim().toLowerCase() == 'unleserlich';

  bool get _hatUnleserlicheFelder {
    final BelegScanErgebnis e = widget.ergebnis;
    if (_istUnleserlich(e.terminalId)) return true;
    if (e.gesamtBetragCent == null) return true;
    for (final ZahlungsartErgebnis z in e.zahlungsarten) {
      if (z.betragCent == null || z.anzahl == null) return true;
    }
    return false;
  }

  String _formatCent(int cent) => _euroFormat.format(cent / 100.0);

  Widget _baueTerminalIdZeile() {
    final String? tid = widget.ergebnis.terminalId;
    final bool istRot = _istUnleserlich(tid);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 115,
            child: Text(
              'Terminal-ID',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(
            child: istRot
                ? Text(
                    '—',
                    style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                  )
                : Text(tid!, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _baueMetadatenZeile(String label, String? wert) {
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
          Expanded(
            child: wert != null
                ? Text(wert, style: const TextStyle(fontSize: 14))
                : Text(
                    'nicht verfügbar',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _baueZahlungsartZeile(ZahlungsartErgebnis z) {
    final bool artUnbekannt =
        z.art.isEmpty || z.art.toLowerCase() == 'unbekannt';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              artUnbekannt ? 'unbekannt' : z.art,
              style: TextStyle(
                fontSize: 14,
                color: artUnbekannt ? Colors.orange.shade700 : null,
                fontStyle: artUnbekannt ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              z.anzahl != null ? '${z.anzahl}' : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: z.anzahl == null ? Colors.red.shade700 : null,
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
                color: z.betragCent == null ? Colors.red.shade700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueGesamtZeile() {
    final BelegScanErgebnis e = widget.ergebnis;
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
              e.gesamtAnzahl?.toString() ?? '—',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: 104,
            child: Text(
              e.gesamtBetragCent != null
                  ? _formatCent(e.gesamtBetragCent!)
                  : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: e.gesamtBetragCent == null
                    ? Colors.red.shade700
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BelegScanErgebnis e = widget.ergebnis;

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
              child: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (_hatUnleserlicheFelder)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              border: Border.all(color: Colors.red.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.error_outline,
                                  size: 18,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Rote Felder nach dem Übernehmen bitte korrigieren.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!_hatUnleserlicheFelder && !e.istPlausibel)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              border: Border.all(
                                  color: const Color(0xFFFFC107)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 18,
                                  color: Color(0xFFF57F17),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF5D4037),
                                      ),
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text:
                                              'Die Kartenbeträge summieren sich nicht zum Gesamtbetrag – bitte nach ',
                                        ),
                                        TextSpan(
                                          text: 'Übernehmen',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: ' prüfen.'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _baueTerminalIdZeile(),
                        _baueMetadatenZeile('Datum', e.datum),
                        _baueMetadatenZeile('Uhrzeit', e.uhrzeit),
                        _baueMetadatenZeile('Beleg-Nr. von', e.belegNrVon),
                        _baueMetadatenZeile('Beleg-Nr. bis', e.belegNrBis),
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
                        for (final ZahlungsartErgebnis z in e.zahlungsarten)
                          _baueZahlungsartZeile(z),
                        const Divider(),
                        _baueGesamtZeile(),
                      ],
                    ),
                  ),
                  if (_zeigeScrollPfeil)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: IgnorePointer(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color(0x00FFFFFF),
                                Color(0xD0FFFFFF),
                              ],
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 4),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
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
                              ergebnis: widget.ergebnis,
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
