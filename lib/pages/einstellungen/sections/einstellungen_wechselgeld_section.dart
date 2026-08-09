import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';

class EinstellungenWechselgeldSection extends StatelessWidget {
  const EinstellungenWechselgeldSection({
    super.key,
    required this.wgController,
    required this.aufgeklappt,
    required this.onToggleAufgeklappt,
    required this.aktiveKinoIndex,
    required this.aktiveKinoName,
    required this.onWgChanged,
  });

  final TextEditingController wgController;
  final bool aufgeklappt;
  final VoidCallback onToggleAufgeklappt;
  final int aktiveKinoIndex;
  final String aktiveKinoName;
  final ValueChanged<String> onWgChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppFarben.gruppierungBandB,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: const Text(
              'Wechselgeldbestand',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (wgController.text.isNotEmpty)
                  Text(
                    wgController.text,
                    style: const TextStyle(fontSize: 11),
                  ),
                const SizedBox(width: 4),
                Icon(
                  aufgeklappt ? Icons.expand_less : Icons.expand_more,
                ),
              ],
            ),
            onTap: onToggleAufgeklappt,
          ),
          if (aufgeklappt && aktiveKinoIndex >= 0) ...<Widget>[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Wechselgeld $aktiveKinoName',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: wgController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        CentWaehrungsEingabeFormatter(),
                      ],
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        suffixText: '€',
                      ),
                      onTap: () {
                        if (wgController.text == '0') wgController.clear();
                      },
                      onChanged: onWgChanged,
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
