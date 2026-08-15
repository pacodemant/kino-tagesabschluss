import 'package:flutter/material.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';

class HelpButton extends StatelessWidget {
  const HelpButton({super.key, required this.helpText});

  final String helpText;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline, color: Colors.white),
      iconSize: 22,
      tooltip: 'Hilfe',
      onPressed: () => zeigeInfoDialog(
        context,
        titel: 'Hilfe',
        inhalt: Text(helpText),
        buttonText: 'OK',
      ),
    );
  }
}
