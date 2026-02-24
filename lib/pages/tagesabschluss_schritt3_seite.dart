import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/tagesabschluss_finalisieren_usecase.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

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

  late final TagesabschlussFinal _abschlussVorschau;
  bool _speichert = false;

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
        differenzAnfangsbestandCent: widget.argumente.differenzAnfangsbestandCent,
      ),
      jetzt: DateTime.now(),
    );
  }

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);

  String _euroMitVorzeichen(int cent) {
    return TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);
  }

  String _deutschesDatum(DateTime zeit) {
    return TagesabschlussFormatierung.deutschesDatum(zeit);
  }

  String _uhrzeit(DateTime zeit) {
    final String stunde = zeit.hour.toString().padLeft(2, '0');
    final String minute = zeit.minute.toString().padLeft(2, '0');
    final String sekunde = zeit.second.toString().padLeft(2, '0');
    return '$stunde:$minute:$sekunde';
  }

  Future<void> _speichereFinalenAbschluss() async {
    if (_speichert) {
      return;
    }

    setState(() {
      _speichert = true;
    });

    try {
      await LokalerSpeicher.speichereFinalenTagesabschluss(_abschlussVorschau);
      if (!mounted) {
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
        const SnackBar(content: Text('Speichern fehlgeschlagen. Bitte erneut versuchen.')),
      );
      setState(() {
        _speichert = false;
      });
    }
  }

  void _zeigeBuchhaltungsAnsicht() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ansicht für Umschlag/Buchhaltung'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Gesamt SOLL: ${_euro(_abschlussVorschau.gesamtSollCent)}'),
              Text('Gesamt IST: ${_euro(_abschlussVorschau.gesamtIstCent)}'),
              Text(
                'Differenz: ${_euroMitVorzeichen(_abschlussVorschau.differenzGesamtCent)}',
              ),
              Text(
                'Differenz Anfangsbestand: ${_euro(_abschlussVorschau.differenzAnfangsbestandCent)}',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  Widget _zeile(String label, String wert, {bool kursiv = false, bool fett = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontStyle: kursiv ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          Text(
            wert,
            style: TextStyle(
              fontWeight: fett ? FontWeight.w700 : FontWeight.w500,
              fontStyle: kursiv ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tagesabschluss – Schritt 3/4: Finalisieren'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _zeile('Kino', '${_abschlussVorschau.kinoName} (${_abschlussVorschau.kinoId})'),
                    _zeile('Datum', _deutschesDatum(_abschlussVorschau.datum)),
                    _zeile(
                      'Erstellt um',
                      '${_deutschesDatum(_abschlussVorschau.createdAt)} ${_uhrzeit(_abschlussVorschau.createdAt)}',
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    _zeile('Scheine', _euro(_abschlussVorschau.scheineCent)),
                    _zeile('Lose Münzen', _euro(_abschlussVorschau.loseMuenzenCent)),
                    _zeile('Rollen', _euro(_abschlussVorschau.rollenCent)),
                    _zeile('Umschläge', _euro(_abschlussVorschau.umschlaegeCent)),
                    _zeile(
                      'Gesamt Bargeld',
                      _euro(_abschlussVorschau.kassenbestandGesamtCent),
                      fett: true,
                    ),
                    _zeile(
                      'Abzgl. Wechselgeld',
                      _euro(_abschlussVorschau.barBestandAbzglWechselgeldCent),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    _zeile('Kino SOLL', _euro(_abschlussVorschau.kinoSollCent)),
                    _zeile('Bistro SOLL', _euro(_abschlussVorschau.bistroSollCent)),
                    _zeile('Ausgaben', _euro(_abschlussVorschau.ausgabenCent)),
                    _zeile('Gesamt SOLL', _euro(_abschlussVorschau.gesamtSollCent), fett: true),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    _zeile('EC Gesamt', _euro(_abschlussVorschau.ecUmsatzGesamtCent)),
                    _zeile(
                      'BAR (abzgl. Wechselgeld)',
                      _euro(_abschlussVorschau.barBestandAbzglWechselgeldCent),
                    ),
                    _zeile('Gesamt IST', _euro(_abschlussVorschau.gesamtIstCent), fett: true),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    _zeile(
                      'Differenz SOLL/IST',
                      _euroMitVorzeichen(_abschlussVorschau.differenzGesamtCent),
                      fett: true,
                    ),
                    _zeile(
                      'Differenz im Anfangsbestand',
                      _euro(_abschlussVorschau.differenzAnfangsbestandCent),
                      kursiv: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _speichert ? null : _speichereFinalenAbschluss,
                child: Text(
                  _speichert ? 'Speichern...' : 'Tagesabschluss speichern/abschließen',
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _zeigeBuchhaltungsAnsicht,
              child: const Text('Ansicht für Umschlag/Buchhaltung'),
            ),
          ],
        ),
      ),
    );
  }
}
