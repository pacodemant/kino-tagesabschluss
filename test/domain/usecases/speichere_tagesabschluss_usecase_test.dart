import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/domain/usecases/speichere_tagesabschluss_usecase.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

void main() {
  group('SpeichereTagesabschlussUsecase', () {
    const SpeichereTagesabschlussUsecase usecase =
        SpeichereTagesabschlussUsecase();
    late Directory tempDir;

    TagesabschlussFinal abschluss({
      String kinoId = 'kino_01',
      DateTime? datum,
      DateTime? createdAt,
    }) {
      final DateTime tag = datum ?? DateTime(2026, 3, 15);
      return TagesabschlussFinal(
        kinoId: kinoId,
        kinoName: 'Test-Kino',
        datum: tag,
        createdAt: createdAt ?? tag,
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

    test('erster Abschluss des Tages wird ohne Rueckfrage gespeichert', () async {
      final SpeichereTagesabschlussErgebnis ergebnis =
          await usecase.ausfuehren(abschluss());

      expect(ergebnis.bereitsVorhanden, isFalse);
      final List<TagesabschlussFinal> gespeichert =
          await LokalerSpeicher.ladeFinaleTagesabschluesse('kino_01');
      expect(gespeichert, hasLength(1));
    });

    test(
      'zweiter Abschluss am selben Tag ohne Override meldet '
      'bereitsVorhanden (Kino mit maxAbrechnungenProTag 1)',
      () async {
        await usecase.ausfuehren(abschluss());
        final SpeichereTagesabschlussErgebnis ergebnis =
            await usecase.ausfuehren(abschluss());

        expect(ergebnis.bereitsVorhanden, isTrue);
        expect(ergebnis.weitereAbrechnungMoeglich, isFalse);
        final List<TagesabschlussFinal> gespeichert =
            await LokalerSpeicher.ladeFinaleTagesabschluesse('kino_01');
        expect(gespeichert, hasLength(1));
      },
    );

    test('ueberschreiben ersetzt den bestehenden Eintrag desselben Tages', () async {
      await usecase.ausfuehren(abschluss());
      final SpeichereTagesabschlussErgebnis ergebnis = await usecase.ausfuehren(
        abschluss(createdAt: DateTime(2026, 3, 15, 23)),
        ueberschreiben: true,
      );

      expect(ergebnis.bereitsVorhanden, isFalse);
      final List<TagesabschlussFinal> gespeichert =
          await LokalerSpeicher.ladeFinaleTagesabschluesse('kino_01');
      expect(gespeichert, hasLength(1));
      expect(gespeichert.single.createdAt, DateTime(2026, 3, 15, 23));
    });

    test(
      'Kino mit maxAbrechnungenProTag > 1 meldet weitereAbrechnungMoeglich, '
      'solange das Tageslimit nicht erreicht ist',
      () async {
        await usecase.ausfuehren(abschluss(kinoId: 'kino_05'));
        final SpeichereTagesabschlussErgebnis ergebnis = await usecase.ausfuehren(
          abschluss(kinoId: 'kino_05'),
        );

        expect(ergebnis.bereitsVorhanden, isTrue);
        expect(ergebnis.weitereAbrechnungMoeglich, isTrue);
      },
    );

    test(
      'alsZusaetzlicheAbrechnung speichert einen weiteren Eintrag statt '
      'zu blockieren',
      () async {
        await usecase.ausfuehren(abschluss(kinoId: 'kino_05'));
        final SpeichereTagesabschlussErgebnis ergebnis = await usecase.ausfuehren(
          abschluss(kinoId: 'kino_05'),
          alsZusaetzlicheAbrechnung: true,
        );

        expect(ergebnis.bereitsVorhanden, isFalse);
        final List<TagesabschlussFinal> gespeichert =
            await LokalerSpeicher.ladeFinaleTagesabschluesse('kino_05');
        expect(gespeichert, hasLength(2));
      },
    );
  });
}
