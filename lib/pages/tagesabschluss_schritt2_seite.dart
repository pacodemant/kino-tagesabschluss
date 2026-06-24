import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/services/beleg_scan_service.dart';
import 'package:kino_bar_app/services/zahlungsarten_config_service.dart';
import 'package:kino_bar_app/widgets/beleg_scan_gegenpruef_dialog.dart';
import 'package:kino_bar_app/services/dev_modus.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/utils/controller_dispose_mixin.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/eingabefeld_clear_helper.dart';
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

class _ZahlungsartZeile {
  _ZahlungsartZeile(this.name, {this.istUnbekannt = false})
      : anzahlController = TextEditingController(),
        betragController = TextEditingController(),
        anzahlFocusNode = FocusNode(),
        betragFocusNode = FocusNode();

  String name;
  final bool istUnbekannt;
  final TextEditingController anzahlController;
  final TextEditingController betragController;
  final FocusNode anzahlFocusNode;
  final FocusNode betragFocusNode;
  int? anzahlWert;
  int? betragCentWert;
  bool nichtPlausibel = false;
  bool nichtImScan = true;

  void dispose() {
    anzahlController.dispose();
    betragController.dispose();
    anzahlFocusNode.dispose();
    betragFocusNode.dispose();
  }

  void reset() {
    anzahlController.clear();
    betragController.clear();
    anzahlWert = null;
    betragCentWert = null;
    nichtPlausibel = false;
    nichtImScan = false;
  }
}

