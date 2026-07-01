import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/usecases/kino_waehlen_usecase.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/pages/datenschutz_seite.dart';
import 'package:kino_bar_app/pages/ueber_entwickler_seite.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class KinoauswahlSeite extends StatefulWidget {
  const KinoauswahlSeite({super.key});

  static const String routenName = '/cinema-selection';

  @override
  State<KinoauswahlSeite> createState() => _KinoauswahlSeiteState();
}

class _KinoauswahlSeiteState extends State<KinoauswahlSeite> {
  final KinoWaehlenUsecase _kinoWaehlenUsecase = const KinoWaehlenUsecase();

  Future<void> _waehleKino(String kinoId) async {
    await _kinoWaehlenUsecase.speichereAktivesKino(kinoId);
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushReplacementNamed(StartmenueSeite.routenName, arguments: kinoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: const Text(
          'Kassenabrechnung',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 17),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Web App 0.9.2 · r302d @ GitHub:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppFarben.subtilerText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Image.asset(
                    'assets/images/qr_webapp_github.png',
                    width: 100,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed(UeberEntwicklerSeite.routenName),
                    child: Image.asset(
                      'assets/images/logo_apprev.png',
                      width: 90,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Kino auswählen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            for (final Kino kino in KinoRepository.kinos) ...<Widget>[
              ElevatedButton(
                onPressed: () => _waehleKino(kino.id),
                child: Text('${kino.name} (${kino.kuerzel})'),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            Center(
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(DatenschutzSeite.routenName),
                child: const Text(
                  'Datenschutzhinweise',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppFarben.subtilerText,
                    decoration: TextDecoration.underline,
                    decorationColor: AppFarben.subtilerText,
                  ),
                ),
              ),
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}
