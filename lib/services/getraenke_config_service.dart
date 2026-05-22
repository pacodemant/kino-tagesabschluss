import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetraenkeConfigService {
  const GetraenkeConfigService({this.kinoId = 'kino_01'});

  final String kinoId;

  static const String _remoteUrl =
      'https://raw.githubusercontent.com/pacodemant/kino-tagesabschluss/master/config/getraenke_schauburg.txt';
  static const String _localKey = 'getraenke_schauburg';
  static const String _localDateKey = 'getraenke_schauburg_date';
  static const String _updateAvailableKey = 'getraenke_update_available';
  static const String _assetPath = 'config/getraenke_schauburg.txt';

  Future<void> initOnAppStart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> vorhanden = await loadLocal();
    final bool leer = vorhanden.isEmpty;

    if (leer) {
      debugPrint('[GetraenkeConfig] Remote-Fetch gestartet');
      try {
        final (String datum, List<String> liste) = await _fetchRemote();
        await _speichereListeUndDatum(prefs, liste, datum);
        await prefs.setBool(_updateAvailableKey, false);
        debugPrint(
          '[GetraenkeConfig] Remote-Fetch erfolgreich, Datum: $datum',
        );
      } catch (e) {
        debugPrint(
          '[GetraenkeConfig] Remote-Fetch fehlgeschlagen: $e — Asset-Fallback',
        );
        try {
          final (String datum, List<String> liste) = await _ladeAsset();
          await _speichereListeUndDatum(prefs, liste, datum);
          debugPrint(
            '[GetraenkeConfig] Asset-Fallback geladen, ${liste.length} Getränke',
          );
        } catch (assetFehler) {
          debugPrint('[GetraenkeConfig] Asset-Fallback fehlgeschlagen: $assetFehler');
        }
      }
      final List<String> geladen = await loadLocal();
      debugPrint('[GetraenkeConfig] Lokale Liste geladen, ${geladen.length} Getränke');
    } else {
      try {
        final String inhalt = await _fetchRemoteRaw();
        final String remoteDatum = inhalt.split('\n').first.trim();
        final String? lokalDatum = prefs.getString(_localDateKey);
        final bool neuer =
            lokalDatum == null || remoteDatum.compareTo(lokalDatum) > 0;
        await prefs.setBool(_updateAvailableKey, neuer);
        if (neuer) {
          debugPrint(
            '[GetraenkeConfig] Update verfügbar: remote $remoteDatum > lokal $lokalDatum',
          );
        }
      } catch (_) {
        await prefs.setBool(_updateAvailableKey, false);
      }
    }
  }

  Future<List<String>> loadLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rohwert = prefs.getString(_localKey);
    if (rohwert == null || rohwert.isEmpty) {
      return <String>[];
    }
    try {
      final List<dynamic> geparst = jsonDecode(rohwert) as List<dynamic>;
      return geparst.map((dynamic e) => e as String).toList();
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> saveLocal(List<String> getraenke) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(getraenke));
  }

  Future<bool> isUpdateAvailable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_updateAvailableKey) ?? false;
  }

  Future<void> updateFromRemote() async {
    final (String datum, List<String> liste) = await _fetchRemote();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _speichereListeUndDatum(prefs, liste, datum);
    await prefs.setBool(_updateAvailableKey, false);
  }

  Future<String> remoteLastUpdated() async {
    final String inhalt = await _fetchRemoteRaw();
    return inhalt.split('\n').first.trim();
  }

  Future<String> _fetchRemoteRaw() async {
    final http.Response response = await http.get(Uri.parse(_remoteUrl));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    return response.body;
  }

  Future<(String, List<String>)> _fetchRemote() async {
    final String inhalt = await _fetchRemoteRaw();
    return _parseInhalt(inhalt);
  }

  Future<(String, List<String>)> _ladeAsset() async {
    final String inhalt = await rootBundle.loadString(_assetPath);
    return _parseInhalt(inhalt);
  }

  (String, List<String>) _parseInhalt(String inhalt) {
    final List<String> zeilen = inhalt.split('\n');
    final String datum = zeilen.first.trim();
    final List<String> liste = zeilen
        .skip(1)
        .map((String z) => z.trim())
        .where((String z) => z.isNotEmpty)
        .toList();
    return (datum, liste);
  }

  Future<void> _speichereListeUndDatum(
    SharedPreferences prefs,
    List<String> liste,
    String datum,
  ) async {
    await prefs.setString(_localKey, jsonEncode(liste));
    await prefs.setString(_localDateKey, datum);
  }
}
