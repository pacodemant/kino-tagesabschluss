import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/einstellungen_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';
import 'package:kino_bar_app/pages/verlauf_seite.dart';
import 'package:kino_bar_app/pages/getraenke_auffuellen_seite.dart';
import 'package:kino_bar_app/pages/wechselgeld_pruefen_seite.dart';

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

  void _oeffneWechselgeldPruefen(BuildContext context) {
    Navigator.of(context).pushNamed(
      WechselgeldPruefenSeite.routenName,
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
        centerTitle: false,
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: Text(
          kino.name,
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
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
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            bottom: -5,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/demo_people.png',
                fit: BoxFit.fitWidth,
                color: AppFarben.appBarRot,
                colorBlendMode: BlendMode.srcATop,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _oeffneTagesabschlussSchritt1(context),
                  child: const Text('Kassenabrechnung (4 Schritte)'),
                ),
                if (kino.hatWechselgeld) ...<Widget>[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _oeffneWechselgeldPruefen(context),
                    child: const Text('Wechselgeld prüfen'),
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
                    'Web App 0.9.12 · r275a4 @ GitHub:',
                    style: TextStyle(fontSize: 13, color: AppFarben.subtilerText),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Image.asset(
                    'assets/images/qr_webapp_github.png',
                    width: 100,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Positioned(
            left: -40,
            right: -40,
            bottom: 150,
            child: Transform.rotate(
              angle: 5 * math.pi / 180,
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  'Perso-Getränke nicht vergessen!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
