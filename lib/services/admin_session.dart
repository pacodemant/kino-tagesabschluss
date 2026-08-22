class AdminSession {
  const AdminSession._();

  /// Bleibt für die Laufzeit der App-Session gesetzt (bis Reload), sobald
  /// der Admin-PIN einmal korrekt eingegeben wurde (siehe
  /// EinstellungenSeite._zeigePinDialog()). Zentral hier statt privat in
  /// der Einstellungen-Seite, damit auch andere PIN-gated Bereiche
  /// (z. B. Verlauf-Löschen) darauf zugreifen können.
  static bool entsperrt = false;
}
