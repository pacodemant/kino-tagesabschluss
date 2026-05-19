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

  static Future<void> speichereWechselgeldSollwertCent(
    String kinoId,
    int cent,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setInt('change_target_cents_$kinoId', cent);
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

  /// Ersetzt den finalen Tagesabschluss desselben Kalendertags.
  static Future<void> ersetzeFinalenTagesabschluss(
    TagesabschlussFinal abschluss,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String key = finaleTagesabschluesseKey(abschluss.kinoId);
    final String? rohwert = speicher.getString(key);

    final List<Map<String, dynamic>> aktualisiert = <Map<String, dynamic>>[];
    if (rohwert != null) {
      try {
        final List<dynamic> geparst = jsonDecode(rohwert) as List<dynamic>;
        for (final dynamic eintrag in geparst) {
          if (eintrag is Map<String, dynamic>) {
            final TagesabschlussFinal bestehend =
                TagesabschlussFinal.fromJson(eintrag);
            final bool gleichenTag =
                bestehend.datum.year == abschluss.datum.year &&
                bestehend.datum.month == abschluss.datum.month &&
                bestehend.datum.day == abschluss.datum.day;
            if (!gleichenTag) {
              aktualisiert.add(eintrag);
            }
          }
        }
      } catch (_) {
        // Bei defektem Inhalt wird neu gespeichert.
      }
    }

    aktualisiert.add(abschluss.toJson());
    await speicher.setString(key, jsonEncode(aktualisiert));
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

  /// Speichert den Schritt-2-Entwurf fuer ein Kino.
  static Future<void> speichereSchritt2Entwurf(
    String kinoId,
    Map<String, dynamic> daten,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString(schritt2EntwurfKey(kinoId), jsonEncode(daten));
  }

  /// Laedt den Schritt-2-Entwurf fuer ein Kino, oder null wenn keiner vorhanden.
  static Future<Map<String, dynamic>?> ladeSchritt2Entwurf(
    String kinoId,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String? rohwert = speicher.getString(schritt2EntwurfKey(kinoId));
    if (rohwert == null) {
      return null;
    }
    try {
      return jsonDecode(rohwert) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String schritt2EntwurfKey(String kinoId) =>
      'entwurf_schritt2_$kinoId';

  /// Löscht den Schritt-1-Entwurf für ein Kino und Datum.
  static Future<void> loescheKassenstandEntwurf({
    required String kinoId,
    required String isoDatum,
  }) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.remove(entwurfKey(kinoId: kinoId, isoDatum: isoDatum));
  }

  /// Löscht den Schritt-2-Entwurf für ein Kino.
  static Future<void> loescheSchritt2Entwurf(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.remove(schritt2EntwurfKey(kinoId));
  }

  static Future<Map<String, dynamic>?> ladeAutoFillSchritt1() async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String? rohwert = speicher.getString('dev_autofill_schritt1');
    if (rohwert == null) {
      return null;
    }
    try {
      return jsonDecode(rohwert) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> speichereAutoFillSchritt1(
    Map<String, dynamic> daten,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString('dev_autofill_schritt1', jsonEncode(daten));
  }

  static Future<Map<String, dynamic>?> ladeAutoFillSchritt2() async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String? rohwert = speicher.getString('dev_autofill_schritt2');
    if (rohwert == null) {
      return null;
    }
    try {
      return jsonDecode(rohwert) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> speichereAutoFillSchritt2(
    Map<String, dynamic> daten,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString('dev_autofill_schritt2', jsonEncode(daten));
  }

  /// Löscht den finalen Tagesabschluss eines bestimmten Kalendertags.
  static Future<void> loescheFinalenTagesabschluss(
    String kinoId,
    DateTime datum,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String key = finaleTagesabschluesseKey(kinoId);
    final String? rohwert = speicher.getString(key);
    if (rohwert == null) {
      return;
    }

    final List<Map<String, dynamic>> aktualisiert = <Map<String, dynamic>>[];
    try {
      final List<dynamic> geparst = jsonDecode(rohwert) as List<dynamic>;
      for (final dynamic eintrag in geparst) {
        if (eintrag is Map<String, dynamic>) {
          final TagesabschlussFinal bestehend =
              TagesabschlussFinal.fromJson(eintrag);
          final bool gleichenTag =
              bestehend.datum.year == datum.year &&
              bestehend.datum.month == datum.month &&
              bestehend.datum.day == datum.day;
          if (!gleichenTag) {
            aktualisiert.add(eintrag);
          }
        }
      }
    } catch (_) {
      return;
    }

    await speicher.setString(key, jsonEncode(aktualisiert));
  }
}
