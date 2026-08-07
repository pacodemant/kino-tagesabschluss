import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

// Zweck: Rendert die Terminal-ID-Zeile eines EC-Belegs im 1-Beleg-Modus —
// entweder als reine Anzeige (Read-Modus nach erfolgreichem Scan) oder als
// editierbares Textfeld (vor dem Scan / nach manueller Korrektur).
class Schritt2EcBelegTerminalIdZeile extends StatelessWidget {
  const Schritt2EcBelegTerminalIdZeile({
    super.key,
    required this.zeigeReadModus,
    required this.label,
    required this.betragCent,
    required this.controller,
    required this.focusNode,
    required this.hintUnleserlich,
    required this.fehlermeldungText,
    required this.textInputActionErmitteln,
    required this.beiEingabeAbgeschlossen,
    required this.onChanged,
    required this.onLoeschen,
  });

  final bool zeigeReadModus;
  final String label;
  final int betragCent;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hintUnleserlich;
  final String? fehlermeldungText;
  final TextInputAction Function(FocusNode focusNode) textInputActionErmitteln;
  final void Function(FocusNode focusNode) beiEingabeAbgeschlossen;
  final ValueChanged<String> onChanged;
  final VoidCallback onLoeschen;

  @override
  Widget build(BuildContext context) {
    if (zeigeReadModus) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label.isNotEmpty ? 'Terminal: $label' : '—',
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(width: 8),
            if (betragCent > 0)
              Text(
                TagesabschlussFormatierung.formatiereEuro(betragCent),
                style: const TextStyle(fontSize: 15),
              ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(
          fontSize: 15,
          color: focusNode.hasFocus ? Colors.black : null,
        ),
        cursorColor: focusNode.hasFocus ? Colors.black : null,
        textInputAction: textInputActionErmitteln(focusNode),
        decoration: InputDecoration(
          hintText: hintUnleserlich ? 'Terminal-ID?' : 'Terminal-ID',
          hintStyle: TextStyle(
            fontSize: 15,
            color: focusNode.hasFocus
                ? Colors.transparent
                : (hintUnleserlich ? Colors.red : null),
          ),
          errorText: fehlermeldungText,
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: AppFarben.appBarRot),
          ),
          isDense: true,
          filled: focusNode.hasFocus,
          fillColor: focusNode.hasFocus ? AppFarben.fokusFarbe : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
            maxWidth: 32,
            maxHeight: 32,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: focusNode.hasFocus ? Colors.black : null,
                  ),
                  onPressed: onLoeschen,
                ),
        ),
        onSubmitted: (_) => beiEingabeAbgeschlossen(focusNode),
        onChanged: onChanged,
      ),
    );
  }
}
