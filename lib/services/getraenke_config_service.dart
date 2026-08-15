import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'remote_config_service_basis.dart';

class GetraenkeConfigService extends RemoteConfigServiceBasis<List<String>> {
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

  String get _assetPath => 'config/$_dateiname';

  @override
  String get remoteUrl => '$_baseRawUrl$_dateiname';
  @override
  String get localKey => 'getraenke_$kinoId';
  @override
  String get localDateKey => 'getraenke_${kinoId}_date';
  @override
  String get updateAvailableKey => 'getraenke_update_available_$kinoId';
  @override
  String get logTag => 'GetraenkeConfig/$kinoId';

  @override
  List<String> get leererWert => <String>[];

  @override
  bool datenSindLeer(List<String> daten) => daten.isEmpty;

  @override
  (String, List<String>) parseInhalt(String inhalt) {
    final List<String> zeilen = inhalt.split('\n');
    final String datum = zeilen.first.trim();
    final List<String> liste = zeilen
        .skip(1)
        .map((String z) => z.trim())
        .where((String z) => z.isNotEmpty)
        .toList();
    return (datum, liste);
  }

  @override
  String kodiere(List<String> daten) => jsonEncode(daten);

  @override
  List<String> dekodiere(String rohwert) {
    final List<dynamic> geparst = jsonDecode(rohwert) as List<dynamic>;
    return geparst.map((dynamic e) => e as String).toList();
  }

  @override
  Future<(String, List<String>)?> assetFallback() async {
    try {
      final String inhalt = await rootBundle.loadString(_assetPath);
      final (String, List<String>) ergebnis = parseInhalt(inhalt);
      debugPrint(
        '[$logTag] Asset-Fallback geladen, ${ergebnis.$2.length} Getränke',
      );
      return ergebnis;
    } catch (assetFehler) {
      debugPrint('[$logTag] Asset-Fallback fehlgeschlagen: $assetFehler');
      return null;
    }
  }

  Future<List<String>> loadLocal() => ladeGespeichertenWert();

  Future<void> saveLocal(List<String> getraenke) => speichereWert(getraenke);
}
