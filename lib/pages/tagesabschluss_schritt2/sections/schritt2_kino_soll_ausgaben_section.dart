import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';

// Zweck: Rendert die Card mit Kino-SOLL/Bistro-SOLL und der Ausgaben-Liste
// (Schritt 2). Bistro-SOLL entfaellt fuer Standorte ohne dieses Feld
// (bistroSollEingabeZeile dann null).
class Schritt2KinoSollUndAusgabenSection extends StatelessWidget {
  const Schritt2KinoSollUndAusgabenSection({
    super.key,
    required this.kinoSollEingabeZeile,
    required this.bistroSollEingabeZeile,
    required this.gesamtUmsatzCent,
    required this.ausgabenIds,
    required this.ausgabenLabelController,
    required this.ausgabenLabelFocusNode,
    required this.ausgabenBetragController,
    required this.ausgabenBetragFocusNode,
    required this.textInputActionFuerSchritt2,
    required this.beiEingabeAbgeschlossen,
    required this.onAusgabenLabelGeaendert,
    required this.onAusgabenLabelGeloescht,
    required this.onAusgabenBetragGeaendert,
    required this.onAusgabeEntfernen,
    required this.onAusgabeHinzufuegen,
  });

  final Widget kinoSollEingabeZeile;
  final Widget? bistroSollEingabeZeile;
  // Nur informativ: Kino SOLL + Bistro SOLL, ohne Abzug der Ausgaben.
  final int gesamtUmsatzCent;
  final List<int> ausgabenIds;
  final List<TextEditingController> ausgabenLabelController;
  final List<FocusNode> ausgabenLabelFocusNode;
  final List<TextEditingController> ausgabenBetragController;
  final List<FocusNode> ausgabenBetragFocusNode;
  final TextInputAction Function(FocusNode focusNode)
  textInputActionFuerSchritt2;
  final void Function(FocusNode focusNode) beiEingabeAbgeschlossen;
  final void Function(int index, String wert) onAusgabenLabelGeaendert;
  final void Function(int index) onAusgabenLabelGeloescht;
  final void Function(int index, String wert) onAusgabenBetragGeaendert;
  final void Function(int index) onAusgabeEntfernen;
  final VoidCallback onAusgabeHinzufuegen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            kinoSollEingabeZeile,
            if (bistroSollEingabeZeile != null) bistroSollEingabeZeile!,
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                'Ausgaben (optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            for (int i = 0; i < ausgabenBetragController.length; i++)
              KeyedSubtree(
                key: ValueKey<int>(ausgabenIds[i]),
                child: _Schritt2AusgabenZeile(
                  labelController: ausgabenLabelController[i],
                  labelFocusNode: ausgabenLabelFocusNode[i],
                  betragController: ausgabenBetragController[i],
                  betragFocusNode: ausgabenBetragFocusNode[i],
                  textInputActionErmitteln: textInputActionFuerSchritt2,
                  beiEingabeAbgeschlossen: beiEingabeAbgeschlossen,
                  onLabelGeaendert: (String wert) =>
                      onAusgabenLabelGeaendert(i, wert),
                  onLabelGeloescht: () => onAusgabenLabelGeloescht(i),
                  onBetragGeaendert: (String wert) =>
                      onAusgabenBetragGeaendert(i, wert),
                  zeigeLoeschen: ausgabenBetragController.length > 1,
                  onLoeschen: () => onAusgabeEntfernen(i),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAusgabeHinzufuegen,
                icon: const Icon(Icons.add),
                label: const Text('+ Ausgabe hinzufügen'),
              ),
            ),
            const Divider(height: 20),
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Umsätze gesamt (Info)',
                    style: TextStyle(fontSize: 13, color: AppFarben.subtilerText),
                  ),
                ),
                Text(
                  TagesabschlussFormatierung.formatiereEuro(gesamtUmsatzCent),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppFarben.subtilerText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Zweck: Rendert eine einzelne Ausgaben-Zeile (Bezeichnung + Betrag +
// optionaler Loeschen-Button).
class _Schritt2AusgabenZeile extends StatelessWidget {
  const _Schritt2AusgabenZeile({
    required this.labelController,
    required this.labelFocusNode,
    required this.betragController,
    required this.betragFocusNode,
    required this.textInputActionErmitteln,
    required this.beiEingabeAbgeschlossen,
    required this.onLabelGeaendert,
    required this.onLabelGeloescht,
    required this.onBetragGeaendert,
    required this.zeigeLoeschen,
    required this.onLoeschen,
  });

  final TextEditingController labelController;
  final FocusNode labelFocusNode;
  final TextEditingController betragController;
  final FocusNode betragFocusNode;
  final TextInputAction Function(FocusNode focusNode) textInputActionErmitteln;
  final void Function(FocusNode focusNode) beiEingabeAbgeschlossen;
  final ValueChanged<String> onLabelGeaendert;
  final VoidCallback onLabelGeloescht;
  final ValueChanged<String> onBetragGeaendert;
  final bool zeigeLoeschen;
  final VoidCallback onLoeschen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: labelController,
              focusNode: labelFocusNode,
              style: TextStyle(
                fontSize: 15,
                color: labelFocusNode.hasFocus ? Colors.black : null,
              ),
              cursorColor: labelFocusNode.hasFocus ? Colors.black : null,
              textInputAction: textInputActionErmitteln(labelFocusNode),
              decoration: InputDecoration(
                hintText: 'Bezeichnung (optional)',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: labelFocusNode.hasFocus ? Colors.transparent : null,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppFarben.appBarRot),
                ),
                isDense: true,
                filled: labelFocusNode.hasFocus,
                fillColor: labelFocusNode.hasFocus
                    ? AppFarben.fokusFarbe
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                  maxWidth: 32,
                  maxHeight: 32,
                ),
                suffixIcon: labelController.text.isEmpty
                    ? null
                    : IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: labelFocusNode.hasFocus ? Colors.black : null,
                        ),
                        onPressed: onLabelGeloescht,
                      ),
              ),
              onSubmitted: (_) => beiEingabeAbgeschlossen(labelFocusNode),
              onChanged: onLabelGeaendert,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 155,
            child: BetragCentEingabefeld(
              textController: betragController,
              focusNode: betragFocusNode,
              textInputAction: textInputActionErmitteln(betragFocusNode),
              onSubmitted: (_) => beiEingabeAbgeschlossen(betragFocusNode),
              onChanged: onBetragGeaendert,
              schriftgroesse: 15,
              hinweisText: '0,00 €',
              mitKomma: false,
            ),
          ),
          if (zeigeLoeschen) ...<Widget>[
            const SizedBox(width: 6),
            IconButton(
              onPressed: onLoeschen,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Ausgabe entfernen',
            ),
          ],
        ],
      ),
    );
  }
}
