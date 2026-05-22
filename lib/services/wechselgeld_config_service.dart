import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WechselgeldConfigService {
  static const String _remoteUrl =
      'https://raw.githubusercontent.com/pacodemant/kino-tagesabschluss/master/config/wechselgeld.txt';
  static const String _localKey = 'wechselgeld_config';
  static const String _localDateKey = 'wechselgeld_config_date';
  static const String _updateAvailableKey = 'wechselgeld_update_available';

  Future<void> initOnAppStart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, int> vorhanden = await _ladeLokal(prefs);
    final bool leer = vorhanden.isEmpty;

    if (leer) {
      debugPrint('[WechselgeldConfig] Remote-Fetch gestartet');
      try {
        final (String datum, Map<String, int> map) = await _fetchRemote();
        await _speichereMapUndDatum(prefs, map, datum);
        await prefs.setBool(_updateAvailableKey, false);
        debugPrint(
          '[WechselgeldConfig] Remote-Fetch erfolgreich, Datum: $datum',
        );
      } catch (e) {
        debugPrint('[WechselgeldConfig] Remote-Fetch fehlgeschlagen: $e');
      }
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
            '[WechselgeldConfig] Update verfügbar: remote $remoteDatum > lokal $lokalDatum',
          );
        }
      } catch (_) {
        await prefs.setBool(_updateAvailableKey, false);
      }
    }
  }

  Future<int> getWechselgeldBetrag(String kinoName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, int> map = await _ladeLokal(prefs);
    return map[kinoName] ?? 0;
  }

  Future<void> updateFromRemote() async {
    final (String datum, Map<String, int> map) = await _fetchRemote();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _speichereMapUndDatum(prefs, map, datum);
    await prefs.setBool(_updateAvailableKey, false);
  }

  Future<bool> isUpdateAvailable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_updateAvailableKey) ?? false;
  }

  Future<String> _fetchRemoteRaw() async {
    final http.Response response = await http.get(Uri.parse(_remoteUrl));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    return response.body;
  }

  Future<(String, Map<String, int>)> _fetchRemote() async {
    final String inhalt = await _fetchRemoteRaw();
    return _parseInhalt(inhalt);
  }

  (String, Map<String, int>) _parseInhalt(String inhalt) {
    final List<String> zeilen = inhalt
        .split('\n')
        .map((String z) => z.trim())
        .where((String z) => z.isNotEmpty && !z.startsWith('#'))
        .toList();
    final String datum = zeilen.isNotEmpty ? zeilen.first : '';
    final Map<String, int> map = <String, int>{};
    for (int i = 1; i + 1 < zeilen.length; i += 2) {
      final String name = zeilen[i];
      final int? euroGanzzahl = int.tryParse(zeilen[i + 1]);
      if (euroGanzzahl != null) {
        map[name] = euroGanzzahl * 100;
      }
    }
    return (datum, map);
  }

  Future<Map<String, int>> _ladeLokal(SharedPreferences prefs) async {
    final String? rohwert = prefs.getString(_localKey);
    if (rohwert == null || rohwert.isEmpty) {
      return <String, int>{};
    }
    try {
      final Map<String, dynamic> geparst =
          jsonDecode(rohwert) as Map<String, dynamic>;
      return geparst.map(
        (String k, dynamic v) =>
            MapEntry<String, int>(k, (v as num).toInt()),
      );
    } catch (_) {
      return <String, int>{};
    }
  }

  Future<void> _speichereMapUndDatum(
    SharedPreferences prefs,
    Map<String, int> map,
    String datum,
  ) async {
    await prefs.setString(_localKey, jsonEncode(map));
    await prefs.setString(_localDateKey, datum);
  }
}
