import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class Schritt2PersonalgetraenkeSection extends StatelessWidget {
  const Schritt2PersonalgetraenkeSection({
    super.key,
    required this.gebont,
    required this.onChanged,
  });

  final bool gebont;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
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
