import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/pages/uebertrag_umschlag_seite.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:kino_bar_app/widgets/uebertrag_umschlag_inhalt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Run 489: SB-Umschlag mit EC1–EC3 nach TID-Platz in den Einstellungen.
void main() {
  const List<TerminalEintrag> sbTerminals = <TerminalEintrag>[
    TerminalEintrag(tid: '60561994', nummer: '1'),
    TerminalEintrag(tid: '60561996', nummer: '2'),
    TerminalEintrag(tid: '60561997', nummer: '3', kinokasse: true),
  ];

  TagesabschlussFinal abschluss({
    String kinoId = 'kino_01',
    String kinoName = 'Schauburg',
    List<int> ecBelegeCent = const <int>[25000, 30000, 20000],
    List<String> ecBelegeLabels = const <String>[
      '60561997',
      '60561994',
      '60561996',
    ],
  }) {
    final int ec = ecBelegeCent.fold(0, (int s, int b) => s + b);
    return TagesabschlussFinal(
      kinoId: kinoId,
      kinoName: kinoName,
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
      ecUmsatzGesamtCent: ec,
      gesamtSollCent: 175000,
      gesamtIstCent: 100000 + ec,
      differenzGesamtCent: ec - 75000,
      differenzAnfangsbestandCent: 0,
      ecBelegeLabels: ecBelegeLabels,
      mitarbeiterName: 'Kim',
      kinokasseKarteCent: 25000,
    );
  }

  group('UebertragUmschlagInhalt.ecZeilenSb', () {
    test('EC-Nummer nach Platz in den Einstellungen, nicht nach '
        'Scan-Reihenfolge; Gerätenummer + TID als Info', () {
      final List<UmschlagEcZeile> zeilen = UebertragUmschlagInhalt.ecZeilenSb(
        abschluss(),
        sbTerminals,
      );

      expect(zeilen.map((UmschlagEcZeile z) => z.label), <String>[
        '+ EC1 IST',
        '+ EC2 IST',
        '+ EC3 IST',
      ]);
      expect(zeilen.map((UmschlagEcZeile z) => z.cent), <int>[
        30000,
        20000,
        25000,
      ]);
      expect(zeilen[2].info, 'Gerät 3 · TID 60561997');
    });

    test('Terminal ohne Beleg -> 0,00 €; Beleg mit nicht eingetragener TID '
        '-> Zusatzzeile, Summe stimmt', () {
      final List<UmschlagEcZeile> zeilen = UebertragUmschlagInhalt.ecZeilenSb(
        abschluss(
          ecBelegeCent: const <int>[30000, 12000],
          ecBelegeLabels: const <String>['60561994', '54017635'],
        ),
        sbTerminals,
      );

      expect(zeilen.map((UmschlagEcZeile z) => z.cent), <int>[
        30000,
        0,
        0,
        12000,
      ]);
      expect(zeilen.last.label, '+ EC IST');
      expect(zeilen.last.info, contains('54017635'));
      expect(zeilen.fold(0, (int s, UmschlagEcZeile z) => s + z.cent), 42000);
    });

    test('keine Terminals eingetragen -> Reihenfolge der Belege', () {
      final List<UmschlagEcZeile> zeilen = UebertragUmschlagInhalt.ecZeilenSb(
        abschluss(),
        const <TerminalEintrag>[],
      );
      expect(zeilen.map((UmschlagEcZeile z) => z.cent), <int>[
        25000,
        30000,
        20000,
      ]);
      expect(zeilen.first.info, 'TID 60561997');
    });
  });

  testWidgets('Übertrag-Seite SB: Umschlag-Layout mit EC1–EC3 aus den '
      'Einstellungen, Name und Datum', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await TerminalIdsConfigService.speichereTerminals('kino_01', sbTerminals);
    await tester.pumpWidget(
      MaterialApp(home: UebertragUmschlagSeite(abschluss: abschluss())),
    );
    await tester.pumpAndSettle();

    expect(find.text('+ KINO SOLL'), findsOneWidget);
    expect(find.text('+ EC1 IST'), findsOneWidget);
    expect(find.text('Gerät 1 · TID 60561994'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Name'), 200);
    expect(find.text('Datum'), findsNothing); // seit Run 492b nur im Kopf
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Kim'), findsOneWidget);
  });

  testWidgets('Übertrag-Seite anderer Standort (AT): bisheriges Layout, eine '
      'EC-Zeile, kein Name/Datum-Rahmen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(
        home: UebertragUmschlagSeite(
          abschluss: abschluss(kinoId: 'kino_03', kinoName: 'Atlantis'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('+ Kino Soll'), findsOneWidget);
    expect(find.text('+ EC IST'), findsOneWidget);
    expect(find.text('+ EC1 IST'), findsNothing);
    expect(find.text('Name'), findsNothing);
    expect(find.text('Datum'), findsNothing);
  });
}
