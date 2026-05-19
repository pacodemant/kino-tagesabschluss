import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Speichert und lädt die Eingabewerte von Schritt 1 je Kino und Abrechnungsdatum.
///
/// Datum-Logik: 0:00–3:59 Uhr → Abrechnungsdatum = Vortag, ab 4:00 Uhr = heute.
/// Key-Schema: "abrechnung_[kinoId]_[yyyy-MM-dd]"
class AbrechnungSpeicher {
  const AbrechnungSpeicher._();

  static DateTime _abrechnungsDatum() {
    final DateTime jetzt = DateTime.now();
    if (jetzt.hour < 4) {
      return jetzt.subtract(const Duration(days: 1));
    }
    return jetzt;
  }

  static String abrechnungsDatumKey(String kinoId) {
    final DateTime datum = _abrechnungsDatum();
    final String iso =
        '${datum.year.toString().padLeft(4, '0')}-'
        '${datum.month.toString().padLeft(2, '0')}-'
        '${datum.day.toString().padLeft(2, '0')}';
    return 'abrechnung_${kinoId}_$iso';
  }

  static Future<void> speichern(
    String kinoId,
    Map<String, dynamic> daten,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(abrechnungsDatumKey(kinoId), jsonEncode(daten));
  }

  static Future<Map<String, dynamic>?> laden(String kinoId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rohwert = prefs.getString(abrechnungsDatumKey(kinoId));
    if (rohwert == null) {
      return null;
    }
    try {
      return jsonDecode(rohwert) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
