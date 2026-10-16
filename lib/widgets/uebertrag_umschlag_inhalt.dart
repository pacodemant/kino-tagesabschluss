import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_soll_section.dart';
import 'package:kino_bar_app/utils/tid_eingabe.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';

/// Eine EC-Zeile des Umschlags.
class UmschlagEcZeile {
  const UmschlagEcZeile(this.label, this.cent, [this.info = '']);

  final String label;
  final int cent;

  /// Graue Zusatzzeile (Gerät/TID), leer = keine.
  final String info;
}

/// Einzige Quelle für den Inhalt von "Übertrag auf Umschlag" (Run 489),
/// genutzt von uebertrag_umschlag_seite.dart (je Rahmen eine Card) und
/// uebertrag_umschlag_kachel.dart (Verlauf, Rahmen durch Linien getrennt).
/// SB hat seit Oktober 2026 einen eigenen Umschlag (EC1–EC3 je Terminal,
/// Name, Datum); die übrigen Standorte behalten das bisherige Layout, da
/// deren Umschläge jeweils anders aussehen.
class UebertragUmschlagInhalt {
  const UebertragUmschlagInhalt._();

  static bool hatSbUmschlag(String kinoId) =>
      KinoRepository.nachId(kinoId)?.kuerzel == 'SB';

  /// EC-Zeilen für den SB-Umschlag: EC1, EC2, … nach Platz der Terminals in
  /// den Einstellungen (Paco-Entscheidung 2026-10-16), Summe aller Belege
  /// dieser TID, auch 0,00 € (Feld auf dem Umschlag). Belege mit einer
  /// nicht eingetragenen TID kommen als zusätzliche Zeile dazu, damit die
  /// Summe stimmt. Ohne eingetragene Terminals: Reihenfolge der Belege.
  /// Passen die Belege nicht zur gespeicherten EC-Summe (alte Einträge):
  /// eine Sammelzeile.
  static List<UmschlagEcZeile> ecZeilenSb(
    TagesabschlussFinal a,
    List<TerminalEintrag> terminals,
  ) {
    final List<int> belege = a.ecBelegeCent;
    final int summe = belege.fold(0, (int s, int b) => s + b);
    // Run 492: bestätigt "heute keine Umsätze".
    final Set<String> keine = <String>{...?a.keineUmsaetzeTids};
    String mitKeine(String info, String tid, int cent) =>
        cent == 0 && keine.contains(tid)
        ? '${info.isEmpty ? '' : '$info · '}keine Umsätze'
        : info;
    if (belege.isEmpty || summe != a.ecUmsatzGesamtCent) {
      return <UmschlagEcZeile>[
        UmschlagEcZeile('+ EC IST', a.ecUmsatzGesamtCent),
      ];
    }
    final List<String> labels = <String>[
      for (int i = 0; i < belege.length; i++)
        TidEingabe.bereinige(
          a.ecBelegeLabels != null && i < a.ecBelegeLabels!.length
              ? a.ecBelegeLabels![i]
              : '',
        ),
    ];

    if (terminals.isEmpty) {
      return <UmschlagEcZeile>[
        for (int i = 0; i < belege.length; i++)
          UmschlagEcZeile(
            '+ EC${i + 1} IST',
            belege[i],
            mitKeine(
              labels[i].isEmpty ? '' : 'TID ${labels[i]}',
              labels[i],
              belege[i],
            ),
          ),
      ];
    }

    final List<UmschlagEcZeile> zeilen = <UmschlagEcZeile>[];
    final Set<int> zugeordnet = <int>{};
    for (int p = 0; p < terminals.length; p++) {
      final TerminalEintrag t = terminals[p];
      int cent = 0;
      for (int i = 0; i < belege.length; i++) {
        if (labels[i] == t.tid) {
          cent += belege[i];
          zugeordnet.add(i);
        }
      }
      zeilen.add(
        UmschlagEcZeile(
          '+ EC${p + 1} IST',
          cent,
          mitKeine(
            '${t.nummer.isEmpty ? '' : 'Gerät ${t.nummer} · '}TID ${t.tid}',
            t.tid,
            cent,
          ),
        ),
      );
    }
    for (int i = 0; i < belege.length; i++) {
      if (zugeordnet.contains(i)) continue;
      zeilen.add(
        UmschlagEcZeile(
          '+ EC IST',
          belege[i],
          labels[i].isEmpty
              ? 'ohne TID'
              : 'TID ${labels[i]} (nicht in Einstellungen)',
        ),
      );
    }
    return zeilen;
  }

