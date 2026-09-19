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

  testWidgets(
    'Abend-Prüfung mit Wechselgeldentnahme: Zeile mit Grund, Sollwert '
    'gekürzt (Differenz −1.400 € statt −2.000 €) und oranger Zettel-Hinweis',
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
      expect(find.textContaining('600,00'), findsOneWidget);
      // Differenz = 0 € gezählt − (2.000 € Sollwert − 600 € Entnahme)
      expect(find.textContaining('1.400,00'), findsOneWidget);
      expect(find.textContaining('Zettel mit Betrag'), findsOneWidget);
      // Abend: kein Morgen-Schalter
      expect(find.byType(Switch), findsNothing);
      await raeumeAuf(tester);
    },
  );

  testWidgets(
    'Abend-Prüfung ohne Wechselgeldentnahme: keine Zeile, kein Hinweis',
    (WidgetTester tester) async {
      await oeffne(
        tester,
        ausTagesabrechnung: true,
        abschluss: heutigerAbschluss(),
      );
      await zeigeZusammenfassung(tester);

      expect(find.textContaining('Wechselgeldentnahme'), findsNothing);
      expect(find.textContaining('Zettel mit Betrag'), findsNothing);
      await raeumeAuf(tester);
    },
  );

  // Der Morgen-Modus gilt nur vor 18 Uhr (siehe _istAbendZeit der Seite);
  // ab 18 Uhr würde die Seite den Morgen-Entwurf als veraltet verwerfen.
  final String? nurVor18Uhr = DateTime.now().hour >= 18
      ? 'Morgen-Modus nur vor 18 Uhr prüfbar'
      : null;

  testWidgets('Morgen-Prüfung: Schalter startet aus, ohne Betragsfeld und ohne '
      'Wechselgeldentnahme-Zeile', (WidgetTester tester) async {
    await oeffne(tester, ausTagesabrechnung: false);
    await zeigeZusammenfassung(tester);

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(
      find.text('Notiz über Wechselgeldentnahme gefunden'),
      findsOneWidget,
    );
    expect(find.textContaining('Betrag laut Zettel'), findsNothing);
    expect(find.text('Wechselgeldentnahme'), findsNothing);
    expect(find.textContaining('Zettel mit Betrag'), findsNothing);
    await raeumeAuf(tester);
  }, skip: nurVor18Uhr != null);

  testWidgets(
    'Morgen-Prüfung: gespeicherter Schalter samt Betrag kommt aus dem '
    'Entwurf zurück und kürzt den Sollwert (kein Zettel-Hinweis)',
    (WidgetTester tester) async {
      await oeffne(
        tester,
        ausTagesabrechnung: false,
        entwurf: <String, dynamic>{
          'herkunft': 'morgen',
          'wechselgeldentnahmeAktiv': true,
          'wechselgeldentnahmeCent': 60000,
        },
      );
      await zeigeZusammenfassung(tester);

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.text('Wechselgeldentnahme'), findsOneWidget);
      // Differenz = 0 € gezählt − (2.000 € Sollwert − 600 € Entnahme)
      expect(find.textContaining('1.400,00'), findsOneWidget);
      expect(find.textContaining('Zettel mit Betrag'), findsNothing);
      await raeumeAuf(tester);
    },
    skip: nurVor18Uhr != null,
  );
}
