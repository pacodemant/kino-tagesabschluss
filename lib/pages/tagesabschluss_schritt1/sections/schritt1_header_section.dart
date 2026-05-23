import 'package:flutter/material.dart';

class Schritt1HeaderSection extends StatelessWidget {
  const Schritt1HeaderSection({
    super.key,
    required this.onTap,
    required this.titel,
    required this.untertitel,
  });

  final VoidCallback onTap;
  final String titel;
  final String untertitel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              untertitel,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            Text(
              titel,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
