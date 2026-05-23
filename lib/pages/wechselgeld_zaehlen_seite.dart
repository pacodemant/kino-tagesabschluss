import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/services/wechselgeld_config_service.dart';
import 'package:kino_bar_app/domain/usecases/kassenstand_entwurf_usecase.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenstand_entwurf.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/controller/schritt1_state_controller.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/orchestrierung/schritt1_orchestrierung_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/scroll/schritt1_scroll_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/setup/schritt1_initialisierung_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_body_content.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_gruppen_orchestrierung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_ui_builder.dart' as schritt1_ui;
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

class WechselgeldZaehlenSeite extends StatefulWidget {
  const WechselgeldZaehlenSeite({super.key, required this.kinoId});

  static const String routenName = '/wechselgeld-zaehlen';

  final String kinoId;

  @override
  State<WechselgeldZaehlenSeite> createState() =>
      _WechselgeldZaehlenSeiteState();
}

class _WechselgeldZaehlenSeiteState extends State<WechselgeldZaehlenSeite> {
  static const int _sectionScheine = 0;
  static const int _sectionLoseMuenzen = 1;
  static const int _sectionRollen = 2;
  static const int _sectionUmschlaege = 4;
  static const Set<String> _kupferRollenIds = <String>{
    'roll_1c',
    'roll_2c',
    'roll_5c',
  };
  static const Set<String> _kupferLoseMuenzenIds = <String>{
    'coin_1c',
    'coin_2c',
    'coin_5c',
  };

  final Schritt1StateController _stateController =
      const Schritt1StateController();
  final Schritt1OrchestrierungHelper _orchestrierungHelper =
      const Schritt1OrchestrierungHelper();
  final Schritt1GruppenOrchestrierung _gruppenOrchestrierung =
      const Schritt1GruppenOrchestrierung();
  final KassenstandEntwurfUsecase _kassenstandEntwurfUsecase =
      const KassenstandEntwurfUsecase();
  late final Schritt1InitialisierungHelper _initialisierungHelper;

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

  int _wechselgeldSollwertCent = 0;
  bool _laedt = true;
  bool _scheineAufgeklappt = true;
  bool _loseMuenzenAufgeklappt = false;
  bool _rollenAufgeklappt = false;
  bool _kupferLoseSichtbar = false;
  bool _kupferRollenSichtbar = false;
  bool _umschlaegeAufgeklappt = false;
  bool _dialogGezeigt = false;
  bool _dialogPruefungGeplant = false;
  bool _rollenUebernommen = false;

  final ScrollController _scrollController = ScrollController();
  final Schritt1ScrollHelper _scrollHelper = Schritt1ScrollHelper();

  List<Kassenzeile> get _scheine => StueckelungKonfiguration.scheine;
  List<Kassenzeile> get _rollenAlle => StueckelungKonfiguration.rollen;
  List<Kassenzeile> get _kupferRollen => _rollenAlle
      .where((Kassenzeile zeile) => _kupferRollenIds.contains(zeile.id))
      .toList();
  List<Kassenzeile> get _rollenOhneKupfer => _rollenAlle
      .where((Kassenzeile zeile) => !_kupferRollenIds.contains(zeile.id))
      .toList();
  List<Kassenzeile> get _rollenSichtbar =>
      _kupferRollenSichtbar ? _rollenAlle : _rollenOhneKupfer;
  List<Kassenzeile> get _loseMuenzartenOhneKupfer => _loseMuenzarten
      .where((Kassenzeile zeile) => !_kupferLoseMuenzenIds.contains(zeile.id))
      .toList();
  List<Kassenzeile> get _kupferLoseMuenzarten => _loseMuenzarten
      .where((Kassenzeile zeile) => _kupferLoseMuenzenIds.contains(zeile.id))
      .toList();
  List<Kassenzeile> get _loseMuenzarten =>
      StueckelungKonfiguration.loseMuenzarten;
  List<Kassenzeile> get _alleStueckzahlZeilen =>
      StueckelungKonfiguration.alleStueckzahlZeilen;

