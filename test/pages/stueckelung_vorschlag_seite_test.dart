import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/stueckelung_vorschlag_seite.dart';

void main() {
  // Reale Werte aus einem gemeldeten Fall (Run 429a-Serie): auf einem
  // 390pt breiten iPhone brachen die Bezeichnungen der Zeilen mit +/-
  // Knöpfen (20 €/10 €) um, weil Knöpfe + fest verdrahtete Zahlenspalten
  // zusammen zu viel Breite belegten.
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
        find.text('Für das Wechselgeld bleiben übrig: 1× 20 €, 27× 10 €.'),
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
}
