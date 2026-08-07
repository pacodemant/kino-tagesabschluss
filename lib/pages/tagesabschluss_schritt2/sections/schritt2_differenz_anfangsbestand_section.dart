import 'package:flutter/material.dart';

class Schritt2DifferenzAnfangsbestandSection extends StatelessWidget {
  const Schritt2DifferenzAnfangsbestandSection({
    super.key,
    required this.eingabeZeile,
    required this.onVorzeichenToggle,
  });

  final Widget eingabeZeile;
  final VoidCallback onVorzeichenToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Differenz im Anfangsbestand',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(width: 120, child: eingabeZeile),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onVorzeichenToggle,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                side: BorderSide(color: Colors.grey.shade400),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              child: const Text(
                '±',
                style: TextStyle(fontSize: 22, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