  static String _euro(int cent) =>
      TagesabschlussFormatierung.formatiereEuro(cent);

  static Widget _zeile(String label, String wert, {bool fett = false}) =>
      InfoZeile(
        label: label,
        wert: wert,
        fett: fett,
        stil: InfoZeileStil.fuehrungslinie,
      );

  static Widget _grauZeile(String text) {
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

  /// Inhalt in Rahmen gegliedert (je Rahmen eine Liste von Zeilen).
  static List<List<Widget>> rahmen(
    TagesabschlussFinal a,
    List<TerminalEintrag> terminals,
  ) {
    final bool hatBistro = KinoRepository.nachId(a.kinoId)?.hatBistro ?? true;
    final bool sb = hatSbUmschlag(a.kinoId);
    final Widget differenz = InfoZeile(
      label: sb ? 'Differenz' : 'Differenz\nKassenabrechnung',
      wert: TagesabschlussFormatierung.formatiereEuroMitVorzeichen(
        a.differenzGesamtCent,
      ),
      fett: true,
      farbe: a.differenzGesamtCent >= 0
          ? Colors.green.shade700
          : Colors.red.shade700,
      stil: InfoZeileStil.fuehrungslinie,
    );

    if (!sb) {
      return <List<Widget>>[
        <Widget>[
          _zeile(
            'Differenz Anfangsbestand',
            _euro(a.differenzAnfangsbestandCent),
          ),
        ],
        <Widget>[
          _zeile(
            hatBistro ? '+ Kino Soll' : '+ Gesamt SOLL',
            _euro(a.kinoSollUebertragCent),
          ),
          if (a.kinokasseKarteCent != 0)
            KinokasseKarteHinweis(kinokasseKarteCent: a.kinokasseKarteCent),
          if (hatBistro) _zeile('+ Bistro Soll', _euro(a.bistroSollCent)),
          _zeile('- Ausgaben', _euro(a.ausgabenCent)),
          _zeile('= Gesamt Soll', _euro(a.gesamtSollCent), fett: true),
        ],
        <Widget>[
          _zeile('+ EC IST', _euro(a.ecUmsatzGesamtCent)),
          _zeile('+ bar IST', _euro(a.barBestandAbzglWechselgeldCent)),
          _zeile('= Gesamt IST', _euro(a.gesamtIstCent), fett: true),
        ],
        <Widget>[differenz],
      ];
    }

    final String? name =
        a.mitarbeiterName != null && a.mitarbeiterName!.isNotEmpty
        ? a.mitarbeiterName
        : null;
    return <List<Widget>>[
      <Widget>[
        _zeile(
          'Differenz im Anfangsbestand',
          _euro(a.differenzAnfangsbestandCent),
        ),
      ],
      <Widget>[
        _zeile('+ KINO SOLL', _euro(a.kinoSollUebertragCent)),
        if (a.kinokasseKarteCent != 0)
          KinokasseKarteHinweis(kinokasseKarteCent: a.kinokasseKarteCent),
        _zeile('+ BISTRO SOLL', _euro(a.bistroSollCent)),
        _zeile('- Ausgaben', _euro(a.ausgabenCent)),
        _zeile('= Gesamt SOLL', _euro(a.gesamtSollCent), fett: true),
      ],
      <Widget>[
        for (final UmschlagEcZeile z in ecZeilenSb(a, terminals)) ...<Widget>[
          _zeile(z.label, _euro(z.cent)),
          if (z.info.isNotEmpty) _grauZeile(z.info),
        ],
        _zeile('+ BAR IST', _euro(a.barBestandAbzglWechselgeldCent)),
        _zeile('= Gesamt IST', _euro(a.gesamtIstCent), fett: true),
      ],
      <Widget>[differenz],
      // Datum steht schon im Kopf bzw. in der Titelleiste (Run 492b).
      if (name != null) <Widget>[_zeile('Name', name)],
    ];
  }
}
