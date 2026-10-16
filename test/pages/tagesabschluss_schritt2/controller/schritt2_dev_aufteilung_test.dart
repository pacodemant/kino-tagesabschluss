import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/controller/schritt2_terminal_felder.dart';

/// Run 491: Dev-Auto-Fill verteilt die EC-Testsumme auf die Terminals.
void main() {
  test('SB-Testwert 578,20 € auf 3 Terminals: deutlich verschiedene '
      'Anteile (9:5:3), Summe bleibt', () {
    final List<int> anteile = Schritt2TerminalFelder.devAufteilung(57820, 3);
    expect(anteile, <int>[30612, 17005, 10203]);
    expect(anteile.fold(0, (int s, int a) => s + a), 57820);
  });

  test('Kartenmix je Beleg verschieden, Summe stimmt exakt (Run 492a)', () {
    for (int i = 0; i < 4; i++) {
      final Map<String, int> karten =
          Schritt2TerminalFelder.devKartenAufteilung(17005, i);
      expect(karten.values.fold(0, (int s, int a) => s + a), 17005);
      expect(karten.length, greaterThan(1));
    }
    expect(
      Schritt2TerminalFelder.devKartenAufteilung(17005, 1).keys,
      containsAll(<String>['Girocard', 'Maestro']),
    );
  });

  test('keine oder ein Terminal -> ein Beleg mit der ganzen Summe', () {
    expect(Schritt2TerminalFelder.devAufteilung(7750, 0), <int>[7750]);
    expect(Schritt2TerminalFelder.devAufteilung(7750, 1), <int>[7750]);
  });
}
