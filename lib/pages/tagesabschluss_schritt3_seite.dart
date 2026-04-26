import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/tagesabschluss_finalisieren_usecase.dart';
import 'package:kino_bar_app/domain/usecases/speichere_tagesabschluss_usecase.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';

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
  bool _speichert = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
      ),
      jetzt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // Gibt das Abrechnungsdatum zurück – vor 3 Uhr zählt der Vortag.
  DateTime _abrechnungsDatum() {
    final DateTime jetzt = DateTime.now();
    if (jetzt.hour < 3) {
      return jetzt.subtract(const Duration(days: 1));
    }
    return jetzt;
  }

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);

  String _euroMitVorzeichen(int cent) =>
      TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);

  String _deutschesDatum(DateTime zeit) =>
      TagesabschlussFormatierung.deutschesDatum(zeit);

  Future<void> _speichereFinalenAbschluss() async {
    if (_speichert) {
      return;
    }

    setState(() {
      _speichert = true;
    });

    try {
      final SpeichereTagesabschlussErgebnis ergebnis =
          await _speichereUsecase.ausfuehren(_abschlussVorschau);
      if (!mounted) {
        return;
      }

      if (ergebnis.bereitsVorhanden) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Für dieses Kino existiert heute bereits ein Tagesabschluss.',
            ),
          ),
        );
        setState(() {
          _speichert = false;
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tagesabschluss wurde gespeichert.')),
      );

      Navigator.of(context).pushNamedAndRemoveUntil(
        StartmenueSeite.routenName,
        (Route<dynamic> _) => false,
        arguments: widget.argumente.kinoId,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speichern fehlgeschlagen. Bitte erneut versuchen.'),
        ),
      );
      setState(() {
        _speichert = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int differenzCent = _abschlussVorschau.differenzGesamtCent;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Text(
                  'Differenz Anfangsbestand: ${_euro(_abschlussVorschau.differenzAnfangsbestandCent)}',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '+ KINO SOLL: ${_euro(_abschlussVorschau.kinoSollCent)}',
                          ),
                          Text(
                            '+ BISTRO SOLL: ${_euro(_abschlussVorschau.bistroSollCent)}',
                          ),
                          Text(
                            '- Ausgaben: ${_euro(_abschlussVorschau.ausgabenCent)}',
                          ),
                          Text(
                            '= Gesamt SOLL: ${_euro(_abschlussVorschau.gesamtSollCent)}',
                          ),
                          const SizedBox(height: 8),
                          const Text('Name: ____________'),
                          Text('Datum: ${_deutschesDatum(_abrechnungsDatum())}'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '+ EC IST: ${_euro(_abschlussVorschau.ecUmsatzGesamtCent)}',
                          ),
                          Text(
                            '+ BAR IST: ${_euro(_abschlussVorschau.barBestandAbzglWechselgeldCent)}',
                          ),
                          Text(
                            '= Gesamt IST: ${_euro(_abschlussVorschau.gesamtIstCent)}',
                          ),
                          Text(
                            'Differenz: ${_euroMitVorzeichen(differenzCent)}',
                            style: TextStyle(
                              color: differenzCent >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Haus: ${widget.argumente.kinoName}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _speichert ? null : _speichereFinalenAbschluss,
                  child: Text(
                    _speichert
                        ? 'Speichern...'
                        : 'Tagesabschluss speichern',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
