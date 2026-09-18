import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/storage/sende_protokoll.dart';
import 'package:shared_preferences/shared_preferences.dart';

TagesabschlussFinal _abschluss({
  required DateTime createdAt,
  DateTime? gesendetAm,
}) {
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
    gesendetAm: gesendetAm,
  );
}

void main() {
  group('SendeProtokoll', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('eintragen/laden: älteste zuerst, mit Uhrzeit', () async {
      await SendeProtokoll.eintragen(
        'eins',
        jetzt: DateTime(2026, 9, 18, 9, 5, 7),
      );
      await SendeProtokoll.eintragen(
        'zwei',
        jetzt: DateTime(2026, 9, 18, 9, 6, 0),
      );
      final List<String> zeilen = await SendeProtokoll.laden();
      expect(zeilen, <String>[
        '18.09. 09:05:07  eins',
        '18.09. 09:06:00  zwei',
      ]);
    });

    test('behält nur die letzten maxEintraege Einträge', () async {
      for (int i = 0; i < SendeProtokoll.maxEintraege + 5; i++) {
        await SendeProtokoll.eintragen('e$i');
      }
      final List<String> zeilen = await SendeProtokoll.laden();
      expect(zeilen.length, SendeProtokoll.maxEintraege);
      expect(zeilen.first.endsWith('e5'), isTrue);
      expect(
        zeilen.last.endsWith('e${SendeProtokoll.maxEintraege + 4}'),
        isTrue,
      );
    });

    test('leeren entfernt alle Einträge', () async {
      await SendeProtokoll.eintragen('x');
      await SendeProtokoll.leeren();
      expect(await SendeProtokoll.laden(), isEmpty);
    });

    test('kuerzel ist deterministisch und unterscheidet Texte', () {
      expect(SendeProtokoll.kuerzel('abc'), SendeProtokoll.kuerzel('abc'));
      expect(
        SendeProtokoll.kuerzel('abc'),
        isNot(SendeProtokoll.kuerzel('abd')),
      );
      expect(SendeProtokoll.kuerzel('').length, 8);
    });

    test('beschreibeSignatur macht cash_total, note und terminals lesbar', () {
      const String sig =
          '{"settlements":[{"cash_total":12345,"note":"x","terminals":[{},{}]}]}';
      final String text = SendeProtokoll.beschreibeSignatur(sig);
      expect(text, contains('cash=12345'));
      expect(text, contains('note=ja'));
      expect(text, contains('terminals=2'));
      expect(SendeProtokoll.beschreibeSignatur(null), 'keine');
      expect(
        SendeProtokoll.beschreibeSignatur('kein json'),
        contains('nicht lesbar'),
      );
    });
  });

  group('LokalerSpeicher schreibt Sende-Protokoll', () {
    late Directory tempDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tempDir = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(tempDir.path);
      await Hive.openBox('box_tagesabschluesse');
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test(
      'markiereAlsGesendet: Treffer -> true und Protokoll "gefunden"',
      () async {
        final DateTime createdAt = DateTime(2026, 9, 18, 14, 0, 0);
        await LokalerSpeicher.speichereFinalenTagesabschluss(
          _abschluss(createdAt: createdAt),
        );
        final bool ok = await LokalerSpeicher.markiereAlsGesendet(
          'kino_01',
          createdAt,
          DateTime(2026, 9, 18, 14, 5),
        );
        expect(ok, isTrue);
        final List<String> zeilen = await SendeProtokoll.laden();
        expect(zeilen.last, contains('gefunden, als gesendet gesetzt'));
      },
    );

    test(
      'markiereAlsGesendet: kein Treffer -> false und "NICHT gefunden" mit vorhandenen createdAt',
      () async {
        await LokalerSpeicher.speichereFinalenTagesabschluss(
          _abschluss(createdAt: DateTime(2026, 9, 18, 14, 0, 0)),
        );
        final bool ok = await LokalerSpeicher.markiereAlsGesendet(
          'kino_01',
          DateTime(2026, 9, 18, 15, 0, 0),
          DateTime(2026, 9, 18, 15, 5),
        );
        expect(ok, isFalse);
        final String letzte = (await SendeProtokoll.laden()).last;
        expect(letzte, contains('NICHT gefunden'));
        expect(letzte, contains('2026-09-18T14:00:00'));
      },
    );

    test('markiereAlsGesendet: leerer Verlauf -> false', () async {
      final bool ok = await LokalerSpeicher.markiereAlsGesendet(
        'kino_01',
        DateTime(2026, 9, 18),
        DateTime(2026, 9, 18),
      );
      expect(ok, isFalse);
    });

    test(
      'ersetze: gesendeter Vorgänger wird im Protokoll als Verlust markiert',
      () async {
        await LokalerSpeicher.speichereFinalenTagesabschluss(
          _abschluss(
            createdAt: DateTime(2026, 9, 18, 14, 0, 0),
            gesendetAm: DateTime(2026, 9, 18, 14, 5),
          ),
        );
        await LokalerSpeicher.ersetzeFinalenTagesabschluss(
          _abschluss(createdAt: DateTime(2026, 9, 18, 16, 0, 0)),
        );
        final String letzte = (await SendeProtokoll.laden()).last;
        expect(letzte, contains('Eintrag ersetzt'));
        expect(letzte, contains('war gesendet: JA'));
      },
    );
  });
}
