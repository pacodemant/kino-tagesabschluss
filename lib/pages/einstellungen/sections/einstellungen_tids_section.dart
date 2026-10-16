import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/utils/tid_eingabe.dart';

/// Kachel "TIDs" (Run 488): bis zu vier Kartenterminals des Standorts mit
/// Geräte-Nummer und "KK connected"-Markierung, pro Gerät gespeichert.
/// Lädt und speichert selbst (jede Änderung sofort), damit die
/// Einstellungen-Seite keine Controller dafür durchreichen muss.
class EinstellungenTidsSection extends StatefulWidget {
  const EinstellungenTidsSection({super.key, required this.kinoId});

  final String kinoId;

  @override
  State<EinstellungenTidsSection> createState() =>
      _EinstellungenTidsSectionState();
}

class _EinstellungenTidsSectionState extends State<EinstellungenTidsSection> {
  static const int _plaetze = TerminalIdsConfigService.maxTerminals;

  final List<TextEditingController> _tidCtrl =
      List<TextEditingController>.generate(
        _plaetze,
        (_) => TextEditingController(),
      );
  final List<TextEditingController> _nummerCtrl =
      List<TextEditingController>.generate(
        _plaetze,
        (_) => TextEditingController(),
      );

  // Platz-Index des "KK connected"-Terminals, null = keins.
  int? _kinokassePlatz;
  bool _aufgeklappt = false;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      ..._tidCtrl,
      ..._nummerCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _laden() async {
    final List<TerminalEintrag> terminals =
        await TerminalIdsConfigService.ladeTerminals(widget.kinoId);
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < terminals.length && i < _plaetze; i++) {
        _tidCtrl[i].text = terminals[i].tid;
        _nummerCtrl[i].text = terminals[i].nummer;
        if (terminals[i].kinokasse) _kinokassePlatz = i;
      }
    });
  }

  Future<void> _speichern() {
    return TerminalIdsConfigService.speichereTerminals(
      widget.kinoId,
      <TerminalEintrag>[
        for (int i = 0; i < _plaetze; i++)
          TerminalEintrag(
            tid: _tidCtrl[i].text,
            nummer: _nummerCtrl[i].text,
            kinokasse: _kinokassePlatz == i,
          ),
      ],
    );
  }

  int get _anzahlEingetragen => _tidCtrl
      .where((TextEditingController c) => c.text.trim().isNotEmpty)
      .length;

  Widget _zeile(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 48,
            child: TextField(
              controller: _nummerCtrl[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              decoration: const InputDecoration(
                labelText: 'Nr.',
                isDense: true,
              ),
              onChanged: (_) => _speichern(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _tidCtrl[i],
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[TidEingabe.formatter],
              decoration: InputDecoration(
                labelText: 'TID ${i + 1}',
                isDense: true,
              ),
              onChanged: (_) {
                setState(() {});
                _speichern();
              },
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Checkbox(
                value: _kinokassePlatz == i,
                activeColor: AppFarben.appBarRot,
                visualDensity: VisualDensity.compact,
                onChanged: (bool? an) {
                  setState(() => _kinokassePlatz = an == true ? i : null);
                  _speichern();
                },
              ),
              const Text('KK', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int anzahl = _anzahlEingetragen;
    // Material statt Container: ListTile braucht für den Tipp-Effekt einen
    // Material-Vorfahren direkt über sich.
    return Material(
      color: AppFarben.gruppierungBandB,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: const Text(
              'TIDs',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  anzahl == 0 ? 'keine' : '$anzahl',
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(width: 4),
                Icon(_aufgeklappt ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () => setState(() => _aufgeklappt = !_aufgeklappt),
          ),
          if (_aufgeklappt) ...<Widget>[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int i = 0; i < _plaetze; i++) _zeile(i),
                  Text(
                    'Nr. = Nummer auf dem Gerät. KK = Gerät hängt an der '
                    'Kinokasse ("KK connected"), dessen Kartenumsatz kommt '
                    'im Übertrag zum Kino Soll. Belege mit anderer TID '
                    'werden abgelehnt. Ohne eingetragene TID keine Prüfung.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
