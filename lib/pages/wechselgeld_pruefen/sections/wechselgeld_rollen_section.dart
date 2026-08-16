import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1/ui/schritt1_ui_builder.dart'
    as schritt1_ui;
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/collapsible_card_section.dart';

class WechselgeldRollenSection extends StatelessWidget {
  const WechselgeldRollenSection({
    super.key,
    required this.rollenOhneKupfer,
    required this.kupferRollen,
    required this.rollenSichtbar,
    required this.kupferRollenSichtbar,
    required this.rollenAufgeklappt,
    required this.rollenUebernommen,
    required this.stueckzahlen,
    required this.stueckzahlController,
    required this.stueckzahlFocusNode,
    required this.summeGruppe,
    required this.formatiereEuro,
    required this.baueFeldMitKey,
    required this.textInputActionFuerSchritt1,
    required this.beiStueckzahlGeaendert,
    required this.beiEingabeAbgeschlossen,
    required this.zeigeKupferRollen,
    required this.entferneKupferRollen,
    required this.onToggleRollen,
    required this.onLoescheRollen,
    required this.onLadeRollenAusErsterZaehlung,
    required this.onZeigeRollenUebernehmenHilfe,
  });

  final List<Kassenzeile> rollenOhneKupfer;
  final List<Kassenzeile> kupferRollen;
  final List<Kassenzeile> rollenSichtbar;
  final bool kupferRollenSichtbar;
  final bool rollenAufgeklappt;
  final bool rollenUebernommen;
  final Map<String, int> stueckzahlen;
  final Map<String, TextEditingController> stueckzahlController;
  final Map<String, FocusNode> stueckzahlFocusNode;
  final int Function(List<Kassenzeile> zeilen) summeGruppe;
  final String Function(int cent) formatiereEuro;
  final Widget Function({required FocusNode focusNode, required Widget child})
      baueFeldMitKey;
  final TextInputAction Function(FocusNode focusNode)
      textInputActionFuerSchritt1;
  final void Function(Kassenzeile zeile, String wert) beiStueckzahlGeaendert;
  final void Function(FocusNode focusNode) beiEingabeAbgeschlossen;
  final VoidCallback zeigeKupferRollen;
  final VoidCallback entferneKupferRollen;
  final VoidCallback onToggleRollen;
  final VoidCallback onLoescheRollen;
  final VoidCallback onLadeRollenAusErsterZaehlung;
  final VoidCallback onZeigeRollenUebernehmenHilfe;

  @override
  Widget build(BuildContext context) {
    final String gesamtbetrag = schritt1_ui.schritt1FormatiereRollenAnzeige(
      summeGruppe(rollenSichtbar),
      formatiereEuro,
    );

    Widget zeilenEintrag(Kassenzeile zeile) {
      return schritt1_ui.Schritt1ZeilenEintrag(
        zeile: zeile,
        stueckzahl: stueckzahlen[zeile.id] ?? 0,
        controller: stueckzahlController[zeile.id]!,
        focusNode: stueckzahlFocusNode[zeile.id]!,
        baueFeldMitKey: baueFeldMitKey,
        textInputActionFuerSchritt1: textInputActionFuerSchritt1,
        beiStueckzahlGeaendert: beiStueckzahlGeaendert,
        beiEingabeAbgeschlossen: beiEingabeAbgeschlossen,
        formatiereEuro: formatiereEuro,
      );
    }

    final Widget inhalt = schritt1_ui.Schritt1RollenInhalt(
      rollenOhneKupfer: rollenOhneKupfer,
      kupferRollen: kupferRollen,
      kupferRollenSichtbar: kupferRollenSichtbar,
      zeilenEintragBuilder: zeilenEintrag,
      summeGruppe: summeGruppe,
      formatiereRollenAnzeige: (int cent) =>
          schritt1_ui.schritt1FormatiereRollenAnzeige(cent, formatiereEuro),
      zeigeKupferRollen: zeigeKupferRollen,
      entferneKupferRollen: entferneKupferRollen,
      rollenSichtbar: rollenSichtbar,
    );

    final Widget zusatzZeile = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: rollenUebernommen
              ? onLoescheRollen
              : onLadeRollenAusErsterZaehlung,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 4,
            ),
            child: Text(
              rollenUebernommen
                  ? 'Geldrollen löschen'
                  : 'Aus Zählung von vorhin übernehmen',
              style: TextStyle(
                fontSize: 10,
                color: AppFarben.appBarRot,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          color: AppFarben.appBarRot,
          iconSize: 18,
          padding: const EdgeInsets.only(left: 4),
          constraints: const BoxConstraints(),
          onPressed: onZeigeRollenUebernehmenHilfe,
        ),
      ],
    );

    return CollapsibleCardSection(
      gesamtbetrag: gesamtbetrag,
      aufgeklappt: rollenAufgeklappt,
      beimUmschalten: onToggleRollen,
      inhalt: inhalt,
      zusatzZeile: zusatzZeile,
      headerText: const TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'Rollen ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' Anzahl ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              backgroundColor: Colors.black,
              fontSize: 10,
            ),
          ),
          TextSpan(
            text: ' der Rollen',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
      hilfeDialogTitel: 'Rollen eingeben',
      hilfeDialogInhalt: const Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: 'Rollen einfach zählen und '),
            TextSpan(
              text: 'Anzahl',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' eingeben, nicht den Betrag.\n'),
            TextSpan(
                text:
                    'Eine Rolle 2-Euro-Münzen hat z.B. einen Wert von 50 €.\n'),
            TextSpan(text: 'Also "2" für zwei Rollen, nicht "100".'),
          ],
        ),
      ),
    );
  }
}
