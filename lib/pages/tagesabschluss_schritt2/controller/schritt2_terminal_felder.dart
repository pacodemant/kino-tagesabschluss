import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/utils/tid_eingabe.dart';

/// Reine Regeln für EC-Felder je Terminal in Schritt 2 (Run 490), ohne
/// Widget-Zustand, damit sie direkt testbar sind.
class Schritt2TerminalFelder {
  const Schritt2TerminalFelder._();

  /// true = Feld eines eingetragenen Terminals ohne erfassten Beleg: TID
  /// vorausgefüllt, kein Betrag, kein Scan, kein Gesamtbetrag getippt.
  /// Nur im Mehrbeleg-Modus — ein einzelnes Feld bleibt Pflichtfeld.
  static bool istLeererTerminalPlatz({
    required List<TerminalEintrag> terminals,
    required int feldAnzahl,
    required String label,
    required int betragCent,
    required bool gescannt,
    required String gesamtBetragText,
  }) {
    if (terminals.isEmpty || feldAnzahl <= 1) return false;
    final String tid = TidEingabe.bereinige(label);
    return tid.isNotEmpty &&
        terminals.any((TerminalEintrag t) => t.tid == tid) &&
        betragCent == 0 &&
        !gescannt &&
        gesamtBetragText.trim().isEmpty;
  }

  /// Ziel-Feld für einen gescannten Beleg: das noch leere Feld mit
  /// derselben TID, egal welches Feld gerade offen war. Sonst bleibt es
  /// beim angetippten Feld [belegIndex] (bisheriges Verhalten).
  static int zielIndex({
    required String? gescannteTid,
    required int belegIndex,
    required List<String> labels,
    required bool Function(int j) istLeer,
  }) {
    final String tid = TidEingabe.bereinige(gescannteTid ?? '');
    if (tid.isEmpty) return belegIndex;
    for (int j = 0; j < labels.length; j++) {
      if (TidEingabe.bereinige(labels[j]) == tid && istLeer(j)) return j;
    }
    return belegIndex;
  }

  /// Dev-Auto-Fill (Run 491, ungleich seit 492a): verteilt die EC-
  /// Testsumme nach festen, deutlich verschiedenen Gewichten auf [anzahl]
  /// Terminals, der Rest-Cent geht an das erste. Mindestens ein Anteil,
  /// auch ohne eingetragene Terminals.
  static List<int> devAufteilung(int gesamtCent, int anzahl) {
    const List<int> gewichte = <int>[9, 5, 3, 2];
    final int n = anzahl < 1 ? 1 : anzahl;
    final List<int> g = <int>[
      for (int i = 0; i < n; i++) gewichte[i % gewichte.length],
    ];
    final int summeGewichte = g.fold(0, (int s, int x) => s + x);
    final List<int> anteile = <int>[
      for (int i = 0; i < n; i++) gesamtCent * g[i] ~/ summeGewichte,
    ];
    final int rest = gesamtCent - anteile.fold(0, (int s, int x) => s + x);
    anteile[0] += rest;
    return anteile;
  }

  /// Dev-Auto-Fill (Run 492a): je Beleg ein anderer Kartenmix (Prozent),
  /// der Rest-Cent geht an Girocard, Summe = [betragCent].
  static Map<String, int> devKartenAufteilung(int betragCent, int belegIndex) {
    const List<Map<String, int>> muster = <Map<String, int>>[
      <String, int>{'Girocard': 60, 'MasterCard': 25, 'Visa': 15},
      <String, int>{'Girocard': 70, 'Maestro': 30},
      <String, int>{'Girocard': 45, 'Visa': 35, 'V Pay': 20},
      <String, int>{'Girocard': 80, 'SEPA Lastschrift': 20},
    ];
    final Map<String, int> prozent = muster[belegIndex % muster.length];
    final Map<String, int> ergebnis = <String, int>{
      for (final MapEntry<String, int> e in prozent.entries)
        if (e.key != 'Girocard') e.key: betragCent * e.value ~/ 100,
    };
    ergebnis['Girocard'] =
        betragCent - ergebnis.values.fold(0, (int s, int x) => s + x);
    return ergebnis;
  }
}
