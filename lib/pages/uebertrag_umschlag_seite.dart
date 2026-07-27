import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/haus_button.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

/// Zeigt die "Übertrag auf Umschlag"-Werte eines bereits abgeschlossenen
/// Tagesabschlusses nachträglich an — gleiches Karten-Layout wie
/// tagesabschluss_schritt3_seite.dart, aber rein lesend: kein Auto-Save,
/// kein "Kassenabrechnung senden", kein Schritt-Slider. Erreichbar über den
/// "Übertrag auf Umschlag"-Button auf der Kino-Startseite.
class UebertragUmschlagSeite extends StatelessWidget {
  const UebertragUmschlagSeite({super.key, required this.abschluss});

  static const String routenName = '/uebertrag-umschlag';

  final TagesabschlussFinal abschluss;

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);

  String _euroMitVorzeichen(int cent) =>
      TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);

  String _deutschesDatum(DateTime zeit) =>
      TagesabschlussFormatierung.deutschesDatum(zeit);

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final int differenzCent = abschluss.differenzGesamtCent;
    final Color differenzFarbe =
        differenzCent >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    return Scaffold(
      backgroundColor: AppFarben.seitenHintergrund,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: const Text(
          'Übertrag auf Umschlag',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: AppFarben.footerDecoration,
        padding: EdgeInsets.fromLTRB(12, 4, 12, 4 + bottomPadding),
        child: const SizedBox(
          height: 36,
          child: Align(
            alignment: Alignment.centerLeft,
            child: HausButton(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Expanded(
                  child: Text(
                    abschluss.kinoName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                Text(
                  _deutschesDatum(abschluss.datum),
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
                    wert: _euro(abschluss.differenzAnfangsbestandCent),
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
                    wert: _euro(abschluss.kinoSollCent),
                    stil: InfoZeileStil.fuehrungslinie,
                  ),
                  if (abschluss.kinoId != 'kino_04')
                    InfoZeile(
                      label: '+ Bistro Soll',
                      wert: _euro(abschluss.bistroSollCent),
                      stil: InfoZeileStil.fuehrungslinie,
                    ),
                  InfoZeile(
                    label: '- Ausgaben',
                    wert: _euro(abschluss.ausgabenCent),
                    stil: InfoZeileStil.fuehrungslinie,
                  ),
                  InfoZeile(
                    label: '= Gesamt Soll',
                    wert: _euro(abschluss.gesamtSollCent),
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
                    wert: _euro(abschluss.ecUmsatzGesamtCent),
                    stil: InfoZeileStil.fuehrungslinie,
                  ),
                  InfoZeile(
                    label: '+ bar IST',
                    wert: _euro(abschluss.barBestandAbzglWechselgeldCent),
                    stil: InfoZeileStil.fuehrungslinie,
                  ),
                  InfoZeile(
                    label: '= Gesamt IST',
                    wert: _euro(abschluss.gesamtIstCent),
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
        ],
      ),
    );
  }
}
