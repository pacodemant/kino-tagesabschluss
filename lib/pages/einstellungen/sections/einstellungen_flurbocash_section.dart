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
    required this.flurbocashLive,
    required this.onFlurbocashLiveGeaendert,
    required this.locationIdStandard,
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

  /// Run 493: Sandbox (aus) oder Livesystem (an). Wählt die
  /// Standard-location_id aus dem Kino-Modell und den passenden Override.
  final bool flurbocashLive;
  final ValueChanged<bool> onFlurbocashLiveGeaendert;

  /// Standard-location_id des aktiven Kinos für die gewählte Umgebung
  /// (null = keine im Code hinterlegt, dann ist das Feld Pflicht).
  final int? locationIdStandard;
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
            SwitchListTile(
              title: const Text('Livesystem'),
              subtitle: Text(
                flurbocashLive
                    ? 'Abrechnungen gehen an das echte Flurbocash'
                    : 'Aus = Sandbox (Testsystem)',
              ),
              value: flurbocashLive,
              onChanged: onFlurbocashLiveGeaendert,
              activeThumbColor: AppFarben.appBarRot,
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: apiUploadUrlController,
                    decoration: InputDecoration(
                      labelText: flurbocashLive
                          ? 'Upload-URL (Live)'
                          : 'Upload-URL (Sandbox)',
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
                    decoration: InputDecoration(
                      labelText: flurbocashLive
                          ? 'location_id (Live)'
                          : 'location_id (Sandbox)',
                      hintText: locationIdStandard != null
                          ? 'leer = Standard $locationIdStandard'
                          : 'kein Standard hinterlegt – bitte eintragen',
                      helperText: locationIdStandard != null
                          ? 'Standard: $locationIdStandard'
                          : null,
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
