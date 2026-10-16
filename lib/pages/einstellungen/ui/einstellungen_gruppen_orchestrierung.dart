import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_belegscan_section.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_dev_modus_section.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_flurbocash_section.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_getraenkeliste_section.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_pwa_install_section.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_standort_admin_section.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_wechselgeld_section.dart';

// Zweck: Kapselt den Gruppen-/Wrapper-Aufbau fuer die Einstellungen-Seite,
// analog zu schritt2_gruppen_orchestrierung.dart. Wird in den naechsten
// Sub-Runs der build()-Zerlegungs-Serie um weitere Sections ergaenzt
// (Admin-Card-Baender).
class EinstellungenGruppenOrchestrierung {
  const EinstellungenGruppenOrchestrierung();

  EinstellungenSectionWidgets baueSections({
    required String kinoKuerzel,
    required bool getraenkelisteAufgeklappt,
    required VoidCallback onToggleGetraenkelisteAufgeklappt,
    required Widget getraenkelisteInhalt,
    required bool pwaInstallVerfuegbar,
    required VoidCallback onPwaInstall,
    required TextEditingController belegScanUrlController,
    required TextEditingController anthropicApiKeyController,
    required VoidCallback onBelegScanUrlGeaendert,
    required VoidCallback onAnthropicApiKeyGeaendert,
    required String? standortModusKinoId,
    required ValueChanged<String?> onStandortModusGeaendert,
    required bool adminStatusHaltenAktiv,
    required ValueChanged<bool> onAdminStatusHaltenGeaendert,
    required TextEditingController wgController,
    required bool wechselgeldAufgeklappt,
    required VoidCallback onToggleWechselgeldAufgeklappt,
    required int aktiveKinoIndex,
    required String aktiveKinoName,
    required ValueChanged<String> onWgChanged,
    required bool apiUploadAktiv,
    required ValueChanged<bool> onApiUploadGeaendert,
    required TextEditingController apiUploadUrlController,
    required VoidCallback onApiUploadUrlGeaendert,
    required TextEditingController locationIdController,
    required FocusNode locationIdFocusNode,
    required VoidCallback onLocationIdGeaendert,
    required TextEditingController flurbocashApiKeyController,
    required FocusNode flurbocashApiKeyFocusNode,
    required VoidCallback onFlurbocashApiKeyGeaendert,
    required bool devModusAktiv,
    required ValueChanged<bool> onDevModusGeaendert,
    required bool testwertAufgeklappt,
    required VoidCallback onToggleTestwertAufgeklappt,
    required VoidCallback onSetzeStandardTestwerte,
    required Widget autoFillInhalt,
  }) {
    return EinstellungenSectionWidgets(
      getraenkeliste: EinstellungenGetraenkelisteSection(
        kinoKuerzel: kinoKuerzel,
        aufgeklappt: getraenkelisteAufgeklappt,
        onToggleAufgeklappt: onToggleGetraenkelisteAufgeklappt,
        inhalt: getraenkelisteInhalt,
      ),
      pwaInstall: pwaInstallVerfuegbar
          ? EinstellungenPwaInstallSection(onInstall: onPwaInstall)
          : null,
      belegscan: EinstellungenBelegscanSection(
        belegScanUrlController: belegScanUrlController,
        anthropicApiKeyController: anthropicApiKeyController,
        onBelegScanUrlGeaendert: onBelegScanUrlGeaendert,
        onAnthropicApiKeyGeaendert: onAnthropicApiKeyGeaendert,
      ),
      standortAdmin: EinstellungenStandortAdminSection(
        standortModusKinoId: standortModusKinoId,
        onStandortModusGeaendert: onStandortModusGeaendert,
        adminStatusHaltenAktiv: adminStatusHaltenAktiv,
        onAdminStatusHaltenGeaendert: onAdminStatusHaltenGeaendert,
      ),
      wechselgeld: EinstellungenWechselgeldSection(
        wgController: wgController,
        aufgeklappt: wechselgeldAufgeklappt,
        onToggleAufgeklappt: onToggleWechselgeldAufgeklappt,
        aktiveKinoIndex: aktiveKinoIndex,
        aktiveKinoName: aktiveKinoName,
        onWgChanged: onWgChanged,
      ),
      flurbocash: EinstellungenFlurbocashSection(
        apiUploadAktiv: apiUploadAktiv,
        onApiUploadGeaendert: onApiUploadGeaendert,
        apiUploadUrlController: apiUploadUrlController,
        onApiUploadUrlGeaendert: onApiUploadUrlGeaendert,
        locationIdController: locationIdController,
        locationIdFocusNode: locationIdFocusNode,
        onLocationIdGeaendert: onLocationIdGeaendert,
        flurbocashApiKeyController: flurbocashApiKeyController,
        flurbocashApiKeyFocusNode: flurbocashApiKeyFocusNode,
        onFlurbocashApiKeyGeaendert: onFlurbocashApiKeyGeaendert,
      ),
      devModus: EinstellungenDevModusSection(
        devModusAktiv: devModusAktiv,
        onDevModusGeaendert: onDevModusGeaendert,
        testwertAufgeklappt: testwertAufgeklappt,
        onToggleTestwertAufgeklappt: onToggleTestwertAufgeklappt,
        onSetzeStandardTestwerte: onSetzeStandardTestwerte,
        autoFillInhalt: autoFillInhalt,
      ),
    );
  }
}

// Zweck: Buendelt die bisher ausgelagerten Section-Widgets fuer die
// Einstellungen-Seite.
class EinstellungenSectionWidgets {
  const EinstellungenSectionWidgets({
    required this.getraenkeliste,
    required this.pwaInstall,
    required this.belegscan,
    required this.standortAdmin,
    required this.wechselgeld,
    required this.flurbocash,
    required this.devModus,
  });

  final Widget getraenkeliste;
  final Widget? pwaInstall;
  final Widget belegscan;
  final Widget standortAdmin;
  final Widget wechselgeld;
  final Widget flurbocash;
  final Widget devModus;
}
