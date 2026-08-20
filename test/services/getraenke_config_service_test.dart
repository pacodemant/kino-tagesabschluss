import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/services/getraenke_config_service.dart';

void main() {
  group('GetraenkeConfigService.parseInhalt', () {
    const GetraenkeConfigService service = GetraenkeConfigService();

    test('parst erste Zeile als Datum und Rest als Getraenkeliste', () {
      final (String, List<String>) ergebnis = service.parseInhalt(
        '2026-03-01\nCola\nFanta\nBier',
      );

      expect(ergebnis.$1, '2026-03-01');
      expect(ergebnis.$2, <String>['Cola', 'Fanta', 'Bier']);
    });

    test('trimmt Whitespace und ueberspringt Leerzeilen in der Liste', () {
      final (String, List<String>) ergebnis = service.parseInhalt(
        '2026-03-01\n  Cola  \n\nFanta\n   \nBier',
      );

      expect(ergebnis.$2, <String>['Cola', 'Fanta', 'Bier']);
    });

    test('behandelt Kommentarzeilen NICHT als Kommentar (kein #-Filter)', () {
      final (String, List<String>) ergebnis = service.parseInhalt(
        '2026-03-01\nCola\n# kein echter Kommentar hier\nFanta',
      );

      expect(ergebnis.$2, <String>['Cola', '# kein echter Kommentar hier', 'Fanta']);
    });

    test('liefert leere Liste, wenn nur die Datumszeile vorhanden ist', () {
      final (String, List<String>) ergebnis = service.parseInhalt('2026-03-01');

      expect(ergebnis.$1, '2026-03-01');
      expect(ergebnis.$2, isEmpty);
    });

    test('liefert leeres Datum und leere Liste bei leerem Inhalt', () {
      final (String, List<String>) ergebnis = service.parseInhalt('');

      expect(ergebnis.$1, '');
      expect(ergebnis.$2, isEmpty);
    });
  });
}
