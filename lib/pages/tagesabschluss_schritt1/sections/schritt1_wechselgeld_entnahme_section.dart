import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';

/// Einmalige, tagesbezogene Entnahme aus der Wechselgeldkasse (z. B.
/// Rollengeld-Vorschuss, der am Folgetag zurückgelegt wird). Wird NICHT
/// wie eine Ausgabe behandelt, sondern gleicht rechnerisch nur den
/// fehlenden physischen Bestand aus – siehe
/// TagesabschlussBerechnung.barumsatzBereinigtCent.
class Schritt1WechselgeldEntnahmeSection extends StatelessWidget {
  const Schritt1WechselgeldEntnahmeSection({
    super.key,
    required this.betragController,
    required this.grundController,
    required this.betragFocusNode,
    required this.grundFocusNode,
    required this.beiBetragGeaendert,
    required this.beiGrundGeaendert,
    required this.betragFehlerhaft,
    required this.grundFehlerhaft,
  });

  final TextEditingController betragController;
  final TextEditingController grundController;
  final FocusNode betragFocusNode;
  final FocusNode grundFocusNode;
  final ValueChanged<String> beiBetragGeaendert;
  final ValueChanged<String> beiGrundGeaendert;
  final bool betragFehlerhaft;
  final bool grundFehlerhaft;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Entnahme Wechselgeldkasse',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  color: AppFarben.appBarRot,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => zeigeInfoDialog(
                    context,
                    titel: 'Entnahme Wechselgeldkasse',
                    inhalt: const Text(
                      'Nur ausfüllen, wenn heute Bargeld aus der '
                      'Wechselgeldkasse entnommen wurde, das zeitnah '
                      'zurückgelegt wird – z. B. ein Rollengeld-Vorschuss '
                      'von 600 €, der morgen wieder eingelegt wird. Der '
                      'Betrag gleicht rechnerisch aus, dass heute weniger '
                      'Bargeld in der Kasse liegt, ohne dass es als '
                      'fehlender Barumsatz gilt.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BetragCentEingabefeld(
              textController: betragController,
              focusNode: betragFocusNode,
              onChanged: beiBetragGeaendert,
              schriftgroesse: 15,
              hinweisText: '0,00 €',
              labelText: 'Betrag €',
              istHervorgehoben: betragFehlerhaft,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: grundController,
              focusNode: grundFocusNode,
              onChanged: beiGrundGeaendert,
              decoration: InputDecoration(
                labelText: 'Grund',
                hintText: 'z. B. Rollengeld-Vorschuss',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: grundFehlerhaft ? 'Bitte Grund angeben' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
