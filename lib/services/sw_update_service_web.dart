import 'dart:async';
import 'dart:js_interop';

@JS('_swUpdateReady')
external JSBoolean? get _jsSwUpdateReady;

@JS('_reloadPage')
external void _reloadPage();

Timer? _pollTimer;

// onUpdate liefert true, wenn der Reload tatsächlich ausgeführt wurde —
// erst dann hört der Poll auf. Liefert es false (z. B. weil gerade eine
// Tagesabschluss-Seite offen ist), wird beim nächsten Tick erneut gefragt.
void initSwUpdateWatcher(bool Function() onUpdate) {
  _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
    if (_jsSwUpdateReady?.toDart == true) {
      if (onUpdate()) {
        _pollTimer?.cancel();
      }
    }
  });
}

void reloadPage() => _reloadPage();
