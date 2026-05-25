import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

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
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Lose Münzen',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color: AppFarben.appBarRot,
                                    fontSize: 11,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Beträge',
                                      style: TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    TextSpan(text: ' in Cent'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          color: AppFarben.appBarRot,
                          iconSize: 18,
                          padding: const EdgeInsets.only(left: 4),
                          constraints: const BoxConstraints(),
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Münzgeld eingeben'),
                              content: const Text(
                                'Hier den Gesamtbetrag des losen Münzgelds in Cent eingeben — ohne Komma.\n'
                                'Also z.B. "340" für drei Euro und vierzig Cent.',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Verstanden'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    gesamtbetrag,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(aufgeklappt ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (aufgeklappt) ...<Widget>[
            const Divider(height: 1),
            Padding(padding: const EdgeInsets.all(12), child: inhalt),
          ],
        ],
      ),
    );
  }
}
