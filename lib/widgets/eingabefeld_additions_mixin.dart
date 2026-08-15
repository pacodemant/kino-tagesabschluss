import 'package:flutter/material.dart';

// Gemeinsame "+"-Additions-Logik für BetragCentEingabefeld und
// GanzzahlEingabefeld: hängt ein "+" an den aktuellen Text an, damit ein
// weiterer Wert addiert werden kann (z.B. beim Nachzählen weiterer
// Scheine/Münzen). Funktioniert unabhängig davon, ob die Tastatur ein
// "+"-Zeichen anbietet.
// Als Mixin statt Top-Level-Funktion (wie in eingabefeld_clear_helper.dart),
// weil der Cursor-Reset im addPostFrameCallback den mounted-Check der
// jeweiligen State-Klasse braucht.
mixin EingabefeldAdditionsMixin<T extends StatefulWidget> on State<T> {
  void fuegeAdditionHinzu({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
  }) {
    final String aktuellerText = controller.text;
    if (aktuellerText.isEmpty || aktuellerText.endsWith('+')) {
      focusNode?.requestFocus();
      return;
    }
    final bool hatteBereitsFokus = focusNode?.hasFocus ?? false;
    final String neuerText = '$aktuellerText+';
    controller.value = TextEditingValue(
      text: neuerText,
      selection: TextSelection.collapsed(offset: neuerText.length),
    );
    // War das Feld schon fokussiert, würde ein erneuter requestFocus()-Aufruf
    // die Text-Input-Verbindung neu aufbauen — das lässt auf iOS Safari die
    // virtuelle Tastatur verschwinden. Nur bei fehlendem Fokus nötig.
    if (!hatteBereitsFokus) {
      focusNode?.requestFocus();
    }
    onChanged(neuerText);
    // Fokuswechsel setzt die Selektion browserseitig teils auf "alles
    // markiert" zurück; Cursor nach dem Frame erneut ans Ende setzen,
    // damit direkt weitergetippt werden kann statt den Betrag zu ersetzen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.selection = TextSelection.collapsed(
          offset: controller.text.length,
        );
      }
    });
  }
}
