import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/verlauf_detail_seite.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/widgets/heute_badge.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';
import 'package:kino_bar_app/widgets/nicht_gesendet_badge.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

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

  String _euroMitVorzeichen(int cent) =>
      TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);

  Future<void> _loescheEintrag(TagesabschlussFinal eintrag) async {
    final bool? bestaetigt = await zeigeLoeschenDialog(context);
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
    return TagesabschlussScaffold(
      title: 'Verlauf – $_kinoName',
      child: !_geladen
          ? const Center(child: CircularProgressIndicator())
          : _abschluesse.isEmpty
              ? const Center(
                  child: Text('Noch keine Abschlüsse gespeichert.'),
                )
              : ListView.separated(
                  itemCount: _abschluesse.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (BuildContext itemContext, int j) {
                    final TagesabschlussFinal eintrag = _abschluesse[j];
                    final int differenz = eintrag.differenzGesamtCent;
                    final Color farbe = differenz >= 0
                        ? AppFarben.differenzPositiv
                        : AppFarben.differenzNegativ;
                    final bool istHeute = DatumsHelper.isoDatum(eintrag.datum) ==
                        DatumsHelper.logischesIsoDatum();
                    return ListTile(
                      subtitle: (eintrag.mitarbeiterName != null &&
                              eintrag.mitarbeiterName!.isNotEmpty)
                          ? Text(
                              eintrag.mitarbeiterName!,
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                      title: Row(
                        children: <Widget>[
                          Text(_deutschesDatum(eintrag.datum)),
                          if (istHeute) ...<Widget>[
                            const SizedBox(width: 8),
                            const HeuteBadge(),
                          ],
                          if (eintrag.gesendetAm == null) ...<Widget>[
                            const SizedBox(width: 8),
                            const NichtGesendetBadge(),
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
                        await navigator.pushNamed<bool>(
                          VerlaufDetailSeite.routenName,
                          arguments: eintrag,
                        );
                        // Immer neu laden, nicht nur bei Löschung: der
                        // Sende-Status kann sich in der Detailseite
                        // geändert haben ("Erneut senden"), ohne dass
                        // das über den Rückgabewert signalisiert wird.
                        if (mounted) {
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
