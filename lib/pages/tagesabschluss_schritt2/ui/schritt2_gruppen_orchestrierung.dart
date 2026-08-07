import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_anmerkung_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_differenz_anfangsbestand_section.dart';
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
    required this.anmerkung,
  });

  final Widget kopf;
  final Widget personalgetraenke;
  final Widget differenzAnfangsbestand;
  final Widget anmerkung;
}
