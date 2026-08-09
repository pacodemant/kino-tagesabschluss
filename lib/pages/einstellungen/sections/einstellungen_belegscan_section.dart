import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class EinstellungenBelegscanSection extends StatelessWidget {
  const EinstellungenBelegscanSection({
    super.key,
    required this.belegScanUrlController,
    required this.anthropicApiKeyController,
    required this.onBelegScanUrlGeaendert,
    required this.onAnthropicApiKeyGeaendert,
  });

  final TextEditingController belegScanUrlController;
  final TextEditingController anthropicApiKeyController;
  final VoidCallback onBelegScanUrlGeaendert;
  final VoidCallback onAnthropicApiKeyGeaendert;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppFarben.gruppierungBandB,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'KI-Belegscan (Anthropic)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: belegScanUrlController,
              decoration: const InputDecoration(
                labelText: 'Service-URL',
                hintText: 'z. B. https://…workers.dev',
                isDense: true,
              ),
              onChanged: (_) => onBelegScanUrlGeaendert(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: anthropicApiKeyController,
              decoration: const InputDecoration(
                labelText: 'Anthropic API-Key',
              ),
              onChanged: (_) => onAnthropicApiKeyGeaendert(),
            ),
          ),
        ],
      ),
    );
  }
}
