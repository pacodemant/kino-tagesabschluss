/// Ergebnis der Plausibilitätsprüfung einer Wechselgeldentnahme.
enum WechselgeldentnahmeFehler { keiner, betragFehlt, grundFehlt, beidesFehlt }

/// Reine Regeln rund um den Schalter "Wechselgeldentnahme" in Schritt 1
/// (ausgelagert, damit sie ohne UI testbar sind).
class WechselgeldentnahmeRegeln {
  const WechselgeldentnahmeRegeln._();

  /// Der Schalterstand wird nicht separat gespeichert, sondern beim
  /// Wiederherstellen eines Entwurfs aus den Werten abgeleitet: an, sobald
  /// Betrag oder Grund gefüllt sind.
  static bool aktivAusEntwurf({
    required int betragCent,
    required String grund,
  }) {
    return betragCent > 0 || grund.trim().isNotEmpty;
  }

  /// Bei ausgeschaltetem Schalter gibt es nichts zu prüfen (die Werte sind
  /// dann ohnehin geleert). Bei eingeschaltetem Schalter müssen Betrag und
  /// Grund beide gesetzt sein.
  static WechselgeldentnahmeFehler pruefe({
    required bool aktiv,
    required int betragCent,
    required String grund,
  }) {
    if (!aktiv) {
      return WechselgeldentnahmeFehler.keiner;
    }
    final bool hatBetrag = betragCent > 0;
    final bool hatGrund = grund.trim().isNotEmpty;
    if (hatBetrag && hatGrund) {
      return WechselgeldentnahmeFehler.keiner;
    }
    if (!hatBetrag && !hatGrund) {
      return WechselgeldentnahmeFehler.beidesFehlt;
    }
    return hatBetrag
        ? WechselgeldentnahmeFehler.grundFehlt
        : WechselgeldentnahmeFehler.betragFehlt;
  }
}
