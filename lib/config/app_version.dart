// Zweck: Einzige Quelle für den Versionsstring, der auf Kinoauswahl- und
// Startmenü-Seite angezeigt wird. Vorher an beiden Stellen als
// String-Literal dupliziert (Risiko: eine Stelle wird bei einem Run
// vergessen zu aktualisieren).
class AppVersion {
  const AppVersion._();

  static const String text = 'Web App 0.9.78 · r406';
}
