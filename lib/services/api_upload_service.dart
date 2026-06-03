import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiUploadService {
  ApiUploadService._();

  static Future<void> upload(
    TagesabschlussFinal abrechnung,
    String url,
    String apiKey,
  ) async {
    final String mitarbeiterName = await _ladeMitarbeiterName();
    final String datum = _formatDatum(abrechnung.datum);
    final String uhrzeit = _formatUhrzeit();

    final Map<String, Object> body = <String, Object>{
      'datum': datum,
      'uhrzeit': uhrzeit,
      'mitarbeiter': mitarbeiterName,
      'differenzAnfangsbestand': _euro(abrechnung.differenzAnfangsbestandCent),
      'kinoSoll': _euro(abrechnung.kinoSollCent),
      'bistroSoll': _euro(abrechnung.bistroSollCent),
      'ausgaben': _euro(abrechnung.ausgabenCent),
      'gesamtSoll': _euro(abrechnung.gesamtSollCent),
      'ecUmsatz': _euro(abrechnung.ecUmsatzGesamtCent),
      'barBestand': _euro(abrechnung.barBestandAbzglWechselgeldCent),
      'gesamtIst': _euro(abrechnung.gesamtIstCent),
      'differenzGesamt': _euro(abrechnung.differenzGesamtCent),
    };

    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  static Future<String> _ladeMitarbeiterName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('mitarbeiter_name') ?? '';
  }

  static String _formatDatum(DateTime datum) {
    final String tag = datum.day.toString().padLeft(2, '0');
    final String monat = datum.month.toString().padLeft(2, '0');
    return '$tag.$monat.${datum.year}';
  }

  static String _formatUhrzeit() {
    final DateTime now = DateTime.now();
    final String stunde = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$stunde:$minute';
  }

  static double _euro(int cent) => cent / 100.0;
}
