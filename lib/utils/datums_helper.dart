class DatumsHelper {
  const DatumsHelper._();

  /// Abschluss vor dieser Uhrzeit zaehlt noch als Vortag (Spaetvorstellungen
  /// enden teils nach Mitternacht, der Geschaeftstag laeuft aber weiter).
  /// Einzige Quelle fuer diese Regel — auch fuer
  /// TagesabschlussFinalisierenUsecase.finalisieren(). Seit Run 402 5 Uhr
  /// (vorher 6 Uhr) — von Yannik fuer Flurbocash bestaetigt.
  static const int _geschaeftstagCutoffStunde = 5;

  /// Ab dieser Uhrzeit gilt der Tag fuer die Wechselgeldpruefung als
  /// "Abend" (bis zum Geschaeftstag-Cutoff, siehe [istAbendzeitraum]).
  static const int _abendBeginnStunde = 18;

  /// [jetzt] optional fuer deterministische Tests, sonst DateTime.now().
  static DateTime logischerAbrechnungsTag({DateTime? jetzt}) {
    final DateTime now = jetzt ?? DateTime.now();
    final DateTime kalendertag = DateTime(now.year, now.month, now.day);
    if (now.hour < _geschaeftstagCutoffStunde) {
      return kalendertag.subtract(const Duration(days: 1));
    }
    return kalendertag;
  }

  /// Ob [jetzt] im Abendzeitraum liegt: ab 18 Uhr bis zum naechsten
  /// Geschaeftstag-Cutoff (5 Uhr). Nachts zwischen 0 und 5 Uhr laeuft der
  /// Geschaeftstag noch (siehe [logischerAbrechnungsTag]), zaehlt also noch
  /// zum Abend.
  static bool istAbendzeitraum({DateTime? jetzt}) {
    final int stunde = (jetzt ?? DateTime.now()).hour;
    return stunde >= _abendBeginnStunde || stunde < _geschaeftstagCutoffStunde;
  }

  static String isoDatum(DateTime datum) =>
      '${datum.year}-${datum.month.toString().padLeft(2, '0')}-'
      '${datum.day.toString().padLeft(2, '0')}';

  static String logischesIsoDatum({DateTime? jetzt}) {
    final DateTime tag = logischerAbrechnungsTag(jetzt: jetzt);
    return isoDatum(tag);
  }

  /// Ob [links] und [rechts] auf denselben Kalendertag fallen (Jahr/Monat/
  /// Tag, Uhrzeit wird ignoriert). Einzige Quelle seit Run 425 — vorher an
  /// 3 Stellen unabhaengig als Jahr/Monat/Tag-Vergleich nachgebaut
  /// (SpeichereTagesabschlussUsecase, LokalerSpeicher.
  /// ersetzeFinalenTagesabschluss/loescheFinalenTagesabschluss).
  static bool istGleicherKalendertag(DateTime links, DateTime rechts) {
    return links.year == rechts.year &&
        links.month == rechts.month &&
        links.day == rechts.day;
  }
}
