import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:shared_preferences/shared_preferences.dart';

TagesabschlussFinal _abschluss(DateTime createdAt) {
  return TagesabschlussFinal(
    kinoId: 'kino_01',
    kinoName: 'Test-Kino',
    datum: DateTime(2026, 9, 18),
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

void main() {
  group('LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst (Run 465)', () {
    late Directory tempDir;
    final DateTime gesendetUm = DateTime(2026, 9, 18, 19, 31, 46);
    final DateTime kopieCreatedAt = DateTime(2026, 9, 18, 19, 33, 5);

    Future<DateTime?> gesendetAmDerKopie() async {
      final List<TagesabschlussFinal> alle =
          await LokalerSpeicher.ladeFinaleTagesabschluesse('kino_01');
      return alle
          .firstWhere(
            (TagesabschlussFinal e) =>
                e.createdAt.isAtSameMomentAs(kopieCreatedAt),
          )
          .gesendetAm;
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tempDir = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(tempDir.path);
      await Hive.openBox('box_tagesabschluesse');
      // Neuer (ungesendeter) Eintrag, wie ihn der Auto-Save beim
      // Wiedereintritt in Schritt 3 anlegt.
      await LokalerSpeicher.speichereFinalenTagesabschluss(
        _abschluss(kopieCreatedAt),
      );
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test(
      'Signatur + Tag passen -> markiert mit ursprünglicher Sendezeit',
      () async {
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG',
          isoDatum: '2026-09-18',
          zeitpunkt: gesendetUm,
        );
        final bool ok =
            await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
              kinoId: 'kino_01',
              createdAt: kopieCreatedAt,
              aktuelleSignatur: 'SIG',
              heutigesIsoDatum: '2026-09-18',
            );
        expect(ok, isTrue);
        expect(await gesendetAmDerKopie(), gesendetUm);
      },
    );

    test(
      'geänderte Daten (Signatur passt nicht) -> bleibt ungesendet',
      () async {
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG',
          isoDatum: '2026-09-18',
          zeitpunkt: gesendetUm,
        );
        final bool ok =
            await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
              kinoId: 'kino_01',
              createdAt: kopieCreatedAt,
              aktuelleSignatur: 'ANDERE',
              heutigesIsoDatum: '2026-09-18',
            );
        expect(ok, isFalse);
        expect(await gesendetAmDerKopie(), isNull);
      },
    );

    test('Versand war an einem anderen Tag -> bleibt ungesendet', () async {
      await LokalerSpeicher.speichereSendeBestaetigung(
        'kino_01',
        'SIG',
        isoDatum: '2026-09-17',
        zeitpunkt: gesendetUm,
      );
      final bool ok =
          await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
            kinoId: 'kino_01',
            createdAt: kopieCreatedAt,
            aktuelleSignatur: 'SIG',
            heutigesIsoDatum: '2026-09-18',
          );
      expect(ok, isFalse);
      expect(await gesendetAmDerKopie(), isNull);
    });

    test('noch nie gesendet -> false', () async {
      final bool ok =
          await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
            kinoId: 'kino_01',
            createdAt: kopieCreatedAt,
            aktuelleSignatur: 'SIG',
            heutigesIsoDatum: '2026-09-18',
          );
      expect(ok, isFalse);
    });

    test(
      'Bestätigung ohne gespeicherte Sendezeit (vor Run 465) -> nimmt jetzt',
      () async {
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG',
          isoDatum: '2026-09-18',
        );
        final DateTime jetzt = DateTime(2026, 9, 18, 20, 0);
        final bool ok =
            await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
              kinoId: 'kino_01',
              createdAt: kopieCreatedAt,
              aktuelleSignatur: 'SIG',
              heutigesIsoDatum: '2026-09-18',
              jetzt: jetzt,
            );
        expect(ok, isTrue);
        expect(await gesendetAmDerKopie(), jetzt);
      },
    );

    test('kein Verlaufseintrag mit dieser createdAt -> false', () async {
      await LokalerSpeicher.speichereSendeBestaetigung(
        'kino_01',
        'SIG',
        isoDatum: '2026-09-18',
        zeitpunkt: gesendetUm,
      );
      final bool ok =
          await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
            kinoId: 'kino_01',
            createdAt: DateTime(2026, 9, 18, 23, 0),
            aktuelleSignatur: 'SIG',
            heutigesIsoDatum: '2026-09-18',
          );
      expect(ok, isFalse);
    });

    test(
      'neue Bestätigung ohne Zeit entfernt alte Zeit; löschen räumt auf',
      () async {
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG',
          isoDatum: '2026-09-18',
          zeitpunkt: gesendetUm,
        );
        expect(
          await LokalerSpeicher.ladeSendeBestaetigungZeit('kino_01'),
          gesendetUm,
        );
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG2',
          isoDatum: '2026-09-18',
        );
        expect(
          await LokalerSpeicher.ladeSendeBestaetigungZeit('kino_01'),
          isNull,
        );
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG3',
          isoDatum: '2026-09-18',
          zeitpunkt: gesendetUm,
        );
        await LokalerSpeicher.loescheSendeBestaetigung('kino_01');
        expect(
          await LokalerSpeicher.ladeSendeBestaetigungZeit('kino_01'),
          isNull,
        );
      },
    );
  });
}
