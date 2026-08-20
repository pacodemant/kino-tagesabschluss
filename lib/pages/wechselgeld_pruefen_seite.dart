import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/services/wechselgeld_config_service.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/services/abrechnung_speicher.dart';
import 'package:kino_bar_app/pages/getraenke_auffuellen_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/widgets/help_button.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/controller/schritt1_state_controller.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/orchestrierung/schritt1_orchestrierung_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/scroll/schritt1_scroll_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/setup/schritt1_initialisierung_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_body_content.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_gruppen_orchestrierung.dart';
import 'package:kino_bar_app/pages/wechselgeld_pruefen/sections/wechselgeld_rollen_section.dart';
import 'package:kino_bar_app/pages/wechselgeld_pruefen/sections/wechselgeld_zusammenfassung_section.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/utils/feld_navigation_helper.dart';
import 'package:kino_bar_app/widgets/hinweis_snackbar.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

/// Typisierte Routen-Argumente für den Aufruf aus der Kassenabrechnung
/// (Schritt 3 · "Wechselgeldkasse prüfen"), damit dort zusätzlich zur
/// kinoId markiert werden kann, dass es sich um die Abend-Prüfung handelt.
/// Der Aufruf aus dem Startmenü (Geschäftsbeginn) übergibt weiterhin nur
/// die kinoId als String — main.dart unterstützt beide Formen.
class WechselgeldPruefenArgumente {
  const WechselgeldPruefenArgumente({
    required this.kinoId,
    this.ausTagesabrechnung = false,
  });

  final String kinoId;
  final bool ausTagesabrechnung;
}

class WechselgeldPruefenSeite extends StatefulWidget {
  const WechselgeldPruefenSeite({
    super.key,
    required this.kinoId,
    this.ausTagesabrechnung = false,
  });

  static const String routenName = '/wechselgeld-pruefen';

  final String kinoId;
  /// true, wenn die Seite aus der Kassenabrechnung (Schritt 3, abends)
  /// aufgerufen wurde statt vom Startmenü (Geschäftsbeginn, morgens) —
  /// dann wird ein evtl. noch vorhandener, unvollendeter Entwurf von der
  /// Morgen-Prüfung vor dem Laden verworfen, statt ihn anzuzeigen.
  final bool ausTagesabrechnung;

  @override
  State<WechselgeldPruefenSeite> createState() =>
      _WechselgeldPruefenSeiteState();
}

