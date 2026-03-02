import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/usecases/kassenstand_entwurf_usecase.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenstand_entwurf.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2_seite.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/ganzzahl_eingabefeld.dart';

class TagesabschlussSchritt1Argumente {
  const TagesabschlussSchritt1Argumente({
    required this.kinoId,
    required this.kinoName,
  });

  final String kinoId;
  final String kinoName;
}

class TagesabschlussSchritt1Seite extends StatefulWidget {
  const TagesabschlussSchritt1Seite({
    super.key,
    required this.kinoId,
    required this.kinoName,
  });

  static const String routenName = '/closure-step-1';

  final String kinoId;
  final String kinoName;

  @override
  State<TagesabschlussSchritt1Seite> createState() =>
      _TagesabschlussSchritt1SeiteState();
}

class _TagesabschlussSchritt1SeiteState
    extends State<TagesabschlussSchritt1Seite> {
  final KassenstandEntwurfUsecase _kassenstandEntwurfUsecase =
      const KassenstandEntwurfUsecase();

  final Map<String, int> _stueckzahlen = <String, int>{};
  final Map<String, TextEditingController> _stueckzahlController =
      <String, TextEditingController>{};
  final Map<String, FocusNode> _stueckzahlFocusNode = <String, FocusNode>{};
  final Map<String, int> _loseMuenzenNachArtCent = <String, int>{};
  final Map<String, TextEditingController> _loseMuenzenController =
      <String, TextEditingController>{};
  final Map<String, FocusNode> _loseMuenzenFocusNode = <String, FocusNode>{};

  final List<UmschlagEintrag> _umschlaege = <UmschlagEintrag>[];
  final List<TextEditingController> _umschlagBetragController =
      <TextEditingController>[];
  final List<TextEditingController> _umschlagBezeichnungController =
      <TextEditingController>[];
  final List<FocusNode> _umschlagBetragFocusNode = <FocusNode>[];
  final List<FocusNode> _umschlagBezeichnungFocusNode = <FocusNode>[];
  final List<int> _umschlagIds = <int>[];
  int _naechsteUmschlagId = 1;

  int _wechselgeldSollwertCent = 20000;
  bool _laedt = true;
  bool _scheineAufgeklappt = false;
  bool _loseMuenzenAufgeklappt = false;
  bool _rollenAufgeklappt = false;
  bool _umschlaegeAufgeklappt = false;
  bool _devToolsOffen = false;
  final Random _zufall = Random();

  List<Kassenzeile> get _scheine => StueckelungKonfiguration.scheine;
  List<Kassenzeile> get _rollen => StueckelungKonfiguration.rollen;
  List<Kassenzeile> get _loseMuenzarten =>
      StueckelungKonfiguration.loseMuenzarten;
  List<Kassenzeile> get _alleStueckzahlZeilen =>
      StueckelungKonfiguration.alleStueckzahlZeilen;
  bool get _devToolsSichtbar => !kReleaseMode;

  @override
  void initState() {
    super.initState();
    for (final Kassenzeile zeile in _alleStueckzahlZeilen) {
      _stueckzahlen[zeile.id] = 0;
      _stueckzahlController[zeile.id] = TextEditingController();
      _stueckzahlFocusNode[zeile.id] = FocusNode();
    }
    for (final Kassenzeile zeile in _loseMuenzarten) {
      _loseMuenzenNachArtCent[zeile.id] = 0;
      _loseMuenzenController[zeile.id] = TextEditingController();
      _loseMuenzenFocusNode[zeile.id] = FocusNode();
    }
    _ladeInitialeDaten();
  }

  @override
  void dispose() {
    for (final TextEditingController controller
        in _stueckzahlController.values) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _stueckzahlFocusNode.values) {
      focusNode.dispose();
    }
    for (final TextEditingController controller
        in _loseMuenzenController.values) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _loseMuenzenFocusNode.values) {
      focusNode.dispose();
    }
    for (final TextEditingController controller in _umschlagBetragController) {
      controller.dispose();
    }
    for (final TextEditingController controller
        in _umschlagBezeichnungController) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _umschlagBetragFocusNode) {
      focusNode.dispose();
    }
    for (final FocusNode focusNode in _umschlagBezeichnungFocusNode) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _ladeInitialeDaten() async {
    final int geladenerWechselgeldSollwert = await _kassenstandEntwurfUsecase
        .ladeWechselgeldSollwertCent(widget.kinoId);

    final KassenstandEntwurf? entwurf = await _kassenstandEntwurfUsecase
        .ladeHeutigenEntwurf(widget.kinoId);

    if (entwurf != null) {
      for (final Kassenzeile zeile in _alleStueckzahlZeilen) {
        _stueckzahlen[zeile.id] = entwurf.stueckzahlen[zeile.id] ?? 0;
      }
      for (final Kassenzeile zeile in _loseMuenzarten) {
        _loseMuenzenNachArtCent[zeile.id] =
            entwurf.loseMuenzenNachArtCent[zeile.id] ?? 0;
      }
      _uebernehmeUmschlagEntwurf(entwurf.umschlaege);
    }

    _synchronisiereControllerAusState();

    if (!mounted) {
      return;
    }

    setState(() {
      _wechselgeldSollwertCent = geladenerWechselgeldSollwert;
      _laedt = false;
    });
  }

  void _leereUmschlagFelder() {
    for (final TextEditingController controller in _umschlagBetragController) {
      controller.dispose();
    }
    for (final TextEditingController controller
        in _umschlagBezeichnungController) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _umschlagBetragFocusNode) {
      focusNode.dispose();
    }
    for (final FocusNode focusNode in _umschlagBezeichnungFocusNode) {
      focusNode.dispose();
    }
    _umschlaege.clear();
    _umschlagBetragController.clear();
    _umschlagBezeichnungController.clear();
    _umschlagBetragFocusNode.clear();
    _umschlagBezeichnungFocusNode.clear();
    _umschlagIds.clear();
  }

  void _uebernehmeUmschlagEntwurf(List<UmschlagEintrag> umschlagEntwurf) {
    _leereUmschlagFelder();
    for (final UmschlagEintrag eintrag in umschlagEntwurf) {
      _umschlaege.add(eintrag);
      _umschlagBetragController.add(
        TextEditingController(text: _formatiereEuroEingabe(eintrag.betragCent)),
      );
      _umschlagBezeichnungController.add(
        TextEditingController(text: eintrag.bezeichnung),
      );
      final FocusNode betragFocusNode = FocusNode();
      final FocusNode bezeichnungFocusNode = FocusNode();
      _umschlagBetragFocusNode.add(betragFocusNode);
      _umschlagBezeichnungFocusNode.add(bezeichnungFocusNode);
      _umschlagIds.add(_naechsteUmschlagId++);
    }
  }

  void _synchronisiereControllerAusState() {
    for (final Kassenzeile zeile in _alleStueckzahlZeilen) {
      final int stueckzahl = _stueckzahlen[zeile.id] ?? 0;
      final TextEditingController controller = _stueckzahlController[zeile.id]!;
      final String naechsterText = stueckzahl == 0 ? '' : stueckzahl.toString();
      if (controller.text != naechsterText) {
        _setzeControllerText(controller, naechsterText);
      }
    }

    for (final Kassenzeile zeile in _loseMuenzarten) {
      final int betragCent = _loseMuenzenNachArtCent[zeile.id] ?? 0;
      final TextEditingController controller =
          _loseMuenzenController[zeile.id]!;
      final String text = betragCent == 0
          ? ''
          : _formatiereEuroEingabe(betragCent);
      if (controller.text != text) {
        _setzeControllerText(controller, text);
      }
    }
  }

  void _setzeControllerText(TextEditingController controller, String text) {
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  int _zufallszahl(int min, int max) {
    return min + _zufall.nextInt(max - min + 1);
  }

  void _autoFillDev() {
    setState(() {
      for (final Kassenzeile zeile in _scheine) {
        _stueckzahlen[zeile.id] = _zufallszahl(0, 20);
      }
      for (final Kassenzeile zeile in _rollen) {
        _stueckzahlen[zeile.id] = _zufallszahl(0, 3);
      }
      for (final Kassenzeile zeile in _loseMuenzarten) {
        _loseMuenzenNachArtCent[zeile.id] = _zufallszahl(0, 3000);
      }

      final int umschlagAnzahl = _zufallszahl(1, 4);
      final List<UmschlagEintrag> umschlaege = <UmschlagEintrag>[];
      for (int i = 0; i < umschlagAnzahl; i++) {
        umschlaege.add(
          UmschlagEintrag(
            bezeichnung: 'Umschlag ${i + 1}',
            betragCent: _zufallszahl(0, 50000),
          ),
        );
      }
      _uebernehmeUmschlagEntwurf(umschlaege);
      _synchronisiereControllerAusState();
    });
  }

  void _leereAlleFelderDev() {
    FocusScope.of(context).unfocus();
    setState(() {
      for (final Kassenzeile zeile in _alleStueckzahlZeilen) {
        _stueckzahlen[zeile.id] = 0;
      }
      for (final Kassenzeile zeile in _loseMuenzarten) {
        _loseMuenzenNachArtCent[zeile.id] = 0;
      }
      _leereUmschlagFelder();
      _synchronisiereControllerAusState();
    });
  }

  Widget _baueDevToolsPanel() {
    return Card(
      color: const Color(0xFFFFF8E1),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'DEV-Tools (nur Debug/Profile)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton(
              onPressed: _autoFillDev,
              child: const Text('Auto-Fill'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _leereAlleFelderDev,
              child: const Text('Alles leeren'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speichereEntwurf() async {
    final KassenstandEntwurf entwurf = KassenstandEntwurf(
      stueckzahlen: Map<String, int>.from(_stueckzahlen),
      umschlaege: List<UmschlagEintrag>.from(_umschlaege),
      loseMuenzenNachArtCent: Map<String, int>.from(_loseMuenzenNachArtCent),
    );

    await _kassenstandEntwurfUsecase.speichereHeutigenEntwurf(
      kinoId: widget.kinoId,
      entwurf: entwurf,
    );
  }

  void _beiStueckzahlGeaendert(Kassenzeile zeile, String wert) {
    final int geparsterWert = int.tryParse(wert) ?? 0;
    setState(() {
      _stueckzahlen[zeile.id] = geparsterWert;
    });
    _speichereEntwurf();
  }

  void _beiLoseMuenzartBetragGeaendert(String muenzartId, String wert) {
    setState(() {
      _loseMuenzenNachArtCent[muenzartId] = _parseCentZiffern(wert);
    });
    _speichereEntwurf();
  }

  void _umschlagHinzufuegen() {
    setState(() {
      _umschlaege.add(const UmschlagEintrag(bezeichnung: '', betragCent: 0));
      _umschlagBetragController.add(TextEditingController());
      _umschlagBezeichnungController.add(TextEditingController());
      final FocusNode betragFocusNode = FocusNode();
      final FocusNode bezeichnungFocusNode = FocusNode();
      _umschlagBetragFocusNode.add(betragFocusNode);
      _umschlagBezeichnungFocusNode.add(bezeichnungFocusNode);
      _umschlagIds.add(_naechsteUmschlagId++);
    });
    _speichereEntwurf();
  }

  void _umschlagEntfernen(int index) {
    if (index < 0 || index >= _umschlaege.length) {
      return;
    }

    setState(() {
      _umschlaege.removeAt(index);
      _umschlagBetragController.removeAt(index).dispose();
      _umschlagBezeichnungController.removeAt(index).dispose();
      final FocusNode betragFocusNode = _umschlagBetragFocusNode.removeAt(
        index,
      );
      final FocusNode bezeichnungFocusNode = _umschlagBezeichnungFocusNode
          .removeAt(index);
      betragFocusNode.dispose();
      bezeichnungFocusNode.dispose();
      _umschlagIds.removeAt(index);
    });
    _speichereEntwurf();
  }

  void _beiUmschlagBezeichnungGeaendert(int index, String wert) {
    if (index < 0 || index >= _umschlaege.length) {
      return;
    }

    setState(() {
      _umschlaege[index] = UmschlagEintrag(
        bezeichnung: wert,
        betragCent: _umschlaege[index].betragCent,
      );
    });
    _speichereEntwurf();
  }

  void _beiUmschlagBetragGeaendert(int index, String wert) {
    if (index < 0 || index >= _umschlaege.length) {
      return;
    }

    final int betragCent = _parseCentZiffern(wert);
    setState(() {
      _umschlaege[index] = UmschlagEintrag(
        bezeichnung: _umschlaege[index].bezeichnung,
        betragCent: betragCent,
      );
    });
    _speichereEntwurf();
  }

  int _parseCentZiffern(String wert) {
    return TagesabschlussBerechnung.parseCentZiffern(wert);
  }

  List<FocusNode> _fokusReihenfolgeSchritt1() {
    final List<FocusNode> reihenfolge = <FocusNode>[
      ..._scheine.map((Kassenzeile zeile) => _stueckzahlFocusNode[zeile.id]!),
      ..._loseMuenzarten.map(
        (Kassenzeile zeile) => _loseMuenzenFocusNode[zeile.id]!,
      ),
      ..._rollen.map((Kassenzeile zeile) => _stueckzahlFocusNode[zeile.id]!),
    ];

    for (int i = 0; i < _umschlaege.length; i++) {
      reihenfolge.add(_umschlagBezeichnungFocusNode[i]);
      reihenfolge.add(_umschlagBetragFocusNode[i]);
    }
    return reihenfolge;
  }

  bool _istLetztesFeldSchritt1(FocusNode focusNode) {
    final List<FocusNode> reihenfolge = _fokusReihenfolgeSchritt1();
    return reihenfolge.isNotEmpty && identical(reihenfolge.last, focusNode);
  }

  FocusNode? _naechstesFeldSchritt1(FocusNode focusNode) {
    final List<FocusNode> reihenfolge = _fokusReihenfolgeSchritt1();
    final int index = reihenfolge.indexWhere(
      (FocusNode kandidat) => identical(kandidat, focusNode),
    );
    if (index < 0 || index >= reihenfolge.length - 1) {
      return null;
    }
    return reihenfolge[index + 1];
  }

  TextInputAction _textInputActionFuerSchritt1(FocusNode focusNode) {
    return _istLetztesFeldSchritt1(focusNode)
        ? TextInputAction.done
        : TextInputAction.next;
  }

  void _beiEingabeAbgeschlossenSchritt1(FocusNode focusNode) {
    final FocusNode? naechstesFeld = _naechstesFeldSchritt1(focusNode);
    if (naechstesFeld == null) {
      FocusScope.of(context).unfocus();
      return;
    }
    FocusScope.of(context).requestFocus(naechstesFeld);
  }

  FocusNode? _aktivesFeldSchritt1() {
    for (final FocusNode focusNode in _fokusReihenfolgeSchritt1()) {
      if (focusNode.hasFocus) {
        return focusNode;
      }
    }
    return null;
  }

  void _weiterZumNaechstenFeldUnten() {
    final List<FocusNode> reihenfolge = _fokusReihenfolgeSchritt1();
    if (reihenfolge.isEmpty) {
      return;
    }
    final FocusNode? aktivesFeld = _aktivesFeldSchritt1();
    if (aktivesFeld == null) {
      _fokussiereTextfeld(reihenfolge.first);
      return;
    }
    final FocusNode? naechstesFeld = _naechstesFeldSchritt1(aktivesFeld);
    if (naechstesFeld == null) {
      FocusScope.of(context).unfocus();
      return;
    }
    _fokussiereTextfeld(naechstesFeld);
  }

  void _fokussiereTextfeld(FocusNode fokusNode) {
    FocusScope.of(context).requestFocus(fokusNode);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    }
  }

  int _summeGruppe(List<Kassenzeile> zeilen) {
    return TagesabschlussBerechnung.summeStueckzahlGruppeCent(
      zeilen: zeilen,
      stueckzahlen: _stueckzahlen,
    );
  }

  int get _umschlagSummeCent {
    return TagesabschlussBerechnung.summeUmschlaegeCent(_umschlaege);
  }

  int get _kassenbestandGesamtCent {
    return TagesabschlussBerechnung.kassenbestandGesamtCent(
      scheineCent: _summeGruppe(_scheine),
      loseMuenzenCent: _loseMuenzenGesamtCent,
      rollenCent: _summeGruppe(_rollen),
      umschlaegeCent: _umschlagSummeCent,
    );
  }

  int get _loseMuenzenGesamtCent {
    return TagesabschlussBerechnung.summeCentBetraege(
      _loseMuenzenNachArtCent.values,
    );
  }

  int get _barumsatzBereinigtCent =>
      TagesabschlussBerechnung.barumsatzBereinigtCent(
        kassenbestandGesamtCent: _kassenbestandGesamtCent,
        wechselgeldSollwertCent: _wechselgeldSollwertCent,
      );

  String _formatiereEuro(int cent) {
    return TagesabschlussFormatierung.formatiereEuro(cent);
  }

  String _formatiereEuroEingabe(int cent) {
    return TagesabschlussFormatierung.formatiereEuroEingabe(cent);
  }

  Future<void> _bestaetigeUndLeereEingaben() async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogKontext) {
        return AlertDialog(
          title: const Text('Eingaben wirklich löschen?'),
          content: const Text(
            'Alle Eingaben in Schritt 1 werden zurückgesetzt.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogKontext).pop(false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogKontext).pop(true),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );

    if (bestaetigt != true) {
      return;
    }
    if (!mounted) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      for (final Kassenzeile zeile in _alleStueckzahlZeilen) {
        _stueckzahlen[zeile.id] = 0;
      }
      for (final Kassenzeile zeile in _loseMuenzarten) {
        _loseMuenzenNachArtCent[zeile.id] = 0;
      }
      _leereUmschlagFelder();
      _synchronisiereControllerAusState();
    });
    await _speichereEntwurf();
  }

  Future<void> _weiterZuSchritt2() async {
    if (_kassenstandEntwurfUsecase.bestaetigungNoetigFuerNullbetrag(
      _kassenbestandGesamtCent,
    )) {
      final bool? bestaetigt = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('0 € übernehmen?'),
            content: const Text(
              'Es wurde noch kein Betrag erfasst. Willst du mit 0 € fortfahren?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Fortfahren'),
              ),
            ],
          );
        },
      );

      if (bestaetigt != true) {
        return;
      }
    }

    await _speichereEntwurf();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamed(
      TagesabschlussSchritt2Seite.routenName,
      arguments: TagesabschlussSchritt2Argumente(
        kinoId: widget.kinoId,
        kinoName: widget.kinoName,
        scheineCent: _summeGruppe(_scheine),
        loseMuenzenCent: _loseMuenzenGesamtCent,
        rollenCent: _summeGruppe(_rollen),
        umschlaegeCent: _umschlagSummeCent,
        wechselgeldSollwertCent: _wechselgeldSollwertCent,
        barBestandAbzglWechselgeldCent: _barumsatzBereinigtCent,
      ),
    );
  }

  Widget _baueGruppenInhalt(
    List<Kassenzeile> zeilen,
    String gesamtbetragLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in zeilen) ...<Widget>[
          _baueZeilenEintrag(zeile),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        Text(
          '$gesamtbetragLabel: ${_formatiereEuro(_summeGruppe(zeilen))}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _baueZeilenEintrag(Kassenzeile zeile) {
    final int stueckzahl = _stueckzahlen[zeile.id] ?? 0;
    final int zwischensumme = stueckzahl * zeile.einzelwertCent;
    final FocusNode focusNode = _stueckzahlFocusNode[zeile.id]!;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(zeile.bezeichnung, style: const TextStyle(fontSize: 16)),
        ),
        SizedBox(
          width: 96,
          child: GanzzahlEingabefeld(
            textController: _stueckzahlController[zeile.id]!,
            focusNode: focusNode,
            schriftgroesse: 16,
            textInputAction: _textInputActionFuerSchritt1(focusNode),
            onChanged: (String wert) => _beiStueckzahlGeaendert(zeile, wert),
            onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt1(focusNode),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 95,
          child: Text(
            _formatiereEuro(zwischensumme),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _baueLoseMuenzenInhalt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in _loseMuenzarten) ...<Widget>[
          Builder(
            builder: (BuildContext _) {
              final FocusNode focusNode = _loseMuenzenFocusNode[zeile.id]!;
              return Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      zeile.bezeichnung,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 148,
                    child: BetragCentEingabefeld(
                      textController: _loseMuenzenController[zeile.id]!,
                      focusNode: focusNode,
                      textInputAction: _textInputActionFuerSchritt1(focusNode),
                      onSubmitted: (_) =>
                          _beiEingabeAbgeschlossenSchritt1(focusNode),
                      onChanged: (String wert) =>
                          _beiLoseMuenzartBetragGeaendert(zeile.id, wert),
                      schriftgroesse: 15,
                      hinweisText: '0,00 €',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Text(
          'Gesamtbetrag Lose Münzen: ${_formatiereEuro(_loseMuenzenGesamtCent)}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _baueUmschlagInhalt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_umschlaege.isEmpty) const Text('Noch keine Umschläge erfasst.'),
        for (int i = 0; i < _umschlaege.length; i++) ...<Widget>[
          Builder(
            builder: (BuildContext _) {
              final FocusNode bezeichnungFocusNode =
                  _umschlagBezeichnungFocusNode[i];
              final FocusNode betragFocusNode = _umschlagBetragFocusNode[i];
              return Row(
                key: ValueKey<int>(_umschlagIds[i]),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _umschlagBezeichnungController[i],
                      focusNode: bezeichnungFocusNode,
                      textInputAction: _textInputActionFuerSchritt1(
                        bezeichnungFocusNode,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Label (optional)',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                      ),
                      onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt1(
                        bezeichnungFocusNode,
                      ),
                      onChanged: (String wert) =>
                          _beiUmschlagBezeichnungGeaendert(i, wert),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 132,
                    child: BetragCentEingabefeld(
                      textController: _umschlagBetragController[i],
                      focusNode: betragFocusNode,
                      textInputAction: _textInputActionFuerSchritt1(
                        betragFocusNode,
                      ),
                      onSubmitted: (_) =>
                          _beiEingabeAbgeschlossenSchritt1(betragFocusNode),
                      onChanged: (String wert) =>
                          _beiUmschlagBetragGeaendert(i, wert),
                      schriftgroesse: 14,
                      hinweisText: '0,00 €',
                      labelText: 'Betrag €',
                    ),
                  ),
                  IconButton(
                    onPressed: () => _umschlagEntfernen(i),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Umschlag entfernen',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _umschlagHinzufuegen,
            icon: const Icon(Icons.add),
            label: const Text('Umschlag hinzufügen'),
          ),
        ),
        Text(
          'Gesamtbetrag Umschläge: ${_formatiereEuro(_umschlagSummeCent)}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _baueEinklappbarenBereich({
    required String titel,
    required int gesamtbetragCent,
    required bool aufgeklappt,
    required VoidCallback beimUmschalten,
    required Widget inhalt,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: beimUmschalten,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      titel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    _formatiereEuro(gesamtbetragCent),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(aufgeklappt ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (aufgeklappt) ...<Widget>[
            const Divider(height: 1),
            Padding(padding: const EdgeInsets.all(12), child: inhalt),
          ],
        ],
      ),
    );
  }

  Widget _baueScheineGruppe() {
    return _baueEinklappbarenBereich(
      titel: 'Scheine (Anzahl eingeben)',
      gesamtbetragCent: _summeGruppe(_scheine),
      aufgeklappt: _scheineAufgeklappt,
      beimUmschalten: () {
        setState(() {
          _scheineAufgeklappt = !_scheineAufgeklappt;
        });
      },
      inhalt: _baueGruppenInhalt(_scheine, 'Gesamtbetrag Scheine'),
    );
  }

  Widget _baueLoseMuenzenGruppe() {
    return _baueEinklappbarenBereich(
      titel: 'Lose Münzen (Betrag eingeben)',
      gesamtbetragCent: _loseMuenzenGesamtCent,
      aufgeklappt: _loseMuenzenAufgeklappt,
      beimUmschalten: () {
        setState(() {
          _loseMuenzenAufgeklappt = !_loseMuenzenAufgeklappt;
        });
      },
      inhalt: _baueLoseMuenzenInhalt(),
    );
  }

  Widget _baueRollenGruppe() {
    return _baueEinklappbarenBereich(
      titel: 'Rollen (Anzahl eingeben)',
      gesamtbetragCent: _summeGruppe(_rollen),
      aufgeklappt: _rollenAufgeklappt,
      beimUmschalten: () {
        setState(() {
          _rollenAufgeklappt = !_rollenAufgeklappt;
        });
      },
      inhalt: _baueGruppenInhalt(_rollen, 'Gesamtbetrag Rollen'),
    );
  }

  Widget _baueUmschlagGruppe() {
    return _baueEinklappbarenBereich(
      titel: 'Umschläge (Betrag eingeben)',
      gesamtbetragCent: _umschlagSummeCent,
      aufgeklappt: _umschlaegeAufgeklappt,
      beimUmschalten: () {
        setState(() {
          _umschlaegeAufgeklappt = !_umschlaegeAufgeklappt;
        });
      },
      inhalt: _baueUmschlagInhalt(),
    );
  }

  Widget _baueZusammenfassung() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Zusammenfassung',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _baueZusammenfassungsZeile(
              'Kassenbestand gesamt',
              _formatiereEuro(_kassenbestandGesamtCent),
            ),
            _baueZusammenfassungsZeile(
              'Wechselgeld-Sollwert',
              _formatiereEuro(_wechselgeldSollwertCent),
            ),
            _baueZusammenfassungsZeile(
              'Barumsatz (bereinigt)',
              _formatiereEuro(_barumsatzBereinigtCent),
              hervorheben: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _baueZusammenfassungsZeile(
    String label,
    String wert, {
    bool hervorheben = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(
            wert,
            style: TextStyle(
              fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w500,
              color: hervorheben && _barumsatzBereinigtCent < 0
                  ? Colors.red
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueFooterLeiste(double footerHoehe) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SizedBox(
        height: footerHoehe,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: _weiterZumNaechstenFeldUnten,
                  child: const Text('nächstes Feld'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _weiterZuSchritt2,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Schritt 2'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_laedt) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool devToolsStickySichtbar = _devToolsSichtbar && _devToolsOffen;
    const double footerHoehe = 72;
    const double devToolsStickyHoehe = 86;
    final double footerBottomInset =
        mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + 8;
    final double bottomPadding = footerHoehe + 16;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 68,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Tagesabschluss'),
            Text(
              '1/4 · Bargeldzählung',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: <Widget>[
          if (_devToolsSichtbar)
            IconButton(
              tooltip: 'DEV-Tools',
              onPressed: () {
                setState(() {
                  _devToolsOffen = !_devToolsOffen;
                });
              },
              icon: Icon(
                _devToolsOffen
                    ? Icons.developer_mode
                    : Icons.developer_mode_outlined,
              ),
            ),
          TextButton(
            onPressed: _bestaetigeUndLeereEingaben,
            child: const Text('Clear'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: const InputDecorationTheme(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: <Widget>[
                  if (devToolsStickySichtbar)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _DevToolsStickyHeaderDelegate(
                        extent: devToolsStickyHoehe,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: _baueDevToolsPanel(),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPadding),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(<Widget>[
                        _baueScheineGruppe(),
                        _baueLoseMuenzenGruppe(),
                        _baueRollenGruppe(),
                        _baueUmschlagGruppe(),
                        _baueZusammenfassung(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: footerBottomInset,
            child: SizedBox(
              height: footerHoehe,
              child: _baueFooterLeiste(footerHoehe),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevToolsStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DevToolsStickyHeaderDelegate({required this.extent, required this.child});

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _DevToolsStickyHeaderDelegate oldDelegate) {
    return extent != oldDelegate.extent || child != oldDelegate.child;
  }
}
