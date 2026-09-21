import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_anmerkung_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_differenz_anfangsbestand_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_differenz_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_ist_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_kopf_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_soll_section.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/help_button.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';
import 'package:kino_bar_app/domain/tagesabschluss_finalisieren_usecase.dart';
import 'package:kino_bar_app/domain/usecases/speichere_tagesabschluss_usecase.dart';
import 'package:kino_bar_app/config/feature_flags.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:kino_bar_app/services/dev_modus.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/storage/sende_protokoll.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kino_bar_app/pages/getraenke_auffuellen_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/pages/stueckelung_vorschlag_seite.dart';
import 'package:kino_bar_app/pages/wechselgeld_pruefen_seite.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/utils/schritt_auswahl_bottom_sheet_helper.dart';
import 'package:kino_bar_app/widgets/hinweis_snackbar.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

class TagesabschlussSchritt3Argumente {
  const TagesabschlussSchritt3Argumente({
    required this.kinoId,
    required this.kinoName,
    required this.scheineCent,
    required this.loseMuenzenCent,
    required this.rollenCent,
    required this.umschlaegeCent,
    required this.wechselgeldSollwertCent,
    this.wechselgeldEntnahmeCent,
    this.wechselgeldEntnahmeGrund,
    required this.kinoSollCent,
    required this.bistroSollCent,
    required this.ausgabenCent,
    required this.ecBelegeCent,
    required this.differenzAnfangsbestandCent,
    required this.stueckzahlen,
    required this.loseMuenzenNachArtCent,
    this.umschlaege,
    this.ausgabenBetraegeCent,
    this.ausgabenLabels,
    this.ecBelegeLabels,
    this.terminalId,
    this.belegNrVon,
    this.belegNrBis,
    this.ecUhrzeit,
    this.zahlungsartenAufschluesselung,
    this.ecBelegeFotosBase64,
    this.ecBelegeFotosMediaTypen,
    this.zielSchrittBeimSprung,
  });

  final String kinoId;
  final String kinoName;

  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int wechselgeldSollwertCent;
  final int? wechselgeldEntnahmeCent;
  final String? wechselgeldEntnahmeGrund;

  final int kinoSollCent;
  final int bistroSollCent;
  final int ausgabenCent;
  final List<int> ecBelegeCent;
  final int differenzAnfangsbestandCent;
  final Map<String, int> stueckzahlen;
  final Map<String, int> loseMuenzenNachArtCent;
  final List<UmschlagEintrag>? umschlaege;
  final List<int>? ausgabenBetraegeCent;
  final List<String>? ausgabenLabels;
  final List<String>? ecBelegeLabels;
  final String? terminalId;
  final String? belegNrVon;
  final String? belegNrBis;
  final String? ecUhrzeit;
  final List<ZahlungsartErgebnis>? zahlungsartenAufschluesselung;
  final List<String>? ecBelegeFotosBase64;
  final List<String>? ecBelegeFotosMediaTypen;
  /// Nur beim AppBar-Schritt-Sprung von Schritt 1/2 zu Schritt 4 gesetzt
  /// (Wert 4): sobald diese Seite aufgebaut ist, springt sie automatisch
  /// weiter zu Schritt 4 — ohne eigenes Gate, da "Barumsatz f. Umschlag
  /// stückeln" schon beim regulären Übergang 3→4 ungefragt navigiert.
  final int? zielSchrittBeimSprung;
}

class TagesabschlussSchritt3Seite extends StatefulWidget {
  const TagesabschlussSchritt3Seite({
    super.key,
    required this.argumente,
    @visibleForTesting this.uploadUeberschreibung,
    @visibleForTesting this.lokalerSendeMerkerUeberschreibung,
    @visibleForTesting this.autoSaveUeberschreibung,
  });

  static const String routenName = '/closure-step-3';

  final TagesabschlussSchritt3Argumente argumente;

  /// Nur fuer Tests: ersetzt den echten Netzwerk-Upload
  /// (ApiUploadService.upload) durch eine Fake-Funktion, damit Erfolgs-
  /// und Fehlerfaelle in _doApiUpload() ohne echtes Netzwerk simulierbar
  /// sind (ApiUploadService.upload ruft direkt die statischen
  /// http.post/http.put-Funktionen auf, es gibt sonst keine Stelle zum
  /// Abfangen). Im Normalbetrieb immer null, dann unveraendertes
  /// Verhalten (ruft ApiUploadService.upload).
  @visibleForTesting
  final Future<Map<String, dynamic>?> Function(TagesabschlussFinal)?
      uploadUeberschreibung;

  /// Nur fuer Tests: ersetzt das Speichern des lokalen Sende-Merkers
  /// (siehe _speichereLokalenSendeMerker()), um einen Fehler dort
  /// gezielt zu simulieren (z. B. QuotaExceededError bei vollem
  /// Browser-Speicher, Run 450/451). Im Normalbetrieb immer null.
  @visibleForTesting
  final Future<void> Function()? lokalerSendeMerkerUeberschreibung;

  /// Nur fuer Tests: ersetzt SpeichereTagesabschlussUsecase.ausfuehren
  /// (siehe _autoSaveImHintergrund()) — der echte Usecase schreibt via
  /// LokalerSpeicher in eine Hive-Box auf der Festplatte, was in
  /// Widget-Tests (Flutters simulierte Pump-Zeit) zu nie auflösenden
  /// Schreibvorgaengen fuehren kann. Im Normalbetrieb immer null.
  @visibleForTesting
  final Future<SpeichereTagesabschlussErgebnis> Function(
    TagesabschlussFinal abschluss, {
    bool ueberschreiben,
    bool alsZusaetzlicheAbrechnung,
  })? autoSaveUeberschreibung;

  @override
  State<TagesabschlussSchritt3Seite> createState() =>
      _TagesabschlussSchritt3SeiteState();
}

