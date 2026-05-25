import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_hinweise_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_muenzen_lose_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_muenzen_rollen_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_scheine_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/sections/schritt1_umschlaege_section.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_ui_builder.dart'
    as schritt1_ui;

// Zweck: Kapselt den verbleibenden Gruppen-/Wrapper-Aufbau fuer Schritt 1.
class Schritt1GruppenOrchestrierung {
  const Schritt1GruppenOrchestrierung();

  Schritt1GruppenWidgets baueGruppen({
    required List<Kassenzeile> scheine,
    required List<Kassenzeile> loseMuenzarten,
    required List<Kassenzeile> rollenOhneKupfer,
    required List<Kassenzeile> kupferRollen,
    required List<Kassenzeile> rollenSichtbar,
    required List<Kassenzeile> loseMuenzartenOhneKupfer,
    required List<Kassenzeile> kupferLoseMuenzarten,
    required bool scheineAufgeklappt,
    required bool loseMuenzenAufgeklappt,
    required bool rollenAufgeklappt,
    required bool umschlaegeAufgeklappt,
    required bool kupferLoseSichtbar,
    required bool kupferRollenSichtbar,
    required VoidCallback zeigeKupferLose,
    required Map<String, int> stueckzahlen,
    required Map<String, TextEditingController> stueckzahlController,
    required Map<String, FocusNode> stueckzahlFocusNode,
    required Map<String, TextEditingController> loseMuenzenController,
    required Map<String, FocusNode> loseMuenzenFocusNode,
    required List<UmschlagEintrag> umschlaege,
    required List<int> umschlagIds,
    required List<TextEditingController> umschlagBezeichnungController,
    required List<TextEditingController> umschlagBetragController,
    required List<FocusNode> umschlagBezeichnungFocusNode,
    required List<FocusNode> umschlagBetragFocusNode,
    required int loseMuenzenGesamtCent,
    required int umschlagSummeCent,
    required String Function(int cent) formatiereEuro,
    required int Function(List<Kassenzeile> zeilen) summeGruppe,
    required Schritt1FeldMitKeyBuilder baueFeldMitKey,
    required TextInputAction Function(FocusNode focusNode)
    textInputActionFuerSchritt1,
    required void Function(FocusNode focusNode) beiEingabeAbgeschlossen,
    required void Function(Kassenzeile zeile, String wert)
    beiStueckzahlGeaendert,
    required void Function(String muenzartId, String wert)
    beiLoseMuenzartBetragGeaendert,
    required void Function(int index, String wert)
    beiUmschlagBezeichnungGeaendert,
    required void Function(int index, String wert) beiUmschlagBetragGeaendert,
    required void Function(int index) umschlagEntfernen,
    required VoidCallback umschlagHinzufuegen,
    required VoidCallback zeigeKupferRollen,
    required VoidCallback toggleScheine,
    required VoidCallback toggleLoseMuenzen,
    required VoidCallback toggleRollen,
    required VoidCallback toggleUmschlaege,
    required Set<FocusNode> rotHervorgehoben,
  }) {
    Widget baueZeilenEintrag(Kassenzeile zeile) {
      return _baueZeilenEintrag(
        zeile: zeile,
        stueckzahl: stueckzahlen[zeile.id] ?? 0,
        controller: stueckzahlController[zeile.id]!,
        focusNode: stueckzahlFocusNode[zeile.id]!,
        baueFeldMitKey: baueFeldMitKey,
        textInputActionFuerSchritt1: textInputActionFuerSchritt1,
        beiStueckzahlGeaendert: beiStueckzahlGeaendert,
        beiEingabeAbgeschlossen: beiEingabeAbgeschlossen,
        formatiereEuro: formatiereEuro,
        istHervorgehoben:
            rotHervorgehoben.contains(stueckzahlFocusNode[zeile.id]!),
      );
    }

    final Widget scheineGruppe = Schritt1ScheineSection(
      gesamtbetrag: formatiereEuro(summeGruppe(scheine)),
      aufgeklappt: scheineAufgeklappt,
      beimUmschalten: toggleScheine,
      inhalt: schritt1_ui.Schritt1GruppenInhalt(
        zeilen: scheine,
        gesamtbetragLabel: 'Gesamtbetrag Scheine',
        zeilenEintragBuilder: baueZeilenEintrag,
        summeGruppe: summeGruppe,
        formatiereBetrag: formatiereEuro,
      ),
    );

    final Widget loseMuenzenGruppe = Schritt1MuenzenLoseSection(
      gesamtbetrag: formatiereEuro(loseMuenzenGesamtCent),
      aufgeklappt: loseMuenzenAufgeklappt,
      beimUmschalten: toggleLoseMuenzen,
      inhalt: schritt1_ui.Schritt1LoseMuenzenInhalt(
        loseMuenzartenOhneKupfer: loseMuenzartenOhneKupfer,
        kupferLoseMuenzarten: kupferLoseMuenzarten,
        kupferLoseSichtbar: kupferLoseSichtbar,
        zeigeKupferLose: zeigeKupferLose,
        loseMuenzenFocusNode: loseMuenzenFocusNode,
        loseMuenzenController: loseMuenzenController,
        baueFeldMitKey: baueFeldMitKey,
        textInputActionFuerSchritt1: textInputActionFuerSchritt1,
        beiEingabeAbgeschlossen: beiEingabeAbgeschlossen,
        beiLoseMuenzartBetragGeaendert: beiLoseMuenzartBetragGeaendert,
        formatiereEuro: formatiereEuro,
        loseMuenzenGesamtCent: loseMuenzenGesamtCent,
        rotHervorgehoben: rotHervorgehoben,
      ),
    );

    final Widget rollenGruppe = Schritt1MuenzenRollenSection(
      gesamtbetrag: schritt1_ui.schritt1FormatiereRollenAnzeige(
        summeGruppe(rollenSichtbar),
        formatiereEuro,
      ),
      aufgeklappt: rollenAufgeklappt,
      beimUmschalten: toggleRollen,
      inhalt: schritt1_ui.Schritt1RollenInhalt(
        rollenOhneKupfer: rollenOhneKupfer,
        kupferRollen: kupferRollen,
        kupferRollenSichtbar: kupferRollenSichtbar,
        zeilenEintragBuilder: baueZeilenEintrag,
        summeGruppe: summeGruppe,
        formatiereRollenAnzeige: (int cent) =>
            schritt1_ui.schritt1FormatiereRollenAnzeige(cent, formatiereEuro),
        zeigeKupferRollen: zeigeKupferRollen,
        rollenSichtbar: rollenSichtbar,
      ),
    );

    final Widget umschlaegeGruppe = _baueEinklappbarenBereich(
      titel: 'Sonstiges (Umschläge u.a.)',
      gesamtbetragCent: umschlagSummeCent,
      aufgeklappt: umschlaegeAufgeklappt,
      beimUmschalten: toggleUmschlaege,
      inhalt: Schritt1UmschlaegeSection(
        umschlaege: umschlaege,
        umschlagIds: umschlagIds,
        umschlagBezeichnungController: umschlagBezeichnungController,
        umschlagBetragController: umschlagBetragController,
        umschlagBezeichnungFocusNode: umschlagBezeichnungFocusNode,
        umschlagBetragFocusNode: umschlagBetragFocusNode,
        baueFeldMitKey: baueFeldMitKey,
        textInputActionFuerSchritt1: textInputActionFuerSchritt1,
        beiEingabeAbgeschlossen: beiEingabeAbgeschlossen,
        beiUmschlagBezeichnungGeaendert: beiUmschlagBezeichnungGeaendert,
        beiUmschlagBetragGeaendert: beiUmschlagBetragGeaendert,
        umschlagEntfernen: umschlagEntfernen,
        umschlagHinzufuegen: umschlagHinzufuegen,
        formatiereEuro: formatiereEuro,
        umschlagSummeCent: umschlagSummeCent,
      ),
      formatiereEuro: formatiereEuro,
      hilfeDialogTitel: 'Sonstiges eingeben',
      hilfeDialogText:
          'Hier den Betrag für sonstige Einnahmen (z.B. Umschläge) in Cent eingeben — ohne Komma.\n'
          'Also z.B. "340" für drei Euro und vierzig Cent.',
    );

    return Schritt1GruppenWidgets(
      scheineGruppe: scheineGruppe,
      loseMuenzenGruppe: loseMuenzenGruppe,
      rollenGruppe: rollenGruppe,
      hinweiseSection: Schritt1HinweiseSection(
        umschlaegeInhalt: umschlaegeGruppe,
      ),
    );
  }

