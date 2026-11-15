import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/stueckelung_vorschlag_seite.dart';

void main() {
  // Reale Werte aus einem gemeldeten Fall (Run 429a-Serie): auf einem
  // 390pt breiten Screen brachen die Bezeichnungen der Zeilen mit +/-
  // Knöpfen (20 €/10 €) um, weil Knöpfe + Zahlenspalten zusammen zu viel
  // Breite belegten. Läuft unter `flutter test` immer mit Android/Roboto-
  // Typografie (Flutter erzwingt TargetPlatform.android in Tests) — das
  // entspricht der echten Zielplattform (Kino-Standorte nutzen die App
  // als PWA auf Android-Smartphones, siehe project_zielplattform_android).
  StueckelungVorschlagArgumente argumente() => const StueckelungVorschlagArgumente(
    barBestandAbzglWechselgeldCent: 55770,
    stueckzahlen: <String, int>{
      'note_100': 1,
      'note_50': 6,
      'note_20': 7,
      'note_10': 30,
      'note_5': 14,
    },
    loseMuenzenNachArtCent: <String, int>{},
  );

  Future<void> setzeIphoneBreite(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'Bezeichnung der 20 €/10 €-Zeile bricht auf schmalem iPhone-Screen '
    'nicht um (gleiche Zeilenhöhe wie eine Zeile ohne Knöpfe)',
    (WidgetTester tester) async {
      await setzeIphoneBreite(tester);

      await tester.pumpWidget(
        MaterialApp(home: StueckelungVorschlagSeite(argumente: argumente())),
      );
      await tester.pumpAndSettle();

      final double hoeheOhneKnoepfe = tester
          .getSize(find.text('100 €'))
          .height;
      final double hoeheMitKnoepfen20 = tester.getSize(find.text('20 €')).height;
      final double hoeheMitKnoepfen10 = tester.getSize(find.text('10 €')).height;

      expect(
        hoeheMitKnoepfen20,
        closeTo(hoeheOhneKnoepfe, 0.5),
        reason: '"20 €" ist umgebrochen (Zeile höher als eine Einzeiler-Zeile)',
      );
      expect(
        hoeheMitKnoepfen10,
        closeTo(hoeheOhneKnoepfe, 0.5),
        reason: '"10 €" ist umgebrochen (Zeile höher als eine Einzeiler-Zeile)',
      );
    },
  );

  testWidgets(
    'Bezeichnung bricht auch bei aktiver Wechselgeld-Verschiebung nicht um',
    (WidgetTester tester) async {
      await setzeIphoneBreite(tester);

      await tester.pumpWidget(
        MaterialApp(home: StueckelungVorschlagSeite(argumente: argumente())),
      );
      await tester.pumpAndSettle();

      final double hoeheOhneKnoepfe = tester
          .getSize(find.text('100 €'))
          .height;

      // Minus-Knopf bei 20 € antippen: verschiebt einen Zwanziger zu den
      // Zehnern, aktiviert damit den Wechselgeld-Hinweistext.
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'Für das Wechselgeld bleiben übrig:\n1× 20 €, 27× 10 €.',
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.text('20 €')).height,
        closeTo(hoeheOhneKnoepfe, 0.5),
        reason: '"20 €" ist bei aktiver Verschiebung umgebrochen',
      );
      expect(
        tester.getSize(find.text('10 €')).height,
        closeTo(hoeheOhneKnoepfe, 0.5),
        reason: '"10 €" ist bei aktiver Verschiebung umgebrochen',
      );
    },
  );

  // Run 507: Kupfergeld wurde immer komplett angesetzt, auch wenn nach den
  // Scheinen weniger Cent fehlten (gemeldeter Fall: Soll 1.905,11 €, Rest
  // 0,11 €, Kupfer 0,31 € -> Umschlag 0,20 € zu viel).
  group('Kupfergeld höchstens so viel wie nach den Scheinen fehlt', () {
    // Liefert den Betrag-Text in derselben Zeile wie [bezeichnung].
    Finder betragInZeile(String bezeichnung, String betrag) => find.descendant(
      of: find.ancestor(of: find.text(bezeichnung), matching: find.byType(Row)),
      matching: find.text(betrag),
    );

    Future<void> zeigeSeite(
      WidgetTester tester, {
      required int sollCent,
      required Map<String, int> loseMuenzen,
    }) async {
      await setzeIphoneBreite(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: StueckelungVorschlagSeite(
            argumente: StueckelungVorschlagArgumente(
              barBestandAbzglWechselgeldCent: sollCent,
              stueckzahlen: const <String, int>{'note_50': 29, 'note_5': 63},
              loseMuenzenNachArtCent: loseMuenzen,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Kupfer > Rest: nur der Rest kommt in den Umschlag', (
      WidgetTester tester,
    ) async {
      // 29x50 + 1x5 = 1.455,00 €, Rest 0,11 €; Kupfer 0,31 €.
      await zeigeSeite(
        tester,
        sollCent: 145511,
        loseMuenzen: const <String, int>{
          'coin_5c': 25,
          'coin_2c': 6,
          'coin_50c': 100,
        },
      );

      expect(betragInZeile('Kupfergeld', '0,11 €'), findsOneWidget);
      expect(
        betragInZeile('Münzgeld (ohne Kupfer)', '0,00 €'),
        findsOneWidget,
      );
      expect(find.textContaining('Nicht abdeckbar'), findsNothing);
    });

    testWidgets('Kupfer < Rest: Kupfer komplett, Silber deckt den Rest', (
      WidgetTester tester,
    ) async {
      // Rest 0,80 €; Kupfer 0,31 €, Silber 1,00 € -> Silber 0,49 €.
      await zeigeSeite(
        tester,
        sollCent: 145580,
        loseMuenzen: const <String, int>{
          'coin_5c': 25,
          'coin_2c': 6,
          'coin_50c': 100,
        },
      );

      expect(betragInZeile('Kupfergeld', '0,31 €'), findsOneWidget);
      expect(
        betragInZeile('Münzgeld (ohne Kupfer)', '0,49 €'),
        findsOneWidget,
      );
      expect(find.textContaining('Nicht abdeckbar'), findsNothing);
    });

    testWidgets('kein Rest nach den Scheinen: Kupfer 0,00 €', (
      WidgetTester tester,
    ) async {
      await zeigeSeite(
        tester,
        sollCent: 145500,
        loseMuenzen: const <String, int>{'coin_5c': 25},
      );

      expect(betragInZeile('Kupfergeld', '0,00 €'), findsOneWidget);
      expect(find.textContaining('Nicht abdeckbar'), findsNothing);
    });
  });
}
