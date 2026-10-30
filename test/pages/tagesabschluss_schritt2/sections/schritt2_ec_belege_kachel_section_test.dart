import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_ec_beleg_sub_kacheln.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_ec_belege_kachel_section.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Startzustand der EC-Kachel mit eingetragenen Terminals (Run 497): Kachel
/// offen, je Terminal eine zugeklappte Unterkachel ("Beleg N", seit Run
/// 502 TID erst nach Erfassung) und Kamera, darunter "Weiteren
/// Kassenschnitt hinzufügen".
Widget _kachel({
  required List<String> labels,
  required List<bool> aufgeklappt,
  List<bool>? gescannt,
  List<int>? betraegeCent,
  bool hatEcBelege = false,
}) {
  final int n = labels.length;
  final List<bool> scan = gescannt ?? List<bool>.filled(n, false);
  final List<int> cent = betraegeCent ?? List<int>.filled(n, 0);
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Schritt2EcBelegeKachelSection(
          aufgeklappt: true,
          onToggleAufgeklappt: () {},
          zeigeManuellEingebenLink: false,
          onManuellEingebenTap: () {},
          scanLaeuft: false,
          hatEcBelege: hatEcBelege,
          einBelegModus: n == 1,
          belegeWithData: 0,
          ecGesamtCent: 0,
          onScanStarten: () {},
          onKartenDatenLoeschen: () {},
          belegdatenBearbeitenRecognizer: TapGestureRecognizer(),
          onBelegdatenBearbeitenTap: () {},
          onEcBelegHinzufuegen: () {},
          belegInhalt: n == 1
              ? const Text('Ein-Beleg-Inhalt')
              : Schritt2EcBelegSubKacheln(
                  belegAnzahl: n,
                  belegIds: List<int>.generate(n, (int i) => i),
                  aufgeklapptListe: aufgeklappt,
                  onToggleAufgeklappt: (_) {},
                  editModusListe: List<bool>.filled(n, false),
                  scanBelegIndex: null,
                  labelController: List<TextEditingController>.generate(
                    n,
                    (int i) => TextEditingController(text: labels[i]),
                  ),
                  labelFocusNode:
                      List<FocusNode>.generate(n, (_) => FocusNode()),
                  labels: labels,
                  nochLeer: (int i) => !scan[i] && cent[i] == 0,
                  betraegeCent: cent,
                  tidUnleserlich: (_) => false,
                  scanLaeuft: false,
                  onScanStarten: (_) {},
                  onTidGeaendert: (_, _) {},
                  onBestaetigtEntfernen: (_) {},
                  hatZahlungsartZeilen: (_) => false,
                  hatScanStattgefunden: (int i) => scan[i],
                  baueZahlungsartenTabelle: (_) =>
                      const Text('Zahlungsarten-Tabelle'),
                  baueMetadatenBlock: (_) => const SizedBox.shrink(),
                  onManuellBearbeitenAktivieren: (_) {},
                  onFertig: (_) {},
                ),
        ),
      ),
    ),
  );
}

Color? _kameraFarbe(WidgetTester tester, int index) => tester
    .widget<Icon>(find.byIcon(Icons.camera_alt).at(index))
    .color;

void main() {
  testWidgets(
    'Start mit 3 Terminals: Unterkacheln zugeklappt als "Beleg N", '
    'Kamera je Terminal, Hinzufügen-Knopf da, keine Kopf-Kamera',
    (WidgetTester tester) async {
      await tester.pumpWidget(_kachel(
        labels: <String>['11111111', '22222222', '33333333'],
        aufgeklappt: <bool>[false, false, false],
      ));

      expect(find.text('Beleg 1'), findsOneWidget);
      expect(find.text('Beleg 2'), findsOneWidget);
      expect(find.text('Beleg 3'), findsOneWidget);
      expect(find.textContaining('TID'), findsNothing);
      expect(find.text('Zahlungsarten-Tabelle'), findsNothing);
      expect(find.byIcon(Icons.camera_alt), findsNWidgets(3));
      expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
      expect(
        find.text('+ Weiteren Kassenschnitt hinzufügen'),
        findsOneWidget,
      );
      expect(find.textContaining('Beleg fehlt oder ist unlesbar'),
          findsNothing);
      for (int i = 0; i < 3; i++) {
        expect(_kameraFarbe(tester, i), AppFarben.fokusFarbe);
      }
    },
  );

  testWidgets(
    'nach Scan von Terminal 2: Unterkachel bleibt zu, Kamera grau',
    (WidgetTester tester) async {
      await tester.pumpWidget(_kachel(
        labels: <String>['11111111', '22222222', '33333333'],
        aufgeklappt: <bool>[false, false, false],
        gescannt: <bool>[false, true, false],
        betraegeCent: <int>[0, 12345, 0],
        hatEcBelege: true,
      ));

      expect(find.text('Zahlungsarten-Tabelle'), findsNothing);
      expect(find.text('123,45 €'), findsOneWidget);
      expect(_kameraFarbe(tester, 0), AppFarben.fokusFarbe);
      expect(_kameraFarbe(tester, 1), Colors.grey.shade400);
      expect(_kameraFarbe(tester, 2), AppFarben.fokusFarbe);
    },
  );

  testWidgets(
    'ein Feld ohne Beleg: Kopf-Kamera und Hinweis wie bisher, kein '
    'Hinzufügen-Knopf',
    (WidgetTester tester) async {
      await tester.pumpWidget(_kachel(
        labels: <String>['11111111'],
        aufgeklappt: <bool>[true],
      ));

      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.textContaining('Beleg fehlt oder ist unlesbar'),
          findsOneWidget);
      expect(find.text('+ Weiteren Kassenschnitt hinzufügen'), findsNothing);
    },
  );

  testWidgets('Run 502: erfasster Beleg zeigt TID statt "Beleg N"',
      (WidgetTester tester) async {
    await tester.pumpWidget(_kachel(
      labels: <String>['11111111', '22222222', '33333333'],
      aufgeklappt: <bool>[false, false, false],
      gescannt: <bool>[false, true, false],
      betraegeCent: <int>[0, 12345, 0],
    ));

    expect(find.text('Beleg 1'), findsOneWidget);
    expect(find.text('TID 22222222'), findsOneWidget);
    expect(find.text('Beleg 2'), findsNothing);
    expect(find.text('Beleg 3'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
