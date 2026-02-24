import 'dart:convert';

import 'package:kino_bar_app/models/kassenstand_entwurf.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Speichert einen finalen Tagesabschluss im eigenen Key-Namespace je Kino.
  static Future<void> speichereFinalenTagesabschluss(
    TagesabschlussFinal abschluss,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String key = finaleTagesabschluesseKey(abschluss.kinoId);
    final String? rohwert = speicher.getString(key);

    final List<Map<String, dynamic>> vorhandeneAbschluesse =
        <Map<String, dynamic>>[];
    if (rohwert != null) {
      try {
        final List<dynamic> geparst = jsonDecode(rohwert) as List<dynamic>;
        for (final dynamic eintrag in geparst) {
          if (eintrag is Map<String, dynamic>) {
            vorhandeneAbschluesse.add(eintrag);
          }
        }
      } catch (_) {
        // Bei defektem Inhalt wird ab hier sauber neu gespeichert.
      }
    }

    vorhandeneAbschluesse.add(abschluss.toJson());
    await speicher.setString(key, jsonEncode(vorhandeneAbschluesse));
  }

  /// Laedt alle finalen Tagesabschluesse fuer ein Kino (neueste zuerst).
  static Future<List<TagesabschlussFinal>> ladeFinaleTagesabschluesse(
    String kinoId,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String key = finaleTagesabschluesseKey(kinoId);
    final String? rohwert = speicher.getString(key);
    if (rohwert == null) {
      return <TagesabschlussFinal>[];
    }

    try {
      final List<dynamic> geparst = jsonDecode(rohwert) as List<dynamic>;
      final List<TagesabschlussFinal> abschluesse = <TagesabschlussFinal>[];
      for (final dynamic eintrag in geparst) {
        if (eintrag is Map<String, dynamic>) {
          abschluesse.add(TagesabschlussFinal.fromJson(eintrag));
        }
      }
      abschluesse.sort(
        (TagesabschlussFinal a, TagesabschlussFinal b) =>
            b.createdAt.compareTo(a.createdAt),
      );
      return abschluesse;
    } catch (_) {
      return <TagesabschlussFinal>[];
    }
  }

  /// Key fuer alle finalen Tagesabschluesse eines Kinos.
  static String finaleTagesabschluesseKey(String kinoId) {
    return 'final/$kinoId/closures';
  }
}
