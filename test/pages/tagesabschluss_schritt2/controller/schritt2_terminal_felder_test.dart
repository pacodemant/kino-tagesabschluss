import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/controller/schritt2_terminal_felder.dart';

/// Run 490: EC-Feld je Terminal in Schritt 2.
void main() {
  const List<TerminalEintrag> sb = <TerminalEintrag>[
    TerminalEintrag(tid: '60561994', nummer: '1'),
    TerminalEintrag(tid: '60561996', nummer: '2'),
    TerminalEintrag(tid: '60561997', nummer: '3', kinokasse: true),
  ];

  bool leer({
    List<TerminalEintrag> terminals = sb,
    int feldAnzahl = 3,
    String label = '60561996',
    int betragCent = 0,
    bool gescannt = false,
    String gesamtBetragText = '',
  }) => Schritt2TerminalFelder.istLeererTerminalPlatz(
    terminals: terminals,
    feldAnzahl: feldAnzahl,
    label: label,
    betragCent: betragCent,
    gescannt: gescannt,
    gesamtBetragText: gesamtBetragText,
  );

  group('istLeererTerminalPlatz', () {
    test('vorausgefülltes Geräte-Feld ohne Beleg -> leer', () {
      expect(leer(), isTrue);
    });

    test('Betrag, Scan oder getippter Gesamtbetrag -> nicht leer', () {
      expect(leer(betragCent: 100), isFalse);
      expect(leer(gescannt: true), isFalse);
      expect(leer(gesamtBetragText: '1,00'), isFalse);
    });

    test('TID nicht eingetragen oder manuell geleert -> nicht leer', () {
      expect(leer(label: '12345678'), isFalse);
      expect(leer(label: ''), isFalse);
    });

    test('Ein-Feld-Modus oder keine Terminals -> nie leer (Pflichtfeld)', () {
      expect(leer(feldAnzahl: 1), isFalse);
      expect(leer(terminals: const <TerminalEintrag>[]), isFalse);
    });
  });

  group('zielIndex', () {
    const List<String> labels = <String>['60561994', '60561996', '60561997'];

    test('Scan aus Feld 1 mit TID von Gerät 3 -> landet in Feld 3', () {
      expect(
        Schritt2TerminalFelder.zielIndex(
          gescannteTid: '60561997',
          belegIndex: 0,
          labels: labels,
          istLeer: (_) => true,
        ),
        2,
      );
    });

    test('Ziel-Feld schon belegt -> bleibt beim angetippten Feld', () {
      expect(
        Schritt2TerminalFelder.zielIndex(
          gescannteTid: '60561997',
          belegIndex: 0,
          labels: labels,
          istLeer: (int j) => j != 2,
        ),
        0,
      );
    });

    test('fremde oder leere TID -> bleibt beim angetippten Feld', () {
      for (final String? tid in <String?>['12345678', '', null]) {
        expect(
          Schritt2TerminalFelder.zielIndex(
            gescannteTid: tid,
            belegIndex: 1,
            labels: labels,
            istLeer: (_) => true,
          ),
          1,
        );
      }
    });
  });
}
