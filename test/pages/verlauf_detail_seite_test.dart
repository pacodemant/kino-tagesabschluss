import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/verlauf_detail_seite.dart';

/// Erzeugt echte, dekodierbare PNG-Bytes (1x1 Pixel) zur Laufzeit —
/// keine hartkodierten Fake-Bytes, damit Image.memory im Test denselben
/// Decode-Pfad durchläuft wie mit einem echten Beleg-Foto.
Future<Uint8List> _tinyPngBytes() async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 1, 1),
    Paint()..color = const Color(0xFFFF0000),
  );
  final ui.Image image = await recorder.endRecording().toImage(1, 1);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

void main() {
  TagesabschlussFinal abschluss({
    List<String>? ecBelegeFotosBase64,
    List<String>? ecBelegeFotosMediaTypen,
    List<String>? ecBelegeLabels,
    DateTime? gesendetAm,
  }) {
    return TagesabschlussFinal(
      kinoId: 'kino_01',
      kinoName: 'Schauburg',
      datum: DateTime(2026, 8, 26),
      createdAt: DateTime(2026, 8, 26, 22, 0),
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
      ecBelegeCent: const <int>[2000],
      ecUmsatzGesamtCent: 2000,
      gesamtSollCent: 5000,
      gesamtIstCent: 5000,
      differenzGesamtCent: 0,
      differenzAnfangsbestandCent: 0,
      ecBelegeLabels: ecBelegeLabels,
      ecBelegeFotosBase64: ecBelegeFotosBase64,
      ecBelegeFotosMediaTypen: ecBelegeFotosMediaTypen,
      gesendetAm: gesendetAm,
    );
  }

  testWidgets(
      'Sende-Button zeigt "Jetzt senden" bei einem noch nie gesendeten '
      'Eintrag (gesendetAm == null, Run 407)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: VerlaufDetailSeite(abschluss: abschluss())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jetzt senden'), findsOneWidget);
    expect(find.text('Erneut senden'), findsNothing);
  });

  testWidgets(
      'Sende-Button zeigt "Erneut senden" bei einem bereits gesendeten '
      'Eintrag (gesendetAm gesetzt, Run 407)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VerlaufDetailSeite(
          abschluss: abschluss(gesendetAm: DateTime(2026, 8, 26, 23, 0)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Erneut senden'), findsOneWidget);
    expect(find.text('Jetzt senden'), findsNothing);
  });

  testWidgets(
      '"Ergebnis"-Kachel ist initial aufgeklappt, ohne Antippen sichtbar '
      '(Run 404)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: VerlaufDetailSeite(abschluss: abschluss())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gesamt SOLL'), findsOneWidget);
  });

  testWidgets(
      'kein Beleg-Foto vorhanden → keine Miniatur, Seite rendert ohne Fehler',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: VerlaufDetailSeite(abschluss: abschluss())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beleg 1'), findsNothing);
  });

  testWidgets(
      'Beleg-Foto vorhanden → Miniatur mit TID-Label wird angezeigt und '
      'öffnet beim Antippen die Vollbild-Ansicht', (WidgetTester tester) async {
    // dart:ui-Bilderzeugung braucht einen echten Async-Roundtrip
    // (Rasterizer) — die Fake-Uhr von flutter_test treibt das nicht von
    // selbst voran, daher runAsync() statt einfachem await.
    final Uint8List? bytes = await tester.runAsync(_tinyPngBytes);
    expect(bytes, isNotNull);
    final String base64Foto = base64Encode(bytes!);

    await tester.pumpWidget(
      MaterialApp(
        home: VerlaufDetailSeite(
          abschluss: abschluss(
            ecBelegeLabels: <String>['12345'],
            ecBelegeFotosBase64: <String>[base64Foto],
            ecBelegeFotosMediaTypen: <String>['image/png'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // "Belege"-Kachel aufklappen, damit die Miniatur im Widget-Baum landet.
    await tester.tap(find.text('Belege'));
    await tester.pumpAndSettle();

    expect(find.text('12345'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    await tester.tap(find.text('12345'));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('12345'), findsWidgets); // AppBar-Titel der Vollbild-Seite
  });
}
