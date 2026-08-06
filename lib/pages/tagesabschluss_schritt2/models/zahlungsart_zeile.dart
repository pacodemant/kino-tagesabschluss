import 'package:flutter/material.dart';

enum ZeilenZustand { hidden, shown, editing }

class ZahlungsartZeile {
  ZahlungsartZeile(this.name, {this.istUnbekannt = false})
      : betragController = TextEditingController(),
        betragFocusNode = FocusNode();

  String name;
  final bool istUnbekannt;
  final TextEditingController betragController;
  final FocusNode betragFocusNode;
  int? betragCentWert;
  bool nichtPlausibel = false;
  ZeilenZustand zustand = ZeilenZustand.hidden;

  void dispose() {
    betragController.dispose();
    betragFocusNode.dispose();
  }

  void reset() {
    betragController.clear();
    betragCentWert = null;
    nichtPlausibel = false;
    zustand = ZeilenZustand.hidden;
  }
}
