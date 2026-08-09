import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class EinstellungenStandortAdminSection extends StatelessWidget {
  const EinstellungenStandortAdminSection({
    super.key,
    required this.standortModusKinoId,
    required this.onStandortModusGeaendert,
    required this.adminStatusHaltenAktiv,
    required this.onAdminStatusHaltenGeaendert,
  });

  final String? standortModusKinoId;
  final ValueChanged<String?> onStandortModusGeaendert;
  final bool adminStatusHaltenAktiv;
  final ValueChanged<bool> onAdminStatusHaltenGeaendert;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppFarben.gruppierungBandA,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Standort',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                DropdownButton<String?>(
                  value: standortModusKinoId,
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Alle'),
                    ),
                    for (final Kino kino in KinoRepository.kinos)
                      DropdownMenuItem<String?>(
                        value: kino.id,
                        child: Text(kino.name),
                      ),
                  ],
                  onChanged: onStandortModusGeaendert,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Bei fester Auswahl entfällt für den Mitarbeiter '
              'die Kinoauswahl und der Button "Kino wechseln".',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          SwitchListTile(
            title: const Text('Admin-Status halten'),
            value: adminStatusHaltenAktiv,
            onChanged: onAdminStatusHaltenGeaendert,
            activeThumbColor: AppFarben.appBarRot,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Hält Admin-Status bis zum nächsten Laden/Öffnen '
              'aufrecht.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
