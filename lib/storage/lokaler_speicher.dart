import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:kino_bar_app/models/kassenstand_entwurf.dart';

class LokalerSpeicher {
  static const String aktivesKinoIdKey = 'activeCinemaId';

  static Future<String?> ladeAktiveKinoId() async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    return speicher.getString(aktivesKinoIdKey);
  }

  static Future<void> speichereAktiveKinoId(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString(aktivesKinoIdKey, kinoId);
  }

  static Future<int> ladeWechselgeldSollwertCent(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    return speicher.getInt('change_target_cents_$kinoId') ?? 20000;
  }

  static Future<KassenstandEntwurf?> ladeKassenstandEntwurf({
    required String kinoId,
    required String isoDatum,
  }) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String key = entwurfKey(kinoId: kinoId, isoDatum: isoDatum);
    final String? rohwert = speicher.getString(key);
    if (rohwert == null) {
      return null;
    }

    try {
      final Map<String, dynamic> geparst =
          jsonDecode(rohwert) as Map<String, dynamic>;
      return KassenstandEntwurf.fromJson(geparst);
    } catch (_) {
      return null;
    }
  }

  static Future<void> speichereKassenstandEntwurf({
    required String kinoId,
    required String isoDatum,
    required KassenstandEntwurf entwurf,
  }) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String key = entwurfKey(kinoId: kinoId, isoDatum: isoDatum);
    await speicher.setString(key, jsonEncode(entwurf.toJson()));
  }

  static String entwurfKey({required String kinoId, required String isoDatum}) {
    return 'draft_closure_${kinoId}_$isoDatum';
  }
}
