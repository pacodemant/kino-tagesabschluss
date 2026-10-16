import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_tids_section.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Run 488: Kachel "TIDs" in den Einstellungen.
void main() {
  Future<void> zeigeAufgeklappt(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EinstellungenTidsSection(kinoId: 'kino_01'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('TIDs'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Eingabe von TID + Nummer wird gespeichert; KK lässt sich nur bei '
    'einem Terminal setzen (zweites Häkchen ersetzt das erste)',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await zeigeAufgeklappt(tester);

      final Finder tidFelder = find.byType(TextField);
      // Reihenfolge je Zeile: Nr., TID
      await tester.enterText(tidFelder.at(0), '1');
      await tester.enterText(tidFelder.at(1), '60561994');
      await tester.enterText(tidFelder.at(2), '3');
      await tester.enterText(tidFelder.at(3), '60561997');
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pumpAndSettle();

      final List<TerminalEintrag> gespeichert =
          await TerminalIdsConfigService.ladeTerminals('kino_01');
      expect(gespeichert.map((TerminalEintrag t) => t.tid), <String>[
        '60561994',
        '60561997',
      ]);
      expect(gespeichert.map((TerminalEintrag t) => t.nummer), <String>[
        '1',
        '3',
      ]);
      expect(
        gespeichert.where((TerminalEintrag t) => t.kinokasse).single.tid,
        '60561997',
      );
      expect(find.text('2'), findsOneWidget); // Anzahl im Kachelkopf
    },
  );

  testWidgets(
    'Gerät mit "TID Kinokasse" aus Run 486 zeigt diese TID in der Kachel '
    'mit gesetztem KK-Häkchen',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        TerminalIdsConfigService.kinokasseTidPrefKey('kino_01'): '60561997',
      });
      await zeigeAufgeklappt(tester);

      expect(find.text('60561997'), findsOneWidget);
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox).at(0)).value,
        isTrue,
      );
    },
  );
}
