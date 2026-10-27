import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/domain/tagesabschluss_finalisieren_usecase.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:kino_bar_app/widgets/uebertrag_umschlag_inhalt.dart';

/// Run 492: "heute keine Umsätze" je Terminal; seit Run 495a ohne Knopf,
/// ausgelöst durch einen Beleg mit 0,00 € (gescannt oder von Hand).
void main() {
  TagesabschlussFinal finalisiere({
    required List<int> ecBelegeCent,
    required List<String> ecBelegeLabels,
    List<String>? keineUmsaetzeTids,
    List<String>? ecBelegeFotosBase64,
  }) {
    return const TagesabschlussFinalisierenUsecase().finalisieren(
      eingabe: TagesabschlussFinalisierenEingabe(
        kinoId: 'kino_01',
        kinoName: 'Schauburg',
        scheineCent: 100000,
        loseMuenzenCent: 0,
        rollenCent: 0,
        umschlaegeCent: 0,
        wechselgeldSollwertCent: 0,
        kinoSollCent: 100000,
        bistroSollCent: 30000,
        ausgabenCent: 0,
        ecBelegeCent: ecBelegeCent,
        differenzAnfangsbestandCent: 0,
        stueckzahlen: const <String, int>{},
        loseMuenzenNachArtCent: const <String, int>{},
        ecBelegeLabels: ecBelegeLabels,
        zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
          for (int i = 0; i < ecBelegeCent.length; i++)
            if (ecBelegeCent[i] > 0)
              ZahlungsartErgebnis(
                art: 'Girocard',
                betragCent: ecBelegeCent[i],
                tid: ecBelegeLabels[i],
                belegIndex: i,
              ),
        ],
        keineUmsaetzeTids: keineUmsaetzeTids,
        ecBelegeFotosBase64: ecBelegeFotosBase64,
      ),
      jetzt: DateTime(2026, 10, 16, 22, 0),
    );
  }

  final TagesabschlussFinal abschluss = finalisiere(
    ecBelegeCent: const <int>[30000, 0, 0],
    ecBelegeLabels: const <String>['60561994', '60561996', '60561997'],
    // 60561994 hat doch einen Beleg -> Merker verfällt
    keineUmsaetzeTids: const <String>['60561994', '60561996', '60561997'],
  );

  test('nur TIDs ohne Betrag bleiben als "keine Umsätze" erhalten', () {
    expect(abschluss.keineUmsaetzeTids, <String>['60561996', '60561997']);
  });

  test('JSON: neues Feld bleibt erhalten, alter Eintrag ohne Feld -> null', () {
    expect(
      TagesabschlussFinal.fromJson(abschluss.toJson()).keineUmsaetzeTids,
      <String>['60561996', '60561997'],
    );
    final Map<String, dynamic> alt = abschluss.toJson()
      ..remove('keineUmsaetzeTids');
    expect(TagesabschlussFinal.fromJson(alt).keineUmsaetzeTids, isNull);
  });

  test('Flurbocash: Terminals mit "keine Umsätze" gehen mit 0-Beträgen und '
      'no_sales mit, das Terminal mit Beleg normal', () {
    final List<dynamic> terminals =
        (ApiUploadService.settlementsBody(abschluss)['settlements']
                    as List<dynamic>)
                .single['terminals']
            as List<dynamic>;
    final Map<String, dynamic> mitBeleg = terminals
        .cast<Map<String, dynamic>>()
        .singleWhere((Map<String, dynamic> t) => t['tid'] == '60561994');
    expect(mitBeleg['girocard'], 30000);
    expect(mitBeleg.containsKey('no_sales'), isFalse);
    for (final String tid in <String>['60561996', '60561997']) {
      final Map<String, dynamic> t = terminals
          .cast<Map<String, dynamic>>()
          .singleWhere((Map<String, dynamic> t) => t['tid'] == tid);
      expect(t['no_sales'], isTrue);
      expect(t['girocard'], 0);
    }
    expect(terminals, hasLength(3));
  });

  test('Umschlag: EC-Zeile 0,00 € mit Zusatz "keine Umsätze"', () {
    final List<UmschlagEcZeile> zeilen =
        UebertragUmschlagInhalt.ecZeilenSb(abschluss, const <TerminalEintrag>[
          TerminalEintrag(tid: '60561994', nummer: '1'),
          TerminalEintrag(tid: '60561996', nummer: '2'),
          TerminalEintrag(tid: '60561997', nummer: '3', kinokasse: true),
        ]);
    expect(zeilen[0].info, 'Gerät 1 · TID 60561994');
    expect(zeilen[1].cent, 0);
    expect(zeilen[1].info, 'Gerät 2 · TID 60561996 · keine Umsätze');
  });

  test('Flurbocash: gescannter 0-€-Beleg geht mit Foto als no_sales mit '
      '(Run 495a)', () {
    final TagesabschlussFinal mitFoto = finalisiere(
      ecBelegeCent: const <int>[30000, 0],
      ecBelegeLabels: const <String>['60561994', '60561996'],
      keineUmsaetzeTids: const <String>['60561996'],
      ecBelegeFotosBase64: const <String>['FOTO_A', 'FOTO_NULL'],
    );
    final List<Map<String, dynamic>> terminals =
        ((ApiUploadService.settlementsBody(mitFoto)['settlements']
                        as List<dynamic>)
                    .single['terminals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    final Map<String, dynamic> nullEuro = terminals
        .singleWhere((Map<String, dynamic> t) => t['tid'] == '60561996');
    expect(nullEuro['no_sales'], isTrue);
    expect(nullEuro['receipt_photo'], 'FOTO_NULL');
    expect(
      terminals.singleWhere(
        (Map<String, dynamic> t) => t['tid'] == '60561994',
      )['receipt_photo'],
      'FOTO_A',
    );
  });

  group('Kommentar-Vermerk bei 0,00 € ohne Scan (Run 495a)', () {
    const String vermerk = 'TID 60561996: Beleg konnte nicht gescannt '
        'werden – 0,00 € von Hand eingetragen.';

    test('leerer Kommentar → nur der Vermerk', () {
      expect(
        TagesabschlussSchritt3Seite.anmerkungMitScanVermerken(
          '',
          const <String>['60561996'],
        ),
        vermerk,
      );
    });

    test('Text der MA bleibt, Vermerk wird angehängt, nicht doppelt', () {
      final String einmal =
          TagesabschlussSchritt3Seite.anmerkungMitScanVermerken(
        'Kasse 2 klemmt',
        const <String>['60561996'],
      );
      expect(einmal, 'Kasse 2 klemmt\n$vermerk');
      expect(
        TagesabschlussSchritt3Seite.anmerkungMitScanVermerken(
          einmal,
          const <String>['60561996'],
        ),
        einmal,
      );
    });

    test('keine TIDs → Kommentar unverändert', () {
      expect(
        TagesabschlussSchritt3Seite.anmerkungMitScanVermerken(
          'Kasse 2 klemmt',
          const <String>[],
        ),
        'Kasse 2 klemmt',
      );
    });
  });
}
