import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

class StueckelungVorschlagArgumente {
  const StueckelungVorschlagArgumente({
    required this.barBestandAbzglWechselgeldCent,
    required this.stueckzahlen,
    required this.loseMuenzenNachArtCent,
  });

  final int barBestandAbzglWechselgeldCent;
  final Map<String, int> stueckzahlen;
  final Map<String, int> loseMuenzenNachArtCent;
}

// ---------------------------------------------------------------------------

enum _ZeilenArt { stueckzahl, betrag, restbetrag, trennlinie }

class _ErgebnisZeile {
  const _ErgebnisZeile._({
    required this.art,
    this.bezeichnung = '',
    this.genommen = 0,
    this.vorhanden = 0,
    this.betragCent = 0,
    this.gruen = false,
    this.rot = false,
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

  factory _ErgebnisZeile.betrag({
    required String bezeichnung,
    required int betragCent,
    bool rot = false,
  }) =>
      _ErgebnisZeile._(
        art: _ZeilenArt.betrag,
        bezeichnung: bezeichnung,
        betragCent: betragCent,
        rot: rot,
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
    if (kupferCent > 0) {
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

    // Trennlinie und Münzbeträge
    if (zeilen.isNotEmpty) {
      zeilen.add(_ErgebnisZeile.trennlinie());
    }

    // Lose Silbermünzen — Gesamtbetrag anzeigen
    const List<String> silberLoseIds = <String>[
      'coin_2e',
      'coin_1e',
      'coin_50c',
      'coin_20c',
      'coin_10c',
    ];
    int loseSilberCent = 0;
    for (final String id in silberLoseIds) {
      loseSilberCent += argumente.loseMuenzenNachArtCent[id] ?? 0;
    }
    final int silberGenommen =
        restCent < loseSilberCent ? restCent : loseSilberCent;
    restCent -= silberGenommen;

    if (loseSilberCent > 0) {
      zeilen.add(
        _ErgebnisZeile.betrag(
          bezeichnung: 'Lose Münzen',
          betragCent: loseSilberCent,
        ),
      );
    }
    if (kupferCent > 0) {
      zeilen.add(
        _ErgebnisZeile.betrag(
          bezeichnung: 'Kupfermünzen',
          betragCent: kupferCent,
          rot: true,
        ),
      );
    }

    // Restbetrag
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
                width: 64,
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

      case _ZeilenArt.betrag:
        final TextStyle? betragStyle = zeile.rot
            ? TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              )
            : null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(zeile.bezeichnung, style: betragStyle)),
              Text(_euro(zeile.betragCent), style: betragStyle),
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

  @override
  Widget build(BuildContext context) {
    final List<_ErgebnisZeile> zeilen = _berechneErgebnis();

    return TagesabschlussScaffold(
      appBar: const TagesabschlussHeader(
        schrittNummer: 4,
        schrittTitel: 'Stückelungsvorschlag',
        gesamtSchritte: 4,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: <Widget>[
          Text(
            'Bareinnahmen: ${_euro(argumente.barBestandAbzglWechselgeldCent)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
                  width: 64,
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
        ],
      ),
    );
  }
}
