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

  group('WechselgeldentnahmeRegeln.wirksameEntnahmeCent', () {
    int wert({
      required bool abend,
      int auto = 0,
      bool morgenAktiv = false,
      int morgen = 0,
    }) => WechselgeldentnahmeRegeln.wirksameEntnahmeCent(
      abend: abend,
      abendAutomatischCent: auto,
      morgenAktiv: morgenAktiv,
      morgenCent: morgen,
    );

    test('Abend: automatischer Betrag aus dem Abschluss zählt', () {
      expect(wert(abend: true, auto: 60000), 60000);
    });

    test('Abend: ein Morgen-Schalter wird ignoriert', () {
      expect(wert(abend: true, morgenAktiv: true, morgen: 5000), 0);
    });

    test('Morgen: ohne aktiven Schalter zählt nichts', () {
      expect(wert(abend: false, auto: 60000, morgen: 5000), 0);
    });

    test('Morgen: aktiver Schalter mit Betrag zählt den Betrag', () {
      expect(wert(abend: false, morgenAktiv: true, morgen: 5000), 5000);
    });

    test('nur Beträge > 0 zählen', () {
      expect(wert(abend: true, auto: -100), 0);
      expect(wert(abend: false, morgenAktiv: true, morgen: 0), 0);
    });
  });

  group('WechselgeldentnahmeRegeln.wirksamerSollwertCent', () {
    test('Entnahme senkt den Sollwert', () {
      expect(
        WechselgeldentnahmeRegeln.wirksamerSollwertCent(
          sollwertCent: 200000,
          entnahmeCent: 60000,
        ),
        140000,
      );
    });

    test('ohne Entnahme unverändert, nie negativ', () {
      expect(
        WechselgeldentnahmeRegeln.wirksamerSollwertCent(
          sollwertCent: 200000,
          entnahmeCent: 0,
        ),
        200000,
      );
      expect(
        WechselgeldentnahmeRegeln.wirksamerSollwertCent(
          sollwertCent: 1000,
          entnahmeCent: 5000,
        ),
        0,
      );
    });
  });
}
