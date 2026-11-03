import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Kleines grünes Badge für Verlauf-Liste und Verlauf-Detail (Run 506),
/// markiert einen bestätigt an Flurbocash übertragenen Tagesabschluss
/// (gesendetAm gesetzt). Gegenstück zu NichtGesendetBadge, beide
/// schließen sich aus; "Korrigiert" kann zusätzlich daneben stehen.
class GesendetBadge extends StatelessWidget {
  const GesendetBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppFarben.differenzPositiv,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Gesendet',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
