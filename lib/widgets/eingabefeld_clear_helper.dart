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
    hatFokus ? Colors.black : Colors.grey.shade600;

// Trennlinie zwischen Wert und Aktions-Buttons (+/X), damit diese optisch
// als eigener Bereich erkennbar sind statt lose Icons zu sein.
Widget baueEingabefeldTrennlinie() => Container(
  width: 1,
  height: 18,
  margin: const EdgeInsets.symmetric(horizontal: 4),
  color: Colors.grey.shade400,
);

// Button-Chip (Hintergrund + Rundung) für "+"/"X" im Eingabefeld — größere,
// klar als Button erkennbare Tippfläche statt bloßem Icon. Die eigentliche
// Tippfläche (HitTestBehavior.opaque + Padding) ist bewusst größer als der
// sichtbare Chip, sonst trifft man ihn mit dem Finger leicht daneben.
Widget baueEingabefeldAktionsChip({
  required IconData icon,
  required VoidCallback onTap,
  required bool hatFokus,
}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: clearIconFarbe(hatFokus)),
      ),
    ),
  );
}
