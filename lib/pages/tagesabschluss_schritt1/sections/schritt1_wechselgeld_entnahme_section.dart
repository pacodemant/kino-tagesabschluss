import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/kompakter_schalter_zeile.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';

/// Einmalige, tagesbezogene Wechselgeldentnahme (z. B. Rollengeld-
/// Vorschuss, der am Folgetag zurückgelegt wird). Wird NICHT wie eine
/// Ausgabe behandelt, sondern gleicht rechnerisch nur den fehlenden
/// physischen Bestand aus – siehe
/// TagesabschlussBerechnung.barumsatzBereinigtCent. Seit Run 468 hinter
/// einem Schalter (Standard: aus, muss bewusst aktiviert werden); erst
/// bei "an" erscheinen Betrag und Grund (Paco-Wunsch: dem seltenen
/// Sonderfall keine Prominenz geben, ein Ein/Aus ist eindeutiger als
/// leere Felder).
class Schritt1WechselgeldEntnahmeSection extends StatelessWidget {
  const Schritt1WechselgeldEntnahmeSection({
    super.key,
    required this.aktiv,
    required this.beiAktivGeaendert,
    required this.betragController,
    required this.grundController,
    required this.betragFocusNode,
    required this.grundFocusNode,
    required this.beiBetragGeaendert,
    required this.beiGrundGeaendert,
    required this.betragFehlerhaft,
    required this.grundFehlerhaft,
  });

  final bool aktiv;
  final ValueChanged<bool> beiAktivGeaendert;
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
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          KompakterSchalterZeile(
            label:
                'Es wurde Geld aus dem Wechselgeldbestand entnommen '
                '(Wechselgeldentnahme)',
            wert: aktiv,
            onChanged: beiAktivGeaendert,
            onHilfe: () => zeigeInfoDialog(
              context,
              titel: 'Wechselgeldentnahme',
              inhalt: const Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text:
                          'Wenn ein Betrag aus der Wechselgeldkasse '
                          'entnommen wird, um ihn morgen als Kleingeld '
                          'wieder hineinzulegen. ',
                    ),
                    TextSpan(
                      text:
                          'Wichtig: eine gut sichtbare Notiz darüber in '
                          'die Wechselgeldkasse legen.',
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
          if (aktiv) ...<Widget>[
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
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppFarben.fokusFarbe,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Zettel mit Betrag und Grund gut sichtbar in die '
                      'Wechselgeldkasse legen!',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
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
