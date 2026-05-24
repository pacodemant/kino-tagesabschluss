import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/usecases/kino_waehlen_usecase.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
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
          'Schauburg Kassenabrechnung',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: Padding(
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
                child: Text(kino.name),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
