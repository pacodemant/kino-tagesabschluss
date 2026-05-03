import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

class VerlaufSeite extends StatefulWidget {
  const VerlaufSeite({super.key});

  static const String routenName = '/verlauf';

  @override
  State<VerlaufSeite> createState() => _VerlaufSeiteState();
}

class _VerlaufSeiteState extends State<VerlaufSeite>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<List<TagesabschlussFinal>> _abschluesse =
      List<List<TagesabschlussFinal>>.generate(
    KinoRepository.kinos.length,
    (_) => <TagesabschlussFinal>[],
  );
  final List<bool> _geladen = List<bool>.generate(
    KinoRepository.kinos.length,
    (_) => false,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: KinoRepository.kinos.length,
      vsync: this,
    );
    _tabController.addListener(_onTabWechsel);
    _ladeAbschluesse(0);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabWechsel);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabWechsel() {
    _ladeAbschluesse(_tabController.index);
  }

  Future<void> _ladeAbschluesse(int index) async {
    if (_geladen[index]) {
      return;
    }
    final String kinoId = KinoRepository.kinos[index].id;
    final List<TagesabschlussFinal> abschluesse =
        await LokalerSpeicher.ladeFinaleTagesabschluesse(kinoId);
    if (!mounted) {
      return;
    }
    setState(() {
      _abschluesse[index] = abschluesse;
      _geladen[index] = true;
    });
  }

  String _deutschesDatum(DateTime datum) =>
      TagesabschlussFormatierung.deutschesDatum(datum);

  String _euroMitVorzeichen(int cent) =>
      TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verlauf'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: KinoRepository.kinos
              .map((Kino kino) => Tab(text: kino.name))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List<Widget>.generate(KinoRepository.kinos.length, (int i) {
          if (!_geladen[i]) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<TagesabschlussFinal> eintraege = _abschluesse[i];
          if (eintraege.isEmpty) {
            return const Center(
              child: Text('Noch keine Abschlüsse gespeichert.'),
            );
          }
          return ListView.separated(
            itemCount: eintraege.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int j) {
              final TagesabschlussFinal eintrag = eintraege[j];
              final int differenz = eintrag.differenzGesamtCent;
              final Color farbe =
                  differenz >= 0 ? Colors.green.shade700 : Colors.red.shade700;
              return ListTile(
                title: Text(_deutschesDatum(eintrag.datum)),
                trailing: Text(
                  _euroMitVorzeichen(differenz),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: farbe,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
