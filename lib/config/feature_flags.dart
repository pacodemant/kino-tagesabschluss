import 'package:shared_preferences/shared_preferences.dart';

class FeatureFlags {
  const FeatureFlags._();

  static const String _keyGoogleSheets = 'dev_google_sheets_aktiv';

  static Future<bool> googleSheetsAktiv() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGoogleSheets) ?? false;
  }

  static Future<void> googleSheetsSetzen(bool wert) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGoogleSheets, wert);
  }
}
