import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';

class TagesabschlussSchritt2Argumente {
  const TagesabschlussSchritt2Argumente({
    required this.kinoId,
    required this.kinoName,
    required this.scheineCent,
    required this.loseMuenzenCent,
    required this.rollenCent,
    required this.umschlaegeCent,
    required this.wechselgeldSollwertCent,
    required this.barBestandAbzglWechselgeldCent,
  });

  final String kinoId;
  final String kinoName;
  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int wechselgeldSollwertCent;
  final int barBestandAbzglWechselgeldCent;
}

class TagesabschlussSchritt2Seite extends StatefulWidget {
  const TagesabschlussSchritt2Seite({
    super.key,
    required this.kinoId,
    required this.kinoName,
    required this.scheineCent,
    required this.loseMuenzenCent,
    required this.rollenCent,
    required this.umschlaegeCent,
    required this.wechselgeldSollwertCent,
    required this.barBestandAbzglWechselgeldCent,
  });

  static const String routenName = '/closure-step-2';

  final String kinoId;
  final String kinoName;
  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int wechselgeldSollwertCent;
  final int barBestandAbzglWechselgeldCent;

  @override
  State<TagesabschlussSchritt2Seite> createState() =>
      _TagesabschlussSchritt2SeiteState();
}

class _TagesabschlussSchritt2SeiteState
    extends State<TagesabschlussSchritt2Seite> {
  final TextEditingController _kinoSollController = TextEditingController();
  final TextEditingController _bistroSollController = TextEditingController();
  final TextEditingController _ausgabenController = TextEditingController();
  final TextEditingController _differenzAnfangsbestandController =
      TextEditingController();
  final FocusNode _kinoSollFocusNode = FocusNode();
  final FocusNode _bistroSollFocusNode = FocusNode();
  final FocusNode _ausgabenFocusNode = FocusNode();
  final FocusNode _differenzAnfangsbestandFocusNode = FocusNode();
  final List<TextEditingController> _ecBelegController =
      <TextEditingController>[TextEditingController()];
  final List<FocusNode> _ecBelegFocusNode = <FocusNode>[];

  int _kinoSollCent = 0;
  int _bistroSollCent = 0;
  int _ausgabenCent = 0;
  int _differenzAnfangsbestandCent = 0;
  final List<int> _ecBelegeCent = <int>[0];

  @override
  void initState() {
    super.initState();
    _kinoSollFocusNode.addListener(_beiFokusGeaendert);
    _bistroSollFocusNode.addListener(_beiFokusGeaendert);
    _ausgabenFocusNode.addListener(_beiFokusGeaendert);
    _differenzAnfangsbestandFocusNode.addListener(_beiFokusGeaendert);
    final FocusNode ersterEcFocusNode = FocusNode()
      ..addListener(_beiFokusGeaendert);
    _ecBelegFocusNode.add(ersterEcFocusNode);
  }

  @override
  void dispose() {
    _kinoSollController.dispose();
    _bistroSollController.dispose();
    _ausgabenController.dispose();
    _differenzAnfangsbestandController.dispose();
    _kinoSollFocusNode.removeListener(_beiFokusGeaendert);
    _bistroSollFocusNode.removeListener(_beiFokusGeaendert);
    _ausgabenFocusNode.removeListener(_beiFokusGeaendert);
    _differenzAnfangsbestandFocusNode.removeListener(_beiFokusGeaendert);
    _kinoSollFocusNode.dispose();
    _bistroSollFocusNode.dispose();
    _ausgabenFocusNode.dispose();
    _differenzAnfangsbestandFocusNode.dispose();
    for (final TextEditingController controller in _ecBelegController) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _ecBelegFocusNode) {
      focusNode.removeListener(_beiFokusGeaendert);
      focusNode.dispose();
    }
    super.dispose();
  }

  int _parseCentZiffern(String wert) {
    return TagesabschlussBerechnung.parseCentZiffern(wert);
  }

  String _formatiereEuro(int cent) {
    return TagesabschlussFormatierung.formatiereEuro(cent);
  }

  String _formatiereEuroMitVorzeichen(int cent) {
    return TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);
  }

  int get _ecUmsatzGesamtCent {
    return TagesabschlussBerechnung.summeCentBetraege(_ecBelegeCent);
  }

  int get _gesamtSollCent => TagesabschlussBerechnung.gesamtSollCent(
    kinoSollCent: _kinoSollCent,
    bistroSollCent: _bistroSollCent,
    ausgabenCent: _ausgabenCent,
  );

  int get _gesamtIstCent => TagesabschlussBerechnung.gesamtIstCent(
    ecUmsatzGesamtCent: _ecUmsatzGesamtCent,
    barBestandAbzglWechselgeldCent: widget.barBestandAbzglWechselgeldCent,
  );

  int get _differenzTagesabschlussCent =>
      TagesabschlussBerechnung.differenzTagesabschlussCent(
        gesamtIstCent: _gesamtIstCent,
        gesamtSollCent: _gesamtSollCent,
      );

  String _heutigesDatumString() {
    return TagesabschlussFormatierung.deutschesDatum(DateTime.now());
  }

  void _zeigeUmschlagVoransicht() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogKontext) {
        return UmschlagVoransichtDialog(
          kinoName: widget.kinoName,
          datum: _heutigesDatumString(),
          kinoSollCent: _kinoSollCent,
          bistroSollCent: _bistroSollCent,
          ausgabenCent: _ausgabenCent,
          gesamtSollCent: _gesamtSollCent,
          ecIstCent: _ecUmsatzGesamtCent,
          barIstCent: widget.barBestandAbzglWechselgeldCent,
          gesamtIstCent: _gesamtIstCent,
          differenzCent: _differenzTagesabschlussCent,
          differenzAnfangsbestandCent: _differenzAnfangsbestandCent,
        );
      },
    );
  }

  void _weiterZuSchritt3() {
    Navigator.of(context).pushNamed(
      TagesabschlussSchritt3Seite.routenName,
      arguments: TagesabschlussSchritt3Argumente(
        kinoId: widget.kinoId,
        kinoName: widget.kinoName,
        scheineCent: widget.scheineCent,
        loseMuenzenCent: widget.loseMuenzenCent,
        rollenCent: widget.rollenCent,
        umschlaegeCent: widget.umschlaegeCent,
        wechselgeldSollwertCent: widget.wechselgeldSollwertCent,
        kinoSollCent: _kinoSollCent,
        bistroSollCent: _bistroSollCent,
        ausgabenCent: _ausgabenCent,
        ecBelegeCent: List<int>.from(_ecBelegeCent),
        differenzAnfangsbestandCent: _differenzAnfangsbestandCent,
      ),
    );
  }

  void _ecBelegHinzufuegen() {
    setState(() {
      _ecBelegController.add(TextEditingController());
      final FocusNode focusNode = FocusNode()..addListener(_beiFokusGeaendert);
      _ecBelegFocusNode.add(focusNode);
      _ecBelegeCent.add(0);
    });
  }

  void _ecBelegEntfernen(int index) {
    if (_ecBelegController.length <= 1 ||
        index < 0 ||
        index >= _ecBelegController.length) {
      return;
    }
    setState(() {
      _ecBelegController.removeAt(index).dispose();
      final FocusNode focusNode = _ecBelegFocusNode.removeAt(index);
      focusNode.removeListener(_beiFokusGeaendert);
      focusNode.dispose();
      _ecBelegeCent.removeAt(index);
    });
  }

  List<FocusNode> _fokusReihenfolgeSchritt2() {
    return <FocusNode>[
      _kinoSollFocusNode,
      _bistroSollFocusNode,
      _ausgabenFocusNode,
      ..._ecBelegFocusNode,
      _differenzAnfangsbestandFocusNode,
    ];
  }

  bool _istLetztesFeldSchritt2(FocusNode focusNode) {
    final List<FocusNode> reihenfolge = _fokusReihenfolgeSchritt2();
    return reihenfolge.isNotEmpty && identical(reihenfolge.last, focusNode);
  }

  void _beiFokusGeaendert() {
    if (mounted) {
      setState(() {});
    }
  }

  FocusNode? _naechstesFeldSchritt2(FocusNode focusNode) {
    final List<FocusNode> reihenfolge = _fokusReihenfolgeSchritt2();
    final int index = reihenfolge.indexWhere(
      (FocusNode kandidat) => identical(kandidat, focusNode),
    );
    if (index < 0 || index >= reihenfolge.length - 1) {
      return null;
    }
    return reihenfolge[index + 1];
  }

  TextInputAction _textInputActionFuerSchritt2(FocusNode focusNode) {
    return _istLetztesFeldSchritt2(focusNode)
        ? TextInputAction.done
        : TextInputAction.next;
  }

  void _beiEingabeAbgeschlossenSchritt2(FocusNode focusNode) {
    final FocusNode? naechstesFeld = _naechstesFeldSchritt2(focusNode);
    if (naechstesFeld == null) {
      FocusScope.of(context).unfocus();
      return;
    }
    FocusScope.of(context).requestFocus(naechstesFeld);
  }

  FocusNode? _aktivesFeldSchritt2() {
    for (final FocusNode focusNode in _fokusReihenfolgeSchritt2()) {
      if (focusNode.hasFocus) {
        return focusNode;
      }
    }
    return null;
  }

  Widget _baueIosTastaturLeiste() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }
    final double tastaturHoehe = MediaQuery.of(context).viewInsets.bottom;
    if (tastaturHoehe <= 0) {
      return const SizedBox.shrink();
    }
    final FocusNode? aktivesFeld = _aktivesFeldSchritt2();
    if (aktivesFeld == null) {
      return const SizedBox.shrink();
    }
    final FocusNode? naechstesFeld = _naechstesFeldSchritt2(aktivesFeld);
    final bool istLetztesFeld = naechstesFeld == null;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        border: const Border(top: BorderSide(color: Color(0x14000000))),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            if (istLetztesFeld) {
              FocusScope.of(context).unfocus();
              return;
            }
            FocusScope.of(context).requestFocus(naechstesFeld);
          },
          child: Text(istLetztesFeld ? 'Fertig' : 'nächstes Feld'),
        ),
      ),
    );
  }

  Widget _baueEingabeZeile({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required FocusNode focusNode,
    bool optional = false,
    bool zeigeLoeschen = false,
    VoidCallback? onLoeschen,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              optional ? '$label (optional)' : label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 170,
            child: BetragCentEingabefeld(
              textController: controller,
              focusNode: focusNode,
              textInputAction: _textInputActionFuerSchritt2(focusNode),
              onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt2(focusNode),
              onChanged: onChanged,
              schriftgroesse: 20,
              hinweisText: '0,00 €',
            ),
          ),
          if (zeigeLoeschen) ...<Widget>[
            const SizedBox(width: 6),
            IconButton(
              onPressed: onLoeschen,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'EC-Beleg entfernen',
            ),
          ],
        ],
      ),
    );
  }

  Widget _baueBerechneteZeile({
    required String label,
    required String wert,
    bool hervorheben = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              wert,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20,
                fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w600,
                color: hervorheben && _differenzTagesabschlussCent < 0
                    ? Colors.red
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
    final bool istTastaturSichtbar =
        MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tagesabschluss – Schritt 2/4: Einnahmen/Abschluss'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: <Widget>[
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: <Widget>[
                  Text(
                    'Kino: ${widget.kinoName} (${widget.kinoId})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hinweis: „SOLL“ ist hier nur eine Bezeichnung für abgelesene Umsätze.',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _baueEingabeZeile(
                            label: 'Kino SOLL',
                            controller: _kinoSollController,
                            focusNode: _kinoSollFocusNode,
                            onChanged: (String wert) {
                              setState(() {
                                _kinoSollCent = _parseCentZiffern(wert);
                              });
                            },
                          ),
                          _baueEingabeZeile(
                            label: 'Bistro SOLL',
                            controller: _bistroSollController,
                            focusNode: _bistroSollFocusNode,
                            onChanged: (String wert) {
                              setState(() {
                                _bistroSollCent = _parseCentZiffern(wert);
                              });
                            },
                          ),
                          _baueEingabeZeile(
                            label: 'Ausgaben',
                            controller: _ausgabenController,
                            focusNode: _ausgabenFocusNode,
                            optional: true,
                            onChanged: (String wert) {
                              setState(() {
                                _ausgabenCent = _parseCentZiffern(wert);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (int i = 0; i < _ecBelegController.length; i++)
                            _baueEingabeZeile(
                              label: 'EC Beleg ${i + 1}',
                              controller: _ecBelegController[i],
                              focusNode: _ecBelegFocusNode[i],
                              optional: i > 0,
                              zeigeLoeschen: i > 0,
                              onLoeschen: () => _ecBelegEntfernen(i),
                              onChanged: (String wert) {
                                setState(() {
                                  _ecBelegeCent[i] = _parseCentZiffern(wert);
                                });
                              },
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: _ecBelegHinzufuegen,
                              icon: const Icon(Icons.add),
                              label: const Text('+ EC-Beleg hinzufügen'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[
                          _baueBerechneteZeile(
                            label: 'Gesamt SOLL',
                            wert: _formatiereEuro(_gesamtSollCent),
                          ),
                          _baueBerechneteZeile(
                            label: 'EC Umsatz',
                            wert: _formatiereEuro(_ecUmsatzGesamtCent),
                          ),
                          _baueBerechneteZeile(
                            label: 'BAR Bestand abzgl. Wechselgeld',
                            wert: _formatiereEuro(
                              widget.barBestandAbzglWechselgeldCent,
                            ),
                          ),
                          _baueBerechneteZeile(
                            label: 'Gesamt IST',
                            wert: _formatiereEuro(_gesamtIstCent),
                          ),
                          _baueBerechneteZeile(
                            label: 'Differenz Tagesabschluss',
                            wert: _formatiereEuroMitVorzeichen(
                              _differenzTagesabschlussCent,
                            ),
                            hervorheben: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[
                          _baueEingabeZeile(
                            label: 'Differenz im Anfangsbestand',
                            controller: _differenzAnfangsbestandController,
                            focusNode: _differenzAnfangsbestandFocusNode,
                            optional: true,
                            onChanged: (String wert) {
                              setState(() {
                                _differenzAnfangsbestandCent =
                                    _parseCentZiffern(wert);
                              });
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Info: ${_formatiereEuro(_differenzAnfangsbestandCent)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!istTastaturSichtbar) ...<Widget>[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _zeigeUmschlagVoransicht,
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('Übertrag auf Umschlag'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _weiterZuSchritt3,
                        child: const Text('Weiter zu Schritt 3'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _baueIosTastaturLeiste(),
            ),
          ],
        ),
      ),
    );
  }
}

class UmschlagVoransichtDialog extends StatelessWidget {
  const UmschlagVoransichtDialog({
    super.key,
    required this.kinoName,
    required this.datum,
    required this.kinoSollCent,
    required this.bistroSollCent,
    required this.ausgabenCent,
    required this.gesamtSollCent,
    required this.ecIstCent,
    required this.barIstCent,
    required this.gesamtIstCent,
    required this.differenzCent,
    required this.differenzAnfangsbestandCent,
  });

  final String kinoName;
  final String datum;
  final int kinoSollCent;
  final int bistroSollCent;
  final int ausgabenCent;
  final int gesamtSollCent;
  final int ecIstCent;
  final int barIstCent;
  final int gesamtIstCent;
  final int differenzCent;
  final int differenzAnfangsbestandCent;

  String _formatiereEuro(int cent) {
    return TagesabschlussFormatierung.formatiereEuro(cent);
  }

  String _formatiereEuroMitVorzeichen(int cent) {
    return TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);
  }

  Widget _baueZeile({
    required String label,
    required String wert,
    bool hervorheben = false,
    Color? wertFarbe,
    bool kursiv = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w500,
                fontStyle: kursiv ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(
              wert,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 18,
                fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w600,
                color: wertFarbe,
                fontStyle: kursiv ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size bildschirm = MediaQuery.sizeOf(context);
    final bool istPortrait = bildschirm.height > bildschirm.width;
    const double umschlagMaxBreite = 680;
    const double umschlagLayoutHoehe = 360;
    Widget baueUmschlagInhalt(double layoutBreite) {
      return SizedBox(
        width: layoutBreite,
        height: umschlagLayoutHoehe,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[
                          _baueZeile(
                            label: 'KINO SOLL',
                            wert: _formatiereEuro(kinoSollCent),
                          ),
                          _baueZeile(
                            label: '+ BISTRO SOLL',
                            wert: _formatiereEuro(bistroSollCent),
                          ),
                          _baueZeile(
                            label: '- Ausgaben',
                            wert: _formatiereEuro(ausgabenCent),
                          ),
                          const Divider(),
                          _baueZeile(
                            label: '= Gesamt SOLL',
                            wert: _formatiereEuro(gesamtSollCent),
                            hervorheben: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[
                          _baueZeile(
                            label: '+ EC IST',
                            wert: _formatiereEuro(ecIstCent),
                          ),
                          _baueZeile(
                            label: '+ BAR IST',
                            wert: _formatiereEuro(barIstCent),
                          ),
                          const Divider(),
                          _baueZeile(
                            label: '= Gesamt IST',
                            wert: _formatiereEuro(gesamtIstCent),
                            hervorheben: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    _baueZeile(
                      label: 'Differenz',
                      wert: _formatiereEuroMitVorzeichen(differenzCent),
                      hervorheben: true,
                      wertFarbe: differenzCent < 0 ? Colors.red : null,
                    ),
                    _baueZeile(
                      label: 'Differenz im Anfangsbestand',
                      wert: _formatiereEuro(differenzAnfangsbestandCent),
                      kursiv: true,
                    ),
                    _baueZeile(label: 'Datum', wert: datum),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: bildschirm.width - 24,
          maxHeight: bildschirm.height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Übertrag auf Umschlag',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Schließen',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double layoutBreite =
                        constraints.maxWidth < umschlagMaxBreite
                        ? constraints.maxWidth
                        : umschlagMaxBreite;
                    if (istPortrait) {
                      return FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: baueUmschlagInhalt(layoutBreite),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: baueUmschlagInhalt(layoutBreite),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
