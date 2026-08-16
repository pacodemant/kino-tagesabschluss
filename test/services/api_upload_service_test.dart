import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';

void main() {
  group('ApiUploadService.settlementsBody', () {
    TagesabschlussFinal abrechnung({
      int ecUmsatzGesamtCent = 0,
      List<ZahlungsartErgebnis>? zahlungsartenAufschluesselung,
      String? terminalId,
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
  });
}
