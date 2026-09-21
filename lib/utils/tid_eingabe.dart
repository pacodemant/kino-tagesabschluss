import 'package:flutter/services.dart';

// Zweck: Einzige Quelle für die Regel "eine Terminal-ID (TID) enthält keine
// Leerzeichen". Auslöser (Run 474): Ein per Hand getipptes " 60561997"
// passierte die getrimmten Prüfungen in Schritt 2 unauffällig, scheiterte
// aber beim Senden am exakten Vergleich gegen config/terminal_ids.json.
class TidEingabe {
  const TidEingabe._();

  // Whitespace (inkl. geschütztes Leerzeichen, Tab) sowie unsichtbare
  // Zero-Width-/Richtungszeichen (U+200B–U+200F, U+2060), wie sie beim
  // Einfügen aus Chat-/Notiz-Apps mitkommen können.
  static final RegExp _unerwuenscht = RegExp(r'[\s​-‏⁠]');

  /// Entfernt alle Leerzeichen und unsichtbaren Zeichen aus [tid] — auch in
  /// der Mitte, denn eine TID besteht aus einem Stück.
  static String bereinige(String tid) => tid.replaceAll(_unerwuenscht, '');

  /// Für TID-Textfelder: verhindert Leerzeichen beim Tippen und entfernt sie
  /// beim Einfügen.
  static final TextInputFormatter formatter =
      FilteringTextInputFormatter.deny(_unerwuenscht);
}
