import 'dart:async';
import 'dart:js_interop';

@JS('_swUpdateReady')
external JSBoolean? get _jsSwUpdateReady;

@JS('_reloadPage')
external void _reloadPage();

Timer? _pollTimer;

void initSwUpdateWatcher(void Function() onUpdate) {
  if (_jsSwUpdateReady?.toDart == true) {
    onUpdate();
    return;
  }
  _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
    if (_jsSwUpdateReady?.toDart == true) {
      _pollTimer?.cancel();
      onUpdate();
    }
  });
}

void reloadPage() => _reloadPage();
