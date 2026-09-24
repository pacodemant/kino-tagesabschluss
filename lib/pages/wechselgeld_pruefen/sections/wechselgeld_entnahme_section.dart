import 'package:flutter/material.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/kompakter_schalter_zeile.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';

/// Morgen-Prüfung: Schalter "Notiz über Wechselgeldentnahme gefunden".
/// Standard aus; nur bei "an" erscheint das Betragsfeld, dessen Wert beim
/// Vergleich mit dem Sollwert berücksichtigt wird. Die App kann nicht
/// wissen, ob das entnommene Geld schon wieder in der Kasse liegt — das
/// entscheidet der MA anhand des Zettels (siehe Run 469).
class WechselgeldEntnahmeNotizSection extends StatelessWidget {
  const WechselgeldEntnahmeNotizSection({
    super.key,
    required this.aktiv,
    required this.beiAktivGeaendert,
    required this.betragController,
    required this.betragFocusNode,
    required this.beiBetragGeaendert,
  });

  final bool aktiv;
  final ValueChanged<bool> beiAktivGeaendert;
  final TextEditingController betragController;
  final FocusNode betragFocusNode;
  final ValueChanged<String> beiBetragGeaendert;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          KompakterSchalterZeile(
            label: 'Notiz über Wechselgeldentnahme gefunden',
            wert: aktiv,
            onChanged: beiAktivGeaendert,
            onHilfe: () => zeigeInfoDialog(
              context,
              titel: 'Wechselgeldentnahme',
              inhalt: const Text(
                'Liegt in der Wechselgeldkasse eine Notiz über eine '
                'Wechselgeldentnahme des Vortags und das Geld ist noch '
                'nicht zurückgelegt: Schalter einschalten und den Betrag '
                'von der Notiz eintragen. Er wird beim Vergleich mit dem '
                'Sollwert berücksichtigt. Ist das Geld schon wieder in '
                'der Kasse, bleibt der Schalter aus.',
              ),
            ),
          ),
          if (aktiv) ...<Widget>[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: BetragCentEingabefeld.standardBreite,
                  child: BetragCentEingabefeld(
                    textController: betragController,
                    focusNode: betragFocusNode,
                    onChanged: beiBetragGeaendert,
                    hinweisText: 'Betrag laut Notiz',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
