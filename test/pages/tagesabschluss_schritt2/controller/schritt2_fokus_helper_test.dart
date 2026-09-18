import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/controller/schritt2_fokus_helper.dart';

void main() {
  group('Schritt2FokusHelper.erstesLeeresFeld', () {
    late FocusNode differenzFn;
    late FocusNode kinoSollFn;
    late FocusNode bistroSollFn;
    late TextEditingController differenzCtrl;
    late TextEditingController kinoSollCtrl;
    late TextEditingController bistroSollCtrl;

    setUp(() {
      differenzFn = FocusNode();
      kinoSollFn = FocusNode();
      bistroSollFn = FocusNode();
      differenzCtrl = TextEditingController();
      kinoSollCtrl = TextEditingController();
      bistroSollCtrl = TextEditingController();
    });

    tearDown(() {
      differenzFn.dispose();
      kinoSollFn.dispose();
      bistroSollFn.dispose();
      differenzCtrl.dispose();
      kinoSollCtrl.dispose();
      bistroSollCtrl.dispose();
    });

    FocusNode? erstesLeeresFeld() {
      return const Schritt2FokusHelper().erstesLeeresFeld(
        kinoSollFocusNode: kinoSollFn,
        kinoSollController: kinoSollCtrl,
        bistroSollFocusNode: bistroSollFn,
        bistroSollController: bistroSollCtrl,
        differenzAnfangsbestandFocusNode: differenzFn,
        differenzAnfangsbestandController: differenzCtrl,
        ausgabenLabelFocusNode: const <FocusNode>[],
        ausgabenLabelController: const <TextEditingController>[],
        ausgabenBetragFocusNode: const <FocusNode>[],
        ausgabenBetragController: const <TextEditingController>[],
        ecBelegLabelFocusNode: const <FocusNode>[],
        ecBelegLabelController: const <TextEditingController>[],
        kartenartenGesamtBetragFocusNode: const <FocusNode>[],
        kartenartenGesamtBetragController: const <TextEditingController>[],
        zahlungsartZeilen: const [],
        // Visuelle Reihenfolge: Differenz steht vor Kino-SOLL.
        fokusReihenfolge: <FocusNode>[differenzFn, kinoSollFn, bistroSollFn],
      );
    }

    test('alles leer → Kino-SOLL, nicht die optionale Differenz', () {
      expect(erstesLeeresFeld(), same(kinoSollFn));
    });

    test('Kino-SOLL gefuellt → Bistro-SOLL', () {
      kinoSollCtrl.text = '100,00';
      expect(erstesLeeresFeld(), same(bistroSollFn));
    });

    test('Differenz gefuellt, Kino-SOLL leer → weiterhin Kino-SOLL', () {
      differenzCtrl.text = '5,00';
      expect(erstesLeeresFeld(), same(kinoSollFn));
    });

    test('nur Differenz leer, alles andere gefuellt → kein Erstfokus', () {
      kinoSollCtrl.text = '100,00';
      bistroSollCtrl.text = '50,00';
      expect(erstesLeeresFeld(), isNull);
    });
  });
}
