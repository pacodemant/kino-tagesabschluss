import 'dart:js_interop';

extension type _BeforeInstallPromptEvent._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> prompt();
}

@JS('_pwaInstallEvent')
external _BeforeInstallPromptEvent? get _jsPwaInstallEvent;

bool get pwaInstallVerfuegbar => _jsPwaInstallEvent != null;

Future<void> pwaInstallStarten() async {
  final _BeforeInstallPromptEvent? event = _jsPwaInstallEvent;
  if (event == null) return;
  await event.prompt().toDart;
}
