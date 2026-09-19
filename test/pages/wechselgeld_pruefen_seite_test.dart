import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/wechselgeld_pruefen_seite.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  TagesabschlussFinal heutigerAbschluss({int? entnahmeCent, String? grund}) {
    final DateTime tag = DatumsHelper.logischerAbrechnungsTag();
    return TagesabschlussFinal(
      kinoId: 'kino_01',
      kinoName: 'Schauburg',
      datum: tag,
      createdAt: tag.add(const Duration(hours: 22)),
      scheineCent: 0,
      loseMuenzenCent: 0,
      rollenCent: 0,
      umschlaegeCent: 0,
      kassenbestandGesamtCent: 0,
      wechselgeldSollwertCent: 0,
      barBestandAbzglWechselgeldCent: 0,
      kinoSollCent: 0,
      bistroSollCent: 0,
      ausgabenCent: 0,
      ecBelegeCent: const <int>[],
      ecUmsatzGesamtCent: 0,
      gesamtSollCent: 0,
      gesamtIstCent: 0,
      differenzGesamtCent: 0,
      differenzAnfangsbestandCent: 0,
      wechselgeldEntnahmeCent: entnahmeCent,
      wechselgeldEntnahmeGrund: grund,
    );
  }

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('box_tagesabschluesse');
    await Hive.openBox('box_wechselgeld_entwuerfe');
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<void> oeffne(
    WidgetTester tester, {
    required bool ausTagesabrechnung,
    TagesabschlussFinal? abschluss,
    Map<String, dynamic>? entwurf,
    DateTime? jetzt,
  }) async {
    // Hohes Testfenster: die ganze Seite wird gebaut, ohne dass Felder
    // beim Scrollen halb unter der Kopfzeile verschwinden.
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await LokalerSpeicher.speichereWechselgeldSollwertCent('kino_01', 200000);
      if (entwurf != null) {
        await LokalerSpeicher.speichereWechselgeldZaehlEntwurf(
          'kino_01',
          entwurf,
        );
      }
      if (abschluss != null) {
        await LokalerSpeicher.speichereFinalenTagesabschluss(abschluss);
      }
    });
    await tester.pumpWidget(
      MaterialApp(
        home: WechselgeldPruefenSeite(
          kinoId: 'kino_01',
          ausTagesabrechnung: ausTagesabrechnung,
          jetztFuerTest: jetzt,
        ),
      ),
    );
    // Laden läuft gegen echten Speicher: außerhalb der Fake-Zeit warten.
    for (int i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  // Seite abbauen und ausstehende Timer (z. B. Auto-Fokus) ablaufen lassen.
  Future<void> raeumeAuf(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  }

  // Der Seitenkörper ist eine CustomScrollView (Slivers werden lazy
  // gebaut): bis zur Zusammenfassung ganz unten scrollen.
  Future<void> zeigeZusammenfassung(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Zusammenfassung'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }

  // Feste Test-Uhrzeiten (unabhängig von der echten Uhr).
  final DateTime vormittags = DateTime(2026, 9, 19, 10, 0);
  final DateTime nachts = DateTime(2026, 9, 20, 0, 40);

  testWidgets(
    'Abend-Prüfung mit Wechselgeldentnahme: Zeile mit Grund, Sollwert '
    'gekürzt (Differenz −1.400 €), Infokasten oben und Notiz-Hinweis',
    (WidgetTester tester) async {
      await oeffne(
        tester,
        ausTagesabrechnung: true,
        abschluss: heutigerAbschluss(
          entnahmeCent: 60000,
          grund: 'Rollengeld-Vorschuss',
        ),
      );
      await zeigeZusammenfassung(tester);

      expect(
        find.text('Wechselgeldentnahme (Rollengeld-Vorschuss)'),
        findsOneWidget,
      );
      // Infokasten + Zusammenfassungszeile nennen den Betrag
      expect(find.textContaining('600,00'), findsNWidgets(2));
      // Differenz = 0 € gezählt − (2.000 € Sollwert − 600 € Entnahme);
      // "1.400,00" steht in Infokasten und Differenz
      expect(find.textContaining('1.400,00'), findsNWidgets(2));
      expect(
        find.textContaining('weil die Entnahme morgen wieder zurückgelegt'),
        findsOneWidget,
      );
      expect(find.textContaining('Notiz mit Betrag und Grund'), findsOneWidget);
      // Abend: kein Morgen-Schalter
      expect(find.byType(Switch), findsNothing);
      await raeumeAuf(tester);
    },
  );

  testWidgets(
    'Abend-Prüfung ohne Wechselgeldentnahme: keine Zeile, kein Infokasten, '
    'kein Hinweis',
    (WidgetTester tester) async {
      await oeffne(
        tester,
        ausTagesabrechnung: true,
        abschluss: heutigerAbschluss(),
      );
      await zeigeZusammenfassung(tester);

      expect(find.textContaining('Wechselgeldentnahme'), findsNothing);
      expect(find.textContaining('Notiz mit Betrag'), findsNothing);
      await raeumeAuf(tester);
    },
  );

  testWidgets(
    'Vormittags von der Startseite, aber heute schon abgerechnet: gilt als '
    'Abend, Wechselgeldentnahme kommt automatisch (kein Morgen-Schalter)',
    (WidgetTester tester) async {
      await oeffne(
        tester,
        ausTagesabrechnung: false,
        jetzt: vormittags,
        abschluss: heutigerAbschluss(
          entnahmeCent: 60000,
          grund: 'Rollengeld-Vorschuss',
        ),
      );
      await zeigeZusammenfassung(tester);

      expect(
        find.text('Wechselgeldentnahme (Rollengeld-Vorschuss)'),
        findsOneWidget,
      );
      expect(find.byType(Switch), findsNothing);
      await raeumeAuf(tester);
    },
  );

  testWidgets(
    '00:40 Uhr (vor dem 5-Uhr-Knick) gilt als Abend: kein Morgen-Schalter',
    (WidgetTester tester) async {
      await oeffne(tester, ausTagesabrechnung: false, jetzt: nachts);
      await zeigeZusammenfassung(tester);

      expect(find.byType(Switch), findsNothing);
      await raeumeAuf(tester);
    },
  );

  testWidgets(
    'Morgen-Prüfung: Schalter startet aus, ohne Betragsfeld, Infokasten '
    'und Wechselgeldentnahme-Zeile',
    (WidgetTester tester) async {
      await oeffne(tester, ausTagesabrechnung: false, jetzt: vormittags);
      await zeigeZusammenfassung(tester);

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(
        find.text('Notiz über Wechselgeldentnahme gefunden'),
        findsOneWidget,
      );
      expect(find.textContaining('Betrag laut Notiz'), findsNothing);
      expect(find.text('Wechselgeldentnahme'), findsNothing);
      expect(find.textContaining('wird berücksichtigt'), findsNothing);
      expect(find.textContaining('Notiz mit Betrag'), findsNothing);
      await raeumeAuf(tester);
    },
  );

  testWidgets(
    'Morgen-Prüfung: gespeicherter Schalter samt Betrag kommt aus dem '
    'Entwurf zurück, kürzt den Sollwert und zeigt den Infokasten',
    (WidgetTester tester) async {
      await oeffne(
        tester,
        ausTagesabrechnung: false,
        jetzt: vormittags,
        entwurf: <String, dynamic>{
          'herkunft': 'morgen',
          'wechselgeldentnahmeAktiv': true,
          'wechselgeldentnahmeCent': 60000,
        },
      );
      await zeigeZusammenfassung(tester);

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.text('Wechselgeldentnahme'), findsOneWidget);
      // Infokasten + Differenz nennen 1.400,00
      expect(find.textContaining('1.400,00'), findsNWidgets(2));
      expect(find.textContaining('Bis sie zurückgelegt ist'), findsOneWidget);
      // Der Notiz-Hinweis gehört nur zur Abend-Prüfung
      expect(find.textContaining('Notiz mit Betrag'), findsNothing);
      await raeumeAuf(tester);
    },
  );
}
