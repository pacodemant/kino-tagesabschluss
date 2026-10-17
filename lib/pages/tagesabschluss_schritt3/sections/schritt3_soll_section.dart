import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_info_card.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

class Schritt3SollSection extends StatelessWidget {
  const Schritt3SollSection({
    super.key,
    required this.kinoSollCent,
    this.kinokasseKarteCent = 0,
    required this.bistroSollCent,
    required this.zeigeBistroSoll,
    required this.ausgabenCent,
    required this.gesamtSollCent,
  });

  // Kino SOLL fuer den Uebertrag, inkl. kinokasseKarteCent (Run 486).
  final int kinoSollCent;
  final int kinokasseKarteCent;
  final int bistroSollCent;
  final bool zeigeBistroSoll;
  final int ausgabenCent;
  final int gesamtSollCent;

  @override
  Widget build(BuildContext context) {
    return Schritt3InfoCard(
      zeilen: <Widget>[
        InfoZeile(
          // Ohne Bistro (zeigeBistroSoll == false) enthaelt dieser Wert
          // bereits das komplette SOLL fuer dieses Kino (siehe
          // tagesabschluss_schritt2_seite.dart._hatBistro) — Label
          // spiegelt das, wie schon bei der Eingabe in Schritt 2.
          label: zeigeBistroSoll ? '+ Kino Soll' : '+ Gesamt SOLL',
          wert: TagesabschlussFormatierung.formatiereEuro(kinoSollCent),
          stil: InfoZeileStil.fuehrungslinie,
        ),
        if (kinokasseKarteCent != 0)
          KinokasseKarteHinweis(kinokasseKarteCent: kinokasseKarteCent),
        if (zeigeBistroSoll)
          InfoZeile(
            label: '+ Bistro Soll',
            wert: TagesabschlussFormatierung.formatiereEuro(bistroSollCent),
            stil: InfoZeileStil.fuehrungslinie,
          ),
        InfoZeile(
          label: '- Ausgaben',
          wert: TagesabschlussFormatierung.formatiereEuro(ausgabenCent),
          stil: InfoZeileStil.fuehrungslinie,
        ),
        InfoZeile(
          label: '= Gesamt Soll',
          wert: TagesabschlussFormatierung.formatiereEuro(gesamtSollCent),
          fett: true,
          stil: InfoZeileStil.fuehrungslinie,
        ),
      ],
    );
  }
}

/// Kleine graue "davon"-Zeile unter dem Kino Soll (Run 486): macht
/// sichtbar, warum das Kino Soll im Uebertrag vom in Schritt 2
/// eingegebenen Wert abweicht. Auch von uebertrag_umschlag_seite.dart und
/// verlauf_detail_seite.dart genutzt.
class KinokasseKarteHinweis extends StatelessWidget {
  const KinokasseKarteHinweis({
    super.key,
    required this.kinokasseKarteCent,
    this.terminalTid,
  });

  final int kinokasseKarteCent;

  /// SB (Run 493c): TID des KK-Terminals aus den Einstellungen, Text dann
  /// "davon Kartenterminal TID" ('' = keins markiert). null = bisheriger
  /// Text für die übrigen Standorte.
  final String? terminalTid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              terminalTid == null
                  ? 'davon Karte Kinokasse'
                  : 'davon Kartenterminal $terminalTid'.trimRight(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Text(
            TagesabschlussFormatierung.formatiereEuro(kinokasseKarteCent),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
