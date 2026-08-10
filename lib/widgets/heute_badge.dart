import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Kleines "Heute"-Badge für Verlauf-Liste und Verlauf-Detail,
/// markiert den heutigen Tagesabschluss-Eintrag.
class HeuteBadge extends StatelessWidget {
  const HeuteBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppFarben.heuteBadgeHintergrund,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Heute',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
