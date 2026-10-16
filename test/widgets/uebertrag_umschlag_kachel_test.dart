import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/verlauf_detail_seite.dart';
import 'package:kino_bar_app/widgets/uebertrag_umschlag_kachel.dart';

/// Run 487: "Übertrag auf Umschlag"-Kachel im Verlauf. SB-Abend wie in
/// kinokasse_karte_uebertrag_test.dart (drei Terminals, 60561997 an der
/// Kinokasse), aber als bereits gespeicherter Verlaufseintrag.
void main() {
  TagesabschlussFinal abschluss({
    List<int> ecBelegeCent = const <int>[30000, 20000, 25000],
    int ecUmsatzGesamtCent = 75000,
    List<String>? ecBelegeLabels = const <String>[
      '60561994',
      '60561996',
      '60561997',
    ],
  }) {
    return TagesabschlussFinal(
      kinoId: 'kino_01',
      kinoName: 'Schauburg',
      datum: DateTime(2026, 10, 15),
      createdAt: DateTime(2026, 10, 15, 23, 0),
      scheineCent: 130000,
      loseMuenzenCent: 0,
      rollenCent: 0,
      umschlaegeCent: 0,
      kassenbestandGesamtCent: 130000,
      wechselgeldSollwertCent: 30000,
      barBestandAbzglWechselgeldCent: 100000,
      kinoSollCent: 100000,
      bistroSollCent: 50000,
      ausgabenCent: 0,
      ecBelegeCent: ecBelegeCent,
      ecUmsatzGesamtCent: ecUmsatzGesamtCent,
      gesamtSollCent: 175000,
      gesamtIstCent: 175000,
      differenzGesamtCent: 0,
      differenzAnfangsbestandCent: 0,
      ecBelegeLabels: ecBelegeLabels,
      mitarbeiterName: 'Kim',
      kinokasseKarteCent: 25000,
    );
  }

  Future<void> zeigeAufgeklappt(
    WidgetTester tester,
    TagesabschlussFinal a,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UebertragUmschlagKachel(abschluss: a),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Übertrag auf Umschlag'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'drei EC-Belege -> EC1/EC2/EC3 IST einzeln mit TID, Kino SOLL inkl. '
    'Kinokasse, Name und Datum',
    (WidgetTester tester) async {
      await zeigeAufgeklappt(tester, abschluss());

      expect(find.text('+ EC1 IST'), findsOneWidget);
      expect(find.text('+ EC2 IST'), findsOneWidget);
      expect(find.text('+ EC3 IST'), findsOneWidget);
      expect(find.text('+ EC IST'), findsNothing);
      expect(find.text('300,00 €'), findsOneWidget);
      expect(find.text('TID 60561997'), findsOneWidget);
      expect(
        find.text('1.250,00 €'),
        findsOneWidget,
      ); // Kino SOLL inkl. Kinokasse
      expect(find.text('Kim'), findsOneWidget);
      expect(find.text('Datum'), findsNothing); // Run 492b
    },
  );

  testWidgets('Belege passen nicht zur EC-Summe (z. B. alter Eintrag) -> eine '
      'Sammelzeile "EC IST" mit der gespeicherten Summe', (
    WidgetTester tester,
  ) async {
    await zeigeAufgeklappt(
      tester,
      abschluss(
        ecBelegeCent: const <int>[],
        ecUmsatzGesamtCent: 75000,
        ecBelegeLabels: null,
      ),
    );

    expect(find.text('+ EC IST'), findsOneWidget);
    expect(find.text('+ EC1 IST'), findsNothing);
    expect(find.text('750,00 €'), findsOneWidget);
  });

  testWidgets(
    'alter Verlaufseintrag (nur Grundfelder, ohne TID/Name/Kinokasse) '
    'aus JSON -> Verlauf-Detail mit aufgeklappter Kachel rendert fehlerfrei',
    (WidgetTester tester) async {
      final TagesabschlussFinal alt = TagesabschlussFinal.fromJson(
        <String, dynamic>{
          'kinoId': 'kino_01',
          'kinoName': 'Schauburg',
          'datumIso': '2026-09-20T00:00:00.000',
          'createdAtIso': '2026-09-20T23:10:00.000',
          'scheineCent': 80000,
          'loseMuenzenCent': 0,
          'rollenCent': 0,
          'umschlaegeCent': 0,
          'kassenbestandGesamtCent': 80000,
          'wechselgeldSollwertCent': 30000,
          'barBestandAbzglWechselgeldCent': 50000,
          'kinoSollCent': 60000,
          'bistroSollCent': 20000,
          'ausgabenCent': 0,
          'ecBelegeCent': <int>[18000, 12000],
          'ecUmsatzGesamtCent': 30000,
          'gesamtSollCent': 80000,
          'gesamtIstCent': 80000,
          'differenzGesamtCent': 0,
          'differenzAnfangsbestandCent': 0,
        },
      );

      await tester.pumpWidget(
        MaterialApp(home: VerlaufDetailSeite(abschluss: alt)),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Übertrag auf Umschlag'), 200);
      await tester.ensureVisible(find.text('Übertrag auf Umschlag'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Übertrag auf Umschlag'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('+ EC2 IST'), 100);
      expect(find.text('+ EC1 IST'), findsOneWidget);
      expect(find.text('+ EC2 IST'), findsOneWidget);
      expect(find.textContaining('TID'), findsNothing);

      await tester.scrollUntilVisible(find.text('Differenz'), 100);
      expect(find.text('Datum'), findsNothing); // Run 492b
      expect(find.text('Name'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
