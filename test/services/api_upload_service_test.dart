import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';

void main() {
  group('ApiUploadService.settlementsBody', () {
    TagesabschlussFinal abrechnung({
      int ecUmsatzGesamtCent = 0,
      List<ZahlungsartErgebnis>? zahlungsartenAufschluesselung,
      String? terminalId,
      String? anmerkung,
      List<String>? ecBelegeLabels,
      List<String>? ecBelegeFotosBase64,
      List<String>? ecBelegeFotosMediaTypen,
    }) {
      return TagesabschlussFinal(
        kinoId: 'kino_01',
        kinoName: 'Schauburg',
        datum: DateTime(2026, 8, 16),
        createdAt: DateTime(2026, 8, 16, 23, 0),
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
        ecBelegeCent: <int>[ecUmsatzGesamtCent],
        ecUmsatzGesamtCent: ecUmsatzGesamtCent,
        gesamtSollCent: 5000,
        gesamtIstCent: 5000,
        differenzGesamtCent: 0,
        differenzAnfangsbestandCent: 0,
        terminalId: terminalId,
        zahlungsartenAufschluesselung: zahlungsartenAufschluesselung,
        anmerkung: anmerkung,
        ecBelegeLabels: ecBelegeLabels,
        ecBelegeFotosBase64: ecBelegeFotosBase64,
        ecBelegeFotosMediaTypen: ecBelegeFotosMediaTypen,
      );
    }

    test('kein EC-Umsatz und keine Aufschlüsselung → leeres terminals-Array',
        () {
      final Map<String, dynamic> body =
          ApiUploadService.settlementsBody(abrechnung());

      final List<dynamic> settlements =
          body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      expect(settlement['terminals'], <Map<String, dynamic>>[]);
    });

    test(
        'EC-Umsatz > 0 ohne Aufschlüsselung → wirft Exception mit '
        'Betrag in der Meldung', () {
      expect(
        () => ApiUploadService.settlementsBody(
          abrechnung(ecUmsatzGesamtCent: 4500),
        ),
        throwsA(
          predicate(
            (Object e) =>
                e is Exception && e.toString().contains('45,00 €'),
          ),
        ),
      );
    });

    test('EC-Umsatz > 0 mit Aufschlüsselung → Kartenart-Mapping unverändert',
        () {
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(
          ecUmsatzGesamtCent: 3000,
          terminalId: '12345',
          zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
            ZahlungsartErgebnis(art: 'Girocard', betragCent: 2000),
            ZahlungsartErgebnis(art: 'Visa', betragCent: 1000),
          ],
        ),
      );

      final List<dynamic> settlements =
          body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      final List<dynamic> terminals = settlement['terminals'] as List<dynamic>;
      final Map<String, dynamic> terminal =
          terminals.single as Map<String, dynamic>;

      expect(terminal['tid'], '12345');
      expect(terminal['girocard'], 2000);
      expect(terminal['visa'], 1000);
      expect(terminal['mastercard'], 0);
    });

    int summeAllerKartenfelderCent(Map<String, dynamic> body) {
      final List<dynamic> settlements = body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      final List<dynamic> terminals =
          settlement['terminals'] as List<dynamic>;
      int summe = 0;
      for (final dynamic t in terminals) {
        final Map<String, dynamic> terminal = t as Map<String, dynamic>;
        for (final String feld in <String>[
          'girocard',
          'lastschrift',
          'mastercard',
          'visa',
          'maestro',
          'vpay',
        ]) {
          summe += terminal[feld] as int;
        }
      }
      return summe;
    }

    test(
        'Fix Bug 1: Kartenart in Großschreibung (z.B. KI-Scan liefert '
        '"MASTERCARD") wird jetzt trotzdem erkannt', () {
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(
          ecUmsatzGesamtCent: 3000,
          terminalId: '12345',
          zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
            ZahlungsartErgebnis(art: 'MASTERCARD', betragCent: 3000),
          ],
        ),
      );

      expect(summeAllerKartenfelderCent(body), 3000);
    });

    test(
        'Fix Bug 1: Kartenart mit umgebendem Leerzeichen (z.B. " Girocard" '
        'aus KI-Scan) wird jetzt trotzdem erkannt', () {
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(
          ecUmsatzGesamtCent: 2000,
          terminalId: '12345',
          zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
            ZahlungsartErgebnis(art: ' Girocard', betragCent: 2000),
          ],
        ),
      );

      expect(summeAllerKartenfelderCent(body), 2000);
    });

    test(
        'Fix Bug 1: Echte unbekannte Kartenart (z.B. "Amex") wirft jetzt '
        'eine Exception statt den Betrag stillschweigend zu verlieren', () {
      expect(
        () => ApiUploadService.settlementsBody(
          abrechnung(
            ecUmsatzGesamtCent: 3000,
            terminalId: '12345',
            zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
              ZahlungsartErgebnis(art: 'Girocard', betragCent: 2000),
              // "Amex" ist keine im Kino akzeptierte Kartenart, ergo
              // nicht im Mapping — realistisch, falls die Beleg-Scan-KI
              // trotzdem eine Zeile dafür erkennt.
              ZahlungsartErgebnis(art: 'Amex', betragCent: 1000),
            ],
          ),
        ),
        throwsA(
          predicate(
            (Object e) => e is Exception && e.toString().contains('Amex'),
          ),
        ),
      );
    });

    test(
        'Fix Bug 2: Summe der Kartenart-Aufschlüsselung weicht von '
        'ecUmsatzGesamtCent ab → wirft jetzt eine Exception', () {
      // ecUmsatzGesamtCent kommt aus der Summe der Beleg-Gesamtbeträge
      // (ecBelegeCent), zahlungsartenAufschluesselung ist eine davon
      // unabhängige zweite Datenquelle (siehe
      // tagesabschluss_finalisieren_usecase.dart). Beide können
      // auseinanderlaufen, z.B. wenn ein Beleg-Betrag nachträglich in
      // Schritt 2 manuell korrigiert wird, ohne die Kartenart-Zeilen
      // anzupassen.
      expect(
        () => ApiUploadService.settlementsBody(
          abrechnung(
            ecUmsatzGesamtCent: 5000,
            terminalId: '12345',
            zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
              ZahlungsartErgebnis(art: 'Girocard', betragCent: 2000),
            ],
          ),
        ),
        throwsA(
          predicate(
            (Object e) =>
                e is Exception &&
                e.toString().contains('50,00 €') &&
                e.toString().contains('20,00 €'),
          ),
        ),
      );
    });

    test('Kontrolltest: mehrere Terminals (TIDs) werden korrekt getrennt',
        () {
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(
          ecUmsatzGesamtCent: 4000,
          zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
            ZahlungsartErgebnis(art: 'Girocard', betragCent: 2000, tid: 'A'),
            ZahlungsartErgebnis(art: 'Visa', betragCent: 2000, tid: 'B'),
          ],
        ),
      );

      final List<dynamic> settlements =
          body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      final List<dynamic> terminals =
          settlement['terminals'] as List<dynamic>;

      expect(terminals.length, 2);
      final Map<String, dynamic> terminalA = terminals.firstWhere(
        (dynamic t) => (t as Map<String, dynamic>)['tid'] == 'A',
      ) as Map<String, dynamic>;
      final Map<String, dynamic> terminalB = terminals.firstWhere(
        (dynamic t) => (t as Map<String, dynamic>)['tid'] == 'B',
      ) as Map<String, dynamic>;
      expect(terminalA['girocard'], 2000);
      expect(terminalB['visa'], 2000);
    });

    test(
        'Bug (gefunden beim Testen, 2026-08-27): zwei Belege MIT '
        'identischer TID werden NICHT mehr zu einer Zeile summiert, '
        'sondern als zwei separate terminals[]-Einträge übertragen '
        '(Yannik-Antwort, fragen_yannik.md Frage 2.1) — jeder Beleg '
        'behält dabei sein eigenes Foto', () {
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(
          ecUmsatzGesamtCent: 4000,
          zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
            ZahlungsartErgebnis(
                art: 'Girocard', betragCent: 2000, tid: '54017635', belegIndex: 0),
            ZahlungsartErgebnis(
                art: 'Girocard', betragCent: 2000, tid: '54017635', belegIndex: 1),
          ],
          ecBelegeLabels: <String>['54017635', '54017635'],
          ecBelegeFotosBase64: <String>['', '/9j/4AAQSkZJRg=='],
          ecBelegeFotosMediaTypen: <String>['', 'image/jpeg'],
        ),
      );

      final List<dynamic> settlements = body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      final List<dynamic> terminals =
          settlement['terminals'] as List<dynamic>;

      expect(terminals.length, 2);
      for (final dynamic t in terminals) {
        expect((t as Map<String, dynamic>)['tid'], '54017635');
      }
      final Map<String, dynamic> mitFoto = terminals.firstWhere(
        (dynamic t) =>
            (t as Map<String, dynamic>).containsKey('receipt_photo'),
      ) as Map<String, dynamic>;
      final Map<String, dynamic> ohneFoto = terminals.firstWhere(
        (dynamic t) =>
            !(t as Map<String, dynamic>).containsKey('receipt_photo'),
      ) as Map<String, dynamic>;
      expect(mitFoto['receipt_photo'], '/9j/4AAQSkZJRg==');
      expect(mitFoto['girocard'], 2000);
      expect(ohneFoto['girocard'], 2000);
    });

    test(
        'Alt-Daten ohne belegIndex (vor Run 399a3 gespeichert, z. B. '
        'erneuter Versand aus dem Verlauf): Fallback-Gruppierung nach '
        'TID bleibt wie zuvor erhalten (summiert zu einer Zeile)', () {
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(
          ecUmsatzGesamtCent: 4000,
          zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
            ZahlungsartErgebnis(art: 'Girocard', betragCent: 2000, tid: '54017635'),
            ZahlungsartErgebnis(art: 'Girocard', betragCent: 2000, tid: '54017635'),
          ],
        ),
      );

      final List<dynamic> settlements = body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      final List<dynamic> terminals =
          settlement['terminals'] as List<dynamic>;

      expect(terminals.length, 1);
      expect(
        (terminals.single as Map<String, dynamic>)['girocard'],
        4000,
      );
    });

    test('Kontrolltest: cash_total entspricht 1:1 '
        'barBestandAbzglWechselgeldCent', () {
      final TagesabschlussFinal a = abrechnung();
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(a);
      final List<dynamic> settlements =
          body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      expect(settlement['cash_total'], a.barBestandAbzglWechselgeldCent);
    });

    test('anmerkung vorhanden → "note" wird 1:1 mitgeschickt', () {
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(anmerkung: 'Anfangsbestand krumm'),
      );
      final List<dynamic> settlements = body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      expect(settlement['note'], 'Anfangsbestand krumm');
    });

    test('keine anmerkung → "note" fehlt im settlement (kein leerer String)',
        () {
      final Map<String, dynamic> body =
          ApiUploadService.settlementsBody(abrechnung());
      final List<dynamic> settlements = body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      expect(settlement.containsKey('note'), isFalse);
    });

    test('sent_at entspricht dem übergebenen Zeitpunkt als ISO8601', () {
      final DateTime jetzt = DateTime(2026, 8, 26, 14, 30);
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(),
        jetzt: jetzt,
      );
      final List<dynamic> settlements = body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      expect(settlement['sent_at'], jetzt.toIso8601String());
    });

    test(
        'receipt_photo/receipt_media_type werden dem Terminal mit '
        'passender TID zugeordnet', () {
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(
          ecUmsatzGesamtCent: 2000,
          zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
            ZahlungsartErgebnis(art: 'Girocard', betragCent: 2000, tid: '12345'),
          ],
          ecBelegeLabels: <String>['12345'],
          ecBelegeFotosBase64: <String>['/9j/4AAQSkZJRg=='],
          ecBelegeFotosMediaTypen: <String>['image/png'],
        ),
      );
      final List<dynamic> settlements = body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      final Map<String, dynamic> terminal =
          (settlement['terminals'] as List<dynamic>).single
              as Map<String, dynamic>;
      expect(terminal['receipt_photo'], '/9j/4AAQSkZJRg==');
      expect(terminal['receipt_media_type'], 'image/png');
    });

    test(
        'kein Beleg-Foto für die TID → receipt_photo/receipt_media_type '
        'fehlen im Terminal', () {
      final Map<String, dynamic> body = ApiUploadService.settlementsBody(
        abrechnung(
          ecUmsatzGesamtCent: 2000,
          zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
            ZahlungsartErgebnis(art: 'Girocard', betragCent: 2000, tid: '12345'),
          ],
        ),
      );
      final List<dynamic> settlements = body['settlements'] as List<dynamic>;
      final Map<String, dynamic> settlement =
          settlements.single as Map<String, dynamic>;
      final Map<String, dynamic> terminal =
          (settlement['terminals'] as List<dynamic>).single
              as Map<String, dynamic>;
      expect(terminal.containsKey('receipt_photo'), isFalse);
      expect(terminal.containsKey('receipt_media_type'), isFalse);
    });
  });

  group('ApiUploadService.ensureBody', () {
    test('location_id und Datum werden unverändert/korrekt übernommen', () {
      final TagesabschlussFinal a = TagesabschlussFinal(
        kinoId: 'kino_01',
        kinoName: 'Schauburg',
        datum: DateTime(2026, 8, 22),
        createdAt: DateTime(2026, 8, 22, 23, 0),
        scheineCent: 0,
        loseMuenzenCent: 0,
        rollenCent: 0,
        umschlaegeCent: 0,
        kassenbestandGesamtCent: 0,
        wechselgeldSollwertCent: 0,
        barBestandAbzglWechselgeldCent: 0,
        kinoSollCent: 0,
        bistroSollCent: 0,
        ausgabenCent: 0,
        ecBelegeCent: const <int>[],
        ecUmsatzGesamtCent: 0,
        gesamtSollCent: 0,
        gesamtIstCent: 0,
        differenzGesamtCent: 0,
        differenzAnfangsbestandCent: 0,
      );

      final Map<String, dynamic> body = ApiUploadService.ensureBody(a, 9);

      expect(body['location_id'], 9);
      expect(body['date'], '2026-08-22');
    });
  });

  group('ApiUploadService.pruefeTerminalIdsGegenKonfiguration', () {
    const Kino schauburg = Kino(id: 'kino_01', name: 'Schauburg', kuerzel: 'SB');
    const Map<String, List<String>> konfiguration = <String, List<String>>{
      'SB': <String>['54017635'],
      'CO': <String>['54017639'],
    };

    test('bekannte, registrierte TID → keine Warnung', () {
      expect(
        ApiUploadService.pruefeTerminalIdsGegenKonfiguration(
          <String>['54017635'],
          schauburg,
          konfiguration,
        ),
        isEmpty,
      );
    });

    test(
        'TID eines anderen Standorts (z.B. Beleg von Cinema Ostertor unter '
        'Schauburg gesendet) → Warnung mit Kino-Name und erwarteten TIDs, '
        'aber KEINE Exception (Referenzliste ist laut TODO.md unbestätigt)',
        () {
      final List<String> warnungen =
          ApiUploadService.pruefeTerminalIdsGegenKonfiguration(
        <String>['54017639'],
        schauburg,
        konfiguration,
      );

      expect(warnungen, hasLength(1));
      expect(warnungen.single, contains('54017639'));
      expect(warnungen.single, contains('Schauburg'));
      expect(warnungen.single, contains('54017635'));
    });

    test('leere TID trotz EC-Umsatz → Warnung', () {
      final List<String> warnungen =
          ApiUploadService.pruefeTerminalIdsGegenKonfiguration(
        <String>[''],
        schauburg,
        konfiguration,
      );

      expect(warnungen, hasLength(1));
    });

    test('Kino ohne hinterlegte TIDs (z.B. Platzhalter "XXXX") → Warnung',
        () {
      const Kino gondel = Kino(id: 'kino_02', name: 'Gondel', kuerzel: 'GO');
      final List<String> warnungen =
          ApiUploadService.pruefeTerminalIdsGegenKonfiguration(
        <String>['12345'],
        gondel,
        konfiguration,
      );

      expect(warnungen, hasLength(1));
      expect(warnungen.single, contains('keine TID'));
    });

    test('unbekanntes Kino (kino == null) → keine Warnung statt Absturz',
        () {
      expect(
        ApiUploadService.pruefeTerminalIdsGegenKonfiguration(
          <String>['54017635'],
          null,
          konfiguration,
        ),
        isEmpty,
      );
    });
  });

  group('ApiUploadService.tidsAusSettlementsBody', () {
    test('extrahiert alle TIDs aus einem gebauten settlementsBody()', () {
      final Map<String, dynamic> body = <String, dynamic>{
        'settlements': <Map<String, dynamic>>[
          <String, dynamic>{
            'cash_total': 0,
            'terminals': <Map<String, dynamic>>[
              <String, dynamic>{'tid': 'A'},
              <String, dynamic>{'tid': 'B'},
            ],
          },
        ],
      };

      expect(
        ApiUploadService.tidsAusSettlementsBody(body),
        <String>['A', 'B'],
      );
    });
  });

  group('ApiUploadService.settlementsBody als Sende-Signatur (Run 401)', () {
    // tagesabschluss_schritt3_seite.dart leitet die "gesendet"-Signatur aus
    // settlementsBody() ab (ohne sent_at) — die Tests hier sichern genau
    // die Eigenschaften, auf die sich dieser Vergleich verlässt.
    TagesabschlussFinal abrechnung({
      int barBestandAbzglWechselgeldCent = 10000,
      int differenzAnfangsbestandCent = 0,
      int ecUmsatzGesamtCent = 0,
      List<ZahlungsartErgebnis>? zahlungsartenAufschluesselung,
    }) {
      return TagesabschlussFinal(
        kinoId: 'kino_01',
        kinoName: 'Schauburg',
        datum: DateTime(2026, 8, 16),
        createdAt: DateTime(2026, 8, 16, 23, 0),
        scheineCent: 10000,
        loseMuenzenCent: 0,
        rollenCent: 0,
        umschlaegeCent: 0,
        kassenbestandGesamtCent: 10000,
        wechselgeldSollwertCent: 0,
        barBestandAbzglWechselgeldCent: barBestandAbzglWechselgeldCent,
        kinoSollCent: 5000,
        bistroSollCent: 0,
        ausgabenCent: 0,
        ecBelegeCent: <int>[ecUmsatzGesamtCent],
        ecUmsatzGesamtCent: ecUmsatzGesamtCent,
        gesamtSollCent: 5000,
        gesamtIstCent: 5000,
        differenzGesamtCent: 0,
        differenzAnfangsbestandCent: differenzAnfangsbestandCent,
        zahlungsartenAufschluesselung: zahlungsartenAufschluesselung,
      );
    }

    String signatur(TagesabschlussFinal a, {DateTime? jetzt}) {
      final Map<String, dynamic> body =
          ApiUploadService.settlementsBody(a, jetzt: jetzt);
      final Map<String, dynamic> settlement =
          (body['settlements'] as List<dynamic>).first
              as Map<String, dynamic>;
      settlement.remove('sent_at');
      return jsonEncode(body);
    }

    test(
        'gleiche Daten, unterschiedlicher Sendezeitpunkt → identische '
        'Signatur (sent_at darf einen Vergleich nicht verfälschen)', () {
      final TagesabschlussFinal a = abrechnung();
      expect(
        signatur(a, jetzt: DateTime(2026, 8, 16, 20, 0)),
        signatur(a, jetzt: DateTime(2026, 8, 17, 9, 30)),
      );
    });

    test(
        'nur Differenz im Anfangsbestand geändert → Signatur bleibt '
        'gleich (Feld geht nie an Flurbocash)', () {
      expect(
        signatur(abrechnung(differenzAnfangsbestandCent: 0)),
        signatur(abrechnung(differenzAnfangsbestandCent: 500)),
      );
    });

    test('Bargeldbestand geändert → Signatur ändert sich', () {
      expect(
        signatur(abrechnung(barBestandAbzglWechselgeldCent: 10000)),
        isNot(
          signatur(abrechnung(barBestandAbzglWechselgeldCent: 12000)),
        ),
      );
    });

    test('Kartenart-Betrag geändert → Signatur ändert sich', () {
      final TagesabschlussFinal a = abrechnung(
        ecUmsatzGesamtCent: 2000,
        zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
          ZahlungsartErgebnis(art: 'Girocard', betragCent: 2000),
        ],
      );
      final TagesabschlussFinal b = abrechnung(
        ecUmsatzGesamtCent: 1500,
        zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
          ZahlungsartErgebnis(art: 'Girocard', betragCent: 1500),
        ],
      );
      expect(signatur(a), isNot(signatur(b)));
    });

    test(
        'EC-Umsatz ohne Kartenart-Aufschlüsselung (unvollständige Daten) → '
        'wirft nicht, wird von _sendeSignatur() als Sentinel behandelt '
        '(Absturzschutz, siehe tagesabschluss_schritt3_seite.dart)', () {
      // settlementsBody() selbst wirft hier bewusst (siehe Test oben bei
      // "EC-Umsatz > 0 ohne Aufschlüsselung") — dieser Test dokumentiert
      // nur, dass der Aufrufer (die Seite) das abfangen muss, nicht dass
      // settlementsBody() selbst sich anders verhält.
      expect(
        () => ApiUploadService.settlementsBody(
          abrechnung(ecUmsatzGesamtCent: 1000),
        ),
        throwsException,
      );
    });
  });
}
