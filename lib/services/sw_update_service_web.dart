import 'dart:js_interop';

@JS('_swUpdateReady')
external JSBoolean? get _jsSwUpdateReady;

@JS('_reloadPage')
external void _reloadPage();

/// Prueft EINMALIG, ob laut JS-Seite (web/index.html, _checkForUpdate(),
/// dort bereits auf max. 1x/Tag gedrosselt und nur beim Laden/Wieder-
/// sichtbarwerden ausgeloest) ein Update bereitsteht, und ruft dann
/// [onUpdate] auf. Kein Dauer-Timer mehr (Run 435 — vorher 20s-Polling,
/// konnte dadurch auch spaetabends mitten in einer laufenden Abrechnung
/// auf dem Startmenue zuschlagen, sobald irgendwann tagsueber ein Update
/// erkannt wurde). Aufrufer ist dafuer verantwortlich, diese Funktion bei
/// den gewuenschten Gelegenheiten erneut aufzurufen (App-Start, Resume aus
/// dem Hintergrund) — siehe update_lifecycle_watcher.dart.
void pruefeUndWendeUpdateAnFallsBereit(void Function() onUpdate) {
  if (_jsSwUpdateReady?.toDart == true) {
    onUpdate();
  }
}

void reloadPage() => _reloadPage();
