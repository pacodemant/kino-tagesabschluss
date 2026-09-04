import 'package:flutter/material.dart';

/// Eine Zeile im Abschnitt "Ausgaben" (Schritt 2) — bündelt Betrag, Label
/// und die zugehörigen Controller/FocusNodes in einem Objekt statt in
/// parallelen Listen (Run 429, ersetzt _ausgabenBetragController/
/// _ausgabenLabelController/_ausgabenBetragFocusNode/
/// _ausgabenLabelFocusNode/_ausgabenBetrageCent/_ausgabenLabels/
/// _ausgabenIds).
class AusgabenZeile {
  AusgabenZeile({required this.id})
      : labelController = TextEditingController(),
        labelFocusNode = FocusNode(),
        betragController = TextEditingController(),
        betragFocusNode = FocusNode();

  final int id;
  String label = '';
  int betragCent = 0;
  final TextEditingController labelController;
  final FocusNode labelFocusNode;
  final TextEditingController betragController;
  final FocusNode betragFocusNode;

  void dispose() {
    labelController.dispose();
    labelFocusNode.dispose();
    betragController.dispose();
    betragFocusNode.dispose();
  }
}