class _WechselgeldPruefenSeiteState extends State<WechselgeldPruefenSeite> {
  static const int _sectionScheine = 0;
  static const int _sectionLoseMuenzen = 1;
  static const int _sectionRollen = 2;
  static const int _sectionUmschlaege = 4;
  final Schritt1StateController _stateController =
      const Schritt1StateController();
  final FeldNavigationHelper _navHelper = const FeldNavigationHelper();
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
      .where((Kassenzeile zeile) => StueckelungKonfiguration.kupferRollenIds.contains(zeile.id))
      .toList();
  List<Kassenzeile> get _rollenOhneKupfer => _rollenAlle
      .where((Kassenzeile zeile) => !StueckelungKonfiguration.kupferRollenIds.contains(zeile.id))
      .toList();
  List<Kassenzeile> get _rollenSichtbar =>
      _kupferRollenSichtbar ? _rollenAlle : _rollenOhneKupfer;
  List<Kassenzeile> get _loseMuenzartenOhneKupfer => _loseMuenzarten
      .where((Kassenzeile zeile) => !StueckelungKonfiguration.kupferMuenzenIds.contains(zeile.id))
      .toList();
  List<Kassenzeile> get _kupferLoseMuenzarten => _loseMuenzarten
      .where((Kassenzeile zeile) => StueckelungKonfiguration.kupferMuenzenIds.contains(zeile.id))
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
      verknuepfeFeldNavigation: _verknuepfeFeldNavigation,
    );
    for (final Kassenzeile zeile in _alleStueckzahlZeilen) {
      _stueckzahlen[zeile.id] = 0;
      _stueckzahlController[zeile.id] = TextEditingController();
      _stueckzahlFocusNode[zeile.id] = FocusNode();
      _verknuepfeFeldNavigation(_stueckzahlFocusNode[zeile.id]!);
    }
    for (final Kassenzeile zeile in _loseMuenzarten) {
      _loseMuenzenNachArtCent[zeile.id] = 0;
      _loseMuenzenController[zeile.id] = TextEditingController();
      _loseMuenzenFocusNode[zeile.id] = FocusNode();
      _verknuepfeFeldNavigation(_loseMuenzenFocusNode[zeile.id]!);
    }
    _scrollController.addListener(_beiScrollAenderung);
    // Prueft "Wechselgeld stimmt!" bei jedem Fokuswechsel (Feld
    // verlassen/bestaetigt) statt bei jedem Tastendruck — siehe die
    // dazu entfernten _planePruefung()-Aufrufe in den onChanged-
    // Handlern weiter unten.
    FocusManager.instance.addListener(_planePruefung);
    _ladeInitialeDaten().then((_) {
      if (mounted) {
        _autoFokussiereNachLaden();
      }
    });
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_planePruefung);
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
    if (widget.ausTagesabrechnung) {
      // Abend-Prüfung im Rahmen der Kassenabrechnung: ein evtl. noch
      // vorhandener, unvollendeter Entwurf von der Morgen-Prüfung darf
      // hier nicht auftauchen — verwerfen, bevor geladen wird.
      await LokalerSpeicher.loescheWechselgeldZaehlEntwurf(widget.kinoId);
    }
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
        StueckelungKonfiguration.kupferRollenIds.any((String id) => (_stueckzahlen[id] ?? 0) > 0);
    final bool hatKupferLoseWerte = StueckelungKonfiguration.kupferMuenzenIds.any(
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
    final Kino? kino = KinoRepository.nachId(widget.kinoId);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogKontext) {
        return AlertDialog(
          title: const Text('Wechselgeld stimmt!'),
          content: const Text('Passt.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogKontext).pop(),
              child: const Text('Weiter zählen'),
            ),
            if (kino?.hatGetraenke == true)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogKontext).pop();
                  Navigator.of(context).pushNamed(
                    GetraenkeAuffuellenSeite.routenName,
                    arguments: widget.kinoId,
                  );
                },
                child: const Text('Getränke auffüllen'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogKontext).pop();
                _zurueckZurStartseite();
              },
              child: const Text('Fertig / Startseite'),
            ),
          ],
        );
      },
    );
  }

  void _zurueckZurStartseite() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      StartmenueSeite.routenName,
      (Route<dynamic> route) => false,
      arguments: widget.kinoId,
    );
  }

  /// Prueft die Differenz zum Wechselgeld-Sollwert unabhaengig vom
  /// gewaehlten Ausgang (Fertig-Button, Zurueck-Pfeil, Haus-Button).
  /// Gibt true zurueck, wenn die Seite verlassen werden darf.
  Future<bool> _pruefeDifferenzUndBestaetigeVerlassen() async {
    final int differenzCent = _kassenbestandGesamtCent - _wechselgeldSollwertCent;
    if (differenzCent == 0) {
      return true;
    }
    final bool? bestaetigt = await zeigeBestaetigungsDialog(
      context,
      titel: 'Wechselgeld stimmt nicht',
      inhalt:
          'Differenz zum Sollwert: '
          '${TagesabschlussFormatierung.formatiereEuroMitVorzeichen(differenzCent)}.\n'
          'Trotzdem fortfahren?',
      abbrechenText: 'Zurück zum Zählen',
      bestaetigenText: 'Ja, trotzdem weiter',
    );
    return bestaetigt == true;
  }

  /// Prueft die Differenz (siehe _pruefeDifferenzUndBestaetigeVerlassen)
  /// und navigiert bei Freigabe direkt zur Startseite — genutzt vom
  /// Haus-Button und vom Footer-Button "Fertig / Startseite". Kein
  /// zusaetzlicher Zwischendialog: wer bei einer Differenz explizit
  /// "Ja, trotzdem weiter" waehlt, moechte direkt fertig sein.
  Future<void> _pruefeDifferenzUndGeheZurStartseite() async {
    if (await _pruefeDifferenzUndBestaetigeVerlassen()) {
      _zurueckZurStartseite();
    }
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

  // _planePruefung() laeuft hier bewusst NICHT mit (siehe FocusManager-
  // Listener in initState): der "Wechselgeld stimmt!"-Dialog soll erst
  // beim Verlassen des Feldes erscheinen, nicht bei jedem Tastendruck.
  void _beiStueckzahlGeaendert(Kassenzeile zeile, String wert) {
    final int geparsterWert = TagesabschlussBerechnung.parseGanzzahlSumme(wert);
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
  }

  void _zeigeKupferLose() {
    setState(() {
      _kupferLoseSichtbar = true;
    });
  }

  void _entferneKupferLose() {
    setState(() {
      _kupferLoseSichtbar = false;
      for (final String id in StueckelungKonfiguration.kupferMuenzenIds) {
        _loseMuenzenNachArtCent[id] = 0;
        _loseMuenzenController[id]?.clear();
      }
    });
  }

  void _zeigeKupferRollen() {
    setState(() {
      _kupferRollenSichtbar = true;
    });
  }

  void _entferneKupferRollen() {
    setState(() {
      _kupferRollenSichtbar = false;
      for (final String id in StueckelungKonfiguration.kupferRollenIds) {
        _stueckzahlen[id] = 0;
        _stueckzahlController[id]?.clear();
      }
    });
  }

  int _parseCentZiffern(String wert) =>
      TagesabschlussBerechnung.parseCentZiffern(wert);

  List<FocusNode> _fokusReihenfolge() => _stateController.fokusReihenfolge(
    scheine: _scheine,
    stueckzahlFocusNode: _stueckzahlFocusNode,
    loseMuenzarten:
        _kupferLoseSichtbar ? _loseMuenzarten : _loseMuenzartenOhneKupfer,
    loseMuenzenFocusNode: _loseMuenzenFocusNode,
    rollenSichtbar: _rollenSichtbar,
    umschlaege: _umschlaege,
    umschlagBezeichnungFocusNode: _umschlagBezeichnungFocusNode,
    umschlagBetragFocusNode: _umschlagBetragFocusNode,
  );

  bool _istLetztesFeld(FocusNode focusNode) =>
      _navHelper.istLetztesFeld(_fokusReihenfolge(), focusNode);

  FocusNode? _naechstesFeld(FocusNode focusNode) =>
      _navHelper.feldNachVorne(_fokusReihenfolge(), focusNode);

  TextInputAction _textInputAction(FocusNode focusNode) =>
      _navHelper.textInputActionFuer(_istLetztesFeld(focusNode));

  void _beiEingabeAbgeschlossen(FocusNode focusNode) =>
      _stateController.beiEingabeAbgeschlossen(
        context,
        _naechstesFeld(focusNode),
      );

  void _fokussiereTextfeld(FocusNode fokusNode) {
    _stateController.fokussiereTextfeld(
      context: context,
      fokusNode: fokusNode,
      aktivesFeld: () => _navHelper.aktivesFeld(_fokusReihenfolge()),
      oeffneSectionFuerFokusfeld: _oeffneSectionFuerFokusfeld,
      fokussiereTextfeldRekursiv: _fokussiereTextfeld,
      mounted: mounted,
    );
    _scrolleZurMitteNachFokus(fokusNode);
  }

  void _verknuepfeFeldNavigation(FocusNode fokusNode) {
    fokusNode.onKeyEvent = (FocusNode node, KeyEvent event) =>
        _navHelper.onKeyEventFuerFeld(
          context: context,
          event: event,
          reihenfolge: _fokusReihenfolge,
          fokussiere: _fokussiereTextfeld,
        );
  }

  Future<void> _scrolleZurMitteNachFokus(FocusNode fn) {
    return _navHelper.scrolleZurMitteNachFokus(
      fn: fn,
      istMounted: () => mounted,
      context: context,
      scrollController: _scrollController,
      findRenderObject: (FocusNode fokusNode) =>
          _holeFeldKey(fokusNode).currentContext?.findRenderObject(),
    );
  }

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

  bool get _irgendeineSectionAufgeklappt =>
      _scheineAufgeklappt ||
      _loseMuenzenAufgeklappt ||
      _rollenAufgeklappt ||
      _umschlaegeAufgeklappt;

  void _toggleAlleSections() {
    setState(() {
      final bool neuerWert = !_irgendeineSectionAufgeklappt;
      _scheineAufgeklappt = neuerWert;
      _loseMuenzenAufgeklappt = neuerWert;
      _rollenAufgeklappt = neuerWert;
      _umschlaegeAufgeklappt = neuerWert;
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

  FocusNode? _erstesLeeresFeld() {
    final List<FocusNode> reihenfolge = _fokusReihenfolge();
    for (final FocusNode fn in reihenfolge) {
      String? schluessel;
      for (final MapEntry<String, FocusNode> entry
          in _stueckzahlFocusNode.entries) {
        if (identical(entry.value, fn)) {
          schluessel = entry.key;
          break;
        }
      }
      if (schluessel != null) {
        if (_stueckzahlController[schluessel]?.text.isEmpty ?? true) {
          return fn;
        }
        continue;
      }
      for (final MapEntry<String, FocusNode> entry
          in _loseMuenzenFocusNode.entries) {
        if (identical(entry.value, fn)) {
          schluessel = entry.key;
          break;
        }
      }
      if (schluessel != null) {
        if (_loseMuenzenController[schluessel]?.text.isEmpty ?? true) {
          return fn;
        }
        continue;
      }
      final int bezIdx = _umschlagBezeichnungFocusNode
          .indexWhere((FocusNode n) => identical(n, fn));
      if (bezIdx >= 0) {
        if (bezIdx < _umschlagBezeichnungController.length &&
            _umschlagBezeichnungController[bezIdx].text.isEmpty) {
          return fn;
        }
        continue;
      }
      final int betIdx = _umschlagBetragFocusNode
          .indexWhere((FocusNode n) => identical(n, fn));
      if (betIdx >= 0) {
        if (betIdx < _umschlagBetragController.length &&
            _umschlagBetragController[betIdx].text.isEmpty) {
          return fn;
        }
        continue;
      }
      return fn;
    }
    return null;
  }

  void _autoFokussiereNachLaden() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final FocusNode? ziel = _erstesLeeresFeld();
      if (ziel != null) {
        _fokussiereTextfeld(ziel);
      }
    });
  }

  int _summeGruppe(List<Kassenzeile> zeilen) =>
      TagesabschlussBerechnung.summeStueckzahlGruppeCent(
        zeilen: zeilen,
        stueckzahlen: _stueckzahlen,
      );

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

  String _formatiereEuro(int cent) =>
      TagesabschlussFormatierung.formatiereEuro(cent);

  String _formatiereEuroEingabe(int cent) =>
      TagesabschlussFormatierung.formatiereEuroEingabe(cent);

  Future<void> _bestaetigeUndLeere() async {
    final bool? bestaetigt = await zeigeBestaetigungsDialog(
      context,
      titel: 'Eingaben wirklich löschen?',
      inhalt: 'Alle Eingaben werden zurückgesetzt.',
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
    final Map<String, dynamic>? daten =
        await AbrechnungSpeicher.laden(widget.kinoId);
    if (!mounted) return;
    final Object? stueckzahlenRoh = daten?['stueckzahlen'];
    final Map<String, dynamic>? stueckzahlMap =
        stueckzahlenRoh is Map<String, dynamic> ? stueckzahlenRoh : null;
    // Nicht nur auf "Map vorhanden" pruefen: nach "Eingaben loeschen" in
    // Schritt 1 bleibt ein Entwurf mit allen Rollen-Keys, aber Werten von
    // 0, gespeichert — das zaehlt fachlich als "keine Zaehlung vorhanden".
    final bool hatRollenDaten =
        stueckzahlMap != null &&
        stueckzahlMap.entries.any(
          (MapEntry<String, dynamic> e) =>
              e.key.startsWith('roll_') &&
              ((e.value as num?)?.toInt() ?? 0) != 0,
        );
    if (!hatRollenDaten) {
      if (!mounted) return;
      zeigeHinweisSnackBar(
        context,
        'Keine Zählung für heute gefunden.',
        vorherigeLoeschen: true,
      );
      return;
    }
    setState(() {
      for (final MapEntry<String, dynamic> e in stueckzahlMap.entries) {
        if (e.key.startsWith('roll_') && _stueckzahlen.containsKey(e.key)) {
          final int wert = (e.value as num?)?.toInt() ?? 0;
          _stueckzahlen[e.key] = wert;
          _stueckzahlController[e.key]?.text =
              wert != 0 ? wert.toString() : '';
        }
      }
      _rollenUebernommen = true;
    });
    await _speichereEntwurf();
    _planePruefung();
  }

  Future<void> _zeigeRollenUebernehmenHilfe() => zeigeInfoDialog(
    context,
    titel: 'Geldrollenanzahl übernehmen',
    inhalt: const Text(
      'Übernimmt die Anzahl der Münzrollen aus der heutigen '
      'Bargeldzählung (Schritt 1). Sinnvoll wenn die Rollenanzahl '
      'seit der ersten Zählung unverändert ist.',
    ),
    buttonText: 'OK',
  );

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
      entferneKupferLose: _entferneKupferLose,
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
      entferneKupferRollen: _entferneKupferRollen,
      toggleScheine: () => _toggleSection(_sectionScheine),
      toggleLoseMuenzen: () => _toggleSection(_sectionLoseMuenzen),
      toggleRollen: () => _toggleSection(_sectionRollen),
      toggleUmschlaege: () => _toggleSection(_sectionUmschlaege),
      rotHervorgehoben: const <FocusNode>{},
    );

    final int differenzCent =
        _kassenbestandGesamtCent - _wechselgeldSollwertCent;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final NavigatorState navigator = Navigator.of(context);
        final bool darfVerlassen = await _pruefeDifferenzUndBestaetigeVerlassen();
        if (!mounted || !darfVerlassen) return;
        navigator.pop();
      },
      child: TagesabschlussScaffold(
      backgroundColor: hintergrundFarbe,
      zeigeHausButton: false,
      appBar: TagesabschlussHeader(
        schrittNummer: 0,
        schrittTitel: 'Wechselgeld prüfen',
        kinoName: KinoRepository.nachId(widget.kinoId)?.name ?? 'Schauburg',
        actions: <Widget>[
          TextButton(
            onPressed: _bestaetigeUndLeere,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Löschen'),
          ),
          const HelpButton(
            helpText:
                'Zähle den Wechselgeldbestand und vergleiche ihn mit dem '
                'Sollwert. Der Bestand muss täglich stimmen, da er als '
                'Startkasse für den nächsten Tag dient.',
          ),
          const SizedBox(width: 8),
        ],
      ),
      footerChild: SizedBox(
        height: 36,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 36,
              height: 36,
              child: ElevatedButton(
                onPressed: _pruefeDifferenzUndGeheZurStartseite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppFarben.appBarRot,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Icon(Icons.home, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            TapRegion(
              groupId: EditableText,
              child: ElevatedButton(
                onPressed: () => _navHelper.springeZuNaechstem(
                  context: context,
                  reihenfolge: _fokusReihenfolge(),
                  fokussiere: _fokussiereTextfeld,
                  vorwaerts: true,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppFarben.appBarRot,
                  minimumSize: const Size(0, 36),
                ),
                child: const Text('Next'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _pruefeDifferenzUndGeheZurStartseite,
                style: AppFarben.footerButtonStyle,
                child: const Text('Fertig / Startseite'),
              ),
            ),
          ],
        ),
      ),
      child: Schritt1BodyContent(
        scrollController: _scrollController,
        devToolsStickySichtbar: false,
        devToolsStickyHoehe: 0,
        devToolsPanel: const SizedBox.shrink(),
        alleZuklappenLink: Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _toggleAlleSections,
            style: TextButton.styleFrom(
              foregroundColor: AppFarben.appBarRot,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _irgendeineSectionAufgeklappt ? 'Alle zuklappen' : 'Alle aufklappen',
            ),
          ),
        ),
        scheineGruppe: gruppen.scheineGruppe,
        loseMuenzenGruppe: gruppen.loseMuenzenGruppe,
        rollenGruppe: WechselgeldRollenSection(
          rollenOhneKupfer: _rollenOhneKupfer,
          kupferRollen: _kupferRollen,
          rollenSichtbar: _rollenSichtbar,
          kupferRollenSichtbar: _kupferRollenSichtbar,
          rollenAufgeklappt: _rollenAufgeklappt,
          rollenUebernommen: _rollenUebernommen,
          stueckzahlen: _stueckzahlen,
          stueckzahlController: _stueckzahlController,
          stueckzahlFocusNode: _stueckzahlFocusNode,
          summeGruppe: _summeGruppe,
          formatiereEuro: _formatiereEuro,
          baueFeldMitKey: _baueFeldMitKey,
          textInputActionFuerSchritt1: _textInputAction,
          beiStueckzahlGeaendert: _beiStueckzahlGeaendert,
          beiEingabeAbgeschlossen: _beiEingabeAbgeschlossen,
          zeigeKupferRollen: _zeigeKupferRollen,
          entferneKupferRollen: _entferneKupferRollen,
          onToggleRollen: () => _toggleSection(_sectionRollen),
          onLoescheRollen: _loescheRollen,
          onLadeRollenAusErsterZaehlung: _ladeRollenAusErsterZaehlung,
          onZeigeRollenUebernehmenHilfe: _zeigeRollenUebernehmenHilfe,
        ),
        hinweiseSection: gruppen.hinweiseSection,
        zusammenfassung: WechselgeldZusammenfassungSection(
          gezaehlterBetragCent: _kassenbestandGesamtCent,
          wechselgeldSollwertCent: _wechselgeldSollwertCent,
          differenzCent: differenzCent,
          formatiereEuro: _formatiereEuro,
        ),
        downButtonSichtbar: _istDownButtonSichtbar(),
        scrolleNachUnten: _scrolleNachUnten,
        beiScrollMetrikAenderung: _beiScrollMetrikAenderung,
      ),
      ),
    );
  }

}
