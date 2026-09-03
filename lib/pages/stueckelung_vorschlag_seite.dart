import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/utils/schritt_auswahl_bottom_sheet_helper.dart';
import 'package:kino_bar_app/widgets/help_button.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

class StueckelungVorschlagArgumente {
  const StueckelungVorschlagArgumente({
    required this.barBestandAbzglWechselgeldCent,
    required this.stueckzahlen,
    required this.loseMuenzenNachArtCent,
    this.kinoName = 'Schauburg',
  });

  final int barBestandAbzglWechselgeldCent;
  final Map<String, int> stueckzahlen;
  final Map<String, int> loseMuenzenNachArtCent;
  final String kinoName;
}

// ---------------------------------------------------------------------------

enum _ZeilenArt { stueckzahl, betragzeile, restbetrag, trennlinie }

class _ErgebnisZeile {
  const _ErgebnisZeile._({
    required this.art,
    this.bezeichnung = '',
    this.genommen = 0,
    this.vorhanden = 0,
    this.betragCent = 0,
    this.gruen = false,
    this.rot = false,
    this.ausgegraut = false,
    this.steuerbar = false,
    this.onPlus,
    this.onMinus,
    this.wechselgeldRest,
  });

  factory _ErgebnisZeile.stueckzahl({
    required String bezeichnung,
    required int genommen,
    required int vorhanden,
    bool gruen = false,
    bool ausgegraut = false,
    bool steuerbar = false,
    VoidCallback? onPlus,
    VoidCallback? onMinus,
    int? wechselgeldRest,
  }) => _ErgebnisZeile._(
    art: _ZeilenArt.stueckzahl,
    bezeichnung: bezeichnung,
    genommen: genommen,
    vorhanden: vorhanden,
    gruen: gruen,
    ausgegraut: ausgegraut,
    steuerbar: steuerbar,
    onPlus: onPlus,
    onMinus: onMinus,
    wechselgeldRest: wechselgeldRest,
  );

  factory _ErgebnisZeile.betragzeile({
    required String bezeichnung,
    required int betragCent,
    bool ausgegraut = false,
    bool rot = false,
  }) => _ErgebnisZeile._(
    art: _ZeilenArt.betragzeile,
    bezeichnung: bezeichnung,
    betragCent: betragCent,
    ausgegraut: ausgegraut,
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
  final bool ausgegraut;
  final bool steuerbar;
  final VoidCallback? onPlus;
  final VoidCallback? onMinus;
  final int? wechselgeldRest;
}

// ---------------------------------------------------------------------------

class StueckelungVorschlagSeite extends StatefulWidget {
  const StueckelungVorschlagSeite({super.key, required this.argumente});

  static const String routenName = '/closure-step-4';

  final StueckelungVorschlagArgumente argumente;

  @override
  State<StueckelungVorschlagSeite> createState() =>
      _StueckelungVorschlagSeiteState();
}

class _StueckelungVorschlagSeiteState extends State<StueckelungVorschlagSeite> {
  // Verschiebt Scheine manuell zwischen Umschlag (Barumsatz) und
  // Wechselgeld: +1 = ein Zwanziger mehr im Umschlag (zwei Zehner weniger),
  // -1 = umgekehrt. 1 Zwanziger entspricht wertmäßig 2 Zehnern, die
  // Umschlag-Summe bleibt bei jeder Verschiebung exakt gleich.
  int _verschiebung = 0;

