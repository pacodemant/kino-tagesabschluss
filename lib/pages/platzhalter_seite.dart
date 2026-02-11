import 'package:flutter/material.dart';

class PlatzhalterSeite extends StatelessWidget {
  const PlatzhalterSeite({super.key, required this.titel});

  static const String routenName = '/placeholder';

  final String titel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(titel),
      ),
      body: Center(child: Text('$titel folgt im nächsten Schritt.')),
    );
  }
}
