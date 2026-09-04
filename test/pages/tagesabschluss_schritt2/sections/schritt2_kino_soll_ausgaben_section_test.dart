import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/models/ausgaben_zeile.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_kino_soll_ausgaben_section.dart';

/// Test-Harness, die die Ausgaben-Zeilenverwaltung so nachbildet wie
/// _TagesabschlussSchritt2SeiteState (Run 429: `List<AusgabenZeile>` statt
/// paralleler Listen) — ohne die restliche, deutlich schwerere Seite
/// (Entwurf-Persistenz, Config-Services, Scan-Ablauf) mit aufzubauen.
class _AusgabenTestHarness extends StatefulWidget {
  const _AusgabenTestHarness();

  @override
  State<_AusgabenTestHarness> createState() => _AusgabenTestHarnessState();
}

class _AusgabenTestHarnessState extends State<_AusgabenTestHarness> {
  final List<AusgabenZeile> _ausgaben = <AusgabenZeile>[AusgabenZeile(id: 0)];
  int _naechsteId = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Schritt2KinoSollUndAusgabenSection(
          kinoSollEingabeZeile: const Text('Kino SOLL Zeile'),
          bistroSollEingabeZeile: null,
          ausgabenIds: _ausgaben.map((AusgabenZeile z) => z.id).toList(),
          ausgabenLabelController:
              _ausgaben.map((AusgabenZeile z) => z.labelController).toList(),
          ausgabenLabelFocusNode:
              _ausgaben.map((AusgabenZeile z) => z.labelFocusNode).toList(),
          ausgabenBetragController:
              _ausgaben.map((AusgabenZeile z) => z.betragController).toList(),
          ausgabenBetragFocusNode:
              _ausgaben.map((AusgabenZeile z) => z.betragFocusNode).toList(),
          textInputActionFuerSchritt2: (_) => TextInputAction.done,
          beiEingabeAbgeschlossen: (_) {},
          onAusgabenLabelGeaendert: (int i, String wert) =>
              setState(() => _ausgaben[i].label = wert),
          onAusgabenLabelGeloescht: (int i) =>
              setState(() => _ausgaben[i].label = ''),
          onAusgabenBetragGeaendert: (int i, String wert) {},
          onAusgabeEntfernen: (int i) {
            if (_ausgaben.length <= 1) return;
            setState(() => _ausgaben.removeAt(i).dispose());
          },
          onAusgabeHinzufuegen: () =>
              setState(() => _ausgaben.add(AusgabenZeile(id: _naechsteId++))),
        ),
      ),
    );
  }
}

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

  testWidgets(
    'Ausgabe entfernen verschiebt die Werte der nachfolgenden Zeile '
    'korrekt nach vorne, statt sie zu vertauschen/zu verlieren '
    '(Run 429: List<AusgabenZeile> statt paralleler Listen)',
    (WidgetTester tester) async {
      await tester.pumpWidget(const _AusgabenTestHarness());

      // Zweite Zeile hinzufuegen.
      await tester.tap(find.text('+ Ausgabe hinzufügen'));
      await tester.pump();
      expect(find.byType(TextField), findsNWidgets(4)); // 2 Zeilen x 2 Felder

      // Zeile 0 (TextFields 0/1) und Zeile 1 (TextFields 2/3) befuellen.
      await tester.enterText(find.byType(TextField).at(0), 'Erste');
      await tester.enterText(find.byType(TextField).at(2), 'Zweite');
      await tester.pump();
      expect(find.text('Erste'), findsOneWidget);
      expect(find.text('Zweite'), findsOneWidget);

      // Zeile 0 entfernen -> "Zweite" muss jetzt allein/vorne stehen,
      // "Erste" darf nirgends mehr auftauchen (kein Index-Versatz).
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Zweite'), findsOneWidget);
      expect(find.text('Erste'), findsNothing);
      // Nur noch 1 Zeile -> Loeschen-Button wieder ausgeblendet.
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    },
  );
}
