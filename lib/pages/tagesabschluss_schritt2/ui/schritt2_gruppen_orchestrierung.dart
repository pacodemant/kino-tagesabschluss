import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_anmerkung_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_differenz_anfangsbestand_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_kino_soll_ausgaben_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_kopf_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_personalgetraenke_section.dart';

// Zweck: Kapselt den Gruppen-/Wrapper-Aufbau fuer Schritt 2, analog zu
// schritt1_gruppen_orchestrierung.dart. Wird in den naechsten Sub-Runs
// der build()-Zerlegungs-Serie um weitere Sections ergaenzt.
class Schritt2GruppenOrchestrierung {
  const Schritt2GruppenOrchestrierung();

  Schritt2SectionWidgets baueSections({
    required String kinoName,
    required String kopfDatumUhrzeit,
    required bool personalgetraenkeGebot,
    required ValueChanged<bool?> beiPersonalgetraenkeGeaendert,
    required Widget differenzAnfangsbestandEingabeZeile,
    required VoidCallback vorzeichenToggleDifferenz,
    required TextEditingController anmerkungController,
    required FocusNode anmerkungFocusNode,
    required ValueChanged<String> beiAnmerkungGeaendert,
    required Widget kinoSollEingabeZeile,
    required Widget? bistroSollEingabeZeile,
    required List<int> ausgabenIds,
    required List<TextEditingController> ausgabenLabelController,
    required List<FocusNode> ausgabenLabelFocusNode,
    required List<TextEditingController> ausgabenBetragController,
    required List<FocusNode> ausgabenBetragFocusNode,
    required TextInputAction Function(FocusNode focusNode)
    textInputActionFuerSchritt2,
    required void Function(FocusNode focusNode) beiEingabeAbgeschlossen,
    required void Function(int index, String wert) onAusgabenLabelGeaendert,
    required void Function(int index) onAusgabenLabelGeloescht,
    required void Function(int index, String wert) onAusgabenBetragGeaendert,
    required void Function(int index) onAusgabeEntfernen,
    required VoidCallback onAusgabeHinzufuegen,
  }) {
    return Schritt2SectionWidgets(
      kopf: Schritt2KopfSection(
        kinoName: kinoName,
        datumUhrzeit: kopfDatumUhrzeit,
      ),
      personalgetraenke: Schritt2PersonalgetraenkeSection(
        gebont: personalgetraenkeGebot,
        onChanged: beiPersonalgetraenkeGeaendert,
      ),
      differenzAnfangsbestand: Schritt2DifferenzAnfangsbestandSection(
        eingabeZeile: differenzAnfangsbestandEingabeZeile,
        onVorzeichenToggle: vorzeichenToggleDifferenz,
      ),
      kinoSollUndAusgaben: Schritt2KinoSollUndAusgabenSection(
        kinoSollEingabeZeile: kinoSollEingabeZeile,
        bistroSollEingabeZeile: bistroSollEingabeZeile,
        ausgabenIds: ausgabenIds,
        ausgabenLabelController: ausgabenLabelController,
        ausgabenLabelFocusNode: ausgabenLabelFocusNode,
        ausgabenBetragController: ausgabenBetragController,
        ausgabenBetragFocusNode: ausgabenBetragFocusNode,
        textInputActionFuerSchritt2: textInputActionFuerSchritt2,
        beiEingabeAbgeschlossen: beiEingabeAbgeschlossen,
        onAusgabenLabelGeaendert: onAusgabenLabelGeaendert,
        onAusgabenLabelGeloescht: onAusgabenLabelGeloescht,
        onAusgabenBetragGeaendert: onAusgabenBetragGeaendert,
        onAusgabeEntfernen: onAusgabeEntfernen,
        onAusgabeHinzufuegen: onAusgabeHinzufuegen,
      ),
      anmerkung: Schritt2AnmerkungSection(
        controller: anmerkungController,
        focusNode: anmerkungFocusNode,
        onChanged: beiAnmerkungGeaendert,
      ),
    );
  }
}

// Zweck: Buendelt die bisher ausgelagerten Section-Widgets fuer Schritt 2.
class Schritt2SectionWidgets {
  const Schritt2SectionWidgets({
    required this.kopf,
    required this.personalgetraenke,
    required this.differenzAnfangsbestand,
    required this.kinoSollUndAusgaben,
    required this.anmerkung,
  });

  final Widget kopf;
  final Widget personalgetraenke;
  final Widget differenzAnfangsbestand;
  final Widget kinoSollUndAusgaben;
  final Widget anmerkung;
}
