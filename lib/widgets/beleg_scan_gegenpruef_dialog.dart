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
  TextEditingController? _terminalIdController;
  TextEditingController? _belegNrVonController;
  TextEditingController? _belegNrBisController;
  TextEditingController? _uhrzeitController;
  TextEditingController? _gesamtBetragController;
  final List<TextEditingController?> _zahlungsartBetragController =
      <TextEditingController?>[];

  static final NumberFormat _euroFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    final BelegScanErgebnis e = widget.ergebnis;
    if (e.terminalId == null) {
      _terminalIdController = TextEditingController()
        ..addListener(_onChanged);
    }
    if (e.belegNrVon == null) {
      _belegNrVonController = TextEditingController()
        ..addListener(_onChanged);
    }
    if (e.belegNrBis == null) {
      _belegNrBisController = TextEditingController()
        ..addListener(_onChanged);
    }
    if (e.uhrzeit == null) {
      _uhrzeitController = TextEditingController()
        ..addListener(_onChanged);
    }
    if (e.gesamtBetragCent == null) {
      _gesamtBetragController = TextEditingController()
        ..addListener(_onChanged);
    }
    for (final ZahlungsartErgebnis z in e.zahlungsarten) {
      if (z.betragCent == null) {
        _zahlungsartBetragController.add(
          TextEditingController()..addListener(_onChanged),
        );
      } else {
        _zahlungsartBetragController.add(null);
      }
    }
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _terminalIdController?.dispose();
    _belegNrVonController?.dispose();
    _belegNrBisController?.dispose();
    _uhrzeitController?.dispose();
    _gesamtBetragController?.dispose();
    for (final TextEditingController? c in _zahlungsartBetragController) {
      c?.dispose();
    }
    super.dispose();
  }

  bool get _allePflichtfelderAusgefuellt {
    if (_terminalIdController?.text.trim().isEmpty ?? false) return false;
    if (_belegNrVonController?.text.trim().isEmpty ?? false) return false;
    if (_belegNrBisController?.text.trim().isEmpty ?? false) return false;
    if (_uhrzeitController?.text.trim().isEmpty ?? false) return false;
    if (_gesamtBetragController?.text.trim().isEmpty ?? false) return false;
    for (final TextEditingController? c in _zahlungsartBetragController) {
      if (c != null && c.text.trim().isEmpty) return false;
    }
    return true;
  }

  int? _parseEuroToCent(String text) {
    final String cleaned = text
        .trim()
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll('€', '');
    final double? value = double.tryParse(cleaned);
    if (value == null) return null;
    return (value * 100).round();
  }

  String _formatCent(int cent) => _euroFormat.format(cent / 100.0);

  BelegScanErgebnis _ergebnisMitManuellen() {
    final BelegScanErgebnis e = widget.ergebnis;
    final List<ZahlungsartErgebnis> zahlungsarten = <ZahlungsartErgebnis>[];
    for (int i = 0; i < e.zahlungsarten.length; i++) {
      final ZahlungsartErgebnis z = e.zahlungsarten[i];
      final int? betrag;
      if (z.betragCent != null) {
        betrag = z.betragCent;
      } else {
        final TextEditingController? c =
            i < _zahlungsartBetragController.length
                ? _zahlungsartBetragController[i]
                : null;
        betrag = c != null ? _parseEuroToCent(c.text) : null;
      }
      zahlungsarten.add(ZahlungsartErgebnis(
        art: z.art,
        anzahl: z.anzahl,
        betragCent: betrag,
      ));
    }
    return BelegScanErgebnis(
      terminalId: e.terminalId ?? _terminalIdController?.text.trim(),
      datum: e.datum,
      uhrzeit: e.uhrzeit ?? _uhrzeitController?.text.trim(),
      belegNrVon: e.belegNrVon ?? _belegNrVonController?.text.trim(),
      belegNrBis: e.belegNrBis ?? _belegNrBisController?.text.trim(),
      zahlungsarten: zahlungsarten,
      gesamtAnzahl: e.gesamtAnzahl,
      gesamtBetragCent: e.gesamtBetragCent ??
          (_gesamtBetragController != null
              ? _parseEuroToCent(_gesamtBetragController!.text)
              : null),
      hinweis: e.hinweis,
    );
  }

  Widget _baueInfoZeile(
    String label,
    String? wert, {
    TextEditingController? controller,
  }) {
    final bool hatController = controller != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
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
                        hatController ? 'unleserlich' : '—',
                        style: TextStyle(
                          fontSize: 14,
                          color: hatController
                              ? Colors.orange.shade700
                              : Colors.black54,
                          fontStyle: hatController
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
              ),
            ],
          ),
          if (wert == null && controller != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 115),
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Bitte manuell eintragen',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _baueZahlungsartZeile(int index, ZahlungsartErgebnis z) {
    final bool betragNull = z.betragCent == null;
    final TextEditingController? c =
        index < _zahlungsartBetragController.length
            ? _zahlungsartBetragController[index]
            : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
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
                  '${z.anzahl}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(
                width: 104,
                child: betragNull
                    ? Text(
                        'unleserlich',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Text(
                        _formatCent(z.betragCent!),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14),
                      ),
              ),
            ],
          ),
          if (betragNull && c != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextField(
                controller: c,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Bitte manuell eintragen',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _baueGesamtZeile(BelegScanErgebnis e, bool istPlausibel) {
    final bool gesamtNull = e.gesamtBetragCent == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
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
                child: gesamtNull
                    ? Text(
                        'unleserlich',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Text(
                        _formatCent(e.gesamtBetragCent!),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color:
                              !istPlausibel ? Colors.red.shade700 : null,
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (gesamtNull && _gesamtBetragController != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: TextField(
              controller: _gesamtBetragController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Bitte manuell eintragen',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final BelegScanErgebnis e = widget.ergebnis;
    final bool istPlausibel = e.istPlausibel;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: const <Widget>[
                  Icon(Icons.receipt_long_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'EC-Beleg prüfen',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
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
                    if (e.hinweis != null)
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
                                e.hinweis!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _baueInfoZeile(
                      'Terminal-ID',
                      e.terminalId,
                      controller: _terminalIdController,
                    ),
                    _baueInfoZeile('Datum', e.datum),
                    _baueInfoZeile(
                      'Uhrzeit',
                      e.uhrzeit,
                      controller: _uhrzeitController,
                    ),
                    _baueInfoZeile(
                      'Beleg-Nr. von',
                      e.belegNrVon,
                      controller: _belegNrVonController,
                    ),
                    _baueInfoZeile(
                      'Beleg-Nr. bis',
                      e.belegNrBis,
                      controller: _belegNrBisController,
                    ),
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
                    for (int i = 0; i < e.zahlungsarten.length; i++)
                      _baueZahlungsartZeile(i, e.zahlungsarten[i]),
                    const Divider(),
                    _baueGesamtZeile(e, istPlausibel),
                    if (!istPlausibel)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
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
                            const Expanded(
                              child: Text(
                                'Summe der Zahlungsarten stimmt nicht mit dem Gesamtbetrag überein.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Abbrechen'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _allePflichtfelderAusgefuellt
                          ? () => Navigator.of(context)
                              .pop(_ergebnisMitManuellen())
                          : null,
                      child: const Text('Bestätigen'),
                    ),
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
