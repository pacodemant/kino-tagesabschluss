import 'package:shared_preferences/shared_preferences.dart';

class FeatureFlags {
  const FeatureFlags._();

  static const String _keyApiUpload = 'dev_api_upload_aktiv';

  static Future<bool> apiUploadAktiv() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyApiUpload) ?? false;
  }

  static Future<void> apiUploadSetzen(bool wert) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyApiUpload, wert);
  }
}
