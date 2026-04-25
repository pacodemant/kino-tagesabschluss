import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/usecases/kassenstand_entwurf_usecase.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenstand_entwurf.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/controller/schritt1_state_controller.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/orchestrierung/schritt1_orchestrierung_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/scroll/schritt1_scroll_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/setup/schritt1_initialisierung_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_body_content.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_footer.dart'
    as schritt1_footer;
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_gruppen_orchestrierung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_zusammenfassung.dart'
    as schritt1_zusammenfassung;
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';

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
  static const int _sectionScheine = 0;
  static const int _sectionLoseMuenzen = 1;
  static const int _sectionRollen = 2;
  static const int _sectionKartenzahlungen = 3;
  static const int _sectionUmschlaege = 4;
  static const EdgeInsets _footerPaddingNormal = EdgeInsets.fromLTRB(
    12,
    4,
    12,
    4,
  );
  static const EdgeInsets _footerPaddingKeyboard = EdgeInsets.fromLTRB(
    12,
    2,
    12,
    2,
  );
  static const double _devToolsStickyHoehe = 86;
  static const Set<String> _kupferRollenIds = <String>{
    'roll_1c',
    'roll_2c',
    'roll_5c',
  };

  final KassenstandEntwurfUsecase _kassenstandEntwurfUsecase =
      const KassenstandEntwurfUsecase();
  final Schritt1StateController _stateController =
      const Schritt1StateController();
  final Schritt1OrchestrierungHelper _orchestrierungHelper =
      const Schritt1OrchestrierungHelper();
  final Schritt1GruppenOrchestrierung _gruppenOrchestrierung =
      const Schritt1GruppenOrchestrierung();
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
  final List<TextEditingController> _kartenzahlungController =
      <TextEditingController>[TextEditingController()];
  final List<FocusNode> _kartenzahlungFocusNode = <FocusNode>[FocusNode()];
  final List<int> _kartenzahlungIds = <int>[0];
  int _naechsteKartenzahlungId = 1;
  int _naechsteUmschlagId = 1;

  int _wechselgeldSollwertCent = 20000;
  final List<int> _kartenzahlungenCent = <int>[0];
  bool _laedt = true;
  bool _scheineAufgeklappt = true;
  bool _loseMuenzenAufgeklappt = false;
  bool _rollenAufgeklappt = false;
  bool _kupferRollenSichtbar = false;
  bool _kartenzahlungenAufgeklappt = false;
  bool _umschlaegeAufgeklappt = false;
  bool _devToolsOffen = false;
  final ScrollController _scrollController = ScrollController();
  final Schritt1ScrollHelper _scrollHelper = Schritt1ScrollHelper();
  bool _zeigeNaechstesFeld = false;
  final Random _zufall = Random();

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
  List<Kassenzeile> get _loseMuenzarten =>
      StueckelungKonfiguration.loseMuenzarten;
  List<Kassenzeile> get _alleStueckzahlZeilen =>
      StueckelungKonfiguration.alleStueckzahlZeilen;
  bool get _devToolsSichtbar => !kReleaseMode;

  void _beiFokuswechselFuerFooter() {
    final bool zeigeNaechstesFeld = _aktivesFeldSchritt1() != null;
    if (zeigeNaechstesFeld == _zeigeNaechstesFeld) {
      return;
    }
    setState(() {
      _zeigeNaechstesFeld = zeigeNaechstesFeld;
    });
  }

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
      kartenzahlungController: _kartenzahlungController,
      kartenzahlungenCent: _kartenzahlungenCent,
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
    FocusManager.instance.addListener(_beiFokuswechselFuerFooter);
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
    for (final TextEditingController controller in _kartenzahlungController) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _kartenzahlungFocusNode) {
      focusNode.dispose();
    }
    _scrollController.removeListener(_beiScrollAenderung);
    _scrollController.dispose();
    FocusManager.instance.removeListener(_beiFokuswechselFuerFooter);
    super.dispose();
  }

  Future<void> _ladeInitialeDaten() async {
    final int geladenerWechselgeldSollwert = await _initialisierungHelper
        .ladeInitialeDaten(
          usecase: _kassenstandEntwurfUsecase,
          kinoId: widget.kinoId,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _wechselgeldSollwertCent = geladenerWechselgeldSollwert;
      _laedt = false;
    });
  }

  void _leereUmschlagFelder() => _initialisierungHelper.leereUmschlagFelder();

  void _uebernehmeUmschlagEntwurf(List<UmschlagEintrag> umschlagEntwurf) =>
      _initialisierungHelper.uebernehmeUmschlagEntwurf(umschlagEntwurf);

  void _fuegeUmschlagEintragOhneSpeichernHinzu(UmschlagEintrag eintrag) =>
      _initialisierungHelper.fuegeUmschlagEintragOhneSpeichernHinzu(eintrag);

  void _sichereMindestensEinenUmschlag() =>
      _initialisierungHelper.sichereMindestensEinenUmschlag();

  void _synchronisiereControllerAusState() =>
      _initialisierungHelper.synchronisiereControllerAusState();

  void _beiScrollAenderung() {
    _scrollHelper.beiScrollAenderung(
      mounted: mounted,
      rebuild: () => setState(() {}),
    );
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

  GlobalKey _holeFeldKey(FocusNode focusNode) {
    return _scrollHelper.holeFeldKey(focusNode);
  }

  Widget _baueFeldMitKey({
    required FocusNode focusNode,
    required Widget child,
  }) {
    return KeyedSubtree(key: _holeFeldKey(focusNode), child: child);
  }

  void _autoFillDev() {
    setState(() {
      _orchestrierungHelper.autoFillDev(
        zufall: _zufall,
        scheine: _scheine,
        rollenSichtbar: _rollenSichtbar,
        loseMuenzarten: _loseMuenzarten,
        stueckzahlen: _stueckzahlen,
        loseMuenzenNachArtCent: _loseMuenzenNachArtCent,
        setzeKartenzahlungAnzahl: _setzeKartenzahlungAnzahl,
        kartenzahlungenCent: _kartenzahlungenCent,
        uebernehmeUmschlagEntwurf: _uebernehmeUmschlagEntwurf,
        sichereMindestensEinenUmschlag: _sichereMindestensEinenUmschlag,
        synchronisiereControllerAusState: _synchronisiereControllerAusState,
      );
    });
  }

  void _leereAlleFelderDev() {
    FocusScope.of(context).unfocus();
    setState(() {
      _orchestrierungHelper.leereAlleFelder(
        alleStueckzahlZeilen: _alleStueckzahlZeilen,
        loseMuenzarten: _loseMuenzarten,
        stueckzahlen: _stueckzahlen,
        loseMuenzenNachArtCent: _loseMuenzenNachArtCent,
        setzeKartenzahlungAnzahl: _setzeKartenzahlungAnzahl,
        kartenzahlungenCent: _kartenzahlungenCent,
        leereUmschlagFelder: _leereUmschlagFelder,
        sichereMindestensEinenUmschlag: _sichereMindestensEinenUmschlag,
        synchronisiereControllerAusState: _synchronisiereControllerAusState,
      );
    });
  }

  Widget _baueDevToolsPanel() => _orchestrierungHelper.baueDevToolsPanel(
    autoFillDev: _autoFillDev,
    leereAlleFelderDev: _leereAlleFelderDev,
  );

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

  // Delegiert State-/Controller-Logik in eine ausgelagerte Helper-Datei.
  void _beiStueckzahlGeaendert(Kassenzeile zeile, String wert) {
    final int geparsterWert = _stateController.parseGanzzahl(wert);
    setState(() {
      _stateController.setzeStueckzahl(_stueckzahlen, zeile.id, geparsterWert);
    });
    _speichereEntwurf();
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
  }

  void _setzeKartenzahlungAnzahl(int anzahl) =>
      _stateController.setzeKartenzahlungAnzahl(
        anzahl: anzahl,
        kartenzahlungController: _kartenzahlungController,
        kartenzahlungFocusNode: _kartenzahlungFocusNode,
        kartenzahlungenCent: _kartenzahlungenCent,
        kartenzahlungIds: _kartenzahlungIds,
        naechsteKartenzahlungId: () => _naechsteKartenzahlungId++,
        entferneFeldKey: _scrollHelper.entferneFeldKey,
      );

  void _kartenzahlungHinzufuegen() {
    setState(() {
      _stateController.setzeKartenzahlungAnzahl(
        anzahl: _kartenzahlungController.length + 1,
        kartenzahlungController: _kartenzahlungController,
        kartenzahlungFocusNode: _kartenzahlungFocusNode,
        kartenzahlungenCent: _kartenzahlungenCent,
        kartenzahlungIds: _kartenzahlungIds,
        naechsteKartenzahlungId: () => _naechsteKartenzahlungId++,
        entferneFeldKey: _scrollHelper.entferneFeldKey,
      );
    });
  }

  void _kartenzahlungEntfernen(int index) {
    if (!_stateController.kannKartenzahlungEntfernen(
      _kartenzahlungController,
      index,
    )) {
      return;
    }
    setState(() {
      _stateController.entferneKartenzahlung(
        kartenzahlungController: _kartenzahlungController,
        kartenzahlungFocusNode: _kartenzahlungFocusNode,
        kartenzahlungenCent: _kartenzahlungenCent,
        kartenzahlungIds: _kartenzahlungIds,
        index: index,
        entferneFeldKey: _scrollHelper.entferneFeldKey,
      );
    });
  }

  // Setzt die Sichtbarkeit der Kupfer-Rollen ohne Layout-/Logikaenderung.
  void _zeigeKupferRollen() {
    setState(() {
      _kupferRollenSichtbar = true;
    });
  }

  // Aktualisiert Kartenzahlung ohne zusaetzlichen Scroll-Ensure bei Eingabe.
  void _beiKartenzahlungBetragGeaendert(int index, String wert) {
    setState(() {
      _kartenzahlungenCent[index] = _parseCentZiffern(wert);
    });
  }

  int _parseCentZiffern(String wert) => _stateController.parseCentZiffern(wert);

  List<FocusNode> _fokusReihenfolgeSchritt1() =>
      _stateController.fokusReihenfolge(
        scheine: _scheine,
        stueckzahlFocusNode: _stueckzahlFocusNode,
        loseMuenzarten: _loseMuenzarten,
        loseMuenzenFocusNode: _loseMuenzenFocusNode,
        rollenSichtbar: _rollenSichtbar,
        kartenzahlungFocusNode: _kartenzahlungFocusNode,
        umschlaege: _umschlaege,
        umschlagBezeichnungFocusNode: _umschlagBezeichnungFocusNode,
        umschlagBetragFocusNode: _umschlagBetragFocusNode,
      );

  bool _istLetztesFeldSchritt1(FocusNode focusNode) =>
      _stateController.istLetztesFeld(_fokusReihenfolgeSchritt1(), focusNode);

  FocusNode? _naechstesFeldSchritt1(FocusNode focusNode) =>
      _stateController.naechstesFeld(_fokusReihenfolgeSchritt1(), focusNode);

  TextInputAction _textInputActionFuerSchritt1(FocusNode focusNode) =>
      _stateController.textInputActionFuerSchritt1(
        _istLetztesFeldSchritt1(focusNode),
      );

  void _beiEingabeAbgeschlossenSchritt1(FocusNode focusNode) => _stateController
      .beiEingabeAbgeschlossen(context, _naechstesFeldSchritt1(focusNode));

  FocusNode? _aktivesFeldSchritt1() =>
      _stateController.aktivesFeld(_fokusReihenfolgeSchritt1());

  void _weiterZumNaechstenFeldUnten() =>
      _stateController.weiterZumNaechstenFeld(
        context: context,
        reihenfolge: _fokusReihenfolgeSchritt1(),
        aktivesFeld: _aktivesFeldSchritt1(),
        naechstesFeld: _naechstesFeldSchritt1,
        fokussiereTextfeld: _fokussiereTextfeld,
      );

  void _fokussiereTextfeld(FocusNode fokusNode) =>
      _stateController.fokussiereTextfeld(
        context: context,
        fokusNode: fokusNode,
        aktivesFeld: _aktivesFeldSchritt1,
        oeffneSectionFuerFokusfeld: _oeffneSectionFuerFokusfeld,
        fokussiereTextfeldRekursiv: _fokussiereTextfeld,
        mounted: mounted,
      );

  // Ermittelt die Section-ID fuer ein Fokusfeld (0..4) oder null bei unbekannt.
  int? _sectionIdFuerFokusfeld(FocusNode fokusNode) {
    if (_scheine.any(
      (Kassenzeile zeile) =>
          identical(_stueckzahlFocusNode[zeile.id], fokusNode),
    )) {
      return _sectionScheine;
    }
    if (_loseMuenzarten.any(
      (Kassenzeile zeile) =>
          identical(_loseMuenzenFocusNode[zeile.id], fokusNode),
    )) {
      return _sectionLoseMuenzen;
    }
    if (_rollenSichtbar.any(
      (Kassenzeile zeile) =>
          identical(_stueckzahlFocusNode[zeile.id], fokusNode),
    )) {
      return _sectionRollen;
    }
    if (_kartenzahlungFocusNode.any(
      (FocusNode node) => identical(node, fokusNode),
    )) {
      return _sectionKartenzahlungen;
    }
    if (_umschlagBezeichnungFocusNode.any(
          (FocusNode node) => identical(node, fokusNode),
        ) ||
        _umschlagBetragFocusNode.any(
          (FocusNode node) => identical(node, fokusNode),
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
      case _sectionKartenzahlungen:
        return _kartenzahlungenAufgeklappt;
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
      case _sectionKartenzahlungen:
        _kartenzahlungenAufgeklappt = wert;
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

  // Oeffnet die Ziel-Section; bei Section-Wechsel wird die vorherige geschlossen.
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

  int get _umschlagSummeCent {
    return TagesabschlussBerechnung.summeUmschlaegeCent(_umschlaege);
  }

  int get _kassenbestandGesamtCent {
    return TagesabschlussBerechnung.kassenbestandGesamtCent(
      scheineCent: _summeGruppe(_scheine),
      loseMuenzenCent: _loseMuenzenGesamtCent,
      rollenCent: _summeGruppe(_rollenSichtbar),
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

  int get _kartenzahlungenSummeCent =>
      TagesabschlussBerechnung.summeCentBetraege(_kartenzahlungenCent);

  int get _gesamtUmsatzMitKarteCent =>
      _barumsatzBereinigtCent + _kartenzahlungenSummeCent;

  String _formatiereEuro(int cent) => _stateController.formatiereEuro(cent);

  String _formatiereEuroEingabe(int cent) =>
      _stateController.formatiereEuroEingabe(cent);

  Future<void> _bestaetigeUndLeereEingaben() async {
    await _orchestrierungHelper.bestaetigeUndLeereEingaben(
      context: context,
      isMounted: () => mounted,
      unfocus: () => FocusScope.of(context).unfocus(),
      mutateState: setState,
      resetStateData: () {
        _orchestrierungHelper.leereAlleFelder(
          alleStueckzahlZeilen: _alleStueckzahlZeilen,
          loseMuenzarten: _loseMuenzarten,
          stueckzahlen: _stueckzahlen,
          loseMuenzenNachArtCent: _loseMuenzenNachArtCent,
          setzeKartenzahlungAnzahl: _setzeKartenzahlungAnzahl,
          kartenzahlungenCent: _kartenzahlungenCent,
          leereUmschlagFelder: _leereUmschlagFelder,
          sichereMindestensEinenUmschlag: _sichereMindestensEinenUmschlag,
          synchronisiereControllerAusState: _synchronisiereControllerAusState,
        );
      },
      speichereEntwurf: _speichereEntwurf,
    );
  }

  Future<void> _weiterZuSchritt2() async {
    await _orchestrierungHelper.weiterZuSchritt2(
      context: context,
      usecase: _kassenstandEntwurfUsecase,
      kassenbestandGesamtCent: _kassenbestandGesamtCent,
      speichereEntwurf: _speichereEntwurf,
      isMounted: () => mounted,
      navigiereZuSchritt2: () {
        Navigator.of(context).pushNamed(
          TagesabschlussSchritt2Seite.routenName,
          arguments: TagesabschlussSchritt2Argumente(
            kinoId: widget.kinoId,
            kinoName: widget.kinoName,
            scheineCent: _summeGruppe(_scheine),
            loseMuenzenCent: _loseMuenzenGesamtCent,
            rollenCent: _summeGruppe(_rollenSichtbar),
            umschlaegeCent: _umschlagSummeCent,
            wechselgeldSollwertCent: _wechselgeldSollwertCent,
            barBestandAbzglWechselgeldCent: _barumsatzBereinigtCent,
          ),
        );
      },
    );
  }

  String _formatiereLeereListe(List<String> bezeichnungen) {
    if (bezeichnungen.length == 1) {
      return bezeichnungen.first;
    }
    return '${bezeichnungen.sublist(0, bezeichnungen.length - 1).join(', ')} und ${bezeichnungen.last}';
  }

  Future<bool> _zeigeEingabePruefDialog({
    required String titel,
    required String inhalt,
  }) async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogKontext) {
        return AlertDialog(
          title: Text(titel),
          content: Text(inhalt),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogKontext).pop(false),
              child: const Text('Korrigieren'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogKontext).pop(true),
              child: const Text('Bestätigen'),
            ),
          ],
        );
      },
    );
    return bestaetigt == true;
  }

  Future<void> _pruefeEingabenUndWeiterZuSchritt2() async {
    if (!mounted) {
      return;
    }

    // Bereich 1: Scheine
    final List<Kassenzeile> leereScheine = _scheine
        .where(
          (Kassenzeile zeile) => _stueckzahlController[zeile.id]!.text.isEmpty,
        )
        .toList();

    if (leereScheine.isNotEmpty) {
      final String auflistung = _formatiereLeereListe(
        leereScheine
            .map((Kassenzeile zeile) => zeile.bezeichnung)
            .toList(),
      );
      final bool bestaetigt = await _zeigeEingabePruefDialog(
        titel: 'Scheine unvollständig',
        inhalt:
            'Für $auflistung wurde kein Wert eingegeben. Ist das korrekt?',
      );
      if (!mounted) {
        return;
      }
      if (!bestaetigt) {
        _fokussiereTextfeld(_stueckzahlFocusNode[leereScheine.first.id]!);
        return;
      }
      for (final Kassenzeile zeile in leereScheine) {
        _stueckzahlController[zeile.id]!.text = '0';
      }
    }

    // Bereich 2: Lose Münzen
    final List<Kassenzeile> leereMuenzen = _loseMuenzarten
        .where(
          (Kassenzeile zeile) =>
              _loseMuenzenController[zeile.id]!.text.isEmpty,
        )
        .toList();

    if (leereMuenzen.isNotEmpty) {
      final String auflistung = _formatiereLeereListe(
        leereMuenzen
            .map((Kassenzeile zeile) => zeile.bezeichnung)
            .toList(),
      );
      final bool bestaetigt = await _zeigeEingabePruefDialog(
        titel: 'Lose Münzen unvollständig',
        inhalt:
            'Für $auflistung wurde kein Wert eingegeben. Ist das korrekt?',
      );
      if (!mounted) {
        return;
      }
      if (!bestaetigt) {
        _fokussiereTextfeld(_loseMuenzenFocusNode[leereMuenzen.first.id]!);
        return;
      }
      for (final Kassenzeile zeile in leereMuenzen) {
        _loseMuenzenController[zeile.id]!.text = '0';
      }
    }

    // Bereich 3: Kartenzahlung
    final bool keineKartenzahlung = _kartenzahlungenCent.every(
      (int cent) => cent == 0,
    );

    if (keineKartenzahlung) {
      final bool bestaetigt = await _zeigeEingabePruefDialog(
        titel: 'Kartenzahlung fehlt',
        inhalt: 'Es wurde keine Kartenzahlung erfasst. Ist das korrekt?',
      );
      if (!mounted) {
        return;
      }
      if (!bestaetigt) {
        _fokussiereTextfeld(_kartenzahlungFocusNode.first);
        return;
      }
    }

    await _weiterZuSchritt2();
  }

  Future<void> _zeigeSchrittAuswahlBottomSheet() async {
    await _orchestrierungHelper.zeigeSchrittAuswahlBottomSheet(
      context: context,
      weiterZuSchritt2: _weiterZuSchritt2,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_laedt) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool devToolsStickySichtbar = _devToolsSichtbar && _devToolsOffen;
    final double bottomInset = mediaQuery.viewPadding.bottom;
    final bool tastaturOffen = mediaQuery.viewInsets.bottom > 0;
    final Schritt1GruppenWidgets gruppen = _gruppenOrchestrierung.baueGruppen(
      scheine: _scheine,
      loseMuenzarten: _loseMuenzarten,
      rollenOhneKupfer: _rollenOhneKupfer,
      kupferRollen: _kupferRollen,
      rollenSichtbar: _rollenSichtbar,
      scheineAufgeklappt: _scheineAufgeklappt,
      loseMuenzenAufgeklappt: _loseMuenzenAufgeklappt,
      rollenAufgeklappt: _rollenAufgeklappt,
      kartenzahlungenAufgeklappt: _kartenzahlungenAufgeklappt,
      umschlaegeAufgeklappt: _umschlaegeAufgeklappt,
      kupferRollenSichtbar: _kupferRollenSichtbar,
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
      kartenzahlungController: _kartenzahlungController,
      kartenzahlungIds: _kartenzahlungIds,
      kartenzahlungFocusNode: _kartenzahlungFocusNode,
      kartenzahlungenCent: _kartenzahlungenCent,
      loseMuenzenGesamtCent: _loseMuenzenGesamtCent,
      kartenzahlungenSummeCent: _kartenzahlungenSummeCent,
      umschlagSummeCent: _umschlagSummeCent,
      formatiereEuro: _formatiereEuro,
      summeGruppe: _summeGruppe,
      baueFeldMitKey: _baueFeldMitKey,
      textInputActionFuerSchritt1: _textInputActionFuerSchritt1,
      beiEingabeAbgeschlossen: _beiEingabeAbgeschlossenSchritt1,
      beiStueckzahlGeaendert: _beiStueckzahlGeaendert,
      beiLoseMuenzartBetragGeaendert: _beiLoseMuenzartBetragGeaendert,
      beiKartenzahlungBetragGeaendert: _beiKartenzahlungBetragGeaendert,
      kartenzahlungEntfernen: _kartenzahlungEntfernen,
      kartenzahlungHinzufuegen: _kartenzahlungHinzufuegen,
      beiUmschlagBezeichnungGeaendert: _beiUmschlagBezeichnungGeaendert,
      beiUmschlagBetragGeaendert: _beiUmschlagBetragGeaendert,
      umschlagEntfernen: _umschlagEntfernen,
      umschlagHinzufuegen: _umschlagHinzufuegen,
      zeigeKupferRollen: _zeigeKupferRollen,
      toggleScheine: () {
        _toggleSection(_sectionScheine);
      },
      toggleLoseMuenzen: () {
        _toggleSection(_sectionLoseMuenzen);
      },
      toggleRollen: () {
        _toggleSection(_sectionRollen);
      },
      toggleKartenzahlungen: () {
        _toggleSection(_sectionKartenzahlungen);
      },
      toggleUmschlaege: () {
        _toggleSection(_sectionUmschlaege);
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      resizeToAvoidBottomInset: true,
      appBar: TagesabschlussHeader(
        schrittNummer: 1,
        schrittTitel: 'Bargeldzählung',
        onTap: _zeigeSchrittAuswahlBottomSheet,
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Clear'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Schritt1BodyContent(
              scrollController: _scrollController,
              devToolsStickySichtbar: devToolsStickySichtbar,
              devToolsStickyHoehe: _devToolsStickyHoehe,
              devToolsPanel: _baueDevToolsPanel(),
              scheineGruppe: gruppen.scheineGruppe,
              loseMuenzenGruppe: gruppen.loseMuenzenGruppe,
              rollenGruppe: gruppen.rollenGruppe,
              hinweiseSection: gruppen.hinweiseSection,
              zusammenfassung: schritt1_zusammenfassung.Schritt1Zusammenfassung(
                kassenbestandGesamt: _formatiereEuro(_kassenbestandGesamtCent),
                wechselgeldSollwert: _formatiereEuro(_wechselgeldSollwertCent),
                barumsatzBereinigt: _formatiereEuro(_barumsatzBereinigtCent),
                kartenzahlungen: _formatiereEuro(_kartenzahlungenSummeCent),
                gesamtInklKarte: _formatiereEuro(_gesamtUmsatzMitKarteCent),
                barumsatzNegativ: _barumsatzBereinigtCent < 0,
              ),
              downButtonSichtbar: _istDownButtonSichtbar(),
              scrolleNachUnten: _scrolleNachUnten,
              beiScrollMetrikAenderung: _beiScrollMetrikAenderung,
            ),
          ),
          schritt1_footer.Schritt1Footer(
            tastaturOffen: tastaturOffen,
            footerPadding: tastaturOffen
                ? _footerPaddingKeyboard
                : _footerPaddingNormal,
            footerBottomInset: tastaturOffen ? 0 : bottomInset,
            zeigeNaechstesFeld: _zeigeNaechstesFeld,
            weiterZumNaechstenFeldUnten: _weiterZumNaechstenFeldUnten,
            weiterZuSchritt2: _pruefeEingabenUndWeiterZuSchritt2,
          ),
        ],
      ),
    );
  }
}
