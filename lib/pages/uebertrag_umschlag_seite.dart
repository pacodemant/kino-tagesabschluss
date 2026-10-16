import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';
import 'package:kino_bar_app/widgets/uebertrag_umschlag_inhalt.dart';

/// Zeigt die "Übertrag auf Umschlag"-Werte eines bereits abgeschlossenen
/// Tagesabschlusses nachträglich an — rein lesend: kein Auto-Save,
/// kein "Kassenabrechnung senden", kein Schritt-Slider. Erreichbar über den
/// "Übertrag auf Umschlag"-Button auf der Kino-Startseite. Inhalt seit
/// Run 489 aus [UebertragUmschlagInhalt] (SB im Layout des SB-Umschlags,
/// EC je Terminal), je Rahmen eine Card.
class UebertragUmschlagSeite extends StatefulWidget {
  const UebertragUmschlagSeite({super.key, required this.abschluss});

  static const String routenName = '/uebertrag-umschlag';

  final TagesabschlussFinal abschluss;

  @override
  State<UebertragUmschlagSeite> createState() => _UebertragUmschlagSeiteState();
}

class _UebertragUmschlagSeiteState extends State<UebertragUmschlagSeite> {
  List<TerminalEintrag> _terminals = const <TerminalEintrag>[];

  @override
  void initState() {
    super.initState();
    TerminalIdsConfigService.ladeTerminals(widget.abschluss.kinoId).then((
      List<TerminalEintrag> terminals,
    ) {
      if (mounted) setState(() => _terminals = terminals);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TagesabschlussFinal abschluss = widget.abschluss;

    return TagesabschlussScaffold(
      backgroundColor: AppFarben.seitenHintergrund,
      title: 'Übertrag auf Umschlag',
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Expanded(
                  child: Text(
                    abschluss.kinoName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                Text(
                  TagesabschlussFormatierung.deutschesDatum(abschluss.datum),
                  style: GoogleFonts.caveat(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          for (final List<Widget> zeilen in UebertragUmschlagInhalt.rahmen(
            abschluss,
            _terminals,
          ))
            Card(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: zeilen),
              ),
            ),
        ],
      ),
    );
  }
}
