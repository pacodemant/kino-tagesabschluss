import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/domain/usecases/speichere_tagesabschluss_usecase.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3/sections/schritt3_soll_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:kino_bar_app/pages/uebertrag_umschlag_seite.dart';
import 'package:kino_bar_app/pages/verlauf_detail_seite.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simuliert einen SB-Abend mit drei Terminal-Belegen (Run 486a), statt
/// sie zu scannen:
///   60561994 (Bistro)    300,00 €
///   60561996 (Kasse 2)   200,00 €
///   60561997 (Kinokasse) 250,00 €  <- am Kino-Kassensystem
/// Kino SOLL lt. Ticket-Umsatz 1.000,00 €, Bistro SOLL 500,00 €,
/// Bar IST 1.000,00 €. Mit Kinokassen-Anteil geht die Kasse genau auf
/// (Soll 1.750,00 = Ist 1.750,00), ohne ihn zeigte sie +250,00 €.
void main() {
  const String kinoIdSb = 'kino_01';

  const TagesabschlussSchritt3Argumente argumente =
      TagesabschlussSchritt3Argumente(
    kinoId: kinoIdSb,
    kinoName: 'Schauburg',
    scheineCent: 130000,
    loseMuenzenCent: 0,
    rollenCent: 0,
    umschlaegeCent: 0,
    wechselgeldSollwertCent: 30000,
    kinoSollCent: 100000,
    bistroSollCent: 50000,
    ausgabenCent: 0,
    ecBelegeCent: <int>[30000, 20000, 25000],
    ecBelegeLabels: <String>['60561994', '60561996', '60561997'],
    differenzAnfangsbestandCent: 0,
    stueckzahlen: <String, int>{},
    loseMuenzenNachArtCent: <String, int>{},
  );

  late Directory tempDir;

  // Echte Hive-I/O nur hier im setUp, nicht im testWidgets-Body (dort
  // laeuft simulierte Zeit, echte Festplattenzugriffe haengen sonst).
  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('box_schritt3_entwuerfe');
  });

  void setUpMitPrefs(Map<String, Object> prefs) {
    SharedPreferences.setMockInitialValues(prefs);
  }

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  /// Baut Schritt 3 auf und liefert den per Auto-Save gespeicherten
  /// Abschluss (so wie er in den Verlauf ginge).
  Future<TagesabschlussFinal> schritt3Aufbauen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    TagesabschlussFinal? gespeichert;
    await tester.pumpWidget(
      MaterialApp(
        home: TagesabschlussSchritt3Seite(
          argumente: argumente,
          autoSaveUeberschreibung: (
            TagesabschlussFinal abschluss, {
            bool ueberschreiben = false,
            bool alsZusaetzlicheAbrechnung = false,
          }) async {
            gespeichert = abschluss;
            return const SpeichereTagesabschlussErgebnis(
              bereitsVorhanden: false,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(gespeichert, isNotNull);
    return gespeichert!;
  }

  /// Wert der InfoZeile mit [label] (Schritt 3 zeigt SB seit Run 491c im
  /// Umschlag-Layout, nicht mehr in den Schritt3-Sections).
  String zeilenWert(WidgetTester tester, String label) => tester
      .widget<InfoZeile>(
        find.byWidgetPredicate((Widget w) => w is InfoZeile && w.label == label),
      )
      .wert;

  testWidgets(
      'Test 1+3: TID Kinokasse gesetzt -> Schritt 3, Übertrag-Seite und '
      'Verlauf zeigen Kino Soll 1.250,00 inkl. "davon Kartenterminal 60561997 '
      '250,00", Kasse geht auf (Differenz 0,00)',
      (WidgetTester tester) async {
    setUpMitPrefs(<String, Object>{
      TerminalIdsConfigService.kinokasseTidPrefKey(kinoIdSb): '60561997',
    });
    final TagesabschlussFinal abschluss = await schritt3Aufbauen(tester);

    // Schritt 3 (SB-Umschlag-Layout seit Run 491c)
    expect(zeilenWert(tester, '+ Kino SOLL (f. Umschlag)'), '1.250,00 €');
    expect(find.text('davon Kartenterminal 60561997'), findsOneWidget);
    expect(zeilenWert(tester, '= Gesamt SOLL'), '1.750,00 €');
    expect(zeilenWert(tester, 'Differenz'), '0,00 €');
    expect(find.byType(Schritt3SollSection), findsNothing);

    // Gespeicherter Verlaufseintrag
    expect(abschluss.kinoSollCent, 100000);
    expect(abschluss.kinokasseKarteCent, 25000);
    expect(abschluss.gesamtSollCent, 175000);
    expect(abschluss.gesamtIstCent, 175000);
    expect(abschluss.differenzGesamtCent, 0);

    // Nach Speichern/Laden (wie nach App-Neustart)
    final TagesabschlussFinal geladen =
        TagesabschlussFinal.fromJson(abschluss.toJson());

    // "Übertrag auf Umschlag" von der Startseite
    await tester.pumpWidget(
      MaterialApp(home: UebertragUmschlagSeite(abschluss: geladen)),
    );
    await tester.pumpAndSettle();
    expect(find.text('1.250,00 €'), findsOneWidget);
    expect(find.text('davon Kartenterminal 60561997'), findsOneWidget);
    // Seit Run 489 SB-Umschlag: "davon"-Zeile + EC-Zeile des KK-Terminals
    // (einziges eingetragenes Terminal in diesem Test).
    expect(find.text('250,00 €'), findsNWidgets(2));
    expect(find.text('0,00 €'), findsWidgets);

    // Verlauf-Detail, Kachel "Umsätze" aufklappen
    await tester.pumpWidget(
      MaterialApp(home: VerlaufDetailSeite(abschluss: geladen)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umsätze'));
    await tester.pumpAndSettle();
    expect(find.text('Kino SOLL'), findsOneWidget);
    expect(find.text('1.250,00 €'), findsOneWidget);
    expect(find.text('davon Kartenterminal 60561997'), findsOneWidget);
  });

  testWidgets(
      'Test 2: Umsätze-Seite unverändert -> gespeichertes Kino SOLL '
      '(Grundlage der Eingabe) bleibt der Ticket-Umsatz 1.000,00',
      (WidgetTester tester) async {
    setUpMitPrefs(<String, Object>{
      TerminalIdsConfigService.kinokasseTidPrefKey(kinoIdSb): '60561997',
    });
    final TagesabschlussFinal abschluss = await schritt3Aufbauen(tester);
    expect(abschluss.kinoSollCent, 100000);
    expect(abschluss.toJson()['kinoSollCent'], 100000);
  });

  testWidgets(
      'Test 4: ohne TID Kinokasse -> wie bisher, keine "davon"-Zeile, '
      'Differenz +250,00', (WidgetTester tester) async {
    setUpMitPrefs(<String, Object>{});
    final TagesabschlussFinal abschluss = await schritt3Aufbauen(tester);

    expect(zeilenWert(tester, '+ Kino SOLL (f. Umschlag)'), '1.000,00 €');
    expect(find.textContaining('davon Karte'), findsNothing);
    expect(abschluss.kinokasseKarteCent, 0);
    expect(abschluss.differenzGesamtCent, 25000);
  });

  testWidgets(
      'Test 4b: TID Kinokasse nur bei Atlantis gesetzt, Abrechnung bei SB '
      '-> kein Effekt (Einstellung gilt pro Kino)', (WidgetTester tester) async {
    setUpMitPrefs(<String, Object>{
      TerminalIdsConfigService.kinokasseTidPrefKey('kino_03'): '60561997',
    });
    final TagesabschlussFinal abschluss = await schritt3Aufbauen(tester);
    expect(abschluss.kinokasseKarteCent, 0);
    expect(find.textContaining('davon Karte'), findsNothing);
  });

  testWidgets(
      'Test 5: alter Verlaufseintrag (JSON ohne neues Feld) -> Werte '
      'unverändert, keine "davon"-Zeile', (WidgetTester tester) async {
    setUpMitPrefs(<String, Object>{});
    final TagesabschlussFinal alt = TagesabschlussFinal.fromJson(
      <String, dynamic>{
        'kinoId': kinoIdSb,
        'kinoName': 'Schauburg',
        'datumIso': '2026-10-10T00:00:00.000',
        'createdAtIso': '2026-10-10T23:00:00.000',
        'kinoSollCent': 100000,
        'bistroSollCent': 50000,
        'ecBelegeCent': <int>[30000, 20000, 25000],
        'ecBelegeLabels': <String>['60561994', '60561996', '60561997'],
        'ecUmsatzGesamtCent': 75000,
        'barBestandAbzglWechselgeldCent': 100000,
        'gesamtSollCent': 150000,
        'gesamtIstCent': 175000,
        'differenzGesamtCent': 25000,
      },
    );
    await tester.pumpWidget(
      MaterialApp(home: UebertragUmschlagSeite(abschluss: alt)),
    );
    await tester.pumpAndSettle();
    // Kino Soll und bar IST sind hier beide 1.000,00 €
    expect(find.text('1.000,00 €'), findsNWidgets(2));
    expect(find.text('1.500,00 €'), findsOneWidget);
    // SB-Umschlag (Run 489) hat mehr Zeilen, Differenz liegt tiefer.
    await tester.scrollUntilVisible(find.text('+250,00 €'), 200);
    expect(find.text('+250,00 €'), findsOneWidget);
    expect(find.textContaining('davon Karte'), findsNothing);
  });
}
