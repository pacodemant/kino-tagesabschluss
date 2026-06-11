import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class UeberEntwicklerSeite extends StatelessWidget {
  const UeberEntwicklerSeite({super.key});

  static const String routenName = '/ueber-entwickler';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: const Text('Über den Entwickler'),
      ),
      body: const Center(
        child: Text(
          'Platzhalter – Infos folgen noch.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
