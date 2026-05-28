import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/collapsible_card_section.dart';

class Schritt1MuenzenLoseSection extends StatelessWidget {
  const Schritt1MuenzenLoseSection({
    super.key,
    required this.gesamtbetrag,
    required this.aufgeklappt,
    required this.beimUmschalten,
    required this.inhalt,
  });

  final String gesamtbetrag;
  final bool aufgeklappt;
  final VoidCallback beimUmschalten;
  final Widget inhalt;

  @override
  Widget build(BuildContext context) {
    return CollapsibleCardSection(
      gesamtbetrag: gesamtbetrag,
      aufgeklappt: aufgeklappt,
      beimUmschalten: beimUmschalten,
      inhalt: inhalt,
      headerText: const TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'Lose Münzen ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: 'Beträge',
            style: TextStyle(fontSize: 10),
          ),
          TextSpan(
            text: ' in ',
            style: TextStyle(fontSize: 10),
          ),
          TextSpan(
            text: 'Cent',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppFarben.appBarRot,
              fontSize: 10,
            ),
          ),
        ],
      ),
      hilfeDialogTitel: 'Münzgeld eingeben',
      hilfeDialogInhalt: const Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: 'Hier die '),
            TextSpan(
              text: 'Beträge',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' der verschiedenen Münzen und ggf. Umschläge u.a. eingeben.\n'),
            TextSpan(text: 'Also z.B. "340" für drei Euro und vierzig Cent.'),
          ],
        ),
      ),
    );
  }
}
