import 'package:flutter/material.dart';

VoidCallback baueClearAktion({
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
  FocusNode? focusNode,
}) =>
    () {
      controller.clear();
      onChanged('');
      focusNode?.requestFocus();
    };

Color clearIconFarbe(bool hatFokus) =>
    hatFokus ? Colors.white : Colors.grey.shade600;