class _TagesabschlussSchritt3SeiteState
    extends State<TagesabschlussSchritt3Seite> {
  final TagesabschlussFinalisierenUsecase _finalisierenUsecase =
      const TagesabschlussFinalisierenUsecase();
  final SpeichereTagesabschlussUsecase _speichereUsecase =
      const SpeichereTagesabschlussUsecase();
  final SchrittAuswahlBottomSheetHelper _schrittAuswahlHelper =
      const SchrittAuswahlBottomSheetHelper();

  // Erstellungszeitpunkt dieser Abrechnung, exakt einmal beim Aufbau
  // dieses State-Objekts gesetzt (Run 457) — wird als createdAt in jedes
  // per _aktualisiereAbschlussVorschau() neu gebaute _abschlussVorschau
  // übernommen. Vorher zog jeder Aufruf von _aktualisiereAbschlussVorschau()
  // (z. B. bei jeder Kommentaränderung oder beim automatischen
  // Testdaten-Zeitstempel-Update kurz vor dem Senden,
  // _aktualisiereTestdatenZeitstempelVorVersand()) einen frischen
  // DateTime.now()-Wert für createdAt. Der Auto-Save persistiert den
  // Verlaufseintrag aber nur einmal, mit dem createdAt vom allerersten
  // Aufbau — driftete createdAt danach weiter, fand markiereAlsGesendet()
  // (lokaler_speicher.dart) beim Senden per exaktem createdAt-Abgleich
  // keinen Treffer mehr und setzte gesendetAm nie: der Verlaufseintrag
  // blieb trotz erfolgreichem Versand dauerhaft auf "Noch nicht gesendet"
  // stehen (Paco-Testfund 2026-09-18, Dev-Modus mit automatischem
  // Testdaten-Zeitstempel).
  final DateTime _erstellungszeitpunkt = DateTime.now();

  // null solange die async-Initialisierung noch läuft
  TagesabschlussFinal? _abschlussVorschau;

  // Kommentarfeld, seit Run 441 hier statt in Schritt 2 (näher am
  // Senden-Button, direkt bevor die Abrechnung tatsächlich rausgeht).
  String _anmerkung = '';
  final TextEditingController _anmerkungController = TextEditingController();
  final FocusNode _anmerkungFocusNode = FocusNode();

  // true = Auto-Save läuft oder abgeschlossen, false = noch ausstehend
  bool _autoSaveErledigt = false;
  Future<void>? _autoSaveErsterLauf;
  bool _autoSaveLaeuft = false;
  bool _autoSaveFehler = false;
  bool _apiUploadErledigt = false;
  bool _apiUploadLaeuft = false;
  bool _devModusAktiv = false;

  // Server-Antwort des letzten echten settlements-Aufrufs dieser Sitzung
  // (report_id, entered_total_cents, discrepancy_cents, ...) — null,
  // solange in dieser Sitzung noch nicht wirklich gesendet wurde. Nur
  // für den Dev-Tools-Button "Server-Antwort anzeigen", nicht
  // persistiert.
  Map<String, dynamic>? _letzteServerAntwort;
  bool _abrechnungGesendet = false;

  // true = in dieser Sitzung wurde mindestens einmal ein Versand-Versuch
  // gestartet (_doApiUpload()), unabhängig vom Ergebnis. Anders als
  // _abrechnungGesendet/_apiUploadErledigt (beide bleiben bei einem
  // echten Fehlschlag false, ununterscheidbar von "nie versucht")
  // erlaubt dieses Flag, "versucht, aber nicht erfolgreich" von
  // "nie versucht" zu unterscheiden — steuert den Zugang zu Schritt 4
  // trotz nicht bestätigtem Versand. Bewusst nicht persistiert: gilt
  // nur für die aktuelle Sitzung dieser Seite.
  bool _uploadVersucht = false;

  // true = Versand wurde versucht, aber (noch) nicht als erfolgreich
  // bestätigt (echter Fehlschlag oder CORS-Fallback ohne Bestätigung).
  bool get _sendenNichtBestaetigt => _uploadVersucht && !_abrechnungGesendet;

  @override
  void initState() {
    super.initState();
    _initialisierenAsync();
  }

  @override
  void dispose() {
    _anmerkungController.dispose();
    _anmerkungFocusNode.dispose();
    super.dispose();
  }

  /// Signatur dessen, was Flurbocash bei einem Versand tatsächlich
  /// bekommen würde — bewusst NICHT die komplette Schritt-1/2-Eingabe
  /// (die enthält viele Felder, die FC nie sieht, z. B. Differenz im
  /// Anfangsbestand, Kino-/Bistro-SOLL, Stückzahlen). Direkt aus
  /// ApiUploadService.settlementsBody() abgeleitet (abzüglich `sent_at`,
  /// das ist immer "jetzt" und darf einen Vergleich nie verfälschen),
  /// damit Signatur und tatsächlich gesendete Daten strukturell nicht
  /// auseinanderlaufen können. Dient dem Vergleich mit der zuletzt
  /// gespeicherten Sende-Bestätigung, um den "gesendet"-Haken bei einer
  /// fachlich relevanten nachträglichen Änderung automatisch wieder
  /// auszublenden.
  String _sendeSignatur() {
    try {
      final Map<String, dynamic> body =
          ApiUploadService.settlementsBody(_abschlussVorschau!);
      final Map<String, dynamic> settlement = (body['settlements']
          as List<dynamic>).first as Map<String, dynamic>;
      settlement.remove('sent_at');
      return jsonEncode(body);
    } catch (_) {
      // _terminalsListe() innerhalb von settlementsBody() wirft bei
      // unvollständigen/inkonsistenten EC-Daten bewusst eine Exception
      // (z. B. EC-Umsatz ohne Kartenart-Aufschlüsselung) — das ist beim
      // echten Versand erwünscht (siehe _doApiUpload()-Catch-Block),
      // darf hier aber nicht die Seite zum Absturz bringen. Sentinel,
      // der nie zu einer gültig gespeicherten Signatur passt — der
      // Haken bleibt in diesem Fall einfach aus.
      return '__unvollstaendig__';
    }
  }

  /// Baut das Dev-Modus-Kennzeichen "testdaten" inkl. aktuellem Datum/
  /// Uhrzeit, z. B. "testdaten 26.9. Mo 12:34" (seit Run 441 hier statt
  /// in Schritt 2, mit dem Kommentarfeld mitgewandert).
  static String _testdatenKennzeichenMitZeitstempel() {
    return 'testdaten '
        '${DateFormat("d.M. EEE HH:mm", 'de_DE').format(DateTime.now())}';
  }

  /// Erkennt den von [_testdatenKennzeichenMitZeitstempel] erzeugten
  /// Zeitstempel-Anfang, auch wenn danach noch eigener Text angehängt
  /// wurde — damit dieser beim Versand aktualisiert werden kann, ohne
  /// angehängten Text zu verwerfen.
  static final RegExp _testdatenZeitstempelMuster = RegExp(
    r'^testdaten \d{1,2}\.\d{1,2}\. [A-Za-zÄÖÜäöüß]+\.? \d{2}:\d{2}',
  );

  /// Ersetzt den Zeitstempel im Dev-Modus-Kennzeichen durch den
  /// tatsächlichen Sendezeitpunkt. Der Zeitstempel wird beim Öffnen der
  /// Seite mit der aktuellen Uhrzeit vorbefüllt (siehe
  /// _initialisierenAsync()), spiegelt dort also nur den Zeitpunkt des
  /// Seitenaufrufs wider, nicht den tatsächlichen Versand — wird hier
  /// direkt vor dem Versand nachgezogen. Speichert den aktualisierten
  /// Kommentar zusätzlich als Entwurf (Run 455, Paco-Testfund): sonst
  /// lädt _ladeAnmerkungEntwurf() bei Rückkehr auf diese Seite (z. B.
  /// über Schritt 2 und zurück, die Seite wird dabei neu aufgebaut) den
  /// alten, hier nie persistierten Zeitstempel wieder ein.
  Future<void> _aktualisiereTestdatenZeitstempelVorVersand() async {
    if (!_devModusAktiv) return;
    if (!_testdatenZeitstempelMuster.hasMatch(_anmerkung)) return;
    final String rest =
        _anmerkung.replaceFirst(_testdatenZeitstempelMuster, '');
    _anmerkung = '${_testdatenKennzeichenMitZeitstempel()}$rest';
    _anmerkungController.text = _anmerkung;
    _aktualisiereAbschlussVorschau();
    await _speichereAnmerkungEntwurf();
  }

  /// Lädt einen zuvor auf dieser Seite eingegebenen, noch nicht
  /// gesendeten Kommentar (siehe _speichereAnmerkungEntwurf()) — nur
  /// gültig für den heutigen logischen Abrechnungstag, sonst wie ein
  /// alter Schritt-2/3-Entwurf verworfen.
  Future<void> _ladeAnmerkungEntwurf() async {
    final Map<String, dynamic>? daten =
        await LokalerSpeicher.ladeSchritt3Entwurf(widget.argumente.kinoId);
    if (daten == null) return;
    final String? gespeichertesDatum = daten['isoDatum'] as String?;
    if (gespeichertesDatum != DatumsHelper.logischesIsoDatum()) return;
    _anmerkung = (daten['anmerkung'] as String?) ?? '';
    if (_anmerkung.isNotEmpty) {
      _anmerkungController.text = _anmerkung;
    }
  }

  Future<void> _speichereAnmerkungEntwurf() async {
    await LokalerSpeicher.speichereSchritt3Entwurf(
      widget.argumente.kinoId,
      <String, dynamic>{
        'isoDatum': DatumsHelper.logischesIsoDatum(),
        if (_anmerkung.trim().isNotEmpty) 'anmerkung': _anmerkung.trim(),
      },
    );
  }

  /// Baut _abschlussVorschau aus widget.argumente + dem aktuellen
  /// Kommentar neu — wird sowohl beim initialen Seitenaufbau als auch
  /// bei jeder Änderung des Kommentarfelds aufgerufen, damit Versand
  /// (_doApiUpload()) und der "Gesendet"-Haken-Abgleich (_sendeSignatur())
  /// immer den zuletzt eingegebenen Kommentar sehen.
  void _aktualisiereAbschlussVorschau() {
    final TagesabschlussFinal abschluss = _finalisierenUsecase.finalisieren(
      eingabe: TagesabschlussFinalisierenEingabe(
        kinoId: widget.argumente.kinoId,
        kinoName: widget.argumente.kinoName,
        scheineCent: widget.argumente.scheineCent,
        loseMuenzenCent: widget.argumente.loseMuenzenCent,
        rollenCent: widget.argumente.rollenCent,
        umschlaegeCent: widget.argumente.umschlaegeCent,
        wechselgeldSollwertCent: widget.argumente.wechselgeldSollwertCent,
        wechselgeldEntnahmeCent: widget.argumente.wechselgeldEntnahmeCent,
        wechselgeldEntnahmeGrund: widget.argumente.wechselgeldEntnahmeGrund,
        kinoSollCent: widget.argumente.kinoSollCent,
        bistroSollCent: widget.argumente.bistroSollCent,
        ausgabenCent: widget.argumente.ausgabenCent,
        ecBelegeCent: widget.argumente.ecBelegeCent,
        differenzAnfangsbestandCent:
            widget.argumente.differenzAnfangsbestandCent,
        stueckzahlen: widget.argumente.stueckzahlen,
        loseMuenzenNachArtCent: widget.argumente.loseMuenzenNachArtCent,
        umschlaege: widget.argumente.umschlaege,
        ausgabenBetraegeCent: widget.argumente.ausgabenBetraegeCent,
        ausgabenLabels: widget.argumente.ausgabenLabels,
        ecBelegeLabels: widget.argumente.ecBelegeLabels,
        terminalId: widget.argumente.terminalId,
        belegNrVon: widget.argumente.belegNrVon,
        belegNrBis: widget.argumente.belegNrBis,
        ecUhrzeit: widget.argumente.ecUhrzeit,
        zahlungsartenAufschluesselung:
            widget.argumente.zahlungsartenAufschluesselung,
        anmerkung: _anmerkung.trim().isEmpty ? null : _anmerkung.trim(),
        ecBelegeFotosBase64: widget.argumente.ecBelegeFotosBase64,
        ecBelegeFotosMediaTypen: widget.argumente.ecBelegeFotosMediaTypen,
      ),
      jetzt: _erstellungszeitpunkt,
    );
    if (!mounted) return;
    setState(() => _abschlussVorschau = abschluss);
  }

  void _beiAnmerkungGeaendert(String wert) {
    _anmerkung = wert;
    _aktualisiereAbschlussVorschau();
    _speichereAnmerkungEntwurf();
  }

  Future<void> _initialisierenAsync() async {
    final bool devModusAktiv = await DevModus.istAktiv();
    if (!mounted) return;
    setState(() => _devModusAktiv = devModusAktiv);
    await _ladeAnmerkungEntwurf();
    if (!mounted) return;
    if (devModusAktiv && _anmerkung.trim().isEmpty) {
      _anmerkung = _testdatenKennzeichenMitZeitstempel();
      _anmerkungController.text = _anmerkung;
    }
    _aktualisiereAbschlussVorschau();
    if (widget.argumente.zielSchrittBeimSprung == 4) {
      _navigiereZuSchritt4();
    }
    _autoSaveErsterLauf = _autoSaveImHintergrund();
    LokalerSpeicher.ladeSendeBestaetigung(widget.argumente.kinoId).then(
      (String? gespeicherteSignatur) {
        final String aktuelleSignatur = _sendeSignatur();
        SendeProtokoll.eintragen(
          'Schritt 3 geöffnet (createdAt '
          '${_erstellungszeitpunkt.toIso8601String()}): gespeicherte '
          'Signatur ${SendeProtokoll.beschreibeSignatur(gespeicherteSignatur)}'
          ', aktuelle ${SendeProtokoll.beschreibeSignatur(aktuelleSignatur)}'
          ' -> ${gespeicherteSignatur == null ? 'noch nie gesendet' : gespeicherteSignatur == aktuelleSignatur ? 'passt (Haken)' : 'passt NICHT (kein Haken)'}',
        );
        if (mounted &&
            gespeicherteSignatur != null &&
            gespeicherteSignatur == aktuelleSignatur) {
          // _apiUploadErledigt hier mitsetzen (nicht nur
          // _abrechnungGesendet): sonst würde ein Klick auf "Abrechnung
          // an Büro senden" nach einem Neuaufbau dieser Seite (z. B.
          // erneuter Durchlauf durch Schritt 1-3 für denselben Tag mit
          // unveränderten Daten) in _zeigeAbschlussDialog() erneut
          // _doApiUpload() auslösen und die Abrechnung ein zweites Mal
          // an Flurbocash senden, obwohl die Signatur bereits als
          // identisch erkannt wurde (Run 427).
          setState(() {
            _abrechnungGesendet = true;
            _apiUploadErledigt = true;
          });
        }
        if (gespeicherteSignatur != null &&
            gespeicherteSignatur == aktuelleSignatur) {
          _markiereVerlaufNachWiedereintritt(aktuelleSignatur);
        }
      },
    );
    LokalerSpeicher.ladeVersandNichtBestaetigtDatum(
      widget.argumente.kinoId,
    ).then((String? datum) {
      if (mounted && datum == DatumsHelper.logischesIsoDatum()) {
        // Stellt den Warn-Zustand nach einem Neuaufbau dieser Seite
        // (z. B. "Übertrag auf Umschlag" erneut geöffnet) wieder her —
        // _uploadVersucht ist sonst reiner Session-State und wäre nach
        // einer neuen Seiteninstanz wieder false, sodass der Haken hier
        // fälschlich wieder grau statt rot wirkte, obwohl das Startmenü
        // (liest denselben persistierten Status) bereits korrekt Rot
        // zeigte (Paco-Testfund Run 448/449).
        setState(() => _uploadVersucht = true);
      }
    });
  }

  /// Run 465: Der Auto-Save beim (erneuten) Öffnen dieser Seite legt einen
  /// neuen bzw. ersetzten Verlaufseintrag ohne gesendetAm an, auch wenn
  /// dieselben Daten heute schon gesendet wurden (Signatur passt) — der
  /// Verlauf zeigte dann fälschlich "Noch nicht gesendet". Hier wird nach
  /// dem Auto-Save die Markierung aus der Sende-Bestätigung nachgezogen.
  /// Bewusst nicht mounted-gated (reine lokale Speicherung).
  Future<void> _markiereVerlaufNachWiedereintritt(String signatur) async {
    try {
      await _autoSaveErsterLauf;
      if (!_autoSaveErledigt || _abschlussVorschau == null) return;
      await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
        kinoId: widget.argumente.kinoId,
        createdAt: _abschlussVorschau!.createdAt,
        aktuelleSignatur: signatur,
        heutigesIsoDatum: DatumsHelper.logischesIsoDatum(),
      );
    } catch (e) {
      debugPrint('Verlauf nachmarkieren fehlgeschlagen: $e');
      await SendeProtokoll.eintragen('Nachmarkieren FEHLGESCHLAGEN: $e');
    }
  }

  /// Speichert den Abschluss beim Öffnen der Seite automatisch.
  /// Duplikat → stillschweigend überschreiben (kein Dialog) — außer für
  /// Kinos mit mehr als einer Abrechnung/Tag (z.B. Bar Tabak): dort wird
  /// vorher nachgefragt, ob ersetzt oder als weitere Abrechnung des
  /// selben Tages gespeichert werden soll.
  Future<void> _autoSaveImHintergrund() async {
    if (_autoSaveLaeuft || _autoSaveErledigt) {
      return;
    }
    setState(() {
      _autoSaveLaeuft = true;
      _autoSaveFehler = false;
    });

    final Future<SpeichereTagesabschlussErgebnis> Function(
      TagesabschlussFinal, {
      bool ueberschreiben,
      bool alsZusaetzlicheAbrechnung,
    }) speichern = widget.autoSaveUeberschreibung ?? _speichereUsecase.ausfuehren;

    try {
      final SpeichereTagesabschlussErgebnis ergebnis =
          await speichern(_abschlussVorschau!);
      if (!mounted) {
        return;
      }

      if (ergebnis.bereitsVorhanden) {
        bool alsZusaetzlicheAbrechnung = false;
        if (ergebnis.weitereAbrechnungMoeglich) {
          alsZusaetzlicheAbrechnung = await _frageZusaetzlicheAbrechnungAb();
          if (!mounted) {
            return;
          }
        }
        await speichern(
          _abschlussVorschau!,
          ueberschreiben: !alsZusaetzlicheAbrechnung,
          alsZusaetzlicheAbrechnung: alsZusaetzlicheAbrechnung,
        );
        if (!mounted) {
          return;
        }
      }

      setState(() {
        _autoSaveErledigt = true;
        _autoSaveLaeuft = false;
      });
    } catch (e) {
      debugPrint('AutoSave fehlgeschlagen: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _autoSaveLaeuft = false;
        _autoSaveFehler = true;
      });
    }
  }

  /// Nur relevant fuer Kinos mit mehr als einer Abrechnung/Tag: fragt ab,
  /// ob der bereits gespeicherte Abschluss ersetzt werden soll (selbe
  /// Abrechnung, z.B. erneut geoeffnet) oder ob dies eine zusaetzliche,
  /// zweite Abrechnung desselben Tages ist.
  Future<bool> _frageZusaetzlicheAbrechnungAb() async {
    final bool? zusaetzlich = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Bereits eine Abrechnung heute vorhanden'),
        content: const Text(
          'Für dieses Kino ist heute schon ein Tagesabschluss gespeichert. '
          'Ist das derselbe Abschluss (ersetzen) oder eine zusätzliche, '
          'zweite Abrechnung des Tages?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Ersetzen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Zusätzliche Abrechnung'),
          ),
        ],
      ),
    );
    return zusaetzlich ?? false;
  }

  /// Persistiert den lokalen Sende-Merker nach einem erfolgreichen
  /// Upload (siehe _doApiUpload()). Eigener try/catch dort (Run 450):
  /// ein Fehler hier (z. B. QuotaExceededError bei vollem Browser-
  /// Speicher, Paco-Testfund 2026-09-16) darf einen erfolgreich
  /// übertragenen Versand nicht mehr fälschlich als "nicht bestätigt"
  /// melden — die MA sah sonst ein Fehler-Popup und schickte die
  /// Abrechnung ein zweites Mal, obwohl sie schon angekommen war.
  Future<void> _speichereLokalenSendeMerker() async {
    final String signatur = _sendeSignatur();
    final DateTime sendezeitpunkt = DateTime.now();
    await LokalerSpeicher.speichereSendeBestaetigung(
      widget.argumente.kinoId,
      signatur,
      isoDatum: DatumsHelper.logischesIsoDatum(),
      zeitpunkt: sendezeitpunkt,
    );
    await SendeProtokoll.eintragen(
      'Sende-Bestätigung gespeichert, Signatur '
      '${SendeProtokoll.beschreibeSignatur(signatur)}',
    );
    await LokalerSpeicher.markiereAlsGesendet(
      _abschlussVorschau!.kinoId,
      _abschlussVorschau!.createdAt,
      sendezeitpunkt,
    );
    // Etwaigen Warn-Status aus einem früheren, nicht bestätigten Versuch
    // an diesem Tag löschen — dieser Versuch war jetzt bestätigt
    // erfolgreich (Run 448).
    await LokalerSpeicher.loescheVersandNichtBestaetigt(
      widget.argumente.kinoId,
    );
  }

  Future<void> _doApiUpload() async {
    if (mounted) {
      setState(() {
        _apiUploadLaeuft = true;
        _uploadVersucht = true;
      });
    }
    try {
      _letzteServerAntwort = await (widget.uploadUeberschreibung ??
          ApiUploadService.upload)(_abschlussVorschau!);
      _apiUploadErledigt = true;
      await SendeProtokoll.eintragen('Versand erfolgreich (Schritt 3)');
      // Bewusst nicht mounted-gated: diese Aufrufe persistieren den
      // Sende-Status lokal und müssen auch dann laufen, wenn die Seite
      // (z. B. via "Zurück zur Startseite") schon verlassen wurde, bevor
      // der Upload zurückkam — sonst bleibt gesendetAm dauerhaft null,
      // obwohl der Upload erfolgreich war (Run 396).
      try {
        await (widget.lokalerSendeMerkerUeberschreibung ??
            _speichereLokalenSendeMerker)();
      } catch (lokalerFehler) {
        debugPrint('Lokaler Sende-Merker fehlgeschlagen: $lokalerFehler');
        await SendeProtokoll.eintragen(
          'Lokaler Sende-Merker FEHLGESCHLAGEN: $lokalerFehler',
        );
      }
      if (mounted) {
        setState(() => _abrechnungGesendet = true);
        // Popup mit Pflicht-Bestätigung statt SnackBar (Run 437,
        // TODO.md "Sendebestätigung ... als Popup statt Snackbar") —
        // kann nicht übersehen/weggewischt werden wie eine SnackBar.
        await zeigeInfoDialog(
          context,
          titel: 'Abrechnung gesendet',
          inhalt: const Text(
            'Die Abrechnung wurde erfolgreich an die Zentrale '
            '(Flurbocash) übertragen.',
          ),
        );
      }
    } catch (e) {
      await SendeProtokoll.eintragen(
        'Versand NICHT bestätigt (Schritt 3): '
        '${SendeProtokoll.fehlerText(e)}',
      );
      // Run 448: Weder der CORS-artige Fehler (ApiUploadService.
      // isCorsArtFehler) noch ein echter Netzwerkfehler (z. B. Flugmodus)
      // dürfen hier noch als "wahrscheinlich doch gesendet" behandelt
      // werden — Browser werfen für beide Fälle dieselbe generische
      // Fehlermeldung ("Failed to fetch"/"Load failed"), von hier aus
      // nicht zuverlässig unterscheidbar (Browser-Sicherheitsgrenze,
      // kein client-seitig lösbares Problem). Vorher wurde dieser Fall
      // fälschlich als erledigt markiert (_apiUploadErledigt = true,
      // markiereAlsGesendet()) — dadurch blieb ein im Flugmodus nie
      // gesendeter Tagesabschluss dauerhaft unversendet, während App und
      // Verlauf ihn als gesendet auswiesen (Paco-Testfund 2026-09-16,
      // siehe auch Memory "Sendefehler als gesendet verbucht"). Beide
      // Fälle jetzt einheitlich als nicht bestätigt behandelt: kein
      // _apiUploadErledigt, kein markiereAlsGesendet(), stattdessen
      // markiereVersandNichtBestaetigt() für den roten Warn-Haken.
      await LokalerSpeicher.markiereVersandNichtBestaetigt(
        widget.argumente.kinoId,
        isoDatum: DatumsHelper.logischesIsoDatum(),
      );
      if (mounted) {
        final bool unklar = ApiUploadService.isCorsArtFehler(e);
        final String meldung;
        if (unklar) {
          // Einfache Sprache für MA (Paco-Testfeedback: bisheriger Text
          // war zu kryptisch, sprach von "Antwort des Servers" und
          // "nicht sicher unterscheidbar").
          meldung =
              'Die Abrechnung konnte nicht sicher an die Zentrale '
              '(Flurbocash) übertragen werden — vermutlich gab es gerade '
              'keine Internetverbindung. Deine Eingaben sind gespeichert '
              'und gehen nicht verloren. Bitte später noch einmal auf '
              '"Abrechnung an Büro senden" tippen.';
        } else {
          final String fehler = e.toString();
          final String anzeige =
              fehler.length > 120 ? '${fehler.substring(0, 120)}…' : fehler;
          meldung =
              'Die Abrechnung konnte nicht an die Zentrale (Flurbocash) '
              'übertragen werden. Deine Eingaben sind gespeichert und '
              'gehen nicht verloren. Bitte später noch einmal auf '
              '"Abrechnung an Büro senden" tippen.\n\n'
              'Fehlermeldung (fürs Büro): $anzeige';
        }
        // Popup statt SnackBar (analog Run 437 bei Erfolg) — Paco-Wunsch,
        // damit ein Fehlschlag wirklich wahrgenommen wird statt als
        // SnackBar übersehen zu werden.
        await zeigeInfoDialog(
          context,
          titel: 'Versand nicht bestätigt',
          inhalt: Text(meldung),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _apiUploadLaeuft = false);
      }
    }
  }

  /// Zeigt Soll/Ist/Differenz nochmal zusammengefasst an und fragt vor
  /// dem tatsächlichen Versand (_doApiUpload()) explizit nach, da dieser
  /// nicht rückgängig zu machen ist. Gibt true zurück, wenn gesendet
  /// werden soll.
  Future<bool> _zeigeVersandBestaetigungsDialog() async {
    final TagesabschlussFinal vorschau = _abschlussVorschau!;
    final int differenzCent = vorschau.differenzGesamtCent;
    final Color differenzFarbe =
        differenzCent >= 0 ? Colors.green.shade700 : Colors.red.shade700;
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Abrechnung senden?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoZeile(
              label: 'Gesamt SOLL',
              wert: TagesabschlussFormatierung.formatiereEuro(
                vorschau.gesamtSollCent,
              ),
            ),
            InfoZeile(
              label: 'Gesamt IST',
              wert: TagesabschlussFormatierung.formatiereEuro(
                vorschau.gesamtIstCent,
              ),
            ),
            InfoZeile(
              label: 'Differenz',
              wert: TagesabschlussFormatierung.formatiereEuroMitVorzeichen(
                differenzCent,
              ),
              fett: true,
              farbe: differenzFarbe,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Senden'),
          ),
        ],
      ),
    );
    return bestaetigt == true;
  }

  Future<void> _zeigeAbschlussDialog() async {
    // Vor jeder Prüfung/Änderung erfasst: true nur, wenn schon VOR
    // diesem Klick gesendet war (echter Versand in einer früheren
    // Sitzung, oder Signatur-Treffer beim Seitenaufbau, Run 427) —
    // steuert unten den Hinweis im Dialog. Run 430 zeigte das noch als
    // SnackBar; Testfeedback Paco (2026-09-06): gehört in den Dialog
    // selbst, nicht in einen separaten SnackBar.
    final bool bereitsGesendetVorKlick = _apiUploadErledigt;

    // Falls Auto-Save noch läuft, kurz warten und erneut prüfen.
    if (_autoSaveLaeuft) {
      return;
    }

    if (!_autoSaveErledigt) {
      // Auto-Save ist fehlgeschlagen – erneut versuchen, dann Dialog.
      await _autoSaveImHintergrund();
      if (!mounted) {
        return;
      }
      if (!_autoSaveErledigt) {
        zeigeHinweisSnackBar(
          context,
          'Speichern fehlgeschlagen. Bitte erneut versuchen.',
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    if (!_apiUploadErledigt) {
      if (!await _zeigeVersandBestaetigungsDialog()) {
        return;
      }
      if (!mounted) return;
      await _aktualisiereTestdatenZeitstempelVorVersand();
      if (!mounted) return;
      final bool apiAktiv = await FeatureFlags.apiUploadAktiv();
      if (!mounted) return;
      if (apiAktiv) {
        // Bewusst awaited (seit Run 436 — vorher .ignore()): der
        // "Was möchtest du als nächstes tun?"-Dialog unten bot sofort
        // "Zurück zur Startseite" an, noch bevor der Upload lokal als
        // gesendet vermerkt war. Landete man dabei auf dem Startmenü,
        // während im Hintergrund noch auf die Serverantwort gewartet
        // wurde, konnte ein automatischer Update-Reload (siehe
        // update_lifecycle_watcher.dart) oder ein Schließen/Verlassen
        // der Seite genau diesen Moment abschneiden: Der Request war
        // beim Server (Flurbocash) bereits angekommen und verarbeitet,
        // aber markiereAlsGesendet()/speichereSendeBestaetigung()
        // liefen nie — der Verlauf zeigte die Abrechnung dauerhaft als
        // "noch nicht gesendet", obwohl sie bei Flurbocash bereits lag.
        // Das verleitete dazu, dieselbe Abrechnung ein zweites Mal zu
        // senden (Doppel-Einträge bei Flurbocash). Die kurze Wartezeit
        // hier (Ladebalken via zeigeLadebalken: _apiUploadLaeuft ist
        // bereits vorhanden) nimmt das in Kauf, um einen zuverlässigen
        // Status zu garantieren.
        await _doApiUpload();
        if (!mounted) return;
        if (!_apiUploadErledigt) {
          // Nicht bestätigt (echter Fehlschlag ODER Ambiguität, siehe
          // _doApiUpload() — seit Run 448 beide gleich behandelt): das
          // Popup kam bereits von dort. Den "Was möchtest du als
          // nächstes tun?"-Dialog hier NICHT zeigen — der würde "Zurück
          // zur Startseite" anbieten, obwohl nichts bestätigt gesendet
          // wurde. Nutzer bleibt auf Schritt 3 und kann erneut senden.
          return;
        }
      } else {
        // Kein Online-Versand für dieses Kino aktiv — "gesendet" meint
        // hier nur die bereits erfolgte lokale Speicherung.
        setState(() => _abrechnungGesendet = true);
        await LokalerSpeicher.speichereSendeBestaetigung(
          widget.argumente.kinoId,
          _sendeSignatur(),
          isoDatum: DatumsHelper.logischesIsoDatum(),
          zeitpunkt: DateTime.now(),
        );
        if (!mounted) return;
      }
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final Kino? kino = KinoRepository.nachId(widget.argumente.kinoId);
        return AlertDialog(
          title: Text(
            bereitsGesendetVorKlick
                ? 'Du hast die Abrechnung bereits gesendet.'
                : 'Was möchtest du als nächstes tun?',
          ),
          content: bereitsGesendetVorKlick
              ? const Text('Was möchtest du als nächstes tun?')
              : null,
          actions: <Widget>[
            if (kino?.hatWechselgeld == true)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamed(
                    WechselgeldPruefenSeite.routenName,
                    arguments: WechselgeldPruefenArgumente(
                      kinoId: widget.argumente.kinoId,
                      ausTagesabrechnung: true,
                    ),
                  );
                },
                child: const Text('Wechselgeldkasse prüfen'),
              ),
            if (kino?.hatGetraenke == true)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamed(
                    GetraenkeAuffuellenSeite.routenName,
                    arguments: widget.argumente.kinoId,
                  );
                },
                child: const Text('Getränke auffüllen'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _navigiereZuSchritt4();
              },
              child: const Text('Barumsatz f. Umschlag stückeln'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  StartmenueSeite.routenName,
                  (Route<dynamic> _) => false,
                  arguments: widget.argumente.kinoId,
                );
              },
              child: const Text('Zurück zur Startseite'),
            ),
          ],
        );
      },
    );
  }

  /// Ersetzt receipt_photo-Werte im settlements-Body durch einen kurzen
  /// Platzhalter — nur für die Debug-JSON-Anzeige, siehe
  /// _zeigeFlurbocashJson().
  Map<String, dynamic> _fuerAnzeigeGekuerzt(Map<String, dynamic> call2) {
    final List<dynamic> settlements =
        (call2['settlements'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic settlement) {
      final Map<String, dynamic> s =
          Map<String, dynamic>.from(settlement as Map<String, dynamic>);
      s['terminals'] =
          (s['terminals'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic terminal) {
        final Map<String, dynamic> t =
            Map<String, dynamic>.from(terminal as Map<String, dynamic>);
        final Object? foto = t['receipt_photo'];
        if (foto is String) {
          t['receipt_photo'] = '<base64, ${foto.length} Zeichen>';
        }
        return t;
      }).toList();
      return s;
    }).toList();
    return <String, dynamic>{...call2, 'settlements': settlements};
  }

  Future<void> _zeigeFlurbocashJson() async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String? locationIdStr = speicher.getString(
      ApiUploadService.locationIdPrefKey(widget.argumente.kinoId),
    );
    final int locationId =
        (locationIdStr != null && locationIdStr.isNotEmpty)
            ? (int.tryParse(locationIdStr) ?? 0)
            : 0;

    if (!mounted) {
      return;
    }

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String call1Json;
    final String call2Json;
    try {
      final Map<String, dynamic> call1 =
          ApiUploadService.ensureBody(_abschlussVorschau!, locationId);
      final Map<String, dynamic> call2 =
          ApiUploadService.settlementsBody(_abschlussVorschau!);
      call1Json = encoder.convert(call1);
      // Beleg-Fotos NUR für diese Debug-Anzeige gekürzt — der reale
      // Request (settlementsBody() beim tatsächlichen Senden) schickt
      // weiterhin das volle Foto. Ein rohes, hunderte KB bis mehrere MB
      // langes base64-Foto ohne einen einzigen Umbruch als SelectableText
      // darzustellen, hat die App beim Testen zuverlässig zum Absturz
      // gebracht (Layout eines pathologisch langen einzelnen "Worts").
      call2Json = encoder.convert(_fuerAnzeigeGekuerzt(call2));
    } catch (e) {
      if (!mounted) return;
      zeigeHinweisSnackBar(
        context,
        'JSON-Vorschau fehlgeschlagen: $e',
        duration: const Duration(seconds: 8),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Flurbocash JSON'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Call 1 — ensure:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  call1Json,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Call 2 — settlements:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  call2Json,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  /// Zeigt die zuletzt vom echten settlements-Aufruf empfangene
  /// Server-Antwort (report_id, entered_total_cents, discrepancy_cents,
  /// ...) — z. B. um zu prüfen, ob Flurbocash bei mehreren
  /// terminals[]-Einträgen gleicher TID tatsächlich beide Beträge
  /// verbucht hat, ohne dafür extra die Browser-DevTools zu brauchen.
  void _zeigeServerAntwort() {
    final Map<String, dynamic>? antwort = _letzteServerAntwort;
    if (antwort == null) return;
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String antwortJson = encoder.convert(antwort);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Flurbocash Server-Antwort'),
          content: SingleChildScrollView(
            child: SelectableText(
              antwortJson,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  void _navigiereZuSchritt4() {
    Navigator.of(context).pushNamed(
      StueckelungVorschlagSeite.routenName,
      arguments: StueckelungVorschlagArgumente(
        barBestandAbzglWechselgeldCent:
            _abschlussVorschau!.barBestandAbzglWechselgeldCent,
        stueckzahlen: widget.argumente.stueckzahlen,
        loseMuenzenNachArtCent: widget.argumente.loseMuenzenNachArtCent,
        kinoName: widget.argumente.kinoName,
        versandNichtBestaetigt: _sendenNichtBestaetigt,
      ),
    );
  }

  String _deutschesDatum(DateTime zeit) =>
      TagesabschlussFormatierung.deutschesDatum(zeit);

  void _zeigeSchrittSlider() {
    _schrittAuswahlHelper.zeigeSchrittAuswahlBottomSheet(
      context: context,
      aktuellerSchritt: 3,
      springeZuSchritt: (int _) => _navigiereZuSchritt4(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TagesabschlussFinal? vorschau = _abschlussVorschau;
    if (vorschau == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final int differenzCent = vorschau.differenzGesamtCent;
    final Color differenzFarbe =
        differenzCent >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    // _apiUploadLaeuft zusaetzlich sperren (nicht nur _autoSaveLaeuft):
    // sonst startet ein zweiter Tap waehrend der laufende Upload noch
    // auf Antwort wartet einen weiteren, parallelen _doApiUpload()-Call
    // (siehe _zeigeAbschlussDialog(), Guard dort greift erst NACH
    // Abschluss des ersten Calls).
    final bool buttonGesperrt = _autoSaveLaeuft || _apiUploadLaeuft;

    return TagesabschlussScaffold(
      backgroundColor: AppFarben.seitenHintergrund,
      zeigeLadebalken: _apiUploadLaeuft,
      appBar: TagesabschlussHeader(
        schrittNummer: 3,
        schrittTitel: 'Übertrag auf Umschlag',
        kinoName: widget.argumente.kinoName,
        onTap: _zeigeSchrittSlider,
        actions: <Widget>[
          const HelpButton(
            helpText:
                'Hier steht, was auf den Umschlag gehört. Prüft die '
                'Differenz zwischen Soll und Ist – bei Abweichungen wenn '
                'möglich erst die Ursache klären, dann den Umschlag '
                'befüllen.',
          ),
        ],
      ),
      footerChild: SizedBox(
        height: 36,
        child: Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (!_abrechnungGesendet &&
                      !_uploadVersucht &&
                      !_devModusAktiv) {
                    zeigeHinweisSnackBar(
                      context,
                      'Bitte zuerst die Abrechnung senden.',
                    );
                    return;
                  }
                  if (_sendenNichtBestaetigt) {
                    // Versand wurde versucht, aber nicht bestätigt — der
                    // Weg zu Schritt 4 ist trotzdem frei (Paco-Wunsch),
                    // aber als Popup (nicht wegwischbar wie eine
                    // SnackBar) daran erinnern, später erneut zu senden.
                    zeigeInfoDialog(
                      context,
                      titel: 'Versand nicht bestätigt',
                      inhalt: const Text(
                        'Die Abrechnung wurde noch nicht erfolgreich an '
                        'die Zentrale übertragen. Bitte den Versand '
                        'später noch einmal versuchen.',
                      ),
                    ).then((_) {
                      if (mounted) _navigiereZuSchritt4();
                    });
                    return;
                  }
                  _navigiereZuSchritt4();
                },
                style: (_abrechnungGesendet || _uploadVersucht)
                    ? AppFarben.footerButtonStyle
                    : (_devModusAktiv
                        ? AppFarben.devBypassButtonStyle
                        : ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.grey.shade300,
                          )),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 6),
                      Text('Stückelung (4/4)'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: <Widget>[
          Schritt3KopfSection(
            kinoName: widget.argumente.kinoName,
            datum: _deutschesDatum(DatumsHelper.logischerAbrechnungsTag()),
          ),
          Schritt3DifferenzAnfangsbestandSection(
            differenzAnfangsbestandCent:
                vorschau.differenzAnfangsbestandCent,
          ),
          Schritt3SollSection(
            kinoSollCent: vorschau.kinoSollCent,
            bistroSollCent: vorschau.bistroSollCent,
            zeigeBistroSoll:
                KinoRepository.nachId(widget.argumente.kinoId)?.hatBistro ??
                    true,
            ausgabenCent: vorschau.ausgabenCent,
            gesamtSollCent: vorschau.gesamtSollCent,
          ),
          Schritt3IstSection(
            ecIstCent: vorschau.ecUmsatzGesamtCent,
            barIstCent: vorschau.barBestandAbzglWechselgeldCent,
            gesamtIstCent: vorschau.gesamtIstCent,
          ),
          Schritt3DifferenzSection(
            differenzCent: differenzCent,
            differenzFarbe: differenzFarbe,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Schritt3AnmerkungSection(
              controller: _anmerkungController,
              focusNode: _anmerkungFocusNode,
              onChanged: _beiAnmerkungGeaendert,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ElevatedButton(
              onPressed: buttonGesperrt ? null : _zeigeAbschlussDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppFarben.fokusFarbe,
                foregroundColor: AppFarben.appBarRot,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _autoSaveLaeuft
                        ? 'Wird gespeichert...'
                        : 'Abrechnung an Büro senden',
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    // Grün = bestätigt erfolgreich gesendet. Rot (Run
                    // 448, Paco-Wunsch) = versucht, aber nicht bestätigt
                    // (echter Fehlschlag oder Ambiguität, siehe
                    // _doApiUpload()) — bewusst ein anderes Icon-Symbol
                    // als der Haken, damit Form UND Farbe "nicht ok"
                    // signalisieren, nicht nur die Farbe. Sonst neutrales
                    // Grau ("nie versucht") — bewusst nicht Orange, siehe
                    // app_farben.dart (Orange ist Führungsfarbe).
                    _sendenNichtBestaetigt ? Icons.error : Icons.check_circle,
                    color: _abrechnungGesendet
                        ? Colors.green
                        : (_sendenNichtBestaetigt
                            ? Colors.red
                            : Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
          if (_devModusAktiv)
            TextButton(
              onPressed: _zeigeFlurbocashJson,
              child: const Text('JSON anzeigen'),
            ),
          if (_devModusAktiv)
            TextButton(
              onPressed: _letzteServerAntwort == null ? null : _zeigeServerAntwort,
              child: const Text('Server-Antwort anzeigen'),
            ),
          if (_autoSaveFehler)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Speichern fehlgeschlagen – bitte erneut versuchen.',
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
