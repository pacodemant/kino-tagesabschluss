import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/services/getraenke_config_service.dart';
import 'package:kino_bar_app/services/wechselgeld_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Run 509: Getränkelisten und Wechselgeldbeträge kommen beim App-Start
// nur noch aus der mitgelieferten Startliste (kein Netzabruf mehr), und
// ein vorhandener Stand auf dem Gerät wird nie überschrieben.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('leeres Gerät: Getränke-Startliste wird übernommen', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const GetraenkeConfigService service =
        GetraenkeConfigService(kinoId: 'kino_01');

    await service.initOnAppStart();

    final List<String> liste = await service.loadLocal();
    expect(liste, isNotEmpty);
  });

  test('vor Ort eingetragene Getränkeliste bleibt beim Start erhalten',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const GetraenkeConfigService service =
        GetraenkeConfigService(kinoId: 'kino_01');
    await service.saveLocal(<String>['Hauswein', 'Mate']);

    await service.initOnAppStart();

    expect(await service.loadLocal(), <String>['Hauswein', 'Mate']);
  });

  test('leeres Gerät: Wechselgeld-Startwerte werden übernommen', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const WechselgeldConfigService service = WechselgeldConfigService();

    await service.initOnAppStart();

    expect(await service.getWechselgeldBetrag('Schauburg'), greaterThan(0));
    expect(await service.getWechselgeldBetrag('Atlantis'), greaterThan(0));
    expect(
      await service.getWechselgeldBetrag('Cinema Ostertor'),
      greaterThan(0),
    );
  });

  test('vorhandene Wechselgeldwerte bleiben beim Start erhalten', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const WechselgeldConfigService service = WechselgeldConfigService();
    await service.speichereWert(<String, int>{'Schauburg': 123400});

    await service.initOnAppStart();

    expect(await service.getWechselgeldBetrag('Schauburg'), 123400);
  });
}
