import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Zeile mit Beschriftung, optionalem Fragezeichen-Icon (Hilfe) und einem
/// kompakten Ein/Aus-Schalter. Der Standard-Schalter von Material 3 ist
/// mit ca. 52 × 32 px sehr groß (siehe Einstellungen) — hier wird er per
/// FittedBox verkleinert, damit er in der Abrechnung nicht dominiert.
/// Bewusst zentral, damit alle Schalter in den Abrechnungs-Seiten gleich
/// aussehen.
class KompakterSchalterZeile extends StatelessWidget {
  const KompakterSchalterZeile({
    super.key,
    required this.label,
    required this.wert,
    required this.onChanged,
    this.onHilfe,
  });

  final String label;
  final bool wert;
  final ValueChanged<bool> onChanged;

  /// Wenn gesetzt, erscheint hinter der Beschriftung ein Fragezeichen-Icon.
  final VoidCallback? onHilfe;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!wert),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (onHilfe != null)
              IconButton(
                icon: const Icon(Icons.help_outline),
                color: AppFarben.appBarRot,
                iconSize: 20,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                constraints: const BoxConstraints(),
                onPressed: onHilfe,
              ),
            SizedBox(
              width: 42,
              height: 26,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Switch(
                  value: wert,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
