import 'package:http/http.dart' as http;
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

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

    final bool hatScanDaten = abrechnung.terminalId != null ||
        abrechnung.belegNrVon != null ||
        abrechnung.belegNrBis != null ||
        abrechnung.ecUhrzeit != null ||
        (abrechnung.zahlungsartenAufschluesselung?.isNotEmpty ?? false);
    if (hatScanDaten) {
      formBody['terminal_id'] = abrechnung.terminalId ?? 'nicht vorhanden';
      formBody['beleg_nr_von'] = abrechnung.belegNrVon ?? 'nicht vorhanden';
      formBody['beleg_nr_bis'] = abrechnung.belegNrBis ?? 'nicht vorhanden';
      formBody['ec_uhrzeit'] = abrechnung.ecUhrzeit ?? 'nicht vorhanden';
    }

    if (abrechnung.zahlungsartenAufschluesselung != null) {
      for (final ZahlungsartErgebnis z
          in abrechnung.zahlungsartenAufschluesselung!) {
        final String key = _kartenartZuSnakeCase(z.art);
        if (z.betragCent != null) {
          formBody['ec_${key}_betrag_cent'] = z.betragCent!.toString();
        }
        formBody['ec_${key}_anzahl'] = z.anzahl.toString();
      }
    }

    final http.Response response = await http.post(
      Uri.parse(url),
      body: formBody,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  static Future<String> _ladeMitarbeiterName() async {
    return (await LokalerSpeicher.ladeMitarbeiterName()) ?? '';
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

  static String _kartenartZuSnakeCase(String art) {
    return art
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
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
