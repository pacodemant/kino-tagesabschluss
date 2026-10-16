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

  /// Dev-Auto-Fill (Run 491): verteilt die EC-Testsumme gleichmäßig auf
  /// [anzahl] Terminals, der Rest-Cent geht an das erste. Mindestens ein
  /// Anteil, auch ohne eingetragene Terminals.
  static List<int> devAufteilung(int gesamtCent, int anzahl) {
    final int n = anzahl < 1 ? 1 : anzahl;
    final int basis = gesamtCent ~/ n;
    return <int>[
      for (int i = 0; i < n; i++) i == 0 ? gesamtCent - basis * (n - 1) : basis,
    ];
  }
}
