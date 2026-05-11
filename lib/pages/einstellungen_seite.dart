import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';

class EinstellungenSeite extends StatefulWidget {
  const EinstellungenSeite({super.key});

  static const String routenName = '/einstellungen';

  @override
  State<EinstellungenSeite> createState() => _EinstellungenSeiteState();
}

class _EinstellungenSeiteState extends State<EinstellungenSeite> {
  late final List<TextEditingController> _controllers;
  bool _geladen = false;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      KinoRepository.kinos.length,
      (_) => TextEditingController(),
    );
    _ladeWerte();
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _ladeWerte() async {
    for (int i = 0; i < KinoRepository.kinos.length; i++) {
      final int cent = await LokalerSpeicher.ladeWechselgeldSollwertCent(
        KinoRepository.kinos[i].id,
      );
      if (!mounted) {
        return;
      }
      _controllers[i].text =
          TagesabschlussFormatierung.formatiereEuroEingabe(cent);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _geladen = true;
    });
  }

  void _onChanged(int index, String text) {
    final String kinoId = KinoRepository.kinos[index].id;
    final int cent =
        int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    LokalerSpeicher.speichereWechselgeldSollwertCent(kinoId, cent);
  }

  @override
  Widget build(BuildContext context) {
    if (!_geladen) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: const Text('Einstellungen'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: KinoRepository.kinos.length,
        itemBuilder: (BuildContext ctx, int i) {
          final Kino kino = KinoRepository.kinos[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      kino.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BetragCentEingabefeld(
                      textController: _controllers[i],
                      onChanged: (String text) => _onChanged(i, text),
                      schriftgroesse: 18,
                      hinweisText: '200,00 €',
                      labelText: 'Wechselgeld-Sollwert',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
