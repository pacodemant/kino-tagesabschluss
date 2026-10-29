import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/domain/tagesabschluss_finalisieren_usecase.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/controller/schritt2_terminal_felder.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:kino_bar_app/widgets/uebertrag_umschlag_inhalt.dart';
import 'package:kino_bar_app/models/flurbocash_zuordnung.dart';

/// Run 498: "Kein Beleg möglich" — Terminal konnte keinen Kassenschnitt
/// drucken. Geht mit 0 € (ohne no_sales) an Flurbocash, Vermerk nur im
/// gesendeten Kommentar.
void main() {
  final String vermerk =
      Schritt2TerminalFelder.keinBelegVermerk('60561996', '2');

  TagesabschlussFinal finalisiere({String? anmerkung}) {
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
        ecBelegeCent: const <int>[30000, 0],
        differenzAnfangsbestandCent: 0,
        stueckzahlen: const <String, int>{},
        loseMuenzenNachArtCent: const <String, int>{},
        ecBelegeLabels: const <String>['60561994', '60561996'],
        zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
          ZahlungsartErgebnis(
            art: 'Girocard',
            betragCent: 30000,
            tid: '60561994',
            belegIndex: 0,
          ),
        ],
        anmerkung: anmerkung,
        keinBelegMoeglichTids: const <String>['60561996'],
        sendeVermerke: <String>[vermerk],
      ),
      jetzt: DateTime(2026, 10, 29, 22, 0),
    );
  }

  Map<String, dynamic> settlement(TagesabschlussFinal a,
          {FlurbocashZuordnung? korrekturVon}) =>
      (ApiUploadService.settlementsBody(a, korrekturVon: korrekturVon)[
              'settlements'] as List<dynamic>)
          .single as Map<String, dynamic>;

  test('Vermerk-Text mit und ohne Gerätenummer', () {
    expect(vermerk, 'Für Terminal 2 (TID 60561996) kein Beleg möglich');
    expect(
      Schritt2TerminalFelder.keinBelegVermerk('60561996', null),
      'Für Terminal (TID 60561996) kein Beleg möglich',
    );
  });

  test('Flurbocash: Terminal mit 0 in allen Kartenarten, ohne no_sales', () {
    final List<Map<String, dynamic>> terminals =
        (settlement(finalisiere())['terminals'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(terminals, hasLength(2));
    final Map<String, dynamic> t = terminals
        .singleWhere((Map<String, dynamic> t) => t['tid'] == '60561996');
    expect(t.containsKey('no_sales'), isFalse);
    for (final String art in <String>[
      'girocard',
      'lastschrift',
      'mastercard',
      'visa',
      'maestro',
      'vpay',
    ]) {
      expect(t[art], 0, reason: art);
    }
  });

  test('Korrektur: Terminal steht genau einmal drin', () {
    final List<dynamic> terminals = settlement(
      finalisiere(),
      korrekturVon: const FlurbocashZuordnung(
        reportId: 1,
        settlementNummer: 2,
        tids: <String>['60561994', '60561996'],
      ),
    )['terminals'] as List<dynamic>;
    expect(
      terminals.where((dynamic t) => (t as Map)['tid'] == '60561996'),
      hasLength(1),
    );
  });

  test('Kommentar: Vermerk nur im gesendeten note, Kommentar der MA '
      'unverändert', () {
    final TagesabschlussFinal a = finalisiere(anmerkung: 'Drucker leer');
    expect(a.anmerkung, 'Drucker leer');
    expect(settlement(a)['note'], 'Drucker leer\n$vermerk');
    expect(settlement(finalisiere())['note'], vermerk);
  });

  test('Signatur enthält den Vermerk (Korrektur-Erkennung stabil)', () {
    final TagesabschlussFinal a = finalisiere(anmerkung: 'Drucker leer');
    final Map<String, dynamic> sig =
        jsonDecode(ApiUploadService.sendeSignatur(a)) as Map<String, dynamic>;
    expect(
      ((sig['settlements'] as List<dynamic>).single as Map)['note'],
      'Drucker leer\n$vermerk',
    );
    expect(
      ApiUploadService.sendeSignatur(a),
      ApiUploadService.sendeSignatur(TagesabschlussFinal.fromJson(a.toJson())),
    );
  });

  test('JSON: neue Felder bleiben erhalten, alter Eintrag ohne -> null', () {
    final TagesabschlussFinal a = finalisiere();
    final TagesabschlussFinal geladen = TagesabschlussFinal.fromJson(a.toJson());
    expect(geladen.keinBelegMoeglichTids, <String>['60561996']);
    expect(geladen.sendeVermerke, <String>[vermerk]);
    final Map<String, dynamic> alt = a.toJson()
      ..remove('keinBelegMoeglichTids')
      ..remove('sendeVermerke');
    final TagesabschlussFinal altGeladen = TagesabschlussFinal.fromJson(alt);
    expect(altGeladen.keinBelegMoeglichTids, isNull);
    expect(altGeladen.sendeVermerke, isNull);
  });

  const List<TerminalEintrag> terminals = <TerminalEintrag>[
    TerminalEintrag(tid: '60561994', nummer: '1'),
    TerminalEintrag(tid: '60561996', nummer: '2'),
  ];

  test('Umschlag: EC-Zeile 0,00 € mit Zusatz "kein Beleg" (Run 499)', () {
    final List<UmschlagEcZeile> zeilen =
        UebertragUmschlagInhalt.ecZeilenSb(finalisiere(), terminals);
    expect(zeilen[0].info, 'Gerät 1 · TID 60561994');
    expect(zeilen[1].cent, 0);
    expect(zeilen[1].info, 'Gerät 2 · TID 60561996 · kein Beleg');
  });

  test('Hinweis unter der Differenz (Run 499, auch für SB)', () {
    expect(
      UebertragUmschlagInhalt.keinBelegHinweis(finalisiere(), terminals),
      'Kein Beleg für Gerät 2 (TID 60561996): Die Differenz kann deshalb '
      'höher ausfallen.',
    );
    final TagesabschlussFinal ohne =
        TagesabschlussFinal.fromJson(finalisiere().toJson()
          ..remove('keinBelegMoeglichTids'));
    expect(UebertragUmschlagInhalt.keinBelegHinweis(ohne, terminals), isNull);
  });
}