  Widget _baueEinklappbarenBereich({
    required String titel,
    required int gesamtbetragCent,
    required bool aufgeklappt,
    required VoidCallback beimUmschalten,
    required Widget inhalt,
    required String Function(int cent) formatiereEuro,
    String? hilfeDialogTitel,
    String? hilfeDialogText,
  }) {
    final bool hatHilfe = hilfeDialogTitel != null && hilfeDialogText != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: beimUmschalten,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: hatHilfe
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                titel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Builder(
                                builder: (BuildContext ctx) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text.rich(
                                      TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'Betrag',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          TextSpan(
                                            text: ' in ',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          TextSpan(
                                            text: 'Cent',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppFarben.appBarRot,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.help_outline),
                                      color: AppFarben.appBarRot,
                                      iconSize: 18,
                                      padding: const EdgeInsets.only(left: 4),
                                      constraints: const BoxConstraints(),
                                      onPressed: () => showDialog<void>(
                                        context: ctx,
                                        builder: (dialogCtx) => AlertDialog(
                                          title: Text(hilfeDialogTitel),
                                          content: Text(hilfeDialogText),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(dialogCtx).pop(),
                                              child: const Text('Verstanden'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Text(
                            titel,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                  Text(
                    formatiereEuro(gesamtbetragCent),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(aufgeklappt ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (aufgeklappt) ...<Widget>[
            const Divider(height: 1),
            Padding(padding: const EdgeInsets.all(12), child: inhalt),
          ],
        ],
      ),
    );
  }

  Widget _baueZeilenEintrag({
    required Kassenzeile zeile,
    required int stueckzahl,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Schritt1FeldMitKeyBuilder baueFeldMitKey,
    required TextInputAction Function(FocusNode focusNode)
    textInputActionFuerSchritt1,
    required void Function(Kassenzeile zeile, String wert)
    beiStueckzahlGeaendert,
    required void Function(FocusNode focusNode) beiEingabeAbgeschlossen,
    required String Function(int cent) formatiereEuro,
    bool istHervorgehoben = false,
  }) {
    return schritt1_ui.Schritt1ZeilenEintrag(
      zeile: zeile,
      stueckzahl: stueckzahl,
      controller: controller,
      focusNode: focusNode,
      baueFeldMitKey: baueFeldMitKey,
      textInputActionFuerSchritt1: textInputActionFuerSchritt1,
      beiStueckzahlGeaendert: beiStueckzahlGeaendert,
      beiEingabeAbgeschlossen: beiEingabeAbgeschlossen,
      formatiereEuro: formatiereEuro,
      istHervorgehoben: istHervorgehoben,
    );
  }
}

// Zweck: Buedelt die gruppierten Widgets fuer die Body-Composition.
class Schritt1GruppenWidgets {
  const Schritt1GruppenWidgets({
    required this.scheineGruppe,
    required this.loseMuenzenGruppe,
    required this.rollenGruppe,
    required this.hinweiseSection,
  });

  final Widget scheineGruppe;
  final Widget loseMuenzenGruppe;
  final Widget rollenGruppe;
  final Widget hinweiseSection;
}
