import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class CollapsibleCardSection extends StatelessWidget {
  const CollapsibleCardSection({
    super.key,
    required this.gesamtbetrag,
    required this.aufgeklappt,
    required this.beimUmschalten,
    required this.inhalt,
    required this.headerText,
    required this.hilfeDialogTitel,
    required this.hilfeDialogInhalt,
  });

  final String gesamtbetrag;
  final bool aufgeklappt;
  final VoidCallback beimUmschalten;
  final Widget inhalt;
  final TextSpan headerText;
  final String hilfeDialogTitel;
  final Widget hilfeDialogInhalt;

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
                        Flexible(
                          child: Text.rich(headerText),
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          color: AppFarben.appBarRot,
                          iconSize: 18,
                          padding: const EdgeInsets.only(left: 4),
                          constraints: const BoxConstraints(),
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (BuildContext ctx) => AlertDialog(
                              title: Text(hilfeDialogTitel),
                              content: hilfeDialogInhalt,
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
