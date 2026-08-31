import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_kino_soll_ausgaben_section.dart';

void main() {
  testWidgets(
    'zeigt die Umsaetze-Info-Zeilen NICHT mehr an (Run 406 entfernt, '
    'da rein informativ und ohne Mehrwert fuer den MA)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Schritt2KinoSollUndAusgabenSection(
              kinoSollEingabeZeile: const Text('Kino SOLL Zeile'),
              bistroSollEingabeZeile: null,
              ausgabenIds: const <int>[0],
              ausgabenLabelController: <TextEditingController>[
                TextEditingController(),
              ],
              ausgabenLabelFocusNode: <FocusNode>[FocusNode()],
              ausgabenBetragController: <TextEditingController>[
                TextEditingController(),
              ],
              ausgabenBetragFocusNode: <FocusNode>[FocusNode()],
              textInputActionFuerSchritt2: (_) => TextInputAction.done,
              beiEingabeAbgeschlossen: (_) {},
              onAusgabenLabelGeaendert: (_, _) {},
              onAusgabenLabelGeloescht: (_) {},
              onAusgabenBetragGeaendert: (_, _) {},
              onAusgabeEntfernen: (_) {},
              onAusgabeHinzufuegen: () {},
            ),
          ),
        ),
      );

      expect(find.text('Umsätze gesamt (Info)'), findsNothing);
      expect(find.text('Umsätze abzgl. Ausgaben (Info)'), findsNothing);
      expect(find.text('Kino SOLL Zeile'), findsOneWidget);
      expect(find.text('+ Ausgabe hinzufügen'), findsOneWidget);
    },
  );
}
