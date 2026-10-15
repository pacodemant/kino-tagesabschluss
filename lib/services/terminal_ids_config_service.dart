import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Laedt die pro Standort registrierten Flurbocash-Terminal-IDs aus
/// config/terminal_ids.json. Liefert eine Map von Kino-Kuerzel (z.B. "SB")
/// auf die Liste der dort erlaubten TIDs.
class TerminalIdsConfigService {
  static const String _assetPath = 'config/terminal_ids.json';

  /// SharedPreferences-Key der TID des Terminals, das direkt am Kino-
  /// Kassensystem haengt (Run 486, bisher nur SB). Pro Kino wie
  /// location_id, bewusst nicht im Code/Asset (Yannik: keine TIDs im
  /// Code). Leer/nicht gesetzt = kein solches Terminal.
  static String kinokasseTidPrefKey(String kinoId) => 'kinokasse_tid_$kinoId';

  static Future<String> ladeKinokasseTid(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    return speicher.getString(kinokasseTidPrefKey(kinoId))?.trim() ?? '';
  }

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
      ergebnis[eintrag.key] = tids.cast<String>();
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
