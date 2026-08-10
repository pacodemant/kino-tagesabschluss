import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Gemeinsames DEV-Tools-Panel für Schritt 1 und Schritt 2
/// (Auto-Fill/Alles-leeren-Werkzeuge, nur Debug/Profile-Build).
class DevToolsPanel extends StatelessWidget {
  const DevToolsPanel({
    super.key,
    required this.onAutoFill,
    required this.onLeeren,
  });

  final VoidCallback onAutoFill;
  final VoidCallback onLeeren;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppFarben.devToolsHintergrund,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'DEV-Tools (nur Debug/Profile)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton(
              onPressed: onAutoFill,
              child: const Text('Auto-Fill'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onLeeren,
              child: const Text('Alles leeren'),
            ),
          ],
        ),
      ),
    );
  }
}