  List<_ErgebnisZeile> _berechneErgebnis() {
    int restCent = widget.argumente.barBestandAbzglWechselgeldCent;
    final List<_ErgebnisZeile> zeilen = <_ErgebnisZeile>[];

    String bezeichnung20 = '';
    String bezeichnung10 = '';
    int vorhanden20 = 0;
    int vorhanden10 = 0;
    int basis20 = 0;
    int basis10 = 0;
    int index20 = -1;
    int index10 = -1;

    // Scheine greedy, absteigend
    for (final Kassenzeile schein in StueckelungKonfiguration.scheine) {
      final int vorhanden = widget.argumente.stueckzahlen[schein.id] ?? 0;
      int genommen = 0;
      if (restCent > 0 && vorhanden > 0) {
        final int maxMoeglich = restCent ~/ schein.einzelwertCent;
        genommen = maxMoeglich < vorhanden ? maxMoeglich : vorhanden;
        restCent -= genommen * schein.einzelwertCent;
      }

      if (schein.id == 'note_20') {
        bezeichnung20 = schein.bezeichnung;
        vorhanden20 = vorhanden;
        basis20 = genommen;
        index20 = zeilen.length;
      } else if (schein.id == 'note_10') {
        bezeichnung10 = schein.bezeichnung;
        vorhanden10 = vorhanden;
        basis10 = genommen;
        index10 = zeilen.length;
      }

      zeilen.add(
        _ErgebnisZeile.stueckzahl(
          bezeichnung: schein.bezeichnung,
          genommen: genommen,
          vorhanden: vorhanden,
          gruen: genommen > 0 && genommen == vorhanden,
          ausgegraut: genommen == 0,
        ),
      );
    }

    // Manuelle Verschiebung Zwanziger <-> Zehner einrechnen. Die
    // Umschlag-Gesamtsumme bleibt dabei unverändert (1x20€ = 2x10€),
    // restCent (für Münzen/Restbetrag unten) muss daher nicht angepasst
    // werden.
    if (index20 != -1 && index10 != -1) {
      final int genommen20 = basis20 + _verschiebung;
      final int genommen10 = basis10 - (2 * _verschiebung);
      final bool kannMehrZwanziger =
          genommen20 < vorhanden20 && genommen10 >= 2;
      final bool kannWenigerZwanziger =
          genommen20 > 0 && vorhanden10 - genommen10 >= 2;
      final bool hatVerschiebung = _verschiebung != 0;

      zeilen[index20] = _ErgebnisZeile.stueckzahl(
        bezeichnung: bezeichnung20,
        genommen: genommen20,
        vorhanden: vorhanden20,
        gruen: genommen20 > 0 && genommen20 == vorhanden20,
        ausgegraut: genommen20 == 0,
        steuerbar: true,
        onMinus: kannWenigerZwanziger
            ? () => setState(() => _verschiebung--)
            : null,
        onPlus: kannMehrZwanziger
            ? () => setState(() => _verschiebung++)
            : null,
        wechselgeldRest: hatVerschiebung ? vorhanden20 - genommen20 : null,
      );
      zeilen[index10] = _ErgebnisZeile.stueckzahl(
        bezeichnung: bezeichnung10,
        genommen: genommen10,
        vorhanden: vorhanden10,
        gruen: genommen10 > 0 && genommen10 == vorhanden10,
        ausgegraut: genommen10 == 0,
        steuerbar: true,
        onMinus: kannMehrZwanziger
            ? () => setState(() => _verschiebung++)
            : null,
        onPlus: kannWenigerZwanziger
            ? () => setState(() => _verschiebung--)
            : null,
        wechselgeldRest: hatVerschiebung ? vorhanden10 - genommen10 : null,
      );
    }

    zeilen.add(_ErgebnisZeile.trennlinie());

    // Münzen: Kupfer und Silber aus losen Münzen summieren
    int kupferCent = 0;
    for (final String id in StueckelungKonfiguration.kupferMuenzenIds) {
      kupferCent += widget.argumente.loseMuenzenNachArtCent[id] ?? 0;
    }
    int silberCent = 0;
    for (final String id in StueckelungKonfiguration.silberMuenzenIds) {
      silberCent += widget.argumente.loseMuenzenNachArtCent[id] ?? 0;
    }

    final bool hatKupfer = kupferCent > 0;
    if (hatKupfer) {
      zeilen.add(
        _ErgebnisZeile.betragzeile(
          bezeichnung: 'Kupfergeld',
          betragCent: kupferCent,
          rot: true,
        ),
      );
      restCent -= kupferCent;
      if (restCent < 0) restCent = 0;
    }

    final int silberGenommen = restCent > 0
        ? (silberCent < restCent ? silberCent : restCent)
        : 0;
    zeilen.add(
      _ErgebnisZeile.betragzeile(
        bezeichnung: hatKupfer ? 'Münzgeld (ohne Kupfer)' : 'Münzgeld',
        betragCent: silberGenommen,
        ausgegraut: silberGenommen == 0,
      ),
    );
    restCent -= silberGenommen;

    if (restCent > 0) {
      zeilen.add(_ErgebnisZeile.restbetrag(restCent));
    }

    return zeilen;
  }

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);

