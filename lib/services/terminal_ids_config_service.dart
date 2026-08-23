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
      ergebnis[eintrag.key] = tids.cast<String>();
    }
    return ergebnis;
  }
}
