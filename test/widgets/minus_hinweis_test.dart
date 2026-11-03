import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_differenz_section.dart';
import 'package:kino_bar_app/widgets/uebertrag_umschlag_inhalt.dart';

/// Run 505: roter Prüfhinweis in Schritt 3 bei mehr als 30 € Minus.
void main() {
  group('UebertragUmschlagInhalt.minusHinweis', () {
    test('genau -30,00 € und weniger Minus: kein Hinweis', () {
      expect(UebertragUmschlagInhalt.minusHinweis(-3000), isNull);
      expect(UebertragUmschlagInhalt.minusHinweis(-2999), isNull);
      expect(UebertragUmschlagInhalt.minusHinweis(0), isNull);
      expect(UebertragUmschlagInhalt.minusHinweis(50000), isNull);
    });

    test('ab -30,01 €: Hinweis mit Kellnerportemonnaie', () {
      final String? text = UebertragUmschlagInhalt.minusHinweis(-3001);
      expect(text, isNotNull);
      expect(text, contains('Kellnerportemonnaie'));
      expect(text, contains('Münzgeldkassette'));
    });
  });

  Future<void> zeige(WidgetTester tester, int differenzCent) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Schritt3DifferenzSection(
              differenzCent: differenzCent,
              differenzFarbe: Colors.red,
            ),
          ),
        ),
      );

  testWidgets('Schritt 3: Hinweis nur bei mehr als 30 € Minus',
      (WidgetTester tester) async {
    await zeige(tester, -3000);
    expect(find.textContaining('Kellnerportemonnaie'), findsNothing);

    await zeige(tester, -4500);
    expect(find.textContaining('Kellnerportemonnaie'), findsOneWidget);
  });
}
