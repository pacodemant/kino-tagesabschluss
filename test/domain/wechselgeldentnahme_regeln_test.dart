import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/domain/wechselgeldentnahme_regeln.dart';

void main() {
  group('WechselgeldentnahmeRegeln.aktivAusEntwurf', () {
    test('leerer Entwurf: Schalter bleibt aus', () {
      expect(
        WechselgeldentnahmeRegeln.aktivAusEntwurf(betragCent: 0, grund: ''),
        isFalse,
      );
      expect(
        WechselgeldentnahmeRegeln.aktivAusEntwurf(betragCent: 0, grund: '  '),
        isFalse,
      );
    });

    test('Betrag oder Grund gesetzt: Schalter an', () {
      expect(
        WechselgeldentnahmeRegeln.aktivAusEntwurf(betragCent: 60000, grund: ''),
        isTrue,
      );
      expect(
        WechselgeldentnahmeRegeln.aktivAusEntwurf(
          betragCent: 0,
          grund: 'Rollengeld',
        ),
        isTrue,
      );
    });
  });

  group('WechselgeldentnahmeRegeln.pruefe', () {
    WechselgeldentnahmeFehler pruefe(bool aktiv, int cent, String grund) =>
        WechselgeldentnahmeRegeln.pruefe(
          aktiv: aktiv,
          betragCent: cent,
          grund: grund,
        );

    test('Schalter aus: nie ein Fehler', () {
      expect(pruefe(false, 0, ''), WechselgeldentnahmeFehler.keiner);
    });

    test('Schalter an, Betrag und Grund gesetzt: ok', () {
      expect(
        pruefe(true, 60000, 'Rollengeld'),
        WechselgeldentnahmeFehler.keiner,
      );
    });

    test('Schalter an, aber beides leer: Fehler beidesFehlt', () {
      expect(pruefe(true, 0, ''), WechselgeldentnahmeFehler.beidesFehlt);
      expect(pruefe(true, 0, '   '), WechselgeldentnahmeFehler.beidesFehlt);
    });

    test('Schalter an, Betrag ohne Grund: grundFehlt', () {
      expect(pruefe(true, 60000, ' '), WechselgeldentnahmeFehler.grundFehlt);
    });

    test('Schalter an, Grund ohne Betrag: betragFehlt', () {
      expect(
        pruefe(true, 0, 'Rollengeld'),
        WechselgeldentnahmeFehler.betragFehlt,
      );
    });
  });
}
