import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_soll_section.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

/// "Übertrag auf Umschlag"-Kachel im Verlauf-Detail (Run 487): zeigt die
/// Werte eines gespeicherten Abschlusses in der Reihenfolge des
/// Papier-Umschlags, damit ein vergessener Übertrag nachgetragen werden
/// kann. EC IST je Terminal einzeln (EC1, EC2, EC3 …) wie auf dem neuen
/// SB-Umschlag, in der Reihenfolge der erfassten Belege, mit TID darunter.
/// Rein lesend, keine Berechnung außer der Aufteilung der EC-Belege.
class UebertragUmschlagKachel extends StatelessWidget {
  const UebertragUmschlagKachel({super.key, required this.abschluss});

  final TagesabschlussFinal abschluss;

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);

  /// Einzelne EC-Zeilen nur, wenn die Belege zur gespeicherten EC-Summe
  /// passen — sonst (z. B. alte Einträge ohne Einzelbelege) eine
  /// Sammelzeile, damit die Summe auf dem Umschlag immer stimmt.
  List<Widget> _ecZeilen() {
    final List<int> belege = abschluss.ecBelegeCent;
    final int summe = belege.fold(0, (int s, int b) => s + b);
    if (belege.isEmpty || summe != abschluss.ecUmsatzGesamtCent) {
      return <Widget>[
        InfoZeile(
          label: '+ EC IST',
          wert: _euro(abschluss.ecUmsatzGesamtCent),
          stil: InfoZeileStil.fuehrungslinie,
        ),
      ];
    }
    final List<String>? labels = abschluss.ecBelegeLabels;
    final List<Widget> zeilen = <Widget>[];
    for (int i = 0; i < belege.length; i++) {
      zeilen.add(
        InfoZeile(
          label: '+ EC${i + 1} IST',
          wert: _euro(belege[i]),
          stil: InfoZeileStil.fuehrungslinie,
        ),
      );
      final String tid = labels != null && i < labels.length ? labels[i] : '';
      if (tid.isNotEmpty) zeilen.add(_grauZeile('TID $tid'));
    }
    return zeilen;
  }

  Widget _grauZeile(String text) {
    // Align: ExpansionTile zentriert seine children sonst.
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TagesabschlussFinal a = abschluss;
    final bool hatBistro = KinoRepository.nachId(a.kinoId)?.hatBistro ?? true;
    final Color differenzFarbe = a.differenzGesamtCent >= 0
        ? Colors.green.shade700
        : Colors.red.shade700;
    final String? name =
        a.mitarbeiterName != null && a.mitarbeiterName!.isNotEmpty
        ? a.mitarbeiterName
        : null;

    return Card(
      child: ExpansionTile(
        title: const Text(
          'Übertrag auf Umschlag',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: false,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: <Widget>[
          InfoZeile(
            label: 'Differenz im Anfangsbestand',
            wert: _euro(a.differenzAnfangsbestandCent),
            stil: InfoZeileStil.fuehrungslinie,
          ),
          const Divider(),
          InfoZeile(
            label: hatBistro ? '+ KINO SOLL' : '+ Gesamt SOLL',
            wert: _euro(a.kinoSollUebertragCent),
            stil: InfoZeileStil.fuehrungslinie,
          ),
          if (a.kinokasseKarteCent != 0)
            KinokasseKarteHinweis(kinokasseKarteCent: a.kinokasseKarteCent),
          if (hatBistro)
            InfoZeile(
              label: '+ BISTRO SOLL',
              wert: _euro(a.bistroSollCent),
              stil: InfoZeileStil.fuehrungslinie,
            ),
          InfoZeile(
            label: '- Ausgaben',
            wert: _euro(a.ausgabenCent),
            stil: InfoZeileStil.fuehrungslinie,
          ),
          InfoZeile(
            label: '= Gesamt SOLL',
            wert: _euro(a.gesamtSollCent),
            fett: true,
            stil: InfoZeileStil.fuehrungslinie,
          ),
          const Divider(),
          ..._ecZeilen(),
          InfoZeile(
            label: '+ BAR IST',
            wert: _euro(a.barBestandAbzglWechselgeldCent),
            stil: InfoZeileStil.fuehrungslinie,
          ),
          InfoZeile(
            label: '= Gesamt IST',
            wert: _euro(a.gesamtIstCent),
            fett: true,
            stil: InfoZeileStil.fuehrungslinie,
          ),
          const Divider(),
          InfoZeile(
            label: 'Differenz',
            wert: TagesabschlussFormatierung.formatiereEuroMitVorzeichen(
              a.differenzGesamtCent,
            ),
            fett: true,
            farbe: differenzFarbe,
            stil: InfoZeileStil.fuehrungslinie,
          ),
          const Divider(),
          if (name != null)
            InfoZeile(
              label: 'Name',
              wert: name,
              stil: InfoZeileStil.fuehrungslinie,
            ),
          InfoZeile(
            label: 'Datum',
            wert: TagesabschlussFormatierung.deutschesDatum(a.datum),
            stil: InfoZeileStil.fuehrungslinie,
          ),
        ],
      ),
    );
  }
}
