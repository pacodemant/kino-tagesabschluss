import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kino_bar_app/domain/usecases/speichere_tagesabschluss_usecase.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Analyse-Run Handnotizen (2026-10-22): hält das IST-Verhalten fest, das
/// in den Notizen 1, 8, 9 und 12 beschrieben ist. Die Tests prüfen
/// bewusst den aktuellen (fehlerhaften) Zustand und laufen deshalb grün.
/// Wird der jeweilige Fehler behoben, schlägt der Test fehl und muss auf
/// das neue Soll-Verhalten umgedreht werden (Punkte in der Aufgabenliste).
void main() {
  TagesabschlussSchritt3Argumente argumente() =>
      const TagesabschlussSchritt3Argumente(
        kinoId: 'test_kino_analyse',
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

  Future<void> pumpKurz(WidgetTester tester) async {
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tippeSendenUndBestaetige(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Abrechnung an Büro senden'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Abrechnung an Büro senden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Senden'));
    await pumpKurz(tester);
  }

  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'dev_api_upload_aktiv': true,
    });
    tempDir = Directory.systemTemp.createTempSync('hive_analyse_');
    Hive.init(tempDir.path);
    // Rein im Speicher (bytes): Das Kommentarfeld schreibt bei jeder
    // Eingabe einen Entwurf — ein echter Platten-Schreibvorgang hängt in
    // der simulierten Pump-Zeit und blockiert das tearDown.
    await Hive.openBox('box_schritt3_entwuerfe', bytes: Uint8List(0));
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets(
      'Notiz 1 (IST): während der Upload noch läuft, zeigt der '
      'Senden-Button bereits das rote Fehler-Icon', (WidgetTester tester) async {
    final Completer<FlurbocashUploadErgebnis> upload =
        Completer<FlurbocashUploadErgebnis>();
    await tester.pumpWidget(
      MaterialApp(
        home: TagesabschlussSchritt3Seite(
          argumente: argumente(),
          autoSaveUeberschreibung: autoSaveErfolgFake,
          uploadUeberschreibung: (TagesabschlussFinal _) => upload.future,
          lokalerSendeMerkerUeberschreibung: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error), findsNothing);
    await tippeSendenUndBestaetige(tester);

    // Upload hängt noch: kein Ergebnis, trotzdem rotes "nicht ok"-Icon.
    final Icon icon = tester.widget<Icon>(find.byIcon(Icons.error));
    expect(icon.color, Colors.red);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    upload.complete(const FlurbocashUploadErgebnis());
    await pumpKurz(tester);
    expect(find.text('Abrechnung gesendet'), findsOneWidget);
  });

  testWidgets(
      'Notiz 9 (IST): Kommentar nach dem Senden in derselben Sitzung '
      'geändert -> "bereits gesendet", keine Korrektur möglich',
      (WidgetTester tester) async {
    int uploads = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: TagesabschlussSchritt3Seite(
          argumente: argumente(),
          autoSaveUeberschreibung: autoSaveErfolgFake,
          uploadUeberschreibung: (TagesabschlussFinal _) async {
            uploads++;
            return const FlurbocashUploadErgebnis();
          },
          lokalerSendeMerkerUeberschreibung: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tippeSendenUndBestaetige(tester);
    await tester.tap(find.text('Verstanden'));
    await pumpKurz(tester);
    await tester.tapAt(const Offset(5, 5));
    await pumpKurz(tester);

    // Kommentar geht als "note" an Flurbocash -> fachlich eine Korrektur.
    await tester.enterText(find.byType(TextField).first, 'Nachtrag');
    await pumpKurz(tester);

    expect(find.text('Korrektur an Büro senden'), findsNothing);
    await tester.tap(find.text('Abrechnung an Büro senden'));
    await pumpKurz(tester);

    expect(
      find.text('Du hast die Abrechnung bereits gesendet.'),
      findsOneWidget,
    );
    expect(uploads, 1);

  });

  test(
      'Notiz 8/12 (IST): die Sende-Signatur (Basis: settlementsBody ohne '
      'sent_at) enthält jedes Belegfoto in voller Länge', () {
    // ~3 MB Base64 je Foto, entspricht grob einem Handy-Kamerafoto.
    final String foto = 'A' * (3 * 1024 * 1024);
    final TagesabschlussFinal abrechnung = TagesabschlussFinal(
      kinoId: 'kino_01',
      kinoName: 'Schauburg',
      datum: DateTime(2026, 10, 22),
      createdAt: DateTime(2026, 10, 22, 23, 0),
      scheineCent: 10000,
      loseMuenzenCent: 0,
      rollenCent: 0,
      umschlaegeCent: 0,
      kassenbestandGesamtCent: 10000,
      wechselgeldSollwertCent: 0,
      barBestandAbzglWechselgeldCent: 10000,
      kinoSollCent: 5000,
      bistroSollCent: 0,
      ausgabenCent: 0,
      ecBelegeCent: const <int>[1000, 2000, 3000],
      ecUmsatzGesamtCent: 6000,
      gesamtSollCent: 5000,
      gesamtIstCent: 16000,
      differenzGesamtCent: 11000,
      differenzAnfangsbestandCent: 0,
      zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
        ZahlungsartErgebnis(
            art: 'Girocard', betragCent: 1000, tid: '11111111', belegIndex: 0),
        ZahlungsartErgebnis(
            art: 'Girocard', betragCent: 2000, tid: '22222222', belegIndex: 1),
        ZahlungsartErgebnis(
            art: 'Girocard', betragCent: 3000, tid: '33333333', belegIndex: 2),
      ],
      ecBelegeLabels: const <String>['11111111', '22222222', '33333333'],
      ecBelegeFotosBase64: <String>[foto, foto, foto],
      ecBelegeFotosMediaTypen: const <String>[
        'image/jpeg',
        'image/jpeg',
        'image/jpeg',
      ],
    );

    final String signaturQuelle =
        ApiUploadService.settlementsBody(abrechnung).toString();

    // Drei Fotos -> > 9 MB Text, der in Schritt 3 als
    // 'sende_bestaetigung_<kinoId>' in SharedPreferences (Web:
    // localStorage, ca. 5 MB je Origin) geschrieben wird.
    expect(signaturQuelle.length, greaterThan(3 * foto.length));
  });
}
