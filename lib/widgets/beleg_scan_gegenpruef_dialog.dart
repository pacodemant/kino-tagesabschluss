import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';

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
  bool _metadatenBearbeiten = false;
  bool _kartenlisteBearbeiten = false;
  bool _eingabeMitKomma = false;

  final TextEditingController _terminalIdController = TextEditingController();
  final TextEditingController _datumController = TextEditingController();
  final TextEditingController _uhrzeitController = TextEditingController();
  final TextEditingController _belegNrVonController = TextEditingController();
  final TextEditingController _belegNrBisController = TextEditingController();
  final FocusNode _terminalIdFocusNode = FocusNode();
  final FocusNode _datumFocusNode = FocusNode();
  final FocusNode _uhrzeitFocusNode = FocusNode();
  final FocusNode _belegNrVonFocusNode = FocusNode();
  final FocusNode _belegNrBisFocusNode = FocusNode();

  final List<TextEditingController> _zahlungsartAnzahlController =
      <TextEditingController>[];
  final List<TextEditingController> _zahlungsartBetragController =
      <TextEditingController>[];
  final List<FocusNode> _zahlungsartAnzahlFocusNode = <FocusNode>[];
  final List<FocusNode> _zahlungsartBetragFocusNode = <FocusNode>[];

  final TextEditingController _gesamtAnzahlController =
      TextEditingController();
  final TextEditingController _gesamtBetragController =
      TextEditingController();
  final FocusNode _gesamtAnzahlFocusNode = FocusNode();
  final FocusNode _gesamtBetragFocusNode = FocusNode();

  static final NumberFormat _euroFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    final BelegScanErgebnis e = widget.ergebnis;

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      if (mounted) {
        setState(() {
          _eingabeMitKomma = prefs.getBool('eingabe_mit_komma') ?? false;
        });
      }
    });

    _terminalIdController.text = e.terminalId ?? '';
    _datumController.text = e.datum ?? '';
    _uhrzeitController.text = e.uhrzeit ?? '';
    _belegNrVonController.text = e.belegNrVon ?? '';
    _belegNrBisController.text = e.belegNrBis ?? '';

    for (final ZahlungsartErgebnis z in e.zahlungsarten) {
      final TextEditingController anzahlController = TextEditingController(
        text: z.anzahl != null ? '${z.anzahl}' : '',
      );
      final TextEditingController betragController = TextEditingController(
        text: z.betragCent != null
            ? TagesabschlussFormatierung.formatiereEuroEingabe(z.betragCent!)
            : '',
      );
      anzahlController.addListener(_onChanged);
      betragController.addListener(_onChanged);
      _zahlungsartAnzahlController.add(anzahlController);
      _zahlungsartBetragController.add(betragController);
      _zahlungsartAnzahlFocusNode.add(FocusNode()..addListener(_onChanged));
      _zahlungsartBetragFocusNode.add(FocusNode()..addListener(_onChanged));
    }

    _gesamtAnzahlController.text =
        e.gesamtAnzahl != null ? '${e.gesamtAnzahl}' : '';
    _gesamtBetragController.text = e.gesamtBetragCent != null
        ? TagesabschlussFormatierung.formatiereEuroEingabe(e.gesamtBetragCent!)
        : '';

    for (final TextEditingController c in <TextEditingController>[
      _terminalIdController,
      _datumController,
      _uhrzeitController,
      _belegNrVonController,
      _belegNrBisController,
      _gesamtAnzahlController,
      _gesamtBetragController,
    ]) {
      c.addListener(_onChanged);
    }
    for (final FocusNode fn in <FocusNode>[
      _terminalIdFocusNode,
      _datumFocusNode,
      _uhrzeitFocusNode,
      _belegNrVonFocusNode,
      _belegNrBisFocusNode,
      _gesamtAnzahlFocusNode,
      _gesamtBetragFocusNode,
    ]) {
      fn.addListener(_onChanged);
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _terminalIdController.dispose();
    _datumController.dispose();
    _uhrzeitController.dispose();
    _belegNrVonController.dispose();
    _belegNrBisController.dispose();
    _terminalIdFocusNode.dispose();
    _datumFocusNode.dispose();
    _uhrzeitFocusNode.dispose();
    _belegNrVonFocusNode.dispose();
    _belegNrBisFocusNode.dispose();
    for (final TextEditingController c in _zahlungsartAnzahlController) {
      c.dispose();
    }
    for (final TextEditingController c in _zahlungsartBetragController) {
      c.dispose();
    }
    for (final FocusNode fn in _zahlungsartAnzahlFocusNode) {
      fn.dispose();
    }
    for (final FocusNode fn in _zahlungsartBetragFocusNode) {
      fn.dispose();
    }
    _gesamtAnzahlController.dispose();
    _gesamtBetragController.dispose();
    _gesamtAnzahlFocusNode.dispose();
    _gesamtBetragFocusNode.dispose();
    super.dispose();
  }

  bool get _hatUnleserlicheFelder {
    final BelegScanErgebnis e = widget.ergebnis;
    return e.terminalId == null ||
        e.gesamtBetragCent == null ||
        e.zahlungsarten.any(
          (ZahlungsartErgebnis z) => z.betragCent == null || z.anzahl == null,
        );
  }

  String? get _plausibilitaetsFehlertext {
    final BelegScanErgebnis e = widget.ergebnis;
    if (!e.betraegePlausibel) {
      return 'Summe der Zahlungsarten stimmt nicht mit dem Gesamtbetrag überein.';
    }
    if (!e.anzahlPlausibel) {
      return 'Summe der Anzahl stimmt nicht mit der Gesamtanzahl überein.';
    }
    return null;
  }

  bool get _kannUebernehmen {
    if (_terminalIdController.text.trim().isEmpty) return false;
    if (_parseBetragEingabe(_gesamtBetragController.text) == null) {
      return false;
    }
    for (int i = 0; i < _zahlungsartBetragController.length; i++) {
      if (_parseBetragEingabe(_zahlungsartBetragController[i].text) == null) {
        return false;
      }
      if (int.tryParse(_zahlungsartAnzahlController[i].text.trim()) == null) {
        return false;
      }
    }
    return true;
  }

  int? _parseBetragEingabe(String text) {
    if (text.trim().isEmpty) return null;
    return _eingabeMitKomma
        ? TagesabschlussBerechnung.parseCentKomma(text)
        : TagesabschlussBerechnung.parseCentZiffern(text);
  }

  String? _textOderNull(String text) =>
      text.trim().isEmpty ? null : text.trim();

  String _formatCent(int cent) => _euroFormat.format(cent / 100.0);

  BelegScanErgebnis _ergebnisMitManuellen() {
    final BelegScanErgebnis e = widget.ergebnis;
    final List<ZahlungsartErgebnis> zahlungsarten = <ZahlungsartErgebnis>[];
    for (int i = 0; i < e.zahlungsarten.length; i++) {
      zahlungsarten.add(ZahlungsartErgebnis(
        art: e.zahlungsarten[i].art,
        anzahl: int.tryParse(_zahlungsartAnzahlController[i].text.trim()),
        betragCent: _parseBetragEingabe(_zahlungsartBetragController[i].text),
      ));
    }
    final String terminalIdText = _terminalIdController.text.trim();
    return BelegScanErgebnis(
      terminalId:
          terminalIdText.isNotEmpty ? terminalIdText : 'nicht vorhanden/unleserlich',
      datum: _textOderNull(_datumController.text),
      uhrzeit: _textOderNull(_uhrzeitController.text),
      belegNrVon: _textOderNull(_belegNrVonController.text),
      belegNrBis: _textOderNull(_belegNrBisController.text),
      zahlungsarten: zahlungsarten,
      gesamtAnzahl: int.tryParse(_gesamtAnzahlController.text.trim()),
      gesamtBetragCent: _parseBetragEingabe(_gesamtBetragController.text),
      hinweis: e.hinweis,
    );
  }

  void _metadatenButtonGedrueckt() {
    setState(() => _metadatenBearbeiten = !_metadatenBearbeiten);
    if (_metadatenBearbeiten) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _terminalIdFocusNode.requestFocus();
      });
    }
  }

  void _kartenlisteButtonGedrueckt() {
    setState(() => _kartenlisteBearbeiten = !_kartenlisteBearbeiten);
    if (_kartenlisteBearbeiten) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_zahlungsartAnzahlFocusNode.isNotEmpty) {
          _zahlungsartAnzahlFocusNode.first.requestFocus();
        } else {
          _gesamtAnzahlFocusNode.requestFocus();
        }
      });
    }
  }

  Widget _baueHighlightFeld({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? hintText,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final double schriftgroesse = style?.fontSize ?? 14;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textAlign: textAlign,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: style ?? const TextStyle(fontSize: 14),
      scrollPadding: const EdgeInsets.only(bottom: 200),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: schriftgroesse),
        isDense: true,
        border: InputBorder.none,
        filled: focusNode.hasFocus,
        fillColor: const Color(0xFFFFF8E1),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
    );
  }

  Widget _baueBearbeitenButton({
    required bool bearbeiten,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          bearbeiten ? 'Fertig.' : 'manuell editieren',
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }

  Widget _baueMetadatenZeile(
    String label,
    String? originalWert,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final Widget wertWidget;
    if (_metadatenBearbeiten) {
      wertWidget = _baueHighlightFeld(
        controller: controller,
        focusNode: focusNode,
        hintText: 'Bitte eintragen',
      );
    } else if (originalWert != null) {
      wertWidget = Text(originalWert, style: const TextStyle(fontSize: 14));
    } else {
      wertWidget = Text(
        '—',
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

  List<TextInputFormatter> get _betragInputFormatters => _eingabeMitKomma
      ? <TextInputFormatter>[]
      : <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          CentWaehrungsEingabeFormatter(),
        ];

  TextInputType get _betragKeyboardType => _eingabeMitKomma
      ? const TextInputType.numberWithOptions(decimal: true)
      : TextInputType.number;

  Widget _baueZahlungsartZeile(int index, ZahlungsartErgebnis z) {
    final Widget anzahlWidget;
    final Widget betragWidget;
    if (_kartenlisteBearbeiten) {
      anzahlWidget = _baueHighlightFeld(
        controller: _zahlungsartAnzahlController[index],
        focusNode: _zahlungsartAnzahlFocusNode[index],
        textAlign: TextAlign.right,
        keyboardType: TextInputType.number,
        hintText: '—',
      );
      betragWidget = _baueHighlightFeld(
        controller: _zahlungsartBetragController[index],
        focusNode: _zahlungsartBetragFocusNode[index],
        textAlign: TextAlign.right,
        keyboardType: _betragKeyboardType,
        inputFormatters: _betragInputFormatters,
        hintText: '0,00',
      );
    } else {
      anzahlWidget = Text(
        z.anzahl != null ? '${z.anzahl}' : '—',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 14,
          color: z.anzahl == null ? Colors.orange.shade700 : null,
        ),
      );
      betragWidget = Text(
        z.betragCent != null ? _formatCent(z.betragCent!) : '—',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 14,
          color: z.betragCent == null ? Colors.orange.shade700 : null,
        ),
      );
    }
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
          SizedBox(width: 44, child: anzahlWidget),
          SizedBox(width: 104, child: betragWidget),
        ],
      ),
    );
  }

  Widget _baueGesamtZeile(BelegScanErgebnis e) {
    final Widget anzahlWidget;
    final Widget betragWidget;
    if (_kartenlisteBearbeiten) {
      anzahlWidget = _baueHighlightFeld(
        controller: _gesamtAnzahlController,
        focusNode: _gesamtAnzahlFocusNode,
        textAlign: TextAlign.right,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        hintText: '—',
      );
      betragWidget = _baueHighlightFeld(
        controller: _gesamtBetragController,
        focusNode: _gesamtBetragFocusNode,
        textAlign: TextAlign.right,
        keyboardType: _betragKeyboardType,
        inputFormatters: _betragInputFormatters,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        hintText: '0,00',
      );
    } else {
      anzahlWidget = Text(
        e.gesamtAnzahl?.toString() ?? '—',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: !e.anzahlPlausibel ? Colors.red.shade700 : null,
        ),
      );
      betragWidget = Text(
        e.gesamtBetragCent != null ? _formatCent(e.gesamtBetragCent!) : '—',
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
          SizedBox(width: 44, child: anzahlWidget),
          SizedBox(width: 104, child: betragWidget),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BelegScanErgebnis e = widget.ergebnis;
    final String? plausibilitaetsFehlertext = _plausibilitaetsFehlertext;

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
                      'EC-Beleg prüfen',
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
                        (e.hinweis != null && !e.istPlausibel))
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
                                e.hinweis ??
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
                    _baueMetadatenZeile(
                      'Terminal-ID',
                      e.terminalId,
                      _terminalIdController,
                      _terminalIdFocusNode,
                    ),
                    _baueMetadatenZeile(
                      'Datum',
                      e.datum,
                      _datumController,
                      _datumFocusNode,
                    ),
                    _baueMetadatenZeile(
                      'Uhrzeit',
                      e.uhrzeit,
                      _uhrzeitController,
                      _uhrzeitFocusNode,
                    ),
                    _baueMetadatenZeile(
                      'Beleg-Nr. von',
                      e.belegNrVon,
                      _belegNrVonController,
                      _belegNrVonFocusNode,
                    ),
                    _baueMetadatenZeile(
                      'Beleg-Nr. bis',
                      e.belegNrBis,
                      _belegNrBisController,
                      _belegNrBisFocusNode,
                    ),
                    _baueBearbeitenButton(
                      bearbeiten: _metadatenBearbeiten,
                      onPressed: _metadatenButtonGedrueckt,
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
                    _baueGesamtZeile(e),
                    if (plausibilitaetsFehlertext != null)
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
                            Expanded(
                              child: Text(
                                plausibilitaetsFehlertext,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _baueBearbeitenButton(
                      bearbeiten: _kartenlisteBearbeiten,
                      onPressed: _kartenlisteButtonGedrueckt,
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
                      onPressed: _kannUebernehmen
                          ? () => Navigator.of(context).pop(
                                BelegScanDialogErgebnis(
                                  ergebnis: _ergebnisMitManuellen(),
                                  kachelOeffnen: false,
                                ),
                              )
                          : null,
                      child: const Text('Übernehmen'),
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
