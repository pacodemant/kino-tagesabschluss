import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/verlauf_detail_seite.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

class VerlaufSeite extends StatefulWidget {
  const VerlaufSeite({super.key, this.initialKinoId});

  static const String routenName = '/verlauf';

  final String? initialKinoId;

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
    final int initialIndex = widget.initialKinoId == null
        ? 0
        : KinoRepository.kinos.indexWhere(
            (Kino k) => k.id == widget.initialKinoId,
          ).clamp(0, KinoRepository.kinos.length - 1);
    _tabController = TabController(
      length: KinoRepository.kinos.length,
      initialIndex: initialIndex,
      vsync: this,
    );
    _tabController.addListener(_onTabWechsel);
    _ladeAbschluesse(initialIndex);
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

  Future<void> _loescheEintrag(
    int tabIndex,
    TagesabschlussFinal eintrag,
  ) async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text('Diesen Tagesabschluss wirklich löschen?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (bestaetigt != true || !mounted) {
      return;
    }
    await LokalerSpeicher.loescheFinalenTagesabschluss(
      eintrag.kinoId,
      eintrag.datum,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _geladen[tabIndex] = false;
      _abschluesse[tabIndex] = <TagesabschlussFinal>[];
    });
    _ladeAbschluesse(tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
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
            itemBuilder: (BuildContext itemContext, int j) {
              final TagesabschlussFinal eintrag = eintraege[j];
              final int differenz = eintrag.differenzGesamtCent;
              final Color farbe =
                  differenz >= 0 ? Colors.green.shade700 : Colors.red.shade700;
              return ListTile(
                title: Text(_deutschesDatum(eintrag.datum)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _euroMitVorzeichen(differenz),
                      style: Theme.of(itemContext).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: farbe,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade400,
                      onPressed: () => _loescheEintrag(i, eintrag),
                    ),
                  ],
                ),
                onTap: () async {
                  final NavigatorState navigator = Navigator.of(context);
                  final bool? geloescht =
                      await navigator.pushNamed<bool>(
                    VerlaufDetailSeite.routenName,
                    arguments: eintrag,
                  );
                  if (geloescht == true && mounted) {
                    setState(() {
                      _geladen[i] = false;
                      _abschluesse[i] = <TagesabschlussFinal>[];
                    });
                    _ladeAbschluesse(i);
                  }
                },
              );
            },
          );
        }),
      ),
    );
  }
}
