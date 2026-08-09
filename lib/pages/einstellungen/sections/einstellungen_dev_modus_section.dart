import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class EinstellungenDevModusSection extends StatelessWidget {
  const EinstellungenDevModusSection({
    super.key,
    required this.devModusAktiv,
    required this.onDevModusGeaendert,
    required this.testwertAufgeklappt,
    required this.onToggleTestwertAufgeklappt,
    required this.onSetzeStandardTestwerte,
    required this.autoFillInhalt,
  });

  final bool devModusAktiv;
  final ValueChanged<bool> onDevModusGeaendert;
  final bool testwertAufgeklappt;
  final VoidCallback onToggleTestwertAufgeklappt;
  final VoidCallback onSetzeStandardTestwerte;
  final Widget autoFillInhalt;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppFarben.gruppierungBandA,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Dev-Modus (Auto-Fill)'),
            value: devModusAktiv,
            onChanged: onDevModusGeaendert,
            activeThumbColor: AppFarben.appBarRot,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Blendet die Auto-Fill-Werkzeuge auf Schritt '
              '1-3 ein oder aus.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Testwerte',
                  style: TextStyle(fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: onToggleTestwertAufgeklappt,
                  icon: Icon(
                    testwertAufgeklappt
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                  label: const Text('Werte eingeben'),
                ),
              ],
            ),
          ),
          if (testwertAufgeklappt) ...<Widget>[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onSetzeStandardTestwerte,
                  child: const Text('Standard-Testwerte übernehmen'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: autoFillInhalt,
            ),
          ],
        ],
      ),
    );
  }
}
