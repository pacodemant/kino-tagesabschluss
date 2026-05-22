import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
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

enum _ZeilenArt { stueckzahl, muenzBetrag, restbetrag, trennlinie }

class _ErgebnisZeile {
  const _ErgebnisZeile._({
    required this.art,
    this.bezeichnung = '',
    this.genommen = 0,
    this.vorhanden = 0,
    this.betragCent = 0,
    this.gruen = false,
    this.rot = false,
    this.fett = true,
  });

  factory _ErgebnisZeile.stueckzahl({
    required String bezeichnung,
    required int genommen,
    required int vorhanden,
    bool gruen = false,
  }) =>
      _ErgebnisZeile._(
        art: _ZeilenArt.stueckzahl,
        bezeichnung: bezeichnung,
        genommen: genommen,
        vorhanden: vorhanden,
        gruen: gruen,
      );

  factory _ErgebnisZeile.muenzBetrag({
    required String bezeichnung,
    required int betragCent,
    bool rot = false,
    bool fett = true,
  }) =>
      _ErgebnisZeile._(
        art: _ZeilenArt.muenzBetrag,
        bezeichnung: bezeichnung,
        betragCent: betragCent,
        rot: rot,
        fett: fett,
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
  final bool rot;
  final bool fett;
}

// ---------------------------------------------------------------------------

class StueckelungVorschlagSeite extends StatelessWidget {
  const StueckelungVorschlagSeite({super.key, required this.argumente});

  static const String routenName = '/closure-step-4';

  final StueckelungVorschlagArgumente argumente;

  // Baut eine Map id → einzelwertCent aus StueckelungKonfiguration.
  Map<String, int> _einzelwertMap() {
    return <String, int>{
      for (final Kassenzeile z in StueckelungKonfiguration.alleStueckzahlZeilen)
        z.id: z.einzelwertCent,
    };
  }

  Map<String, String> _bezeichnungMap() {
    return <String, String>{
      for (final Kassenzeile z in StueckelungKonfiguration.alleStueckzahlZeilen)
        z.id: z.bezeichnung,
    };
  }

  List<_ErgebnisZeile> _berechneErgebnis() {
    int restCent = argumente.barBestandAbzglWechselgeldCent;
    final List<_ErgebnisZeile> zeilen = <_ErgebnisZeile>[];
    final Map<String, int> ew = _einzelwertMap();
    final Map<String, String> bez = _bezeichnungMap();

    // Schritt 1 — Kupfergeld komplett raus
    const Set<String> kupferLoseIds = <String>{'coin_5c', 'coin_2c', 'coin_1c'};
    const Set<String> kupferRollenIds = <String>{
      'roll_5c',
      'roll_2c',
      'roll_1c',
    };

    int kupferCent = 0;
    for (final String id in kupferLoseIds) {
      kupferCent += argumente.loseMuenzenNachArtCent[id] ?? 0;
    }
    for (final String id in kupferRollenIds) {
      kupferCent += (argumente.stueckzahlen[id] ?? 0) * (ew[id] ?? 0);
    }
    // restCent sofort reduzieren, Zeile erst nach Schritt 2 einfügen
    _ErgebnisZeile? kupferZeile;
    if (kupferCent > 0) {
      kupferZeile = _ErgebnisZeile.muenzBetrag(
        bezeichnung: 'Kupfermünzen',
        betragCent: kupferCent,
        rot: true,
      );
      restCent -= kupferCent;
    }

    // Schritt 2 — Scheine + Silberrollen absteigend
    const List<String> reihenfolge = <String>[
      'note_100',
      'note_50',
      'note_20',
      'note_10',
      'note_5',
      'roll_2e',
      'roll_1e',
      'roll_50c',
      'roll_20c',
      'roll_10c',
    ];

    for (final String id in reihenfolge) {
      if (restCent <= 0) {
        break;
      }
      final int einzelwert = ew[id] ?? 1;
      final int maxMoeglich = restCent ~/ einzelwert;
      final int vorhanden = argumente.stueckzahlen[id] ?? 0;
      final int genommen =
          maxMoeglich < vorhanden ? maxMoeglich : vorhanden;
      if (genommen > 0) {
        restCent -= genommen * einzelwert;
        zeilen.add(
          _ErgebnisZeile.stueckzahl(
            bezeichnung: bez[id] ?? id,
            genommen: genommen,
            vorhanden: vorhanden,
            gruen: genommen == vorhanden,
          ),
        );
      }
    }

    // Trennlinie vor Münzzeilen
    if (zeilen.isNotEmpty) {
      zeilen.add(_ErgebnisZeile.trennlinie());
    }

    if (kupferZeile != null) {
      zeilen.add(kupferZeile);
    }

    // Schritt 3 — Lose Silbermünzen
    const List<String> silberLoseIds = <String>[
      'coin_2e',
      'coin_1e',
      'coin_50c',
      'coin_20c',
      'coin_10c',
    ];
    if (restCent > 0) {
      int silberVerfuegbar = 0;
      for (final String id in silberLoseIds) {
        silberVerfuegbar += argumente.loseMuenzenNachArtCent[id] ?? 0;
      }
      final int genommen =
          restCent < silberVerfuegbar ? restCent : silberVerfuegbar;
      if (genommen > 0) {
        zeilen.add(
          _ErgebnisZeile.muenzBetrag(
            bezeichnung: 'Münzen',
            betragCent: genommen,
          ),
        );
        restCent -= genommen;
      }
    }

    // Schritt 4 — Restbetrag
    if (restCent > 0) {
      zeilen.add(_ErgebnisZeile.restbetrag(restCent));
    }

    return zeilen;
  }

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);

  Widget _baueZeile(_ErgebnisZeile zeile) {
    switch (zeile.art) {
      case _ZeilenArt.stueckzahl:
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
              Expanded(child: Text(zeile.bezeichnung)),
              SizedBox(
                width: 96,
                child: Text(
                  '${zeile.genommen} Stk.',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  '/ ${zeile.vorhanden}',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        );

      case _ZeilenArt.muenzBetrag:
        final TextStyle? muenzStyle = zeile.rot
            ? const TextStyle(
                color: Color(0xFFB87333),
                fontWeight: FontWeight.bold,
              )
            : null;
        final TextStyle betragStyle = zeile.rot
            ? const TextStyle(
                color: Color(0xFFB87333),
                fontWeight: FontWeight.bold,
              )
            : zeile.fett
                ? const TextStyle(fontWeight: FontWeight.bold)
                : const TextStyle();
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(zeile.bezeichnung, style: muenzStyle)),
              SizedBox(
                width: 96,
                child: Text(
                  _euro(zeile.betragCent),
                  textAlign: TextAlign.right,
                  style: betragStyle,
                ),
              ),
              const SizedBox(width: 64),
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
                title: const Text('2/4 · Einnahmen'),
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
