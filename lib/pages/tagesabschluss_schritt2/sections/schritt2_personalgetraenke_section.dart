import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class Schritt2PersonalgetraenkeSection extends StatelessWidget {
  const Schritt2PersonalgetraenkeSection({
    super.key,
    required this.gebont,
    required this.onChanged,
    this.hervorgehoben = false,
  });

  final bool gebont;
  final ValueChanged<bool?> onChanged;

  /// Roter Rahmen, solange nicht abgehakt: wird gesetzt, wenn die MA
  /// "Weiter" tippt, obwohl die Kachel noch offen ist — der Grund fürs
  /// Nicht-Weiterkommen soll sichtbar sein, nicht nur in einer flüchtigen
  /// SnackBar stehen.
  final bool hervorgehoben;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: (hervorgehoben && !gebont)
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: AppFarben.differenzNegativ,
                width: 2,
              ),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Personalgetränke gebont?'),
                  const SizedBox(height: 4),
                  const Text('Artikel gestundet?'),
                  const SizedBox(height: 4),
                  const Text(
                    "Denk' ans Kellnerportemonnaie.",
                    style: TextStyle(color: AppFarben.differenzNegativ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: gebont,
              onChanged: onChanged,
              activeColor: Colors.green,
              shape: const CircleBorder(),
            ),
          ],
        ),
      ),
    );
  }
}
