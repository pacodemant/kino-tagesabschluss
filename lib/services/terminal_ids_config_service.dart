import 'dart:convert';

import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/utils/tid_eingabe.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Liest und speichert die Kartenterminals (TID, Nummer, "KK connected")
/// eines Standorts. Seit Run 488 pro Gerät in den Einstellungen (Kachel
/// "TIDs") statt in config/terminal_ids.json — Yannik: keine TIDs im Code.
/// Kein Terminal eingetragen = keine TID-Prüfung auf diesem Gerät.
class TerminalIdsConfigService {
  const TerminalIdsConfigService._();

  static const int maxTerminals = 4;

  /// SharedPreferences-Key der Terminal-Liste (JSON) pro Kino.
  static String terminalsPrefKey(String kinoId) => 'terminals_$kinoId';

  /// Alt-Key aus Run 486 (nur die Kinokassen-TID). Wird nur noch gelesen,
  /// solange die neue Liste fehlt, und beim ersten Speichern entfernt.
  static String kinokasseTidPrefKey(String kinoId) => 'kinokasse_tid_$kinoId';

  static Future<List<TerminalEintrag>> ladeTerminals(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String? roh = speicher.getString(terminalsPrefKey(kinoId));
    if (roh != null) {
      try {
        return (jsonDecode(roh) as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(TerminalEintrag.fromJson)
            .where((TerminalEintrag t) => t.tid.isNotEmpty)
            .toList();
      } catch (_) {
        return <TerminalEintrag>[];
      }
    }
    final String altKinokasse = TidEingabe.bereinige(
      speicher.getString(kinokasseTidPrefKey(kinoId)) ?? '',
    );
    if (altKinokasse.isEmpty) return <TerminalEintrag>[];
    return <TerminalEintrag>[
      TerminalEintrag(tid: altKinokasse, kinokasse: true),
    ];
  }

  /// Speichert nur Einträge mit TID (bereinigt), höchstens [maxTerminals].
  static Future<void> speichereTerminals(
    String kinoId,
    List<TerminalEintrag> terminals,
  ) async {
    final List<TerminalEintrag> bereinigt = terminals
        .map(
          (TerminalEintrag t) => TerminalEintrag(
            tid: TidEingabe.bereinige(t.tid),
            nummer: t.nummer.trim(),
            kinokasse: t.kinokasse,
          ),
        )
        .where((TerminalEintrag t) => t.tid.isNotEmpty)
        .take(maxTerminals)
        .toList();
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString(
      terminalsPrefKey(kinoId),
      jsonEncode(bereinigt.map((TerminalEintrag t) => t.toJson()).toList()),
    );
    await speicher.remove(kinokasseTidPrefKey(kinoId));
  }

  /// Alle eingetragenen TIDs des Standorts, in Platz-Reihenfolge.
  static Future<List<String>> ladeTids(String kinoId) async {
    final List<TerminalEintrag> terminals = await ladeTerminals(kinoId);
    return terminals.map((TerminalEintrag t) => t.tid).toList();
  }

  /// TID des als "KK connected" markierten Terminals, sonst leer.
  static Future<String> ladeKinokasseTid(String kinoId) async {
    final List<TerminalEintrag> terminals = await ladeTerminals(kinoId);
    for (final TerminalEintrag t in terminals) {
      if (t.kinokasse) return t.tid;
    }
    return '';
  }

  /// Vorausgefüllte TID (Dev-Modus-Auto-Fill): Konvention seit
  /// 2026-08-30, der erste Eintrag gilt als aktiv. Leer ohne Eintrag.
  static String aktiveTid(List<String> tids) =>
      tids.isNotEmpty ? tids.first : '';
}
