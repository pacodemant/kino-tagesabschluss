import 'package:kino_bar_app/utils/datums_helper.dart';

class AdminSession {
  const AdminSession._();

  static String? _entsperrtAmGeschaeftstag;

  /// Bleibt gesetzt, sobald der Admin-PIN einmal korrekt eingegeben wurde
  /// (siehe EinstellungenSeite._zeigePinDialog()) — aber nur bis zum
  /// nächsten Tagesknick (Geschäftstag-Cutoff, siehe DatumsHelper) bzw.
  /// bis zum Reload. Wird bei jedem Lesen gegen den aktuellen
  /// Geschäftstag geprüft, daher kein Timer nötig. Zentral hier statt
  /// privat in der Einstellungen-Seite, damit auch andere PIN-gated
  /// Bereiche (z. B. Verlauf-Löschen) darauf zugreifen können.
  static bool get entsperrt => istEntsperrt();

  static set entsperrt(bool wert) {
    if (wert) {
      entsperren();
    } else {
      _entsperrtAmGeschaeftstag = null;
    }
  }

  static bool istEntsperrt({DateTime? jetzt}) =>
      _entsperrtAmGeschaeftstag != null &&
      _entsperrtAmGeschaeftstag == DatumsHelper.logischesIsoDatum(jetzt: jetzt);

  static void entsperren({DateTime? jetzt}) {
    _entsperrtAmGeschaeftstag = DatumsHelper.logischesIsoDatum(jetzt: jetzt);
  }
}
