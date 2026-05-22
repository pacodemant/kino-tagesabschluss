import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class GetraenkeConfigService {
  static const String _remoteUrl =
      'https://raw.githubusercontent.com/pacodemant/kino-tagesabschluss/master/config/getraenke_schauburg.txt';
  static const String _localKey = 'getraenke_schauburg';
  static const String _localDateKey = 'getraenke_schauburg_date';
  static const String _updateAvailableKey = 'getraenke_update_available';

  Future<void> initOnAppStart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rohwert = prefs.getString(_localKey);
    final bool leer = rohwert == null || rohwert.isEmpty;

    if (leer) {
      try {
        final (String datum, List<String> liste) = await _fetchRemote();
        await _speichereListeUndDatum(prefs, liste, datum);
        await prefs.setBool(_updateAvailableKey, false);
      } catch (_) {
        // offline: kein Fehler
      }
    } else {
      try {
        final String inhalt = await _fetchRemoteRaw();
        final String remoteDatum = inhalt.split('\n').first.trim();
        final String? lokalDatum = prefs.getString(_localDateKey);
        final bool neuer =
            lokalDatum == null || remoteDatum.compareTo(lokalDatum) > 0;
        await prefs.setBool(_updateAvailableKey, neuer);
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
    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request =
          await client.getUrl(Uri.parse(_remoteUrl));
      final HttpClientResponse response = await request.close();
      return response.transform(utf8.decoder).join();
    } finally {
      client.close();
    }
  }

  Future<(String, List<String>)> _fetchRemote() async {
    final String inhalt = await _fetchRemoteRaw();
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
