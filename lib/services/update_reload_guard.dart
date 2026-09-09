import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';

/// Verfolgt rein lesend die aktuell sichtbare Route, damit
/// UpdateLifecycleWatcher (update_lifecycle_watcher.dart) vor einem
/// automatischen Reload prüfen kann, ob gerade Kinoauswahl/Startmenü
/// sichtbar ist (kein eigener Auslöser — nur eine Bedingung für den bei
/// App-Start/Resume ausgelösten Update-Check, siehe TODO.md
/// "Update-Reload nicht mitten in der Abrechnung").
class UpdateReloadGuard extends NavigatorObserver {
  static String? _aktuelleRoute;

  static bool get istAufSichererSeite =>
      _aktuelleRoute == KinoauswahlSeite.routenName ||
      _aktuelleRoute == StartmenueSeite.routenName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _aktuelleRoute = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _aktuelleRoute = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _aktuelleRoute = newRoute?.settings.name;
  }
}
