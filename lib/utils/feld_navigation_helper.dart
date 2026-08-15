import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  bool istLetztesFeld(List<FocusNode> reihenfolge, FocusNode focusNode) {
    return reihenfolge.isNotEmpty && identical(reihenfolge.last, focusNode);
  }

  TextInputAction textInputActionFuer(bool istLetztesFeld) {
    return istLetztesFeld ? TextInputAction.done : TextInputAction.next;
  }

  /// Scrollt nach einer Fokusänderung so, dass das Feld nicht von der
  /// virtuellen Tastatur verdeckt wird. findRenderObject liefert das
  /// RenderObject des fokussierten Feldes — je nach Seite entweder über
  /// FocusNode.context oder über einen seiteneigenen GlobalKey.
  Future<void> scrolleZurMitteNachFokus({
    required FocusNode fn,
    required bool Function() istMounted,
    required BuildContext context,
    required ScrollController scrollController,
    required RenderObject? Function(FocusNode fokusNode) findRenderObject,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!istMounted() || !fn.hasFocus || !context.mounted) return;
    if (MediaQuery.of(context).viewInsets.bottom <= 0) return;
    if (!scrollController.hasClients) return;
    final RenderObject? ro = findRenderObject(fn);
    if (ro == null || !ro.attached) return;
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(
      ro,
    );
    if (viewport == null) return;
    final double revealOffset = viewport.getOffsetToReveal(ro, 0.0).offset;
    final double targetOffset =
        (revealOffset - scrollController.position.viewportDimension * 0.3)
            .clamp(0.0, scrollController.position.maxScrollExtent);
    await scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
