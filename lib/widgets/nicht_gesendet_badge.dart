import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Kleines Badge für Verlauf-Liste und Verlauf-Detail, markiert einen
/// abgeschlossenen Tagesabschluss, der noch nicht erfolgreich an
/// Flurbocash übertragen wurde.
class NichtGesendetBadge extends StatelessWidget {
  const NichtGesendetBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppFarben.nichtGesendetBadgeHintergrund,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Noch nicht gesendet',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
