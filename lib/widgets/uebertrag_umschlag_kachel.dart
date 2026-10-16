import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:kino_bar_app/widgets/uebertrag_umschlag_inhalt.dart';

/// "Übertrag auf Umschlag"-Kachel im Verlauf-Detail (Run 487): zeigt die
/// Umschlag-Werte eines gespeicherten Abschlusses, damit ein vergessener
/// Übertrag nachgetragen werden kann. Inhalt seit Run 489 aus
/// [UebertragUmschlagInhalt] — derselbe wie auf der Übertrag-Seite (SB im
/// Layout des SB-Umschlags). Rein lesend.
class UebertragUmschlagKachel extends StatefulWidget {
  const UebertragUmschlagKachel({super.key, required this.abschluss});

  final TagesabschlussFinal abschluss;

  @override
  State<UebertragUmschlagKachel> createState() =>
      _UebertragUmschlagKachelState();
}

class _UebertragUmschlagKachelState extends State<UebertragUmschlagKachel> {
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
    final List<List<Widget>> rahmen = UebertragUmschlagInhalt.rahmen(
      widget.abschluss,
      _terminals,
    );
    return Card(
      child: ExpansionTile(
        title: const Text(
          'Übertrag auf Umschlag',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: false,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: <Widget>[
          for (int i = 0; i < rahmen.length; i++) ...<Widget>[
            if (i > 0) const Divider(),
            ...rahmen[i],
          ],
        ],
      ),
    );
  }
}
