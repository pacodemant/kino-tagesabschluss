import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/usecases/kassenstand_entwurf_usecase.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenstand_entwurf.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_hinweise_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_muenzen_lose_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_muenzen_rollen_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_scheine_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_umschlaege_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_uebersicht_section.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/ganzzahl_eingabefeld.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';

part 'tagesabschluss_schritt1/controller/schritt1_state_controller.dart';

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
    extends State<TagesabschlussSchritt1Seite>
    with WidgetsBindingObserver {
  static const double _footerContentHoeheNormal = 44;
  static const double _footerContentHoeheKeyboard = 40;
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
  static const Duration _footerAnimationDauer = Duration(milliseconds: 200);
  static const Curve _footerAnimationKurve = Curves.easeOutCubic;
  static const double _appBarHoehe = 48;
  static const double _devToolsStickyHoehe = 86;
  static const Set<String> _kupferRollenIds = <String>{
    'roll_1c',
    'roll_2c',
    'roll_5c',
  };

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
  final Map<FocusNode, GlobalKey> _feldKeys = <FocusNode, GlobalKey>{};
  FocusNode? _letztesAktivesFeld;
  double _keyboardInset = 0;
  bool _ensureNachEingabeGeplant = false;
  DateTime _letztesEnsureNachEingabe = DateTime.fromMillisecondsSinceEpoch(0);
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _keyboardInset = _leseKeyboardInset();
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
    FocusManager.instance.addListener(_beiGlobalemFokuswechsel);
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
    FocusManager.instance.removeListener(_beiGlobalemFokuswechsel);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (!mounted) {
      return;
    }
    final double neuerKeyboardInset = _leseKeyboardInset();
    if (neuerKeyboardInset != _keyboardInset) {
      setState(() {
        _keyboardInset = neuerKeyboardInset;
      });
    }
    if (neuerKeyboardInset > 0 && _aktivesFeldSchritt1() != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _ensureAktivesFeldSichtbar();
      });
    }
  }

  double _leseKeyboardInset() {
    final ui.FlutterView view =
        WidgetsBinding.instance.platformDispatcher.views.first;
    return view.viewInsets.bottom / view.devicePixelRatio;
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
    _sichereMindestensEinenUmschlag();

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
      _feldKeys.remove(focusNode);
      focusNode.dispose();
    }
    for (final FocusNode focusNode in _umschlagBezeichnungFocusNode) {
      _feldKeys.remove(focusNode);
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
      _fuegeUmschlagEintragOhneSpeichernHinzu(eintrag);
    }
  }

  void _fuegeUmschlagEintragOhneSpeichernHinzu(UmschlagEintrag eintrag) {
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

  void _sichereMindestensEinenUmschlag() {
    if (_umschlaege.isNotEmpty) {
      return;
    }
    _fuegeUmschlagEintragOhneSpeichernHinzu(
      const UmschlagEintrag(bezeichnung: '', betragCent: 0),
    );
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

    for (int i = 0; i < _kartenzahlungController.length; i++) {
      final String text = _kartenzahlungenCent[i] == 0
          ? ''
          : _formatiereEuroEingabe(_kartenzahlungenCent[i]);
      if (_kartenzahlungController[i].text != text) {
        _setzeControllerText(_kartenzahlungController[i], text);
      }
    }
  }

  void _setzeControllerText(TextEditingController controller, String text) {
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _beiGlobalemFokuswechsel() {
    if (!mounted) {
      return;
    }
    final FocusNode? aktivesFeld = _aktivesFeldSchritt1();
    if (!identical(_letztesAktivesFeld, aktivesFeld)) {
      _letztesAktivesFeld = aktivesFeld;
      if (aktivesFeld != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          _ensureAktivesFeldSichtbar();
        });
      }
    }
    setState(() {});
  }

  void _beiScrollAenderung() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  GlobalKey _holeFeldKey(FocusNode focusNode) {
    return _feldKeys.putIfAbsent(focusNode, () => GlobalKey());
  }

  Widget _baueFeldMitKey({
    required FocusNode focusNode,
    required Widget child,
  }) {
    return KeyedSubtree(key: _holeFeldKey(focusNode), child: child);
  }

  void _ensureAktivesFeldSichtbar() {
    final FocusNode? aktivesFeld = _aktivesFeldSchritt1();
    if (aktivesFeld == null) {
      return;
    }
    final BuildContext? feldKontext = _feldKeys[aktivesFeld]?.currentContext;
    if (feldKontext == null) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }
    final RenderObject? renderObject = feldKontext.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }
    final RenderObject? viewportObject = _scrollController
        .position
        .context
        .storageContext
        .findRenderObject();
    if (viewportObject is! RenderBox) {
      return;
    }

    final Offset feldPositionImViewport = renderObject.localToGlobal(
      Offset.zero,
      ancestor: viewportObject,
    );
    final double fieldTop =
        _scrollController.position.pixels + feldPositionImViewport.dy;
    final double fieldBottom = fieldTop + renderObject.size.height;

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double keyboardInset = _keyboardInset;
    final bool tastaturOffen = keyboardInset > 0;
    final double footerContentHoehe = tastaturOffen
        ? _footerContentHoeheKeyboard
        : _footerContentHoeheNormal;
    final double footerBottomInset = tastaturOffen
        ? 0
        : mediaQuery.viewPadding.bottom;
    final double footerTotalHoehe = footerContentHoehe + footerBottomInset;
    final double stickyHeaderHeight = (_devToolsSichtbar && _devToolsOffen)
        ? _devToolsStickyHoehe
        : 0;
    final bool istUmschlagFeld =
        _umschlagBezeichnungFocusNode.contains(aktivesFeld) ||
        _umschlagBetragFocusNode.contains(aktivesFeld);
    final bool istKartenzahlungFeld = _kartenzahlungFocusNode.contains(
      aktivesFeld,
    );
    final double bottomSafety = (istUmschlagFeld || istKartenzahlungFeld)
        ? 100
        : 0;

    final double scrollOffset = _scrollController.position.pixels;
    final double viewportHeight = _scrollController.position.viewportDimension;
    final double visibleTop =
        scrollOffset + statusBarHeight + _appBarHoehe + stickyHeaderHeight + 8;
    final double visibleBottom =
        scrollOffset -
        (keyboardInset + footerTotalHoehe + 8 + bottomSafety) +
        viewportHeight;

    double? targetOffset;
    if (fieldTop < visibleTop) {
      targetOffset =
          fieldTop - (statusBarHeight + _appBarHoehe + stickyHeaderHeight + 8);
    } else if (fieldBottom > visibleBottom) {
      targetOffset =
          fieldBottom -
          viewportHeight +
          (keyboardInset + footerTotalHoehe + 16 + bottomSafety);
    }
    if (targetOffset == null) {
      return;
    }
    final double begrenzt = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );
    if ((begrenzt - _scrollController.position.pixels).abs() < 1) {
      return;
    }
    _scrollController.animateTo(
      begrenzt,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
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
      for (final Kassenzeile zeile in _rollenSichtbar) {
        _stueckzahlen[zeile.id] = _zufallszahl(0, 3);
      }
      for (final Kassenzeile zeile in _loseMuenzarten) {
        _loseMuenzenNachArtCent[zeile.id] = _zufallszahl(0, 3000);
      }
      _setzeKartenzahlungAnzahl(1);
      _kartenzahlungenCent[0] = _zufallszahl(0, 250000);

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
      _sichereMindestensEinenUmschlag();
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
      _setzeKartenzahlungAnzahl(1);
      _kartenzahlungenCent[0] = 0;
      _leereUmschlagFelder();
      _sichereMindestensEinenUmschlag();
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

  // Delegiert State-/Controller-Logik in eine ausgelagerte Helper-Datei.
  void _beiStueckzahlGeaendert(Kassenzeile zeile, String wert) {
    final int geparsterWert = _schritt1ParseGanzzahl(wert);
    setState(() {
      _schritt1SetzeStueckzahl(this, zeile.id, geparsterWert);
    });
    _triggerEnsureBeiEingabe(_stueckzahlFocusNode[zeile.id]!);
    _speichereEntwurf();
  }

  void _beiLoseMuenzartBetragGeaendert(String muenzartId, String wert) {
    setState(() {
      _schritt1SetzeLoseMuenzartBetrag(this, muenzartId, _parseCentZiffern(wert));
    });
    _triggerEnsureBeiEingabe(_loseMuenzenFocusNode[muenzartId]!);
    _speichereEntwurf();
  }

  void _umschlagHinzufuegen() {
    setState(() {
      _schritt1FuegeUmschlagEintragHinzu(this);
    });
    _speichereEntwurf();
  }

  void _umschlagEntfernen(int index) {
    if (!_schritt1KannUmschlagEntfernen(this, index)) {
      return;
    }
    setState(() {
      _schritt1EntferneUmschlag(this, index);
    });
    _speichereEntwurf();
  }

  void _beiUmschlagBezeichnungGeaendert(int index, String wert) {
    if (!_schritt1IstUmschlagIndexGueltig(this, index)) {
      return;
    }
    setState(() {
      _schritt1SetzeUmschlagBezeichnung(this, index, wert);
    });
    _triggerEnsureBeiEingabe(_umschlagBezeichnungFocusNode[index]);
    _speichereEntwurf();
  }

  void _beiUmschlagBetragGeaendert(int index, String wert) {
    if (!_schritt1IstUmschlagIndexGueltig(this, index)) {
      return;
    }
    final int betragCent = _parseCentZiffern(wert);
    setState(() {
      _schritt1SetzeUmschlagBetrag(this, index, betragCent);
    });
    _triggerEnsureBeiEingabe(_umschlagBetragFocusNode[index]);
    _speichereEntwurf();
  }

  void _triggerEnsureBeiEingabe(FocusNode focusNode) =>
      _schritt1TriggerEnsureBeiEingabe(this, focusNode);

  void _setzeKartenzahlungAnzahl(int anzahl) =>
      _schritt1SetzeKartenzahlungAnzahl(this, anzahl);

  void _kartenzahlungHinzufuegen() {
    setState(() {
      _schritt1SetzeKartenzahlungAnzahl(this, _kartenzahlungController.length + 1);
    });
  }

  void _kartenzahlungEntfernen(int index) {
    if (!_schritt1KannKartenzahlungEntfernen(this, index)) {
      return;
    }
    setState(() {
      _schritt1EntferneKartenzahlung(this, index);
    });
  }

  int _parseCentZiffern(String wert) => _schritt1ParseCentZiffern(wert);

  List<FocusNode> _fokusReihenfolgeSchritt1() => _schritt1FokusReihenfolge(
    this,
  );

  bool _istLetztesFeldSchritt1(FocusNode focusNode) =>
      _schritt1IstLetztesFeld(this, focusNode);

  FocusNode? _naechstesFeldSchritt1(FocusNode focusNode) =>
      _schritt1NaechstesFeld(this, focusNode);

  TextInputAction _textInputActionFuerSchritt1(FocusNode focusNode) =>
      _schritt1TextInputActionFuerSchritt1(this, focusNode);

  void _beiEingabeAbgeschlossenSchritt1(FocusNode focusNode) =>
      _schritt1BeiEingabeAbgeschlossen(this, focusNode);

  FocusNode? _aktivesFeldSchritt1() => _schritt1AktivesFeld(this);

  void _weiterZumNaechstenFeldUnten() => _schritt1WeiterZumNaechstenFeld(this);

  void _fokussiereTextfeld(FocusNode fokusNode) =>
      _schritt1FokussiereTextfeld(this, fokusNode);

  int _summeGruppe(List<Kassenzeile> zeilen) =>
      _schritt1SummeGruppe(_stueckzahlen, zeilen);

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

  String _formatiereEuro(int cent) => _schritt1FormatiereEuro(cent);

  String _formatiereEuroEingabe(int cent) => _schritt1FormatiereEuroEingabe(
    cent,
  );

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
      _setzeKartenzahlungAnzahl(1);
      _kartenzahlungenCent[0] = 0;
      _leereUmschlagFelder();
      _sichereMindestensEinenUmschlag();
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
        rollenCent: _summeGruppe(_rollenSichtbar),
        umschlaegeCent: _umschlagSummeCent,
        wechselgeldSollwertCent: _wechselgeldSollwertCent,
        barBestandAbzglWechselgeldCent: _barumsatzBereinigtCent,
      ),
    );
  }

  Future<void> _zeigeSchrittAuswahlBottomSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text(
                  '1/4 · Bargeldzählung',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Aktueller Schritt'),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.arrow_forward),
                title: const Text('2/4 · Einnahmen/Abschluss'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _weiterZuSchritt2();
                },
              ),
              const ListTile(title: Text('3/4 · Finalisieren'), enabled: false),
              const ListTile(title: Text('4/4 · Schritt 4'), enabled: false),
            ],
          ),
        );
      },
    );
  }

  Widget _baueGruppenInhalt(
    List<Kassenzeile> zeilen,
    String gesamtbetragLabel, {
    String Function(int cent)? formatierer,
  }) {
    final String Function(int cent) nutzeFormatierer =
        formatierer ?? _formatiereEuro;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in zeilen) ...<Widget>[
          _baueZeilenEintrag(zeile),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        Text(
          '$gesamtbetragLabel: ${nutzeFormatierer(_summeGruppe(zeilen))}',
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
          child: Text(
            zeile.bezeichnung,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 96,
          child: _baueFeldMitKey(
            focusNode: focusNode,
            child: GanzzahlEingabefeld(
              textController: _stueckzahlController[zeile.id]!,
              focusNode: focusNode,
              schriftgroesse: 16,
              textInputAction: _textInputActionFuerSchritt1(focusNode),
              onChanged: (String wert) => _beiStueckzahlGeaendert(zeile, wert),
              onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt1(focusNode),
            ),
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
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 148,
                    child: _baueFeldMitKey(
                      focusNode: focusNode,
                      child: BetragCentEingabefeld(
                        textController: _loseMuenzenController[zeile.id]!,
                        focusNode: focusNode,
                        textInputAction: _textInputActionFuerSchritt1(
                          focusNode,
                        ),
                        onSubmitted: (_) =>
                            _beiEingabeAbgeschlossenSchritt1(focusNode),
                        onChanged: (String wert) =>
                            _beiLoseMuenzartBetragGeaendert(zeile.id, wert),
                        schriftgroesse: 15,
                        hinweisText: '0,00 €',
                      ),
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

  Widget _baueEinklappbarenBereich({
    required String titel,
    required int gesamtbetragCent,
    required bool aufgeklappt,
    required VoidCallback beimUmschalten,
    required Widget inhalt,
    String Function(int cent)? gesamtformatierer,
  }) {
    final String Function(int cent) formatierer =
        gesamtformatierer ?? _formatiereEuro;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
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
                    formatierer(gesamtbetragCent),
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
    return Schritt1ScheineSection(
      gesamtbetrag: _formatiereEuro(_summeGruppe(_scheine)),
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
    return Schritt1MuenzenLoseSection(
      gesamtbetrag: _formatiereEuro(_loseMuenzenGesamtCent),
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
    return Schritt1MuenzenRollenSection(
      gesamtbetrag: _formatiereRollenAnzeige(_summeGruppe(_rollenSichtbar)),
      aufgeklappt: _rollenAufgeklappt,
      beimUmschalten: () {
        setState(() {
          _rollenAufgeklappt = !_rollenAufgeklappt;
        });
      },
      inhalt: _baueRollenInhalt(),
    );
  }

  Widget _baueRollenInhalt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in _rollenOhneKupfer) ...<Widget>[
          _baueZeilenEintrag(zeile),
          const SizedBox(height: 8),
        ],
        if (!_kupferRollenSichtbar)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _kupferRollenSichtbar = true;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Kupfer-Rollen hinzufügen'),
            ),
          ),
        if (_kupferRollenSichtbar) ...<Widget>[
          const SizedBox(height: 8),
          for (final Kassenzeile zeile in _kupferRollen) ...<Widget>[
            _baueZeilenEintrag(zeile),
            const SizedBox(height: 8),
          ],
        ],
        const SizedBox(height: 4),
        Text(
          'Gesamtbetrag Rollen: ${_formatiereRollenAnzeige(_summeGruppe(_rollenSichtbar))}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatiereRollenAnzeige(int cent) {
    if (cent % 100 == 0) {
      return '${cent ~/ 100} €';
    }
    return _formatiereEuro(cent);
  }

  Widget _baueUmschlagGruppe() {
    return _baueEinklappbarenBereich(
      titel: 'Umschläge (Beträge)',
      gesamtbetragCent: _umschlagSummeCent,
      aufgeklappt: _umschlaegeAufgeklappt,
      beimUmschalten: () {
        setState(() {
          _umschlaegeAufgeklappt = !_umschlaegeAufgeklappt;
        });
      },
      inhalt: Schritt1UmschlaegeSection(
        umschlaege: _umschlaege,
        umschlagIds: _umschlagIds,
        umschlagBezeichnungController: _umschlagBezeichnungController,
        umschlagBetragController: _umschlagBetragController,
        umschlagBezeichnungFocusNode: _umschlagBezeichnungFocusNode,
        umschlagBetragFocusNode: _umschlagBetragFocusNode,
        baueFeldMitKey: _baueFeldMitKey,
        textInputActionFuerSchritt1: _textInputActionFuerSchritt1,
        beiEingabeAbgeschlossen: _beiEingabeAbgeschlossenSchritt1,
        beiUmschlagBezeichnungGeaendert: _beiUmschlagBezeichnungGeaendert,
        beiUmschlagBetragGeaendert: _beiUmschlagBetragGeaendert,
        umschlagEntfernen: _umschlagEntfernen,
        umschlagHinzufuegen: _umschlagHinzufuegen,
        formatiereEuro: _formatiereEuro,
        umschlagSummeCent: _umschlagSummeCent,
      ),
    );
  }

  Widget _baueKartenzahlungenInhalt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < _kartenzahlungController.length; i++) ...<Widget>[
          Row(
            key: ValueKey<int>(_kartenzahlungIds[i]),
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Kartenzahlung',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 148,
                child: _baueFeldMitKey(
                  focusNode: _kartenzahlungFocusNode[i],
                  child: BetragCentEingabefeld(
                    textController: _kartenzahlungController[i],
                    focusNode: _kartenzahlungFocusNode[i],
                    textInputAction: _textInputActionFuerSchritt1(
                      _kartenzahlungFocusNode[i],
                    ),
                    onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt1(
                      _kartenzahlungFocusNode[i],
                    ),
                    onChanged: (String wert) {
                      setState(() {
                        _kartenzahlungenCent[i] = _parseCentZiffern(wert);
                      });
                      _triggerEnsureBeiEingabe(_kartenzahlungFocusNode[i]);
                    },
                    schriftgroesse: 15,
                    hinweisText: '0,00 €',
                  ),
                ),
              ),
              if (i > 0) ...<Widget>[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => _kartenzahlungEntfernen(i),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Kartenzahlung entfernen',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (_kartenzahlungenCent.first > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _kartenzahlungHinzufuegen,
              icon: const Icon(Icons.add),
              label: const Text('Kartenzahlung hinzufügen'),
            ),
          ),
        Text(
          'Gesamt Kartenzahlungen: ${_formatiereEuro(_kartenzahlungenSummeCent)}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _baueKartenzahlungenGruppe() {
    return _baueEinklappbarenBereich(
      titel: 'Kartenzahlungen (Beträge)',
      gesamtbetragCent: _kartenzahlungenSummeCent,
      aufgeklappt: _kartenzahlungenAufgeklappt,
      beimUmschalten: () {
        setState(() {
          _kartenzahlungenAufgeklappt = !_kartenzahlungenAufgeklappt;
        });
      },
      inhalt: _baueKartenzahlungenInhalt(),
    );
  }

  Widget _baueZusammenfassung() {
    return Schritt1UebersichtSection(
      kassenbestandGesamt: _formatiereEuro(_kassenbestandGesamtCent),
      wechselgeldSollwert: _formatiereEuro(_wechselgeldSollwertCent),
      barumsatzBereinigt: _formatiereEuro(_barumsatzBereinigtCent),
      kartenzahlungen: _formatiereEuro(_kartenzahlungenSummeCent),
      gesamtInklKarte: _formatiereEuro(_gesamtUmsatzMitKarteCent),
      barumsatzNegativ: _barumsatzBereinigtCent < 0,
    );
  }

  Widget _baueFooterLeiste({
    required bool tastaturOffen,
    required EdgeInsets footerPadding,
    required double footerBottomInset,
    required bool zeigeNaechstesFeld,
  }) {
    const Color footerBg = Colors.black87;
    final ButtonStyle kompaktButtonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(0, tastaturOffen ? 36 : 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return ColoredBox(
      color: footerBg,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x52FFFFFF))),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, -2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: footerPadding.add(
            EdgeInsets.only(bottom: footerBottomInset),
          ),
          child: Row(
            children: <Widget>[
              if (zeigeNaechstesFeld) ...<Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _weiterZumNaechstenFeldUnten,
                    style: kompaktButtonStyle,
                    child: const Text('nächstes Feld'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _weiterZuSchritt2,
                  style: kompaktButtonStyle,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 6),
                      Text('Schritt 2'),
                    ],
                  ),
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
    final bool zeigeNaechstesFeld = _aktivesFeldSchritt1() != null;
    final double keyboardInset = _keyboardInset;
    final bool tastaturOffen = keyboardInset > 0;
    final double keyboardAnimationZiel = tastaturOffen ? 1.0 : 0.0;
    final double bottomInset = mediaQuery.viewPadding.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      resizeToAvoidBottomInset: false,
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
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: keyboardAnimationZiel),
        duration: _footerAnimationDauer,
        curve: _footerAnimationKurve,
        builder: (BuildContext context, double faktor, _) {
          final double footerBottom = keyboardInset * faktor;
          final double footerContentHoehe = ui.lerpDouble(
            _footerContentHoeheNormal,
            _footerContentHoeheKeyboard,
            faktor,
          )!;
          final double footerBottomInset = ui.lerpDouble(
            bottomInset,
            0,
            faktor,
          )!;
          final EdgeInsets footerPadding = EdgeInsets.lerp(
            _footerPaddingNormal,
            _footerPaddingKeyboard,
            faktor,
          )!;
          final double footerTotalHoehe =
              footerContentHoehe + footerBottomInset;
          final double bottomPadding = keyboardInset + footerTotalHoehe + 16;
          final bool downButtonSichtbar =
              _scrollController.hasClients &&
              _scrollController.position.pixels <
                  _scrollController.position.maxScrollExtent - 24;

          return Stack(
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
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    slivers: <Widget>[
                      if (devToolsStickySichtbar)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _DevToolsStickyHeaderDelegate(
                            extent: _devToolsStickyHoehe,
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
                            Schritt1HinweiseSection(
                              kartenzahlungenInhalt:
                                  _baueKartenzahlungenGruppe(),
                              umschlaegeInhalt: _baueUmschlagGruppe(),
                            ),
                            _baueZusammenfassung(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: footerBottom,
                child: SizedBox(
                  height: footerTotalHoehe,
                  child: _baueFooterLeiste(
                    tastaturOffen: tastaturOffen,
                    footerPadding: footerPadding,
                    footerBottomInset: footerBottomInset,
                    zeigeNaechstesFeld: zeigeNaechstesFeld,
                  ),
                ),
              ),
              if (downButtonSichtbar)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: footerBottom + footerTotalHoehe + 10,
                  child: Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: FloatingActionButton(
                        heroTag: 'step1DownFab',
                        mini: true,
                        elevation: 2,
                        onPressed: () {
                          if (!_scrollController.hasClients) {
                            return;
                          }
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
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
