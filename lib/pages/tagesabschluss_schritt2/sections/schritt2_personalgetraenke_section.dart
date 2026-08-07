import 'package:flutter/material.dart';

class Schritt2PersonalgetraenkeSection extends StatelessWidget {
  const Schritt2PersonalgetraenkeSection({
    super.key,
    required this.gebont,
    required this.onChanged,
  });

  final bool gebont;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Personalgetränke gebont?'),
            Checkbox(
              value: gebont,
              onChanged: onChanged,
              activeColor: Colors.green,
              shape: const CircleBorder(),
            ),
          ],
        ),
      ),
    );
  }
}
