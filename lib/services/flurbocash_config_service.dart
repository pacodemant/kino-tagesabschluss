import 'dart:convert';

import 'package:flutter/services.dart';

class FlurbocashStandort {
  const FlurbocashStandort({
    required this.name,
    required this.kinoId,
    required this.locationId,
    required this.apiKey,
  });

  final String name;
  final String kinoId;
  final int locationId;
  final String apiKey;
}

class FlurbocashConfig {
  const FlurbocashConfig({
    required this.sandboxUrl,
    required this.standorte,
  });

  final String sandboxUrl;
  final List<FlurbocashStandort> standorte;
}

class FlurbocashConfigService {
  FlurbocashConfigService._();

  static const String _assetPfad = 'config/flurbocash_anbindung.json';
  static FlurbocashConfig? _cache;

  static Future<FlurbocashConfig?> ladeConfig() async {
    if (_cache != null) return _cache;
    try {
      final String inhalt = await rootBundle.loadString(_assetPfad);
      final Map<String, dynamic> json =
          jsonDecode(inhalt) as Map<String, dynamic>;
      final String url = json['sandbox_url'] as String? ?? '';
      final List<dynamic> raw =
          json['standorte'] as List<dynamic>? ?? <dynamic>[];
      final List<FlurbocashStandort> standorte = raw
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> s) => FlurbocashStandort(
              name: s['name'] as String? ?? '',
              kinoId: s['kino_id'] as String? ?? '',
              locationId: (s['location_id'] as num?)?.toInt() ?? 0,
              apiKey: s['api_key'] as String? ?? '',
            ),
          )
          .toList();
      _cache = FlurbocashConfig(sandboxUrl: url, standorte: standorte);
      return _cache;
    } catch (_) {
      return null;
    }
  }

  static Future<FlurbocashStandort?> fuerKinoId(String kinoId) async {
    final FlurbocashConfig? config = await ladeConfig();
    if (config == null) return null;
    try {
      return config.standorte.firstWhere(
        (FlurbocashStandort s) => s.kinoId == kinoId,
      );
    } catch (_) {
      return null;
    }
  }
}
