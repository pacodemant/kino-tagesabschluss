import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class Schritt1MuenzenRollenSection extends StatelessWidget {
  const Schritt1MuenzenRollenSection({
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              'Rollen',
                              style: TextStyle(fontWeight: FontWeight.w700),
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
                                  title: const Text('Rollen eingeben'),
                                  content: const Text(
                                    'Bitte die Anzahl der Münzrollen eingeben — nicht den Betrag.\n'
                                    'Eine Rolle 2-Euro-Münzen hat z.B. einen Wert von 50 €.\n'
                                    'Also "2" für zwei Rollen, nicht "100".',
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
                        const Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: AppFarben.appBarRot,
                              fontSize: 11,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Anzahl',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(text: ' der Rollen'),
                            ],
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
