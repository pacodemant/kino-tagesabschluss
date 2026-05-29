import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/services/google_sheets_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: GoogleSheetsConfig.clientId,
  scopes: <String>[GoogleSheetsConfig.scope],
);

class GoogleSheetsService {
  GoogleSheetsService._();

  static Future<String> authenticate() async {
    GoogleSignInAccount? account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();
    account ??= await _googleSignIn.signIn();

    if (account == null) {
      throw Exception('Google Sign-In abgebrochen');
    }

    final bool hasScope = await _googleSignIn.canAccessScopes(
      <String>[GoogleSheetsConfig.scope],
    );
    if (!hasScope) {
      final bool granted = await _googleSignIn.requestScopes(
        <String>[GoogleSheetsConfig.scope],
      );
      if (!granted) {
        throw Exception('Zugriff auf Google Sheets verweigert');
      }
    }

    final GoogleSignInAccount? current = _googleSignIn.currentUser;
    final GoogleSignInAuthentication auth =
        await (current ?? account).authentication;
    final String? accessToken = auth.accessToken;
    if (accessToken == null) {
      throw Exception('Kein Access Token erhalten');
    }
    return accessToken;
  }

  static Future<void> uploadAbrechnung(
    TagesabschlussFinal abrechnung,
    String accessToken,
  ) async {
    final Kino? kino = KinoRepository.nachId(abrechnung.kinoId);
    final String tabName = kino?.kuerzel ?? abrechnung.kinoId;
    final String mitarbeiterName = await _ladeMitarbeiterName();
    final String datum = _formatDatum(abrechnung.datum);

    final List<Object> zeile = <Object>[
      datum,
      mitarbeiterName,
      _euro(abrechnung.differenzAnfangsbestandCent),
      _euro(abrechnung.kinoSollCent),
      _euro(abrechnung.bistroSollCent),
      _euro(abrechnung.ausgabenCent),
      _euro(abrechnung.gesamtSollCent),
      _euro(abrechnung.ecUmsatzGesamtCent),
      _euro(abrechnung.barBestandAbzglWechselgeldCent),
      _euro(abrechnung.gesamtIstCent),
      _euro(abrechnung.differenzGesamtCent),
    ];

    final int? vorhandeneZeile =
        await _findeZeileNachDatum(tabName, abrechnung.datum, accessToken);

    if (vorhandeneZeile != null) {
      await _aktualisiereZeile(tabName, vorhandeneZeile, zeile, accessToken);
    } else {
      await _haengeZeileAn(tabName, zeile, accessToken);
    }
  }

  /// Liest Spalte A und gibt die 1-basierte Zeilennummer zurück, falls ein
  /// Eintrag mit gleichem Datum existiert — sonst null.
  ///
  /// UNFORMATTED_VALUE wird verwendet, weil Sheets Datumsstrings mit
  /// USER_ENTERED als Serial-Number (Zahl) speichert. Beide Fälle werden
  /// geprüft: String-Gleichheit und Serial-Date-Vergleich.
  static Future<int?> _findeZeileNachDatum(
    String tabName,
    DateTime datum,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      'https://sheets.googleapis.com/v4/spreadsheets/${GoogleSheetsConfig.sheetId}'
      '/values/$tabName!A:A?valueRenderOption=UNFORMATTED_VALUE',
    );
    final http.Response response = await http.get(
      uri,
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Lesefehler HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic>? values = body['values'] as List<dynamic>?;
    if (values == null) return null;

    final String datumString = _formatDatum(datum);

    for (int i = 0; i < values.length; i++) {
      final List<dynamic> row = values[i] as List<dynamic>;
      if (row.isEmpty) continue;
      final dynamic wert = row[0];

      // Fall 1: Sheets hat den Wert als Text gespeichert
      if (wert is String && wert == datumString) {
        return i + 1;
      }

      // Fall 2: Sheets hat den Wert als Datums-Serial gespeichert
      if (wert is num) {
        final DateTime gespeichert = _datumAusSheetsSerial(wert.toInt());
        if (gespeichert.year == datum.year &&
            gespeichert.month == datum.month &&
            gespeichert.day == datum.day) {
          return i + 1;
        }
      }
    }
    return null;
  }

  /// Google Sheets Serial-Date: Tage seit 30.12.1899 (inkl. Schaltjahr-Bug).
  /// Formel korrekt für alle Daten ab 1. März 1900.
  static DateTime _datumAusSheetsSerial(int serial) {
    return DateTime(1899, 12, 30).add(Duration(days: serial));
  }

  static Future<void> _aktualisiereZeile(
    String tabName,
    int zeilenNummer,
    List<Object> zeile,
    String accessToken,
  ) async {
    final String range = '$tabName!A$zeilenNummer:K$zeilenNummer';
    final Uri uri = Uri.parse(
      'https://sheets.googleapis.com/v4/spreadsheets/${GoogleSheetsConfig.sheetId}'
      '/values/$range?valueInputOption=USER_ENTERED',
    );
    final http.Response response = await http.put(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, Object>{
        'range': range,
        'values': <Object>[zeile],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  static Future<void> _haengeZeileAn(
    String tabName,
    List<Object> zeile,
    String accessToken,
  ) async {
    final Uri uri = Uri.parse(
      'https://sheets.googleapis.com/v4/spreadsheets/${GoogleSheetsConfig.sheetId}'
      '/values/$tabName!A1:append?valueInputOption=USER_ENTERED',
    );
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, Object>{
        'values': <Object>[zeile],
      }),
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

  static double _euro(int cent) => cent / 100.0;
}
