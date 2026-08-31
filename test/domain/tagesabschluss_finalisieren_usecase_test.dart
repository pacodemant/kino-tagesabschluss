import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/domain/tagesabschluss_finalisieren_usecase.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';

void main() {
  group('TagesabschlussFinalisierenUsecase', () {
    const TagesabschlussFinalisierenUsecase usecase =
        TagesabschlussFinalisierenUsecase();

    TagesabschlussFinalisierenEingabe eingabe({
      String kinoId = 'kino_01',
      int kinoSollCent = 5000,
      int bistroSollCent = 2000,
      int ausgabenCent = 300,
      List<int> ecBelegeCent = const <int>[3000, 1500],
      Map<String, int>? stueckzahlen,
      Map<String, int>? loseMuenzenNachArtCent,
      List<int>? ausgabenBetraegeCent,
      List<String>? ausgabenLabels,
      List<String>? ecBelegeLabels,
      List<String>? ecBelegeFotosBase64,
      List<String>? ecBelegeFotosMediaTypen,
      String? mitarbeiterName,
      String? anmerkung,
    }) {
      return TagesabschlussFinalisierenEingabe(
        kinoId: kinoId,
        kinoName: 'Schauburg',
        scheineCent: 10000,
        loseMuenzenCent: 2000,
        rollenCent: 500,
        umschlaegeCent: 300,
        wechselgeldSollwertCent: 20000,
        kinoSollCent: kinoSollCent,
        bistroSollCent: bistroSollCent,
        ausgabenCent: ausgabenCent,
        ecBelegeCent: ecBelegeCent,
        differenzAnfangsbestandCent: 100,
        stueckzahlen: stueckzahlen,
        loseMuenzenNachArtCent: loseMuenzenNachArtCent,
        ausgabenBetraegeCent: ausgabenBetraegeCent,
        ausgabenLabels: ausgabenLabels,
        ecBelegeLabels: ecBelegeLabels,
        ecBelegeFotosBase64: ecBelegeFotosBase64,
        ecBelegeFotosMediaTypen: ecBelegeFotosMediaTypen,
        mitarbeiterName: mitarbeiterName,
        anmerkung: anmerkung,
      );
    }

    test('finalisieren berechnet alle Summen korrekt aus den Eingaben', () {
      final DateTime jetzt = DateTime(2026, 3, 15, 14, 30, 5);
      final TagesabschlussFinal ergebnis = usecase.finalisieren(
        eingabe: eingabe(
          ausgabenBetraegeCent: <int>[300],
          ausgabenLabels: <String>['Trinkgeld'],
          mitarbeiterName: 'Max',
          anmerkung: 'Testlauf',
        ),
        jetzt: jetzt,
      );

      // kassenbestandGesamtCent = 10000+2000+500+300
      expect(ergebnis.kassenbestandGesamtCent, 12800);
      // barBestandAbzglWechselgeldCent = 12800-20000
      expect(ergebnis.barBestandAbzglWechselgeldCent, -7200);
      // ecUmsatzGesamtCent = 3000+1500
      expect(ergebnis.ecUmsatzGesamtCent, 4500);
      // gesamtSollCent = 5000+2000-300
      expect(ergebnis.gesamtSollCent, 6700);
      // gesamtIstCent = 4500 + (-7200)
      expect(ergebnis.gesamtIstCent, -2700);
      // differenzGesamtCent = -2700 - 6700
      expect(ergebnis.differenzGesamtCent, -9400);
      expect(ergebnis.differenzAnfangsbestandCent, 100);

      expect(ergebnis.datum, DateTime(2026, 3, 15));
      expect(ergebnis.createdAt, jetzt);
      expect(ergebnis.ecBelegeCent, <int>[3000, 1500]);
      expect(ergebnis.ausgabenBetraegeCent, <int>[300]);
      expect(ergebnis.ausgabenLabels, <String>['Trinkgeld']);
      expect(ergebnis.mitarbeiterName, 'Max');
      expect(ergebnis.anmerkung, 'Testlauf');
    });

    test(
      'finalisieren zaehlt Abschluss vor 5 Uhr noch als Vortag '
      '(Cutoff fuer Spaetvorstellungen nach Mitternacht)',
      () {
        final TagesabschlussFinal ergebnis = usecase.finalisieren(
          eingabe: eingabe(),
          jetzt: DateTime(2026, 3, 16, 0, 1),
        );

        expect(ergebnis.datum, DateTime(2026, 3, 15));
        expect(ergebnis.createdAt, DateTime(2026, 3, 16, 0, 1));
      },
    );

    test('finalisieren zaehlt Abschluss um 4:59 Uhr noch als Vortag', () {
      final TagesabschlussFinal ergebnis = usecase.finalisieren(
        eingabe: eingabe(),
        jetzt: DateTime(2026, 3, 16, 4, 59),
      );

      expect(ergebnis.datum, DateTime(2026, 3, 15));
    });

    test('finalisieren zaehlt Abschluss ab 5 Uhr als aktuellen Tag', () {
      final TagesabschlussFinal ergebnis = usecase.finalisieren(
        eingabe: eingabe(),
        jetzt: DateTime(2026, 3, 16, 5, 0),
      );

      expect(ergebnis.datum, DateTime(2026, 3, 16));
    });

    test('finalisieren zaehlt Abschluss um 23:50 Uhr als aktuellen Tag', () {
      final TagesabschlussFinal ergebnis = usecase.finalisieren(
        eingabe: eingabe(),
        jetzt: DateTime(2026, 3, 15, 23, 50),
      );

      expect(ergebnis.datum, DateTime(2026, 3, 15));
    });

    test(
      'finalisieren behandelt Cutoff korrekt ueber einen Jahreswechsel',
      () {
        final TagesabschlussFinal ergebnis = usecase.finalisieren(
          eingabe: eingabe(),
          jetzt: DateTime(2026, 1, 1, 0, 1),
        );

        expect(ergebnis.datum, DateTime(2025, 12, 31));
      },
    );

    test('finalisieren wirft bei leerer kinoId', () {
      expect(
        () => usecase.finalisieren(eingabe: eingabe(kinoId: '  ')),
        throwsA(isA<TagesabschlussValidierungsFehler>()),
      );
    });

    test('finalisieren wirft bei negativem kinoSollCent', () {
      expect(
        () => usecase.finalisieren(eingabe: eingabe(kinoSollCent: -1)),
        throwsA(isA<TagesabschlussValidierungsFehler>()),
      );
    });

    test('finalisieren wirft bei negativem bistroSollCent', () {
      expect(
        () => usecase.finalisieren(eingabe: eingabe(bistroSollCent: -1)),
        throwsA(isA<TagesabschlussValidierungsFehler>()),
      );
    });

    test('finalisieren wirft bei negativen ausgabenCent', () {
      expect(
        () => usecase.finalisieren(eingabe: eingabe(ausgabenCent: -1)),
        throwsA(isA<TagesabschlussValidierungsFehler>()),
      );
    });

    test('finalisieren wirft bei negativem EC-Beleg', () {
      expect(
        () => usecase.finalisieren(
          eingabe: eingabe(ecBelegeCent: <int>[100, -50]),
        ),
        throwsA(isA<TagesabschlussValidierungsFehler>()),
      );
    });

    test(
      'finalisieren leitet Scheine-/Rollen-Stückzahlen ab und ignoriert '
      'Werte <= 0 sowie unbekannte Präfixe',
      () {
        final TagesabschlussFinal ergebnis = usecase.finalisieren(
          eingabe: eingabe(
            stueckzahlen: <String, int>{
              'note_50': 2,
              'note_20': 0,
              'roll_2e': 3,
              'roll_1e': -1,
              'sonstiges_x': 5,
            },
          ),
        );

        expect(ergebnis.scheineStueckzahlen, <String, int>{'note_50': 2});
        expect(ergebnis.rollenStueckzahlen, <String, int>{'roll_2e': 3});
      },
    );

    test('finalisieren summiert Silber- und Kupfermünzen getrennt', () {
      final TagesabschlussFinal ergebnis = usecase.finalisieren(
        eingabe: eingabe(
          loseMuenzenNachArtCent: <String, int>{
            'coin_2e': 200,
            'coin_50c': 10,
            'coin_1c': 5,
            'coin_5c': 3,
          },
        ),
      );

      // Kupfer: coin_1c + coin_5c
      expect(ergebnis.kupferMuenzenCent, 8);
      // Silber: alles andere (coin_2e + coin_50c)
      expect(ergebnis.silberMuenzenCent, 210);
    });

    test('finalisieren normalisiert leere optionale Werte zu null', () {
      final TagesabschlussFinal ergebnis = usecase.finalisieren(
        eingabe: eingabe(
          ausgabenBetraegeCent: <int>[],
          ausgabenLabels: <String>[],
          ecBelegeLabels: <String>[],
          ecBelegeFotosBase64: <String>[],
          ecBelegeFotosMediaTypen: <String>[],
          mitarbeiterName: '',
          anmerkung: '',
        ),
      );

      expect(ergebnis.ausgabenBetraegeCent, isNull);
      expect(ergebnis.ausgabenLabels, isNull);
      expect(ergebnis.ecBelegeLabels, isNull);
      expect(ergebnis.ecBelegeFotosBase64, isNull);
      expect(ergebnis.ecBelegeFotosMediaTypen, isNull);
      expect(ergebnis.mitarbeiterName, isNull);
      expect(ergebnis.anmerkung, isNull);
    });

    test('finalisieren reicht Beleg-Fotos (base64 + media_type) durch', () {
      final TagesabschlussFinal ergebnis = usecase.finalisieren(
        eingabe: eingabe(
          ecBelegeLabels: <String>['12345'],
          ecBelegeFotosBase64: <String>['/9j/4AAQSkZJRg=='],
          ecBelegeFotosMediaTypen: <String>['image/jpeg'],
        ),
      );

      expect(ergebnis.ecBelegeFotosBase64, <String>['/9j/4AAQSkZJRg==']);
      expect(ergebnis.ecBelegeFotosMediaTypen, <String>['image/jpeg']);
    });
  });
}
