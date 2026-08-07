import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/models/zahlungsart_zeile.dart';
import 'package:kino_bar_app/utils/feld_navigation_helper.dart';

// Zweck: Eigenstaendiger Helfer fuer Fokus-Reihenfolge, Feld-
// Navigation und Scroll-zu-Feld/Scroll-Pfeil-Logik in Schritt 2.
class Schritt2FokusHelper {
  const Schritt2FokusHelper();

  List<FocusNode> fokusReihenfolge({
    required FocusNode differenzAnfangsbestandFocusNode,
    required FocusNode kinoSollFocusNode,
    required FocusNode bistroSollFocusNode,
    required List<FocusNode> ausgabenLabelFocusNode,
    required List<FocusNode> ausgabenBetragFocusNode,
    required List<FocusNode> ecBelegLabelFocusNode,
    required List<FocusNode> kartenartenGesamtBetragFocusNode,
    required List<List<ZahlungsartZeile>> zahlungsartZeilen,
  }) {
    final List<FocusNode> ausgabenFokus = <FocusNode>[];
    for (int i = 0; i < ausgabenLabelFocusNode.length; i++) {
      ausgabenFokus.add(ausgabenLabelFocusNode[i]);
      if (i < ausgabenBetragFocusNode.length) {
        ausgabenFokus.add(ausgabenBetragFocusNode[i]);
      }
    }
    final List<FocusNode> ecBelegFokus = <FocusNode>[];
    for (int i = 0; i < ecBelegLabelFocusNode.length; i++) {
      ecBelegFokus.add(ecBelegLabelFocusNode[i]);
      if (i < zahlungsartZeilen.length) {
        for (final ZahlungsartZeile zeile in zahlungsartZeilen[i]) {
          if (zeile.zustand == ZeilenZustand.editing) {
            ecBelegFokus.add(zeile.betragFocusNode);
          }
        }
      }
      if (i < kartenartenGesamtBetragFocusNode.length) {
        ecBelegFokus.add(kartenartenGesamtBetragFocusNode[i]);
      }
    }
    return <FocusNode>[
      differenzAnfangsbestandFocusNode,
      kinoSollFocusNode,
      bistroSollFocusNode,
      ...ausgabenFokus,
      ...ecBelegFokus,
    ];
  }

  bool istLetztesFeld(List<FocusNode> reihenfolge, FocusNode focusNode) {
    return reihenfolge.isNotEmpty && identical(reihenfolge.last, focusNode);
  }

  FocusNode? naechstesFeld(List<FocusNode> reihenfolge, FocusNode focusNode) {
    final int index = reihenfolge.indexWhere(
      (FocusNode kandidat) => identical(kandidat, focusNode),
    );
    if (index < 0 || index >= reihenfolge.length - 1) {
      return null;
    }
    return reihenfolge[index + 1];
  }

  TextInputAction textInputActionFuer(bool istLetztesFeld) {
    return istLetztesFeld ? TextInputAction.done : TextInputAction.next;
  }

  void beiEingabeAbgeschlossen({
    required BuildContext context,
    required FocusNode? naechstesFeld,
    required void Function(FocusNode ziel) fokussiereFeld,
  }) {
    if (naechstesFeld == null) {
      FocusScope.of(context).unfocus();
      return;
    }
    fokussiereFeld(naechstesFeld);
  }

  void fokussiereFeld({
    required BuildContext context,
    required FocusNode ziel,
    required void Function(FocusNode fn) scrolleZurMitteNachFokus,
  }) {
    FocusScope.of(context).requestFocus(ziel);
    scrolleZurMitteNachFokus(ziel);
  }

  void verknuepfeFeldNavigation({
    required FocusNode fokusNode,
    required FeldNavigationHelper navHelper,
    required BuildContext context,
    required List<FocusNode> Function() reihenfolge,
    required void Function(FocusNode ziel) fokussiere,
  }) {
    fokusNode.onKeyEvent = (FocusNode node, KeyEvent event) =>
        navHelper.onKeyEventFuerFeld(
          context: context,
          event: event,
          reihenfolge: reihenfolge,
          fokussiere: fokussiere,
        );
  }

  Future<void> scrolleZurMitteNachFokus({
    required FocusNode fn,
    required bool Function() istMounted,
    required BuildContext context,
    required ScrollController scrollController,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!istMounted() || !fn.hasFocus || !context.mounted) return;
    if (MediaQuery.of(context).viewInsets.bottom <= 0) return;
    if (!scrollController.hasClients) return;
    final RenderObject? ro = fn.context?.findRenderObject();
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

  FocusNode? erstesLeeresFeld({
    required FocusNode kinoSollFocusNode,
    required TextEditingController kinoSollController,
    required FocusNode bistroSollFocusNode,
    required TextEditingController bistroSollController,
    required FocusNode differenzAnfangsbestandFocusNode,
    required TextEditingController differenzAnfangsbestandController,
    required List<FocusNode> ausgabenLabelFocusNode,
    required List<TextEditingController> ausgabenLabelController,
    required List<FocusNode> ausgabenBetragFocusNode,
    required List<TextEditingController> ausgabenBetragController,
    required List<FocusNode> ecBelegLabelFocusNode,
    required List<TextEditingController> ecBelegLabelController,
    required List<FocusNode> kartenartenGesamtBetragFocusNode,
    required List<TextEditingController> kartenartenGesamtBetragController,
    required List<List<ZahlungsartZeile>> zahlungsartZeilen,
    required List<FocusNode> fokusReihenfolge,
  }) {
    final Map<FocusNode, TextEditingController> lookup =
        <FocusNode, TextEditingController>{
          kinoSollFocusNode: kinoSollController,
          bistroSollFocusNode: bistroSollController,
          differenzAnfangsbestandFocusNode: differenzAnfangsbestandController,
          for (int i = 0; i < ausgabenLabelFocusNode.length; i++)
            ausgabenLabelFocusNode[i]: ausgabenLabelController[i],
          for (int i = 0; i < ausgabenBetragFocusNode.length; i++)
            ausgabenBetragFocusNode[i]: ausgabenBetragController[i],
          for (int i = 0; i < ecBelegLabelFocusNode.length; i++)
            ecBelegLabelFocusNode[i]: ecBelegLabelController[i],
          for (int i = 0; i < kartenartenGesamtBetragFocusNode.length; i++)
            kartenartenGesamtBetragFocusNode[i]:
                kartenartenGesamtBetragController[i],
          for (final List<ZahlungsartZeile> zeilen in zahlungsartZeilen)
            for (final ZahlungsartZeile zeile in zeilen)
              if (zeile.zustand == ZeilenZustand.editing)
                zeile.betragFocusNode: zeile.betragController,
        };
    for (final FocusNode fn in fokusReihenfolge) {
      if (lookup[fn]?.text.isEmpty ?? true) {
        return fn;
      }
    }
    return null;
  }

  void autoFokussiereNachLaden({
    required bool Function() istMounted,
    required FocusNode? Function() erstesLeeresFeld,
    required BuildContext context,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!istMounted()) {
        return;
      }
      final FocusNode? ziel = erstesLeeresFeld();
      if (ziel != null) {
        FocusScope.of(context).requestFocus(ziel);
      }
    });
  }
}
