import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_wechselgeld_entnahme_section.dart';

void main() {
  Widget baue({required bool aktiv, ValueChanged<bool>? beiAktiv}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Schritt1WechselgeldEntnahmeSection(
            aktiv: aktiv,
            beiAktivGeaendert: beiAktiv ?? (_) {},
            betragController: TextEditingController(),
            grundController: TextEditingController(),
            betragFocusNode: FocusNode(),
            grundFocusNode: FocusNode(),
            beiBetragGeaendert: (_) {},
            beiGrundGeaendert: (_) {},
            betragFehlerhaft: false,
            grundFehlerhaft: false,
          ),
        ),
      ),
    );
  }

  testWidgets('Schalter aus: nur die Schalterzeile, keine Eingabefelder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(baue(aktiv: false));

    expect(find.textContaining('Wechselgeldentnahme'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('Zettel'), findsNothing);
  });

  testWidgets('Schalter an: Betrag, Grund und roter Zettel-Hinweis sichtbar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(baue(aktiv: true));

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.textContaining('Zettel'), findsOneWidget);
  });

  testWidgets('Tippen auf den Schalter meldet den neuen Zustand', (
    WidgetTester tester,
  ) async {
    bool? gemeldet;
    await tester.pumpWidget(
      baue(aktiv: false, beiAktiv: (bool v) => gemeldet = v),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(gemeldet, isTrue);
  });
}
