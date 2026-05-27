import 'package:flutter/material.dart';

class HelpButton extends StatelessWidget {
  const HelpButton({super.key, required this.helpText});

  final String helpText;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline, color: Colors.white),
      iconSize: 22,
      tooltip: 'Hilfe',
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
            title: const Text('Hilfe'),
            content: Text(helpText),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}
