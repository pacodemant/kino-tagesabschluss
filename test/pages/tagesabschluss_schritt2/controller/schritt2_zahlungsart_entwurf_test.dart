import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/controller/schritt2_zahlungsart_entwurf.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/models/zahlungsart_zeile.dart';

// Reihenfolge wie config/zahlungsarten.json.
const List<String> _config = <String>[
  'Girocard',
  'SEPA Lastschrift',
  'MasterCard',
  'Visa',
  'Maestro',
  'V Pay',
];

List<ZahlungsartZeile> _configZeilen() =>
    _config.map((String n) => ZahlungsartZeile(n)).toList();

Map<String, int?> _betraegeNachName(List<ZahlungsartZeile> zeilen) =>
    <String, int?>{
      for (final ZahlungsartZeile z in zeilen) z.name: z.betragCentWert,
    };

void main() {
  group('Schritt2ZahlungsartEntwurf', () {
    test(
        'Beleg-Reihenfolge != Config-Reihenfolge: Betraege bleiben nach '
        'Speichern + Neuaufbau bei ihrer Kartenart (Fall 06.10.2026)', () {
      // Zustand nach Scan von 60561994: in Beleg-Reihenfolge umsortiert.
      final List<ZahlungsartZeile> alt = _configZeilen();
      final List<ZahlungsartZeile> nachScan = <ZahlungsartZeile>[
        alt[0], // Girocard
        alt[2], // MasterCard
        alt[3], // Visa
        alt[1], // SEPA Lastschrift
        alt[4],
        alt[5],
      ];
      nachScan[0].betragCentWert = 73400;
      nachScan[1].betragCentWert = 4500;
      nachScan[2].betragCentWert = 14600;

      // Rundreise durch JSON wie im echten Entwurf (SharedPreferences).
      final List<dynamic> gespeichert = jsonDecode(jsonEncode(
        Schritt2ZahlungsartEntwurf.zumSpeichern(
          <List<ZahlungsartZeile>>[nachScan],
        ),
      )) as List<dynamic>;

      // Neuaufbau von Schritt 2: Zeilen wieder in Config-Reihenfolge.
      final List<ZahlungsartZeile> geladen =
          Schritt2ZahlungsartEntwurf.wiederherstellen(
        _configZeilen(),
        gespeichert.first as List<dynamic>,
      );

      expect(_betraegeNachName(geladen), <String, int?>{
        'Girocard': 73400,
        'SEPA Lastschrift': null,
        'MasterCard': 4500,
        'Visa': 14600,
        'Maestro': null,
        'V Pay': null,
      });
      // Anzeige-Reihenfolge bleibt wie vor dem Neuaufbau.
      expect(
        geladen.map((ZahlungsartZeile z) => z.name).toList(),
        <String>[
          'Girocard',
          'MasterCard',
          'Visa',
          'SEPA Lastschrift',
          'Maestro',
          'V Pay',
        ],
      );
    });

    test('unbekannter Name im Entwurf wird ignoriert, nicht verschoben', () {
      final List<ZahlungsartZeile> geladen =
          Schritt2ZahlungsartEntwurf.wiederherstellen(
        _configZeilen(),
        <dynamic>[
          <String, dynamic>{'name': 'Amex', 'betragCent': 999},
          <String, dynamic>{'name': 'Visa', 'betragCent': 2550},
        ],
      );
      expect(_betraegeNachName(geladen)['Visa'], 2550);
      expect(
        geladen.where((ZahlungsartZeile z) => z.betragCentWert != null),
        hasLength(1),
      );
    });

    test('Altformat nach Scan: Positionen werden verworfen', () {
      final List<ZahlungsartZeile> zeilen = _configZeilen();
      final bool uebernommen =
          Schritt2ZahlungsartEntwurf.wiederherstellenAltformat(
        zeilen,
        <dynamic>[73400, 4500, 14600, null, null, null],
        scanHatStattgefunden: true,
      );
      expect(uebernommen, isFalse);
      expect(
        zeilen.every((ZahlungsartZeile z) => z.betragCentWert == null),
        isTrue,
      );
    });

    test('Altformat ohne Scan: Positionen in Config-Reihenfolge uebernommen',
        () {
      final List<ZahlungsartZeile> zeilen = _configZeilen();
      final bool uebernommen =
          Schritt2ZahlungsartEntwurf.wiederherstellenAltformat(
        zeilen,
        <dynamic>[1000, null, 500],
        scanHatStattgefunden: false,
      );
      expect(uebernommen, isTrue);
      expect(_betraegeNachName(zeilen)['Girocard'], 1000);
      expect(_betraegeNachName(zeilen)['MasterCard'], 500);
    });
  });
}
