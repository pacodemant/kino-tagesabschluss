import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Gemeinsamer Ablauf für Remote-Configs mit Datums-basiertem
// Update-Check (Getränkelisten, Wechselgeldbeträge): bei leerem lokalem
// Stand wird die Remote-Datei geholt und gespeichert, sonst wird nur
// das Datum verglichen und ein Update-Flag gesetzt. Unterklassen
// liefern nur noch die datentyp-spezifischen Teile (Parsing, Kodierung,
// Leer-Check) sowie ihre Schlüssel/URL — Template-Method-Muster.
abstract class RemoteConfigServiceBasis<T> {
  const RemoteConfigServiceBasis();

  String get remoteUrl;
  String get localKey;
  String get localDateKey;
  String get updateAvailableKey;
  String get logTag;

  T get leererWert;
  bool datenSindLeer(T daten);
  (String datum, T daten) parseInhalt(String inhalt);
  String kodiere(T daten);
  T dekodiere(String rohwert);

  /// Wird nur aufgerufen, wenn der lokale Stand leer ist UND der
  /// Remote-Fetch fehlschlägt. Default: kein Fallback vorhanden.
  Future<(String datum, T daten)?> assetFallback() async => null;

  Future<void> initOnAppStart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final T vorhanden = await _ladeLokal(prefs);
    final bool leer = datenSindLeer(vorhanden);

    if (leer) {
      debugPrint('[$logTag] Remote-Fetch gestartet');
      try {
        final (String datum, T daten) = await _fetchRemote();
        await _speichereUndDatum(prefs, daten, datum);
        await prefs.setBool(updateAvailableKey, false);
        debugPrint('[$logTag] Remote-Fetch erfolgreich, Datum: $datum');
      } catch (e) {
        debugPrint('[$logTag] Remote-Fetch fehlgeschlagen: $e');
        final (String, T)? fallback = await assetFallback();
        if (fallback != null) {
          final (String datum, T daten) = fallback;
          await _speichereUndDatum(prefs, daten, datum);
        }
      }
    } else {
      try {
        final String inhalt = await _fetchRemoteRaw();
        final String remoteDatum = inhalt.split('\n').first.trim();
        final String? lokalDatum = prefs.getString(localDateKey);
        final bool neuer =
            lokalDatum == null || remoteDatum.compareTo(lokalDatum) > 0;
        await prefs.setBool(updateAvailableKey, neuer);
        if (neuer) {
          debugPrint(
            '[$logTag] Update verfügbar: remote $remoteDatum > lokal $lokalDatum',
          );
        }
      } catch (_) {
        await prefs.setBool(updateAvailableKey, false);
      }
    }
  }

  Future<T> ladeGespeichertenWert() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return _ladeLokal(prefs);
  }

  Future<void> speichereWert(T daten) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(localKey, kodiere(daten));
  }

  Future<bool> isUpdateAvailable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(updateAvailableKey) ?? false;
  }

  Future<void> updateFromRemote() async {
    final (String datum, T daten) = await _fetchRemote();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _speichereUndDatum(prefs, daten, datum);
    await prefs.setBool(updateAvailableKey, false);
  }

  Future<String> remoteLastUpdated() async {
    final String inhalt = await _fetchRemoteRaw();
    return inhalt.split('\n').first.trim();
  }

  Future<T> _ladeLokal(SharedPreferences prefs) async {
    final String? rohwert = prefs.getString(localKey);
    if (rohwert == null || rohwert.isEmpty) {
      return leererWert;
    }
    try {
      return dekodiere(rohwert);
    } catch (_) {
      return leererWert;
    }
  }

  Future<void> _speichereUndDatum(
    SharedPreferences prefs,
    T daten,
    String datum,
  ) async {
    await prefs.setString(localKey, kodiere(daten));
    await prefs.setString(localDateKey, datum);
  }

  Future<String> _fetchRemoteRaw() async {
    final http.Response response = await http.get(Uri.parse(remoteUrl));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    return response.body;
  }

  Future<(String, T)> _fetchRemote() async {
    final String inhalt = await _fetchRemoteRaw();
    return parseInhalt(inhalt);
  }
}