class _TagesabschlussSchritt2SeiteState
    extends State<TagesabschlussSchritt2Seite>
    with ControllerDisposeMixin {
  static const double _devToolsPanelHoehe = 68;

  final TextEditingController _kinoSollController = TextEditingController();
  final TextEditingController _bistroSollController = TextEditingController();
  final TextEditingController _differenzAnfangsbestandController =
      TextEditingController();
  final FocusNode _kinoSollFocusNode = FocusNode();
  final FocusNode _bistroSollFocusNode = FocusNode();
  final FocusNode _differenzAnfangsbestandFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
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
  final List<List<_ZahlungsartZeile>> _zahlungsartZeilen = <List<_ZahlungsartZeile>>[];
  final List<bool> _scanHatStattgefunden = <bool>[];
  final List<int?> _kartenartenGesamtAnzahl = <int?>[];
  final List<int?> _kartenartenGesamtBetragCent = <int?>[];
  final List<TextEditingController> _kartenartenGesamtAnzahlController = <TextEditingController>[];
  final List<TextEditingController> _kartenartenGesamtBetragController = <TextEditingController>[];
  final List<bool> _metadatenAufgeklappt = <bool>[];
  final List<bool> _metadatenNurAnzeige = <bool>[];
  final List<bool> _kartenartenNurAnzeige = <bool>[];

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
  bool _devToolsOffen = false;
  bool _devModusAktiv = false;
  int? _scanBelegIndex;
  bool get _scanLaeuft => _scanBelegIndex != null;
  bool _eingabeMitKomma = false;
  bool _validierungAusgeloest = false;
  bool _kinoSollBeruehrt = false;
  bool _bistroSollBeruehrt = false;
  bool _ecBeleg1Beruehrt = false;
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
  final GlobalKey _ecKachelKey = GlobalKey();
  bool _ecKachelZeigeScrollPfeil = false;

  @override
  void initState() {
    super.initState();
    _setzeEcBelegAnzahl(1);
    _setzeAusgabenAnzahl(1);
    DevModus.istAktiv().then((bool aktiv) {
      setState(() {
        _devModusAktiv = aktiv;
      });
    });
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      if (mounted) {
        setState(() {
          _eingabeMitKomma = prefs.getBool('eingabe_mit_komma') ?? false;
        });
      }
    });
    _scrollController.addListener(_aktualisiereScrollPfeil);
    for (final FocusNode fn in <FocusNode>[
      _scanDatumFocusNode,
      _scanUhrzeitFocusNode,
      _scanBelegNrVonFocusNode,
      _scanBelegNrBisFocusNode,
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
          for (final _ZahlungsartZeile z in _zahlungsartZeilen[b]) {
            z.dispose();
          }
          _zahlungsartZeilen[b] = List<_ZahlungsartZeile>.generate(
            liste.length,
            (int i) => _ZahlungsartZeile(liste[i]),
          );
        }
      });
      for (final List<_ZahlungsartZeile> belegZeilen in _zahlungsartZeilen) {
        for (final _ZahlungsartZeile zeile in belegZeilen) {
          zeile.anzahlFocusNode.addListener(() { if (mounted) setState(() {}); });
          zeile.betragFocusNode.addListener(() { if (mounted) setState(() {}); });
        }
      }
      await _ladeEntwurf();
      if (!mounted) return;
      _autoFokussiereNachLaden();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _aktualisiereScrollPfeil();
      });
    });
  }

  @override
  void dispose() {
    _kinoSollController.dispose();
    _bistroSollController.dispose();
    _differenzAnfangsbestandController.dispose();
    _kinoSollFocusNode.dispose();
    _bistroSollFocusNode.dispose();
    _differenzAnfangsbestandFocusNode.dispose();
    _scrollController.dispose();
    _scanDatumController.dispose();
    _scanUhrzeitController.dispose();
    _scanBelegNrVonController.dispose();
    _scanBelegNrBisController.dispose();
    _scanDatumFocusNode.dispose();
    _scanUhrzeitFocusNode.dispose();
    _scanBelegNrVonFocusNode.dispose();
    _scanBelegNrBisFocusNode.dispose();
    disposeControllers(_kartenartenGesamtAnzahlController);
    disposeControllers(_kartenartenGesamtBetragController);
    disposeControllers(_ecBelegController);
    disposeControllers(_ecBelegLabelController);
    disposeFocusNodes(_ecBelegFocusNode);
    disposeFocusNodes(_ecBelegLabelFocusNode);
    disposeControllers(_ausgabenBetragController);
    disposeControllers(_ausgabenLabelController);
    disposeFocusNodes(_ausgabenBetragFocusNode);
    disposeFocusNodes(_ausgabenLabelFocusNode);
    for (final List<_ZahlungsartZeile> belegZeilen in _zahlungsartZeilen) {
      for (final _ZahlungsartZeile zeile in belegZeilen) {
        zeile.dispose();
      }
    }
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
      // kartenartenGesamtAnzahl: neu List<int?>, rückwärtskompatibel int?
      final Object? gesAnzahlRoh = daten['kartenartenGesamtAnzahl'];
      if (gesAnzahlRoh is List<dynamic>) {
        for (int b = 0; b < _kartenartenGesamtAnzahl.length && b < gesAnzahlRoh.length; b++) {
          _kartenartenGesamtAnzahl[b] = (gesAnzahlRoh[b] as num?)?.toInt();
        }
      } else if (_kartenartenGesamtAnzahl.isNotEmpty) {
        _kartenartenGesamtAnzahl[0] = (gesAnzahlRoh as num?)?.toInt();
      }
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
    });

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
    for (int b = 0; b < _kartenartenGesamtAnzahlController.length; b++) {
      final int? anz = _kartenartenGesamtAnzahl[b];
      if (anz != null) {
        _setzeControllerText(_kartenartenGesamtAnzahlController[b], '$anz');
      }
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
    final Object? anzahlRoh = daten['zahlungsartAnzahlWerte'];
    final Object? betragRoh = daten['zahlungsartBetragCentWerte'];
    if (mounted && anzahlRoh is List<dynamic> && betragRoh is List<dynamic>) {
      // Neues Format: List<List<dynamic>>  –  altes Format: List<dynamic> (nur Beleg 0)
      final bool isNeuesFormat =
          anzahlRoh.isNotEmpty && anzahlRoh.first is List<dynamic>;
      if (isNeuesFormat) {
        setState(() {
          for (int b = 0; b < _zahlungsartZeilen.length && b < anzahlRoh.length; b++) {
            final List<dynamic> bAnzahl = anzahlRoh[b] as List<dynamic>;
            final List<dynamic> bBetrag = b < betragRoh.length
                ? (betragRoh[b] as List<dynamic>)
                : <dynamic>[];
            for (int i = 0;
                i < _zahlungsartZeilen[b].length &&
                    i < bAnzahl.length &&
                    i < bBetrag.length;
                i++) {
              _zahlungsartZeilen[b][i].anzahlWert = (bAnzahl[i] as num?)?.toInt();
              _zahlungsartZeilen[b][i].betragCentWert = (bBetrag[i] as num?)?.toInt();
            }
          }
        });
        for (int b = 0; b < _zahlungsartZeilen.length && b < anzahlRoh.length; b++) {
          final List<dynamic> bAnzahl = anzahlRoh[b] as List<dynamic>;
          final List<dynamic> bBetrag = b < betragRoh.length
              ? (betragRoh[b] as List<dynamic>)
              : <dynamic>[];
          for (int i = 0;
              i < _zahlungsartZeilen[b].length &&
                  i < bAnzahl.length &&
                  i < bBetrag.length;
              i++) {
            final int? anzahl = _zahlungsartZeilen[b][i].anzahlWert;
            final int? betrag = _zahlungsartZeilen[b][i].betragCentWert;
            if (anzahl != null) {
              _setzeControllerText(_zahlungsartZeilen[b][i].anzahlController, '$anzahl');
            }
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
                i < _zahlungsartZeilen[0].length &&
                    i < anzahlRoh.length &&
                    i < betragRoh.length;
                i++) {
              _zahlungsartZeilen[0][i].anzahlWert = (anzahlRoh[i] as num?)?.toInt();
              _zahlungsartZeilen[0][i].betragCentWert = (betragRoh[i] as num?)?.toInt();
            }
          });
          for (int i = 0;
              i < _zahlungsartZeilen[0].length &&
                  i < anzahlRoh.length &&
                  i < betragRoh.length;
              i++) {
            final int? anzahl = _zahlungsartZeilen[0][i].anzahlWert;
            final int? betrag = _zahlungsartZeilen[0][i].betragCentWert;
            if (anzahl != null) {
              _setzeControllerText(_zahlungsartZeilen[0][i].anzahlController, '$anzahl');
            }
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
    // Nach dem Laden: Anzeige-Modus setzen für Belege mit Zahlungsarten-Daten
    if (mounted) {
      setState(() {
        for (int b = 0; b < _zahlungsartZeilen.length; b++) {
          if (_kartenartenNurAnzeige.length > b &&
              (_scanHatStattgefunden.length > b && _scanHatStattgefunden[b] ||
                  _zahlungsartZeilen[b]
                      .any((_ZahlungsartZeile z) => z.anzahlWert != null || z.betragCentWert != null))) {
            _kartenartenNurAnzeige[b] = true;
          }
        }
      });
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
        'kartenartenGesamtAnzahl': List<int?>.from(_kartenartenGesamtAnzahl),
        'kartenartenGesamtBetragCent': List<int?>.from(_kartenartenGesamtBetragCent),
        'zahlungsartAnzahlWerte': <List<int?>>[
          for (final List<_ZahlungsartZeile> belegZeilen in _zahlungsartZeilen)
            belegZeilen
                .where((_ZahlungsartZeile z) => !z.istUnbekannt)
                .map((_ZahlungsartZeile z) => z.anzahlWert)
                .toList(),
        ],
        'zahlungsartBetragCentWerte': <List<int?>>[
          for (final List<_ZahlungsartZeile> belegZeilen in _zahlungsartZeilen)
            belegZeilen
                .where((_ZahlungsartZeile z) => !z.istUnbekannt)
                .map((_ZahlungsartZeile z) => z.betragCentWert)
                .toList(),
        ],
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

  void _weiterZuSchritt3() {
    if (!_pruefePflichtfelderVorSchritt3()) {
      return;
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
      ),
    );
  }

  /// Prueft nur die fachlich noetigen Pflichtfelder vor dem finalen Abschluss.
  bool _pruefePflichtfelderVorSchritt3() {
    setState(() {
      _validierungAusgeloest = true;
      if (!_ecKachelAufgeklappt) _ecKachelAufgeklappt = true;
      if (_ecUnterkachelAufgeklappt.isNotEmpty &&
          !_ecUnterkachelAufgeklappt[0]) {
        _ecUnterkachelAufgeklappt[0] = true;
      }
    });

    final List<({TextEditingController controller, FocusNode fokus})>
    pflichtfelder = <({TextEditingController controller, FocusNode fokus})>[
      (controller: _kinoSollController, fokus: _kinoSollFocusNode),
      if (widget.kinoId != 'kino_04')
        (controller: _bistroSollController, fokus: _bistroSollFocusNode),
      (
        controller: _ecBelegLabelController.first,
        fokus: _ecBelegLabelFocusNode.first
      ),
      (controller: _ecBelegController.first, fokus: _ecBelegFocusNode.first),
    ];

    for (final ({TextEditingController controller, FocusNode fokus}) feld
        in pflichtfelder) {
      if (feld.controller.text.trim().isEmpty) {
        _zeigeValidierungsfehlerUndFokussiere(fokusNode: feld.fokus);
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

  /// Zeigt eine knappe Rueckmeldung und macht das erste fehlerhafte Feld sichtbar.
  void _zeigeValidierungsfehlerUndFokussiere({required FocusNode fokusNode}) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bitte Pflichtfelder ausfüllen.')),
    );
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
      _ecBelegLabelFocusNode.add(FocusNode());
      _ecBelegeCent.add(0);
      _ecBelegLabels.add('');
      _ecBelegIds.add(_naechsteEcBelegId++);
      _ecUnterkachelAufgeklappt.add(true);
      _ecUnterkachelEditModus.add(false);
      _ecBelegScanGescannt.add(false);
      // per-Beleg
      _zahlungsartZeilen.add(
        _zahlungsartKonfigNamen.isEmpty
            ? <_ZahlungsartZeile>[]
            : List<_ZahlungsartZeile>.generate(
                _zahlungsartKonfigNamen.length,
                (int i) => _ZahlungsartZeile(_zahlungsartKonfigNamen[i]),
              ),
      );
      _scanHatStattgefunden.add(false);
      _kartenartenGesamtAnzahl.add(null);
      _kartenartenGesamtBetragCent.add(null);
      _kartenartenGesamtAnzahlController.add(TextEditingController());
      _kartenartenGesamtBetragController.add(TextEditingController());
      _metadatenAufgeklappt.add(false);
      _metadatenNurAnzeige.add(false);
      _kartenartenNurAnzeige.add(true);
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
        for (final _ZahlungsartZeile z in _zahlungsartZeilen[index]) {
          z.dispose();
        }
        _zahlungsartZeilen.removeAt(index);
      }
      if (index < _scanHatStattgefunden.length) _scanHatStattgefunden.removeAt(index);
      if (index < _kartenartenGesamtAnzahl.length) _kartenartenGesamtAnzahl.removeAt(index);
      if (index < _kartenartenGesamtBetragCent.length) _kartenartenGesamtBetragCent.removeAt(index);
      if (index < _kartenartenGesamtAnzahlController.length) _kartenartenGesamtAnzahlController.removeAt(index).dispose();
      if (index < _kartenartenGesamtBetragController.length) _kartenartenGesamtBetragController.removeAt(index).dispose();
      if (index < _metadatenAufgeklappt.length) _metadatenAufgeklappt.removeAt(index);
      if (index < _metadatenNurAnzeige.length) _metadatenNurAnzeige.removeAt(index);
      if (index < _kartenartenNurAnzeige.length) _kartenartenNurAnzeige.removeAt(index);
    });
    _speichereEntwurf();
  }

  int _parsiereBetragCent(String wert) => _eingabeMitKomma
      ? TagesabschlussBerechnung.parseCentKomma(wert)
      : TagesabschlussBerechnung.parseCentZiffern(wert);

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
        for (final _ZahlungsartZeile z in _zahlungsartZeilen.last) {
          z.dispose();
        }
        _zahlungsartZeilen.removeLast();
      }
      if (_scanHatStattgefunden.isNotEmpty) _scanHatStattgefunden.removeLast();
      if (_kartenartenGesamtAnzahl.isNotEmpty) _kartenartenGesamtAnzahl.removeLast();
      if (_kartenartenGesamtBetragCent.isNotEmpty) _kartenartenGesamtBetragCent.removeLast();
      if (_kartenartenGesamtAnzahlController.isNotEmpty) _kartenartenGesamtAnzahlController.removeLast().dispose();
      if (_kartenartenGesamtBetragController.isNotEmpty) _kartenartenGesamtBetragController.removeLast().dispose();
      if (_metadatenAufgeklappt.isNotEmpty) _metadatenAufgeklappt.removeLast();
      if (_metadatenNurAnzeige.isNotEmpty) _metadatenNurAnzeige.removeLast();
      if (_kartenartenNurAnzeige.isNotEmpty) _kartenartenNurAnzeige.removeLast();
    }
    while (_ecBelegController.length < anzahl) {
      _ecBelegController.add(TextEditingController());
      _ecBelegLabelController.add(TextEditingController());
      _ecBelegFocusNode.add(FocusNode());
      final FocusNode ecBelegLabelFn = FocusNode()
        ..addListener(() {
          if (mounted) setState(() {});
        });
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
            ? <_ZahlungsartZeile>[]
            : List<_ZahlungsartZeile>.generate(
                _zahlungsartKonfigNamen.length,
                (int i) => _ZahlungsartZeile(_zahlungsartKonfigNamen[i]),
              ),
      );
      _scanHatStattgefunden.add(false);
      _kartenartenGesamtAnzahl.add(null);
      _kartenartenGesamtBetragCent.add(null);
      _kartenartenGesamtAnzahlController.add(TextEditingController());
      _kartenartenGesamtBetragController.add(TextEditingController());
      _metadatenAufgeklappt.add(false);
      _metadatenNurAnzeige.add(false);
      _kartenartenNurAnzeige.add(true);
    }
  }

  void _ausgabeHinzufuegen() {
    setState(() {
      _letzteAenderung = DateTime.now();
      _ausgabenBetragController.add(TextEditingController());
      _ausgabenLabelController.add(TextEditingController());
      _ausgabenBetragFocusNode.add(FocusNode());
      _ausgabenLabelFocusNode.add(FocusNode());
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
      _ausgabenBetragFocusNode.add(FocusNode());
      final FocusNode ausgabenLabelFn = FocusNode()
        ..addListener(() {
          if (mounted) setState(() {});
        });
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
      _ecBelegLabels[0] = '';

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
      _setzeControllerText(_ecBelegLabelController[0], '');
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
        for (final _ZahlungsartZeile zeile in _zahlungsartZeilen[0]) {
          zeile.reset();
        }
      }
      if (_metadatenNurAnzeige.isNotEmpty) _metadatenNurAnzeige[0] = false;
      if (_metadatenAufgeklappt.isNotEmpty) _metadatenAufgeklappt[0] = false;
      if (_kartenartenNurAnzeige.isNotEmpty) _kartenartenNurAnzeige[0] = false;
      if (_kartenartenGesamtAnzahl.isNotEmpty) _kartenartenGesamtAnzahl[0] = null;
      if (_kartenartenGesamtBetragCent.isNotEmpty) _kartenartenGesamtBetragCent[0] = null;
      if (_kartenartenGesamtAnzahlController.isNotEmpty) _setzeControllerText(_kartenartenGesamtAnzahlController[0], '');
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
      _ecBeleg1Beruehrt = false;
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
        for (final _ZahlungsartZeile zeile in _zahlungsartZeilen[0]) {
          zeile.reset();
        }
      }
      if (_metadatenNurAnzeige.isNotEmpty) _metadatenNurAnzeige[0] = false;
      if (_metadatenAufgeklappt.isNotEmpty) _metadatenAufgeklappt[0] = false;
      if (_kartenartenNurAnzeige.isNotEmpty) _kartenartenNurAnzeige[0] = false;
      if (_kartenartenGesamtAnzahl.isNotEmpty) _kartenartenGesamtAnzahl[0] = null;
      if (_kartenartenGesamtBetragCent.isNotEmpty) _kartenartenGesamtBetragCent[0] = null;
      if (_kartenartenGesamtAnzahlController.isNotEmpty) _setzeControllerText(_kartenartenGesamtAnzahlController[0], '');
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
        final BelegScanDialogErgebnis? dialogErgebnis =
            await showDialog<BelegScanDialogErgebnis>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) =>
              BelegScanGegenpruefDialog(ergebnis: ergebnis),
        );
        if (!mounted) return;
        if (dialogErgebnis == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scan abgebrochen.')),
          );
          return;
        }
        if (dialogErgebnis.istNeueScanAnfrage) {
          wiederholen = true;
          continue;
        }
        final BelegScanErgebnis geprueftes = dialogErgebnis.ergebnis!;
        setState(() {
          if (geprueftes.gesamtBetragCent != null) {
            _ecBelegeCent[belegIndex] = geprueftes.gesamtBetragCent!;
            _setzeControllerText(
              _ecBelegController[belegIndex],
              TagesabschlussFormatierung.formatiereEuroEingabe(
                  geprueftes.gesamtBetragCent!),
            );
            if (belegIndex == 0) _ecBeleg1Beruehrt = true;
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
          for (final _ZahlungsartZeile zeile in _zahlungsartZeilen[belegIndex]) {
            zeile.reset();
          }
          _sortiereZahlungsartenNachBeleg(geprueftes.zahlungsarten, belegIndex);
          _preFillZahlungsartenFromScan(geprueftes, originalErgebnis, belegIndex);
          _kartenartenGesamtAnzahl[belegIndex] = geprueftes.gesamtAnzahl;
          _kartenartenGesamtBetragCent[belegIndex] = geprueftes.gesamtBetragCent;
          _setzeControllerText(
            _kartenartenGesamtAnzahlController[belegIndex],
            _kartenartenGesamtAnzahl[belegIndex] != null
                ? '${_kartenartenGesamtAnzahl[belegIndex]}'
                : '',
          );
          _setzeControllerText(
            _kartenartenGesamtBetragController[belegIndex],
            _kartenartenGesamtBetragCent[belegIndex] != null
                ? TagesabschlussFormatierung
                    .formatiereEuroEingabe(_kartenartenGesamtBetragCent[belegIndex]!)
                : '',
          );
          _metadatenNurAnzeige[belegIndex] = true;
          _metadatenAufgeklappt[belegIndex] = false;
          _kartenartenNurAnzeige[belegIndex] = true;
          _letzteAenderung = DateTime.now();
        });
        _speichereEntwurf();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _aktualisiereScrollPfeil();
        });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              istNetzwerkFehler
                  ? e.message
                  : 'Scan nicht lesbar – bitte erneut versuchen\n'
                      '(z.B. unscharf, zu dunkel oder kein Beleg).',
            ),
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Scan nicht lesbar – bitte erneut versuchen\n'
              '(z.B. unscharf, zu dunkel oder kein Beleg).',
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

  void _manuellBearbeitenAktivieren(int i) {
    setState(() {
      if (i < _ecUnterkachelEditModus.length) {
        _ecUnterkachelEditModus[i] = true;
      }
      if (i < _kartenartenNurAnzeige.length) {
        _kartenartenNurAnzeige[i] = false;
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

  void _bereinigUnbekannteZeilen(int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return;
    final List<_ZahlungsartZeile> zuEntfernen = _zahlungsartZeilen[belegIndex]
        .where((_ZahlungsartZeile z) => z.istUnbekannt)
        .toList();
    for (final _ZahlungsartZeile z in zuEntfernen) {
      z.dispose();
    }
    _zahlungsartZeilen[belegIndex]
        .removeWhere((_ZahlungsartZeile z) => z.istUnbekannt);
  }

  List<String> _dropdownOptionenFuerUnbekannte(int zeileIndex, int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return <String>[];
    final List<_ZahlungsartZeile> zeilen = _zahlungsartZeilen[belegIndex];
    final Set<String> bereitsGewaehlt = <String>{};
    for (int i = 0; i < zeilen.length; i++) {
      if (i == zeileIndex) continue;
      final _ZahlungsartZeile z = zeilen[i];
      if (z.istUnbekannt && z.name.isNotEmpty) {
        bereitsGewaehlt.add(z.name);
      }
    }
    return zeilen
        .where((_ZahlungsartZeile z) =>
            !z.istUnbekannt &&
            z.nichtImScan &&
            !bereitsGewaehlt.contains(z.name))
        .map((_ZahlungsartZeile z) => z.name)
        .toList();
  }

  void _sortiereZahlungsartenNachBeleg(
      List<ZahlungsartErgebnis> belegArten, int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return;
    final List<_ZahlungsartZeile> zeilen = _zahlungsartZeilen[belegIndex];
    final List<_ZahlungsartZeile> sortiert = <_ZahlungsartZeile>[];
    for (final ZahlungsartErgebnis z in belegArten) {
      for (final _ZahlungsartZeile zeile in zeilen) {
        if (!sortiert.contains(zeile) && _matchKartenart(zeile.name, z.art)) {
          sortiert.add(zeile);
          break;
        }
      }
    }
    for (final _ZahlungsartZeile zeile in zeilen) {
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
    for (final _ZahlungsartZeile zeile in _zahlungsartZeilen[belegIndex]) {
      ZahlungsartErgebnis? matching;
      for (final ZahlungsartErgebnis z in geprueftes.zahlungsarten) {
        if (_matchKartenart(zeile.name, z.art)) {
          matching = z;
          break;
        }
      }
      if (matching == null) {
        zeile.nichtImScan = true;
        continue;
      }
      zeile.nichtImScan = false;

      if (matching.anzahl != null) {
        zeile.anzahlWert = matching.anzahl;
        _setzeControllerText(zeile.anzahlController, '${matching.anzahl}');
      } else {
        zeile.anzahlWert = null;
        _setzeControllerText(zeile.anzahlController, '');
      }

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
            origNichtPlausibel = z.betragCent == null || z.anzahl == null;
            break;
          }
        }
      }
      zeile.nichtPlausibel = origNichtPlausibel;
    }

    for (final ZahlungsartErgebnis z in geprueftes.zahlungsarten) {
      if (z.art.trim().isEmpty && (z.betragCent != null || z.anzahl != null)) {
        final _ZahlungsartZeile unbekannte =
            _ZahlungsartZeile('', istUnbekannt: true);
        unbekannte.anzahlFocusNode
            .addListener(() { if (mounted) setState(() {}); });
        unbekannte.betragFocusNode
            .addListener(() { if (mounted) setState(() {}); });
        if (z.anzahl != null) {
          unbekannte.anzahlWert = z.anzahl;
          _setzeControllerText(unbekannte.anzahlController, '${z.anzahl}');
        }
        if (z.betragCent != null) {
          unbekannte.betragCentWert = z.betragCent;
          _setzeControllerText(
            unbekannte.betragController,
            TagesabschlussFormatierung.formatiereEuroEingabe(z.betragCent!),
          );
        }
        _zahlungsartZeilen[belegIndex].insert(0, unbekannte);
      }
    }
  }

  bool _istZeileImplausibel(_ZahlungsartZeile zeile, int belegIndex) {
    if (zeile.anzahlWert == null && zeile.betragCentWert == null) {
      return belegIndex < _scanHatStattgefunden.length &&
          _scanHatStattgefunden[belegIndex] &&
          !zeile.nichtImScan;
    }
    if (zeile.anzahlWert == null || zeile.betragCentWert == null) return true;
    if (zeile.anzahlWert == 0) return true;
    return false;
  }

  List<ZahlungsartErgebnis>? _baueZahlungsartenListe() {
    final List<ZahlungsartErgebnis> liste = <ZahlungsartErgebnis>[];
    for (final List<_ZahlungsartZeile> belegZeilen in _zahlungsartZeilen) {
      for (final _ZahlungsartZeile zeile in belegZeilen) {
        if (zeile.anzahlWert == null && zeile.betragCentWert == null) continue;
        liste.add(ZahlungsartErgebnis(
          art: zeile.name,
          anzahl: zeile.anzahlWert ?? 0,
          betragCent: zeile.betragCentWert,
        ));
      }
    }
    return liste.isEmpty ? null : liste;
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

  List<FocusNode> _fokusReihenfolgeSchritt2() {
    final List<FocusNode> ausgabenFokus = <FocusNode>[];
    for (int i = 0; i < _ausgabenLabelFocusNode.length; i++) {
      ausgabenFokus.add(_ausgabenLabelFocusNode[i]);
      if (i < _ausgabenBetragFocusNode.length) {
        ausgabenFokus.add(_ausgabenBetragFocusNode[i]);
      }
    }
    final List<FocusNode> ecBelegFokus = <FocusNode>[];
    for (int i = 0; i < _ecBelegLabelFocusNode.length; i++) {
      ecBelegFokus.add(_ecBelegLabelFocusNode[i]);
      if (i < _ecBelegFocusNode.length) {
        ecBelegFokus.add(_ecBelegFocusNode[i]);
      }
    }
    return <FocusNode>[
      _kinoSollFocusNode,
      _bistroSollFocusNode,
      ...ausgabenFokus,
      ...ecBelegFokus,
      _differenzAnfangsbestandFocusNode,
    ];
  }

  bool _istLetztesFeldSchritt2(FocusNode focusNode) {
    final List<FocusNode> reihenfolge = _fokusReihenfolgeSchritt2();
    return reihenfolge.isNotEmpty && identical(reihenfolge.last, focusNode);
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
    _scrolleZurMitteNachFokus(naechstesFeld);
  }

  Future<void> _scrolleZurMitteNachFokus(FocusNode fn) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || !fn.hasFocus || !context.mounted) return;
    if (MediaQuery.of(context).viewInsets.bottom <= 0) return;
    if (!_scrollController.hasClients) return;
    final RenderObject? ro = fn.context?.findRenderObject();
    if (ro == null || !ro.attached) return;
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(ro);
    if (viewport == null) return;
    final double revealOffset = viewport.getOffsetToReveal(ro, 0.0).offset;
    final double targetOffset = (revealOffset - _scrollController.position.viewportDimension * 0.3)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  FocusNode? _erstesLeeresFeld() {
    final Map<FocusNode, TextEditingController> lookup =
        <FocusNode, TextEditingController>{
      _kinoSollFocusNode: _kinoSollController,
      _bistroSollFocusNode: _bistroSollController,
      _differenzAnfangsbestandFocusNode: _differenzAnfangsbestandController,
      for (int i = 0; i < _ausgabenLabelFocusNode.length; i++)
        _ausgabenLabelFocusNode[i]: _ausgabenLabelController[i],
      for (int i = 0; i < _ausgabenBetragFocusNode.length; i++)
        _ausgabenBetragFocusNode[i]: _ausgabenBetragController[i],
      for (int i = 0; i < _ecBelegLabelFocusNode.length; i++)
        _ecBelegLabelFocusNode[i]: _ecBelegLabelController[i],
      for (int i = 0; i < _ecBelegFocusNode.length; i++)
        _ecBelegFocusNode[i]: _ecBelegController[i],
    };
    for (final FocusNode fn in _fokusReihenfolgeSchritt2()) {
      if (lookup[fn]?.text.isEmpty ?? true) {
        return fn;
      }
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
        FocusScope.of(context).requestFocus(ziel);
      }
    });
  }

  void _aktualisiereScrollPfeil() {
    if (!mounted) return;
    if (!_ecKachelAufgeklappt) {
      if (_ecKachelZeigeScrollPfeil) {
        setState(() => _ecKachelZeigeScrollPfeil = false);
      }
      return;
    }
    final RenderObject? ro = _ecKachelKey.currentContext?.findRenderObject();
    if (ro == null || !ro.attached) return;
    final RenderAbstractViewport? vp = RenderAbstractViewport.maybeOf(ro);
    if (vp == null || !_scrollController.hasClients) return;
    final double scrollFuerUnten = vp.getOffsetToReveal(ro, 1.0).offset;
    final bool zeige = scrollFuerUnten > _scrollController.offset + 1.0;
    if (zeige != _ecKachelZeigeScrollPfeil) {
      setState(() => _ecKachelZeigeScrollPfeil = zeige);
    }
  }

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
      _ecBeleg1Beruehrt = false;
      _ecBelegLabels[0] = '';
      _setzeControllerText(_ecBelegLabelController[0], '');
      _ecBelegLabel1Beruehrt = false;
      if (_scanHatStattgefunden.isNotEmpty) _scanHatStattgefunden[0] = false;
      _bereinigUnbekannteZeilen(0);
      if (_zahlungsartZeilen.isNotEmpty) {
        for (final _ZahlungsartZeile zeile in _zahlungsartZeilen[0]) {
          zeile.reset();
        }
      }
      if (_metadatenNurAnzeige.isNotEmpty) _metadatenNurAnzeige[0] = false;
      if (_metadatenAufgeklappt.isNotEmpty) _metadatenAufgeklappt[0] = false;
      if (_kartenartenNurAnzeige.isNotEmpty) _kartenartenNurAnzeige[0] = false;
      if (_kartenartenGesamtAnzahl.isNotEmpty) _kartenartenGesamtAnzahl[0] = null;
      if (_kartenartenGesamtBetragCent.isNotEmpty) _kartenartenGesamtBetragCent[0] = null;
      if (_kartenartenGesamtAnzahlController.isNotEmpty) _setzeControllerText(_kartenartenGesamtAnzahlController[0], '');
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
  }) {
    // Ohne Label: nur das Eingabefeld zurückgeben (Breite kommt vom Eltern-Widget).
    if (!zeigeLabel) {
      return BetragCentEingabefeld(
        textController: controller,
        focusNode: focusNode,
        textInputAction: _textInputActionFuerSchritt2(focusNode),
        onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt2(focusNode),
        onChanged: onChanged,
        schriftgroesse: 15,
        hinweisText: '0,00 €',
        fehlermeldungText: fehlermeldungText,
        farbeNachWert: farbeNachWert,
        mitKomma: _eingabeMitKomma,
      );
    }

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
            width: 148,
            child: BetragCentEingabefeld(
              textController: controller,
              focusNode: focusNode,
              textInputAction: _textInputActionFuerSchritt2(focusNode),
              onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt2(focusNode),
              onChanged: onChanged,
              schriftgroesse: 15,
              hinweisText: '0,00 €',
              fehlermeldungText: fehlermeldungText,
              farbeNachWert: farbeNachWert,
              mitKomma: _eingabeMitKomma,
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

  Widget _baueMetadatenInfoZeile(String label, String? wert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            child: wert != null
                ? Text(wert, style: const TextStyle(fontSize: 13))
                : Text(
                    'nicht verfügbar',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _baueMetadatenEditZeile(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                filled: focusNode.hasFocus,
                fillColor: const Color(0xFFFFF8E1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                  maxWidth: 28,
                  maxHeight: 28,
                ),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.clear,
                            size: 16, color: clearIconFarbe(focusNode.hasFocus)),
                        onPressed: baueClearAktion(
                          controller: controller,
                          onChanged: onChanged,
                          focusNode: focusNode,
                        ),
                      ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueMetadatenBlock(int belegIndex) {
    final bool aufgeklappt = belegIndex < _metadatenAufgeklappt.length
        ? _metadatenAufgeklappt[belegIndex]
        : false;
    final bool nurAnzeige = belegIndex < _metadatenNurAnzeige.length
        ? _metadatenNurAnzeige[belegIndex]
        : false;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              if (belegIndex < _metadatenAufgeklappt.length) {
                _metadatenAufgeklappt[belegIndex] = !_metadatenAufgeklappt[belegIndex];
              }
            }),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Scan-Metadaten',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                if (aufgeklappt)
                  TextButton(
                    onPressed: () {
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
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      nurAnzeige
                          ? 'Metadaten bearbeiten'
                          : 'Fertig.',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                Icon(
                  aufgeklappt
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 16,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          if (aufgeklappt) ...<Widget>[
            const SizedBox(height: 4),
            if (nurAnzeige) ...<Widget>[
              _baueMetadatenInfoZeile('Datum', _scanDatum),
              _baueMetadatenInfoZeile('Uhrzeit', _scanUhrzeit),
              _baueMetadatenInfoZeile('Beleg-Nr. von', _scanBelegNrVon),
              _baueMetadatenInfoZeile('Beleg-Nr. bis', _scanBelegNrBis),
            ] else ...<Widget>[
              _baueMetadatenEditZeile(
                'Datum',
                _scanDatumController,
                _scanDatumFocusNode,
                (String wert) => _scanMetadatenfeldGeaendert(
                    wert, (String? w) => _scanDatum = w),
              ),
              _baueMetadatenEditZeile(
                'Uhrzeit',
                _scanUhrzeitController,
                _scanUhrzeitFocusNode,
                (String wert) => _scanMetadatenfeldGeaendert(
                    wert, (String? w) => _scanUhrzeit = w),
              ),
              _baueMetadatenEditZeile(
                'Beleg-Nr. von',
                _scanBelegNrVonController,
                _scanBelegNrVonFocusNode,
                (String wert) => _scanMetadatenfeldGeaendert(
                    wert, (String? w) => _scanBelegNrVon = w),
              ),
              _baueMetadatenEditZeile(
                'Beleg-Nr. bis',
                _scanBelegNrBisController,
                _scanBelegNrBisFocusNode,
                (String wert) => _scanMetadatenfeldGeaendert(
                    wert, (String? w) => _scanBelegNrBis = w),
              ),
            ],
          ],
        ],
      ),
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

  Widget _baueKartenartenZeile(int index, int belegIndex) {
    final _ZahlungsartZeile zeile = _zahlungsartZeilen[belegIndex][index];
    final OutlineInputBorder? roteBorder = _istZeileImplausibel(zeile, belegIndex)
        ? OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade300),
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: zeile.istUnbekannt
                ? DropdownButton<String?>(
                    value: zeile.name.isEmpty ? null : zeile.name,
                    hint: const Text(
                      'Kartenart?',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFFF57F17)),
                    ),
                    isExpanded: true,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87),
                    items: _dropdownOptionenFuerUnbekannte(index, belegIndex)
                        .map((String n) => DropdownMenuItem<String?>(
                              value: n,
                              child: Text(n),
                            ))
                        .toList(),
                    onChanged: (String? wert) {
                      setState(() {
                        zeile.name = wert ?? '';
                        _letzteAenderung = DateTime.now();
                      });
                      _speichereEntwurf();
                    },
                  )
                : Text(
                    zeile.name,
                    style: const TextStyle(fontSize: 13),
                  ),
          ),
          SizedBox(
            width: 52,
            child: TextField(
              controller: zeile.anzahlController,
              focusNode: zeile.anzahlFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: '—',
                isDense: true,
                border: const OutlineInputBorder(),
                enabledBorder: roteBorder,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              ),
              onChanged: (String wert) {
                setState(() {
                  zeile.anzahlWert = int.tryParse(wert.trim());
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 104,
            child: TextField(
              controller: zeile.betragController,
              focusNode: zeile.betragFocusNode,
              keyboardType: _eingabeMitKomma
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              inputFormatters: _eingabeMitKomma
                  ? <TextInputFormatter>[]
                  : <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      CentWaehrungsEingabeFormatter(),
                    ],
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: '0,00',
                isDense: true,
                border: const OutlineInputBorder(),
                enabledBorder: roteBorder,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              ),
              onChanged: (String wert) {
                setState(() {
                  zeile.betragCentWert = _parsiereBetragCent(wert);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueKartenartenZeileAnzeige(int index, int belegIndex) {
    final _ZahlungsartZeile zeile = _zahlungsartZeilen[belegIndex][index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: zeile.istUnbekannt && zeile.name.isEmpty
                ? Text(
                    '?',
                    style: TextStyle(
                        fontSize: 13, color: Colors.orange.shade700),
                  )
                : Text(
                    zeile.name,
                    style: const TextStyle(fontSize: 13),
                  ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              zeile.anzahlWert != null ? '${zeile.anzahlWert}' : '—',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 104,
            child: Text(
              zeile.betragCentWert != null
                  ? TagesabschlussFormatierung.formatiereEuro(
                      zeile.betragCentWert!)
                  : '—',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueKartenartenEditButton(int belegIndex) {
    // Im 2+-Beleg-Modus übernimmt der Sub-Kachel-"Manuell bearbeiten"-Button die Steuerung
    if (_ecBelegController.length > 1) return const SizedBox.shrink();
    final bool nurAnzeige = belegIndex < _kartenartenNurAnzeige.length
        ? _kartenartenNurAnzeige[belegIndex]
        : false;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: nurAnzeige
              ? () => setState(() {
                    if (belegIndex < _kartenartenNurAnzeige.length) {
                      _kartenartenNurAnzeige[belegIndex] = false;
                    }
                  })
              : () => setState(() {
                    if (belegIndex < _kartenartenNurAnzeige.length) {
                      _kartenartenNurAnzeige[belegIndex] = true;
                    }
                  }),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 28),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            nurAnzeige ? 'Belegdaten bearbeiten' : 'Fertig.',
            style: const TextStyle(
                fontSize: 11, decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }

  Widget _baueZahlungsartenTabelle(int belegIndex) {
    if (belegIndex >= _zahlungsartZeilen.length) return const SizedBox.shrink();
    final List<_ZahlungsartZeile> zeilen = _zahlungsartZeilen[belegIndex];
    final bool nurAnzeige = belegIndex < _kartenartenNurAnzeige.length
        ? _kartenartenNurAnzeige[belegIndex]
        : false;
    final int? gesAnzahl = belegIndex < _kartenartenGesamtAnzahl.length
        ? _kartenartenGesamtAnzahl[belegIndex]
        : null;
    final int? gesBetrag = belegIndex < _kartenartenGesamtBetragCent.length
        ? _kartenartenGesamtBetragCent[belegIndex]
        : null;
    int tabellenSummeCent = 0;
    int tabellenSummeAnzahl = 0;
    for (final _ZahlungsartZeile zeile in zeilen) {
      if (zeile.betragCentWert != null) tabellenSummeCent += zeile.betragCentWert!;
      if (zeile.anzahlWert != null) tabellenSummeAnzahl += zeile.anzahlWert!;
    }
    final int ecGesamtCent = belegIndex < _ecBelegeCent.length
        ? _ecBelegeCent[belegIndex]
        : 0;
    final bool summePasstNicht =
        tabellenSummeCent > 0 && ecGesamtCent > 0 && tabellenSummeCent != ecGesamtCent;
    final bool anzahlMismatch = gesAnzahl != null && tabellenSummeAnzahl != gesAnzahl;
    final bool betragMismatch = gesBetrag != null && tabellenSummeCent != gesBetrag;
    final bool kartenartenHatFokus = zeilen.any(
      (_ZahlungsartZeile z) =>
          z.anzahlFocusNode.hasFocus || z.betragFocusNode.hasFocus,
    );
    final bool irgendEineZeileInkonsistent = zeilen
        .where((_ZahlungsartZeile z) => !z.nichtImScan)
        .any((_ZahlungsartZeile z) => _istZeileImplausibel(z, belegIndex));

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
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
                  width: 52,
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
                SizedBox(width: 6),
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
          for (int i = 0; i < zeilen.length; i++)
            if (!zeilen[i].nichtImScan)
              nurAnzeige
                  ? _baueKartenartenZeileAnzeige(i, belegIndex)
                  : _baueKartenartenZeile(i, belegIndex),
          if (zeilen.any((_ZahlungsartZeile z) => z.nichtImScan))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (final _ZahlungsartZeile zeile in zeilen)
                    if (zeile.nichtImScan)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            zeile.nichtImScan = false;
                            if (belegIndex < _kartenartenNurAnzeige.length) {
                              _kartenartenNurAnzeige[belegIndex] = false;
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 0),
                          minimumSize: const Size(0, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.add, size: 14),
                        label: Text(
                          zeile.name,
                          style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                ],
              ),
            ),
          const Divider(height: 10),
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Gesamt (laut Beleg)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(
                width: 52,
                child: nurAnzeige
                    ? Text(
                        gesAnzahl != null ? '$gesAnzahl' : '—',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: anzahlMismatch ? Colors.red.shade700 : null,
                        ),
                      )
                    : TextField(
                        controller: belegIndex < _kartenartenGesamtAnzahlController.length
                            ? _kartenartenGesamtAnzahlController[belegIndex]
                            : TextEditingController(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText: '—',
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                        ),
                        onChanged: (String wert) {
                          setState(() {
                            if (belegIndex < _kartenartenGesamtAnzahl.length) {
                              _kartenartenGesamtAnzahl[belegIndex] =
                                  int.tryParse(wert.trim());
                            }
                          });
                          _speichereEntwurf();
                        },
                      ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 104,
                child: nurAnzeige
                    ? Text(
                        gesBetrag != null
                            ? TagesabschlussFormatierung.formatiereEuro(
                                gesBetrag)
                            : '—',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: betragMismatch ? Colors.red.shade700 : null,
                        ),
                      )
                    : TextField(
                        controller: belegIndex < _kartenartenGesamtBetragController.length
                            ? _kartenartenGesamtBetragController[belegIndex]
                            : TextEditingController(),
                        keyboardType: _eingabeMitKomma
                            ? const TextInputType.numberWithOptions(
                                decimal: true)
                            : TextInputType.number,
                        inputFormatters: _eingabeMitKomma
                            ? <TextInputFormatter>[]
                            : <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                CentWaehrungsEingabeFormatter(),
                              ],
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0,00',
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                        ),
                        onChanged: (String wert) {
                          setState(() {
                            if (belegIndex < _kartenartenGesamtBetragCent.length) {
                              _kartenartenGesamtBetragCent[belegIndex] =
                                  wert.trim().isEmpty
                                      ? null
                                      : _parsiereBetragCent(wert);
                              if (_ecBelegController.length > 1 &&
                                  belegIndex < _ecBelegeCent.length) {
                                _ecBelegeCent[belegIndex] =
                                    _kartenartenGesamtBetragCent[belegIndex] ?? 0;
                              }
                            }
                          });
                          _speichereEntwurf();
                        },
                      ),
              ),
            ],
          ),
          if (anzahlMismatch && !kartenartenHatFokus && !irgendEineZeileInkonsistent)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Hinweis: Anzahl der Kartenvorgänge stimmt nicht mit der '
                'erfassten Gesamtanzahl überein.',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
            ),
          if (betragMismatch && !kartenartenHatFokus && !irgendEineZeileInkonsistent)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Hinweis: Summe der Beträge stimmt nicht mit der erfassten '
                'Gesamtsumme überein.',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
            ),
          if (summePasstNicht && !betragMismatch && !kartenartenHatFokus && !irgendEineZeileInkonsistent)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Hinweis: Kartensumme stimmt nicht mit dem eingetragenen '
                'EC-Gesamtbetrag überein.',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
            ),
          _baueKartenartenEditButton(belegIndex),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_laedt) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bool tastaturOffen = MediaQuery.of(context).viewInsets.bottom > 0;
    final int ecGesamtCent = _ecBelegeCent.fold(0, (int a, int b) => a + b);
    final bool hatEcBelege = _scanHatStattgefunden.any((bool b) => b) || ecGesamtCent > 0;
    final int belegeWithData = List.generate(_ecBelegController.length, (int j) => j)
        .where((int j) => _ecBelegeCent[j] > 0 || _ecBelegLabels[j].isNotEmpty)
        .length;
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
            if (tastaturOffen) ...<Widget>[
              ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('funktioniert noch nicht')),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Next'),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: _weiterZuSchritt3,
                style: AppFarben.footerButtonStyle,
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
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
          ),
        ),
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: <Widget>[
                IgnorePointer(
                  ignoring: !_devModusAktiv || !_devToolsOffen,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    opacity: _devModusAktiv && _devToolsOffen ? 1 : 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      height: _devModusAktiv && _devToolsOffen ? _devToolsPanelHoehe : 0,
                      child: _baueDevToolsPanel(),
                    ),
                  ),
                ),
                Text(
                  'Kassenabrechnung ${widget.kinoName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _kopfDatumUhrzeit(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Differenz im Anfangsbestand',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              IntrinsicHeight(
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  SizedBox(
                                    width: 148,
                                    child: _baueEingabeZeile(
                                      label: 'Differenz im Anfangsbestand',
                                      controller:
                                          _differenzAnfangsbestandController,
                                      focusNode:
                                          _differenzAnfangsbestandFocusNode,
                                      zeigeLabel: false,
                                      farbeNachWert:
                                          _differenzAnfangsbestandCent,
                                      onChanged: (String wert) {
                                        setState(() {
                                          _letzteAenderung = DateTime.now();
                                          final int absolutWert =
                                              _parsiereBetragCent(wert);
                                          final bool istNegativ =
                                              _differenzAnfangsbestandCent < 0;
                                          _differenzAnfangsbestandCent =
                                              istNegativ
                                                  ? -absolutWert
                                                  : absolutWert;
                                        });
                                        _speichereEntwurf();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: _vorzeichenToggleDifferenz,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(48, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      '±',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ),
                            ],
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
                          _baueEingabeZeile(
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
                          if (widget.kinoId != 'kino_04')
                            _baueEingabeZeile(
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
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text(
                              'Ausgaben (optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          for (int i = 0;
                              i < _ausgabenBetragController.length;
                              i++)
                            KeyedSubtree(
                              key: ValueKey<int>(_ausgabenIds[i]),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        controller: _ausgabenLabelController[i],
                                        focusNode: _ausgabenLabelFocusNode[i],
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: _ausgabenLabelFocusNode[i].hasFocus
                                              ? Colors.white
                                              : null,
                                        ),
                                        cursorColor: _ausgabenLabelFocusNode[i].hasFocus
                                            ? Colors.white
                                            : null,
                                        textInputAction:
                                            _textInputActionFuerSchritt2(
                                          _ausgabenLabelFocusNode[i],
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Bezeichnung (optional)',
                                          hintStyle: const TextStyle(
                                            fontSize: 15,
                                          ),
                                          border: const OutlineInputBorder(),
                                          isDense: true,
                                          filled: _ausgabenLabelFocusNode[i].hasFocus,
                                          fillColor: _ausgabenLabelFocusNode[i].hasFocus
                                              ? Colors.black87
                                              : null,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                          suffixIconConstraints: const BoxConstraints(
                                            minWidth: 0,
                                            minHeight: 0,
                                            maxWidth: 32,
                                            maxHeight: 32,
                                          ),
                                          suffixIcon: _ausgabenLabelController[i].text.isEmpty
                                              ? null
                                              : IconButton(
                                                  constraints: const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
                                                  icon: Icon(
                                                    Icons.close,
                                                    size: 18,
                                                    color: _ausgabenLabelFocusNode[i].hasFocus
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                  onPressed: () {
                                                    _ausgabenLabelController[i].clear();
                                                    setState(() {
                                                      _ausgabenLabels[i] = '';
                                                    });
                                                    _speichereEntwurf();
                                                    _ausgabenLabelFocusNode[i].requestFocus();
                                                  },
                                                ),
                                        ),
                                        onSubmitted: (_) =>
                                            _beiEingabeAbgeschlossenSchritt2(
                                          _ausgabenLabelFocusNode[i],
                                        ),
                                        onChanged: (String wert) {
                                          setState(() {
                                            _letzteAenderung = DateTime.now();
                                            _ausgabenLabels[i] = wert;
                                          });
                                          _speichereEntwurf();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 120,
                                      child: BetragCentEingabefeld(
                                        textController:
                                            _ausgabenBetragController[i],
                                        focusNode: _ausgabenBetragFocusNode[i],
                                        textInputAction:
                                            _textInputActionFuerSchritt2(
                                          _ausgabenBetragFocusNode[i],
                                        ),
                                        onSubmitted: (_) =>
                                            _beiEingabeAbgeschlossenSchritt2(
                                          _ausgabenBetragFocusNode[i],
                                        ),
                                        onChanged: (String wert) {
                                          setState(() {
                                            _letzteAenderung = DateTime.now();
                                            _ausgabenBetrageCent[i] =
                                                _parsiereBetragCent(wert);
                                          });
                                          _speichereEntwurf();
                                        },
                                        schriftgroesse: 15,
                                        hinweisText: '0,00 €',
                                        mitKomma: _eingabeMitKomma,
                                      ),
                                    ),
                                    if (_ausgabenBetragController.length >
                                        1) ...<Widget>[
                                      const SizedBox(width: 6),
                                      IconButton(
                                        onPressed: () =>
                                            _ausgabeEntfernen(i),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                        ),
                                        tooltip: 'Ausgabe entfernen',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: _ausgabeHinzufuegen,
                              icon: const Icon(Icons.add),
                              label: const Text('+ Ausgabe hinzufügen'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Stack(
                  children: <Widget>[
                Card(
                  key: _ecKachelKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Header
                      InkWell(
                        onTap: () {
                          setState(() =>
                              _ecKachelAufgeklappt = !_ecKachelAufgeklappt);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _aktualisiereScrollPfeil();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                          child: Row(
                            children: <Widget>[
                              const Text(
                                'EC-Belege',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              if (!_ecKachelAufgeklappt &&
                                  !_scanHatStattgefunden.any((bool b) => b) &&
                                  !_scanLaeuft &&
                                  _ecBelegeCent.fold(
                                          0, (int a, int b) => a + b) ==
                                      0)
                                GestureDetector(
                                  onTap: () {
                                    setState(
                                        () => _ecKachelAufgeklappt = true);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted) {
                                        _aktualisiereScrollPfeil();
                                        FocusScope.of(context).requestFocus(
                                          _ecBelegLabelFocusNode.first,
                                        );
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'manuell eingeben',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppFarben.appBarRot,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                      const Text(
                                        ' oder: ',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_scanLaeuft)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Text(
                                    'in Arbeit …',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              if (hatEcBelege)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    '${belegeWithData == 1 ? '1 Beleg' : '$belegeWithData Belege'} / ${TagesabschlussFormatierung.formatiereEuro(ecGesamtCent)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppFarben.appBarRot,
                                    ),
                                  ),
                                ),
                              if (!hatEcBelege)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppFarben.appBarRot,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppFarben.appBarRot,
                                    disabledForegroundColor: Colors.white,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: const Size(36, 36),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: _scanLaeuft
                                      ? null
                                      : () => _starteEcBelegScan(),
                                  child: _scanLaeuft
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.camera_alt_outlined,
                                          size: 20),
                                ),
                              if (hatEcBelege) ...<Widget>[
                                const SizedBox(width: 2),
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    tooltip: 'Kartendaten löschen',
                                    padding: EdgeInsets.zero,
                                    onPressed: _loescheKartenDaten,
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: AppFarben.appBarRot,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 4),
                              Icon(
                                _ecKachelAufgeklappt
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                      if (_ecKachelAufgeklappt) ...<Widget>[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (hatEcBelege)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: OutlinedButton(
                                    onPressed: _scanLaeuft
                                        ? null
                                        : _ecBelegHinzufuegen,
                                    child: const Text(
                                      '+ Weiteren Beleg hinzufügen',
                                    ),
                                  ),
                                ),
                              if (_ecBelegController.length == 1) ...<Widget>[
                                // 1-Beleg-Modus: flaches Layout
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: TextField(
                                          controller: _ecBelegLabelController[0],
                                          focusNode: _ecBelegLabelFocusNode[0],
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: _ecBelegLabelFocusNode[0].hasFocus
                                                ? Colors.white
                                                : null,
                                          ),
                                          cursorColor: _ecBelegLabelFocusNode[0].hasFocus
                                              ? Colors.white
                                              : null,
                                          textInputAction:
                                              _textInputActionFuerSchritt2(_ecBelegLabelFocusNode[0]),
                                          decoration: InputDecoration(
                                            hintText: 'Terminal-ID',
                                            hintStyle: const TextStyle(fontSize: 15),
                                            errorText: _pflichtfeldFehlertext(
                                              feldBeruehrt: _ecBelegLabel1Beruehrt,
                                              controller: _ecBelegLabelController[0],
                                              fehlertext: 'Terminal-ID eingeben',
                                            ),
                                            errorBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                            focusedErrorBorder: const OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red, width: 2),
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                            filled: _ecBelegLabelFocusNode[0].hasFocus,
                                            fillColor: _ecBelegLabelFocusNode[0].hasFocus
                                                ? Colors.black87
                                                : null,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            suffixIconConstraints: const BoxConstraints(
                                              minWidth: 0,
                                              minHeight: 0,
                                              maxWidth: 32,
                                              maxHeight: 32,
                                            ),
                                            suffixIcon: _ecBelegLabelController[0].text.isEmpty
                                                ? null
                                                : IconButton(
                                                    constraints: const BoxConstraints(),
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                      Icons.close,
                                                      size: 18,
                                                      color: _ecBelegLabelFocusNode[0].hasFocus
                                                          ? Colors.white
                                                          : null,
                                                    ),
                                                    onPressed: () {
                                                      _ecBelegLabelController[0].clear();
                                                      setState(() { _ecBelegLabels[0] = ''; });
                                                      _speichereEntwurf();
                                                      _ecBelegLabelFocusNode[0].requestFocus();
                                                    },
                                                  ),
                                          ),
                                          onSubmitted: (_) =>
                                              _beiEingabeAbgeschlossenSchritt2(_ecBelegLabelFocusNode[0]),
                                          onChanged: (String wert) {
                                            setState(() {
                                              _letzteAenderung = DateTime.now();
                                              _ecBelegLabels[0] = wert;
                                              _ecBelegLabel1Beruehrt = true;
                                            });
                                            _speichereEntwurf();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 120,
                                        child: BetragCentEingabefeld(
                                          textController: _ecBelegController[0],
                                          focusNode: _ecBelegFocusNode[0],
                                          textInputAction:
                                              _textInputActionFuerSchritt2(_ecBelegFocusNode[0]),
                                          onSubmitted: (_) =>
                                              _beiEingabeAbgeschlossenSchritt2(_ecBelegFocusNode[0]),
                                          onChanged: (String wert) {
                                            setState(() {
                                              _letzteAenderung = DateTime.now();
                                              _ecBeleg1Beruehrt = true;
                                              _ecBelegeCent[0] = _parsiereBetragCent(wert);
                                            });
                                            _speichereEntwurf();
                                          },
                                          schriftgroesse: 15,
                                          hinweisText: '0,00 €',
                                          fehlermeldungText: _pflichtfeldFehlertext(
                                            feldBeruehrt: _ecBeleg1Beruehrt,
                                            controller: _ecBelegController.first,
                                          ),
                                          mitKomma: _eingabeMitKomma,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_scanHatStattgefunden.isNotEmpty && _scanHatStattgefunden[0])
                                  _baueMetadatenBlock(0),
                                if (_zahlungsartZeilen.isNotEmpty && _zahlungsartZeilen[0].isNotEmpty)
                                  _baueZahlungsartenTabelle(0),
                              ] else ...<Widget>[
                                // 2+-Beleg-Modus: Sub-Kacheln
                                for (int i = _ecBelegController.length - 1; i >= 0; i--)
                                  KeyedSubtree(
                                    key: ValueKey<int>(_ecBelegIds[i]),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Card(
                                        elevation: 0,
                                        color: Colors.grey.shade50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        margin: EdgeInsets.zero,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            // Sub-Kachel-Header
                                            InkWell(
                                              onTap: () => setState(() =>
                                                  _ecUnterkachelAufgeklappt[i] =
                                                      !_ecUnterkachelAufgeklappt[i]),
                                              borderRadius: _ecUnterkachelAufgeklappt[i]
                                                  ? const BorderRadius.vertical(
                                                      top: Radius.circular(8))
                                                  : BorderRadius.circular(8),
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: _scanBelegIndex == i
                                                          ? Text(
                                                              'In Arbeit …',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.grey.shade500,
                                                              ),
                                                            )
                                                          : (_ecUnterkachelEditModus[i]
                                                              ? SizedBox(
                                                                  height: 28,
                                                                  child: TextField(
                                                                    controller: _ecBelegLabelController[i],
                                                                    focusNode: _ecBelegLabelFocusNode[i],
                                                                    style: const TextStyle(
                                                                      fontSize: 13,
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                    decoration: InputDecoration(
                                                                      hintText: 'Terminal-ID',
                                                                      isDense: true,
                                                                      contentPadding: const EdgeInsets.symmetric(
                                                                          horizontal: 6, vertical: 4),
                                                                      border: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                          color: _subKachelTidUnleserlich(i)
                                                                              ? Colors.red.shade700
                                                                              : Colors.grey.shade400,
                                                                        ),
                                                                      ),
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                          color: _subKachelTidUnleserlich(i)
                                                                              ? Colors.red.shade700
                                                                              : Colors.grey.shade400,
                                                                        ),
                                                                      ),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                          color: _subKachelTidUnleserlich(i)
                                                                              ? Colors.red.shade700
                                                                              : Colors.blue,
                                                                          width: 2,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    onChanged: (String wert) {
                                                                      setState(() {
                                                                        _letzteAenderung = DateTime.now();
                                                                        _ecBelegLabels[i] = wert;
                                                                      });
                                                                      _speichereEntwurf();
                                                                    },
                                                                  ),
                                                                )
                                                              : Text(
                                                                  _ecBelegLabels[i].isNotEmpty &&
                                                                          _ecBelegLabels[i].trim().toLowerCase() !=
                                                                              'unleserlich'
                                                                      ? _ecBelegLabels[i]
                                                                      : 'Beleg ${i + 1}',
                                                                  style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: _subKachelTidUnleserlich(i)
                                                                        ? Colors.red.shade700
                                                                        : (_ecBelegLabels[i].isNotEmpty &&
                                                                                _ecBelegLabels[i]
                                                                                        .trim()
                                                                                        .toLowerCase() !=
                                                                                    'unleserlich'
                                                                            ? Colors.black87
                                                                            : Colors.grey.shade500),
                                                                  ),
                                                                  overflow: TextOverflow.ellipsis,
                                                                )),
                                                    ),
                                                    if (_ecBelegeCent[i] > 0)
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 4),
                                                        child: Text(
                                                          TagesabschlussFormatierung
                                                              .formatiereEuro(_ecBelegeCent[i]),
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    // Kamera-Button: gefüllt, Kino-Rot
                                                    SizedBox(
                                                      width: 32,
                                                      height: 32,
                                                      child: IconButton(
                                                        tooltip: 'Beleg scannen',
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                        icon: _scanBelegIndex == i
                                                            ? const SizedBox(
                                                                width: 16,
                                                                height: 16,
                                                                child: CircularProgressIndicator(
                                                                    strokeWidth: 2),
                                                              )
                                                            : Icon(
                                                                Icons.camera_alt,
                                                                size: 18,
                                                                color: (_ecBelegLabels[i].isNotEmpty || _ecBelegeCent[i] > 0)
                                                                    ? Colors.grey.shade400
                                                                    : AppFarben.appBarRot),
                                                        onPressed: _scanLaeuft
                                                            ? null
                                                            : () => _starteEcBelegScan(belegIndex: i),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 32,
                                                      height: 32,
                                                      child: IconButton(
                                                        tooltip: 'Beleg entfernen',
                                                        padding: EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(),
                                                        icon: const Icon(
                                                            Icons.delete_outline,
                                                            size: 18),
                                                        onPressed: _scanLaeuft
                                                            ? null
                                                            : () async {
                                                                final bool? ok =
                                                                    await showDialog<
                                                                        bool>(
                                                                  context:
                                                                      context,
                                                                  builder: (BuildContext
                                                                          ctx) =>
                                                                      AlertDialog(
                                                                    title: const Text(
                                                                        'Beleg löschen?'),
                                                                    content: Text(
                                                                        'Beleg ${i + 1} wirklich löschen?'),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        onPressed: () =>
                                                                            Navigator.of(ctx).pop(false),
                                                                        child: const Text(
                                                                            'Abbrechen'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () =>
                                                                            Navigator.of(ctx).pop(true),
                                                                        child: const Text(
                                                                            'Löschen'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                                if (!mounted) {
                                                                  return;
                                                                }
                                                                if (ok == true) {
                                                                  _ecBelegEntfernen(i);
                                                                }
                                                              },
                                                      ),
                                                    ),
                                                    Icon(
                                                      _ecUnterkachelAufgeklappt[i]
                                                          ? Icons.expand_less
                                                          : Icons.expand_more,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Sub-Kachel-Body
                                            if (_ecUnterkachelAufgeklappt[i]) ...<Widget>[
                                              const Divider(height: 1),
                                              Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.stretch,
                                                  children: <Widget>[
                                                    // Kartendaten: per-Beleg-State
                                                    if (_zahlungsartZeilen.length > i &&
                                                        _zahlungsartZeilen[i].isNotEmpty) ...<Widget>[
                                                      _baueZahlungsartenTabelle(i),
                                                      if (_scanHatStattgefunden.length > i &&
                                                          _scanHatStattgefunden[i])
                                                        _baueMetadatenBlock(i),
                                                    ] else if (_ecBelegeCent[i] > 0 ||
                                                        (_ecBelegLabels[i].isNotEmpty &&
                                                            !_subKachelTidUnleserlich(i)))
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 4),
                                                        child: Text(
                                                          'Betrag gespeichert. Für Umsatz-Aufschlüsselung Beleg erneut scannen.',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey.shade600),
                                                        ),
                                                      )
                                                    else
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 4),
                                                        child: Text(
                                                          'Noch kein Beleg – Kamera verwenden.',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey.shade500),
                                                        ),
                                                      ),
                                                    // TID-Hinweis wenn unleserlich
                                                    if (_subKachelTidUnleserlich(i))
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 4),
                                                        child: Text(
                                                          'Terminal-ID konnte nicht gelesen werden – oben korrigieren.',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.red.shade700),
                                                        ),
                                                      ),
                                                    // Manuell bearbeiten / Fertig
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 4),
                                                        child: _ecUnterkachelEditModus[i]
                                                            ? TextButton(
                                                                onPressed: () => setState(() {
                                                                    _ecUnterkachelEditModus[i] = false;
                                                                    if (i < _kartenartenNurAnzeige.length) {
                                                                      _kartenartenNurAnzeige[i] = true;
                                                                    }
                                                                  }),
                                                                style: TextButton.styleFrom(
                                                                  padding: EdgeInsets.zero,
                                                                  minimumSize: const Size(0, 28),
                                                                  tapTargetSize:
                                                                      MaterialTapTargetSize.shrinkWrap,
                                                                ),
                                                                child: const Text(
                                                                  'Fertig.',
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w700,
                                                                    decoration:
                                                                        TextDecoration.underline,
                                                                  ),
                                                                ),
                                                              )
                                                            : TextButton(
                                                                onPressed: () =>
                                                                    _manuellBearbeitenAktivieren(i),
                                                                style: TextButton.styleFrom(
                                                                  padding: EdgeInsets.zero,
                                                                  minimumSize: const Size(0, 28),
                                                                  tapTargetSize:
                                                                      MaterialTapTargetSize.shrinkWrap,
                                                                ),
                                                                child: const Text(
                                                                  'Belegdaten bearbeiten',
                                                                  style: TextStyle(fontSize: 12),
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                    if (_ecKachelAufgeklappt && _ecKachelZeigeScrollPfeil)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 44,
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
                            padding: const EdgeInsets.only(bottom: 6),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 28,
                              color: Colors.grey,
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
                const SizedBox(height: 8),
              ],
        ),
      ),
    );
  }
}
