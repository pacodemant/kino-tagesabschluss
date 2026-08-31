import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/services/storage_persist_service.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
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

  static const String standortModusKey = 'standort_modus';

  /// Liefert die fest eingestellte Kino-ID des Geräts, oder null bei
  /// "Alle" (Standard: Kinoauswahl bleibt für den MA sichtbar).
  static Future<String?> ladeStandortModus() async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    return speicher.getString(standortModusKey);
  }

  static Future<void> speichereStandortModus(String? kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    if (kinoId == null) {
      await speicher.remove(standortModusKey);
    } else {
      await speicher.setString(standortModusKey, kinoId);
    }
  }

  static Future<int> ladeWechselgeldSollwertCent(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    return speicher.getInt('change_target_cents_$kinoId') ?? 0;
  }

  static Future<void> speichereWechselgeldSollwertCent(
    String kinoId,
    int cent,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setInt('change_target_cents_$kinoId', cent);
  }

  /// Lädt einen JSON-kodierten String aus der Hive-Box [boxName] unter
  /// [key] und dekodiert ihn per [parse]. Liefert null wenn kein Wert
  /// vorhanden oder der Inhalt nicht dekodierbar ist.
  static Future<T?> _ladeJson<T>(
    String boxName,
    String key,
    T Function(dynamic rohJson) parse,
  ) async {
    final Box<dynamic> box = Hive.box(boxName);
    final String? rohwert = box.get(key) as String?;
    if (rohwert == null) {
      return null;
    }
    try {
      return parse(jsonDecode(rohwert));
    } catch (_) {
      return null;
    }
  }

  /// Kodiert [daten] als JSON und speichert es in der Hive-Box [boxName]
  /// unter [key].
  static Future<void> _speichereJson(
    String boxName,
    String key,
    Object daten,
  ) async {
    final Box<dynamic> box = Hive.box(boxName);
    await box.put(key, jsonEncode(daten));
  }

  static Future<Map<String, dynamic>?> ladeGetraenkeMengen(
    String kinoId,
  ) async {
    final String key =
        'getraenke_mengen_${kinoId}_${DatumsHelper.logischesIsoDatum()}';
    return _ladeJson(
      'box_getraenke_mengen',
      key,
      (dynamic v) => v as Map<String, dynamic>,
    );
  }

  static Future<void> speichereGetraenkeMengen(
    String kinoId,
    Map<String, dynamic> daten,
  ) async {
    final String key =
        'getraenke_mengen_${kinoId}_${DatumsHelper.logischesIsoDatum()}';
    await _speichereJson('box_getraenke_mengen', key, daten);
  }

  static Future<List<String>> ladeGetraenkeliste(String kinoId) async {
    final List<String>? geparst = await _ladeJson(
      'box_getraenkeliste',
      'getraenkeliste_$kinoId',
      (dynamic v) =>
          (v as List<dynamic>).map((dynamic e) => e as String).toList(),
    );
    return geparst ?? <String>[];
  }

  static Future<void> speichereGetraenkeliste(
    String kinoId,
    List<String> liste,
  ) async {
    await _speichereJson(
      'box_getraenkeliste',
      'getraenkeliste_$kinoId',
      liste,
    );
  }

  /// Speichert eine finale Tagesabrechnung im eigenen Key-Namespace je Kino.
  static Future<void> speichereFinalenTagesabschluss(
    TagesabschlussFinal abschluss,
  ) async {
    final Box<dynamic> box = Hive.box('box_tagesabschluesse');
    final String key = finaleTagesabschluesseKey(abschluss.kinoId);
    final String? rohwert = box.get(key) as String?;

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
    await box.put(key, jsonEncode(vorhandeneAbschluesse));
    await StoragePersistService.requestIfNeeded();
  }

  /// Ersetzt die zuletzt erstellte finale Tagesabrechnung desselben
  /// Kalendertags. Gibt es fuer den Tag mehrere Eintraege (z.B. Bar Tabak
  /// mit zwei Abrechnungen/Tag), bleiben die uebrigen erhalten — es wird
  /// gezielt nur der juengste (per createdAt) ersetzt.
  static Future<void> ersetzeFinalenTagesabschluss(
    TagesabschlussFinal abschluss,
  ) async {
    final Box<dynamic> box = Hive.box('box_tagesabschluesse');
    final String key = finaleTagesabschluesseKey(abschluss.kinoId);
    final String? rohwert = box.get(key) as String?;

    final List<Map<String, dynamic>> gleicherTag = <Map<String, dynamic>>[];
    final List<Map<String, dynamic>> andereTage = <Map<String, dynamic>>[];
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
            if (gleichenTag) {
              gleicherTag.add(eintrag);
            } else {
              andereTage.add(eintrag);
            }
          }
        }
      } catch (_) {
        // Bei defektem Inhalt wird neu gespeichert.
      }
    }

    if (gleicherTag.isNotEmpty) {
      gleicherTag.sort(
        (Map<String, dynamic> a, Map<String, dynamic> b) =>
            TagesabschlussFinal.fromJson(a).createdAt.compareTo(
                  TagesabschlussFinal.fromJson(b).createdAt,
                ),
      );
      gleicherTag.removeLast();
    }

    final List<Map<String, dynamic>> aktualisiert = <Map<String, dynamic>>[
      ...andereTage,
      ...gleicherTag,
      abschluss.toJson(),
    ];
    await box.put(key, jsonEncode(aktualisiert));
  }

  /// Laedt alle finalen Tagesabschluesse fuer ein Kino (neueste zuerst).
  static Future<List<TagesabschlussFinal>> ladeFinaleTagesabschluesse(
    String kinoId,
  ) async {
    final Box<dynamic> box = Hive.box('box_tagesabschluesse');
    final String key = finaleTagesabschluesseKey(kinoId);
    final String? rohwert = box.get(key) as String?;
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

  /// Laedt die finalen Tagesabschluesse eines Kinos fuer die Anzeige
  /// (Verlauf, Startseite): pro Kalendertag bleibt nur der zuletzt erstellte
  /// Eintrag (per createdAt) uebrig, aeltere Eintraege desselben Tages
  /// (z.B. liegengebliebene Testdaten-Laeufe oder mehrfach korrigierte
  /// Abrechnungen) werden ausgeblendet. Fuer die Duplikat-/Ueberschreib-
  /// Logik beim Speichern selbst weiterhin die ungefilterte
  /// `ladeFinaleTagesabschluesse()` verwenden, nicht diese Methode.
  static Future<List<TagesabschlussFinal>>
      ladeFinaleTagesabschluesseNeuesteProTag(String kinoId) async {
    final List<TagesabschlussFinal> alle =
        await ladeFinaleTagesabschluesse(kinoId);
    final Map<String, TagesabschlussFinal> neuesterProTag =
        <String, TagesabschlussFinal>{};
    for (final TagesabschlussFinal eintrag in alle) {
      final String tag = DatumsHelper.isoDatum(eintrag.datum);
      final TagesabschlussFinal? bisheriger = neuesterProTag[tag];
      if (bisheriger == null ||
          eintrag.createdAt.isAfter(bisheriger.createdAt)) {
        neuesterProTag[tag] = eintrag;
      }
    }
    final List<TagesabschlussFinal> gefiltert =
        neuesterProTag.values.toList();
    gefiltert.sort(
      (TagesabschlussFinal a, TagesabschlussFinal b) =>
          b.createdAt.compareTo(a.createdAt),
    );
    return gefiltert;
  }

  /// Laedt die finalen Tagesabschluesse eines Kinos, die dem aktuellen
  /// logischen Tag (6-Uhr-Knick) zugeordnet sind (neueste zuerst) — pro
  /// Kalendertag maximal ein Eintrag, siehe
  /// `ladeFinaleTagesabschluesseNeuesteProTag()`.
  static Future<List<TagesabschlussFinal>> ladeHeutigeFinaleTagesabschluesse(
    String kinoId,
  ) async {
    final List<TagesabschlussFinal> alle =
        await ladeFinaleTagesabschluesseNeuesteProTag(kinoId);
    return alle
        .where(
          (TagesabschlussFinal a) =>
              DatumsHelper.isoDatum(a.datum) == DatumsHelper.logischesIsoDatum(),
        )
        .toList();
  }

  /// Key fuer alle finalen Tagesabschluesse eines Kinos.
  static String finaleTagesabschluesseKey(String kinoId) {
    return 'final/$kinoId/closures';
  }

  static Future<bool> ladeLinkshaenderModus() async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    return speicher.getBool('linkshaender_modus') ?? false;
  }

  static Future<void> speichereLinkshaenderModus(bool wert) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setBool('linkshaender_modus', wert);
  }

  /// Speichert den Schritt-2-Entwurf fuer ein Kino.
  static Future<void> speichereSchritt2Entwurf(
    String kinoId,
    Map<String, dynamic> daten,
  ) async {
    await _speichereJson(
      'box_schritt2_entwuerfe',
      schritt2EntwurfKey(kinoId),
      daten,
    );
  }

  /// Laedt den Schritt-2-Entwurf fuer ein Kino, oder null wenn keiner vorhanden.
  static Future<Map<String, dynamic>?> ladeSchritt2Entwurf(
    String kinoId,
  ) async {
    return _ladeJson(
      'box_schritt2_entwuerfe',
      schritt2EntwurfKey(kinoId),
      (dynamic v) => v as Map<String, dynamic>,
    );
  }

  static String schritt2EntwurfKey(String kinoId) =>
      'entwurf_schritt2_$kinoId';

  /// Löscht den Schritt-2-Entwurf für ein Kino.
  static Future<void> loescheSchritt2Entwurf(String kinoId) async {
    final Box<dynamic> box = Hive.box('box_schritt2_entwuerfe');
    await box.delete(schritt2EntwurfKey(kinoId));
  }

  /// Speichert die Signatur der zuletzt erfolgreich an die Buchhaltung
  /// gesendeten Abrechnung eines Kinos (für den "Gesendet"-Haken in
  /// Schritt 3, überlebt Navigation weg von der Seite) sowie separat das
  /// logische Sendedatum (seit Run 402 — die Signatur selbst enthält seit
  /// Run 401 kein Datumsfeld mehr, siehe _sendeSignatur() in
  /// tagesabschluss_schritt3_seite.dart, wird aber für den "heute
  /// gesendet"-Haken im Startmenü gebraucht).
  static Future<void> speichereSendeBestaetigung(
    String kinoId,
    String signatur, {
    required String isoDatum,
  }) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString(_sendeBestaetigungKey(kinoId), signatur);
    await speicher.setString(_sendeBestaetigungDatumKey(kinoId), isoDatum);
  }

  /// Lädt die gespeicherte Sende-Signatur eines Kinos, oder null wenn
  /// noch nie erfolgreich gesendet wurde.
  static Future<String?> ladeSendeBestaetigung(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    return speicher.getString(_sendeBestaetigungKey(kinoId));
  }

  /// Lädt das separat gespeicherte logische Sendedatum eines Kinos, oder
  /// null wenn noch nie erfolgreich gesendet wurde (siehe
  /// [speichereSendeBestaetigung]).
  static Future<String?> ladeSendeBestaetigungDatum(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    return speicher.getString(_sendeBestaetigungDatumKey(kinoId));
  }

  static String _sendeBestaetigungKey(String kinoId) =>
      'sende_bestaetigung_$kinoId';

  static String _sendeBestaetigungDatumKey(String kinoId) =>
      'sende_bestaetigung_datum_$kinoId';

  /// Löscht die gespeicherte Sende-Signatur eines Kinos (z. B. wenn die
  /// zugehörige Abrechnung wieder gelöscht wird — siehe
  /// [loescheFinalenTagesabschluss]).
  static Future<void> loescheSendeBestaetigung(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.remove(_sendeBestaetigungKey(kinoId));
    await speicher.remove(_sendeBestaetigungDatumKey(kinoId));
  }

  static Map<String, dynamic> _schritt1StandardWerte(String kinoId) {
    switch (kinoId) {
      case 'kino_03':
        return <String, dynamic>{
          'stueckzahlen': <String, dynamic>{
            'note_100': 0, 'note_50': 8, 'note_20': 7, 'note_10': 30,
            'note_5': 14,
            'roll_2e': 1, 'roll_1e': 1, 'roll_50c': 1, 'roll_20c': 0,
            'roll_10c': 1, 'roll_5c': 0, 'roll_2c': 0, 'roll_1c': 0,
          },
          'loseMuenzenNachArtCent': <String, dynamic>{
            'coin_2e': 1400, 'coin_1e': 1800, 'coin_50c': 700,
            'coin_20c': 680, 'coin_10c': 290,
            'coin_5c': 0, 'coin_2c': 0, 'coin_1c': 0,
          },
          'umschlaege': <dynamic>[
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
          ],
        };
      case 'kino_04':
        return <String, dynamic>{
          'stueckzahlen': <String, dynamic>{
            'note_100': 0, 'note_50': 1, 'note_20': 6, 'note_10': 9,
            'note_5': 11,
            'roll_2e': 2, 'roll_1e': 1, 'roll_50c': 1, 'roll_20c': 1,
            'roll_10c': 1, 'roll_5c': 0, 'roll_2c': 0, 'roll_1c': 0,
          },
          'loseMuenzenNachArtCent': <String, dynamic>{
            'coin_2e': 2200, 'coin_1e': 2900, 'coin_50c': 1550,
            'coin_20c': 360, 'coin_10c': 390,
            'coin_5c': 0, 'coin_2c': 0, 'coin_1c': 0,
          },
          'umschlaege': <dynamic>[
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
          ],
        };
      default:
        return <String, dynamic>{
          'stueckzahlen': <String, dynamic>{
            'note_100': 1, 'note_50': 13, 'note_20': 17, 'note_10': 65,
            'note_5': 20,
            'roll_2e': 5, 'roll_1e': 8, 'roll_50c': 0, 'roll_20c': 0,
            'roll_10c': 0, 'roll_5c': 0, 'roll_2c': 0, 'roll_1c': 0,
          },
          'loseMuenzenNachArtCent': <String, dynamic>{
            'coin_2e': 6400, 'coin_1e': 5400, 'coin_50c': 1900,
            'coin_20c': 1340, 'coin_10c': 390,
            'coin_5c': 0, 'coin_2c': 0, 'coin_1c': 0,
          },
          'umschlaege': <dynamic>[
            <String, dynamic>{'label': 'Couverts', 'amountCents': 380},
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
          ],
        };
    }
  }

  static Future<Map<String, dynamic>?> ladeAutoFillSchritt1(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String? rohwert = speicher.getString('dev_autofill_schritt1_$kinoId');
    if (rohwert == null) {
      return _schritt1StandardWerte(kinoId);
    }
    try {
      return jsonDecode(rohwert) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> speichereAutoFillSchritt1(
    String kinoId,
    Map<String, dynamic> daten,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString('dev_autofill_schritt1_$kinoId', jsonEncode(daten));
  }

  static Map<String, dynamic> _schritt2StandardWerte(String kinoId) {
    switch (kinoId) {
      case 'kino_03':
        return <String, dynamic>{
          'kinoSollCent': 69000,
          'bistroSollCent': 24930,
          'ausgabenCent': 0,
          'ecBelegCent': 38160,
          'differenzAnfangsbestandCent': 0,
          'zahlungsartenNamen': <String>['Girocard', 'MasterCard', 'Visa'],
          'zahlungsartenBetragCent': <int>[25000, 8000, 5160],
        };
      case 'kino_04':
        return <String, dynamic>{
          'kinoSollCent': 22350,
          'bistroSollCent': 0,
          'ausgabenCent': 0,
          'ecBelegCent': 7750,
          'differenzAnfangsbestandCent': 0,
          'zahlungsartenNamen': <String>['Girocard'],
          'zahlungsartenBetragCent': <int>[7750],
        };
      default:
        return <String, dynamic>{
          'kinoSollCent': 110000,
          'bistroSollCent': 52630,
          'ausgabenCent': 0,
          'ecBelegCent': 57820,
          'differenzAnfangsbestandCent': 0,
          'zahlungsartenNamen': <String>['Girocard', 'MasterCard', 'Visa'],
          'zahlungsartenBetragCent': <int>[40000, 12000, 5820],
        };
    }
  }

  static Future<Map<String, dynamic>?> ladeAutoFillSchritt2(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String? rohwert = speicher.getString('dev_autofill_schritt2_$kinoId');
    if (rohwert == null) {
      return _schritt2StandardWerte(kinoId);
    }
    try {
      return jsonDecode(rohwert) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> speichereAutoFillSchritt2(
    String kinoId,
    Map<String, dynamic> daten,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString('dev_autofill_schritt2_$kinoId', jsonEncode(daten));
  }

  static Future<Map<String, dynamic>?> ladeWechselgeldZaehlEntwurf(
    String kinoId,
  ) async {
    return _ladeJson(
      'box_wechselgeld_entwuerfe',
      _wechselgeldZaehlEntwurfKey(kinoId),
      (dynamic v) => v as Map<String, dynamic>,
    );
  }

  static Future<void> speichereWechselgeldZaehlEntwurf(
    String kinoId,
    Map<String, dynamic> daten,
  ) async {
    await _speichereJson(
      'box_wechselgeld_entwuerfe',
      _wechselgeldZaehlEntwurfKey(kinoId),
      daten,
    );
  }

  static Future<void> loescheWechselgeldZaehlEntwurf(String kinoId) async {
    final Box<dynamic> box = Hive.box('box_wechselgeld_entwuerfe');
    await box.delete(_wechselgeldZaehlEntwurfKey(kinoId));
  }

  static String _wechselgeldZaehlEntwurfKey(String kinoId) =>
      'wechselgeld_zaehlen_entwurf_${kinoId}_${DatumsHelper.logischesIsoDatum()}';

  /// Markiert den Verlaufseintrag mit passendem [createdAt] (identifiziert
  /// die konkrete Abrechnung, auch wenn mehrere desselben Kalendertags
  /// existieren) als erfolgreich an Flurbocash gesendet.
  static Future<void> markiereAlsGesendet(
    String kinoId,
    DateTime createdAt,
    DateTime zeitpunkt,
  ) async {
    final Box<dynamic> box = Hive.box('box_tagesabschluesse');
    final String key = finaleTagesabschluesseKey(kinoId);
    final String? rohwert = box.get(key) as String?;
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
          if (bestehend.createdAt.isAtSameMomentAs(createdAt)) {
            aktualisiert.add(bestehend.mitGesendetAm(zeitpunkt).toJson());
          } else {
            aktualisiert.add(eintrag);
          }
        }
      }
    } catch (_) {
      return;
    }

    await box.put(key, jsonEncode(aktualisiert));
  }

  /// Löscht die finale Tagesabrechnung eines bestimmten Kalendertags.
  static Future<void> loescheFinalenTagesabschluss(
    String kinoId,
    DateTime datum,
  ) async {
    final Box<dynamic> box = Hive.box('box_tagesabschluesse');
    final String key = finaleTagesabschluesseKey(kinoId);
    final String? rohwert = box.get(key) as String?;
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

    await box.put(key, jsonEncode(aktualisiert));
  }

  /// Entfernt abgeschlossene Tagesabrechnungen, deren Kalendertag mehr als
  /// [maxAlterTage] zurueckliegt (Datenschutz). Schreibt nur, wenn sich
  /// tatsaechlich etwas geaendert hat.
  static Future<void> bereinigeAlteTagesabschluesse(
    String kinoId, {
    int maxAlterTage = 30,
  }) async {
    final Box<dynamic> box = Hive.box('box_tagesabschluesse');
    final String key = finaleTagesabschluesseKey(kinoId);
    final String? rohwert = box.get(key) as String?;
    if (rohwert == null) {
      return;
    }

    final DateTime grenze =
        DateTime.now().subtract(Duration(days: maxAlterTage));
    final List<Map<String, dynamic>> aktualisiert = <Map<String, dynamic>>[];
    bool geaendert = false;
    try {
      final List<dynamic> geparst = jsonDecode(rohwert) as List<dynamic>;
      for (final dynamic eintrag in geparst) {
        if (eintrag is Map<String, dynamic>) {
          final TagesabschlussFinal bestehend =
              TagesabschlussFinal.fromJson(eintrag);
          if (bestehend.datum.isBefore(grenze)) {
            geaendert = true;
          } else {
            aktualisiert.add(eintrag);
          }
        }
      }
    } catch (_) {
      return;
    }

    if (geaendert) {
      await box.put(key, jsonEncode(aktualisiert));
    }
  }

  static Future<bool> istErstesSchritt1OeffnenHeute(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String? gespeichert =
        speicher.getString('schritt1_letztesOeffnen_$kinoId');
    final String heute = DatumsHelper.isoDatum(DateTime.now());
    return gespeichert != heute;
  }

  static Future<void> speichereSchritt1OeffnungsDatum(String kinoId) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String heute = DatumsHelper.isoDatum(DateTime.now());
    await speicher.setString('schritt1_letztesOeffnen_$kinoId', heute);
  }

  static Future<String?> ladeMitarbeiterName() async {
    final Box<dynamic> box = Hive.box('box_einstellungen');
    return box.get('mitarbeiter_name') as String?;
  }

  static Future<void> speichereMitarbeiterName(String name) async {
    final Box<dynamic> box = Hive.box('box_einstellungen');
    await box.put('mitarbeiter_name', name);
  }
}
