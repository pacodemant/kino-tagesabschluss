import 'dart:js_interop';

import 'package:flutter/material.dart';
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
  static Future<void> requestIfNeeded(BuildContext context) async {
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

      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          content: const Text(
            'Damit deine Einstellungen und angefangene Abrechnungen auch nach '
            'mehreren Tagen noch da sind, bitte einmal bestätigen.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      final bool granted = (await storage.persist().toDart).toDart;
      await box.put('storage_persist_granted', granted);
    } catch (_) {
      // navigator.storage nicht verfügbar — kein Fehler
    }
  }
}
