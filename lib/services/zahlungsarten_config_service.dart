import 'package:flutter/services.dart';

class ZahlungsartenConfigService {
  static const String _assetPath = 'config/zahlungsarten.txt';

  static Future<List<String>> laden() async {
    final String inhalt = await rootBundle.loadString(_assetPath);
    return inhalt
        .split('\n')
        .map((String z) => z.trim())
        .where((String z) => z.isNotEmpty)
        .toList();
  }
}
