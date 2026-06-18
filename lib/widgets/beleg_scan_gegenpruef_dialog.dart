import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/services/zahlungsarten_config_service.dart';

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
  List<String> _verfuegbareArten = <String>[];
  List<String?> _gewaehlteArten = <String?>[];

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
    _ladeZahlungsarten();
  }

  Future<void> _ladeZahlungsarten() async {
    final List<String> arten = await ZahlungsartenConfigService.laden();
    if (!mounted) return;
    setState(() {
      _verfuegbareArten = arten;
      _gewaehlteArten = widget.ergebnis.zahlungsarten
          .map((ZahlungsartErgebnis z) =>
              arten.contains(z.art) ? z.art : null)
          .toList();
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

  bool get _hatUnleserlicheFelder {
    return widget.ergebnis.terminalId == null ||
        widget.ergebnis.gesamtBetragCent == null ||
        widget.ergebnis.zahlungsarten.any(
          (ZahlungsartErgebnis z) => z.betragCent == null || z.anzahl == null,
        );
  }

  String _formatCent(int cent) => _euroFormat.format(cent / 100.0);

  List<String> _optionenFuerZeile(int index) {
    final Set<String> bereits = _gewaehlteArten
        .asMap()
        .entries
        .where((MapEntry<int, String?> e) => e.key != index && e.value != null)
        .map((MapEntry<int, String?> e) => e.value!)
        .toSet();
    return _verfuegbareArten
        .where((String a) => !bereits.contains(a))
        .toList();
  }

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

  Widget _baueZahlungsartZeile(ZahlungsartErgebnis z, int index) {
    final bool zeigeDropdown =
        z.art.isEmpty && _verfuegbareArten.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: zeigeDropdown
                ? DropdownButton<String?>(
                    value: _gewaehlteArten.length > index
                        ? _gewaehlteArten[index]
                        : null,
                    hint: const Text('—', style: TextStyle(fontSize: 14)),
                    isExpanded: true,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87),
                    items: _optionenFuerZeile(index)
                        .map((String art) => DropdownMenuItem<String?>(
                              value: art,
                              child: Text(art),
                            ))
                        .toList(),
                    onChanged: (String? wert) {
                      setState(() => _gewaehlteArten[index] = wert);
                    },
                  )
                : Text(
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
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: !e.anzahlPlausibel ? Colors.red.shade700 : null,
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
                color: !e.betraegePlausibel ? Colors.red.shade700 : null,
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
                              border:
                                  Border.all(color: const Color(0xFFFFC107)),
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
                                  child: Text.rich(
                                    TextSpan(
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF5D4037),
                                      ),
                                      children: e.hinweis != null
                                          ? <InlineSpan>[
                                              TextSpan(text: e.hinweis),
                                            ]
                                          : const <InlineSpan>[
                                              TextSpan(
                                                text:
                                                    'Bitte die markierten Felder nach ',
                                              ),
                                              TextSpan(
                                                text: 'Übernehmen',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              TextSpan(
                                                  text: ' ggf. manuell prüfen.'),
                                            ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _baueMetadatenZeile('Terminal-ID', e.terminalId),
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
                          onPressed: () {
                            final BelegScanErgebnis e = widget.ergebnis;
                            final List<ZahlungsartErgebnis> korrigiert =
                                List<ZahlungsartErgebnis>.generate(
                              e.zahlungsarten.length,
                              (int i) {
                                final ZahlungsartErgebnis z =
                                    e.zahlungsarten[i];
                                return ZahlungsartErgebnis(
                                  art: z.art.isEmpty &&
                                          _gewaehlteArten.length > i
                                      ? (_gewaehlteArten[i] ?? '')
                                      : z.art,
                                  anzahl: z.anzahl,
                                  betragCent: z.betragCent,
                                );
                              },
                            );
                            Navigator.of(context).pop(
                              BelegScanDialogErgebnis(
                                ergebnis: BelegScanErgebnis(
                                  keinTerminalBeleg: e.keinTerminalBeleg,
                                  terminalId: e.terminalId,
                                  datum: e.datum,
                                  uhrzeit: e.uhrzeit,
                                  belegNrVon: e.belegNrVon,
                                  belegNrBis: e.belegNrBis,
                                  zahlungsarten: korrigiert,
                                  gesamtAnzahl: e.gesamtAnzahl,
                                  gesamtBetragCent: e.gesamtBetragCent,
                                  hinweis: e.hinweis,
                                ),
                                kachelOeffnen: false,
                              ),
                            );
                          },
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
