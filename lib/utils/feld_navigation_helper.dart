import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Gemeinsamer Mechanismus für "zum logisch nächsten/vorherigen Feld
/// springen" — genutzt vom Next-Button, von Tab/Shift+Tab und von
/// Pfeil-runter/-hoch. Jede Seite liefert lediglich ihre eigene
/// Feld-Reihenfolge und ihre eigene fokussiere()-Methode (die auch
/// eingeklappte Bereiche öffnet und zum Feld scrollt).
class FeldNavigationHelper {
  const FeldNavigationHelper();

  FocusNode? aktivesFeld(List<FocusNode> reihenfolge) {
    for (final FocusNode feld in reihenfolge) {
      if (feld.hasFocus) {
        return feld;
      }
    }
    return null;
  }

  FocusNode? feldNachVorne(List<FocusNode> reihenfolge, FocusNode aktuell) {
    final int index = reihenfolge.indexWhere(
      (FocusNode kandidat) => identical(kandidat, aktuell),
    );
    if (index < 0 || index >= reihenfolge.length - 1) {
      return null;
    }
    return reihenfolge[index + 1];
  }

  FocusNode? feldNachHinten(List<FocusNode> reihenfolge, FocusNode aktuell) {
    final int index = reihenfolge.indexWhere(
      (FocusNode kandidat) => identical(kandidat, aktuell),
    );
    if (index <= 0) {
      return null;
    }
    return reihenfolge[index - 1];
  }

  /// Springt zum nächsten (vorwaerts: true) oder vorherigen Feld.
  /// Ohne aktives Feld wird bei vorwaerts das erste Feld fokussiert.
  /// Gibt es kein nächstes Feld mehr, wird die Tastatur geschlossen.
  void springeZuNaechstem({
    required BuildContext context,
    required List<FocusNode> reihenfolge,
    required void Function(FocusNode ziel) fokussiere,
    required bool vorwaerts,
  }) {
    if (reihenfolge.isEmpty) {
      return;
    }
    final FocusNode? aktuell = aktivesFeld(reihenfolge);
    if (aktuell == null) {
      if (vorwaerts) {
        fokussiere(reihenfolge.first);
      }
      return;
    }
    final FocusNode? ziel = vorwaerts
        ? feldNachVorne(reihenfolge, aktuell)
        : feldNachHinten(reihenfolge, aktuell);
    if (ziel == null) {
      if (vorwaerts) {
        FocusScope.of(context).unfocus();
      }
      return;
    }
    fokussiere(ziel);
  }

  /// Bildet Tab/Shift+Tab und Pfeil-runter/-hoch auf springeZuNaechstem ab.
  /// reihenfolge wird als Funktion übergeben, damit bei dynamischen Listen
  /// (z. B. neue Ausgaben-Zeilen) immer der aktuelle Stand verwendet wird.
  KeyEventResult onKeyEventFuerFeld({
    required BuildContext context,
    required KeyEvent event,
    required List<FocusNode> Function() reihenfolge,
    required void Function(FocusNode ziel) fokussiere,
  }) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final bool istTab = event.logicalKey == LogicalKeyboardKey.tab;
    final bool istPfeilRunter = event.logicalKey == LogicalKeyboardKey.arrowDown;
    final bool istPfeilHoch = event.logicalKey == LogicalKeyboardKey.arrowUp;
    if (!istTab && !istPfeilRunter && !istPfeilHoch) {
      return KeyEventResult.ignored;
    }
    final bool shiftGedrueckt = HardwareKeyboard.instance.isShiftPressed;
    final bool vorwaerts = istPfeilRunter || (istTab && !shiftGedrueckt);
    springeZuNaechstem(
      context: context,
      reihenfolge: reihenfolge(),
      fokussiere: fokussiere,
      vorwaerts: vorwaerts,
    );
    return KeyEventResult.handled;
  }
}
