import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiUploadService {
  ApiUploadService._();

  static const Map<String, String> _kartenartMapping = <String, String>{
    'Girocard': 'girocard',
    'girocard': 'girocard',
    'SEPA Lastschrift': 'lastschrift',
    'lastschrift': 'lastschrift',
    'MasterCard': 'mastercard',
    'mastercard': 'mastercard',
    'Visa': 'visa',
    'visa': 'visa',
    'Maestro': 'maestro',
    'maestro': 'maestro',
    'V Pay': 'vpay',
    'vpay': 'vpay',
  };

  static Future<void> upload(TagesabschlussFinal abrechnung) async {
    final ({String url, int locationId, String apiKey}) konfig =
        await _ladeKonfigWerte(abrechnung.kinoId);
    final String datumIso = _datumIso(abrechnung.datum);

    final int reportId =
        await _ensure(konfig.url, konfig.apiKey, konfig.locationId, datumIso);
    await _speichereReportId(abrechnung.kinoId, abrechnung.datum, reportId);

    await _settlements(konfig.url, konfig.apiKey, reportId, abrechnung);
  }

  static Future<({String url, int locationId, String apiKey})> _ladeKonfigWerte(
    String kinoId,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();

    final String baseUrl = speicher.getString('api_upload_url') ?? '';
    if (baseUrl.isEmpty) {
      throw Exception(
        'Keine Flurbocash-URL konfiguriert. Bitte Upload-URL in den Einstellungen eintragen.',
      );
    }

    final String? locationIdStr =
        speicher.getString('flurbocash_location_id_$kinoId');
    final int locationId =
        (locationIdStr != null && locationIdStr.isNotEmpty)
            ? (int.tryParse(locationIdStr) ?? 0)
            : 0;

    final String? perKinoKey =
        speicher.getString('flurbocash_api_key_$kinoId');
    final String apiKey = (perKinoKey != null && perKinoKey.isNotEmpty)
        ? perKinoKey
        : (speicher.getString('api_upload_key') ?? '');

    return (url: baseUrl, locationId: locationId, apiKey: apiKey);
  }

  static Future<int> _ensure(
    String baseUrl,
    String apiKey,
    int locationId,
    String datumIso,
  ) async {
    final Uri uri = Uri.parse('$baseUrl/api/daily-reports/ensure');
    final http.Response response;
    try {
      response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode(<String, dynamic>{
          'location_id': locationId,
          'date': datumIso,
        }),
      );
    } catch (_) {
      throw Exception('Keine Verbindung zur Flurbocash-API.');
    }
    _pruefeStatus(response);
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    return (body['report_id'] as num).toInt();
  }

  static Future<void> _settlements(
    String baseUrl,
    String apiKey,
    int reportId,
    TagesabschlussFinal abrechnung,
  ) async {
    final Uri uri =
        Uri.parse('$baseUrl/api/daily-reports/$reportId/settlements');
    final Map<String, int> karten = _kartenBetraege(abrechnung);
    final http.Response response;
    try {
      response = await http.put(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode(<String, dynamic>{
          'settlements': <Map<String, dynamic>>[
            <String, dynamic>{
              'cash_total': abrechnung.barBestandAbzglWechselgeldCent,
              'terminals': <Map<String, dynamic>>[
                <String, dynamic>{
                  'tid': abrechnung.terminalId ?? '',
                  'girocard': karten['girocard'] ?? 0,
                  'lastschrift': karten['lastschrift'] ?? 0,
                  'mastercard': karten['mastercard'] ?? 0,
                  'visa': karten['visa'] ?? 0,
                  'maestro': karten['maestro'] ?? 0,
                  'vpay': karten['vpay'] ?? 0,
                },
              ],
            },
          ],
        }),
      );
    } catch (_) {
      throw Exception('Keine Verbindung zur Flurbocash-API.');
    }
    _pruefeStatus(response);
  }

  static Map<String, int> _kartenBetraege(TagesabschlussFinal abrechnung) {
    final Map<String, int> ergebnis = <String, int>{};
    final List<ZahlungsartErgebnis>? liste =
        abrechnung.zahlungsartenAufschluesselung;
    if (liste == null || liste.isEmpty) return ergebnis;
    for (final ZahlungsartErgebnis z in liste) {
      final String? feldname = _kartenartMapping[z.art];
      if (feldname != null && z.betragCent != null) {
        ergebnis[feldname] = (ergebnis[feldname] ?? 0) + z.betragCent!;
      }
    }
    return ergebnis;
  }

  static void _pruefeStatus(http.Response response) {
    final int code = response.statusCode;
    if (code >= 200 && code < 300) return;
    switch (code) {
      case 400:
        throw Exception(
          'Übertragung fehlgeschlagen: Ungültige Daten oder Terminal-ID unbekannt.',
        );
      case 401:
        throw Exception(
          'Zugang verweigert – API-Key ungültig. Bitte Einstellungen prüfen.',
        );
      case 403:
        throw Exception(
          'API-Key nicht berechtigt für diesen Standort. Bitte IT kontaktieren.',
        );
      case 404:
        throw Exception(
          'Tagesbericht nicht gefunden. Bitte erneut versuchen.',
        );
      case 500:
        throw Exception(
          'Serverfehler bei Flurbocash. Bitte später erneut versuchen.',
        );
      default:
        throw Exception('Unbekannter Fehler (HTTP $code).');
    }
  }

  static Future<void> _speichereReportId(
    String kinoId,
    DateTime datum,
    int reportId,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setInt(
      'flurbocash_report_id_${kinoId}_${_datumKey(datum)}',
      reportId,
    );
  }

  static String _datumIso(DateTime datum) {
    final String monat = datum.month.toString().padLeft(2, '0');
    final String tag = datum.day.toString().padLeft(2, '0');
    return '${datum.year}-$monat-$tag';
  }

  static String _datumKey(DateTime datum) {
    final String monat = datum.month.toString().padLeft(2, '0');
    final String tag = datum.day.toString().padLeft(2, '0');
    return '${datum.year}_${monat}_$tag';
  }

  // Browser blockiert das Lesen der Antwort bei fehlendem CORS-Header,
  // obwohl der POST beim Server ankam. Diese Fehlertexte kommen vom Browser.
  static bool isCorsArtFehler(Object e) {
    final String text = e.toString().toLowerCase();
    return text.contains('failed to fetch') ||
        text.contains('networkerror') ||
        text.contains('load failed');
  }
}
