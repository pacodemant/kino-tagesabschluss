class DatumsHelper {
  const DatumsHelper._();

  /// Abschluss vor dieser Uhrzeit zaehlt noch als Vortag (Spaetvorstellungen
  /// enden teils nach Mitternacht, der Geschaeftstag laeuft aber weiter).
  /// Einzige Quelle fuer diese Regel — auch fuer
  /// TagesabschlussFinalisierenUsecase.finalisieren().
  static const int _geschaeftstagCutoffStunde = 6;

  /// [jetzt] optional fuer deterministische Tests, sonst DateTime.now().
  static DateTime logischerAbrechnungsTag({DateTime? jetzt}) {
    final DateTime now = jetzt ?? DateTime.now();
    final DateTime kalendertag = DateTime(now.year, now.month, now.day);
    if (now.hour < _geschaeftstagCutoffStunde) {
      return kalendertag.subtract(const Duration(days: 1));
    }
    return kalendertag;
  }

  static String isoDatum(DateTime datum) =>
      '${datum.year}-${datum.month.toString().padLeft(2, '0')}-'
      '${datum.day.toString().padLeft(2, '0')}';

  static String logischesIsoDatum({DateTime? jetzt}) {
    final DateTime tag = logischerAbrechnungsTag(jetzt: jetzt);
    return isoDatum(tag);
  }
}
