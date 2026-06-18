import 'dart:convert';

import 'package:flutter/services.dart';

class ZahlungsartenConfigService {
  static const String _assetPath = 'config/zahlungsarten.json';

  static Future<List<String>> laden() async {
    final String inhalt = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> map =
        json.decode(inhalt) as Map<String, dynamic>;
    return map.values.cast<String>().toList();
  }
}