  Widget _baueSteuerKnopf({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final bool aktiv = onPressed != null;
    return SizedBox(
      width: 44,
      child: Material(
        color: aktiv ? Colors.grey.shade200 : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: aktiv ? Colors.grey.shade500 : Colors.grey.shade300,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: Icon(
              icon,
              size: 14,
              color: aktiv ? Colors.grey.shade800 : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _baueZeile(_ErgebnisZeile zeile) {
    switch (zeile.art) {
      case _ZeilenArt.stueckzahl:
        final Color? grauFarbe = zeile.ausgegraut ? Colors.grey.shade400 : null;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: zeile.gruen
              ? BoxDecoration(
                  color: AppFarben.validierungErfolgsHintergrund,
                  border: Border.all(color: AppFarben.stueckelungErfolgsRand),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Text(
                    zeile.bezeichnung,
                    style: TextStyle(color: grauFarbe),
                  ),
                ),
                if (zeile.steuerbar) ...<Widget>[
                  _baueSteuerKnopf(
                    icon: Icons.remove,
                    onPressed: zeile.onMinus,
                  ),
                  const SizedBox(width: 22),
                  _baueSteuerKnopf(icon: Icons.add, onPressed: zeile.onPlus),
                ],
                SizedBox(
                  width: 40,
                  child: Text(
                    zeile.wechselgeldRest != null
                        ? '(${zeile.wechselgeldRest})'
                        : '',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey.shade600),
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
                  width: 40,
                  child: Text(
                    '/ ${zeile.vorhanden}',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: grauFarbe ?? Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        );

      case _ZeilenArt.betragzeile:
        final Color? grauFarbe = zeile.ausgegraut ? Colors.grey.shade400 : null;
        final Color? rotFarbe = zeile.rot ? AppFarben.differenzNegativ : null;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  zeile.bezeichnung,
                  style: TextStyle(
                    color: grauFarbe ?? rotFarbe,
                    fontWeight: zeile.rot ? FontWeight.bold : null,
                  ),
                ),
              ),
              const SizedBox(width: 40),
              SizedBox(
                width: 96,
                child: Text(
                  _euro(zeile.betragCent),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: grauFarbe ?? rotFarbe,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        );

      case _ZeilenArt.restbetrag:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Nicht abdeckbar: ${_euro(zeile.betragCent)}',
                style: TextStyle(
                  color: AppFarben.differenzNegativ,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Steckt vermutlich in Rollen oder Umschlägen — dort '
                'nachzählen.',
                style: TextStyle(
                  color: AppFarben.differenzNegativ,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );

      case _ZeilenArt.trennlinie:
        return Divider(
          height: 16,
          thickness: 1.5,
          color: Colors.grey.shade500,
          indent: 8,
          endIndent: 8,
        );
    }
  }

  void _zeigeSchrittSlider(BuildContext context) {
    const SchrittAuswahlBottomSheetHelper().zeigeSchrittAuswahlBottomSheet(
      context: context,
      aktuellerSchritt: 4,
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
        kinoName: widget.argumente.kinoName,
        onTap: () => _zeigeSchrittSlider(context),
        actions: <Widget>[
          const HelpButton(
            helpText:
                'Hier siehst du, wie du den Barumsatz optimal mit den '
                'verfügbaren Scheinen und Münzen stückeln kannst. '
                'Grün markierte Einheiten werden vollständig in den Umschlag gegeben. '
                'Mit den +/- Knöpfen bei den 20ern und 10ern kannst du bei Bedarf '
                'Zwanziger gegen Zehner tauschen, z. B. um Wechselgeld für den '
                'nächsten Tag zurückzubehalten.',
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <TextSpan>[
                const TextSpan(
                  text: 'Bareinnahmen Stückelung: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextSpan(
                  text: _euro(widget.argumente.barBestandAbzglWechselgeldCent),
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
                const SizedBox(width: 40),
                SizedBox(
                  width: 96,
                  child: Text(
                    'Bedarf',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 40,
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
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: AppFarben.validierungErfolgsHintergrund,
              border: Border.all(color: AppFarben.stueckelungErfolgsRand),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Grüne Zeile: Die Anzahl der Scheine im Stapel entspricht genau '
              'dem Soll-Betrag — der gesamte Stapel kann direkt in den Umschlag '
              'gelegt werden, nochmaliges Zählen entfällt.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Barumsatz und Belege in den Umschlag tun.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(
              context,
            ).popUntil(ModalRoute.withName(StartmenueSeite.routenName)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppFarben.fokusFarbe,
              foregroundColor: AppFarben.appBarRot,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Fertig.'),
          ),
        ],
      ),
    );
  }
}
