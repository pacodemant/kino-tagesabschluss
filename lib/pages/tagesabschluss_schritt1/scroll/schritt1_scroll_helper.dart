import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// Zweck: Kapselt Scroll-/Keyboard-/Fokus-Helfer fuer Schritt 1.
class Schritt1ScrollHelper {
  final Map<FocusNode, GlobalKey> _feldKeys = <FocusNode, GlobalKey>{};
  FocusNode? _letztesAktivesFeld;
  int _fokuswechselEnsureGeneration = 0;
  bool _ensureNachEingabeGeplant = false;
  DateTime _letztesEnsureNachEingabe = DateTime.fromMillisecondsSinceEpoch(0);
  bool _komfortablesScrollZielEinmalig = false;

  // Aktiviert fuer den naechsten Ensure-Lauf eine bequemere Zielposition.
  void markiereProgrammatischenFokuswechsel() {
    _komfortablesScrollZielEinmalig = true;
  }

  double leseKeyboardInset() {
    final ui.FlutterView view =
        WidgetsBinding.instance.platformDispatcher.views.first;
    return view.viewInsets.bottom / view.devicePixelRatio;
  }

  void beiGlobalemFokuswechsel({
    required bool mounted,
    required FocusNode? aktivesFeld,
    required bool Function() isMounted,
    required VoidCallback ensureAktivesFeldSichtbar,
  }) {
    if (!mounted) {
      return;
    }
    if (!identical(_letztesAktivesFeld, aktivesFeld)) {
      _letztesAktivesFeld = aktivesFeld;
      if (aktivesFeld != null) {
        // Entschaerft konkurrierende Scrolls waehrend Keyboard-Uebergang.
        final int ensureGeneration = ++_fokuswechselEnsureGeneration;
        Future<void>.delayed(const Duration(milliseconds: 120), () {
          if (!isMounted()) {
            return;
          }
          if (ensureGeneration != _fokuswechselEnsureGeneration) {
            return;
          }
          if (!identical(_letztesAktivesFeld, aktivesFeld) ||
              !aktivesFeld.hasFocus) {
            return;
          }
          if (leseKeyboardInset() <= 0) {
            return;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!isMounted()) {
              return;
            }
            if (ensureGeneration != _fokuswechselEnsureGeneration) {
              return;
            }
            if (!identical(_letztesAktivesFeld, aktivesFeld) ||
                !aktivesFeld.hasFocus) {
              return;
            }
            ensureAktivesFeldSichtbar();
          });
        });
      }
    }
  }

  void beiScrollAenderung({
    required bool mounted,
    required VoidCallback rebuild,
  }) {
    if (!mounted) {
      return;
    }
    rebuild();
  }

  GlobalKey holeFeldKey(FocusNode focusNode) {
    return _feldKeys.putIfAbsent(focusNode, () => GlobalKey());
  }

  Widget baueFeldMitKey({required FocusNode focusNode, required Widget child}) {
    return KeyedSubtree(key: holeFeldKey(focusNode), child: child);
  }

  void entferneFeldKey(FocusNode focusNode) {
    _feldKeys.remove(focusNode);
  }

  void ensureAktivesFeldSichtbar({
    required FocusNode? aktivesFeld,
    required ScrollController scrollController,
    required BuildContext context,
    required double keyboardInset,
    required double footerContentHoeheNormal,
    required double footerContentHoeheKeyboard,
    required double appBarHoehe,
    required double devToolsStickyHoehe,
    required bool devToolsSichtbar,
    required bool devToolsOffen,
    required List<FocusNode> umschlagBezeichnungFocusNodes,
    required List<FocusNode> umschlagBetragFocusNodes,
    required List<FocusNode> kartenzahlungFocusNodes,
  }) {
    if (aktivesFeld == null) {
      return;
    }
    final BuildContext? feldKontext = _feldKeys[aktivesFeld]?.currentContext;
    if (feldKontext == null) {
      return;
    }
    if (!scrollController.hasClients) {
      return;
    }
    final RenderObject? renderObject = feldKontext.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }
    final RenderObject? viewportObject = scrollController
        .position
        .context
        .storageContext
        .findRenderObject();
    if (viewportObject is! RenderBox) {
      return;
    }

    final Offset feldPositionImViewport = renderObject.localToGlobal(
      Offset.zero,
      ancestor: viewportObject,
    );
    final double fieldTop =
        scrollController.position.pixels + feldPositionImViewport.dy;
    final double fieldBottom = fieldTop + renderObject.size.height;

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final bool tastaturOffen = keyboardInset > 0;
    final double footerContentHoehe = tastaturOffen
        ? footerContentHoeheKeyboard
        : footerContentHoeheNormal;
    final double footerBottomInset = tastaturOffen
        ? 0
        : mediaQuery.viewPadding.bottom;
    final double footerTotalHoehe = footerContentHoehe + footerBottomInset;
    final double stickyHeaderHeight = (devToolsSichtbar && devToolsOffen)
        ? devToolsStickyHoehe
        : 0;
    final bool istUmschlagFeld =
        umschlagBezeichnungFocusNodes.contains(aktivesFeld) ||
        umschlagBetragFocusNodes.contains(aktivesFeld);
    final bool istKartenzahlungFeld = kartenzahlungFocusNodes.contains(
      aktivesFeld,
    );
    final double bottomSafety = (istUmschlagFeld || istKartenzahlungFeld)
        ? 100
        : 0;

    final double scrollOffset = scrollController.position.pixels;
    final double viewportHeight = scrollController.position.viewportDimension;
    final double visibleTop =
        scrollOffset + statusBarHeight + appBarHoehe + stickyHeaderHeight + 8;
    final double visibleBottom =
        scrollOffset -
        (keyboardInset + footerTotalHoehe + 8 + bottomSafety) +
        viewportHeight;
    final bool nutzeKomfortablesZiel = _komfortablesScrollZielEinmalig;
    _komfortablesScrollZielEinmalig = false;

    double? targetOffset;
    if (fieldTop < visibleTop) {
      targetOffset =
          fieldTop - (statusBarHeight + appBarHoehe + stickyHeaderHeight + 8);
    } else {
      if (nutzeKomfortablesZiel) {
        final double feldMitte = fieldTop + (renderObject.size.height / 2);
        // Feintuning: programmatischen Fokuswechsel etwa eine Feldhoehe hoeher platzieren.
        const double komfortOffsetNachOben = 44;
        final double zielMitte =
            visibleTop +
            ((visibleBottom - visibleTop) * 0.56) -
            komfortOffsetNachOben;
        if (feldMitte > zielMitte) {
          targetOffset = scrollOffset + (feldMitte - zielMitte);
        }
      }
      if (targetOffset == null && fieldBottom > visibleBottom) {
        targetOffset =
            fieldBottom -
            viewportHeight +
            (keyboardInset + footerTotalHoehe + 16 + bottomSafety);
      }
    }
    if (targetOffset == null) {
      return;
    }
    final double begrenzt = targetOffset.clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent,
    );
    if ((begrenzt - scrollController.position.pixels).abs() < 1) {
      return;
    }
    scrollController.animateTo(
      begrenzt,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void triggerEnsureBeiEingabe({
    required FocusNode focusNode,
    required double keyboardInset,
    required bool Function() isMounted,
    required VoidCallback ensureAktivesFeldSichtbar,
  }) {
    if (!focusNode.hasFocus || keyboardInset <= 0) {
      return;
    }
    if (_ensureNachEingabeGeplant) {
      return;
    }
    final Duration seitLetztemEnsure = DateTime.now().difference(
      _letztesEnsureNachEingabe,
    );
    if (seitLetztemEnsure < const Duration(milliseconds: 120)) {
      return;
    }
    _ensureNachEingabeGeplant = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureNachEingabeGeplant = false;
      if (!isMounted()) {
        return;
      }
      _letztesEnsureNachEingabe = DateTime.now();
      ensureAktivesFeldSichtbar();
    });
  }

  bool istDownButtonSichtbar({
    required ScrollController scrollController,
    double mindestRestDistanz = 24,
  }) {
    if (!scrollController.hasClients) {
      return false;
    }
    return scrollController.position.extentAfter > mindestRestDistanz;
  }

  void scrolleNachUnten({
    required ScrollController scrollController,
    Duration dauer = const Duration(milliseconds: 220),
    Curve kurve = Curves.easeOutCubic,
  }) {
    if (!scrollController.hasClients) {
      return;
    }
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: dauer,
      curve: kurve,
    );
  }
}
