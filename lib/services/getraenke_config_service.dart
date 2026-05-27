import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetraenkeConfigService {
  const GetraenkeConfigService({this.kinoId = 'kino_01'});

  final String kinoId;

  static const String _baseRawUrl =
      'https://raw.githubusercontent.com/pacodemant/kino-tagesabschluss/master/config/';

  String get _dateiname {
    switch (kinoId) {
      case 'kino_03':
        return 'getraenke_atlantis.txt';
      case 'kino_04':
        return 'getraenke_cinema_ostertor.txt';
      default:
        return 'getraenke_schauburg.txt';
    }
  }

  String get _remoteUrl => '$_baseRawUrl$_dateiname';
  String get _localKey => 'getraenke_$kinoId';
  String get _localDateKey => 'getraenke_${kinoId}_date';
  String get _updateAvailableKey => 'getraenke_update_available_$kinoId';
  String get _assetPath => 'config/$_dateiname';

  Future<void> initOnAppStart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> vorhanden = await loadLocal();
    final bool leer = vorhanden.isEmpty;

    if (leer) {
      debugPrint('[GetraenkeConfig/$kinoId] Remote-Fetch gestartet');
      try {
        final (String datum, List<String> liste) = await _fetchRemote();
        await _speichereListeUndDatum(prefs, liste, datum);
        await prefs.setBool(_updateAvailableKey, false);
        debugPrint(
          '[GetraenkeConfig/$kinoId] Remote-Fetch erfolgreich, Datum: $datum',
        );
      } catch (e) {
        debugPrint(
          '[GetraenkeConfig/$kinoId] Remote-Fetch fehlgeschlagen: $e — Asset-Fallback',
        );
        try {
          final (String datum, List<String> liste) = await _ladeAsset();
          await _speichereListeUndDatum(prefs, liste, datum);
          debugPrint(
            '[GetraenkeConfig/$kinoId] Asset-Fallback geladen, ${liste.length} Getränke',
          );
        } catch (assetFehler) {
          debugPrint('[GetraenkeConfig/$kinoId] Asset-Fallback fehlgeschlagen: $assetFehler');
        }
      }
      final List<String> geladen = await loadLocal();
      debugPrint('[GetraenkeConfig/$kinoId] Lokale Liste geladen, ${geladen.length} Getränke');
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
            '[GetraenkeConfig/$kinoId] Update verfügbar: remote $remoteDatum > lokal $lokalDatum',
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

  Future<List<String>> ladeOriginalNamen() async {
    try {
      final (_, List<String> liste) = await _ladeAsset();
      return liste;
    } catch (_) {
      return <String>[];
    }
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
