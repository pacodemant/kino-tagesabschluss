import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Kleines Ereignisprotokoll rund um Speichern/Senden der Abrechnung
/// (Run 464). Reine Diagnose, ändert kein App-Verhalten: erklärt, wenn der
/// Verlauf "Noch nicht gesendet" zeigt, obwohl gesendet wurde. Sichtbar im
/// Admin-Bereich der Einstellungen (Paco testet als iOS-Safari-PWA, dort
/// ist debugPrint nicht sichtbar).
class SendeProtokoll {
  const SendeProtokoll._();

  static const String _key = 'sende_protokoll';
  static const int maxEintraege = 30;

  /// Hängt eine Zeile an. Wirft nie — ein Fehler im Protokoll darf den
  /// eigentlichen Ablauf nicht stören.
  static Future<void> eintragen(String ereignis, {DateTime? jetzt}) async {
    try {
      final SharedPreferences speicher = await SharedPreferences.getInstance();
      final List<String> zeilen = speicher.getStringList(_key) ?? <String>[];
      zeilen.add('${_zeit(jetzt ?? DateTime.now())}  $ereignis');
      final int ueberschuss = zeilen.length - maxEintraege;
      final List<String> gekuerzt = ueberschuss > 0
          ? zeilen.sublist(ueberschuss)
          : zeilen;
      await speicher.setStringList(_key, gekuerzt);
    } catch (_) {}
  }

  /// Älteste zuerst.
  static Future<List<String>> laden() async {
    try {
      final SharedPreferences speicher = await SharedPreferences.getInstance();
      return List<String>.from(speicher.getStringList(_key) ?? <String>[]);
    } catch (_) {
      return <String>[];
    }
  }

  static Future<void> leeren() async {
    try {
      final SharedPreferences speicher = await SharedPreferences.getInstance();
      await speicher.remove(_key);
    } catch (_) {}
  }

  /// Kurze, plattformstabile Kennung (FNV-1a, 32 Bit) — String.hashCode ist
  /// zwischen Läufen/Plattformen nicht garantiert stabil.
  static String kuerzel(String text) {
    int hash = 0x811c9dc5;
    for (final int einheit in text.codeUnits) {
      hash ^= einheit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// Macht eine Sende-Signatur (JSON aus settlementsBody) lesbar, damit man
  /// bei "Signatur passt nicht" sieht, welcher Teil abweicht.
  static String beschreibeSignatur(String? signatur) {
    if (signatur == null) return 'keine';
    try {
      final Map<String, dynamic> body =
          jsonDecode(signatur) as Map<String, dynamic>;
      final Map<String, dynamic> s =
          (body['settlements'] as List<dynamic>).first as Map<String, dynamic>;
      final int terminals = (s['terminals'] as List<dynamic>?)?.length ?? 0;
      final String note = s['note'] == null ? 'nein' : 'ja';
      return '${kuerzel(signatur)} (cash=${s['cash_total']}, '
          'note=$note, terminals=$terminals)';
    } catch (_) {
      return '${kuerzel(signatur)} (nicht lesbar)';
    }
  }

  static String _zeit(DateTime t) {
    String zwei(int n) => n.toString().padLeft(2, '0');
    return '${zwei(t.day)}.${zwei(t.month)}. '
        '${zwei(t.hour)}:${zwei(t.minute)}:${zwei(t.second)}';
  }
}
