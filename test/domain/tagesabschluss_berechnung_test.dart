import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';

void main() {
  group('TagesabschlussBerechnung', () {
    test('parseCentZiffern entfernt Nicht-Ziffern', () {
      expect(TagesabschlussBerechnung.parseCentZiffern('12,34 €'), 1234);
      expect(TagesabschlussBerechnung.parseCentZiffern('-9,90'), 990);
      expect(TagesabschlussBerechnung.parseCentZiffern('abc'), 0);
    });

    test('summeStueckzahlGruppeCent summiert nur bekannte IDs', () {
      const List<Kassenzeile> zeilen = <Kassenzeile>[
        Kassenzeile(id: 'schein_20', bezeichnung: '20€', einzelwertCent: 2000),
        Kassenzeile(id: 'schein_10', bezeichnung: '10€', einzelwertCent: 1000),
      ];
      final Map<String, int> stueckzahlen = <String, int>{
        'schein_20': 2,
        'schein_10': 3,
        'unbekannt': 99,
      };

      expect(
        TagesabschlussBerechnung.summeStueckzahlGruppeCent(
          zeilen: zeilen,
          stueckzahlen: stueckzahlen,
        ),
        7000,
      );
    });

    test('summeCentBetraege addiert auch negative Werte korrekt', () {
      expect(TagesabschlussBerechnung.summeCentBetraege(<int>[100, -20, 3]), 83);
      expect(TagesabschlussBerechnung.summeCentBetraege(<int>[]), 0);
    });

    test('summeUmschlaegeCent addiert alle Umschlag-Betraege', () {
      const List<UmschlagEintrag> umschlaege = <UmschlagEintrag>[
        UmschlagEintrag(bezeichnung: 'A', betragCent: 150),
        UmschlagEintrag(bezeichnung: 'B', betragCent: 250),
      ];

      expect(TagesabschlussBerechnung.summeUmschlaegeCent(umschlaege), 400);
    });

    test('abgeleitete Summen und Differenz werden korrekt berechnet', () {
      expect(
        TagesabschlussBerechnung.kassenbestandGesamtCent(
          scheineCent: 1000,
          loseMuenzenCent: 200,
          rollenCent: 300,
          umschlaegeCent: 500,
        ),
        2000,
      );
      expect(
        TagesabschlussBerechnung.barumsatzBereinigtCent(
          kassenbestandGesamtCent: 2000,
          wechselgeldSollwertCent: 700,
        ),
        1300,
      );
      expect(
        TagesabschlussBerechnung.gesamtSollCent(
          kinoSollCent: 1000,
          bistroSollCent: 500,
          ausgabenCent: 100,
        ),
        1400,
      );
      expect(
        TagesabschlussBerechnung.gesamtIstCent(
          ecUmsatzGesamtCent: 900,
          barBestandAbzglWechselgeldCent: 600,
        ),
        1500,
      );
      expect(
        TagesabschlussBerechnung.differenzTagesabschlussCent(
          gesamtIstCent: 1500,
          gesamtSollCent: 1400,
        ),
        100,
      );
    });
  });

  group('TagesabschlussFormatierung', () {
    test('formatiereEuro und formatiereEuroEingabe formatieren Cent korrekt', () {
      expect(TagesabschlussFormatierung.formatiereEuro(1234), '12,34 €');
      expect(TagesabschlussFormatierung.formatiereEuro(-1234), '-12,34 €');
      expect(TagesabschlussFormatierung.formatiereEuroEingabe(567), '5,67');
      expect(TagesabschlussFormatierung.formatiereEuroEingabe(-567), '-5,67');
    });

    test('formatiereEuroMitVorzeichen zeigt Plus nur bei positiven Werten', () {
      expect(TagesabschlussFormatierung.formatiereEuroMitVorzeichen(250), '+2,50 €');
      expect(TagesabschlussFormatierung.formatiereEuroMitVorzeichen(0), '0,00 €');
      expect(TagesabschlussFormatierung.formatiereEuroMitVorzeichen(-250), '-2,50 €');
    });

    test('heutigesIsoDatum und deutschesDatum formatieren Datum erwartungsgemaess', () {
      final DateTime datum = DateTime(2026, 2, 3);

      expect(TagesabschlussFormatierung.heutigesIsoDatum(datum), '2026-02-03');
      expect(TagesabschlussFormatierung.deutschesDatum(datum), '03.02.2026');
    });
  });
}
