import 'package:flutter/material.dart';

// Zweck: Seitenweiter Scroll-Helfer fuer Schritt 2 (Down-Button),
// analog zu schritt1_scroll_helper.dart.
class Schritt2ScrollHelper {
  const Schritt2ScrollHelper();

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
