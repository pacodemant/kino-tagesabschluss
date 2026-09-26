import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Kleines Badge für Verlauf-Liste und Verlauf-Detail (Run 479), markiert
/// einen Tagesabschluss, dessen bei Flurbocash gespeicherte Abrechnung
/// durch eine Korrektur ersetzt wurde.
class KorrigiertBadge extends StatelessWidget {
  const KorrigiertBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppFarben.korrigiertBadgeHintergrund,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Korrigiert',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
