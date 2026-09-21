import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/utils/tid_eingabe.dart';

void main() {
  group('TidEingabe.bereinige', () {
    test('unveränderte TID bleibt unverändert', () {
      expect(TidEingabe.bereinige('60561997'), '60561997');
    });

    test('führendes Leerzeichen (Auslöser Run 474) wird entfernt', () {
      expect(TidEingabe.bereinige(' 60561997'), '60561997');
    });

    test('Leerzeichen am Ende, in der Mitte und Tab werden entfernt', () {
      expect(TidEingabe.bereinige('6056 1997 '), '60561997');
      expect(TidEingabe.bereinige('60561997\t'), '60561997');
    });

    test('geschütztes Leerzeichen und Zero-Width-Zeichen werden entfernt',
        () {
      expect(TidEingabe.bereinige(' 60561997'), '60561997');
      expect(TidEingabe.bereinige('60561997​'), '60561997');
      expect(TidEingabe.bereinige('‎60561997'), '60561997');
    });

    test('leerer String bleibt leer, reiner Text bleibt erhalten', () {
      expect(TidEingabe.bereinige(''), '');
      expect(TidEingabe.bereinige('   '), '');
      expect(TidEingabe.bereinige('unleserlich'), 'unleserlich');
    });
  });

  group('TidEingabe.formatter', () {
    TextEditingValue wert(String text) => TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );

    test('Leerzeichen tippen wird verworfen', () {
      final TextEditingValue ergebnis = TidEingabe.formatter
          .formatEditUpdate(wert('6056'), wert('6056 '));

      expect(ergebnis.text, '6056');
    });

    test('Einfügen mit Leerzeichen vorn/mitten/hinten → ohne Leerzeichen',
        () {
      final TextEditingValue ergebnis = TidEingabe.formatter
          .formatEditUpdate(wert(''), wert(' 6056 1997 '));

      expect(ergebnis.text, '60561997');
    });

    test('Ziffern werden nicht verändert', () {
      final TextEditingValue ergebnis = TidEingabe.formatter
          .formatEditUpdate(wert('6056199'), wert('60561997'));

      expect(ergebnis.text, '60561997');
    });
  });
}
