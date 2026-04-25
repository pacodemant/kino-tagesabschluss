import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_umschlaege_section.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/ganzzahl_eingabefeld.dart';

// Zweck: Formatiert Rollen-Betraege konsistent als Euro-Wert mit Cent.
String schritt1FormatiereRollenAnzeige(
  int cent,
  String Function(int cent) formatiereEuro,
) {
  // Regression-Fix: Rollensumme immer im gleichen Euroformat mit Cent anzeigen.
  return formatiereEuro(cent);
}

class Schritt1GruppenInhalt extends StatelessWidget {
  const Schritt1GruppenInhalt({
    super.key,
    required this.zeilen,
    required this.gesamtbetragLabel,
    required this.zeilenEintragBuilder,
    required this.summeGruppe,
    required this.formatiereBetrag,
  });

  final List<Kassenzeile> zeilen;
  final String gesamtbetragLabel;
  final Widget Function(Kassenzeile zeile) zeilenEintragBuilder;
  final int Function(List<Kassenzeile> zeilen) summeGruppe;
  final String Function(int cent) formatiereBetrag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in zeilen) ...<Widget>[
          zeilenEintragBuilder(zeile),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        Text(
          '$gesamtbetragLabel: ${formatiereBetrag(summeGruppe(zeilen))}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class Schritt1ZeilenEintrag extends StatelessWidget {
  const Schritt1ZeilenEintrag({
    super.key,
    required this.zeile,
    required this.stueckzahl,
    required this.controller,
    required this.focusNode,
    required this.baueFeldMitKey,
    required this.textInputActionFuerSchritt1,
    required this.beiStueckzahlGeaendert,
    required this.beiEingabeAbgeschlossen,
    required this.formatiereEuro,
    this.istHervorgehoben = false,
  });

  final Kassenzeile zeile;
  final int stueckzahl;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Schritt1FeldMitKeyBuilder baueFeldMitKey;
  final TextInputAction Function(FocusNode focusNode)
  textInputActionFuerSchritt1;
  final void Function(Kassenzeile zeile, String wert) beiStueckzahlGeaendert;
  final void Function(FocusNode focusNode) beiEingabeAbgeschlossen;
  final String Function(int cent) formatiereEuro;
  final bool istHervorgehoben;

  @override
  Widget build(BuildContext context) {
    final int zwischensumme = stueckzahl * zeile.einzelwertCent;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            zeile.bezeichnung,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 96,
          child: baueFeldMitKey(
            focusNode: focusNode,
            child: GanzzahlEingabefeld(
              textController: controller,
              focusNode: focusNode,
              schriftgroesse: 16,
              textInputAction: textInputActionFuerSchritt1(focusNode),
              onChanged: (String wert) => beiStueckzahlGeaendert(zeile, wert),
              onSubmitted: (_) => beiEingabeAbgeschlossen(focusNode),
              istHervorgehoben: istHervorgehoben,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 95,
          child: Text(
            formatiereEuro(zwischensumme),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class Schritt1LoseMuenzenInhalt extends StatelessWidget {
  const Schritt1LoseMuenzenInhalt({
    super.key,
    required this.loseMuenzarten,
    required this.loseMuenzenFocusNode,
    required this.loseMuenzenController,
    required this.baueFeldMitKey,
    required this.textInputActionFuerSchritt1,
    required this.beiEingabeAbgeschlossen,
    required this.beiLoseMuenzartBetragGeaendert,
    required this.formatiereEuro,
    required this.loseMuenzenGesamtCent,
    this.rotHervorgehoben = const <FocusNode>{},
  });

  final List<Kassenzeile> loseMuenzarten;
  final Map<String, FocusNode> loseMuenzenFocusNode;
  final Map<String, TextEditingController> loseMuenzenController;
  final Schritt1FeldMitKeyBuilder baueFeldMitKey;
  final TextInputAction Function(FocusNode focusNode)
  textInputActionFuerSchritt1;
  final void Function(FocusNode focusNode) beiEingabeAbgeschlossen;
  final void Function(String muenzartId, String wert)
  beiLoseMuenzartBetragGeaendert;
  final String Function(int cent) formatiereEuro;
  final int loseMuenzenGesamtCent;
  final Set<FocusNode> rotHervorgehoben;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in loseMuenzarten) ...<Widget>[
          Builder(
            builder: (BuildContext _) {
              final FocusNode focusNode = loseMuenzenFocusNode[zeile.id]!;
              return Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      zeile.bezeichnung,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 148,
                    child: baueFeldMitKey(
                      focusNode: focusNode,
                      child: BetragCentEingabefeld(
                        textController: loseMuenzenController[zeile.id]!,
                        focusNode: focusNode,
                        textInputAction: textInputActionFuerSchritt1(focusNode),
                        onSubmitted: (_) => beiEingabeAbgeschlossen(focusNode),
                        onChanged: (String wert) =>
                            beiLoseMuenzartBetragGeaendert(zeile.id, wert),
                        schriftgroesse: 15,
                        hinweisText: '0,00 €',
                        istHervorgehoben: rotHervorgehoben.contains(focusNode),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Text(
          'Gesamtbetrag Lose Münzen: ${formatiereEuro(loseMuenzenGesamtCent)}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class Schritt1RollenInhalt extends StatelessWidget {
  const Schritt1RollenInhalt({
    super.key,
    required this.rollenOhneKupfer,
    required this.kupferRollen,
    required this.kupferRollenSichtbar,
    required this.zeilenEintragBuilder,
    required this.summeGruppe,
    required this.formatiereRollenAnzeige,
    required this.zeigeKupferRollen,
    required this.rollenSichtbar,
  });

  final List<Kassenzeile> rollenOhneKupfer;
  final List<Kassenzeile> kupferRollen;
  final bool kupferRollenSichtbar;
  final Widget Function(Kassenzeile zeile) zeilenEintragBuilder;
  final int Function(List<Kassenzeile> zeilen) summeGruppe;
  final String Function(int cent) formatiereRollenAnzeige;
  final VoidCallback zeigeKupferRollen;
  final List<Kassenzeile> rollenSichtbar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in rollenOhneKupfer) ...<Widget>[
          zeilenEintragBuilder(zeile),
          const SizedBox(height: 8),
        ],
        if (!kupferRollenSichtbar)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: zeigeKupferRollen,
              icon: const Icon(Icons.add),
              label: const Text('Kupfer-Rollen hinzufügen'),
            ),
          ),
        if (kupferRollenSichtbar) ...<Widget>[
          const SizedBox(height: 8),
          for (final Kassenzeile zeile in kupferRollen) ...<Widget>[
            zeilenEintragBuilder(zeile),
            const SizedBox(height: 8),
          ],
        ],
        const SizedBox(height: 4),
        Text(
          'Gesamtbetrag Rollen: ${formatiereRollenAnzeige(summeGruppe(rollenSichtbar))}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class Schritt1KartenzahlungenInhalt extends StatelessWidget {
  const Schritt1KartenzahlungenInhalt({
    super.key,
    required this.kartenzahlungController,
    required this.kartenzahlungIds,
    required this.kartenzahlungFocusNode,
    required this.baueFeldMitKey,
    required this.textInputActionFuerSchritt1,
    required this.beiEingabeAbgeschlossen,
    required this.beiKartenzahlungBetragGeaendert,
    required this.kartenzahlungEntfernen,
    required this.kartenzahlungHinzufuegen,
    required this.kartenzahlungenCent,
    required this.formatiereEuro,
    required this.kartenzahlungenSummeCent,
    this.rotHervorgehoben = const <FocusNode>{},
  });

  final List<TextEditingController> kartenzahlungController;
  final List<int> kartenzahlungIds;
  final List<FocusNode> kartenzahlungFocusNode;
  final Schritt1FeldMitKeyBuilder baueFeldMitKey;
  final TextInputAction Function(FocusNode focusNode)
  textInputActionFuerSchritt1;
  final void Function(FocusNode focusNode) beiEingabeAbgeschlossen;
  final void Function(int index, String wert) beiKartenzahlungBetragGeaendert;
  final void Function(int index) kartenzahlungEntfernen;
  final VoidCallback kartenzahlungHinzufuegen;
  final List<int> kartenzahlungenCent;
  final String Function(int cent) formatiereEuro;
  final int kartenzahlungenSummeCent;
  final Set<FocusNode> rotHervorgehoben;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < kartenzahlungController.length; i++) ...<Widget>[
          Row(
            key: ValueKey<int>(kartenzahlungIds[i]),
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Kartenzahlung',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 148,
                child: baueFeldMitKey(
                  focusNode: kartenzahlungFocusNode[i],
                  child: BetragCentEingabefeld(
                    textController: kartenzahlungController[i],
                    focusNode: kartenzahlungFocusNode[i],
                    textInputAction: textInputActionFuerSchritt1(
                      kartenzahlungFocusNode[i],
                    ),
                    onSubmitted: (_) =>
                        beiEingabeAbgeschlossen(kartenzahlungFocusNode[i]),
                    onChanged: (String wert) =>
                        beiKartenzahlungBetragGeaendert(i, wert),
                    schriftgroesse: 15,
                    hinweisText: '0,00 €',
                    istHervorgehoben:
                        rotHervorgehoben.contains(kartenzahlungFocusNode[i]),
                  ),
                ),
              ),
              if (i > 0) ...<Widget>[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => kartenzahlungEntfernen(i),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Kartenzahlung entfernen',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (kartenzahlungenCent.first > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: kartenzahlungHinzufuegen,
              icon: const Icon(Icons.add),
              label: const Text('Kartenzahlung hinzufügen'),
            ),
          ),
        Text(
          'Gesamt Kartenzahlungen: ${formatiereEuro(kartenzahlungenSummeCent)}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
