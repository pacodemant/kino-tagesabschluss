import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/ec_terminal_ergebnis.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/controller/schritt2_fokus_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/models/zahlungsart_zeile.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_ec_beleg_terminal_id_zeile.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/scroll/schritt2_scroll_helper.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/ui/schritt2_ui_builder.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/ui/schritt2_body_content.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/ui/schritt2_gruppen_orchestrierung.dart';
import 'package:kino_bar_app/services/beleg_scan_service.dart';
import 'package:kino_bar_app/services/zahlungsarten_config_service.dart';
import 'package:kino_bar_app/services/dev_modus.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/utils/controller_dispose_mixin.dart';
import 'package:kino_bar_app/utils/feld_navigation_helper.dart';
import 'package:kino_bar_app/widgets/beleg_scan_bestaetigen_dialog.dart';
import 'package:kino_bar_app/widgets/help_button.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

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
    required this.stueckzahlen,
    required this.loseMuenzenNachArtCent,
    this.umschlaege,
  });

  final String kinoId;
  final String kinoName;
  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int wechselgeldSollwertCent;
  final int barBestandAbzglWechselgeldCent;
  final Map<String, int> stueckzahlen;
  final Map<String, int> loseMuenzenNachArtCent;
  final List<UmschlagEintrag>? umschlaege;
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
    required this.stueckzahlen,
    required this.loseMuenzenNachArtCent,
    this.umschlaege,
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
  final Map<String, int> stueckzahlen;
  final Map<String, int> loseMuenzenNachArtCent;
  final List<UmschlagEintrag>? umschlaege;

  @override
  State<TagesabschlussSchritt2Seite> createState() =>
      _TagesabschlussSchritt2SeiteState();
}

