import 'package:flutter/widgets.dart';
import 'package:kino_bar_app/services/sw_update_service.dart';
import 'package:kino_bar_app/services/update_reload_guard.dart';

/// Prueft nur beim App-Start und beim Zurueckkehren aus dem Hintergrund
/// (AppLifecycleState.resumed) auf ein bereitstehendes Update — kein
/// Dauer-Timer mehr (Run 435, vorher alle 20s ueber initSwUpdateWatcher(),
/// siehe sw_update_service_web.dart). Der Reload selbst bleibt zusaetzlich
/// an UpdateReloadGuard.istAufSichererSeite gebunden (Run 412) und feuert
/// deshalb weiterhin nicht mitten in einer laufenden Abrechnung. Manuelles
/// Neuladen ueber den Button in den Einstellungen (reloadPage()) ist davon
/// unabhaengig und bleibt unveraendert.
class UpdateLifecycleWatcher extends WidgetsBindingObserver {
  void starten() {
    WidgetsBinding.instance.addObserver(this);
    _pruefen();
  }

  /// Wartezeit bis zur zweiten Pruefung nach dem Zurueckkehren (Run 496):
  /// web/index.html fragt version.json erst beim Sichtbarwerden ab, die
  /// Antwort kommt also nach dem ersten _pruefen() an. Ohne Nachpruefung
  /// griffe ein erkanntes Update erst beim naechsten Zurueckkehren.
  static const Duration nachpruefungNach = Duration(seconds: 5);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pruefen();
      Future<void>.delayed(nachpruefungNach, _pruefen);
    }
  }

  void _pruefen() {
    pruefeUndWendeUpdateAnFallsBereit(() {
      if (UpdateReloadGuard.istAufSichererSeite) {
        reloadPage();
      }
    });
  }
}
