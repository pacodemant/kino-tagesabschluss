import 'dart:convert';

import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Speichert und lädt die Eingabewerte von Schritt 1 je Kino und Abrechnungsdatum.
///
/// Datum-Logik: 0:00–5:59 Uhr → Abrechnungsdatum = Vortag, ab 6:00 Uhr = heute.
/// Key-Schema: "abrechnung_[kinoId]_[yyyy-MM-dd]"
class AbrechnungSpeicher {
  const AbrechnungSpeicher._();

  static String abrechnungsDatumKey(String kinoId) {
    return 'abrechnung_${kinoId}_${DatumsHelper.logischesIsoDatum()}';
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