class _TagesabschlussSchritt2SeiteState
    extends State<TagesabschlussSchritt2Seite>
    with ControllerDisposeMixin {
  static const double _devToolsPanelHoehe = 68;
  final FeldNavigationHelper _navHelper = const FeldNavigationHelper();
  final Schritt2FokusHelper _fokusHelper = const Schritt2FokusHelper();
  final Schritt2ScrollHelper _scrollHelper = const Schritt2ScrollHelper();
  final Schritt2GruppenOrchestrierung _gruppenOrchestrierung =
      const Schritt2GruppenOrchestrierung();

  final TextEditingController _kinoSollController = TextEditingController();
  final TextEditingController _bistroSollController = TextEditingController();
  final TextEditingController _differenzAnfangsbestandController =
      TextEditingController();
  final FocusNode _kinoSollFocusNode = FocusNode();
  final FocusNode _bistroSollFocusNode = FocusNode();
  final FocusNode _differenzAnfangsbestandFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TapGestureRecognizer _belegdatenBearbeitenRecognizer =
      TapGestureRecognizer();
  final List<TextEditingController> _ecBelegController = <TextEditingController>[];
  final List<TextEditingController> _ecBelegLabelController = <TextEditingController>[];
  final List<FocusNode> _ecBelegFocusNode = <FocusNode>[];
  final List<FocusNode> _ecBelegLabelFocusNode = <FocusNode>[];
  final List<int> _ecBelegIds = <int>[];
  int _naechsteEcBelegId = 1;
  final List<String> _ecBelegLabels = <String>[];
  final List<bool> _ecUnterkachelAufgeklappt = <bool>[];
  final List<bool> _ecUnterkachelEditModus = <bool>[];
  final List<bool> _ecBelegScanGescannt = <bool>[];

  // Per-Beleg: Zahlungsarten und Scan-Status
  List<String> _zahlungsartKonfigNamen = <String>[];
  final List<List<ZahlungsartZeile>> _zahlungsartZeilen = <List<ZahlungsartZeile>>[];
  final List<bool> _scanHatStattgefunden = <bool>[];
  final List<int?> _kartenartenGesamtBetragCent = <int?>[];
  final List<TextEditingController> _kartenartenGesamtBetragController = <TextEditingController>[];
  final List<FocusNode> _kartenartenGesamtBetragFocusNode = <FocusNode>[];
  final List<bool> _metadatenAufgeklappt = <bool>[];
  final List<bool> _metadatenNurAnzeige = <bool>[];

  final List<TextEditingController> _ausgabenBetragController = <TextEditingController>[];
  final List<TextEditingController> _ausgabenLabelController = <TextEditingController>[];
  final List<FocusNode> _ausgabenBetragFocusNode = <FocusNode>[];
  final List<FocusNode> _ausgabenLabelFocusNode = <FocusNode>[];
  final List<int> _ausgabenBetrageCent = <int>[];
  final List<String> _ausgabenLabels = <String>[];
  final List<int> _ausgabenIds = <int>[];
  int _naechsteAusgabeId = 1;

  int _kinoSollCent = 0;
  int _bistroSollCent = 0;
  int _differenzAnfangsbestandCent = 0;
  final List<int> _ecBelegeCent = <int>[];
  bool _personalgetraenkeGebot = false;
  String _anmerkung = '';
  final TextEditingController _anmerkungController = TextEditingController();
  final FocusNode _anmerkungFocusNode = FocusNode();
  bool _devToolsOffen = false;
  bool _devModusAktiv = false;
  int? _scanBelegIndex;
  bool get _scanLaeuft => _scanBelegIndex != null;
  bool _validierungAusgeloest = false;
  bool _kinoSollBeruehrt = false;
  bool _bistroSollBeruehrt = false;
  bool _kartenartenGesamt1Beruehrt = false;
  bool _ecBelegLabel1Beruehrt = false;
  bool _laedt = true;
  DateTime _letzteAenderung = DateTime.now();

  // Scan-Metadaten
  String? _scanTerminalId;
  String? _scanDatum;
  String? _scanUhrzeit;
  String? _scanBelegNrVon;
  String? _scanBelegNrBis;
  final TextEditingController _scanDatumController = TextEditingController();
  final TextEditingController _scanUhrzeitController =
      TextEditingController();
  final TextEditingController _scanBelegNrVonController =
      TextEditingController();
  final TextEditingController _scanBelegNrBisController =
      TextEditingController();
  final FocusNode _scanDatumFocusNode = FocusNode();
  final FocusNode _scanUhrzeitFocusNode = FocusNode();
  final FocusNode _scanBelegNrVonFocusNode = FocusNode();
  final FocusNode _scanBelegNrBisFocusNode = FocusNode();

  // EC-Kachel
  bool _ecKachelAufgeklappt = false;

  @override
  void initState() {
    super.initState();
    _verknuepfeFeldNavigationSchritt2(_kinoSollFocusNode);
    _verknuepfeFeldNavigationSchritt2(_bistroSollFocusNode);
    _verknuepfeFeldNavigationSchritt2(_differenzAnfangsbestandFocusNode);
    _setzeEcBelegAnzahl(1);
    _setzeAusgabenAnzahl(1);
    DevModus.istAktiv().then((bool aktiv) {
      setState(() {
        _devModusAktiv = aktiv;
      });
    });
    _scrollController.addListener(_beiScrollAenderung);
    FocusManager.instance.addListener(_beiGlobalerFokusAenderung);
    for (final FocusNode fn in <FocusNode>[
      _scanDatumFocusNode,
      _scanUhrzeitFocusNode,
      _scanBelegNrVonFocusNode,
      _scanBelegNrBisFocusNode,
      _anmerkungFocusNode,
    ]) {
      fn.addListener(() {
        if (mounted) setState(() {});
      });
    }
    ZahlungsartenConfigService.laden().then((List<String> liste) async {
      if (!mounted) return;
      _zahlungsartKonfigNamen = liste;
      setState(() {
        // Alle bestehenden Belege (mindestens Beleg 0) mit Konfigzeilen befüllen
        for (int b = 0; b < _zahlungsartZeilen.length; b++) {
          for (final ZahlungsartZeile z in _zahlungsartZeilen[b]) {
            z.dispose();
          }
          _zahlungsartZeilen[b] = List<ZahlungsartZeile>.generate(
            liste.length,
            (int i) => ZahlungsartZeile(liste[i]),
          );
        }
      });
      for (final List<ZahlungsartZeile> belegZeilen in _zahlungsartZeilen) {
        for (final ZahlungsartZeile zeile in belegZeilen) {
          zeile.betragFocusNode.addListener(() { if (mounted) setState(() {}); });
          _verknuepfeFeldNavigationSchritt2(zeile.betragFocusNode);
        }
      }
      await _ladeEntwurf();
      if (!mounted) return;
      _autoFokussiereNachLaden();
    });
  }

  // Loest bei jeder Fokusaenderung im gesamten App-Baum ein setState aus,
  // damit z.B. der Next-Button auch ohne virtuelle Tastatur (Desktop-
  // Browser) sichtbar wird, sobald ein Feld fokussiert ist.
  void _beiGlobalerFokusAenderung() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_beiGlobalerFokusAenderung);
    _kinoSollController.dispose();
    _bistroSollController.dispose();
    _differenzAnfangsbestandController.dispose();
    _kinoSollFocusNode.dispose();
    _bistroSollFocusNode.dispose();
    _differenzAnfangsbestandFocusNode.dispose();
    _scrollController.dispose();
    _belegdatenBearbeitenRecognizer.dispose();
    _scanDatumController.dispose();
    _scanUhrzeitController.dispose();
    _scanBelegNrVonController.dispose();
    _scanBelegNrBisController.dispose();
    _scanDatumFocusNode.dispose();
    _scanUhrzeitFocusNode.dispose();
    _scanBelegNrVonFocusNode.dispose();
    _scanBelegNrBisFocusNode.dispose();
    disposeControllers(_kartenartenGesamtBetragController);
    disposeFocusNodes(_kartenartenGesamtBetragFocusNode);
    disposeControllers(_ecBelegController);
    disposeControllers(_ecBelegLabelController);
    disposeFocusNodes(_ecBelegFocusNode);
    disposeFocusNodes(_ecBelegLabelFocusNode);
    disposeControllers(_ausgabenBetragController);
    disposeControllers(_ausgabenLabelController);
    disposeFocusNodes(_ausgabenBetragFocusNode);
    disposeFocusNodes(_ausgabenLabelFocusNode);
    for (final List<ZahlungsartZeile> belegZeilen in _zahlungsartZeilen) {
      for (final ZahlungsartZeile zeile in belegZeilen) {
        zeile.dispose();
      }
    }
    _anmerkungController.dispose();
    _anmerkungFocusNode.dispose();
    super.dispose();
  }

  Future<void> _ladeEntwurf() async {
    final Map<String, dynamic>? daten =
        await LokalerSpeicher.ladeSchritt2Entwurf(widget.kinoId);
    if (daten == null || !mounted) {
      if (mounted) setState(() { _laedt = false; });
      return;
    }
    final String? gespeichertesDatum = daten['isoDatum'] as String?;
    if (gespeichertesDatum != DatumsHelper.logischesIsoDatum()) {
      setState(() { _laedt = false; });
      return;
    }

    final int kinoSollCent = (daten['kinoSollCent'] as num?)?.toInt() ?? 0;
    final int bistroSollCent = (daten['bistroSollCent'] as num?)?.toInt() ?? 0;
    final int differenzAnfangsbestandCent =
        (daten['differenzAnfangsbestandCent'] as num?)?.toInt() ?? 0;

    final List<int> ecBelege = <int>[];
    final Object? ecRoh = daten['ecBelegeCent'];
    if (ecRoh is List<dynamic>) {
      for (final dynamic wert in ecRoh) {
        ecBelege.add((wert as num?)?.toInt() ?? 0);
      }
    }
    if (ecBelege.isEmpty) {
      ecBelege.add(0);
    }

    final List<String> ecBelegeLabelsListe = <String>[];
    final Object? ecLabelsRoh = daten['ecBelegeLabels'];
    if (ecLabelsRoh is List<dynamic>) {
      for (final dynamic wert in ecLabelsRoh) {
        ecBelegeLabelsListe.add(wert?.toString() ?? '');
      }
    }
    while (ecBelegeLabelsListe.length < ecBelege.length) {
      ecBelegeLabelsListe.add('');
    }

    // Ausgaben-Einzelposten laden; Fallback auf altes ausgabenCent-Feld
    List<int> ausgabenBetraege = <int>[];
    List<String> ausgabenLabelListe = <String>[];
    final Object? ausgabenBetraegeRoh = daten['ausgabenBetraegeCent'];
    if (ausgabenBetraegeRoh is List<dynamic>) {
      for (final dynamic wert in ausgabenBetraegeRoh) {
        ausgabenBetraege.add((wert as num?)?.toInt() ?? 0);
      }
    }
    final Object? ausgabenLabelsRoh = daten['ausgabenLabels'];
    if (ausgabenLabelsRoh is List<dynamic>) {
      for (final dynamic wert in ausgabenLabelsRoh) {
        ausgabenLabelListe.add(wert?.toString() ?? '');
      }
    }
    if (ausgabenBetraege.isEmpty) {
      final int altCent = (daten['ausgabenCent'] as num?)?.toInt() ?? 0;
      ausgabenBetraege.add(altCent);
      ausgabenLabelListe.add('');
    }
    while (ausgabenLabelListe.length < ausgabenBetraege.length) {
      ausgabenLabelListe.add('');
    }

    setState(() {
      _laedt = false;
      _setzeEcBelegAnzahl(ecBelege.length);
      _setzeAusgabenAnzahl(ausgabenBetraege.length);
      _kinoSollCent = kinoSollCent;
      _bistroSollCent = bistroSollCent;
      _differenzAnfangsbestandCent = differenzAnfangsbestandCent;
      for (int i = 0; i < ecBelege.length; i++) {
        _ecBelegeCent[i] = ecBelege[i];
        _ecBelegLabels[i] = ecBelegeLabelsListe[i];
      }
      for (int i = 0; i < ausgabenBetraege.length; i++) {
        _ausgabenBetrageCent[i] = ausgabenBetraege[i];
        _ausgabenLabels[i] = ausgabenLabelListe[i];
      }
      // scanHatStattgefunden: neu List<bool>, rückwärtskompatibel bool
      final Object? scanRoh = daten['scanHatStattgefunden'];
      if (scanRoh is List<dynamic>) {
        for (int b = 0; b < _scanHatStattgefunden.length && b < scanRoh.length; b++) {
          _scanHatStattgefunden[b] = (scanRoh[b] as bool?) ?? false;
        }
      } else {
        if (_scanHatStattgefunden.isNotEmpty) {
          _scanHatStattgefunden[0] = (scanRoh as bool?) ?? false;
        }
      }
      _scanTerminalId = daten['scanTerminalId'] as String?;
      _scanDatum = daten['scanDatum'] as String?;
      _scanUhrzeit = daten['scanUhrzeit'] as String?;
      _scanBelegNrVon = daten['scanBelegNrVon'] as String?;
      _scanBelegNrBis = daten['scanBelegNrBis'] as String?;
      // kartenartenGesamtBetragCent: neu List<int?>, rückwärtskompatibel int?
      final Object? gesBetragRoh = daten['kartenartenGesamtBetragCent'];
      if (gesBetragRoh is List<dynamic>) {
        for (int b = 0; b < _kartenartenGesamtBetragCent.length && b < gesBetragRoh.length; b++) {
          _kartenartenGesamtBetragCent[b] = (gesBetragRoh[b] as num?)?.toInt();
        }
      } else if (_kartenartenGesamtBetragCent.isNotEmpty) {
        _kartenartenGesamtBetragCent[0] = (gesBetragRoh as num?)?.toInt();
      }
      if ((_scanHatStattgefunden.isNotEmpty && _scanHatStattgefunden[0]) ||
          ecBelege[0] != 0 ||
          ecBelegeLabelsListe[0].isNotEmpty) {
        _ecKachelAufgeklappt = true;
      }
      _anmerkung = (daten['anmerkung'] as String?) ?? '';
      _personalgetraenkeGebot = (daten['personalgetraenkeGebot'] as bool?) ?? false;
    });
    if (_anmerkung.isNotEmpty) {
      _anmerkungController.text = _anmerkung;
    }

    if (kinoSollCent != 0) {
      _setzeControllerText(
        _kinoSollController,
        TagesabschlussFormatierung.formatiereEuroEingabe(kinoSollCent),
      );
    }
    if (bistroSollCent != 0) {
      _setzeControllerText(
        _bistroSollController,
        TagesabschlussFormatierung.formatiereEuroEingabe(bistroSollCent),
      );
    }
    if (differenzAnfangsbestandCent != 0) {
      _setzeControllerText(
        _differenzAnfangsbestandController,
        _differenzAnzeigeText(differenzAnfangsbestandCent),
      );
    }
    if (_scanDatum != null) {
      _setzeControllerText(_scanDatumController, _scanDatum!);
    }
    if (_scanUhrzeit != null) {
      _setzeControllerText(_scanUhrzeitController, _scanUhrzeit!);
    }
    if (_scanBelegNrVon != null) {
      _setzeControllerText(_scanBelegNrVonController, _scanBelegNrVon!);
    }
    if (_scanBelegNrBis != null) {
      _setzeControllerText(_scanBelegNrBisController, _scanBelegNrBis!);
    }
    for (int b = 0; b < _kartenartenGesamtBetragController.length; b++) {
      final int? bet = _kartenartenGesamtBetragCent[b];
      if (bet != null) {
        _setzeControllerText(
          _kartenartenGesamtBetragController[b],
          TagesabschlussFormatierung.formatiereEuroEingabe(bet),
        );
      }
    }
    for (int i = 0; i < ecBelege.length; i++) {
      _setzeControllerText(
        _ecBelegController[i],
        TagesabschlussFormatierung.formatiereEuroEingabe(ecBelege[i]),
      );
      if (ecBelegeLabelsListe[i].isNotEmpty) {
        _setzeControllerText(_ecBelegLabelController[i], ecBelegeLabelsListe[i]);
      }
    }
    for (int i = 0; i < ausgabenBetraege.length; i++) {
      if (ausgabenBetraege[i] != 0) {
        _setzeControllerText(
          _ausgabenBetragController[i],
          TagesabschlussFormatierung.formatiereEuroEingabe(ausgabenBetraege[i]),
        );
      }
      if (ausgabenLabelListe[i].isNotEmpty) {
        _setzeControllerText(_ausgabenLabelController[i], ausgabenLabelListe[i]);
      }
    }

    // Zahlungsarten-Tabelle pro Beleg wiederherstellen
    final Object? betragRoh = daten['zahlungsartBetragCentWerte'];
    if (mounted && betragRoh is List<dynamic>) {
      // Neues Format: List<List<dynamic>>  –  altes Format: List<dynamic> (nur Beleg 0)
      final bool isNeuesFormat =
          betragRoh.isNotEmpty && betragRoh.first is List<dynamic>;
      if (isNeuesFormat) {
        setState(() {
          for (int b = 0; b < _zahlungsartZeilen.length && b < betragRoh.length; b++) {
            final List<dynamic> bBetrag = betragRoh[b] as List<dynamic>;
            for (int i = 0;
                i < _zahlungsartZeilen[b].length && i < bBetrag.length;
                i++) {
              _zahlungsartZeilen[b][i].betragCentWert = (bBetrag[i] as num?)?.toInt();
              if (_zahlungsartZeilen[b][i].betragCentWert != null) {
                _zahlungsartZeilen[b][i].zustand = ZeilenZustand.shown;
              }
            }
          }
        });
        for (int b = 0; b < _zahlungsartZeilen.length && b < betragRoh.length; b++) {
          final List<dynamic> bBetrag = betragRoh[b] as List<dynamic>;
          for (int i = 0;
              i < _zahlungsartZeilen[b].length && i < bBetrag.length;
              i++) {
            final int? betrag = _zahlungsartZeilen[b][i].betragCentWert;
            if (betrag != null) {
              _setzeControllerText(
                _zahlungsartZeilen[b][i].betragController,
                TagesabschlussFormatierung.formatiereEuroEingabe(betrag),
              );
            }
          }
        }
      } else {
        // Altes Format: flache Liste → nur Beleg 0
        if (_zahlungsartZeilen.isNotEmpty) {
          setState(() {
            for (int i = 0;
                i < _zahlungsartZeilen[0].length && i < betragRoh.length;
                i++) {
              _zahlungsartZeilen[0][i].betragCentWert = (betragRoh[i] as num?)?.toInt();
              if (_zahlungsartZeilen[0][i].betragCentWert != null) {
                _zahlungsartZeilen[0][i].zustand = ZeilenZustand.shown;
              }
            }
          });
          for (int i = 0;
              i < _zahlungsartZeilen[0].length && i < betragRoh.length;
              i++) {
            final int? betrag = _zahlungsartZeilen[0][i].betragCentWert;
            if (betrag != null) {
              _setzeControllerText(
                _zahlungsartZeilen[0][i].betragController,
                TagesabschlussFormatierung.formatiereEuroEingabe(betrag),
              );
            }
          }
        }
      }
    }
  }

  Future<void> _speichereEntwurf() async {
    await LokalerSpeicher.speichereSchritt2Entwurf(
      widget.kinoId,
      <String, dynamic>{
        'kinoId': widget.kinoId,
        'isoDatum': DatumsHelper.logischesIsoDatum(),
        'kinoSollCent': _kinoSollCent,
        'bistroSollCent': _bistroSollCent,
        'ausgabenCent': _ausgabenBetrageCent.fold(0, (int a, int b) => a + b),
        'ausgabenBetraegeCent': List<int>.from(_ausgabenBetrageCent),
        'ausgabenLabels': List<String>.from(_ausgabenLabels),
        'differenzAnfangsbestandCent': _differenzAnfangsbestandCent,
        'ecBelegeCent': List<int>.from(_ecBelegeCent),
        'ecBelegeLabels': List<String>.from(_ecBelegLabels),
        'scanHatStattgefunden': List<bool>.from(_scanHatStattgefunden),
        'scanTerminalId': _scanTerminalId,
        'scanDatum': _scanDatum,
        'scanUhrzeit': _scanUhrzeit,
        'scanBelegNrVon': _scanBelegNrVon,
        'scanBelegNrBis': _scanBelegNrBis,
        'kartenartenGesamtBetragCent': List<int?>.from(_kartenartenGesamtBetragCent),
        'personalgetraenkeGebot': _personalgetraenkeGebot,
        'zahlungsartBetragCentWerte': <List<int?>>[
          for (final List<ZahlungsartZeile> belegZeilen in _zahlungsartZeilen)
            belegZeilen
                .where((ZahlungsartZeile z) => !z.istUnbekannt)
                .map((ZahlungsartZeile z) => z.betragCentWert)
                .toList(),
        ],
        if (_anmerkung.trim().isNotEmpty) 'anmerkung': _anmerkung.trim(),
      },
    );
  }

  /// Gibt den Anzeigetext für das Differenz-Feld zurück (mit Minuszeichen wenn negativ).
  String _differenzAnzeigeText(int cent) {
    if (cent == 0) return '';
    return TagesabschlussFormatierung.formatiereEuroEingabe(cent);
  }

  /// Negiert den Differenz-Anfangsbestand-Wert; ignoriert 0; aktualisiert Controller-Anzeige.
  void _vorzeichenToggleDifferenz() {
    if (_differenzAnfangsbestandCent == 0) return;
    setState(() {
      _letzteAenderung = DateTime.now();
      _differenzAnfangsbestandCent = -_differenzAnfangsbestandCent;
    });
    _setzeControllerText(
      _differenzAnfangsbestandController,
      _differenzAnzeigeText(_differenzAnfangsbestandCent),
    );
    _speichereEntwurf();
  }

  String _kopfDatumUhrzeit() {
    return DateFormat(
      "EEEE, d.M.yy, 'Stand' H:mm 'Uhr'",
      'de_DE',
    ).format(_letzteAenderung);
  }

  Future<void> _weiterZuSchritt3() async {
    if (!await _pruefePflichtfelderVorSchritt3()) {
      return;
    }
    if (!mounted) return;

    // V5: Kino-Soll = 0
    if (_kinoSollCent == 0) {
      final bool? bestaetigt = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          content:
              const Text('Kino-Soll ist 0 € — ist das korrekt?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Korrigieren'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Ja, stimmt so'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (bestaetigt != true) {
        FocusScope.of(context).requestFocus(_kinoSollFocusNode);
        return;
      }
    }

    // V7: EC = 0
    if (TagesabschlussBerechnung.istEcNull(_ecBelegeCent)) {
      final bool? weiter = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          content: const Text(
            'Kein EC-Umsatz erfasst — nur wenn heute '
            'ausschließlich bar bezahlt wurde.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Korrigieren'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Trotzdem weiter'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (weiter != true) return;
    }

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
        ausgabenCent: _ausgabenBetrageCent.fold(0, (int a, int b) => a + b),
        ecBelegeCent: List<int>.from(_ecBelegeCent),
        differenzAnfangsbestandCent: _differenzAnfangsbestandCent,
        stueckzahlen: widget.stueckzahlen,
        loseMuenzenNachArtCent: widget.loseMuenzenNachArtCent,
        umschlaege: widget.umschlaege,
        ausgabenBetraegeCent: List<int>.from(_ausgabenBetrageCent),
        ausgabenLabels: List<String>.from(_ausgabenLabels),
        ecBelegeLabels: List<String>.from(_ecBelegLabels),
        terminalId: _scanTerminalId,
        belegNrVon: _scanBelegNrVon,
        belegNrBis: _scanBelegNrBis,
        ecUhrzeit: _scanUhrzeit,
        zahlungsartenAufschluesselung: _baueZahlungsartenListe(),
        ecTerminals: _baueEcTerminals(),
        anmerkung: _anmerkung.trim().isNotEmpty ? _anmerkung.trim() : null,
      ),
    );
  }

  Future<bool> _pruefePflichtfelderVorSchritt3() async {
    setState(() {
      _validierungAusgeloest = true;
      if (!_ecKachelAufgeklappt) _ecKachelAufgeklappt = true;
      for (int i = 0; i < _ecBelegController.length; i++) {
        if (i < _ecUnterkachelAufgeklappt.length) {
          _ecUnterkachelAufgeklappt[i] = true;
        }
        if (i < _ecUnterkachelEditModus.length) {
          _ecUnterkachelEditModus[i] = true;
        }
        if (i < _zahlungsartZeilen.length) {
          for (final ZahlungsartZeile zeile in _zahlungsartZeilen[i]) {
            zeile.zustand = ZeilenZustand.editing;
          }
        }
      }
    });

    // V3: Ausgaben mit Label aber Betrag = 0
    for (int i = 0; i < _ausgabenLabels.length; i++) {
      if (_ausgabenLabels[i].trim().isNotEmpty &&
          (i < _ausgabenBetrageCent.length && _ausgabenBetrageCent[i] == 0)) {
        await _zeigeValidierungsfehlerUndFokussiere(
          fokusNode: _ausgabenBetragFocusNode[i],
          feldBezeichnung: 'Betrag für „${_ausgabenLabels[i]}"',
        );
        return false;
      }
    }

    final List<
            ({
              TextEditingController controller,
              FocusNode fokus,
              String bezeichnung
            })>
        pflichtfelder = <
            ({
              TextEditingController controller,
              FocusNode fokus,
              String bezeichnung
            })>[
      (
        controller: _kinoSollController,
        fokus: _kinoSollFocusNode,
        bezeichnung: 'Kino-Soll',
      ),
      if (widget.kinoId != 'kino_04')
        (
          controller: _bistroSollController,
          fokus: _bistroSollFocusNode,
          bezeichnung: 'Bistro-Soll',
        ),
      for (int i = 0; i < _ecBelegController.length; i++) ...<
          ({
            TextEditingController controller,
            FocusNode fokus,
            String bezeichnung
          })>[
        (
          controller: _ecBelegLabelController[i],
          fokus: _ecBelegLabelFocusNode[i],
          bezeichnung: 'Terminal-ID',
        ),
        (
          controller: _kartenartenGesamtBetragController[i],
          fokus: _kartenartenGesamtBetragFocusNode[i],
          bezeichnung: 'EC-Gesamtbetrag',
        ),
      ],
    ];

    for (final ({
      TextEditingController controller,
      FocusNode fokus,
      String bezeichnung
    }) feld in pflichtfelder) {
      if (feld.controller.text.trim().isEmpty) {
        await _zeigeValidierungsfehlerUndFokussiere(
          fokusNode: feld.fokus,
          feldBezeichnung: feld.bezeichnung,
        );
        return false;
      }
    }
    return true;
  }

  bool _istPflichtfeldLeer(TextEditingController controller) {
    return controller.text.trim().isEmpty;
  }

  String? _pflichtfeldFehlertext({
    required bool feldBeruehrt,
    required TextEditingController controller,
    String fehlertext = 'Pflichtfeld',
  }) {
    final bool fehlerSichtbar = _validierungAusgeloest || feldBeruehrt;
    if (!fehlerSichtbar || !_istPflichtfeldLeer(controller)) {
      return null;
    }
    return fehlertext;
  }

  Future<void> _zeigeValidierungsfehlerUndFokussiere({
    required FocusNode fokusNode,
    String feldBezeichnung = 'Dieses Feld',
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        content:
            Text('„$feldBezeichnung" ist ein Pflichtfeld — bitte ausfüllen.'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ändern'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    FocusScope.of(context).requestFocus(fokusNode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _macheFehlerfeldSichtbar(fokusNode);
    });
  }

  void _macheFehlerfeldSichtbar(FocusNode fokusNode) {
    final BuildContext? feldKontext = fokusNode.context;
    if (feldKontext == null) {
      return;
    }
    Scrollable.ensureVisible(
      feldKontext,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _ecBelegHinzufuegen() {
    setState(() {
      _letzteAenderung = DateTime.now();
      for (int j = 0; j < _ecUnterkachelAufgeklappt.length; j++) {
        _ecUnterkachelAufgeklappt[j] = false;
      }
      final int prevIdx = _ecUnterkachelEditModus.length - 1;
      if (prevIdx >= 0 &&
          (_ecBelegeCent[prevIdx] > 0 || _ecBelegLabels[prevIdx].isNotEmpty)) {
        _ecUnterkachelEditModus[prevIdx] = false;
      }
      _ecBelegController.add(TextEditingController());
      _ecBelegLabelController.add(TextEditingController());
      _ecBelegFocusNode.add(FocusNode());
      final FocusNode neueEcBelegLabelFn = FocusNode();
      _verknuepfeFeldNavigationSchritt2(neueEcBelegLabelFn);
      _ecBelegLabelFocusNode.add(neueEcBelegLabelFn);
      _ecBelegeCent.add(0);
      _ecBelegLabels.add('');
      _ecBelegIds.add(_naechsteEcBelegId++);
      _ecUnterkachelAufgeklappt.add(true);
      // Neuer Beleg startet im Mehrbeleg-Modus sofort editierbar (TID direkt eingebbar).
      _ecUnterkachelEditModus.add(true);
      _ecBelegScanGescannt.add(false);
      // per-Beleg
      _zahlungsartZeilen.add(
        _zahlungsartKonfigNamen.isEmpty
            ? <ZahlungsartZeile>[]
            : List<ZahlungsartZeile>.generate(
                _zahlungsartKonfigNamen.length,
                (int i) {
                  final ZahlungsartZeile zeile =
                      ZahlungsartZeile(_zahlungsartKonfigNamen[i]);
                  _verknuepfeFeldNavigationSchritt2(zeile.betragFocusNode);
                  return zeile;
                },
              ),
      );
      _scanHatStattgefunden.add(false);
      _kartenartenGesamtBetragCent.add(null);
      _kartenartenGesamtBetragController.add(TextEditingController());
      final FocusNode neuerKartenartenGesamtBetragFn = FocusNode();
      _verknuepfeFeldNavigationSchritt2(neuerKartenartenGesamtBetragFn);
      neuerKartenartenGesamtBetragFn.addListener(() {
        if (mounted) setState(() {});
      });
      _kartenartenGesamtBetragFocusNode.add(neuerKartenartenGesamtBetragFn);
      _metadatenAufgeklappt.add(false);
      _metadatenNurAnzeige.add(false);
    });
    _speichereEntwurf();
  }

  void _ecBelegEntfernen(int index) {
    if (_ecBelegController.length <= 1 ||
        index < 0 ||
        index >= _ecBelegController.length) {
      return;
    }
    setState(() {
      _letzteAenderung = DateTime.now();
      _ecBelegController.removeAt(index).dispose();
      _ecBelegLabelController.removeAt(index).dispose();
      _ecBelegFocusNode.removeAt(index).dispose();
      _ecBelegLabelFocusNode.removeAt(index).dispose();
      _ecBelegeCent.removeAt(index);
      _ecBelegLabels.removeAt(index);
      _ecBelegIds.removeAt(index);
      if (index < _ecUnterkachelAufgeklappt.length) _ecUnterkachelAufgeklappt.removeAt(index);
      if (index < _ecUnterkachelEditModus.length) _ecUnterkachelEditModus.removeAt(index);
      if (index < _ecBelegScanGescannt.length) _ecBelegScanGescannt.removeAt(index);
      // per-Beleg
      if (index < _zahlungsartZeilen.length) {
        for (final ZahlungsartZeile z in _zahlungsartZeilen[index]) {
          z.dispose();
        }
        _zahlungsartZeilen.removeAt(index);
      }
      if (index < _scanHatStattgefunden.length) _scanHatStattgefunden.removeAt(index);
      if (index < _kartenartenGesamtBetragCent.length) _kartenartenGesamtBetragCent.removeAt(index);
      if (index < _kartenartenGesamtBetragController.length) _kartenartenGesamtBetragController.removeAt(index).dispose();
      if (index < _kartenartenGesamtBetragFocusNode.length) _kartenartenGesamtBetragFocusNode.removeAt(index).dispose();
      if (index < _metadatenAufgeklappt.length) _metadatenAufgeklappt.removeAt(index);
      if (index < _metadatenNurAnzeige.length) _metadatenNurAnzeige.removeAt(index);
    });
    _speichereEntwurf();
  }

  int _parsiereBetragCent(String wert) =>
      TagesabschlussBerechnung.parseCentZiffern(wert);

  void _setzeControllerText(TextEditingController controller, String text) {
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _setzeEcBelegAnzahl(int anzahl) {
    while (_ecBelegController.length > anzahl) {
      _ecBelegController.removeLast().dispose();
      _ecBelegLabelController.removeLast().dispose();
      _ecBelegFocusNode.removeLast().dispose();
      _ecBelegLabelFocusNode.removeLast().dispose();
      _ecBelegeCent.removeLast();
      _ecBelegLabels.removeLast();
      _ecBelegIds.removeLast();
      if (_ecUnterkachelAufgeklappt.isNotEmpty) _ecUnterkachelAufgeklappt.removeLast();
      if (_ecUnterkachelEditModus.isNotEmpty) _ecUnterkachelEditModus.removeLast();
      if (_ecBelegScanGescannt.isNotEmpty) _ecBelegScanGescannt.removeLast();
      // per-Beleg
      if (_zahlungsartZeilen.isNotEmpty) {
        for (final ZahlungsartZeile z in _zahlungsartZeilen.last) {
          z.dispose();
        }
        _zahlungsartZeilen.removeLast();
      }
      if (_scanHatStattgefunden.isNotEmpty) _scanHatStattgefunden.removeLast();
      if (_kartenartenGesamtBetragCent.isNotEmpty) _kartenartenGesamtBetragCent.removeLast();
      if (_kartenartenGesamtBetragController.isNotEmpty) _kartenartenGesamtBetragController.removeLast().dispose();
      if (_kartenartenGesamtBetragFocusNode.isNotEmpty) _kartenartenGesamtBetragFocusNode.removeLast().dispose();
      if (_metadatenAufgeklappt.isNotEmpty) _metadatenAufgeklappt.removeLast();
      if (_metadatenNurAnzeige.isNotEmpty) _metadatenNurAnzeige.removeLast();
    }
    while (_ecBelegController.length < anzahl) {
      _ecBelegController.add(TextEditingController());
      _ecBelegLabelController.add(TextEditingController());
      _ecBelegFocusNode.add(FocusNode());
      final FocusNode ecBelegLabelFn = FocusNode()
        ..addListener(() {
          if (mounted) setState(() {});
        });
      _verknuepfeFeldNavigationSchritt2(ecBelegLabelFn);
      _ecBelegLabelFocusNode.add(ecBelegLabelFn);
      _ecBelegeCent.add(0);
      _ecBelegLabels.add('');
      _ecBelegIds.add(_naechsteEcBelegId++);
      _ecUnterkachelAufgeklappt.add(true);
      _ecUnterkachelEditModus.add(false);
      _ecBelegScanGescannt.add(false);
      // per-Beleg
      _zahlungsartZeilen.add(
        _zahlungsartKonfigNamen.isEmpty
            ? <ZahlungsartZeile>[]
            : List<ZahlungsartZeile>.generate(
                _zahlungsartKonfigNamen.length,
                (int i) {
                  final ZahlungsartZeile zeile =
                      ZahlungsartZeile(_zahlungsartKonfigNamen[i]);
                  _verknuepfeFeldNavigationSchritt2(zeile.betragFocusNode);
                  return zeile;
                },
              ),
      );
      _scanHatStattgefunden.add(false);
      _kartenartenGesamtBetragCent.add(null);
      _kartenartenGesamtBetragController.add(TextEditingController());
      final FocusNode kartenartenGesamtBetragFn = FocusNode();
      _verknuepfeFeldNavigationSchritt2(kartenartenGesamtBetragFn);
      kartenartenGesamtBetragFn.addListener(() {
        if (mounted) setState(() {});
      });
      _kartenartenGesamtBetragFocusNode.add(kartenartenGesamtBetragFn);
      _metadatenAufgeklappt.add(false);
      _metadatenNurAnzeige.add(false);
    }
  }

  void _beiAusgabenLabelGeaendert(int index, String wert) {
    setState(() {
      _letzteAenderung = DateTime.now();
      _ausgabenLabels[index] = wert;
    });
    _speichereEntwurf();
  }

  void _ausgabenLabelLoeschen(int index) {
    _ausgabenLabelController[index].clear();
    setState(() {
      _ausgabenLabels[index] = '';
    });
    _speichereEntwurf();
    _ausgabenLabelFocusNode[index].requestFocus();
  }

  void _beiAusgabenBetragGeaendert(int index, String wert) {
    setState(() {
      _letzteAenderung = DateTime.now();
      _ausgabenBetrageCent[index] = _parsiereBetragCent(wert);
    });
    _speichereEntwurf();
  }

  void _ausgabeHinzufuegen() {
    setState(() {
      _letzteAenderung = DateTime.now();
      final FocusNode neueAusgabenBetragFn = FocusNode();
      final FocusNode neueAusgabenLabelFn = FocusNode();
      _verknuepfeFeldNavigationSchritt2(neueAusgabenBetragFn);
      _verknuepfeFeldNavigationSchritt2(neueAusgabenLabelFn);
      _ausgabenBetragController.add(TextEditingController());
      _ausgabenLabelController.add(TextEditingController());
      _ausgabenBetragFocusNode.add(neueAusgabenBetragFn);
      _ausgabenLabelFocusNode.add(neueAusgabenLabelFn);
      _ausgabenBetrageCent.add(0);
      _ausgabenLabels.add('');
      _ausgabenIds.add(_naechsteAusgabeId++);
    });
    _speichereEntwurf();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _ausgabenLabelFocusNode.isNotEmpty) {
        FocusScope.of(context).requestFocus(_ausgabenLabelFocusNode.last);
      }
    });
  }

  void _ausgabeEntfernen(int index) {
    if (_ausgabenBetragController.length <= 1 ||
        index < 0 ||
        index >= _ausgabenBetragController.length) {
      return;
    }
    setState(() {
      _letzteAenderung = DateTime.now();
      _ausgabenBetragController.removeAt(index).dispose();
      _ausgabenLabelController.removeAt(index).dispose();
      _ausgabenBetragFocusNode.removeAt(index).dispose();
      _ausgabenLabelFocusNode.removeAt(index).dispose();
      _ausgabenBetrageCent.removeAt(index);
      _ausgabenLabels.removeAt(index);
      _ausgabenIds.removeAt(index);
    });
    _speichereEntwurf();
  }

  void _setzeAusgabenAnzahl(int anzahl) {
    while (_ausgabenBetragController.length > anzahl) {
      _ausgabenBetragController.removeLast().dispose();
      _ausgabenLabelController.removeLast().dispose();
      _ausgabenBetragFocusNode.removeLast().dispose();
      _ausgabenLabelFocusNode.removeLast().dispose();
      _ausgabenBetrageCent.removeLast();
      _ausgabenLabels.removeLast();
      _ausgabenIds.removeLast();
    }
    while (_ausgabenBetragController.length < anzahl) {
      _ausgabenBetragController.add(TextEditingController());
      _ausgabenLabelController.add(TextEditingController());
      final FocusNode ausgabenBetragFn = FocusNode();
      _verknuepfeFeldNavigationSchritt2(ausgabenBetragFn);
      _ausgabenBetragFocusNode.add(ausgabenBetragFn);
      final FocusNode ausgabenLabelFn = FocusNode()
        ..addListener(() {
          if (mounted) setState(() {});
        });
      _verknuepfeFeldNavigationSchritt2(ausgabenLabelFn);
      _ausgabenLabelFocusNode.add(ausgabenLabelFn);
      _ausgabenBetrageCent.add(0);
      _ausgabenLabels.add('');
      _ausgabenIds.add(_naechsteAusgabeId++);
    }
  }

  Future<void> _autoFillDev() async {
    final Map<String, dynamic>? daten =
        await LokalerSpeicher.ladeAutoFillSchritt2(widget.kinoId);
    if (!mounted) {
      return;
    }
    await _leereAlleFelder();
    if (!mounted) {
      return;
    }
    final int kinoSoll =
        (daten?['kinoSollCent'] as num?)?.toInt() ?? 0;
    final int bistroSoll =
        (daten?['bistroSollCent'] as num?)?.toInt() ?? 0;
    final int ausgaben =
        (daten?['ausgabenCent'] as num?)?.toInt() ?? 0;
    final int ecBeleg =
        (daten?['ecBelegCent'] as num?)?.toInt() ?? 0;
    final int differenz =
        (daten?['differenzAnfangsbestandCent'] as num?)?.toInt() ?? 0;

    setState(() {
      _kinoSollCent = kinoSoll;
      _bistroSollCent = bistroSoll;
      _differenzAnfangsbestandCent = differenz;

      _setzeEcBelegAnzahl(1);
      _ecBelegeCent[0] = ecBeleg;
      _ecBelegLabels[0] = '54017635';
      _kartenartenGesamtBetragCent[0] = ecBeleg;
      _kartenartenGesamt1Beruehrt = true;
      _ecBelegLabel1Beruehrt = true;

      _setzeAusgabenAnzahl(1);
      _ausgabenBetrageCent[0] = ausgaben;
      _ausgabenLabels[0] = '';

      _setzeControllerText(
        _kinoSollController,
        kinoSoll != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(kinoSoll)
            : '',
      );
      _setzeControllerText(
        _bistroSollController,
        bistroSoll != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(bistroSoll)
            : '',
      );
      _setzeControllerText(
        _ausgabenBetragController[0],
        ausgaben != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(ausgaben)
            : '',
      );
      _setzeControllerText(_ausgabenLabelController[0], '');
      _setzeControllerText(_differenzAnfangsbestandController, '');
      _setzeControllerText(
        _ecBelegController[0],
        ecBeleg != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(ecBeleg)
            : '',
      );
      _setzeControllerText(_ecBelegLabelController[0], '54017635');
      _setzeControllerText(
        _kartenartenGesamtBetragController[0],
        ecBeleg != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(ecBeleg)
            : '',
      );
      // Zahlungsarten aus Auto-Fill-Daten
      if (_zahlungsartZeilen.isNotEmpty) {
        final List<dynamic>? zahlungsartenNamen =
            daten?['zahlungsartenNamen'] as List<dynamic>?;
        final List<dynamic>? zahlungsartenBetragCent =
            daten?['zahlungsartenBetragCent'] as List<dynamic>?;
        if (zahlungsartenNamen != null) {
          for (int k = 0; k < zahlungsartenNamen.length; k++) {
            final String name = zahlungsartenNamen[k] as String;
            final int? betrag = k < (zahlungsartenBetragCent?.length ?? 0)
                ? (zahlungsartenBetragCent![k] as num?)?.toInt()
                : null;
            final int zeilenIdx =
                _zahlungsartZeilen[0].indexWhere((ZahlungsartZeile z) => z.name == name);
            if (zeilenIdx >= 0 && betrag != null) {
              _zahlungsartZeilen[0][zeilenIdx].betragCentWert = betrag;
              _zahlungsartZeilen[0][zeilenIdx].zustand = ZeilenZustand.shown;
              _setzeControllerText(
                _zahlungsartZeilen[0][zeilenIdx].betragController,
                TagesabschlussFormatierung.formatiereEuroEingabe(betrag),
              );
            }
          }
        }
      }
    });
    _speichereEntwurf();
  }

  void _leereAlleFelderDev() {
    FocusScope.of(context).unfocus();
    setState(() {
      _kinoSollCent = 0;
      _bistroSollCent = 0;
      _differenzAnfangsbestandCent = 0;

      _setzeEcBelegAnzahl(1);
      _ecBelegeCent[0] = 0;
      _ecBelegLabels[0] = '';

      _setzeAusgabenAnzahl(1);
      _ausgabenBetrageCent[0] = 0;
      _ausgabenLabels[0] = '';

      _setzeControllerText(_kinoSollController, '');
      _setzeControllerText(_bistroSollController, '');
      _setzeControllerText(_ausgabenBetragController[0], '');
      _setzeControllerText(_ausgabenLabelController[0], '');
      _setzeControllerText(_differenzAnfangsbestandController, '');
      _setzeControllerText(_ecBelegController[0], '');
      _setzeControllerText(_ecBelegLabelController[0], '');
      _scanTerminalId = null;
      _scanDatum = null;
      _scanUhrzeit = null;
      _scanBelegNrVon = null;
      _scanBelegNrBis = null;
      _setzeControllerText(_scanDatumController, '');
      _setzeControllerText(_scanUhrzeitController, '');
      _setzeControllerText(_scanBelegNrVonController, '');
      _setzeControllerText(_scanBelegNrBisController, '');
      if (_scanHatStattgefunden.isNotEmpty) _scanHatStattgefunden[0] = false;
      _bereinigUnbekannteZeilen(0);
      if (_zahlungsartZeilen.isNotEmpty) {
        for (final ZahlungsartZeile zeile in _zahlungsartZeilen[0]) {
          zeile.reset();
        }
      }
      if (_metadatenNurAnzeige.isNotEmpty) _metadatenNurAnzeige[0] = false;
      if (_metadatenAufgeklappt.isNotEmpty) _metadatenAufgeklappt[0] = false;
      if (_kartenartenGesamtBetragCent.isNotEmpty) _kartenartenGesamtBetragCent[0] = null;
      if (_kartenartenGesamtBetragController.isNotEmpty) _setzeControllerText(_kartenartenGesamtBetragController[0], '');
    });
  }

  Future<void> _leereAlleFelder() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _kinoSollCent = 0;
      _bistroSollCent = 0;
      _differenzAnfangsbestandCent = 0;
      _kinoSollBeruehrt = false;
      _bistroSollBeruehrt = false;
      _kartenartenGesamt1Beruehrt = false;
      _ecBelegLabel1Beruehrt = false;
      _validierungAusgeloest = false;

      _setzeEcBelegAnzahl(1);
      _ecBelegeCent[0] = 0;
      _ecBelegLabels[0] = '';

      _setzeAusgabenAnzahl(1);
      _ausgabenBetrageCent[0] = 0;
      _ausgabenLabels[0] = '';

      _setzeControllerText(_kinoSollController, '');
      _setzeControllerText(_bistroSollController, '');
      _setzeControllerText(_differenzAnfangsbestandController, '');
      _setzeControllerText(_ecBelegController[0], '');
      _setzeControllerText(_ecBelegLabelController[0], '');
      _setzeControllerText(_ausgabenBetragController[0], '');
      _setzeControllerText(_ausgabenLabelController[0], '');
      _scanTerminalId = null;
      _scanDatum = null;
      _scanUhrzeit = null;
      _scanBelegNrVon = null;
      _scanBelegNrBis = null;
      _setzeControllerText(_scanDatumController, '');
      _setzeControllerText(_scanUhrzeitController, '');
      _setzeControllerText(_scanBelegNrVonController, '');
      _setzeControllerText(_scanBelegNrBisController, '');
      if (_scanHatStattgefunden.isNotEmpty) _scanHatStattgefunden[0] = false;
      _bereinigUnbekannteZeilen(0);
      if (_zahlungsartZeilen.isNotEmpty) {
        for (final ZahlungsartZeile zeile in _zahlungsartZeilen[0]) {
          zeile.reset();
        }
      }
      if (_metadatenNurAnzeige.isNotEmpty) _metadatenNurAnzeige[0] = false;
      if (_metadatenAufgeklappt.isNotEmpty) _metadatenAufgeklappt[0] = false;
      if (_kartenartenGesamtBetragCent.isNotEmpty) _kartenartenGesamtBetragCent[0] = null;
      if (_kartenartenGesamtBetragController.isNotEmpty) _setzeControllerText(_kartenartenGesamtBetragController[0], '');
    });
    await LokalerSpeicher.loescheSchritt2Entwurf(widget.kinoId);
  }

  Future<void> _starteEcBelegScan({int belegIndex = 0}) async {
    final List<ConnectivityResult> verbindung =
        await Connectivity().checkConnectivity();
    if (verbindung.contains(ConnectivityResult.none)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein Internet – Scan nicht möglich.')),
      );
      return;
    }
    bool wiederholen;
    do {
      wiederholen = false;
      final XFile? bild =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (bild == null) return;
      setState(() => _scanBelegIndex = belegIndex);
      BelegScanErgebnis? originalErgebnis;
      try {
        final BelegScanErgebnis ergebnis = await BelegScanService.scan(bild);
        originalErgebnis = ergebnis;
        if (!mounted) return;
        setState(() => _scanBelegIndex = null);
        if (ergebnis.keinTerminalBeleg) {
          final bool? nochmal = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext ctx) => AlertDialog(
              title: const Text('Kein Terminal-Beleg'),
              content: const Text(
                'Das Foto zeigt keinen EC-Terminal-Beleg, '
                'oder die Aufnahme ist unscharf, zu dunkel '
                'oder unvollständig.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Abbrechen'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('nochmal'),
                      SizedBox(width: 6),
                      Icon(Icons.camera_alt_outlined, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          );
          if (!mounted) return;
          if (nochmal == true) {
            wiederholen = true;
            continue;
          }
          return;
        }
        final BelegScanErgebnis geprueftes = ergebnis;
        final List<BelegScanZeilenVorschau> vorschauZeilen =
            _baueScanVorschauZeilen(geprueftes, belegIndex);
        final bool uebernehmen = await zeigeBelegScanBestaetigenDialog(
          context,
          ergebnis: geprueftes,
          zeilen: vorschauZeilen,
        );
        if (!mounted) return;
        if (!uebernehmen) {
          wiederholen = true;
          continue;
        }
        final bool hatUnlesbareDaten =
            belegScanHatUnlesbareDaten(geprueftes, vorschauZeilen);
        setState(() {
          if (geprueftes.gesamtBetragCent != null) {
            _ecBelegeCent[belegIndex] = geprueftes.gesamtBetragCent!;
            _setzeControllerText(
              _ecBelegController[belegIndex],
              TagesabschlussFormatierung.formatiereEuroEingabe(
                  geprueftes.gesamtBetragCent!),
            );
            if (belegIndex == 0) _kartenartenGesamt1Beruehrt = true;
          }
          _scanTerminalId = _feldWertOderNull(geprueftes.terminalId);
          if (_scanTerminalId != null) {
            _ecBelegLabels[belegIndex] = _scanTerminalId!;
            _setzeControllerText(
                _ecBelegLabelController[belegIndex], _scanTerminalId!);
            if (belegIndex == 0) _ecBelegLabel1Beruehrt = true;
          }
          if (belegIndex < _ecUnterkachelAufgeklappt.length) {
            _ecUnterkachelAufgeklappt[belegIndex] = true;
          }
          if (belegIndex < _ecUnterkachelEditModus.length) {
            _ecUnterkachelEditModus[belegIndex] = false;
          }
          if (belegIndex < _ecBelegScanGescannt.length) {
            _ecBelegScanGescannt[belegIndex] = true;
          }
          _scanDatum = _feldWertOderNull(geprueftes.datum);
          _scanUhrzeit = _feldWertOderNull(geprueftes.uhrzeit);
          _scanBelegNrVon = _feldWertOderNull(geprueftes.belegNrVon);
          _scanBelegNrBis = _feldWertOderNull(geprueftes.belegNrBis);
          _setzeControllerText(_scanDatumController, _scanDatum ?? '');
          _setzeControllerText(_scanUhrzeitController, _scanUhrzeit ?? '');
          _setzeControllerText(
              _scanBelegNrVonController, _scanBelegNrVon ?? '');
          _setzeControllerText(
              _scanBelegNrBisController, _scanBelegNrBis ?? '');
          _scanHatStattgefunden[belegIndex] = true;
          _ecKachelAufgeklappt = true;
          _bereinigUnbekannteZeilen(belegIndex);
          for (final ZahlungsartZeile zeile in _zahlungsartZeilen[belegIndex]) {
            zeile.reset();
          }
          _sortiereZahlungsartenNachBeleg(geprueftes.zahlungsarten, belegIndex);
          _preFillZahlungsartenFromScan(geprueftes, originalErgebnis, belegIndex);
          if (hatUnlesbareDaten) {
            if (belegIndex < _ecUnterkachelEditModus.length) {
              _ecUnterkachelEditModus[belegIndex] = true;
            }
            // Nur die tatsächlich betroffenen Zeilen öffnen: erkannte
            // Kartenart mit unlesbarem Betrag, sowie die "unbekannte
            // Kartenart"-Zeile. Kartenarten ohne Umsatz bleiben hidden
            // und weiterhin nur über den "+"-Chip erreichbar.
            for (final ZahlungsartZeile zeile in _zahlungsartZeilen[belegIndex]) {
              if (zeile.istUnbekannt ||
                  (zeile.zustand == ZeilenZustand.shown &&
                      _istZeileImplausibel(zeile, belegIndex))) {
                zeile.zustand = ZeilenZustand.editing;
              }
            }
          }
          _kartenartenGesamtBetragCent[belegIndex] = geprueftes.gesamtBetragCent;
          _setzeControllerText(
            _kartenartenGesamtBetragController[belegIndex],
            _kartenartenGesamtBetragCent[belegIndex] != null
                ? TagesabschlussFormatierung
                    .formatiereEuroEingabe(_kartenartenGesamtBetragCent[belegIndex]!)
                : '',
          );
          _metadatenNurAnzeige[belegIndex] = true;
          _metadatenAufgeklappt[belegIndex] = false;
          _letzteAenderung = DateTime.now();
        });
        _speichereEntwurf();
        final String betrag = geprueftes.gesamtBetragCent != null
            ? '${(geprueftes.gesamtBetragCent! / 100).toStringAsFixed(2).replaceAll('.', ',')} €'
            : '—';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan bestätigt · Gesamt: $betrag')),
        );
      } on BelegScanException catch (e) {
        if (!mounted) return;
        final bool istNetzwerkFehler = e.message.startsWith('Keine Internet') ||
            e.message.startsWith('HTTP ');
        final bool istKonfigurationsFehler =
            e.message.startsWith('Service-URL nicht konfiguriert');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: (istNetzwerkFehler || istKonfigurationsFehler)
                ? Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: '${e.message}\n'),
                        const TextSpan(
                          text: 'Beleg kann auch manuell eingegeben werden.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : const Text(
                    'Scan nicht lesbar – bitte erneut versuchen\n'
                    '(z.B. unscharf, zu dunkel oder kein Beleg) oder Beleg '
                    'manuell eingeben.',
                  ),
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Scan nicht lesbar – bitte erneut versuchen\n'
              '(z.B. unscharf, zu dunkel oder kein Beleg) oder Beleg '
              'manuell eingeben.',
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _scanBelegIndex = null);
      }
    } while (wiederholen);
  }

  String? _feldWertOderNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  bool _subKachelTidUnleserlich(int i) {
    if (i >= _ecBelegScanGescannt.length || !_ecBelegScanGescannt[i]) {
      return false;
    }
    final String label = _ecBelegLabels[i];
    return label.isEmpty || label.trim().toLowerCase() == 'unleserlich';
  }

  bool _ersterBelegIstLeer() {
    return !_scanHatStattgefunden.any((bool b) => b) &&
        !_scanLaeuft &&
        _ecBelegeCent.fold(0, (int a, int b) => a + b) == 0;
  }

  /// Öffnet beim ersten (noch leeren) Beleg direkt alle Kartenart-Zeilen zur
  /// Bearbeitung, damit die manuelle Eingabe ohne Zwischenschritt möglich ist.
  void _oeffneErstenBelegZurBearbeitungFallsLeer() {
    if (_ersterBelegIstLeer() && _zahlungsartZeilen.isNotEmpty) {
      for (final ZahlungsartZeile zeile in _zahlungsartZeilen[0]) {
        zeile.zustand = ZeilenZustand.editing;
      }
    }
  }

  void _ecKachelToggleAufgeklappt() {
    final bool wirdGeoeffnet = !_ecKachelAufgeklappt;
    setState(() {
      _ecKachelAufgeklappt = !_ecKachelAufgeklappt;
      if (wirdGeoeffnet) {
        _oeffneErstenBelegZurBearbeitungFallsLeer();
      }
    });
  }

  void _manuellEingebenTap() {
    setState(() {
      _ecKachelAufgeklappt = true;
      _oeffneErstenBelegZurBearbeitungFallsLeer();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_ecBelegLabelFocusNode.first);
      }
    });
  }

  void _beiEcBelegLabel1Geaendert(String wert) {
    setState(() {
      _letzteAenderung = DateTime.now();
      _ecBelegLabels[0] = wert;
      _ecBelegLabel1Beruehrt = true;
    });
    _speichereEntwurf();
  }

  void _ecBelegLabel1Loeschen() {
    _ecBelegLabelController[0].clear();
    setState(() {
      _ecBelegLabels[0] = '';
    });
    _speichereEntwurf();
    _ecBelegLabelFocusNode[0].requestFocus();
  }

  void _ecUnterkachelToggleAufgeklappt(int belegIndex) {
    setState(() {
      _ecUnterkachelAufgeklappt[belegIndex] =
          !_ecUnterkachelAufgeklappt[belegIndex];
    });
  }

  void _beiSubKachelTidGeaendert(int belegIndex, String wert) {
    setState(() {
      _letzteAenderung = DateTime.now();
      _ecBelegLabels[belegIndex] = wert;
    });
    _speichereEntwurf();
  }

  bool _hatZahlungsartZeilenFuerBeleg(int belegIndex) {
    return _zahlungsartZeilen.length > belegIndex &&
        _zahlungsartZeilen[belegIndex].isNotEmpty;
  }

  bool _hatScanStattgefundenFuerBeleg(int belegIndex) {
    return _scanHatStattgefunden.length > belegIndex &&
        _scanHatStattgefunden[belegIndex];
  }

  void _ecUnterkachelFertig(int belegIndex) {
    setState(() {
      _ecUnterkachelEditModus[belegIndex] = false;
      _kartenartenFertig(belegIndex);
    });
  }

  void _manuellBearbeitenAktivieren(int i) {
    setState(() {
      if (i < _ecUnterkachelEditModus.length) {
        _ecUnterkachelEditModus[i] = true;
      }
      if (i < _zahlungsartZeilen.length) {
        for (final ZahlungsartZeile z in _zahlungsartZeilen[i]) {
          z.zustand = ZeilenZustand.editing;
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && i < _ecBelegLabelFocusNode.length) {
        FocusScope.of(context).requestFocus(_ecBelegLabelFocusNode[i]);
      }
    });
  }

  bool _matchKartenart(String configName, String belegArt) {
    if (belegArt.trim().isEmpty) return false;
    final String c = configName.trim().toLowerCase();
    final String b = belegArt.trim().toLowerCase();
    return b.contains(c) || c.contains(b);
  }

  /// Baut eine reine Lese-Vorschau der Scan-Zahlungsarten für das
  /// Bestätigungs-Popup, ohne `_zahlungsartZeilen` zu verändern.
  List<BelegScanZeilenVorschau> _baueScanVorschauZeilen(
      BelegScanErgebnis ergebnis, int belegIndex) {
    final List<BelegScanZeilenVorschau> vorschau = <BelegScanZeilenVorschau>[];
    final List<ZahlungsartZeile> zeilen =
        belegIndex < _zahlungsartZeilen.length
            ? _zahlungsartZeilen[belegIndex]
            : const <ZahlungsartZeile>[];
    for (final ZahlungsartErgebnis z in ergebnis.zahlungsarten) {
      if (z.art.trim().isEmpty) {
        vorschau.add(BelegScanZeilenVorschau(
          name: 'Unbekannte Kartenart',
          betragCent: z.betragCent,
          nichtLesbar: z.betragCent == null,
          nameNichtLesbar: true,
        ));
        continue;
      }
      String name = z.art;
      for (final ZahlungsartZeile zeile in zeilen) {
        if (_matchKartenart(zeile.name, z.art)) {
          name = zeile.name;
          break;
        }
      }
      vorschau.add(BelegScanZeilenVorschau(
        name: name,
        betragCent: z.betragCent,
        nichtLesbar: z.betragCent == null,
      ));
    }
    return vorschau;
  }

  void _bereinigUnbekannteZeilen(int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return;
    final List<ZahlungsartZeile> zuEntfernen = _zahlungsartZeilen[belegIndex]
        .where((ZahlungsartZeile z) => z.istUnbekannt)
        .toList();
    for (final ZahlungsartZeile z in zuEntfernen) {
      z.dispose();
    }
    _zahlungsartZeilen[belegIndex]
        .removeWhere((ZahlungsartZeile z) => z.istUnbekannt);
  }

  List<String> _dropdownOptionenFuerUnbekannte(int zeileIndex, int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return <String>[];
    final List<ZahlungsartZeile> zeilen = _zahlungsartZeilen[belegIndex];
    final Set<String> bereitsGewaehlt = <String>{};
    for (int i = 0; i < zeilen.length; i++) {
      if (i == zeileIndex) continue;
      final ZahlungsartZeile z = zeilen[i];
      if (z.istUnbekannt && z.name.isNotEmpty) {
        bereitsGewaehlt.add(z.name);
      }
    }
    return zeilen
        .where((ZahlungsartZeile z) =>
            !z.istUnbekannt &&
            z.zustand == ZeilenZustand.hidden &&
            !bereitsGewaehlt.contains(z.name))
        .map((ZahlungsartZeile z) => z.name)
        .toList();
  }

  /// true, wenn eine "unbekannte Kartenart"-Zeile bereits diesen Namen
  /// zugeordnet bekommen hat — der "+"-Chip für diesen Namen soll dann
  /// verschwinden, da die Kartenart schon erfasst ist.
  bool _kartenartBereitsAlsUnbekannteZugeordnet(String name, int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return false;
    return _zahlungsartZeilen[belegIndex]
        .any((ZahlungsartZeile z) => z.istUnbekannt && z.name == name);
  }

  void _sortiereZahlungsartenNachBeleg(
      List<ZahlungsartErgebnis> belegArten, int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return;
    final List<ZahlungsartZeile> zeilen = _zahlungsartZeilen[belegIndex];
    final List<ZahlungsartZeile> sortiert = <ZahlungsartZeile>[];
    for (final ZahlungsartErgebnis z in belegArten) {
      for (final ZahlungsartZeile zeile in zeilen) {
        if (!sortiert.contains(zeile) && _matchKartenart(zeile.name, z.art)) {
          sortiert.add(zeile);
          break;
        }
      }
    }
    for (final ZahlungsartZeile zeile in zeilen) {
      if (!sortiert.contains(zeile)) sortiert.add(zeile);
    }
    _zahlungsartZeilen[belegIndex] = sortiert;
  }

  void _preFillZahlungsartenFromScan(
    BelegScanErgebnis geprueftes,
    BelegScanErgebnis? original,
    int belegIndex,
  ) {
    if (belegIndex >= _zahlungsartZeilen.length) return;
    for (final ZahlungsartZeile zeile in _zahlungsartZeilen[belegIndex]) {
      ZahlungsartErgebnis? matching;
      for (final ZahlungsartErgebnis z in geprueftes.zahlungsarten) {
        if (_matchKartenart(zeile.name, z.art)) {
          matching = z;
          break;
        }
      }
      if (matching == null) {
        zeile.zustand = ZeilenZustand.hidden;
        zeile.nichtPlausibel = false;
        continue;
      }
      zeile.zustand = ZeilenZustand.shown;

      if (matching.betragCent != null) {
        zeile.betragCentWert = matching.betragCent;
        _setzeControllerText(
          zeile.betragController,
          TagesabschlussFormatierung.formatiereEuroEingabe(matching.betragCent!),
        );
      } else {
        zeile.betragCentWert = null;
        _setzeControllerText(zeile.betragController, '');
      }

      bool origNichtPlausibel = false;
      if (original != null) {
        for (final ZahlungsartErgebnis z in original.zahlungsarten) {
          if (_matchKartenart(zeile.name, z.art)) {
            origNichtPlausibel = z.betragCent == null;
            break;
          }
        }
      }
      zeile.nichtPlausibel = origNichtPlausibel;
    }

    for (final ZahlungsartErgebnis z in geprueftes.zahlungsarten) {
      if (z.art.trim().isEmpty && z.betragCent != null) {
        final ZahlungsartZeile unbekannte =
            ZahlungsartZeile('', istUnbekannt: true);
        unbekannte.betragFocusNode
            .addListener(() { if (mounted) setState(() {}); });
        _verknuepfeFeldNavigationSchritt2(unbekannte.betragFocusNode);
        unbekannte.betragCentWert = z.betragCent;
        _setzeControllerText(
          unbekannte.betragController,
          TagesabschlussFormatierung.formatiereEuroEingabe(z.betragCent!),
        );
        _zahlungsartZeilen[belegIndex].insert(0, unbekannte);
      }
    }
  }

  /// Rot markiert werden nur echte Scan-Problemfälle (Kartenart laut Rohdaten
  /// erkannt, aber Betrag nicht lesbar) — solange noch kein Betrag nachgetragen
  /// wurde. Zeilen, die schlicht nicht auf dem Beleg stehen oder 0 enthalten,
  /// bleiben unmarkiert.
  bool _istZeileImplausibel(ZahlungsartZeile zeile, int belegIndex) {
    return zeile.nichtPlausibel && zeile.betragCentWert == null;
  }

  List<ZahlungsartErgebnis>? _baueZahlungsartenListe() {
    final List<ZahlungsartErgebnis> liste = <ZahlungsartErgebnis>[];
    for (int belegIndex = 0; belegIndex < _zahlungsartZeilen.length; belegIndex++) {
      final String tid =
          belegIndex < _ecBelegLabels.length ? _ecBelegLabels[belegIndex] : '';
      for (final ZahlungsartZeile zeile in _zahlungsartZeilen[belegIndex]) {
        if (zeile.betragCentWert == null) continue;
        liste.add(ZahlungsartErgebnis(
          art: zeile.name,
          betragCent: zeile.betragCentWert,
          tid: tid.isEmpty ? null : tid,
        ));
      }
    }
    return liste.isEmpty ? null : liste;
  }

  List<EcTerminalErgebnis> _baueEcTerminals() {
    final List<EcTerminalErgebnis> liste = <EcTerminalErgebnis>[];
    for (int i = 0; i < _zahlungsartZeilen.length; i++) {
      final String tid =
          i < _ecBelegLabels.length ? _ecBelegLabels[i] : '';
      final List<ZahlungsartZeile> zeilen = _zahlungsartZeilen[i];

      int betragFuer(String art) {
        for (final ZahlungsartZeile z in zeilen) {
          if (z.name == art) return z.betragCentWert ?? 0;
        }
        return 0;
      }

      liste.add(EcTerminalErgebnis(
        tid: tid,
        girocard: betragFuer('girocard'),
        lastschrift: betragFuer('lastschrift'),
        mastercard: betragFuer('mastercard'),
        visa: betragFuer('visa'),
        maestro: betragFuer('maestro'),
        vpay: betragFuer('vpay'),
      ));
    }
    return liste;
  }

  Future<void> _bestaetigeUndLeereEingaben() async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Eingaben löschen?'),
        content: const Text('Alle Felder in Schritt 2 werden zurückgesetzt.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (bestaetigt != true || !mounted) {
      return;
    }
    await _leereAlleFelder();
  }

  List<FocusNode> _fokusReihenfolgeSchritt2() {
    final List<FocusNode> reihenfolge = _fokusHelper.fokusReihenfolge(
      differenzAnfangsbestandFocusNode: _differenzAnfangsbestandFocusNode,
      kinoSollFocusNode: _kinoSollFocusNode,
      bistroSollFocusNode: _bistroSollFocusNode,
      ausgabenLabelFocusNode: _ausgabenLabelFocusNode,
      ausgabenBetragFocusNode: _ausgabenBetragFocusNode,
      ecBelegLabelFocusNode: _ecBelegLabelFocusNode,
      kartenartenGesamtBetragFocusNode: _kartenartenGesamtBetragFocusNode,
      zahlungsartZeilen: _zahlungsartZeilen,
    );
    // Kein Bistro-SOLL-Feld fuer dieses Kino gebaut (siehe Kino-SOLL-
    // Card) -> zugehoerigen FocusNode aus der Fokus-Reihenfolge nehmen,
    // sonst landet "Weiter" auf einem FocusNode ohne Widget im Baum.
    if (widget.kinoId == 'kino_04') {
      reihenfolge.remove(_bistroSollFocusNode);
    }
    return reihenfolge;
  }

  bool _istLetztesFeldSchritt2(FocusNode focusNode) {
    return _fokusHelper.istLetztesFeld(_fokusReihenfolgeSchritt2(), focusNode);
  }

  FocusNode? _naechstesFeldSchritt2(FocusNode focusNode) {
    return _fokusHelper.naechstesFeld(_fokusReihenfolgeSchritt2(), focusNode);
  }

  TextInputAction _textInputActionFuerSchritt2(FocusNode focusNode) {
    return _fokusHelper.textInputActionFuer(_istLetztesFeldSchritt2(focusNode));
  }

  void _beiEingabeAbgeschlossenSchritt2(FocusNode focusNode) {
    _fokusHelper.beiEingabeAbgeschlossen(
      context: context,
      naechstesFeld: _naechstesFeldSchritt2(focusNode),
      fokussiereFeld: _fokussiereFeldSchritt2,
    );
  }

  void _fokussiereFeldSchritt2(FocusNode ziel) {
    _fokusHelper.fokussiereFeld(
      context: context,
      ziel: ziel,
      scrolleZurMitteNachFokus: _scrolleZurMitteNachFokus,
    );
  }

  void _verknuepfeFeldNavigationSchritt2(FocusNode fokusNode) {
    _fokusHelper.verknuepfeFeldNavigation(
      fokusNode: fokusNode,
      navHelper: _navHelper,
      context: context,
      reihenfolge: _fokusReihenfolgeSchritt2,
      fokussiere: _fokussiereFeldSchritt2,
    );
  }

  Future<void> _scrolleZurMitteNachFokus(FocusNode fn) {
    return _fokusHelper.scrolleZurMitteNachFokus(
      fn: fn,
      istMounted: () => mounted,
      context: context,
      scrollController: _scrollController,
    );
  }

  FocusNode? _erstesLeeresFeld() {
    return _fokusHelper.erstesLeeresFeld(
      kinoSollFocusNode: _kinoSollFocusNode,
      kinoSollController: _kinoSollController,
      bistroSollFocusNode: _bistroSollFocusNode,
      bistroSollController: _bistroSollController,
      differenzAnfangsbestandFocusNode: _differenzAnfangsbestandFocusNode,
      differenzAnfangsbestandController: _differenzAnfangsbestandController,
      ausgabenLabelFocusNode: _ausgabenLabelFocusNode,
      ausgabenLabelController: _ausgabenLabelController,
      ausgabenBetragFocusNode: _ausgabenBetragFocusNode,
      ausgabenBetragController: _ausgabenBetragController,
      ecBelegLabelFocusNode: _ecBelegLabelFocusNode,
      ecBelegLabelController: _ecBelegLabelController,
      kartenartenGesamtBetragFocusNode: _kartenartenGesamtBetragFocusNode,
      kartenartenGesamtBetragController: _kartenartenGesamtBetragController,
      zahlungsartZeilen: _zahlungsartZeilen,
      fokusReihenfolge: _fokusReihenfolgeSchritt2(),
    );
  }

  void _autoFokussiereNachLaden() {
    _fokusHelper.autoFokussiereNachLaden(
      istMounted: () => mounted,
      erstesLeeresFeld: _erstesLeeresFeld,
      context: context,
    );
  }

  void _beiScrollAenderung() {
    if (!mounted) return;
    setState(() {});
  }

  void _beiScrollMetrikAenderung() {
    if (!mounted) return;
    setState(() {});
  }

  bool _istDownButtonSichtbar() =>
      _scrollHelper.istDownButtonSichtbar(scrollController: _scrollController);

  void _scrolleNachUnten() =>
      _scrollHelper.scrolleNachUnten(scrollController: _scrollController);

  void _loescheKartenDaten() {
    setState(() {
      _scanTerminalId = null;
      _scanDatum = null;
      _scanUhrzeit = null;
      _scanBelegNrVon = null;
      _scanBelegNrBis = null;
      _setzeControllerText(_scanDatumController, '');
      _setzeControllerText(_scanUhrzeitController, '');
      _setzeControllerText(_scanBelegNrVonController, '');
      _setzeControllerText(_scanBelegNrBisController, '');
      _setzeEcBelegAnzahl(1);
      if (_ecUnterkachelEditModus.isNotEmpty) {
        _ecUnterkachelEditModus[0] = true;
      }
      _ecBelegeCent[0] = 0;
      _setzeControllerText(_ecBelegController[0], '');
      _kartenartenGesamt1Beruehrt = false;
      _ecBelegLabels[0] = '';
      _setzeControllerText(_ecBelegLabelController[0], '');
      _ecBelegLabel1Beruehrt = false;
      if (_scanHatStattgefunden.isNotEmpty) _scanHatStattgefunden[0] = false;
      _bereinigUnbekannteZeilen(0);
      if (_zahlungsartZeilen.isNotEmpty) {
        for (final ZahlungsartZeile zeile in _zahlungsartZeilen[0]) {
          zeile.reset();
        }
      }
      if (_metadatenNurAnzeige.isNotEmpty) _metadatenNurAnzeige[0] = false;
      if (_metadatenAufgeklappt.isNotEmpty) _metadatenAufgeklappt[0] = false;
      if (_kartenartenGesamtBetragCent.isNotEmpty) _kartenartenGesamtBetragCent[0] = null;
      if (_kartenartenGesamtBetragController.isNotEmpty) _setzeControllerText(_kartenartenGesamtBetragController[0], '');
      _letzteAenderung = DateTime.now();
    });
    _speichereEntwurf();
  }

  Widget _baueEingabeZeile({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required FocusNode focusNode,
    String? fehlermeldungText,
    bool optional = false,
    bool zeigeLoeschen = false,
    VoidCallback? onLoeschen,
    int? farbeNachWert,
    bool zeigeLabel = true,
    bool zeigeAdditionsButton = true,
  }) {
    return Schritt2EingabeZeile(
      label: label,
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputActionErmitteln: _textInputActionFuerSchritt2,
      beiEingabeAbgeschlossen: _beiEingabeAbgeschlossenSchritt2,
      fehlermeldungText: fehlermeldungText,
      optional: optional,
      zeigeLoeschen: zeigeLoeschen,
      onLoeschen: onLoeschen,
      farbeNachWert: farbeNachWert,
      zeigeLabel: zeigeLabel,
      zeigeAdditionsButton: zeigeAdditionsButton,
    );
  }

  void _zeigeSchrittSlider() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('1/4 · Bargeld zählen'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/closure-step-1'));
                },
              ),
              const ListTile(
                leading: Icon(Icons.check_circle),
                title: Text(
                  '2/4 · Belege',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Aktueller Schritt'),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.arrow_forward),
                title: const Text('3/4 · Finalisieren'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _weiterZuSchritt3();
                },
              ),
              const ListTile(
                title: Text('4/4 · Stückelung Barumsatz'),
                enabled: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _baueMetadatenBlock(int belegIndex) {
    final bool aufgeklappt = belegIndex < _metadatenAufgeklappt.length
        ? _metadatenAufgeklappt[belegIndex]
        : false;
    final bool nurAnzeige = belegIndex < _metadatenNurAnzeige.length
        ? _metadatenNurAnzeige[belegIndex]
        : false;
    return Schritt2MetadatenBlock(
      aufgeklappt: aufgeklappt,
      nurAnzeige: nurAnzeige,
      onToggleAufgeklappt: () => setState(() {
        if (belegIndex < _metadatenAufgeklappt.length) {
          _metadatenAufgeklappt[belegIndex] = !_metadatenAufgeklappt[belegIndex];
        }
      }),
      onToggleNurAnzeige: () {
        setState(() {
          if (belegIndex < _metadatenNurAnzeige.length) {
            _metadatenNurAnzeige[belegIndex] = !_metadatenNurAnzeige[belegIndex];
          }
        });
        if (belegIndex < _metadatenNurAnzeige.length &&
            !_metadatenNurAnzeige[belegIndex]) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scanDatumFocusNode.requestFocus();
          });
        }
      },
      scanDatum: _scanDatum,
      scanUhrzeit: _scanUhrzeit,
      scanBelegNrVon: _scanBelegNrVon,
      scanBelegNrBis: _scanBelegNrBis,
      scanDatumController: _scanDatumController,
      scanUhrzeitController: _scanUhrzeitController,
      scanBelegNrVonController: _scanBelegNrVonController,
      scanBelegNrBisController: _scanBelegNrBisController,
      scanDatumFocusNode: _scanDatumFocusNode,
      scanUhrzeitFocusNode: _scanUhrzeitFocusNode,
      scanBelegNrVonFocusNode: _scanBelegNrVonFocusNode,
      scanBelegNrBisFocusNode: _scanBelegNrBisFocusNode,
      onDatumGeaendert: (String wert) =>
          _scanMetadatenfeldGeaendert(wert, (String? w) => _scanDatum = w),
      onUhrzeitGeaendert: (String wert) =>
          _scanMetadatenfeldGeaendert(wert, (String? w) => _scanUhrzeit = w),
      onBelegNrVonGeaendert: (String wert) => _scanMetadatenfeldGeaendert(
          wert, (String? w) => _scanBelegNrVon = w),
      onBelegNrBisGeaendert: (String wert) => _scanMetadatenfeldGeaendert(
          wert, (String? w) => _scanBelegNrBis = w),
    );
  }

  void _scanMetadatenfeldGeaendert(
    String wert,
    void Function(String?) setter,
  ) {
    setState(() {
      _letzteAenderung = DateTime.now();
      setter(wert.trim().isEmpty ? null : wert);
    });
    _speichereEntwurf();
  }

  void _kartenartenFertig(int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return;
    for (final ZahlungsartZeile z in _zahlungsartZeilen[belegIndex]) {
      if (z.zustand == ZeilenZustand.editing) {
        z.zustand = z.betragCentWert != null
            ? ZeilenZustand.shown
            : ZeilenZustand.hidden;
      }
    }
  }

  Widget _baueZahlungsartenTabelle(int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return const SizedBox.shrink();
    final List<ZahlungsartZeile> zeilen = _zahlungsartZeilen[belegIndex];
    final bool editModus = zeilen.any((ZahlungsartZeile z) => z.zustand == ZeilenZustand.editing);
    final bool wurdeGescannt =
        belegIndex < _scanHatStattgefunden.length && _scanHatStattgefunden[belegIndex];
    final int? gesBetrag = belegIndex < _kartenartenGesamtBetragCent.length
        ? _kartenartenGesamtBetragCent[belegIndex]
        : null;
    int tabellenSummeCent = 0;
    for (final ZahlungsartZeile zeile in zeilen) {
      if (zeile.betragCentWert != null) tabellenSummeCent += zeile.betragCentWert!;
    }
    final int ecGesamtCent = belegIndex < _ecBelegeCent.length
        ? _ecBelegeCent[belegIndex]
        : 0;
    final bool summePasstNicht =
        tabellenSummeCent > 0 && ecGesamtCent > 0 && tabellenSummeCent != ecGesamtCent;
    final bool betragMismatch = gesBetrag != null && tabellenSummeCent != gesBetrag;
    final bool kartenartenHatFokus = zeilen.any(
      (ZahlungsartZeile z) => z.betragFocusNode.hasFocus,
    );
    final bool gesamtBetragHatFokus =
        belegIndex < _kartenartenGesamtBetragFocusNode.length &&
            _kartenartenGesamtBetragFocusNode[belegIndex].hasFocus;
    final bool irgendEineZeileInkonsistent = zeilen
        .where((ZahlungsartZeile z) => z.zustand != ZeilenZustand.hidden)
        .any((ZahlungsartZeile z) => _istZeileImplausibel(z, belegIndex));
    final TextEditingController gesamtBetragController =
        belegIndex < _kartenartenGesamtBetragController.length
            ? _kartenartenGesamtBetragController[belegIndex]
            : TextEditingController();
    final FocusNode? gesamtBetragFocusNode =
        belegIndex < _kartenartenGesamtBetragFocusNode.length
            ? _kartenartenGesamtBetragFocusNode[belegIndex]
            : null;
    final String? gesamtBetragErrorText =
        belegIndex < _kartenartenGesamtBetragController.length
            ? _pflichtfeldFehlertext(
                feldBeruehrt:
                    belegIndex == 0 ? _kartenartenGesamt1Beruehrt : false,
                controller: _kartenartenGesamtBetragController[belegIndex],
              )
            : null;

    return Schritt2ZahlungsartenTabelle(
      zeilen: zeilen,
      editModus: editModus,
      wurdeGescannt: wurdeGescannt,
      gesamtBetragCent: gesBetrag,
      tabellenSummeCent: tabellenSummeCent,
      summePasstNicht: summePasstNicht,
      betragMismatch: betragMismatch,
      kartenartenHatFokus: kartenartenHatFokus,
      gesamtBetragHatFokus: gesamtBetragHatFokus,
      irgendEineZeileInkonsistent: irgendEineZeileInkonsistent,
      gesamtBetragController: gesamtBetragController,
      gesamtBetragFocusNode: gesamtBetragFocusNode,
      gesamtBetragErrorText: gesamtBetragErrorText,
      zeigeKartenartenEditButton: _ecBelegController.length <= 1,
      istZeileImplausibel: (ZahlungsartZeile z) =>
          _istZeileImplausibel(z, belegIndex),
      dropdownOptionenFuerZeile: (int i) =>
          _dropdownOptionenFuerUnbekannte(i, belegIndex),
      istBereitsAlsUnbekannteZugeordnet: (String name) =>
          _kartenartBereitsAlsUnbekannteZugeordnet(name, belegIndex),
      onZeileNameGeaendert: (ZahlungsartZeile zeile, String? wert) {
        setState(() {
          zeile.name = wert ?? '';
          _letzteAenderung = DateTime.now();
        });
        _speichereEntwurf();
      },
      onZeileBetragGeaendert: (ZahlungsartZeile zeile, String wert) {
        setState(() {
          zeile.betragCentWert = _parsiereBetragCent(wert);
        });
      },
      onZeileAktivieren: (ZahlungsartZeile zeile) {
        setState(() {
          zeile.zustand = ZeilenZustand.editing;
        });
      },
      onGesamtBetragGeaendert: (String wert) {
        setState(() {
          if (belegIndex < _kartenartenGesamtBetragCent.length) {
            _kartenartenGesamtBetragCent[belegIndex] =
                wert.trim().isEmpty ? null : _parsiereBetragCent(wert);
            if (belegIndex < _ecBelegeCent.length) {
              _ecBelegeCent[belegIndex] =
                  _kartenartenGesamtBetragCent[belegIndex] ?? 0;
            }
          }
          if (belegIndex == 0) _kartenartenGesamt1Beruehrt = true;
          _letzteAenderung = DateTime.now();
        });
        _speichereEntwurf();
      },
      onEditButtonToggle: editModus
          ? () => setState(() => _kartenartenFertig(belegIndex))
          : () => setState(() {
                if (belegIndex < _zahlungsartZeilen.length) {
                  for (final ZahlungsartZeile z in _zahlungsartZeilen[belegIndex]) {
                    z.zustand = ZeilenZustand.editing;
                  }
                }
              }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_laedt) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bool tastaturOffen = MediaQuery.of(context).viewInsets.bottom > 0;
    // Ohne virtuelle Tastatur (z.B. Desktop-Browser) bleibt tastaturOffen
    // immer false -> zusaetzlich pruefen, ob ein Feld aus der Fokus-
    // Reihenfolge aktuell fokussiert ist, damit der Next-Button auch dort
    // erscheint.
    final bool feldFokussiert = _fokusReihenfolgeSchritt2()
        .any((FocusNode fn) => fn.hasFocus);
    final int ecGesamtCent = _ecBelegeCent.fold(0, (int a, int b) => a + b);
    final bool hatEcBelege = _scanHatStattgefunden.any((bool b) => b) || ecGesamtCent > 0;
    final int belegeWithData = List.generate(_ecBelegController.length, (int j) => j)
        .where((int j) => _ecBelegeCent[j] > 0 || _ecBelegLabels[j].isNotEmpty)
        .length;
    final Widget devToolsBereich = IgnorePointer(
      ignoring: !_devModusAktiv || !_devToolsOffen,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 140),
        opacity: _devModusAktiv && _devToolsOffen ? 1 : 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: _devModusAktiv && _devToolsOffen ? _devToolsPanelHoehe : 0,
          child: Schritt2DevToolsPanel(
            onAutoFill: _autoFillDev,
            onLeeren: _leereAlleFelderDev,
          ),
        ),
      ),
    );
    final Schritt2SectionWidgets sections =
        _gruppenOrchestrierung.baueSections(
      kinoName: widget.kinoName,
      kopfDatumUhrzeit: _kopfDatumUhrzeit(),
      personalgetraenkeGebot: _personalgetraenkeGebot,
      beiPersonalgetraenkeGeaendert: (bool? v) {
        setState(() => _personalgetraenkeGebot = v ?? false);
        _speichereEntwurf();
      },
      differenzAnfangsbestandEingabeZeile: _baueEingabeZeile(
        label: 'Differenz im Anfangsbestand',
        controller: _differenzAnfangsbestandController,
        focusNode: _differenzAnfangsbestandFocusNode,
        zeigeLabel: false,
        zeigeAdditionsButton: false,
        farbeNachWert: _differenzAnfangsbestandCent,
        onChanged: (String wert) {
          setState(() {
            _letzteAenderung = DateTime.now();
            final int absolutWert = _parsiereBetragCent(wert);
            final bool istNegativ = _differenzAnfangsbestandCent < 0;
            _differenzAnfangsbestandCent =
                istNegativ ? -absolutWert : absolutWert;
          });
          _speichereEntwurf();
        },
      ),
      vorzeichenToggleDifferenz: _vorzeichenToggleDifferenz,
      anmerkungController: _anmerkungController,
      anmerkungFocusNode: _anmerkungFocusNode,
      beiAnmerkungGeaendert: (String wert) {
        _anmerkung = wert;
        _speichereEntwurf();
      },
      kinoSollEingabeZeile: _baueEingabeZeile(
        label: 'Kino SOLL',
        controller: _kinoSollController,
        focusNode: _kinoSollFocusNode,
        fehlermeldungText: _pflichtfeldFehlertext(
          feldBeruehrt: _kinoSollBeruehrt,
          controller: _kinoSollController,
        ),
        onChanged: (String wert) {
          setState(() {
            _letzteAenderung = DateTime.now();
            _kinoSollBeruehrt = true;
            _kinoSollCent = _parsiereBetragCent(wert);
          });
          _speichereEntwurf();
        },
      ),
      bistroSollEingabeZeile: widget.kinoId == 'kino_04'
          ? null
          : _baueEingabeZeile(
              label: 'Bistro SOLL',
              controller: _bistroSollController,
              focusNode: _bistroSollFocusNode,
              fehlermeldungText: _pflichtfeldFehlertext(
                feldBeruehrt: _bistroSollBeruehrt,
                controller: _bistroSollController,
              ),
              onChanged: (String wert) {
                setState(() {
                  _letzteAenderung = DateTime.now();
                  _bistroSollBeruehrt = true;
                  _bistroSollCent = _parsiereBetragCent(wert);
                });
                _speichereEntwurf();
              },
            ),
      ausgabenIds: _ausgabenIds,
      ausgabenLabelController: _ausgabenLabelController,
      ausgabenLabelFocusNode: _ausgabenLabelFocusNode,
      ausgabenBetragController: _ausgabenBetragController,
      ausgabenBetragFocusNode: _ausgabenBetragFocusNode,
      textInputActionFuerSchritt2: _textInputActionFuerSchritt2,
      beiEingabeAbgeschlossen: _beiEingabeAbgeschlossenSchritt2,
      onAusgabenLabelGeaendert: _beiAusgabenLabelGeaendert,
      onAusgabenLabelGeloescht: _ausgabenLabelLoeschen,
      onAusgabenBetragGeaendert: _beiAusgabenBetragGeaendert,
      onAusgabeEntfernen: _ausgabeEntfernen,
      onAusgabeHinzufuegen: _ausgabeHinzufuegen,
    );
    final bool ecBeleg0ZeigeReadModus =
        _scanHatStattgefunden.isNotEmpty &&
        _scanHatStattgefunden[0] &&
        _zahlungsartZeilen.isNotEmpty &&
        !_zahlungsartZeilen[0].any(
          (ZahlungsartZeile z) => z.zustand == ZeilenZustand.editing,
        ) &&
        !_subKachelTidUnleserlich(0);
    final Widget belegInhalt = _ecBelegController.length == 1
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Schritt2EcBelegTerminalIdZeile(
                zeigeReadModus: ecBeleg0ZeigeReadModus,
                label: _ecBelegLabels[0],
                betragCent: _ecBelegeCent[0],
                controller: _ecBelegLabelController[0],
                focusNode: _ecBelegLabelFocusNode[0],
                hintUnleserlich: _subKachelTidUnleserlich(0),
                fehlermeldungText: _pflichtfeldFehlertext(
                  feldBeruehrt: _ecBelegLabel1Beruehrt,
                  controller: _ecBelegLabelController[0],
                  fehlertext: 'Terminal-ID eingeben',
                ),
                textInputActionErmitteln: _textInputActionFuerSchritt2,
                beiEingabeAbgeschlossen: _beiEingabeAbgeschlossenSchritt2,
                onChanged: _beiEcBelegLabel1Geaendert,
                onLoeschen: _ecBelegLabel1Loeschen,
              ),
              if (_scanHatStattgefunden.isNotEmpty && _scanHatStattgefunden[0])
                _baueMetadatenBlock(0),
              if (_zahlungsartZeilen.isNotEmpty &&
                  _zahlungsartZeilen[0].isNotEmpty)
                _baueZahlungsartenTabelle(0),
            ],
          )
        : _gruppenOrchestrierung.baueEcBelegSubKacheln(
            belegAnzahl: _ecBelegController.length,
            belegIds: _ecBelegIds,
            aufgeklapptListe: _ecUnterkachelAufgeklappt,
            onToggleAufgeklappt: _ecUnterkachelToggleAufgeklappt,
            editModusListe: _ecUnterkachelEditModus,
            scanBelegIndex: _scanBelegIndex,
            labelController: _ecBelegLabelController,
            labelFocusNode: _ecBelegLabelFocusNode,
            labels: _ecBelegLabels,
            betraegeCent: _ecBelegeCent,
            tidUnleserlich: _subKachelTidUnleserlich,
            scanLaeuft: _scanLaeuft,
            onScanStarten: (int i) => _starteEcBelegScan(belegIndex: i),
            onTidGeaendert: _beiSubKachelTidGeaendert,
            onBestaetigtEntfernen: _ecBelegEntfernen,
            hatZahlungsartZeilen: _hatZahlungsartZeilenFuerBeleg,
            hatScanStattgefunden: _hatScanStattgefundenFuerBeleg,
            baueZahlungsartenTabelle: _baueZahlungsartenTabelle,
            baueMetadatenBlock: _baueMetadatenBlock,
            onManuellBearbeitenAktivieren: _manuellBearbeitenAktivieren,
            onFertig: _ecUnterkachelFertig,
          );
    final Widget ecBelegeKachel = _gruppenOrchestrierung.baueEcBelegeKachel(
      aufgeklappt: _ecKachelAufgeklappt,
      onToggleAufgeklappt: _ecKachelToggleAufgeklappt,
      zeigeManuellEingebenLink:
          !_ecKachelAufgeklappt && _ersterBelegIstLeer(),
      onManuellEingebenTap: _manuellEingebenTap,
      scanLaeuft: _scanLaeuft,
      hatEcBelege: hatEcBelege,
      belegeWithData: belegeWithData,
      ecGesamtCent: ecGesamtCent,
      onScanStarten: () => _starteEcBelegScan(),
      onKartenDatenLoeschen: _loescheKartenDaten,
      belegdatenBearbeitenRecognizer: _belegdatenBearbeitenRecognizer,
      onBelegdatenBearbeitenTap: () => FocusScope.of(
        context,
      ).requestFocus(_ecBelegLabelFocusNode[0]),
      onEcBelegHinzufuegen: _ecBelegHinzufuegen,
      belegInhalt: belegInhalt,
    );
    final List<Widget> ecBelegeBereich = <Widget>[
                Stack(
                  children: <Widget>[
                ecBelegeKachel,
                  if (_scanLaeuft)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppFarben.appBarRot,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_ecKachelAufgeklappt && hatEcBelege)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setState(() => _ecKachelAufgeklappt = true);
                        _ecBelegHinzufuegen();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Weiteren Beleg hinzufügen'),
                    ),
                  ),
    ];
    return TagesabschlussScaffold(
      backgroundColor: AppFarben.seitenHintergrund,
      appBar: TagesabschlussHeader(
        schrittNummer: 2,
        schrittTitel: 'Belege',
        kinoName: widget.kinoName,
        onTap: _zeigeSchrittSlider,
        actions: <Widget>[
          const HelpButton(
            helpText:
                'Trage alle Belege ein: Kino- und Bistro-Soll aus dem '
                'Kassensystem, Ausgaben mit Quittung sowie EC-Belege. '
                'Daraus errechnet sich die Differenz zum gezählten Bargeld.',
          ),
          TextButton(
            onPressed: _bestaetigeUndLeereEingaben,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Clear'),
          ),
          if (_devModusAktiv)
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
        ],
      ),
      footerChild: SizedBox(
        height: 36,
        child: Row(
          children: <Widget>[
            if (tastaturOffen || feldFokussiert) ...<Widget>[
              TapRegion(
                groupId: EditableText,
                child: ElevatedButton(
                  onPressed: () => _navHelper.springeZuNaechstem(
                    context: context,
                    reihenfolge: _fokusReihenfolgeSchritt2(),
                    fokussiere: _fokussiereFeldSchritt2,
                    vorwaerts: true,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppFarben.appBarRot,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Next'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (!_personalgetraenkeGebot) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Personalgetränke gebont?')),
                    );
                    return;
                  }
                  _weiterZuSchritt3();
                },
                style: _personalgetraenkeGebot
                    ? AppFarben.footerButtonStyle
                    : ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.grey.shade300,
                      ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 6),
                      Text('Übertrag auf Umschlag (3/4)'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      child: Schritt2BodyContent(
        scrollController: _scrollController,
        devToolsBereich: devToolsBereich,
        kopfSection: sections.kopf,
        personalgetraenkeSection: sections.personalgetraenke,
        differenzAnfangsbestandSection: sections.differenzAnfangsbestand,
        kinoSollUndAusgabenBereich: sections.kinoSollUndAusgaben,
        ecBelegeBereich: ecBelegeBereich,
        anmerkungSection: sections.anmerkung,
        downButtonSichtbar: _istDownButtonSichtbar(),
        scrolleNachUnten: _scrolleNachUnten,
        beiScrollMetrikAenderung: _beiScrollMetrikAenderung,
      ),
    );
  }
}
