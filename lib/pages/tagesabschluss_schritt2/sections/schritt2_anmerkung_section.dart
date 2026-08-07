import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class Schritt2AnmerkungSection extends StatelessWidget {
  const Schritt2AnmerkungSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Hinweis / Kommentar (optional)',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: focusNode.hasFocus ? Colors.black : null,
              style: TextStyle(color: focusNode.hasFocus ? Colors.black : null),
              decoration: InputDecoration(
                hintText: 'Anmerkungen',
                isDense: true,
                filled: focusNode.hasFocus,
                fillColor: focusNode.hasFocus ? AppFarben.fokusFarbe : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
