import 'dart:convert';

import 'remote_config_service_basis.dart';

class WechselgeldConfigService
    extends RemoteConfigServiceBasis<Map<String, int>> {
  const WechselgeldConfigService();

  @override
  String get remoteUrl =>
      'https://raw.githubusercontent.com/pacodemant/kino-tagesabschluss/master/config/wechselgeld.txt';
  @override
  String get localKey => 'wechselgeld_config';
  @override
  String get localDateKey => 'wechselgeld_config_date';
  @override
  String get updateAvailableKey => 'wechselgeld_update_available';
  @override
  String get logTag => 'WechselgeldConfig';

  @override
  Map<String, int> get leererWert => <String, int>{};

  @override
  bool datenSindLeer(Map<String, int> daten) => daten.isEmpty;

  @override
  (String, Map<String, int>) parseInhalt(String inhalt) {
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

  @override
  String kodiere(Map<String, int> daten) => jsonEncode(daten);

  @override
  Map<String, int> dekodiere(String rohwert) {
    final Map<String, dynamic> geparst =
        jsonDecode(rohwert) as Map<String, dynamic>;
    return geparst.map(
      (String k, dynamic v) => MapEntry<String, int>(k, (v as num).toInt()),
    );
  }

  Future<int> getWechselgeldBetrag(String kinoName) async {
    final Map<String, int> map = await ladeGespeichertenWert();
    return map[kinoName] ?? 0;
  }
}
