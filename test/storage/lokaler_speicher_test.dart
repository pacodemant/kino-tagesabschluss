import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

void main() {
  group('LokalerSpeicher.ladeFinaleTagesabschluesseNeuesteProTag', () {
    late Directory tempDir;

    TagesabschlussFinal abschluss({
      String kinoId = 'kino_01',
      required DateTime datum,
      required DateTime createdAt,
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
}
