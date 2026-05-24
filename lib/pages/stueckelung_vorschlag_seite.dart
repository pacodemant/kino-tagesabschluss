import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

class StueckelungVorschlagArgumente {
  const StueckelungVorschlagArgumente({
    required this.barBestandAbzglWechselgeldCent,
    required this.stueckzahlen,
    required this.loseMuenzenNachArtCent,
    this.kinoName = 'Schauburg',
    this.onAbschliessen,
  });

  final int barBestandAbzglWechselgeldCent;
  final Map<String, int> stueckzahlen;
  final Map<String, int> loseMuenzenNachArtCent;
  final String kinoName;
  final VoidCallback? onAbschliessen;
}

// ---------------------------------------------------------------------------

enum _ZeilenArt { stueckzahl, restbetrag, trennlinie }

class _Denomination {
  const _Denomination(this.id, this.bezeichnung, this.einzelwertCent, this.istMuenze);
  final String id;
  final String bezeichnung;
  final int einzelwertCent;
  final bool istMuenze;
}

const List<_Denomination> _alleDenominationen = <_Denomination>[
  _Denomination('note_100', '100 €', 10000, false),
  _Denomination('note_50', '50 €', 5000, false),
  _Denomination('note_20', '20 €', 2000, false),
  _Denomination('note_10', '10 €', 1000, false),
  _Denomination('note_5', '5 €', 500, false),
  _Denomination('coin_2e', '2 €', 200, true),
  _Denomination('coin_1e', '1 €', 100, true),
  _Denomination('coin_50c', '0,50 €', 50, true),
  _Denomination('coin_20c', '0,20 €', 20, true),
  _Denomination('coin_10c', '0,10 €', 10, true),
  _Denomination('coin_5c', '0,05 €', 5, true),
  _Denomination('coin_2c', '0,02 €', 2, true),
  _Denomination('coin_1c', '0,01 €', 1, true),
];

class _ErgebnisZeile {
  const _ErgebnisZeile._({
    required this.art,
    this.bezeichnung = '',
    this.genommen = 0,
    this.vorhanden = 0,
    this.betragCent = 0,
    this.gruen = false,
    this.ausgegraut = false,
  });

  factory _ErgebnisZeile.stueckzahl({
    required String bezeichnung,
    required int genommen,
    required int vorhanden,
    bool gruen = false,
    bool ausgegraut = false,
  }) =>
      _ErgebnisZeile._(
        art: _ZeilenArt.stueckzahl,
        bezeichnung: bezeichnung,
        genommen: genommen,
        vorhanden: vorhanden,
        gruen: gruen,
        ausgegraut: ausgegraut,
      );

  factory _ErgebnisZeile.restbetrag(int betragCent) =>
      _ErgebnisZeile._(art: _ZeilenArt.restbetrag, betragCent: betragCent);

  factory _ErgebnisZeile.trennlinie() =>
      _ErgebnisZeile._(art: _ZeilenArt.trennlinie);

  final _ZeilenArt art;
  final String bezeichnung;
  final int genommen;
  final int vorhanden;
  final int betragCent;
  final bool gruen;
  final bool ausgegraut;
}

// ---------------------------------------------------------------------------

class StueckelungVorschlagSeite extends StatelessWidget {
  const StueckelungVorschlagSeite({super.key, required this.argumente});

  static const String routenName = '/closure-step-4';

  final StueckelungVorschlagArgumente argumente;

  List<_ErgebnisZeile> _berechneErgebnis() {
    int restCent = argumente.barBestandAbzglWechselgeldCent;
    final List<_ErgebnisZeile> zeilen = <_ErgebnisZeile>[];

    bool trennlinieEingefuegt = false;
    for (final _Denomination denom in _alleDenominationen) {
      if (denom.istMuenze && !trennlinieEingefuegt) {
        zeilen.add(_ErgebnisZeile.trennlinie());
        trennlinieEingefuegt = true;
      }

      final int vorhanden = denom.istMuenze
          ? (argumente.loseMuenzenNachArtCent[denom.id] ?? 0) ~/
              denom.einzelwertCent
          : argumente.stueckzahlen[denom.id] ?? 0;

      int genommen = 0;
      if (restCent > 0 && vorhanden > 0) {
        final int maxMoeglich = restCent ~/ denom.einzelwertCent;
        genommen = maxMoeglich < vorhanden ? maxMoeglich : vorhanden;
        restCent -= genommen * denom.einzelwertCent;
      }

      zeilen.add(
        _ErgebnisZeile.stueckzahl(
          bezeichnung: denom.bezeichnung,
          genommen: genommen,
          vorhanden: vorhanden,
          gruen: genommen > 0 && genommen == vorhanden,
          ausgegraut: genommen == 0,
        ),
      );
    }

    if (restCent > 0) {
      zeilen.add(_ErgebnisZeile.restbetrag(restCent));
    }

    return zeilen;
  }

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);

  Widget _baueZeile(_ErgebnisZeile zeile) {
    switch (zeile.art) {
      case _ZeilenArt.stueckzahl:
        final Color? grauFarbe =
            zeile.ausgegraut ? Colors.grey.shade400 : null;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: zeile.gruen
              ? BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  zeile.bezeichnung,
                  style: TextStyle(color: grauFarbe),
                ),
              ),
              SizedBox(
                width: 96,
                child: Text(
                  '${zeile.genommen} Stk.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: grauFarbe,
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  '/ ${zeile.vorhanden}',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: grauFarbe ?? Colors.grey.shade600),
                ),
              ),
            ],
          ),
        );

      case _ZeilenArt.restbetrag:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            'Nicht abdeckbar: ${_euro(zeile.betragCent)}',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case _ZeilenArt.trennlinie:
        return Divider(
          height: 12,
          thickness: 1,
          color: Colors.grey.shade300,
          indent: 8,
          endIndent: 8,
        );
    }
  }

  void _zeigeSchrittSlider(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('1/4 · Bargeldzählung'),
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
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('3/4 · Finalisieren'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/closure-step-3'));
                },
              ),
              const ListTile(
                leading: Icon(Icons.check_circle),
                title: Text(
                  '4/4 · Stückelung Barumsatz',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Aktueller Schritt'),
                enabled: false,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_ErgebnisZeile> zeilen = _berechneErgebnis();

    return TagesabschlussScaffold(
      appBar: TagesabschlussHeader(
        schrittNummer: 4,
        schrittTitel: 'Stückelung Barumsatz',
        gesamtSchritte: 4,
        kinoName: argumente.kinoName,
        onTap: () => _zeigeSchrittSlider(context),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <TextSpan>[
                const TextSpan(
                  text: 'Bareinnahmen Stückelung: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: _euro(argumente.barBestandAbzglWechselgeldCent),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Einheit',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                    'Bedarf',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    'Vorh.',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 12),
          if (zeilen.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'Keine Einheiten benötigt.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...zeilen.map(_baueZeile),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: argumente.onAbschliessen,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppFarben.appBarRot,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Tagesabrechnung abschließen'),
          ),
        ],
      ),
    );
  }
}
