import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';

typedef Schritt1FeldMitKeyBuilder = Widget Function({
  required FocusNode focusNode,
  required Widget child,
});

// Zweck: Rendert den kompletten Umschlaege-Bereich in Schritt 1.
class Schritt1UmschlaegeSection extends StatelessWidget {
  const Schritt1UmschlaegeSection({
    super.key,
    required this.umschlaege,
    required this.umschlagIds,
    required this.umschlagBezeichnungController,
    required this.umschlagBetragController,
    required this.umschlagBezeichnungFocusNode,
    required this.umschlagBetragFocusNode,
    required this.baueFeldMitKey,
    required this.textInputActionFuerSchritt1,
    required this.beiEingabeAbgeschlossen,
    required this.beiUmschlagBezeichnungGeaendert,
    required this.beiUmschlagBetragGeaendert,
    required this.umschlagEntfernen,
    required this.umschlagHinzufuegen,
    required this.formatiereEuro,
    required this.umschlagSummeCent,
  });

  final List<UmschlagEintrag> umschlaege;
  final List<int> umschlagIds;
  final List<TextEditingController> umschlagBezeichnungController;
  final List<TextEditingController> umschlagBetragController;
  final List<FocusNode> umschlagBezeichnungFocusNode;
  final List<FocusNode> umschlagBetragFocusNode;
  final Schritt1FeldMitKeyBuilder baueFeldMitKey;
  final TextInputAction Function(FocusNode focusNode) textInputActionFuerSchritt1;
  final void Function(FocusNode focusNode) beiEingabeAbgeschlossen;
  final void Function(int index, String wert) beiUmschlagBezeichnungGeaendert;
  final void Function(int index, String wert) beiUmschlagBetragGeaendert;
  final void Function(int index) umschlagEntfernen;
  final VoidCallback umschlagHinzufuegen;
  final String Function(int cent) formatiereEuro;
  final int umschlagSummeCent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (umschlaege.isEmpty) const Text('Noch keine Umschläge erfasst.'),
        for (int i = 0; i < umschlaege.length; i++) ...<Widget>[
          Builder(
            builder: (BuildContext _) {
              final FocusNode bezeichnungFocusNode =
                  umschlagBezeichnungFocusNode[i];
              final FocusNode betragFocusNode = umschlagBetragFocusNode[i];
              return Row(
                key: ValueKey<int>(umschlagIds[i]),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: baueFeldMitKey(
                      focusNode: bezeichnungFocusNode,
                      child: TextField(
                        controller: umschlagBezeichnungController[i],
                        focusNode: bezeichnungFocusNode,
                        style: const TextStyle(fontSize: 15),
                        textInputAction: textInputActionFuerSchritt1(
                          bezeichnungFocusNode,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Label (optional)',
                          hintStyle: const TextStyle(fontSize: 15),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          suffixIcon: umschlagBezeichnungController[i].text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    umschlagBezeichnungController[i].clear();
                                    beiUmschlagBezeichnungGeaendert(i, '');
                                  },
                                ),
                        ),
                        onSubmitted: (_) =>
                            beiEingabeAbgeschlossen(bezeichnungFocusNode),
                        onChanged: (String wert) =>
                            beiUmschlagBezeichnungGeaendert(i, wert),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 132,
                    child: baueFeldMitKey(
                      focusNode: betragFocusNode,
                      child: BetragCentEingabefeld(
                        textController: umschlagBetragController[i],
                        focusNode: betragFocusNode,
                        textInputAction: textInputActionFuerSchritt1(
                          betragFocusNode,
                        ),
                        onSubmitted: (_) =>
                            beiEingabeAbgeschlossen(betragFocusNode),
                        onChanged: (String wert) =>
                            beiUmschlagBetragGeaendert(i, wert),
                        schriftgroesse: 14,
                        hinweisText: '0,00 €',
                        labelText: 'Betrag €',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => umschlagEntfernen(i),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Umschlag entfernen',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
        if (umschlaege.isNotEmpty && umschlaege.first.betragCent > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: umschlagHinzufuegen,
              icon: const Icon(Icons.add),
              label: const Text('Umschlag hinzufügen'),
            ),
          ),
        Text(
          'Gesamtbetrag Umschläge: ${formatiereEuro(umschlagSummeCent)}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
