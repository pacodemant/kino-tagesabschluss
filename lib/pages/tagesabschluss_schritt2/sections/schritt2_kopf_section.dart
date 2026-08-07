import 'package:flutter/material.dart';

class Schritt2KopfSection extends StatelessWidget {
  const Schritt2KopfSection({
    super.key,
    required this.kinoName,
    required this.datumUhrzeit,
  });

  final String kinoName;
  final String datumUhrzeit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Kassenabrechnung $kinoName',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(datumUhrzeit, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
