import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class EinstellungenFlurbocashSection extends StatelessWidget {
  const EinstellungenFlurbocashSection({
    super.key,
    required this.apiUploadAktiv,
    required this.onApiUploadGeaendert,
    required this.apiUploadUrlController,
    required this.onApiUploadUrlGeaendert,
    required this.locationIdController,
    required this.locationIdFocusNode,
    required this.onLocationIdGeaendert,
    required this.flurbocashApiKeyController,
    required this.flurbocashApiKeyFocusNode,
    required this.onFlurbocashApiKeyGeaendert,
  });

  final bool apiUploadAktiv;
  final ValueChanged<bool> onApiUploadGeaendert;
  final TextEditingController apiUploadUrlController;
  final VoidCallback onApiUploadUrlGeaendert;
  final TextEditingController locationIdController;
  final FocusNode locationIdFocusNode;
  final VoidCallback onLocationIdGeaendert;
  final TextEditingController flurbocashApiKeyController;
  final FocusNode flurbocashApiKeyFocusNode;
  final VoidCallback onFlurbocashApiKeyGeaendert;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppFarben.gruppierungBandA,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Flurbocash-Anbindung'),
            value: apiUploadAktiv,
            onChanged: onApiUploadGeaendert,
            activeThumbColor: AppFarben.appBarRot,
          ),
          if (apiUploadAktiv) ...<Widget>[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: apiUploadUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Upload-URL',
                      hintText: 'https://...',
                      isDense: true,
                    ),
                    onChanged: (_) => onApiUploadUrlGeaendert(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationIdController,
                    focusNode: locationIdFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'location_id',
                      isDense: true,
                    ),
                    onChanged: (_) => onLocationIdGeaendert(),
                    onEditingComplete: () => locationIdFocusNode.unfocus(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: flurbocashApiKeyController,
                    focusNode: flurbocashApiKeyFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'API-Key',
                      isDense: true,
                    ),
                    onChanged: (_) => onFlurbocashApiKeyGeaendert(),
                    onEditingComplete: () =>
                        flurbocashApiKeyFocusNode.unfocus(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
