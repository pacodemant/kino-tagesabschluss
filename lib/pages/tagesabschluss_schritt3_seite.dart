import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/ec_terminal_ergebnis.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/help_button.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';
import 'package:kino_bar_app/domain/tagesabschluss_finalisieren_usecase.dart';
import 'package:kino_bar_app/domain/usecases/speichere_tagesabschluss_usecase.dart';
import 'package:kino_bar_app/config/feature_flags.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:kino_bar_app/services/dev_modus.dart';
import 'package:kino_bar_app/services/google_sheets_service.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/getraenke_auffuellen_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/pages/stueckelung_vorschlag_seite.dart';
import 'package:kino_bar_app/pages/wechselgeld_pruefen_seite.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
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

  // null solange die async-Initialisierung noch läuft
  TagesabschlussFinal? _abschlussVorschau;

  // true = Auto-Save läuft oder abgeschlossen, false = noch ausstehend
  bool _autoSaveErledigt = false;
  bool _autoSaveLaeuft = false;
  bool _autoSaveFehler = false;
  bool _uploadErledigt = false;
  bool _apiUploadErledigt = false;
  bool _devModusAktiv = false;

  @override
  void initState() {
    super.initState();
    _initialisierenAsync();
  }

  Future<void> _initialisierenAsync() async {
    final String? mitarbeiterName = await LokalerSpeicher.ladeMitarbeiterName();
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
        mitarbeiterName: mitarbeiterName?.isNotEmpty == true
            ? mitarbeiterName
            : null,
        terminalId: widget.argumente.terminalId,
        belegNrVon: widget.argumente.belegNrVon,
        belegNrBis: widget.argumente.belegNrBis,
        ecUhrzeit: widget.argumente.ecUhrzeit,
        zahlungsartenAufschluesselung:
            widget.argumente.zahlungsartenAufschluesselung,
      ),
      jetzt: DateTime.now(),
    );
    if (!mounted) return;
    setState(() => _abschlussVorschau = abschluss);
    _autoSaveImHintergrund();
    DevModus.istAktiv().then((bool aktiv) {
      if (mounted) setState(() => _devModusAktiv = aktiv);
    });
  }

  /// Speichert den Abschluss beim Öffnen der Seite automatisch.
  /// Duplikat → stillschweigend überschreiben (kein Dialog).
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
        await _speichereUsecase.ausfuehren(
          _abschlussVorschau!,
          ueberschreiben: true,
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

  Future<void> _doApiUpload() async {
    try {
      await ApiUploadService.upload(_abschlussVorschau!);
      _apiUploadErledigt = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Upload erfolgreich ✓')),
        );
      }
    } catch (e) {
      if (ApiUploadService.isCorsArtFehler(e)) {
        _apiUploadErledigt = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload gesendet — Empfang nicht bestätigbar'),
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
              content: Text(
                'API Upload fehlgeschlagen — Abrechnung lokal gespeichert\n$anzeige',
              ),
              duration: const Duration(seconds: 8),
            ),
          );
        }
      }
    }
  }

  Future<void> _doUpload(String accessToken) async {
    try {
      await GoogleSheetsService.uploadAbrechnung(_abschlussVorschau!, accessToken);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abrechnung hochgeladen ✓')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Upload fehlgeschlagen — Abrechnung wurde lokal gespeichert',
            ),
          ),
        );
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
            content: Text('Speichern fehlgeschlagen. Bitte erneut versuchen.'),
          ),
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    if (!_uploadErledigt) {
      final bool googleSheetsAktiv = await FeatureFlags.googleSheetsAktiv();
      if (!mounted) return;
      if (googleSheetsAktiv) {
        try {
          final String token = await GoogleSheetsService.authenticate();
          if (!mounted) return;
          _uploadErledigt = true;
          _doUpload(token).ignore();
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Upload fehlgeschlagen — Abrechnung wurde lokal gespeichert',
                ),
              ),
            );
          }
        }
      }
    }

    if (!_apiUploadErledigt) {
      final bool apiAktiv = await FeatureFlags.apiUploadAktiv();
      if (!mounted) return;
      if (apiAktiv) {
        _doApiUpload().ignore();
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
                    arguments: widget.argumente.kinoId,
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

  void _zeigeFlurbocashJson() {
    // TODO: location_id aus Einstellungen laden (SharedPreferences-Key noch nicht vergeben)
    final Map<String, dynamic> call1 = <String, dynamic>{
      'location_id': 0,
      'date': DatumsHelper.logischesIsoDatum(),
    };

    final List<EcTerminalErgebnis> ecTerminals =
        widget.argumente.ecTerminals ?? <EcTerminalErgebnis>[];

    final List<Map<String, dynamic>> terminals = ecTerminals
        .map((EcTerminalErgebnis t) => <String, dynamic>{
              'tid': t.tid,
              'girocard': t.girocard,
              'lastschrift': t.lastschrift,
              'mastercard': t.mastercard,
              'visa': t.visa,
              'maestro': t.maestro,
              'vpay': t.vpay,
            })
        .toList();

    final Map<String, dynamic> call2 = <String, dynamic>{
      'settlements': <Map<String, dynamic>>[
        <String, dynamic>{
          'cash_total':
              _abschlussVorschau?.barBestandAbzglWechselgeldCent ?? 0,
          'terminals': terminals,
        },
      ],
    };

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String call1Json = encoder.convert(call1);
    final String call2Json = encoder.convert(call2);

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

  void _navigiereZuSchritt4() {
    Navigator.of(context).pushNamed(
      StueckelungVorschlagSeite.routenName,
      arguments: StueckelungVorschlagArgumente(
        barBestandAbzglWechselgeldCent:
            _abschlussVorschau!.barBestandAbzglWechselgeldCent,
        stueckzahlen: widget.argumente.stueckzahlen,
        loseMuenzenNachArtCent: widget.argumente.loseMuenzenNachArtCent,
        kinoName: widget.argumente.kinoName,
        onAbschliessen: _zeigeAbschlussDialog,
      ),
    );
  }

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);

  String _euroMitVorzeichen(int cent) =>
      TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);

  String _deutschesDatum(DateTime zeit) =>
      TagesabschlussFormatierung.deutschesDatum(zeit);

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
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('2/4 · Belege'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/closure-step-2'));
                },
              ),
              const ListTile(
                leading: Icon(Icons.check_circle),
                title: Text(
                  '3/4 · Finalisieren',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Aktueller Schritt'),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.arrow_forward),
                title: const Text('4/4 · Stückelung Barumsatz'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _navigiereZuSchritt4();
                },
              ),
            ],
          ),
        );
      },
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

    final bool buttonGesperrt = _autoSaveLaeuft;

    return TagesabschlussScaffold(
      backgroundColor: AppFarben.seitenHintergrund,
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
                onPressed: _navigiereZuSchritt4,
                style: AppFarben.footerButtonStyle,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.argumente.kinoName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Text(
                        _deutschesDatum(
                          DatumsHelper.logischerAbrechnungsTag(),
                        ),
                        style: GoogleFonts.caveat(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rahmen 1 – Differenz Anfangsbestand
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        InfoZeile(
                          label: 'Differenz Anfangsbestand',
                          wert: _euro(vorschau.differenzAnfangsbestandCent),
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                      ],
                    ),
                  ),
                ),
                // Rahmen 2 – SOLL
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        InfoZeile(
                          label: '+ Kino Soll',
                          wert: _euro(vorschau.kinoSollCent),
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                        if (widget.argumente.kinoId != 'kino_04')
                          InfoZeile(
                            label: '+ Bistro Soll',
                            wert: _euro(vorschau.bistroSollCent),
                            stil: InfoZeileStil.fuehrungslinie,
                          ),
                        InfoZeile(
                          label: '- Ausgaben',
                          wert: _euro(vorschau.ausgabenCent),
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                        InfoZeile(
                          label: '= Gesamt Soll',
                          wert: _euro(vorschau.gesamtSollCent),
                          fett: true,
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                      ],
                    ),
                  ),
                ),
                // Rahmen 3 – IST
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        InfoZeile(
                          label: '+ EC IST',
                          wert: _euro(vorschau.ecUmsatzGesamtCent),
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                        InfoZeile(
                          label: '+ bar IST',
                          wert: _euro(vorschau.barBestandAbzglWechselgeldCent),
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                        InfoZeile(
                          label: '= Gesamt IST',
                          wert: _euro(vorschau.gesamtIstCent),
                          fett: true,
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                      ],
                    ),
                  ),
                ),
                // Rahmen 4 – Differenz
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        InfoZeile(
                          label: 'Differenz\nKassenabrechnung',
                          wert: _euroMitVorzeichen(differenzCent),
                          fett: true,
                          farbe: differenzFarbe,
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: ElevatedButton(
                    onPressed: buttonGesperrt ? null : _zeigeAbschlussDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppFarben.appBarRot,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(
                      _autoSaveLaeuft
                          ? 'Wird gespeichert...'
                          : 'Kassenabrechnung senden',
                    ),
                  ),
                ),
                if (_devModusAktiv)
                  TextButton(
                    onPressed: _zeigeFlurbocashJson,
                    child: const Text('JSON anzeigen'),
                  ),
                if (_autoSaveFehler)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Speichern fehlgeschlagen – bitte erneut versuchen.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}
