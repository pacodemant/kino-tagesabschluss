import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2_seite.dart';
import 'package:kino_bar_app/services/zahlungsarten_config_service.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Run 499: Unterkacheln nach dem Laden zugeklappt; der Mülleimer setzt
/// den Beleg eines eingetragenen Terminals zurück, statt ihn zu entfernen.
void main() {
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'terminals_kino_01': jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{'tid': '11111111', 'nummer': '1'},
        <String, dynamic>{'tid': '22222222', 'nummer': '2'},
        <String, dynamic>{'tid': '33333333', 'nummer': '3'},
      ]),
    });
    await initializeDateFormatting('de_DE');
    tempDir = Directory.systemTemp.createTempSync('hive_s2e_');
    Hive.init(tempDir.path);
    await Hive.openBox('box_schritt2_entwuerfe');
    await Hive.openBox('box_schritt3_entwuerfe');
    // Asset einmal außerhalb der Tests laden (siehe
    // kein_beleg_moeglich_seite_test.dart).
    await ZahlungsartenConfigService.laden();
    await LokalerSpeicher.speichereSchritt2Entwurf('kino_01', <String, dynamic>{
      'kinoId': 'kino_01',
      'isoDatum': DatumsHelper.logischesIsoDatum(),
      'ecBelegeCent': <int>[12345, 0, 0],
      'ecBelegeLabels': <String>['11111111', '22222222', '33333333'],
      'scanHatStattgefunden': <bool>[true, false, false],
      'kartenartenGesamtBetragCent': <int?>[12345, null, null],
    });
  });

  // Kein Hive.close(), siehe kein_beleg_moeglich_seite_test.dart.
  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<void> warte(WidgetTester tester) async {
    for (int i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('Entwurf laden: alle Unterkacheln zu, Mülleimer bei Gerät 1 '
      'setzt zurück, Unterkachel bleibt', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: TagesabschlussSchritt2Seite(
          kinoId: 'kino_01',
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

    expect(find.text('Gerät 1 · TID 11111111'), findsOneWidget);
    expect(find.text('123,45 €'), findsWidgets);
    // Nur die EC-Kachel selbst ist offen.
    expect(find.byIcon(Icons.expand_less), findsOneWidget);

    await tester.tap(find.byTooltip('Beleg entfernen').first);
    await warte(tester);
    await tester.tap(find.text('Löschen').last);
    await warte(tester);

    expect(find.text('Gerät 1 · TID 11111111'), findsOneWidget);
    expect(find.text('Gerät 2 · TID 22222222'), findsOneWidget);
    expect(find.text('Gerät 3 · TID 33333333'), findsOneWidget);
    expect(find.text('123,45 €'), findsNothing);
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    final Map<String, dynamic>? entwurf = await tester
        .runAsync<Map<String, dynamic>?>(
          () => LokalerSpeicher.ladeSchritt2Entwurf('kino_01'),
        );
    expect(entwurf!['ecBelegeCent'], <int>[0, 0, 0]);
    expect(entwurf['ecBelegeLabels'], <String>[
      '11111111',
      '22222222',
      '33333333',
    ]);
  });
}
