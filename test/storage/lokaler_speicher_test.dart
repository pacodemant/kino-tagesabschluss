import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:image/image.dart' as img;
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LokalerSpeicher.ladeFinaleTagesabschluesseNeuesteProTag', () {
    late Directory tempDir;

    TagesabschlussFinal abschluss({
      String kinoId = 'kino_01',
      required DateTime datum,
      required DateTime createdAt,
      DateTime? gesendetAm,
      List<String>? ecBelegeFotosBase64,
      List<String>? ecBelegeFotosMediaTypen,
    }) {
      return TagesabschlussFinal(
        kinoId: kinoId,
        kinoName: 'Test-Kino',
        datum: datum,
        createdAt: createdAt,
        scheineCent: 0,
        loseMuenzenCent: 0,
        rollenCent: 0,
        umschlaegeCent: 0,
        kassenbestandGesamtCent: 0,
        wechselgeldSollwertCent: 0,
        barBestandAbzglWechselgeldCent: 0,
        kinoSollCent: 0,
        bistroSollCent: 0,
        ausgabenCent: 0,
        ecBelegeCent: const <int>[],
        ecUmsatzGesamtCent: 0,
        gesamtSollCent: 0,
        gesamtIstCent: 0,
        differenzGesamtCent: 0,
        differenzAnfangsbestandCent: 0,
        gesendetAm: gesendetAm,
        ecBelegeFotosBase64: ecBelegeFotosBase64,
        ecBelegeFotosMediaTypen: ecBelegeFotosMediaTypen,
      );
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(tempDir.path);
      await Hive.openBox('box_tagesabschluesse');
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'von mehreren Eintraegen desselben Kalendertags bleibt nur der '
      'zuletzt erstellte uebrig (z.B. Testdaten-Lauf + echte Abrechnung)',
      () async {
        final DateTime tag = DateTime(2026, 3, 15);
        await LokalerSpeicher.speichereFinalenTagesabschluss(
          abschluss(datum: tag, createdAt: DateTime(2026, 3, 15, 9)),
        );
        await LokalerSpeicher.speichereFinalenTagesabschluss(
          abschluss(datum: tag, createdAt: DateTime(2026, 3, 15, 18)),
        );

        final List<TagesabschlussFinal> gefiltert =
            await LokalerSpeicher.ladeFinaleTagesabschluesseNeuesteProTag(
          'kino_01',
        );

        expect(gefiltert, hasLength(1));
        expect(gefiltert.single.createdAt, DateTime(2026, 3, 15, 18));
      },
    );

    test(
      'Eintraege verschiedener Kalendertage bleiben alle erhalten, '
      'neuester Tag zuerst',
      () async {
        await LokalerSpeicher.speichereFinalenTagesabschluss(
          abschluss(
            datum: DateTime(2026, 3, 14),
            createdAt: DateTime(2026, 3, 14, 20),
          ),
        );
        await LokalerSpeicher.speichereFinalenTagesabschluss(
          abschluss(
            datum: DateTime(2026, 3, 15),
            createdAt: DateTime(2026, 3, 15, 20),
          ),
        );

        final List<TagesabschlussFinal> gefiltert =
            await LokalerSpeicher.ladeFinaleTagesabschluesseNeuesteProTag(
          'kino_01',
        );

        expect(gefiltert, hasLength(2));
        expect(gefiltert.first.datum, DateTime(2026, 3, 15));
        expect(gefiltert.last.datum, DateTime(2026, 3, 14));
      },
    );
  });

  group(
    'LokalerSpeicher Verlauf-Aufbewahrung (Run 452, 10-Tage-Grenze)',
    () {
      late Directory tempDir;

      TagesabschlussFinal abschluss({
        required DateTime datum,
        required DateTime createdAt,
        DateTime? gesendetAm,
      }) {
        return TagesabschlussFinal(
          kinoId: 'kino_01',
          kinoName: 'Test-Kino',
          datum: datum,
          createdAt: createdAt,
          scheineCent: 0,
          loseMuenzenCent: 0,
          rollenCent: 0,
          umschlaegeCent: 0,
          kassenbestandGesamtCent: 0,
          wechselgeldSollwertCent: 0,
          barBestandAbzglWechselgeldCent: 0,
          kinoSollCent: 0,
          bistroSollCent: 0,
          ausgabenCent: 0,
          ecBelegeCent: const <int>[],
          ecUmsatzGesamtCent: 0,
          gesamtSollCent: 0,
          gesamtIstCent: 0,
          differenzGesamtCent: 0,
          differenzAnfangsbestandCent: 0,
          gesendetAm: gesendetAm,
        );
      }

      setUp(() async {
        tempDir = Directory.systemTemp.createTempSync('hive_test_');
        Hive.init(tempDir.path);
        await Hive.openBox('box_tagesabschluesse');
      });

      tearDown(() async {
        await Hive.deleteFromDisk();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      test(
        'ein bestaetigt gesendeter Eintrag aelter als 10 Tage wird bei '
        'der naechsten Speicherung entfernt',
        () async {
          final DateTime alteTag = DateTime.now().subtract(
            const Duration(days: 20),
          );
          await LokalerSpeicher.speichereFinalenTagesabschluss(
            abschluss(
              datum: alteTag,
              createdAt: alteTag,
              gesendetAm: alteTag.add(const Duration(minutes: 5)),
            ),
          );
          await LokalerSpeicher.speichereFinalenTagesabschluss(
            abschluss(datum: DateTime.now(), createdAt: DateTime.now()),
          );

          final List<TagesabschlussFinal> alle =
              await LokalerSpeicher.ladeFinaleTagesabschluesse('kino_01');

          expect(alle, hasLength(1));
          expect(alle.single.gesendetAm, isNull);
        },
      );

      test(
        'ein NICHT bestaetigter Eintrag aelter als 10 Tage bleibt '
        'erhalten (kein Datenverlust bei offenem Versand, Run 448)',
        () async {
          final DateTime alteTag = DateTime.now().subtract(
            const Duration(days: 20),
          );
          await LokalerSpeicher.speichereFinalenTagesabschluss(
            abschluss(datum: alteTag, createdAt: alteTag, gesendetAm: null),
          );
          await LokalerSpeicher.speichereFinalenTagesabschluss(
            abschluss(datum: DateTime.now(), createdAt: DateTime.now()),
          );

          final List<TagesabschlussFinal> alle =
              await LokalerSpeicher.ladeFinaleTagesabschluesse('kino_01');

          expect(alle, hasLength(2));
        },
      );

      test(
        'ein bestaetigt gesendeter Eintrag juenger als 10 Tage bleibt '
        'erhalten',
        () async {
          final DateTime kuerzlich = DateTime.now().subtract(
            const Duration(days: 3),
          );
          await LokalerSpeicher.speichereFinalenTagesabschluss(
            abschluss(
              datum: kuerzlich,
              createdAt: kuerzlich,
              gesendetAm: kuerzlich.add(const Duration(minutes: 5)),
            ),
          );

          final List<TagesabschlussFinal> alle =
              await LokalerSpeicher.ladeFinaleTagesabschluesse('kino_01');

          expect(alle, hasLength(1));
        },
      );
    },
  );

  group(
    'LokalerSpeicher Belegfoto-Kompression im Verlauf (Run 451)',
    () {
      late Directory tempDir;

      // Echtes Rauschen (fester Seed), siehe beleg_foto_komprimierung_
      // test.dart: bildet ein echtes, detailreiches Kamerafoto realistischer
      // ab als eine einfarbige/regelmaessige Testflaeche.
      String grossesBase64Foto() {
        final img.Image bild = img.Image(width: 2000, height: 1500);
        final Random rnd = Random(42);
        for (int y = 0; y < 1500; y++) {
          for (int x = 0; x < 2000; x++) {
            bild.setPixelRgb(
              x,
              y,
              rnd.nextInt(256),
              rnd.nextInt(256),
              rnd.nextInt(256),
            );
          }
        }
        return base64Encode(img.encodePng(bild));
      }

      TagesabschlussFinal abschlussMitFoto(String fotoBase64) {
        return TagesabschlussFinal(
          kinoId: 'kino_01',
          kinoName: 'Test-Kino',
          datum: DateTime.now(),
          createdAt: DateTime.now(),
          scheineCent: 0,
          loseMuenzenCent: 0,
          rollenCent: 0,
          umschlaegeCent: 0,
          kassenbestandGesamtCent: 0,
          wechselgeldSollwertCent: 0,
          barBestandAbzglWechselgeldCent: 0,
          kinoSollCent: 0,
          bistroSollCent: 0,
          ausgabenCent: 0,
          ecBelegeCent: const <int>[],
          ecUmsatzGesamtCent: 0,
          gesamtSollCent: 0,
          gesamtIstCent: 0,
          differenzGesamtCent: 0,
          differenzAnfangsbestandCent: 0,
          ecBelegeFotosBase64: <String>[fotoBase64],
          ecBelegeFotosMediaTypen: const <String>['image/png'],
        );
      }

      setUp(() async {
        tempDir = Directory.systemTemp.createTempSync('hive_test_');
        Hive.init(tempDir.path);
        await Hive.openBox('box_tagesabschluesse');
      });

      tearDown(() async {
        await Hive.deleteFromDisk();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      test(
        'ein grosses Belegfoto wird beim Speichern in den Verlauf '
        'komprimiert abgelegt (kuerzeres Base64 als das Original)',
        () async {
          final String original = grossesBase64Foto();
          final TagesabschlussFinal eingabe = abschlussMitFoto(original);

          await LokalerSpeicher.speichereFinalenTagesabschluss(eingabe);

          final List<TagesabschlussFinal> geladen =
              await LokalerSpeicher.ladeFinaleTagesabschluesse('kino_01');
          final String gespeichertesFoto =
              geladen.single.ecBelegeFotosBase64!.single;

          expect(gespeichertesFoto.length, lessThan(original.length));
          // Das Original-Objekt (z. B. weiterhin fuer den Versand an
          // Flurbocash in Verwendung) bleibt dabei unveraendert.
          expect(eingabe.ecBelegeFotosBase64!.single, original);
        },
      );
    },
  );

  group('LokalerSpeicher.speichereSendeBestaetigung / ladeSendeBestaetigung*', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test(
      'Signatur und isoDatum werden getrennt gespeichert und wieder '
      'geladen (Regression Run 401: das Datum steht seither NICHT mehr '
      'in der Signatur selbst, siehe _sendeSignatur() in '
      'tagesabschluss_schritt3_seite.dart)',
      () async {
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          '{"settlements":[{"cash_total":123}]}',
          isoDatum: '2026-08-31',
        );

        final String? signatur = await LokalerSpeicher.ladeSendeBestaetigung(
          'kino_01',
        );
        final String? datum = await LokalerSpeicher.ladeSendeBestaetigungDatum(
          'kino_01',
        );

        expect(signatur, '{"settlements":[{"cash_total":123}]}');
        expect(datum, '2026-08-31');
      },
    );

    test(
      'ohne vorherigen Sendevorgang liefert ladeSendeBestaetigungDatum null',
      () async {
        final String? datum = await LokalerSpeicher.ladeSendeBestaetigungDatum(
          'kino_01',
        );
        expect(datum, isNull);
      },
    );

    test(
      'loescheSendeBestaetigung entfernt Signatur UND Datum',
      () async {
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'irgendeine-signatur',
          isoDatum: '2026-08-31',
        );

        await LokalerSpeicher.loescheSendeBestaetigung('kino_01');

        expect(await LokalerSpeicher.ladeSendeBestaetigung('kino_01'), isNull);
        expect(
          await LokalerSpeicher.ladeSendeBestaetigungDatum('kino_01'),
          isNull,
        );
      },
    );

    test(
      'unterschiedliche Kinos speichern ihr Sendedatum unabhaengig '
      'voneinander',
      () async {
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'signatur-1',
          isoDatum: '2026-08-31',
        );
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_02',
          'signatur-2',
          isoDatum: '2026-08-30',
        );

        expect(
          await LokalerSpeicher.ladeSendeBestaetigungDatum('kino_01'),
          '2026-08-31',
        );
        expect(
          await LokalerSpeicher.ladeSendeBestaetigungDatum('kino_02'),
          '2026-08-30',
        );
      },
    );
  });

  group(
    'LokalerSpeicher.markiereVersandNichtBestaetigt / '
    'ladeVersandNichtBestaetigtDatum* (Run 448)',
    () {
      setUp(() {
        SharedPreferences.setMockInitialValues(<String, Object>{});
      });

      test(
        'ohne vorherigen Versandversuch liefert '
        'ladeVersandNichtBestaetigtDatum null',
        () async {
          final String? datum =
              await LokalerSpeicher.ladeVersandNichtBestaetigtDatum(
            'kino_01',
          );
          expect(datum, isNull);
        },
      );

      test(
        'markiereVersandNichtBestaetigt speichert das isoDatum, danach '
        'lesbar ueber ladeVersandNichtBestaetigtDatum',
        () async {
          await LokalerSpeicher.markiereVersandNichtBestaetigt(
            'kino_01',
            isoDatum: '2026-09-16',
          );

          expect(
            await LokalerSpeicher.ladeVersandNichtBestaetigtDatum('kino_01'),
            '2026-09-16',
          );
        },
      );

      test(
        'loescheVersandNichtBestaetigt entfernt das Datum wieder (z.B. '
        'nach einem spaeter doch bestaetigten Versand)',
        () async {
          await LokalerSpeicher.markiereVersandNichtBestaetigt(
            'kino_01',
            isoDatum: '2026-09-16',
          );

          await LokalerSpeicher.loescheVersandNichtBestaetigt('kino_01');

          expect(
            await LokalerSpeicher.ladeVersandNichtBestaetigtDatum('kino_01'),
            isNull,
          );
        },
      );

      test(
        'unterschiedliche Kinos speichern ihren Warn-Status unabhaengig '
        'voneinander',
        () async {
          await LokalerSpeicher.markiereVersandNichtBestaetigt(
            'kino_01',
            isoDatum: '2026-09-16',
          );
          await LokalerSpeicher.markiereVersandNichtBestaetigt(
            'kino_02',
            isoDatum: '2026-09-15',
          );

          expect(
            await LokalerSpeicher.ladeVersandNichtBestaetigtDatum('kino_01'),
            '2026-09-16',
          );
          expect(
            await LokalerSpeicher.ladeVersandNichtBestaetigtDatum('kino_02'),
            '2026-09-15',
          );
        },
      );
    },
  );

  group('LokalerSpeicher.ladeAutoFillSchritt2', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test(
      'fuellt zahlungsartenNamen/-BetragCent aus den Standardwerten nach, '
      'wenn ein bereits gespeicherter (vor Run 419 entstandener, kaputter) '
      'Stand sie nicht enthaelt, alle anderen Felder bleiben unveraendert '
      '(Regression Run 420: Run-419-Fix verhinderte nur kuenftigen '
      'Datenverlust, reparierte aber bereits kaputte Altstaende nicht)',
      () async {
        final SharedPreferences speicher =
            await SharedPreferences.getInstance();
        await speicher.setString(
          'dev_autofill_schritt2_kino_03',
          jsonEncode(<String, dynamic>{
            'kinoSollCent': 12345,
            'bistroSollCent': 0,
            'ausgabenCent': 0,
            'ecBelegCent': 52000,
            'differenzAnfangsbestandCent': 0,
          }),
        );

        final Map<String, dynamic>? geladen =
            await LokalerSpeicher.ladeAutoFillSchritt2('kino_03');

        expect(geladen?['kinoSollCent'], 12345);
        expect(geladen?['ecBelegCent'], 52000);
        expect(
          geladen?['zahlungsartenNamen'],
          <String>['Girocard', 'MasterCard', 'Visa'],
        );
        expect(geladen?['zahlungsartenBetragCent'], <int>[25000, 8000, 5160]);
      },
    );

    test(
      'laesst einen bereits vollstaendigen gespeicherten Stand '
      '(mit eigenen zahlungsartenNamen) unveraendert',
      () async {
        final SharedPreferences speicher =
            await SharedPreferences.getInstance();
        await speicher.setString(
          'dev_autofill_schritt2_kino_03',
          jsonEncode(<String, dynamic>{
            'kinoSollCent': 12345,
            'zahlungsartenNamen': <String>['Girocard'],
            'zahlungsartenBetragCent': <int>[12345],
          }),
        );

        final Map<String, dynamic>? geladen =
            await LokalerSpeicher.ladeAutoFillSchritt2('kino_03');

        expect(geladen?['zahlungsartenNamen'], <String>['Girocard']);
        expect(geladen?['zahlungsartenBetragCent'], <int>[12345]);
      },
    );
  });

  group(
    'LokalerSpeicher.autoFillSchritt2MitBestehendenZahlungsarten',
    () {
      test(
        'uebernimmt zahlungsartenNamen/-BetragCent aus den bestehenden '
        'Daten, wenn "neu" (aus der Einstellungen-Seite, hat dafuer keine '
        'eigenen Felder) sie nicht enthaelt (Regression Run 419: Auto-Fill '
        'auf der Umsaetze-Seite fuellte auf Geraeten, auf denen schon '
        'einmal in den Einstellungen gespeichert wurde, keine Kartenarten '
        'mehr, nur noch den Gesamtbetrag)',
        () {
          final Map<String, dynamic> bestehend = <String, dynamic>{
            'kinoSollCent': 110000,
            'zahlungsartenNamen': <String>['Girocard', 'MasterCard'],
            'zahlungsartenBetragCent': <int>[40000, 12000],
          };
          final Map<String, dynamic> neu = <String, dynamic>{
            'kinoSollCent': 99900,
            'bistroSollCent': 0,
            'ausgabenCent': 0,
            'ecBelegCent': 52000,
            'differenzAnfangsbestandCent': 0,
          };

          final Map<String, dynamic> ergebnis =
              LokalerSpeicher.autoFillSchritt2MitBestehendenZahlungsarten(
            neu,
            bestehend,
          );

          expect(ergebnis['kinoSollCent'], 99900);
          expect(ergebnis['ecBelegCent'], 52000);
          expect(
            ergebnis['zahlungsartenNamen'],
            <String>['Girocard', 'MasterCard'],
          );
          expect(ergebnis['zahlungsartenBetragCent'], <int>[40000, 12000]);
        },
      );

      test(
        'ohne bestehende Daten (erstes Speichern ueberhaupt) bleibt "neu" '
        'unveraendert, kein Absturz',
        () {
          final Map<String, dynamic> neu = <String, dynamic>{
            'kinoSollCent': 0,
          };

          final Map<String, dynamic> ergebnis =
              LokalerSpeicher.autoFillSchritt2MitBestehendenZahlungsarten(
            neu,
            null,
          );

          expect(ergebnis, <String, dynamic>{'kinoSollCent': 0});
        },
      );

      test(
        'Speichern+Laden-Roundtrip ueber SharedPreferences: '
        'zahlungsartenNamen bleiben ueber zwei aufeinanderfolgende '
        'Speichervorgaenge erhalten, auch wenn nur die uebrigen Felder '
        'geaendert werden',
        () async {
          SharedPreferences.setMockInitialValues(<String, Object>{});

          final Map<String, dynamic>? erste =
              await LokalerSpeicher.ladeAutoFillSchritt2('kino_03');
          await LokalerSpeicher.speichereAutoFillSchritt2(
            'kino_03',
            LokalerSpeicher.autoFillSchritt2MitBestehendenZahlungsarten(
              <String, dynamic>{'kinoSollCent': 12345},
              erste,
            ),
          );

          final Map<String, dynamic>? zweite =
              await LokalerSpeicher.ladeAutoFillSchritt2('kino_03');
          await LokalerSpeicher.speichereAutoFillSchritt2(
            'kino_03',
            LokalerSpeicher.autoFillSchritt2MitBestehendenZahlungsarten(
              <String, dynamic>{'kinoSollCent': 67890},
              zweite,
            ),
          );

          final Map<String, dynamic>? dritte =
              await LokalerSpeicher.ladeAutoFillSchritt2('kino_03');

          expect(dritte?['kinoSollCent'], 67890);
          expect(
            dritte?['zahlungsartenNamen'],
            <String>['Girocard', 'MasterCard', 'Visa'],
          );
        },
      );
    },
  );
}
