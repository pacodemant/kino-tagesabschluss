import 'package:flutter/material.dart';

class Schritt3InfoCard extends StatelessWidget {
  const Schritt3InfoCard({super.key, required this.zeilen});

  final List<Widget> zeilen;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: zeilen),
      ),
    );
  }
}
