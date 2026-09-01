import 'dart:convert';

import 'package:flutter/services.dart';

/// Laedt die pro Standort registrierten Flurbocash-Terminal-IDs aus
/// config/terminal_ids.json. Liefert eine Map von Kino-Kuerzel (z.B. "SB")
/// auf die Liste der dort erlaubten TIDs.
class TerminalIdsConfigService {
  static const String _assetPath = 'config/terminal_ids.json';

  static Future<Map<String, List<String>>> laden() async {
    final String inhalt = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> map =
        json.decode(inhalt) as Map<String, dynamic>;
    final Map<String, List<String>> ergebnis = <String, List<String>>{};
    for (final MapEntry<String, dynamic> eintrag in map.entries) {
      if (eintrag.key.startsWith('_')) continue;
      final Map<String, dynamic> kino = eintrag.value as Map<String, dynamic>;
      final List<dynamic> tids = kino['terminal_ids'] as List<dynamic>? ??
          const <dynamic>[];
      // Jeder Eintrag ist ein Objekt {"tid": "...", "kommentar": "..."} —
      // "kommentar" ist rein dokumentarisch (z. B. "alte TID"/"neue TID")
      // und wird hier bewusst nicht ausgelesen.
      ergebnis[eintrag.key] = tids
          .map((dynamic e) => (e as Map<String, dynamic>)['tid'] as String)
          .toList();
    }
    return ergebnis;
  }

  /// Liefert die als "aktiv" geltende TID fuer ein Kino-Kuerzel (z.B. "SB")
  /// aus einer bereits geladenen Konfiguration — Konvention (Paco-
  /// Entscheidung 2026-08-30, siehe TODO.md "Auto-Fill: konfigurierte TID
  /// pro Standort"): der erste Eintrag der Liste gilt als aktiv, weitere
  /// Eintraege sind Ersatz-/Zukunftsgeraete. Leerer String, wenn kein
  /// Standort/keine TID hinterlegt ist.
  static String aktiveTid(
    String? kinoKuerzel,
    Map<String, List<String>> konfiguration,
  ) {
    final List<String> tids = konfiguration[kinoKuerzel] ?? const <String>[];
    return tids.isNotEmpty ? tids.first : '';
  }
}
