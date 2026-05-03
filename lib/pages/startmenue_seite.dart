import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/platzhalter_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';
import 'package:kino_bar_app/pages/verlauf_seite.dart';

class StartmenueSeite extends StatelessWidget {
  const StartmenueSeite({super.key, required this.kino});

  static const String routenName = '/start-menu';

  final Kino kino;

  void _oeffneTagesabschlussSchritt1(BuildContext context) {
    Navigator.of(context).pushNamed(
      TagesabschlussSchritt1Seite.routenName,
      arguments: TagesabschlussSchritt1Argumente(
        kinoId: kino.id,
        kinoName: kino.name,
      ),
    );
  }

  void _oeffnePlatzhalter(BuildContext context, String titel) {
    Navigator.of(context).pushNamed(PlatzhalterSeite.routenName, arguments: titel);
  }

  void _oeffneVerlauf(BuildContext context) {
    Navigator.of(context).pushNamed(VerlaufSeite.routenName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(kino.name),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(KinoauswahlSeite.routenName);
            },
            child: const Text('Kino wechseln'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _oeffneTagesabschlussSchritt1(context),
              child: const Text('Tagesabschluss'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _oeffnePlatzhalter(context, 'Getränke auffüllen'),
              child: const Text('Getränke auffüllen'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _oeffnePlatzhalter(context, 'Einstellungen'),
              child: const Text('Einstellungen'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _oeffneVerlauf(context),
              child: const Text('Verlauf'),
            ),
          ],
        ),
      ),
    );
  }
}
