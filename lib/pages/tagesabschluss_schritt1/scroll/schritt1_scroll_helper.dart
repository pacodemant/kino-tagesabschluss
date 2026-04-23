import 'package:flutter/material.dart';

// Zweck: Kapselt Scroll-/Keyboard-/Fokus-Helfer fuer Schritt 1.
class Schritt1ScrollHelper {
  final Map<FocusNode, GlobalKey> _feldKeys = <FocusNode, GlobalKey>{};

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
