import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_belegscan_section.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_getraenkeliste_section.dart';
import 'package:kino_bar_app/pages/einstellungen/sections/einstellungen_pwa_install_section.dart';

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
  });

  final Widget getraenkeliste;
  final Widget? pwaInstall;
  final Widget belegscan;
}
