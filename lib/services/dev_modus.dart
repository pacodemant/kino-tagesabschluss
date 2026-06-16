import 'package:shared_preferences/shared_preferences.dart';

class DevModus {
  const DevModus._();

  static const String _key = 'dev_modus_aktiv';

  static Future<bool> istAktiv() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> setzen(bool wert) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, wert);
  }
}
