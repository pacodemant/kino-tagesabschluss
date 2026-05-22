import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';
import 'package:kino_bar_app/domain/tagesabschluss_finalisieren_usecase.dart';
import 'package:kino_bar_app/domain/usecases/speichere_tagesabschluss_usecase.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/getraenke_auffuellen_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/pages/stueckelung_vorschlag_seite.dart';
import 'package:kino_bar_app/pages/wechselgeld_zaehlen_seite.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';

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

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Was möchtest du als nächstes tun?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed(
                WechselgeldZaehlenSeite.routenName,
              );
            },
            child: const Text('Wechselgeldkasse prüfen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed(
                GetraenkeAuffuellenSeite.routenName,
              );
            },
            child: const Text('Getränke auffüllen'),
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
      ),
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

  Widget _zeile(String label, String wert, {bool fett = false, Color? farbe}) {
    final FontWeight gewicht =
        fett ? FontWeight.bold : FontWeight.normal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label, style: TextStyle(fontWeight: gewicht)),
          ),
          Text(
            wert,
            style: GoogleFonts.caveat(
              fontSize: 22,
              fontWeight: gewicht,
              color: farbe,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int differenzCent = _abschlussVorschau.differenzGesamtCent;
    final Color differenzFarbe =
        differenzCent >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    final bool buttonGesperrt = _autoSaveLaeuft;

    return TagesabschlussScaffold(
      backgroundColor: Colors.white,
      appBar: TagesabschlussHeader(
        schrittNummer: 3,
        schrittTitel: 'Übertrag auf Umschlag',
        kinoName: widget.argumente.kinoName,
      ),
      footerChild: SizedBox(
        height: 36,
        child: Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: _navigiereZuSchritt4,
                style: AppFarben.footerButtonStyle,
                child: const Text('Stückelung Barumsatz'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.argumente.kinoName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _deutschesDatum(
                          DatumsHelper.logischerAbrechnungsTag(),
                        ),
                        style: GoogleFonts.caveat(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
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
                        _zeile(
                          'Differenz Anfangsbestand',
                          _euro(
                            _abschlussVorschau.differenzAnfangsbestandCent,
                          ),
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
                        _zeile(
                          '+ Kino Soll',
                          _euro(_abschlussVorschau.kinoSollCent),
                        ),
                        _zeile(
                          '+ Bistro Soll',
                          _euro(_abschlussVorschau.bistroSollCent),
                        ),
                        _zeile(
                          '- Ausgaben',
                          _euro(_abschlussVorschau.ausgabenCent),
                        ),
                        _zeile(
                          '= Gesamt Soll',
                          _euro(_abschlussVorschau.gesamtSollCent),
                          fett: true,
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
                        _zeile(
                          '+ EC IST',
                          _euro(_abschlussVorschau.ecUmsatzGesamtCent),
                        ),
                        _zeile(
                          '+ bar IST',
                          _euro(
                            _abschlussVorschau.barBestandAbzglWechselgeldCent,
                          ),
                        ),
                        _zeile(
                          '= Gesamt IST',
                          _euro(_abschlussVorschau.gesamtIstCent),
                          fett: true,
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
                        _zeile(
                          'Differenz Tagesabrechnung',
                          _euroMitVorzeichen(differenzCent),
                          fett: true,
                          farbe: differenzFarbe,
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
                          : 'Tagesabrechnung abschließen',
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
