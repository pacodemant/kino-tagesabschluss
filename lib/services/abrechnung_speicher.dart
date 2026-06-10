import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';

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
    final Box<dynamic> box = Hive.box('box_abrechnung_entwuerfe');
    await box.put(abrechnungsDatumKey(kinoId), jsonEncode(daten));
  }

  static Future<Map<String, dynamic>?> laden(String kinoId) async {
    final Box<dynamic> box = Hive.box('box_abrechnung_entwuerfe');
    final String? rohwert = box.get(abrechnungsDatumKey(kinoId)) as String?;
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
