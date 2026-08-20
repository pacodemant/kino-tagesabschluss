import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/domain/usecases/startziel_bestimmen_usecase.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StartzielBestimmenUsecase.bestimmeStartziel', () {
    const StartzielBestimmenUsecase usecase = StartzielBestimmenUsecase();

    test(
      'gueltiger Standort-Modus hat Vorrang vor der zuletzt gewaehlten '
      'Kino-ID und wird als aktive Kino-ID uebernommen',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'standort_modus': 'kino_04',
          LokalerSpeicher.aktivesKinoIdKey: 'kino_01',
        });

        final StartzielBestimmungErgebnis ergebnis =
            await usecase.bestimmeStartziel();

        expect(ergebnis.aktivesKinoId, 'kino_04');
        expect(ergebnis.hatGueltigesKino, isTrue);

        final String? gespeichert = await LokalerSpeicher.ladeAktiveKinoId();
        expect(gespeichert, 'kino_04');
      },
    );

    test(
      'ungueltiger Standort-Modus faellt zurueck auf die zuletzt gewaehlte '
      'Kino-ID',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'standort_modus': 'kino_99',
          LokalerSpeicher.aktivesKinoIdKey: 'kino_02',
        });

        final StartzielBestimmungErgebnis ergebnis =
            await usecase.bestimmeStartziel();

        expect(ergebnis.aktivesKinoId, 'kino_02');
        expect(ergebnis.hatGueltigesKino, isTrue);
      },
    );

    test(
      'ohne Standort-Modus und mit gueltiger gespeicherter Kino-ID '
      'gilt diese als aktives Kino',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          LokalerSpeicher.aktivesKinoIdKey: 'kino_05',
        });

        final StartzielBestimmungErgebnis ergebnis =
            await usecase.bestimmeStartziel();

        expect(ergebnis.aktivesKinoId, 'kino_05');
        expect(ergebnis.hatGueltigesKino, isTrue);
      },
    );

    test(
      'ohne Standort-Modus und ohne gespeicherte Kino-ID gibt es kein '
      'gueltiges Kino',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});

        final StartzielBestimmungErgebnis ergebnis =
            await usecase.bestimmeStartziel();

        expect(ergebnis.aktivesKinoId, isNull);
        expect(ergebnis.hatGueltigesKino, isFalse);
      },
    );

    test(
      'ungueltige gespeicherte Kino-ID wird unveraendert zurueckgegeben, '
      'aber als ungueltig markiert',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          LokalerSpeicher.aktivesKinoIdKey: 'kino_99',
        });

        final StartzielBestimmungErgebnis ergebnis =
            await usecase.bestimmeStartziel();

        expect(ergebnis.aktivesKinoId, 'kino_99');
        expect(ergebnis.hatGueltigesKino, isFalse);
      },
    );
  });
}
