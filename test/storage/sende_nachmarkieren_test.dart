import 'dart:io';

import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Run 481: Testtag relativ zu heute statt fest 18.09.2026 — sonst
// entfernt die Verlauf-Aufbewahrung (10 Tage, Run 451/452) die
// gesendeten Testeinträge, sobald das feste Datum zu alt ist.
final DateTime _tag = DateUtils.dateOnly(DateTime.now());
DateTime _am(int stunde, int minute, [int sekunde = 0]) =>
    DateTime(_tag.year, _tag.month, _tag.day, stunde, minute, sekunde);
final String _iso = DatumsHelper.isoDatum(_tag);
final String _isoVortag =
    DatumsHelper.isoDatum(_tag.subtract(const Duration(days: 1)));

TagesabschlussFinal _abschluss(DateTime createdAt) {
  return TagesabschlussFinal(
    kinoId: 'kino_01',
    kinoName: 'Test-Kino',
    datum: _tag,
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
    final DateTime gesendetUm = _am(19, 31, 46);
    final DateTime kopieCreatedAt = _am(19, 33, 5);

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
          isoDatum: _iso,
          zeitpunkt: gesendetUm,
        );
        final bool ok =
            await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
              kinoId: 'kino_01',
              createdAt: kopieCreatedAt,
              aktuelleSignatur: 'SIG',
              heutigesIsoDatum: _iso,
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
          isoDatum: _iso,
          zeitpunkt: gesendetUm,
        );
        final bool ok =
            await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
              kinoId: 'kino_01',
              createdAt: kopieCreatedAt,
              aktuelleSignatur: 'ANDERE',
              heutigesIsoDatum: _iso,
            );
        expect(ok, isFalse);
        expect(await gesendetAmDerKopie(), isNull);
      },
    );

    test('Versand war an einem anderen Tag -> bleibt ungesendet', () async {
      await LokalerSpeicher.speichereSendeBestaetigung(
        'kino_01',
        'SIG',
        isoDatum: _isoVortag,
        zeitpunkt: gesendetUm,
      );
      final bool ok =
          await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
            kinoId: 'kino_01',
            createdAt: kopieCreatedAt,
            aktuelleSignatur: 'SIG',
            heutigesIsoDatum: _iso,
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
            heutigesIsoDatum: _iso,
          );
      expect(ok, isFalse);
    });

    test(
      'Bestätigung ohne gespeicherte Sendezeit (vor Run 465) -> nimmt jetzt',
      () async {
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG',
          isoDatum: _iso,
        );
        final DateTime jetzt = _am(20, 0);
        final bool ok =
            await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
              kinoId: 'kino_01',
              createdAt: kopieCreatedAt,
              aktuelleSignatur: 'SIG',
              heutigesIsoDatum: _iso,
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
        isoDatum: _iso,
        zeitpunkt: gesendetUm,
      );
      final bool ok =
          await LokalerSpeicher.markiereAlsGesendetFallsSignaturPasst(
            kinoId: 'kino_01',
            createdAt: _am(23, 0),
            aktuelleSignatur: 'SIG',
            heutigesIsoDatum: _iso,
          );
      expect(ok, isFalse);
    });

    test(
      'neue Bestätigung ohne Zeit entfernt alte Zeit; löschen räumt auf',
      () async {
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG',
          isoDatum: _iso,
          zeitpunkt: gesendetUm,
        );
        expect(
          await LokalerSpeicher.ladeSendeBestaetigungZeit('kino_01'),
          gesendetUm,
        );
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG2',
          isoDatum: _iso,
        );
        expect(
          await LokalerSpeicher.ladeSendeBestaetigungZeit('kino_01'),
          isNull,
        );
        await LokalerSpeicher.speichereSendeBestaetigung(
          'kino_01',
          'SIG3',
          isoDatum: _iso,
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
