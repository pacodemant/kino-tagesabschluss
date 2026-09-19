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

  /// Wechselgeldentnahme, die in der Wechselgeldprüfung gilt.
  /// Abend-Prüfung: automatisch die Entnahme des heutigen Abschlusses (die
  /// Abrechnung hat sie gerade erfasst). Morgen-Prüfung: nur, wenn der MA
  /// den Schalter "Notiz gefunden" aktiviert und den Betrag selbst
  /// eingetragen hat — die App kann nicht wissen, ob das Geld schon wieder
  /// zurückgelegt wurde. Nur Beträge > 0 zählen.
  static int wirksameEntnahmeCent({
    required bool abend,
    required int abendAutomatischCent,
    required bool morgenAktiv,
    required int morgenCent,
  }) {
    final int cent = abend
        ? abendAutomatischCent
        : (morgenAktiv ? morgenCent : 0);
    return cent > 0 ? cent : 0;
  }

  /// Sollwert für den Vergleich mit dem gezählten Wechselgeld: die
  /// Wechselgeldentnahme fehlt physisch in der Kasse, senkt also den
  /// erwarteten Bestand. Nie negativ.
  static int wirksamerSollwertCent({
    required int sollwertCent,
    required int entnahmeCent,
  }) {
    final int rest = sollwertCent - entnahmeCent;
    return rest > 0 ? rest : 0;
  }
}
