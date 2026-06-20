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

  // Lokal veränderliche Kopien für Inline-Korrekturen
  String? _terminalId;
  int? _gesamtBetragCent;
  late List<int?> _zahlungsartenBetragCent;
  late List<int?> _zahlungsartenAnzahl;

  // Inline-Edit-Zustand
  String? _editiertesfeld;
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();

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

    final BelegScanErgebnis e = widget.ergebnis;
    _terminalId = e.terminalId;
    _gesamtBetragCent = e.gesamtBetragCent;
    _zahlungsartenBetragCent =
        e.zahlungsarten.map((ZahlungsartErgebnis z) => z.betragCent).toList();
    _zahlungsartenAnzahl =
        e.zahlungsarten.map((ZahlungsartErgebnis z) => z.anzahl).toList();

    _editFocusNode.addListener(() {
      if (!_editFocusNode.hasFocus) {
        _bestaetigenEdit();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _editController.dispose();
    _editFocusNode.dispose();
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
    if (_istUnleserlich(_terminalId)) return true;
    if (_gesamtBetragCent == null) return true;
    for (int i = 0; i < _zahlungsartenBetragCent.length; i++) {
      if (_zahlungsartenBetragCent[i] == null) return true;
      if (_zahlungsartenAnzahl[i] == null) return true;
    }
    return false;
  }

  void _startEdit(String feld, String initialWert) {
    setState(() {
      _editiertesfeld = feld;
      _editController.text = initialWert;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
      _editController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _editController.text.length,
      );
    });
  }

  void _bestaetigenEdit() {
    if (_editiertesfeld == null) return;
    final String feld = _editiertesfeld!;
    final String wert = _editController.text.trim();

    setState(() {
      _editiertesfeld = null;
      if (feld == 'terminalId') {
        _terminalId = wert.isEmpty ? null : wert;
      } else if (feld == 'gesamt_betrag') {
        _gesamtBetragCent = _parseCent(wert);
      } else {
        final List<String> teile = feld.split('_');
        if (teile.length == 3 && teile[0] == 'za') {
          final int idx = int.tryParse(teile[1]) ?? -1;
          if (idx >= 0) {
            if (teile[2] == 'betrag') {
              _zahlungsartenBetragCent[idx] = _parseCent(wert);
            } else if (teile[2] == 'anzahl') {
              _zahlungsartenAnzahl[idx] = int.tryParse(wert);
            }
          }
        }
      }
    });
  }

  int? _parseCent(String wert) {
    if (wert.isEmpty) return null;
    final String bereinigt = wert
        .replaceAll('€', '')
        .replaceAll(' ', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final double? betrag = double.tryParse(bereinigt);
    if (betrag == null) return null;
    return (betrag * 100).round();
  }

  String _formatCent(int cent) => _euroFormat.format(cent / 100.0);

  Widget _inlineEingabefeld({TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 28,
      child: TextField(
        controller: _editController,
        focusNode: _editFocusNode,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        onSubmitted: (_) => _bestaetigenEdit(),
      ),
    );
  }

  Widget _baueMetadatenZeile(String label, String? wert, {String? feldKey}) {
    Widget wertWidget;

    if (feldKey != null && _editiertesfeld == feldKey) {
      wertWidget = _inlineEingabefeld();
    } else if (feldKey != null && _istUnleserlich(wert)) {
      wertWidget = GestureDetector(
        onTap: () => _startEdit(feldKey, ''),
        child: Text(
          'unleserlich – tippen zum Korrigieren',
          style: TextStyle(
            fontSize: 13,
            color: Colors.red.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    } else if (wert != null) {
      wertWidget = Text(wert, style: const TextStyle(fontSize: 14));
    } else {
      wertWidget = Text(
        'nicht verfügbar',
        style: TextStyle(
          fontSize: 13,
          color: Colors.orange.shade700,
          fontStyle: FontStyle.italic,
        ),
      );
    }

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

  Widget _baueZahlungsartZeile(ZahlungsartErgebnis z, int index) {
    final bool artUnbekannt =
        z.art.isEmpty || z.art.toLowerCase() == 'unbekannt';

    final int? lokalBetrag = _zahlungsartenBetragCent[index];
    final int? lokalAnzahl = _zahlungsartenAnzahl[index];
    final String betragFeld = 'za_${index}_betrag';
    final String anzahlFeld = 'za_${index}_anzahl';

    Widget anzahlWidget;
    if (_editiertesfeld == anzahlFeld) {
      anzahlWidget = _inlineEingabefeld(keyboardType: TextInputType.number);
    } else if (lokalAnzahl == null) {
      anzahlWidget = GestureDetector(
        onTap: () => _startEdit(anzahlFeld, ''),
        child: Text(
          '—',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14, color: Colors.red.shade700),
        ),
      );
    } else {
      anzahlWidget = Text(
        '$lokalAnzahl',
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 14),
      );
    }

    Widget betragWidget;
    if (_editiertesfeld == betragFeld) {
      betragWidget = _inlineEingabefeld(
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
      );
    } else if (lokalBetrag == null) {
      betragWidget = GestureDetector(
        onTap: () => _startEdit(betragFeld, ''),
        child: Text(
          '—',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14, color: Colors.red.shade700),
        ),
      );
    } else {
      betragWidget = Text(
        _formatCent(lokalBetrag),
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 14),
      );
    }

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
                fontStyle:
                    artUnbekannt ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          SizedBox(width: 44, child: anzahlWidget),
          SizedBox(width: 104, child: betragWidget),
        ],
      ),
    );
  }

  Widget _baueGesamtZeile() {
    final BelegScanErgebnis e = widget.ergebnis;
    const String gesamtBetragFeld = 'gesamt_betrag';

    Widget gesamtBetragWidget;
    if (_editiertesfeld == gesamtBetragFeld) {
      gesamtBetragWidget = _inlineEingabefeld(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
    } else if (_gesamtBetragCent == null) {
      gesamtBetragWidget = GestureDetector(
        onTap: () => _startEdit(gesamtBetragFeld, ''),
        child: Text(
          '—',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.red.shade700,
          ),
        ),
      );
    } else {
      gesamtBetragWidget = Text(
        _formatCent(_gesamtBetragCent!),
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: !e.betraegePlausibel ? Colors.red.shade700 : null,
        ),
      );
    }

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
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: !e.anzahlPlausibel ? Colors.red.shade700 : null,
              ),
            ),
          ),
          SizedBox(width: 104, child: gesamtBetragWidget),
        ],
      ),
    );
  }

  BelegScanErgebnis _erstelleKorrigiertes() {
    final BelegScanErgebnis e = widget.ergebnis;
    final List<ZahlungsartErgebnis> korrigiert = <ZahlungsartErgebnis>[];
    for (int i = 0; i < e.zahlungsarten.length; i++) {
      korrigiert.add(ZahlungsartErgebnis(
        art: e.zahlungsarten[i].art,
        anzahl: _zahlungsartenAnzahl[i],
        betragCent: _zahlungsartenBetragCent[i],
      ));
    }
    return BelegScanErgebnis(
      keinTerminalBeleg: e.keinTerminalBeleg,
      terminalId: _terminalId,
      datum: e.datum,
      uhrzeit: e.uhrzeit,
      belegNrVon: e.belegNrVon,
      belegNrBis: e.belegNrBis,
      zahlungsarten: korrigiert,
      gesamtAnzahl: e.gesamtAnzahl,
      gesamtBetragCent: _gesamtBetragCent,
      hinweis: e.hinweis,
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
                                    'Rote Felder bitte korrigieren.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!_hatUnleserlicheFelder &&
                            e.hinweis != null &&
                            !e.istPlausibel)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              border:
                                  Border.all(color: const Color(0xFFFFC107)),
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
                        _baueMetadatenZeile(
                          'Terminal-ID',
                          _terminalId,
                          feldKey: 'terminalId',
                        ),
                        _baueMetadatenZeile('Datum', e.datum),
                        _baueMetadatenZeile('Uhrzeit', e.uhrzeit),
                        _baueMetadatenZeile('Beleg-Nr. von', e.belegNrVon),
                        _baueMetadatenZeile('Beleg-Nr. bis', e.belegNrBis),
                        const SizedBox(height: 10),
                        const Divider(),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 4, top: 2),
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
                          _baueZahlungsartZeile(e.zahlungsarten[i], i),
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
                              ergebnis: _erstelleKorrigiertes(),
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
