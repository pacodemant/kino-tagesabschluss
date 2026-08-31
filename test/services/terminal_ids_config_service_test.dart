import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';

void main() {
  group('TerminalIdsConfigService.aktiveTid', () {
    final Map<String, List<String>> konfiguration = <String, List<String>>{
      'SB': <String>['54017635', '60561994', '60561996', '60561997'],
      'CO': <String>['60561995'],
      'GO': <String>['XXXX'],
      'AT': <String>[],
    };

    test(
      'Standort mit mehreren TIDs (SB) liefert die erste als aktive TID',
      () {
        expect(
          TerminalIdsConfigService.aktiveTid('SB', konfiguration),
          '54017635',
        );
      },
    );

    test('Standort mit genau einer TID (CO) liefert diese TID', () {
      expect(
        TerminalIdsConfigService.aktiveTid('CO', konfiguration),
        '60561995',
      );
    });

    test(
      'Standort mit nur einem Platzhalter (GO, noch keine echte TID) '
      'liefert den Platzhalter unveraendert',
      () {
        expect(
          TerminalIdsConfigService.aktiveTid('GO', konfiguration),
          'XXXX',
        );
      },
    );

    test('Standort mit leerer TID-Liste liefert einen leeren String', () {
      expect(TerminalIdsConfigService.aktiveTid('AT', konfiguration), '');
    });

    test(
      'unbekanntes oder fehlendes Kuerzel (z.B. Kino nicht gefunden) '
      'liefert einen leeren String statt zu werfen',
      () {
        expect(
          TerminalIdsConfigService.aktiveTid('ZZ', konfiguration),
          '',
        );
        expect(TerminalIdsConfigService.aktiveTid(null, konfiguration), '');
      },
    );
  });
}
