import 'package:flutter/material.dart';

mixin ControllerDisposeMixin {
  void disposeControllers(Iterable<TextEditingController> controllers) {
    for (final TextEditingController c in controllers) {
      c.dispose();
    }
  }

  void disposeFocusNodes(Iterable<FocusNode> nodes) {
    for (final FocusNode fn in nodes) {
      fn.dispose();
    }
  }
}
