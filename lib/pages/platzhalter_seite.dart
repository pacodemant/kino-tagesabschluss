import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class PlatzhalterSeite extends StatelessWidget {
  const PlatzhalterSeite({super.key, required this.titel});

  static const String routenName = '/placeholder';

  final String titel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: Text(
          titel,
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: Center(child: Text('$titel folgt im nächsten Schritt.')),
    );
  }
}
