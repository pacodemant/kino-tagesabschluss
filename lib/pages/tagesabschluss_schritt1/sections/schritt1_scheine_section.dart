import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/collapsible_card_section.dart';

class Schritt1ScheineSection extends StatelessWidget {
  const Schritt1ScheineSection({
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
            text: 'Scheine ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: 'Anzahl',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppFarben.appBarRot,
              fontSize: 10,
            ),
          ),
          TextSpan(
            text: ' der Scheine',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
      hilfeDialogTitel: 'Scheine eingeben',
      hilfeDialogInhalt: const Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: 'Scheine einfach zählen und '),
            TextSpan(
              text: 'Anzahl',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' eingeben, nicht den Betrag.\n'),
            TextSpan(text: 'Also z.B. "3" für drei 50-Euro-Scheine, nicht "150".'),
          ],
        ),
      ),
    );
  }
}
