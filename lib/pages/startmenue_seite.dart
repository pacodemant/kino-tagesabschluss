import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/einstellungen_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';
import 'package:kino_bar_app/pages/verlauf_seite.dart';
import 'package:kino_bar_app/pages/getraenke_auffuellen_seite.dart';
import 'package:kino_bar_app/pages/wechselgeld_zaehlen_seite.dart';

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

  void _oeffneEinstellungen(BuildContext context) {
    Navigator.of(context).pushNamed(EinstellungenSeite.routenName);
  }

  void _oeffneVerlauf(BuildContext context) {
    Navigator.of(context).pushNamed(VerlaufSeite.routenName, arguments: kino.id);
  }

  void _oeffneWechselgeldZaehlen(BuildContext context) {
    Navigator.of(context).pushNamed(
      WechselgeldZaehlenSeite.routenName,
      arguments: kino.id,
    );
  }

  void _oeffneGetraenkeAuffuellen(BuildContext context) {
    Navigator.of(context).pushNamed(
      GetraenkeAuffuellenSeite.routenName,
      arguments: kino.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: Text(kino.name),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(KinoauswahlSeite.routenName);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
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
              child: const Text('Tagesabrechnung'),
            ),
            if (kino.hatWechselgeld) ...<Widget>[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _oeffneWechselgeldZaehlen(context),
                child: const Text('Wechselgeld zählen'),
              ),
            ],
            if (kino.hatGetraenke) ...<Widget>[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _oeffneGetraenkeAuffuellen(context),
                child: const Text('Getränke auffüllen'),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _oeffneEinstellungen(context),
              child: const Text('Einstellungen'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _oeffneVerlauf(context),
              child: const Text('Verlauf'),
            ),
            const Spacer(),
            const Center(
              child: Text(
                'Web App @ GitHub:',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Image.asset(
                'assets/images/qr_webapp_github.png',
                width: 180,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
