import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

class StartpruefungSeite extends StatefulWidget {
  const StartpruefungSeite({super.key});

  static const String routenName = '/';

  @override
  State<StartpruefungSeite> createState() => _StartpruefungSeiteState();
}

class _StartpruefungSeiteState extends State<StartpruefungSeite> {
  @override
  void initState() {
    super.initState();
    _navigiereNachGespeichertemKino();
  }

  Future<void> _navigiereNachGespeichertemKino() async {
    final String? aktivesKinoId = await LokalerSpeicher.ladeAktiveKinoId();
    if (!mounted) {
      return;
    }

    final String zielRoute = KinoRepository.nachId(aktivesKinoId ?? '') == null
        ? KinoauswahlSeite.routenName
        : StartmenueSeite.routenName;

    Navigator.of(
      context,
    ).pushReplacementNamed(zielRoute, arguments: aktivesKinoId);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
