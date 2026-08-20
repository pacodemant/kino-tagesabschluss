import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/services/wechselgeld_config_service.dart';

void main() {
  group('WechselgeldConfigService.parseInhalt', () {
    const WechselgeldConfigService service = WechselgeldConfigService();

    test('parst Datumszeile und Name/Euro-Paare zu Cent-Betraegen', () {
      final (String, Map<String, int>) ergebnis = service.parseInhalt(
        '2026-03-01\nSchauburg\n150\nAtlantis\n200',
      );

      expect(ergebnis.$1, '2026-03-01');
      expect(ergebnis.$2, <String, int>{
        'Schauburg': 15000,
        'Atlantis': 20000,
      });
    });

    test('ueberspringt Kommentarzeilen und Leerzeilen', () {
      final (String, Map<String, int>) ergebnis = service.parseInhalt(
        '# Stand 01.03.2026\n2026-03-01\n\nSchauburg\n150\n'
        '# Kommentar mittendrin\nAtlantis\n200\n',
      );

      expect(ergebnis.$1, '2026-03-01');
      expect(ergebnis.$2, <String, int>{
        'Schauburg': 15000,
        'Atlantis': 20000,
      });
    });

    test('ignoriert nicht-numerische Werte statt abzustuerzen', () {
      final (String, Map<String, int>) ergebnis = service.parseInhalt(
        '2026-03-01\nSchauburg\nabc\nAtlantis\n200',
      );

      expect(ergebnis.$2, <String, int>{'Atlantis': 20000});
    });

    test('ignoriert eine ueberzaehlige letzte Zeile ohne Betrags-Partner', () {
      final (String, Map<String, int>) ergebnis = service.parseInhalt(
        '2026-03-01\nSchauburg\n150\nAtlantis',
      );

      expect(ergebnis.$2, <String, int>{'Schauburg': 15000});
    });

    test('liefert leeres Ergebnis bei leerem Inhalt', () {
      final (String, Map<String, int>) ergebnis = service.parseInhalt('');

      expect(ergebnis.$1, '');
      expect(ergebnis.$2, isEmpty);
    });
  });
}
