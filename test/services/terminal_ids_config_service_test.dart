import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TerminalIdsConfigService.aktiveTid', () {
    test('erste eingetragene TID gilt als aktiv', () {
      expect(
        TerminalIdsConfigService.aktiveTid(<String>[
          '60561994',
          '60561996',
          '60561997',
        ]),
        '60561994',
      );
    });

    test('keine TID eingetragen -> leer', () {
      expect(TerminalIdsConfigService.aktiveTid(const <String>[]), '');
    });
  });

  group('TerminalIdsConfigService Speicher (Run 488)', () {
    test('Speichern und Laden: Nummer und KK bleiben erhalten, leere Plätze '
        'und Leerzeichen in der TID fallen weg', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await TerminalIdsConfigService.speichereTerminals(
        'kino_01',
        const <TerminalEintrag>[
          TerminalEintrag(tid: '60561994', nummer: '1'),
          TerminalEintrag(tid: ''),
          TerminalEintrag(tid: ' 60561997', nummer: '3', kinokasse: true),
          TerminalEintrag(tid: '60561996', nummer: '2'),
        ],
      );

      final List<TerminalEintrag> geladen =
          await TerminalIdsConfigService.ladeTerminals('kino_01');
      expect(geladen.map((TerminalEintrag t) => t.tid), <String>[
        '60561994',
        '60561997',
        '60561996',
      ]);
      expect(geladen.map((TerminalEintrag t) => t.nummer), <String>[
        '1',
        '3',
        '2',
      ]);
      expect(
        await TerminalIdsConfigService.ladeKinokasseTid('kino_01'),
        '60561997',
      );
      expect(await TerminalIdsConfigService.ladeTids('kino_01'), <String>[
        '60561994',
        '60561997',
        '60561996',
      ]);
    });

    test('Einstellung gilt pro Kino', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await TerminalIdsConfigService.speichereTerminals(
        'kino_03',
        const <TerminalEintrag>[TerminalEintrag(tid: '60561998')],
      );
      expect(await TerminalIdsConfigService.ladeTids('kino_01'), isEmpty);
    });

    test('Gerät mit "TID Kinokasse" aus Run 486 -> wird als KK-Terminal '
        'übernommen; erstes Speichern entfernt den Alt-Key', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        TerminalIdsConfigService.kinokasseTidPrefKey('kino_01'): '60561997',
      });

      final List<TerminalEintrag> migriert =
          await TerminalIdsConfigService.ladeTerminals('kino_01');
      expect(migriert, hasLength(1));
      expect(migriert.single.tid, '60561997');
      expect(migriert.single.kinokasse, isTrue);

      await TerminalIdsConfigService.speichereTerminals('kino_01', migriert);
      final SharedPreferences speicher = await SharedPreferences.getInstance();
      expect(
        speicher.containsKey(
          TerminalIdsConfigService.kinokasseTidPrefKey('kino_01'),
        ),
        isFalse,
      );
      expect(
        await TerminalIdsConfigService.ladeKinokasseTid('kino_01'),
        '60561997',
      );
    });

    test('mehr als vier Einträge -> nur die ersten vier', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await TerminalIdsConfigService.speichereTerminals(
        'kino_01',
        const <TerminalEintrag>[
          TerminalEintrag(tid: '1'),
          TerminalEintrag(tid: '2'),
          TerminalEintrag(tid: '3'),
          TerminalEintrag(tid: '4'),
          TerminalEintrag(tid: '5'),
        ],
      );
      expect(await TerminalIdsConfigService.ladeTids('kino_01'), hasLength(4));
    });
  });
}
