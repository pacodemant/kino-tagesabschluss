import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/domain/usecases/speichere_tagesabschluss_usecase.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deckt die Sende-Orchestrierung in _doApiUpload() ab — dort lagen
/// mehrere produktive Fehler, die vorher unentdeckt blieben (Run 436:
/// Race zwischen Upload und Navigation; Run 448: Netzwerkfehler als
/// "gesendet" verbucht; Run 450/451: QuotaExceededError beim lokalen
/// Merker maskierte einen erfolgreichen Versand als Fehlschlag).
///
/// Der echte Netzwerk-Upload (ApiUploadService.upload ruft direkt
/// http.post/http.put auf) und der echte Auto-Save/lokale Sende-Merker
/// (schreiben via LokalerSpeicher in echte Hive-Boxen) sind in einem
/// Widget-Test ohne DI nicht sinnvoll nutzbar — echte Festplatten-
/// Schreibvorgänge können in Flutters simulierter Pump-Zeit hängen
/// bleiben (beobachtet: Testlauf blockierte 10 Minuten in tearDown).
/// Deshalb nutzt dieser Test ausschließlich die dafür eingeführten
/// Test-Seams (Run 456): uploadUeberschreibung,
/// lokalerSendeMerkerUeberschreibung, autoSaveUeberschreibung.
void main() {
  TagesabschlussSchritt3Argumente argumente() =>
      const TagesabschlussSchritt3Argumente(
        kinoId: 'test_kino_schritt3',
        kinoName: 'Test-Kino',
        scheineCent: 10000,
        loseMuenzenCent: 0,
        rollenCent: 0,
        umschlaegeCent: 0,
        wechselgeldSollwertCent: 0,
        kinoSollCent: 10000,
        bistroSollCent: 0,
        ausgabenCent: 0,
        ecBelegeCent: <int>[],
        differenzAnfangsbestandCent: 0,
        stueckzahlen: <String, int>{},
        loseMuenzenNachArtCent: <String, int>{},
      );

  Future<SpeichereTagesabschlussErgebnis> autoSaveErfolgFake(
    TagesabschlussFinal _, {
    bool ueberschreiben = false,
    bool alsZusaetzlicheAbrechnung = false,
  }) async =>
      const SpeichereTagesabschlussErgebnis(bereitsVorhanden: false);

  /// Tippt den Sende-Button + die Bestätigung "Senden" an. Der Button
  /// steht am Ende einer scrollbaren ListView und liegt je nach
  /// Testgerät außerhalb des ohne Scrollen gebauten Bereichs (Flutter
  /// baut bei einer ListView nur Kinder im sichtbaren Bereich + kleinem
  /// Cache-Rand) — deshalb wird zuerst dorthin gescrollt statt die
  /// Fenstergröße zu erraten. Nach dem Tippen bewusst KEIN
  /// pumpAndSettle(): während des Uploads zeigt die Seite einen
  /// indeterminate LinearProgressIndicator (TagesabschlussScaffold,
  /// zeigeLadebalken), der erst nach dem Schließen des anschließenden,
  /// hier nicht weggetippten Info-Dialogs endet — pumpAndSettle() würde
  /// auf die nie endende Animation warten und in einen Timeout laufen.
  Future<void> sendeVersuchen(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Abrechnung an Büro senden'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Abrechnung an Büro senden'));
    await tester.pumpAndSettle();
    expect(find.text('Abrechnung senden?'), findsOneWidget);
    await tester.tap(find.text('Senden'));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'dev_api_upload_aktiv': true,
    });
    // Nur für den (rein lesenden) Schritt-3-Entwurf-Check beim
    // Seitenaufbau — Auto-Save und der lokale Sende-Merker laufen in
    // diesem Test über die Fakes oben, nicht über echtes Hive.
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('box_schritt3_entwuerfe');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets(
      'Erfolgsfall: Upload und lokaler Merker gelingen -> '
      '"Abrechnung gesendet"-Dialog erscheint, kein Fehler-Popup',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TagesabschlussSchritt3Seite(
          argumente: argumente(),
          autoSaveUeberschreibung: autoSaveErfolgFake,
          uploadUeberschreibung: (TagesabschlussFinal _) async =>
              <String, dynamic>{'report_id': 1},
          lokalerSendeMerkerUeberschreibung: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await sendeVersuchen(tester);

    expect(find.text('Abrechnung gesendet'), findsOneWidget);
    expect(find.text('Versand nicht bestätigt'), findsNothing);
  });

  testWidgets(
      'Netzwerkfehler-Fall (Regressionsschutz Run 448): Upload wirft -> '
      '"Versand nicht bestätigt"-Dialog statt fälschlich "gesendet"',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TagesabschlussSchritt3Seite(
          argumente: argumente(),
          autoSaveUeberschreibung: autoSaveErfolgFake,
          uploadUeberschreibung: (TagesabschlussFinal _) async =>
              throw Exception('Failed to fetch'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await sendeVersuchen(tester);

    expect(find.text('Versand nicht bestätigt'), findsOneWidget);
    expect(find.text('Abrechnung gesendet'), findsNothing);
  });

  testWidgets(
      'Lokaler-Merker-Fehler-Fall (Regressionsschutz Run 450/451): '
      'Upload gelingt, lokaler Merker wirft (z.B. QuotaExceeded) -> '
      'trotzdem "gesendet", kein Fehler-Popup',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TagesabschlussSchritt3Seite(
          argumente: argumente(),
          autoSaveUeberschreibung: autoSaveErfolgFake,
          uploadUeberschreibung: (TagesabschlussFinal _) async =>
              <String, dynamic>{'report_id': 2},
          lokalerSendeMerkerUeberschreibung: () async =>
              throw Exception('QuotaExceededError (simuliert)'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await sendeVersuchen(tester);

    expect(find.text('Abrechnung gesendet'), findsOneWidget);
    expect(find.text('Versand nicht bestätigt'), findsNothing);
  });
}
