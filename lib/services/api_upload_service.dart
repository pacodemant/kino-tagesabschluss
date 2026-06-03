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

    // application/x-www-form-urlencoded ist ein CORS-"simple request" —
    // kein Preflight, funktioniert in allen Browsern ohne Serveranpassung.
    // Sobald der echte Kino-Server CORS-Header setzt, auf JSON umstellen.
    final Map<String, String> formBody = <String, String>{
      'datum': datum,
      'uhrzeit': uhrzeit,
      'mitarbeiter': mitarbeiterName,
      'differenzAnfangsbestand': _euro(abrechnung.differenzAnfangsbestandCent).toString(),
      'kinoSoll': _euro(abrechnung.kinoSollCent).toString(),
      'bistroSoll': _euro(abrechnung.bistroSollCent).toString(),
      'ausgaben': _euro(abrechnung.ausgabenCent).toString(),
      'gesamtSoll': _euro(abrechnung.gesamtSollCent).toString(),
      'ecUmsatz': _euro(abrechnung.ecUmsatzGesamtCent).toString(),
      'barBestand': _euro(abrechnung.barBestandAbzglWechselgeldCent).toString(),
      'gesamtIst': _euro(abrechnung.gesamtIstCent).toString(),
      'differenzGesamt': _euro(abrechnung.differenzGesamtCent).toString(),
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      body: formBody,
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