  @override
  void initState() {
    super.initState();
    _initialisierungHelper = Schritt1InitialisierungHelper(
      stueckzahlen: _stueckzahlen,
      loseMuenzenNachArtCent: _loseMuenzenNachArtCent,
      umschlaege: _umschlaege,
      umschlagBetragController: _umschlagBetragController,
      umschlagBezeichnungController: _umschlagBezeichnungController,
      umschlagBetragFocusNode: _umschlagBetragFocusNode,
      umschlagBezeichnungFocusNode: _umschlagBezeichnungFocusNode,
      umschlagIds: _umschlagIds,
      stueckzahlController: _stueckzahlController,
      loseMuenzenController: _loseMuenzenController,
      alleStueckzahlZeilen: _alleStueckzahlZeilen,
      loseMuenzarten: _loseMuenzarten,
      formatiereEuroEingabe: _formatiereEuroEingabe,
      entferneFeldKey: _scrollHelper.entferneFeldKey,
      naechsteUmschlagId: () => _naechsteUmschlagId++,
    );
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
    _scrollController.addListener(_beiScrollAenderung);
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
    _scrollController.removeListener(_beiScrollAenderung);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _ladeInitialeDaten() async {
    int geladenerSollwert =
        await LokalerSpeicher.ladeWechselgeldSollwertCent(widget.kinoId);
    if (geladenerSollwert == 0) {
      final String kinoName =
          KinoRepository.nachId(widget.kinoId)?.name ?? '';
      geladenerSollwert =
          await WechselgeldConfigService().getWechselgeldBetrag(kinoName);
    }
    final Map<String, dynamic>? entwurf =
        await LokalerSpeicher.ladeWechselgeldZaehlEntwurf(widget.kinoId);

    if (!mounted) {
      return;
    }

    if (entwurf != null) {
      final Object? stueckzahlenRoh = entwurf['stueckzahlen'];
      if (stueckzahlenRoh is Map<String, dynamic>) {
        for (final MapEntry<String, dynamic> e in stueckzahlenRoh.entries) {
          _stueckzahlen[e.key] = (e.value as num?)?.toInt() ?? 0;
        }
      }
      final Object? loseRoh = entwurf['loseMuenzenNachArtCent'];
      if (loseRoh is Map<String, dynamic>) {
        for (final MapEntry<String, dynamic> e in loseRoh.entries) {
          _loseMuenzenNachArtCent[e.key] = (e.value as num?)?.toInt() ?? 0;
        }
      }
      final Object? umschlaegeRoh = entwurf['umschlaege'];
      if (umschlaegeRoh is List<dynamic>) {
        final List<UmschlagEintrag> umschlagListe = <UmschlagEintrag>[];
        for (final dynamic item in umschlaegeRoh) {
          if (item is Map<String, dynamic>) {
            umschlagListe.add(UmschlagEintrag.fromJson(item));
          }
        }
        _initialisierungHelper.uebernehmeUmschlagEntwurf(umschlagListe);
      }
      _initialisierungHelper.synchronisiereControllerAusState();
    }

    _initialisierungHelper.sichereMindestensEinenUmschlag();

    final bool hatKupferRollenWerte =
        _kupferRollenIds.any((String id) => (_stueckzahlen[id] ?? 0) > 0);
    final bool hatKupferLoseWerte = _kupferLoseMuenzenIds.any(
      (String id) => (_loseMuenzenNachArtCent[id] ?? 0) > 0,
    );

    setState(() {
      _wechselgeldSollwertCent = geladenerSollwert;
      _laedt = false;
      if (hatKupferRollenWerte) {
        _kupferRollenSichtbar = true;
      }
      if (hatKupferLoseWerte) {
        _kupferLoseSichtbar = true;
      }
    });
  }

  Future<void> _speichereEntwurf() async {
    await LokalerSpeicher.speichereWechselgeldZaehlEntwurf(
      widget.kinoId,
      <String, dynamic>{
        'stueckzahlen': Map<String, int>.from(_stueckzahlen),
        'loseMuenzenNachArtCent': Map<String, int>.from(_loseMuenzenNachArtCent),
        'umschlaege': _umschlaege
            .map((UmschlagEintrag e) => e.toJson())
            .toList(),
      },
    );
  }

  void _planePruefung() {
    if (_dialogPruefungGeplant) {
      return;
    }
    _dialogPruefungGeplant = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dialogPruefungGeplant = false;
      if (!mounted) {
        return;
      }
      _pruefUndZeigeDialogWennNoetig();
    });
  }

  void _pruefUndZeigeDialogWennNoetig() {
    if (!mounted || _laedt) {
      return;
    }
    final bool uebereinstimmung = _wechselgeldSollwertCent > 0 &&
        _kassenbestandGesamtCent == _wechselgeldSollwertCent;

    if (!uebereinstimmung) {
      if (_dialogGezeigt) {
        setState(() {
          _dialogGezeigt = false;
        });
      }
      return;
    }

    if (!_dialogGezeigt) {
      setState(() {
        _dialogGezeigt = true;
      });
      _zeigeUebereinstimmungsDialog();
    }
  }

  Future<void> _zeigeUebereinstimmungsDialog() async {
    final String betragText = _formatiereEuro(_kassenbestandGesamtCent);
    final bool? zurueck = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogKontext) {
        return AlertDialog(
          title: const Text('Wechselgeld stimmt!'),
          content: Text('Gezählter Betrag: $betragText'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogKontext).pop(false),
              child: const Text('Weiter zählen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogKontext).pop(true),
              child: const Text('Zurück zur Startseite'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (zurueck == true) {
      _zurueckZurStartseite();
    }
  }

  void _zurueckZurStartseite() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      StartmenueSeite.routenName,
      (Route<dynamic> route) => false,
      arguments: widget.kinoId,
    );
  }

  void _leereUmschlagFelder() => _initialisierungHelper.leereUmschlagFelder();

  void _fuegeUmschlagEintragOhneSpeichernHinzu(UmschlagEintrag eintrag) =>
      _initialisierungHelper.fuegeUmschlagEintragOhneSpeichernHinzu(eintrag);

  void _sichereMindestensEinenUmschlag() =>
      _initialisierungHelper.sichereMindestensEinenUmschlag();

  void _synchronisiereControllerAusState() =>
      _initialisierungHelper.synchronisiereControllerAusState();

  void _beiScrollAenderung() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _beiScrollMetrikAenderung() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  bool _istDownButtonSichtbar() =>
      _scrollHelper.istDownButtonSichtbar(scrollController: _scrollController);

  void _scrolleNachUnten() =>
      _scrollHelper.scrolleNachUnten(scrollController: _scrollController);

  GlobalKey _holeFeldKey(FocusNode focusNode) =>
      _scrollHelper.holeFeldKey(focusNode);

  Widget _baueFeldMitKey({
    required FocusNode focusNode,
    required Widget child,
  }) {
    return KeyedSubtree(key: _holeFeldKey(focusNode), child: child);
  }

  void _beiStueckzahlGeaendert(Kassenzeile zeile, String wert) {
    final int geparsterWert = _stateController.parseGanzzahl(wert);
    setState(() {
      _stateController.setzeStueckzahl(_stueckzahlen, zeile.id, geparsterWert);
    });
    _speichereEntwurf();
    _planePruefung();
  }

  void _beiLoseMuenzartBetragGeaendert(String muenzartId, String wert) {
    setState(() {
      _stateController.setzeLoseMuenzartBetrag(
        _loseMuenzenNachArtCent,
        muenzartId,
        _parseCentZiffern(wert),
      );
    });
    _speichereEntwurf();
    _planePruefung();
  }

  void _umschlagHinzufuegen() {
    setState(() {
      _stateController.fuegeUmschlagEintragHinzu(() {
        _fuegeUmschlagEintragOhneSpeichernHinzu(
          const UmschlagEintrag(bezeichnung: '', betragCent: 0),
        );
      });
    });
    _speichereEntwurf();
  }

  void _umschlagEntfernen(int index) {
    if (!_stateController.kannUmschlagEntfernen(_umschlaege, index)) {
      return;
    }
    setState(() {
      _stateController.entferneUmschlag(
        umschlaege: _umschlaege,
        umschlagBetragController: _umschlagBetragController,
        umschlagBezeichnungController: _umschlagBezeichnungController,
        umschlagBetragFocusNode: _umschlagBetragFocusNode,
        umschlagBezeichnungFocusNode: _umschlagBezeichnungFocusNode,
        umschlagIds: _umschlagIds,
        index: index,
        entferneFeldKey: _scrollHelper.entferneFeldKey,
      );
    });
    _speichereEntwurf();
    _planePruefung();
  }

  void _beiUmschlagBezeichnungGeaendert(int index, String wert) {
    if (!_stateController.istUmschlagIndexGueltig(_umschlaege, index)) {
      return;
    }
    setState(() {
      _stateController.setzeUmschlagBezeichnung(_umschlaege, index, wert);
    });
    _speichereEntwurf();
  }

  void _beiUmschlagBetragGeaendert(int index, String wert) {
    if (!_stateController.istUmschlagIndexGueltig(_umschlaege, index)) {
      return;
    }
    final int betragCent = _parseCentZiffern(wert);
    setState(() {
      _stateController.setzeUmschlagBetrag(_umschlaege, index, betragCent);
    });
    _speichereEntwurf();
    _planePruefung();
  }

  void _zeigeKupferLose() {
    setState(() {
      _kupferLoseSichtbar = true;
    });
  }

  void _zeigeKupferRollen() {
    setState(() {
      _kupferRollenSichtbar = true;
    });
  }

  int _parseCentZiffern(String wert) => _stateController.parseCentZiffern(wert);

  List<FocusNode> _fokusReihenfolge() => _stateController.fokusReihenfolge(
    scheine: _scheine,
    stueckzahlFocusNode: _stueckzahlFocusNode,
    loseMuenzarten: _loseMuenzarten,
    loseMuenzenFocusNode: _loseMuenzenFocusNode,
    rollenSichtbar: _rollenSichtbar,
    umschlaege: _umschlaege,
    umschlagBezeichnungFocusNode: _umschlagBezeichnungFocusNode,
    umschlagBetragFocusNode: _umschlagBetragFocusNode,
  );

  bool _istLetztesFeld(FocusNode focusNode) =>
      _stateController.istLetztesFeld(_fokusReihenfolge(), focusNode);

  FocusNode? _naechstesFeld(FocusNode focusNode) =>
      _stateController.naechstesFeld(_fokusReihenfolge(), focusNode);

  TextInputAction _textInputAction(FocusNode focusNode) =>
      _stateController.textInputActionFuerSchritt1(_istLetztesFeld(focusNode));

  void _beiEingabeAbgeschlossen(FocusNode focusNode) =>
      _stateController.beiEingabeAbgeschlossen(
        context,
        _naechstesFeld(focusNode),
      );

  FocusNode? _aktivesFeld() =>
      _stateController.aktivesFeld(_fokusReihenfolge());

  void _weiterZumNaechstenFeld() => _stateController.weiterZumNaechstenFeld(
    context: context,
    reihenfolge: _fokusReihenfolge(),
    aktivesFeld: _aktivesFeld(),
    naechstesFeld: _naechstesFeld,
    fokussiereTextfeld: _fokussiereTextfeld,
  );

  void _fokussiereTextfeld(FocusNode fokusNode) =>
      _stateController.fokussiereTextfeld(
        context: context,
        fokusNode: fokusNode,
        aktivesFeld: _aktivesFeld,
        oeffneSectionFuerFokusfeld: _oeffneSectionFuerFokusfeld,
        fokussiereTextfeldRekursiv: _fokussiereTextfeld,
        mounted: mounted,
      );

  int? _sectionIdFuerFokusfeld(FocusNode focusNode) {
    if (_scheine.any(
      (Kassenzeile zeile) =>
          identical(_stueckzahlFocusNode[zeile.id], focusNode),
    )) {
      return _sectionScheine;
    }
    if (_loseMuenzarten.any(
      (Kassenzeile zeile) =>
          identical(_loseMuenzenFocusNode[zeile.id], focusNode),
    )) {
      return _sectionLoseMuenzen;
    }
    if (_rollenSichtbar.any(
      (Kassenzeile zeile) =>
          identical(_stueckzahlFocusNode[zeile.id], focusNode),
    )) {
      return _sectionRollen;
    }
    if (_umschlagBezeichnungFocusNode.any(
          (FocusNode node) => identical(node, focusNode),
        ) ||
        _umschlagBetragFocusNode.any(
          (FocusNode node) => identical(node, focusNode),
        )) {
      return _sectionUmschlaege;
    }
    return null;
  }

  bool _istSectionAufgeklappt(int sectionId) {
    switch (sectionId) {
      case _sectionScheine:
        return _scheineAufgeklappt;
      case _sectionLoseMuenzen:
        return _loseMuenzenAufgeklappt;
      case _sectionRollen:
        return _rollenAufgeklappt;
      case _sectionUmschlaege:
        return _umschlaegeAufgeklappt;
    }
    return false;
  }

  void _setzeSectionAufgeklappt(int sectionId, bool wert) {
    switch (sectionId) {
      case _sectionScheine:
        _scheineAufgeklappt = wert;
        return;
      case _sectionLoseMuenzen:
        _loseMuenzenAufgeklappt = wert;
        return;
      case _sectionRollen:
        _rollenAufgeklappt = wert;
        return;
      case _sectionUmschlaege:
        _umschlaegeAufgeklappt = wert;
        return;
    }
  }

  void _toggleSection(int sectionId) {
    setState(() {
      _setzeSectionAufgeklappt(sectionId, !_istSectionAufgeklappt(sectionId));
    });
  }

  bool _oeffneSectionFuerFokusfeld(
    FocusNode zielFokusNode, {
    FocusNode? vorherigesFokusfeld,
  }) {
    final int? zielSectionId = _sectionIdFuerFokusfeld(zielFokusNode);
    if (zielSectionId == null) {
      return false;
    }
    final int? vorherigeSectionId = vorherigesFokusfeld == null
        ? null
        : _sectionIdFuerFokusfeld(vorherigesFokusfeld);

    bool geaendert = false;
    if (vorherigeSectionId != null &&
        vorherigeSectionId != zielSectionId &&
        _istSectionAufgeklappt(vorherigeSectionId)) {
      geaendert = true;
    }
    if (!_istSectionAufgeklappt(zielSectionId)) {
      geaendert = true;
    }
    if (!geaendert) {
      return false;
    }

    setState(() {
      if (vorherigeSectionId != null &&
          vorherigeSectionId != zielSectionId &&
          _istSectionAufgeklappt(vorherigeSectionId)) {
        _setzeSectionAufgeklappt(vorherigeSectionId, false);
      }
      if (!_istSectionAufgeklappt(zielSectionId)) {
        _setzeSectionAufgeklappt(zielSectionId, true);
      }
    });
    return true;
  }

  int _summeGruppe(List<Kassenzeile> zeilen) =>
      _stateController.summeGruppe(_stueckzahlen, zeilen);

  int get _umschlagSummeCent =>
      TagesabschlussBerechnung.summeUmschlaegeCent(_umschlaege);

  int get _loseMuenzenGesamtCent =>
      TagesabschlussBerechnung.summeCentBetraege(
        _loseMuenzenNachArtCent.values,
      );

  int get _kassenbestandGesamtCent =>
      TagesabschlussBerechnung.kassenbestandGesamtCent(
        scheineCent: _summeGruppe(_scheine),
        loseMuenzenCent: _loseMuenzenGesamtCent,
        rollenCent: _summeGruppe(_rollenSichtbar),
        umschlaegeCent: _umschlagSummeCent,
      );

  String _formatiereEuro(int cent) => _stateController.formatiereEuro(cent);

  String _formatiereEuroEingabe(int cent) =>
      _stateController.formatiereEuroEingabe(cent);

  Future<void> _bestaetigeUndLeere() async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogKontext) {
        return AlertDialog(
          title: const Text('Eingaben wirklich löschen?'),
          content: const Text('Alle Eingaben werden zurückgesetzt.'),
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

    if (bestaetigt != true || !mounted) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _orchestrierungHelper.leereAlleFelder(
        alleStueckzahlZeilen: _alleStueckzahlZeilen,
        loseMuenzarten: _loseMuenzarten,
        stueckzahlen: _stueckzahlen,
        loseMuenzenNachArtCent: _loseMuenzenNachArtCent,
        leereUmschlagFelder: _leereUmschlagFelder,
        sichereMindestensEinenUmschlag: _sichereMindestensEinenUmschlag,
        synchronisiereControllerAusState: _synchronisiereControllerAusState,
      );
      _dialogGezeigt = false;
    });

    await LokalerSpeicher.loescheWechselgeldZaehlEntwurf(widget.kinoId);
  }

  Future<void> _ladeRollenAusErsterZaehlung() async {
    final KassenstandEntwurf? entwurf =
        await _kassenstandEntwurfUsecase.ladeHeutigenEntwurf(widget.kinoId);
    if (!mounted) return;
    if (entwurf == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Keine Zählung für heute gefunden.')),
        );
      return;
    }
    setState(() {
      for (final MapEntry<String, int> e in entwurf.stueckzahlen.entries) {
        if (e.key.startsWith('roll_') && _stueckzahlen.containsKey(e.key)) {
          _stueckzahlen[e.key] = e.value;
          _stueckzahlController[e.key]?.text =
              e.value != 0 ? e.value.toString() : '';
        }
      }
      _rollenUebernommen = true;
    });
    await _speichereEntwurf();
    _planePruefung();
  }

  Future<void> _zeigeRollenUebernehmenHilfe() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Geldrollenanzahl übernehmen'),
          content: const Text(
            'Übernimmt die Anzahl der Münzrollen aus der heutigen '
            'Bargeldzählung (Schritt 1). Sinnvoll wenn die Rollenanzahl '
            'seit der ersten Zählung unverändert ist.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _loescheRollen() {
    setState(() {
      for (final String key in _stueckzahlen.keys) {
        if (key.startsWith('roll_')) {
          _stueckzahlen[key] = 0;
          _stueckzahlController[key]?.clear();
        }
      }
      _rollenUebernommen = false;
    });
    _speichereEntwurf();
    _planePruefung();
  }

  @override
  Widget build(BuildContext context) {
    if (_laedt) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool tastaturOffen = MediaQuery.of(context).viewInsets.bottom > 0;
    final bool hatUebereinstimmung = _wechselgeldSollwertCent > 0 &&
        _kassenbestandGesamtCent == _wechselgeldSollwertCent;
    final Color hintergrundFarbe = hatUebereinstimmung
        ? Colors.green.shade50
        : AppFarben.seitenHintergrund;

    final Schritt1GruppenWidgets gruppen = _gruppenOrchestrierung.baueGruppen(
      scheine: _scheine,
      loseMuenzarten: _loseMuenzarten,
      loseMuenzartenOhneKupfer: _loseMuenzartenOhneKupfer,
      kupferLoseMuenzarten: _kupferLoseMuenzarten,
      rollenOhneKupfer: _rollenOhneKupfer,
      kupferRollen: _kupferRollen,
      rollenSichtbar: _rollenSichtbar,
      scheineAufgeklappt: _scheineAufgeklappt,
      loseMuenzenAufgeklappt: _loseMuenzenAufgeklappt,
      rollenAufgeklappt: _rollenAufgeklappt,
      umschlaegeAufgeklappt: _umschlaegeAufgeklappt,
      kupferLoseSichtbar: _kupferLoseSichtbar,
      kupferRollenSichtbar: _kupferRollenSichtbar,
      zeigeKupferLose: _zeigeKupferLose,
      stueckzahlen: _stueckzahlen,
      stueckzahlController: _stueckzahlController,
      stueckzahlFocusNode: _stueckzahlFocusNode,
      loseMuenzenController: _loseMuenzenController,
      loseMuenzenFocusNode: _loseMuenzenFocusNode,
      umschlaege: _umschlaege,
      umschlagIds: _umschlagIds,
      umschlagBezeichnungController: _umschlagBezeichnungController,
      umschlagBetragController: _umschlagBetragController,
      umschlagBezeichnungFocusNode: _umschlagBezeichnungFocusNode,
      umschlagBetragFocusNode: _umschlagBetragFocusNode,
      loseMuenzenGesamtCent: _loseMuenzenGesamtCent,
      umschlagSummeCent: _umschlagSummeCent,
      formatiereEuro: _formatiereEuro,
      summeGruppe: _summeGruppe,
      baueFeldMitKey: _baueFeldMitKey,
      textInputActionFuerSchritt1: _textInputAction,
      beiEingabeAbgeschlossen: _beiEingabeAbgeschlossen,
      beiStueckzahlGeaendert: _beiStueckzahlGeaendert,
      beiLoseMuenzartBetragGeaendert: _beiLoseMuenzartBetragGeaendert,
      beiUmschlagBezeichnungGeaendert: _beiUmschlagBezeichnungGeaendert,
      beiUmschlagBetragGeaendert: _beiUmschlagBetragGeaendert,
      umschlagEntfernen: _umschlagEntfernen,
      umschlagHinzufuegen: _umschlagHinzufuegen,
      zeigeKupferRollen: _zeigeKupferRollen,
      toggleScheine: () => _toggleSection(_sectionScheine),
      toggleLoseMuenzen: () => _toggleSection(_sectionLoseMuenzen),
      toggleRollen: () => _toggleSection(_sectionRollen),
      toggleUmschlaege: () => _toggleSection(_sectionUmschlaege),
      rotHervorgehoben: const <FocusNode>{},
    );

    final int differenzCent =
        _kassenbestandGesamtCent - _wechselgeldSollwertCent;

    return TagesabschlussScaffold(
      backgroundColor: hintergrundFarbe,
      appBar: TagesabschlussHeader(
        schrittNummer: 0,
        schrittTitel: 'Wechselgeld zählen',
        kinoName: KinoRepository.nachId(widget.kinoId)?.name ?? 'Schauburg',
        actions: <Widget>[
          TextButton(
            onPressed: _bestaetigeUndLeere,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Clear'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      footerChild: tastaturOffen
          ? SizedBox(
              height: 36,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _weiterZumNaechstenFeld,
                      style: AppFarben.footerButtonStyle,
                      child: const Text('nächstes Feld'),
                    ),
                  ),
                ],
              ),
            )
          : null,
      child: Schritt1BodyContent(
        scrollController: _scrollController,
        devToolsStickySichtbar: false,
        devToolsStickyHoehe: 0,
        devToolsPanel: const SizedBox.shrink(),
        scheineGruppe: gruppen.scheineGruppe,
        loseMuenzenGruppe: gruppen.loseMuenzenGruppe,
        rollenGruppe: _baueRollenGruppe(),
        hinweiseSection: gruppen.hinweiseSection,
        zusammenfassung: _baueZusammenfassung(differenzCent),
        downButtonSichtbar: _istDownButtonSichtbar(),
        scrolleNachUnten: _scrolleNachUnten,
        beiScrollMetrikAenderung: _beiScrollMetrikAenderung,
      ),
    );
  }

  Widget _baueRollenGruppe() {
    final String gesamtbetrag = schritt1_ui.schritt1FormatiereRollenAnzeige(
      _summeGruppe(_rollenSichtbar),
      _formatiereEuro,
    );

    Widget zeilenEintrag(Kassenzeile zeile) {
      return schritt1_ui.Schritt1ZeilenEintrag(
        zeile: zeile,
        stueckzahl: _stueckzahlen[zeile.id] ?? 0,
        controller: _stueckzahlController[zeile.id]!,
        focusNode: _stueckzahlFocusNode[zeile.id]!,
        baueFeldMitKey: _baueFeldMitKey,
        textInputActionFuerSchritt1: _textInputAction,
        beiStueckzahlGeaendert: _beiStueckzahlGeaendert,
        beiEingabeAbgeschlossen: _beiEingabeAbgeschlossen,
        formatiereEuro: _formatiereEuro,
      );
    }

    final Widget inhalt = schritt1_ui.Schritt1RollenInhalt(
      rollenOhneKupfer: _rollenOhneKupfer,
      kupferRollen: _kupferRollen,
      kupferRollenSichtbar: _kupferRollenSichtbar,
      zeilenEintragBuilder: zeilenEintrag,
      summeGruppe: _summeGruppe,
      formatiereRollenAnzeige: (int cent) =>
          schritt1_ui.schritt1FormatiereRollenAnzeige(cent, _formatiereEuro),
      zeigeKupferRollen: _zeigeKupferRollen,
      rollenSichtbar: _rollenSichtbar,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: () => _toggleSection(_sectionRollen),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Rollen (Anzahl der Rollen)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    gesamtbetrag,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _rollenAufgeklappt
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (_rollenAufgeklappt) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: <Widget>[
                  TextButton(
                    onPressed: _rollenUebernommen
                        ? _loescheRollen
                        : _ladeRollenAusErsterZaehlung,
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: Text(
                      _rollenUebernommen ? 'Geldrollen löschen' : 'Übernehmen',
                    ),
                  ),
                  IconButton(
                    iconSize: 18,
                    onPressed: _zeigeRollenUebernehmenHilfe,
                    icon: const Icon(Icons.help_outline),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(padding: const EdgeInsets.all(12), child: inhalt),
          ],
        ],
      ),
    );
  }

  Widget _baueZusammenfassung(int differenzCent) {
    final bool differenzNull = differenzCent == 0;
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
            _ZusammenfassungsZeile(
              label: 'Gezählter Betrag',
              wert: _formatiereEuro(_kassenbestandGesamtCent),
            ),
            _ZusammenfassungsZeile(
              label: 'Wechselgeld',
              wert: '− ${_formatiereEuro(_wechselgeldSollwertCent)}',
            ),
            _ZusammenfassungsZeile(
              label: 'Differenz',
              wert: _formatiereEuro(differenzCent),
              hervorheben: true,
              farbe: differenzNull ? Colors.green.shade700 : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _ZusammenfassungsZeile extends StatelessWidget {
  const _ZusammenfassungsZeile({
    required this.label,
    required this.wert,
    this.hervorheben = false,
    this.farbe,
  });

  final String label;
  final String wert;
  final bool hervorheben;
  final Color? farbe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(
            wert,
            style: TextStyle(
              fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w500,
              color: farbe,
            ),
          ),
        ],
      ),
    );
  }
}
