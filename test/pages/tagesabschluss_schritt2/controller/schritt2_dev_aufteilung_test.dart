import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/controller/schritt2_terminal_felder.dart';

/// Run 491: Dev-Auto-Fill verteilt die EC-Testsumme auf die Terminals.
void main() {
  test('SB-Testwert 578,20 € auf 3 Terminals: Summe bleibt, Rest-Cent an '
      'das erste', () {
    final List<int> anteile = Schritt2TerminalFelder.devAufteilung(57820, 3);
    expect(anteile, <int>[19274, 19273, 19273]);
    expect(anteile.fold(0, (int s, int a) => s + a), 57820);
  });

  test('keine oder ein Terminal -> ein Beleg mit der ganzen Summe', () {
    expect(Schritt2TerminalFelder.devAufteilung(7750, 0), <int>[7750]);
    expect(Schritt2TerminalFelder.devAufteilung(7750, 1), <int>[7750]);
  });
}
