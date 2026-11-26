import 'package:kino_bar_app/config/feature_flags.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:kino_bar_app/services/beleg_scan_service.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prüft, ob dieses Gerät für einen Standort fertig eingerichtet ist
/// (seit Run 511, Go-Live-Plan). Einzige Quelle für den Hinweis auf dem
/// Startmenü und die Einrichtungs-Checkliste. Liest nur, ändert nichts.
class GeraeteEinrichtung {
  const GeraeteEinrichtung._();

  static const String versandAus = 'Online-Versand ist ausgeschaltet';
  static const String urlFehlt = 'Flurbocash-Adresse fehlt';
  static const String apiKeyFehlt = 'API-Key fehlt';
  static const String locationIdFehlt = 'Standortnummer (location_id) fehlt';
  static const String tidsFehlen = 'Kartenterminals (TIDs) fehlen';
  static const String belegScanFehlt = 'Belegscan-Adresse fehlt';

  /// Was für [kinoId] auf diesem Gerät noch fehlt, in Einrichtungs-
  /// Reihenfolge. Leere Liste = fertig eingerichtet. Ob Sandbox oder
  /// Livesystem gewählt ist, gilt bewusst nicht als Mangel (Testphase).
  static Future<List<String>> fehlendePunkte(String kinoId) async {
    final List<String> fehlend = <String>[];
    if (!await FeatureFlags.apiUploadAktiv()) fehlend.add(versandAus);

    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final bool live = await ApiUploadService.ladeLiveModus(kinoId);
    final String url =
        speicher.getString(ApiUploadService.uploadUrlPrefKey(live: live)) ??
            '';
    if (url.trim().isEmpty) fehlend.add(urlFehlt);

    // Gleiche Reihenfolge wie beim Senden: Key je Kino, sonst der alte
    // geräteweite Key.
    final String keyKino =
        speicher.getString(ApiUploadService.apiKeyPrefKey(kinoId)) ?? '';
    final String keyAlt = speicher.getString('api_upload_key') ?? '';
    if (keyKino.trim().isEmpty && keyAlt.trim().isEmpty) {
      fehlend.add(apiKeyFehlt);
    }

    if (await ApiUploadService.ladeLocationId(kinoId) == null) {
      fehlend.add(locationIdFehlt);
    }
    if ((await TerminalIdsConfigService.ladeTids(kinoId)).isEmpty) {
      fehlend.add(tidsFehlen);
    }
    if ((await BelegScanService.ladeWorkerUrl()).isEmpty) {
      fehlend.add(belegScanFehlt);
    }
    return fehlend;
  }
}
