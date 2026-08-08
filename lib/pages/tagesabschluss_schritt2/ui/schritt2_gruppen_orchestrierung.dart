import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_anmerkung_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_differenz_anfangsbestand_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_ec_beleg_sub_kacheln.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/sections/schritt2_ec_belege_kachel_section.dart';
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
    required int gesamtUmsatzCent,
    required int gesamtNachAusgabenCent,
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
        gesamtUmsatzCent: gesamtUmsatzCent,
        gesamtNachAusgabenCent: gesamtNachAusgabenCent,
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

  Widget baueEcBelegeKachel({
    required bool aufgeklappt,
    required VoidCallback onToggleAufgeklappt,
    required bool zeigeManuellEingebenLink,
    required VoidCallback onManuellEingebenTap,
    required bool scanLaeuft,
    required bool hatEcBelege,
    required int belegeWithData,
    required int ecGesamtCent,
    required VoidCallback onScanStarten,
    required VoidCallback onKartenDatenLoeschen,
    required TapGestureRecognizer belegdatenBearbeitenRecognizer,
    required VoidCallback onBelegdatenBearbeitenTap,
    required VoidCallback onEcBelegHinzufuegen,
    required Widget belegInhalt,
  }) {
    return Schritt2EcBelegeKachelSection(
      aufgeklappt: aufgeklappt,
      onToggleAufgeklappt: onToggleAufgeklappt,
      zeigeManuellEingebenLink: zeigeManuellEingebenLink,
      onManuellEingebenTap: onManuellEingebenTap,
      scanLaeuft: scanLaeuft,
      hatEcBelege: hatEcBelege,
      belegeWithData: belegeWithData,
      ecGesamtCent: ecGesamtCent,
      onScanStarten: onScanStarten,
      onKartenDatenLoeschen: onKartenDatenLoeschen,
      belegdatenBearbeitenRecognizer: belegdatenBearbeitenRecognizer,
      onBelegdatenBearbeitenTap: onBelegdatenBearbeitenTap,
      onEcBelegHinzufuegen: onEcBelegHinzufuegen,
      belegInhalt: belegInhalt,
    );
  }

  Widget baueEcBelegSubKacheln({
    required int belegAnzahl,
    required List<int> belegIds,
    required List<bool> aufgeklapptListe,
    required void Function(int belegIndex) onToggleAufgeklappt,
    required List<bool> editModusListe,
    required int? scanBelegIndex,
    required List<TextEditingController> labelController,
    required List<FocusNode> labelFocusNode,
    required List<String> labels,
    required List<int> betraegeCent,
    required bool Function(int belegIndex) tidUnleserlich,
    required bool scanLaeuft,
    required void Function(int belegIndex) onScanStarten,
    required void Function(int belegIndex, String wert) onTidGeaendert,
    required void Function(int belegIndex) onBestaetigtEntfernen,
    required bool Function(int belegIndex) hatZahlungsartZeilen,
    required bool Function(int belegIndex) hatScanStattgefunden,
    required Widget Function(int belegIndex) baueZahlungsartenTabelle,
    required Widget Function(int belegIndex) baueMetadatenBlock,
    required void Function(int belegIndex) onManuellBearbeitenAktivieren,
    required void Function(int belegIndex) onFertig,
  }) {
    return Schritt2EcBelegSubKacheln(
      belegAnzahl: belegAnzahl,
      belegIds: belegIds,
      aufgeklapptListe: aufgeklapptListe,
      onToggleAufgeklappt: onToggleAufgeklappt,
      editModusListe: editModusListe,
      scanBelegIndex: scanBelegIndex,
      labelController: labelController,
      labelFocusNode: labelFocusNode,
      labels: labels,
      betraegeCent: betraegeCent,
      tidUnleserlich: tidUnleserlich,
      scanLaeuft: scanLaeuft,
      onScanStarten: onScanStarten,
      onTidGeaendert: onTidGeaendert,
      onBestaetigtEntfernen: onBestaetigtEntfernen,
      hatZahlungsartZeilen: hatZahlungsartZeilen,
      hatScanStattgefunden: hatScanStattgefunden,
      baueZahlungsartenTabelle: baueZahlungsartenTabelle,
      baueMetadatenBlock: baueMetadatenBlock,
      onManuellBearbeitenAktivieren: onManuellBearbeitenAktivieren,
      onFertig: onFertig,
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
