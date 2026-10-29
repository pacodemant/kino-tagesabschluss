import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2_seite.dart';
import 'package:kino_bar_app/services/zahlungsarten_config_service.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Run 497/498 auf der echten Schritt-2-Seite: Startzustand mit drei
/// eingetragenen Terminals und "Kein Beleg möglich" im Dialog "Beleg
/// fehlt" (Pflichtprüfung, Aufheben, Entwurf).
void main() {
  late Directory tempDir;

  setUpAll(() async {
    await initializeDateFormatting('de_DE');
    tempDir = Directory.systemTemp.createTempSync('hive_s2_');
    Hive.init(tempDir.path);
    await Hive.openBox('box_schritt2_entwuerfe');
    await Hive.openBox('box_schritt3_entwuerfe');
    // Asset einmal außerhalb der Tests laden: sonst hängt die Seite ab dem
    // zweiten Test an einem gecachten Future aus dem vorigen Test.
    await ZahlungsartenConfigService.laden();
  });

  // Kein Hive.close(): Schreibvorgänge der Seite aus der Test-Zone
  // bleiben offen und ließen close() hängen.
  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  // Jeder Test bekommt einen eigenen Standort (frischer Entwurf). Ein
  // box.clear() zwischen den Tests hinge an offenen Schreibvorgängen.
  int testNr = 0;
  String kinoId = '';

  setUp(() {
    kinoId = 'kino_t${testNr++}';
    SharedPreferences.setMockInitialValues(<String, Object>{
      'terminals_$kinoId': jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{'tid': '11111111', 'nummer': '1'},
        <String, dynamic>{'tid': '22222222', 'nummer': '2'},
        <String, dynamic>{'tid': '33333333', 'nummer': '3'},
      ]),
    });
  });

  Future<void> warte(WidgetTester tester) async {
    for (int i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> starteSeite(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: TagesabschlussSchritt2Seite(
          kinoId: kinoId,
          kinoName: 'Schauburg',
          scheineCent: 0,
          loseMuenzenCent: 0,
          rollenCent: 0,
          umschlaegeCent: 0,
          wechselgeldSollwertCent: 0,
          barBestandAbzglWechselgeldCent: 0,
          stueckzahlen: <String, int>{},
          loseMuenzenNachArtCent: <String, int>{},
        ),
      ),
    );
    await warte(tester);
  }

  Future<Map<String, dynamic>?> ladeEntwurf(WidgetTester tester) async =>
      tester.runAsync<Map<String, dynamic>?>(
        () => LokalerSpeicher.ladeSchritt2Entwurf(kinoId),
      );

  Future<void> tippeWeiter(WidgetTester tester) async {
    await tester.tap(find.text('Übertrag auf Umschlag (3/4)'));
    await warte(tester);
  }

  ElevatedButton dialogWeiter(WidgetTester tester) => tester.widget(
        find.widgetWithText(ElevatedButton, 'Weiter').last,
      );

  testWidgets('Start: EC-Kachel offen, drei Terminals sichtbar (Run 497)',
      (WidgetTester tester) async {
    await starteSeite(tester);
    expect(find.text('Gerät 1 · TID 11111111'), findsOneWidget);
    expect(find.text('Gerät 2 · TID 22222222'), findsOneWidget);
    expect(find.text('Gerät 3 · TID 33333333'), findsOneWidget);
    expect(find.text('+ Weiteren Kassenschnitt hinzufügen'), findsOneWidget);
  });

  testWidgets(
      'Beleg fehlt: Weiter erst mit allen Häkchen, Zurück markiert nichts',
      (WidgetTester tester) async {
    await starteSeite(tester);
    await tippeWeiter(tester);

    expect(find.text('Beleg fehlt'), findsOneWidget);
    expect(find.text('Kein Beleg möglich'), findsNWidgets(3));
    expect(dialogWeiter(tester).onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey<String>('kein_beleg_11111111')));
    await tester.tap(find.byKey(const ValueKey<String>('kein_beleg_22222222')));
    await tester.pump();
    expect(dialogWeiter(tester).onPressed, isNull);

    await tester.tap(find.text('Zurück'));
    await warte(tester);
    expect(find.text('Beleg fehlt'), findsNothing);
    expect(find.text('Aufheben'), findsNothing);
    expect((await ladeEntwurf(tester))?['keinBelegMoeglichTids'] ?? <dynamic>[],
        isEmpty);
  });

  testWidgets(
      'alle angehakt: Kachel zeigt "Kein Beleg möglich", Entwurf speichert, '
      'übersteht Neustart, Aufheben nimmt es zurück', (WidgetTester tester) async {
    await starteSeite(tester);
    await tippeWeiter(tester);
    for (final String tid in <String>['11111111', '22222222', '33333333']) {
      await tester.tap(find.byKey(ValueKey<String>('kein_beleg_$tid')));
    }
    await tester.pump();
    expect(dialogWeiter(tester).onPressed, isNotNull);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Weiter').last);
    await warte(tester);
    // Nächste Prüfung (Kino-Soll ist Pflichtfeld) hält die Seite an.
    await tester.tap(find.text('Ändern'));
    await warte(tester);
    // Run 499: die Weiter-Prüfung klappt keine Unterkachel auf (nur die
    // EC-Kachel selbst zeigt "aufgeklappt").
    expect(find.byIcon(Icons.expand_less), findsOneWidget);

    expect(find.text('Kein Beleg möglich'), findsNWidgets(3));
    expect(find.text('Aufheben'), findsNWidgets(3));
    expect(
      (await ladeEntwurf(tester))!['keinBelegMoeglichTids'],
      unorderedEquals(<String>['11111111', '22222222', '33333333']),
    );

    await tester.tap(find.text('Aufheben').first);
    await warte(tester);
    expect(find.text('Aufheben'), findsNWidgets(2));
    expect(
      (await ladeEntwurf(tester))!['keinBelegMoeglichTids'],
      unorderedEquals(<String>['22222222', '33333333']),
    );

    // Neustart: Seite neu aufbauen, Markierung kommt aus dem Entwurf.
    await tester.pumpWidget(const SizedBox.shrink());
    await starteSeite(tester);
    expect(find.text('Kein Beleg möglich'), findsNWidgets(2));
    expect(find.text('Aufheben'), findsNWidgets(2));

    // Erneut Weiter: nur noch Gerät 1 fehlt im Dialog.
    await tippeWeiter(tester);
    expect(find.text('Beleg fehlt'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('kein_beleg_11111111')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('kein_beleg_22222222')),
      findsNothing,
    );
  });

  testWidgets('"manuell eingeben" schließt den Dialog und öffnet nur dieses '
      'Terminal zur Eingabe (Run 499)', (WidgetTester tester) async {
    await starteSeite(tester);
    final int felderVorher = find.byType(TextField).evaluate().length;
    await tippeWeiter(tester);
    await tester.tap(find.byKey(const ValueKey<String>('manuell_22222222')));
    await warte(tester);

    expect(find.text('Beleg fehlt'), findsNothing);
    expect(find.byIcon(Icons.expand_less), findsNWidgets(2));
    expect(find.byType(TextField).evaluate().length, greaterThan(felderVorher));
    expect(FocusManager.instance.primaryFocus?.context, isNotNull);
    expect(
      (await ladeEntwurf(tester))?['keinBelegMoeglichTids'] ?? <dynamic>[],
      isEmpty,
    );
  });
}
