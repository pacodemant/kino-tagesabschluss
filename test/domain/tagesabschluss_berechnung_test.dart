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

    test('parseCentKomma parst einfache Euro-Komma-Eingaben', () {
      expect(TagesabschlussBerechnung.parseCentKomma('6,40'), 640);
      expect(TagesabschlussBerechnung.parseCentKomma('380'), 38000);
      expect(TagesabschlussBerechnung.parseCentKomma('0,0'), 0);
      expect(TagesabschlussBerechnung.parseCentKomma(''), 0);
    });

    test('parseCentKomma verarbeitet einstellige Cent-Angaben mal 10', () {
      // "6,4" ist als "6,40" gemeint, nicht als "6,04".
      expect(TagesabschlussBerechnung.parseCentKomma('6,4'), 640);
    });

    test('parseCentKomma akzeptiert Punkt als Dezimaltrenner', () {
      expect(TagesabschlussBerechnung.parseCentKomma('12.34'), 1234);
    });

    test('parseCentKomma entfernt Euro-Zeichen und Leerraum', () {
      expect(TagesabschlussBerechnung.parseCentKomma('  12,34 €  '), 1234);
    });

    test('parseCentKomma nimmt bei Punkt+Komma das Komma als Dezimaltrenner',
        () {
      // Deutsches Format "1.234,56" (Punkt = Tausendertrenner).
      expect(TagesabschlussBerechnung.parseCentKomma('1.234,56'), 123456);
    });

    test(
        'parseCentKomma: bekannte Einschraenkung bei reinem Tausenderpunkt '
        'ohne Komma', () {
      // "1.400" (z. B. Wechselgeld-Sollwert Gondel, siehe TODO.md) wird
      // hier als Dezimaltrenner interpretiert, nicht als Tausenderpunkt:
      // Ergebnis ist 1,40 EUR statt der vermutlich gemeinten 1.400,00 EUR.
      // Dieser Pfad ist seit Run 317 nirgends mehr aktiv (mitKomma ist
      // app-weit fest auf false, siehe TODO.md "Eingabe mit Komma"), daher
      // kein akutes Risiko - der Test dokumentiert nur das bestehende
      // Verhalten, damit eine künftige Reaktivierung nicht stillschweigend
      // in diese Falle läuft.
      expect(TagesabschlussBerechnung.parseCentKomma('1.400'), 140);
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

  group('Validierungen', () {
    test('hatAusgabeMitFehlendemBetrag erkennt Label ohne Betrag', () {
      expect(
        TagesabschlussBerechnung.hatAusgabeMitFehlendemBetrag(
          <String>['Lieferant'], <int>[0]),
        isTrue,
      );
      expect(
        TagesabschlussBerechnung.hatAusgabeMitFehlendemBetrag(
          <String>['Lieferant'], <int>[500]),
        isFalse,
      );
      expect(
        TagesabschlussBerechnung.hatAusgabeMitFehlendemBetrag(
          <String>[''], <int>[0]),
        isFalse,
      );
      expect(
        TagesabschlussBerechnung.hatAusgabeMitFehlendemBetrag(
          <String>[], <int>[]),
        isFalse,
      );
    });

    test('istEcNull erkennt fehlenden EC-Umsatz', () {
      expect(TagesabschlussBerechnung.istEcNull(<int>[0]), isTrue);
      expect(TagesabschlussBerechnung.istEcNull(<int>[0, 0]), isTrue);
      expect(TagesabschlussBerechnung.istEcNull(<int>[0, 100]), isFalse);
      expect(TagesabschlussBerechnung.istEcNull(<int>[100]), isFalse);
      expect(TagesabschlussBerechnung.istEcNull(<int>[]), isFalse);
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
