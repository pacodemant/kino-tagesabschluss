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

  // Gibt Access Token zurück; wirft Exception bei Abbruch oder Fehler.
  static Future<String> authenticate() async {
    GoogleSignInAccount? account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();
    account ??= await _googleSignIn.signIn();

    if (account == null) {
      throw Exception('Google Sign-In abgebrochen');
    }

    // GIS trennt Authentifizierung (signIn) und Autorisierung (Scope/Token).
    // canAccessScopes prüft, ob der Sheets-Scope bereits gewährt ist.
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

    final List<Object> zeile = <Object>[
      _formatDatum(abrechnung.datum),
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
