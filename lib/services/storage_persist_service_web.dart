import 'dart:js_interop';

import 'package:hive_ce/hive.dart';

extension type _StorageManager._(JSObject _) implements JSObject {
  external JSPromise<JSBoolean> persist();
  external JSPromise<JSBoolean> persisted();
}

extension type _Navigator._(JSObject _) implements JSObject {
  external _StorageManager? get storage;
}

@JS('navigator')
external _Navigator get _jsNavigator;

class StoragePersistService {
  static Future<void> requestIfNeeded() async {
    try {
      final _StorageManager? storage = _jsNavigator.storage;
      if (storage == null) return;

      final Box<dynamic> box = Hive.box('box_einstellungen');
      final bool alreadyGranted =
          box.get('storage_persist_granted', defaultValue: false) as bool;
      if (alreadyGranted) return;

      final bool alreadyPersisted =
          (await storage.persisted().toDart).toDart;
      if (alreadyPersisted) {
        await box.put('storage_persist_granted', true);
        return;
      }

      final bool granted = (await storage.persist().toDart).toDart;
      await box.put('storage_persist_granted', granted);
    } catch (_) {
      // navigator.storage nicht verfügbar — kein Fehler
    }
  }
}
