import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:kino_bar_app/services/beleg_scan_service.dart';
import 'package:kino_bar_app/services/geraete_einrichtung.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Run 511: Einrichtungs-Prüfung für den Hinweis auf dem Startmenü.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> vollstaendigEingerichtet(String kinoId) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'dev_api_upload_aktiv': true,
      ApiUploadService.apiUploadUrlPrefKey: 'https://fc.test',
      ApiUploadService.apiKeyPrefKey(kinoId): 'key',
      BelegScanService.belegScanUrlPrefKey: 'https://scan.test',
    });
    await TerminalIdsConfigService.speichereTerminals(
      kinoId,
      const <TerminalEintrag>[TerminalEintrag(tid: '11112222')],
    );
  }

  test('frisches Gerät: alle Punkte fehlen, Versand aus zuerst', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final List<String> fehlend =
        await GeraeteEinrichtung.fehlendePunkte('kino_01');

    expect(fehlend, <String>[
      GeraeteEinrichtung.versandAus,
      GeraeteEinrichtung.urlFehlt,
      GeraeteEinrichtung.apiKeyFehlt,
      // SB hat eine Sandbox-location_id im Kino-Modell -> fehlt nicht.
      GeraeteEinrichtung.tidsFehlen,
      GeraeteEinrichtung.belegScanFehlt,
    ]);
  });

  test('vollständig eingerichtet (Sandbox): nichts fehlt', () async {
    await vollstaendigEingerichtet('kino_01');

    expect(await GeraeteEinrichtung.fehlendePunkte('kino_01'), isEmpty);
  });

  test('alter geräteweiter API-Key zählt wie beim Senden', () async {
    await vollstaendigEingerichtet('kino_01');
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.remove(ApiUploadService.apiKeyPrefKey('kino_01'));
    await speicher.setString('api_upload_key', 'alt');

    expect(await GeraeteEinrichtung.fehlendePunkte('kino_01'), isEmpty);
  });

  test('Dev-Modus an zählt als Mangel (Run 514)', () async {
    await vollstaendigEingerichtet('kino_01');
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setBool('dev_modus_aktiv', true);

    expect(await GeraeteEinrichtung.fehlendePunkte('kino_01'), <String>[
      GeraeteEinrichtung.devModusAn,
    ]);
  });

  test('SB im Livesystem ohne Live-Adresse und Live-location_id', () async {
    await vollstaendigEingerichtet('kino_01');
    await ApiUploadService.speichereLiveModus('kino_01', true);

    expect(await GeraeteEinrichtung.fehlendePunkte('kino_01'), <String>[
      GeraeteEinrichtung.urlFehlt,
      GeraeteEinrichtung.locationIdFehlt,
    ]);
  });
}
