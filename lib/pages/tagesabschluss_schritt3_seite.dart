import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/help_button.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';
import 'package:kino_bar_app/domain/tagesabschluss_finalisieren_usecase.dart';
import 'package:kino_bar_app/domain/usecases/speichere_tagesabschluss_usecase.dart';
import 'package:kino_bar_app/services/google_sheets_service.dart';
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

  late final TagesabschlussFinal _abschlussVorschau;

  // true = Auto-Save läuft oder abgeschlossen, false = noch ausstehend
  bool _autoSaveErledigt = false;
  bool _autoSaveLaeuft = false;
  bool _autoSaveFehler = false;
  bool _uploadErledigt = false;

  @override
  void initState() {
    super.initState();
    _abschlussVorschau = _finalisierenUsecase.finalisieren(
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
      ),
      jetzt: DateTime.now(),
    );

    _autoSaveImHintergrund();
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
          await _speichereUsecase.ausfuehren(_abschlussVorschau);
      if (!mounted) {
        return;
      }

      if (ergebnis.bereitsVorhanden) {
        await _speichereUsecase.ausfuehren(
          _abschlussVorschau,
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

  Future<void> _triggerUpload() async {
    try {
      await GoogleSheetsService.uploadAbrechnung(_abschlussVorschau);
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
      _uploadErledigt = true;
      _triggerUpload().ignore();
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

  void _navigiereZuSchritt4() {
    Navigator.of(context).pushNamed(
      StueckelungVorschlagSeite.routenName,
      arguments: StueckelungVorschlagArgumente(
        barBestandAbzglWechselgeldCent:
            _abschlussVorschau.barBestandAbzglWechselgeldCent,
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
    final int differenzCent = _abschlussVorschau.differenzGesamtCent;
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
                          wert: _euro(_abschlussVorschau.differenzAnfangsbestandCent),
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
                          wert: _euro(_abschlussVorschau.kinoSollCent),
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                        if (widget.argumente.kinoId != 'kino_04')
                          InfoZeile(
                            label: '+ Bistro Soll',
                            wert: _euro(_abschlussVorschau.bistroSollCent),
                            stil: InfoZeileStil.fuehrungslinie,
                          ),
                        InfoZeile(
                          label: '- Ausgaben',
                          wert: _euro(_abschlussVorschau.ausgabenCent),
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                        InfoZeile(
                          label: '= Gesamt Soll',
                          wert: _euro(_abschlussVorschau.gesamtSollCent),
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
                          wert: _euro(_abschlussVorschau.ecUmsatzGesamtCent),
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                        InfoZeile(
                          label: '+ bar IST',
                          wert: _euro(_abschlussVorschau.barBestandAbzglWechselgeldCent),
                          stil: InfoZeileStil.fuehrungslinie,
                        ),
                        InfoZeile(
                          label: '= Gesamt IST',
                          wert: _euro(_abschlussVorschau.gesamtIstCent),
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
                          : 'Kassenabrechnung abschließen',
                    ),
                  ),
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
