import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';

/// Einmalige, tagesbezogene Entnahme aus der Wechselgeldkasse (z. B.
/// Rollengeld-Vorschuss, der am Folgetag zurückgelegt wird). Wird NICHT
/// wie eine Ausgabe behandelt, sondern gleicht rechnerisch nur den
/// fehlenden physischen Bestand aus – siehe
/// TagesabschlussBerechnung.barumsatzBereinigtCent. Einklappbar wie die
/// anderen Schritt-1-Kacheln, standardmäßig zugeklappt (Paco-Wunsch:
/// dem seltenen Sonderfall nicht zu viel Prominenz geben).
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
    required this.aufgeklappt,
    required this.beimUmschalten,
    required this.betragAnzeige,
  });

  final TextEditingController betragController;
  final TextEditingController grundController;
  final FocusNode betragFocusNode;
  final FocusNode grundFocusNode;
  final ValueChanged<String> beiBetragGeaendert;
  final ValueChanged<String> beiGrundGeaendert;
  final bool betragFehlerhaft;
  final bool grundFehlerhaft;
  final bool aufgeklappt;
  final VoidCallback beimUmschalten;
  final String betragAnzeige;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: beimUmschalten,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Entnahme Wechselgeldkasse',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    betragAnzeige,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    color: AppFarben.appBarRot,
                    iconSize: 20,
                    padding: const EdgeInsets.only(left: 4),
                    constraints: const BoxConstraints(),
                    onPressed: () => zeigeInfoDialog(
                      context,
                      titel: 'Entnahme Wechselgeldkasse',
                      inhalt: const Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Wenn ein Betrag entnommen wird, um ihn '
                                  'morgen als Kleingeld wieder in die '
                                  'Wechselgeldkasse zurückzulegen. ',
                            ),
                            TextSpan(
                              text: 'Wichtig: eine gut sichtbare Notiz '
                                  'darüber in die Wechselgeldkasse legen.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppFarben.appBarRot,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Icon(aufgeklappt ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (aufgeklappt) ...<Widget>[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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
          ],
        ],
      ),
    );
  }
}
