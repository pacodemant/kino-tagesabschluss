import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/datenschutz_seite.dart';
import 'package:kino_bar_app/pages/einstellungen_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';
import 'package:kino_bar_app/pages/uebertrag_umschlag_seite.dart';
import 'package:kino_bar_app/pages/verlauf_seite.dart';
import 'package:kino_bar_app/pages/getraenke_auffuellen_seite.dart';
import 'package:kino_bar_app/pages/wechselgeld_pruefen_seite.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/route_observer.dart';

class StartmenueSeite extends StatefulWidget {
  const StartmenueSeite({super.key, required this.kino});

  static const String routenName = '/start-menu';

  final Kino kino;

  @override
  State<StartmenueSeite> createState() => _StartmenueSeiteState();
}

/// Lädt "heutige Abschlüsse" und "Standort-Modus" zentral und hält sie über
/// RouteAware aktuell: Kehrt man von einer anderen Seite (z. B. Verlauf,
/// nach Löschen/Erstellen einer Abrechnung) per pop() zur Startseite zurück,
/// wird die bereits existierende Widget-Instanz NICHT neu erzeugt — ein
/// simples initState()-Laden (oder ein FutureBuilder mit inline erzeugtem
/// Future) bliebe daher auf dem veralteten Stand hängen. didPopNext() löst
/// stattdessen ein frisches Nachladen aus.
class _StartmenueSeiteState extends State<StartmenueSeite> with RouteAware {
  List<TagesabschlussFinal>? _heutigeAbschluesse;
  String? _standortModus;

  Kino get kino => widget.kino;

  @override
  void initState() {
    super.initState();
    _ladeDaten();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _ladeDaten();
  }

  Future<void> _ladeDaten() async {
    final List<TagesabschlussFinal> heutige =
        await LokalerSpeicher.ladeHeutigeFinaleTagesabschluesse(kino.id);
    final String? standortModus = await LokalerSpeicher.ladeStandortModus();
    if (!mounted) {
      return;
    }
    setState(() {
      _heutigeAbschluesse = heutige;
      _standortModus = standortModus;
    });
  }

  void _oeffneTagesabschlussSchritt1(BuildContext context) {
    Navigator.of(context).pushNamed(
      TagesabschlussSchritt1Seite.routenName,
      arguments: TagesabschlussSchritt1Argumente(
        kinoId: kino.id,
        kinoName: kino.name,
      ),
    );
  }

  Future<void> _oeffneUebertragUmschlag(BuildContext context) async {
    final List<TagesabschlussFinal> heutige =
        _heutigeAbschluesse ?? <TagesabschlussFinal>[];

    if (heutige.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          content: const Text('Du musst erst eine Abrechnung durchführen.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (heutige.length == 1) {
      Navigator.of(context).pushNamed(
        UebertragUmschlagSeite.routenName,
        arguments: heutige.first,
      );
      return;
    }

    final TagesabschlussFinal? ausgewaehlt =
        await showModalBottomSheet<TagesabschlussFinal>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welche Abrechnung von heute?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              for (final TagesabschlussFinal eintrag in heutige)
                ListTile(
                  title: Text(
                    '${eintrag.createdAt.hour.toString().padLeft(2, '0')}:'
                    '${eintrag.createdAt.minute.toString().padLeft(2, '0')} Uhr',
                  ),
                  subtitle: (eintrag.mitarbeiterName != null &&
                          eintrag.mitarbeiterName!.isNotEmpty)
                      ? Text(eintrag.mitarbeiterName!)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(eintrag),
                ),
            ],
          ),
        );
      },
    );
    if (ausgewaehlt == null || !context.mounted) {
      return;
    }
    Navigator.of(context).pushNamed(
      UebertragUmschlagSeite.routenName,
      arguments: ausgewaehlt,
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
    final bool uebertragAktiv =
        (_heutigeAbschluesse ?? <TagesabschlussFinal>[]).isNotEmpty;
    final bool zeigeKinoWechseln = _standortModus == null;

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
          if (zeigeKinoWechseln)
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppFarben.fokusFarbe,
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Kassenabrechnung (4 Schritte)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _oeffneUebertragUmschlag(context),
                  style: uebertragAktiv
                      ? null
                      : ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.grey.shade700,
                        ),
                  child: const Text('Übertrag auf Umschlag'),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppFarben.appBarRotGedaempft,
                  ),
                  child: const Text('Einstellungen'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _oeffneVerlauf(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppFarben.appBarRotGedaempft,
                  ),
                  child: const Text('Verlauf'),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(DatenschutzSeite.routenName),
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
                const Spacer(),
                const Center(
                  child: Text(
                    'Web App 0.9.12 · r336a4 @ GitHub:',
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
        ],
      ),
    );
  }
}
