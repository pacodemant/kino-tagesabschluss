import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/usecases/startziel_bestimmen_usecase.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';

class StartpruefungSeite extends StatefulWidget {
  const StartpruefungSeite({super.key});

  static const String routenName = '/';

  @override
  State<StartpruefungSeite> createState() => _StartpruefungSeiteState();
}

class _StartpruefungSeiteState extends State<StartpruefungSeite> {
  final StartzielBestimmenUsecase _startzielUsecase =
      const StartzielBestimmenUsecase();

  @override
  void initState() {
    super.initState();
    _navigiereNachGespeichertemKino();
  }

  Future<void> _navigiereNachGespeichertemKino() async {
    final StartzielBestimmungErgebnis ergebnis =
        await _startzielUsecase.bestimmeStartziel();
    if (!mounted) {
      return;
    }

    final String zielRoute = ergebnis.hatGueltigesKino
        ? StartmenueSeite.routenName
        : KinoauswahlSeite.routenName;

    Navigator.of(
      context,
    ).pushReplacementNamed(zielRoute, arguments: ergebnis.aktivesKinoId);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
