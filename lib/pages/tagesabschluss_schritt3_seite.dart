import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/ec_terminal_ergebnis.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kino_bar_app/pages/getraenke_auffuellen_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/pages/stueckelung_vorschlag_seite.dart';
import 'package:kino_bar_app/pages/wechselgeld_pruefen_seite.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/utils/schritt_auswahl_bottom_sheet_helper.dart';

class TagesabschlussSchritt3Argumente {
  const TagesabschlussSchritt3Argumente({
    required this.kinoId,
    required this.kinoName,
    required this.scheineCent,
    required this.loseMuenzenCent,
    required this.rollenCent,
    required this.umschlaegeCent,
    required this.wechselgeldSollwertCent,
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
    this.ecTerminals,
    this.anmerkung,
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
  final List<EcTerminalErgebnis>? ecTerminals;
  final String? anmerkung;
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
  });

  static const String routenName = '/closure-step-3';

  final TagesabschlussSchritt3Argumente argumente;

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

  // null solange die async-Initialisierung noch läuft
  TagesabschlussFinal? _abschlussVorschau;

  // true = Auto-Save läuft oder abgeschlossen, false = noch ausstehend
  bool _autoSaveErledigt = false;
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

  @override
  void initState() {
    super.initState();
    _initialisierenAsync();
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

  Future<void> _initialisierenAsync() async {
    final TagesabschlussFinal abschluss = _finalisierenUsecase.finalisieren(
      eingabe: TagesabschlussFinalisierenEingabe(
        kinoId: widget.argumente.kinoId,
        kinoName: widget.argumente.kinoName,
        scheineCent: widget.argumente.scheineCent,
        loseMuenzenCent: widget.argumente.loseMuenzenCent,
        rollenCent: widget.argumente.rollenCent,
        umschlaegeCent: widget.argumente.umschlaegeCent,
        wechselgeldSollwertCent: widget.argumente.wechselgeldSollwertCent,
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
        anmerkung: widget.argumente.anmerkung,
        ecBelegeFotosBase64: widget.argumente.ecBelegeFotosBase64,
        ecBelegeFotosMediaTypen: widget.argumente.ecBelegeFotosMediaTypen,
      ),
      jetzt: DateTime.now(),
    );
    if (!mounted) return;
    setState(() => _abschlussVorschau = abschluss);
    if (widget.argumente.zielSchrittBeimSprung == 4) {
      _navigiereZuSchritt4();
    }
    _autoSaveImHintergrund();
    DevModus.istAktiv().then((bool aktiv) {
      if (mounted) setState(() => _devModusAktiv = aktiv);
    });
    LokalerSpeicher.ladeSendeBestaetigung(widget.argumente.kinoId).then(
      (String? gespeicherteSignatur) {
        if (mounted &&
            gespeicherteSignatur != null &&
            gespeicherteSignatur == _sendeSignatur()) {
          setState(() => _abrechnungGesendet = true);
        }
      },
    );
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

    try {
      final SpeichereTagesabschlussErgebnis ergebnis =
          await _speichereUsecase.ausfuehren(_abschlussVorschau!);
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
        await _speichereUsecase.ausfuehren(
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

  Future<void> _doApiUpload() async {
    if (mounted) {
      setState(() => _apiUploadLaeuft = true);
    }
    try {
      _letzteServerAntwort =
          await ApiUploadService.upload(_abschlussVorschau!);
      _apiUploadErledigt = true;
      // Bewusst nicht mounted-gated: diese beiden Aufrufe persistieren
      // den Sende-Status lokal und müssen auch dann laufen, wenn die
      // Seite (z. B. via "Zurück zur Startseite") schon verlassen wurde,
      // bevor der Upload zurückkam — sonst bleibt gesendetAm dauerhaft
      // null, obwohl der Upload erfolgreich war (Run 396).
      await LokalerSpeicher.speichereSendeBestaetigung(
        widget.argumente.kinoId,
        _sendeSignatur(),
        isoDatum: DatumsHelper.logischesIsoDatum(),
      );
      await LokalerSpeicher.markiereAlsGesendet(
        _abschlussVorschau!.kinoId,
        _abschlussVorschau!.createdAt,
        DateTime.now(),
      );
      if (mounted) {
        setState(() => _abrechnungGesendet = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppFarben.fokusFarbe,
            content: Text(
              'API Upload erfolgreich ✓',
              style: TextStyle(color: AppFarben.appBarRot),
            ),
          ),
        );
      }
    } catch (e) {
      if (ApiUploadService.isCorsArtFehler(e)) {
        _apiUploadErledigt = true;
        await LokalerSpeicher.markiereAlsGesendet(
          _abschlussVorschau!.kinoId,
          _abschlussVorschau!.createdAt,
          DateTime.now(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppFarben.fokusFarbe,
              content: Text(
                'Upload gesendet — Empfang nicht bestätigbar',
                style: TextStyle(color: AppFarben.appBarRot),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          final String fehler = e.toString();
          final String anzeige =
              fehler.length > 120 ? '${fehler.substring(0, 120)}…' : fehler;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppFarben.fokusFarbe,
              content: Text(
                'API Upload fehlgeschlagen — Abrechnung lokal gespeichert\n$anzeige',
                style: const TextStyle(color: AppFarben.appBarRot),
              ),
              duration: const Duration(seconds: 8),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _apiUploadLaeuft = false);
      }
    }
  }

  Future<void> _zeigeAbschlussDialog() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppFarben.fokusFarbe,
            content: Text(
              'Speichern fehlgeschlagen. Bitte erneut versuchen.',
              style: TextStyle(color: AppFarben.appBarRot),
            ),
          ),
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    if (!_apiUploadErledigt) {
      final bool apiAktiv = await FeatureFlags.apiUploadAktiv();
      if (!mounted) return;
      if (apiAktiv) {
        // Bewusst nicht awaited: Dialog soll sofort öffnen, ohne auf die
        // Netzwerkantwort zu warten. Haken + Persistierung passieren
        // direkt in _doApiUpload() im echten Erfolgsfall — nicht beim
        // CORS-Fallback, da der nicht von einem echten Offline-Fehler
        // unterscheidbar ist.
        _doApiUpload().ignore();
      } else {
        // Kein Online-Versand für dieses Kino aktiv — "gesendet" meint
        // hier nur die bereits erfolgte lokale Speicherung.
        setState(() => _abrechnungGesendet = true);
        await LokalerSpeicher.speichereSendeBestaetigung(
          widget.argumente.kinoId,
          _sendeSignatur(),
          isoDatum: DatumsHelper.logischesIsoDatum(),
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
          title: const Text('Was möchtest du als nächstes tun?'),
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
    final String? locationIdStr =
        speicher.getString('flurbocash_location_id_${widget.argumente.kinoId}');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppFarben.fokusFarbe,
          content: Text(
            'JSON-Vorschau fehlgeschlagen: $e',
            style: const TextStyle(color: AppFarben.appBarRot),
          ),
          duration: const Duration(seconds: 8),
        ),
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
                'Hier wird der Betrag errechnet, der auf den Umschlag gehört. '
                'Prüfe die Differenz zwischen Soll und Ist. Bei Abweichungen '
                'zuerst die Ursache klären, dann den Umschlag befüllen.',
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
                  if (!_abrechnungGesendet && !_devModusAktiv) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppFarben.fokusFarbe,
                        content: Text(
                          'Bitte zuerst die Abrechnung senden.',
                          style: TextStyle(color: AppFarben.appBarRot),
                        ),
                      ),
                    );
                    return;
                  }
                  _navigiereZuSchritt4();
                },
                style: _abrechnungGesendet
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
            zeigeBistroSoll: widget.argumente.kinoId != 'kino_04',
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
                    Icons.check_circle,
                    color: _abrechnungGesendet
                        ? Colors.green
                        : Colors.grey.shade400,
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
