import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_personalgetraenke_section.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

Widget _baue({required bool gebont, required bool hervorgehoben}) {
  return MaterialApp(
    home: Scaffold(
      body: Schritt2PersonalgetraenkeSection(
        gebont: gebont,
        hervorgehoben: hervorgehoben,
        onChanged: (_) {},
      ),
    ),
  );
}

Color? _rahmenfarbe(WidgetTester tester) {
  final Card card = tester.widget<Card>(find.byType(Card));
  final ShapeBorder? shape = card.shape;
  return shape is RoundedRectangleBorder ? shape.side.color : null;
}

void main() {
  testWidgets('offen + hervorgehoben -> roter Rahmen', (tester) async {
    await tester.pumpWidget(_baue(gebont: false, hervorgehoben: true));
    expect(_rahmenfarbe(tester), AppFarben.differenzNegativ);
  });

  testWidgets('offen, nicht hervorgehoben -> Standard-Karte', (tester) async {
    await tester.pumpWidget(_baue(gebont: false, hervorgehoben: false));
    expect(tester.widget<Card>(find.byType(Card)).shape, isNull);
  });

  testWidgets('abgehakt -> kein roter Rahmen, auch wenn hervorgehoben', (
    tester,
  ) async {
    await tester.pumpWidget(_baue(gebont: true, hervorgehoben: true));
    expect(tester.widget<Card>(find.byType(Card)).shape, isNull);
  });
}
