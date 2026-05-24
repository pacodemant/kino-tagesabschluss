import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/verlauf_detail_seite.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/widgets/haus_button.dart';

class VerlaufSeite extends StatefulWidget {
  const VerlaufSeite({super.key, required this.kinoId});

  static const String routenName = '/verlauf';

  final String kinoId;

  @override
  State<VerlaufSeite> createState() => _VerlaufSeiteState();
}

class _VerlaufSeiteState extends State<VerlaufSeite> {
  List<TagesabschlussFinal> _abschluesse = <TagesabschlussFinal>[];
  bool _geladen = false;

  String get _kinoName {
    final Kino? kino = KinoRepository.kinos.cast<Kino?>().firstWhere(
      (Kino? k) => k?.id == widget.kinoId,
      orElse: () => null,
    );
    return kino?.name ?? 'Verlauf';
  }

  @override
  void initState() {
    super.initState();
    _ladeAbschluesse();
  }

  Future<void> _ladeAbschluesse() async {
    final List<TagesabschlussFinal> abschluesse =
        await LokalerSpeicher.ladeFinaleTagesabschluesse(widget.kinoId);
    if (!mounted) {
      return;
    }
    setState(() {
      _abschluesse = abschluesse;
      _geladen = true;
    });
  }

  String _deutschesDatum(DateTime datum) =>
      TagesabschlussFormatierung.deutschesDatum(datum);

  String _isoDatum(DateTime datum) =>
      '${datum.year}-${datum.month.toString().padLeft(2, '0')}-'
      '${datum.day.toString().padLeft(2, '0')}';

  String _euroMitVorzeichen(int cent) =>
      TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);

  Future<void> _loescheEintrag(TagesabschlussFinal eintrag) async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text('Diese Kassenabrechnung wirklich löschen?'),
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
      _geladen = false;
      _abschluesse = <TagesabschlussFinal>[];
    });
    _ladeAbschluesse();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: Text(
          'Verlauf – $_kinoName',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          border: Border(top: BorderSide(color: Color(0x52FFFFFF))),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, -2),
              blurRadius: 12,
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(12, 4, 12, 4 + bottomPadding),
        child: const SizedBox(
          height: 36,
          child: Align(
            alignment: Alignment.centerLeft,
            child: HausButton(),
          ),
        ),
      ),
      body: !_geladen
          ? const Center(child: CircularProgressIndicator())
          : _abschluesse.isEmpty
              ? const Center(
                  child: Text('Noch keine Abschlüsse gespeichert.'),
                )
              : ListView.separated(
                  itemCount: _abschluesse.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext itemContext, int j) {
                    final TagesabschlussFinal eintrag = _abschluesse[j];
                    final int differenz = eintrag.differenzGesamtCent;
                    final Color farbe = differenz >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700;
                    final bool istHeute = _isoDatum(eintrag.datum) ==
                        DatumsHelper.logischesIsoDatum();
                    return ListTile(
                      title: Row(
                        children: <Widget>[
                          Text(_deutschesDatum(eintrag.datum)),
                          if (istHeute) ...<Widget>[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Heute',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _euroMitVorzeichen(differenz),
                            style: Theme.of(itemContext)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: farbe,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red.shade400,
                            onPressed: () => _loescheEintrag(eintrag),
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
                            _geladen = false;
                            _abschluesse = <TagesabschlussFinal>[];
                          });
                          _ladeAbschluesse();
                        }
                      },
                    );
                  },
                ),
    );
  }
}
