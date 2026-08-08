import 'package:flutter/material.dart';

class EinstellungenPwaInstallSection extends StatelessWidget {
  const EinstellungenPwaInstallSection({
    super.key,
    required this.onInstall,
  });

  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'App installieren',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Füge die App zum Home-Bildschirm hinzu, um sie wie eine native App zu nutzen.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onInstall,
                  child: const Text('App installieren'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
