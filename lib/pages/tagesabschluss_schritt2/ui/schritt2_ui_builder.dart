import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2/models/zahlungsart_zeile.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/eingabefeld_clear_helper.dart';

class Schritt2EingabeZeile extends StatelessWidget {
  const Schritt2EingabeZeile({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.focusNode,
    required this.textInputActionErmitteln,
    required this.beiEingabeAbgeschlossen,
    this.fehlermeldungText,
    this.optional = false,
    this.zeigeLoeschen = false,
    this.onLoeschen,
    this.farbeNachWert,
    this.zeigeLabel = true,
    this.zeigeAdditionsButton = true,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FocusNode focusNode;
  final TextInputAction Function(FocusNode focusNode) textInputActionErmitteln;
  final void Function(FocusNode focusNode) beiEingabeAbgeschlossen;
  final String? fehlermeldungText;
  final bool optional;
  final bool zeigeLoeschen;
  final VoidCallback? onLoeschen;
  final int? farbeNachWert;
  final bool zeigeLabel;
  final bool zeigeAdditionsButton;

  @override
  Widget build(BuildContext context) {
    // Ohne Label: nur das Eingabefeld zurückgeben (Breite kommt vom Eltern-Widget).
    if (!zeigeLabel) {
      return BetragCentEingabefeld(
        textController: controller,
        focusNode: focusNode,
        textInputAction: textInputActionErmitteln(focusNode),
        onSubmitted: (_) => beiEingabeAbgeschlossen(focusNode),
        onChanged: onChanged,
        schriftgroesse: 15,
        hinweisText: '0,00 €',
        fehlermeldungText: fehlermeldungText,
        farbeNachWert: farbeNachWert,
        mitKomma: false,
        zeigeAdditionsButton: zeigeAdditionsButton,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              optional ? '$label (optional)' : label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 190,
            child: BetragCentEingabefeld(
              textController: controller,
              focusNode: focusNode,
              textInputAction: textInputActionErmitteln(focusNode),
              onSubmitted: (_) => beiEingabeAbgeschlossen(focusNode),
              onChanged: onChanged,
              schriftgroesse: 15,
              hinweisText: '0,00 €',
              fehlermeldungText: fehlermeldungText,
              farbeNachWert: farbeNachWert,
              mitKomma: false,
              zeigeAdditionsButton: zeigeAdditionsButton,
            ),
          ),
          if (zeigeLoeschen) ...<Widget>[
            const SizedBox(width: 6),
            IconButton(
              onPressed: onLoeschen,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'EC-Beleg entfernen',
            ),
          ],
        ],
      ),
    );
  }
}

class Schritt2MetadatenInfoZeile extends StatelessWidget {
  const Schritt2MetadatenInfoZeile({
    super.key,
    required this.label,
    required this.wert,
  });

  final String label;
  final String? wert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppFarben.subtilerText),
            ),
          ),
          Expanded(
            child: wert != null
                ? Text(wert!, style: const TextStyle(fontSize: 13))
                : Text(
                    'nicht verfügbar',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class Schritt2MetadatenEditZeile extends StatelessWidget {
  const Schritt2MetadatenEditZeile({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppFarben.subtilerText),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                filled: focusNode.hasFocus,
                fillColor: const Color(0xFFFFF8E1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                  maxWidth: 28,
                  maxHeight: 28,
                ),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.clear,
                            size: 16, color: clearIconFarbe(focusNode.hasFocus)),
                        onPressed: baueClearAktion(
                          controller: controller,
                          onChanged: onChanged,
                          focusNode: focusNode,
                        ),
                      ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Zweck: Rendert den auf-/zuklappbaren Scan-Metadaten-Block (Datum, Uhrzeit,
// Beleg-Nr. von/bis) eines EC-Belegs, wahlweise als reine Anzeige oder editierbar.
class Schritt2MetadatenBlock extends StatelessWidget {
  const Schritt2MetadatenBlock({
    super.key,
    required this.aufgeklappt,
    required this.nurAnzeige,
    required this.onToggleAufgeklappt,
    required this.onToggleNurAnzeige,
    required this.scanDatum,
    required this.scanUhrzeit,
    required this.scanBelegNrVon,
    required this.scanBelegNrBis,
    required this.scanDatumController,
    required this.scanUhrzeitController,
    required this.scanBelegNrVonController,
    required this.scanBelegNrBisController,
    required this.scanDatumFocusNode,
    required this.scanUhrzeitFocusNode,
    required this.scanBelegNrVonFocusNode,
    required this.scanBelegNrBisFocusNode,
    required this.onDatumGeaendert,
    required this.onUhrzeitGeaendert,
    required this.onBelegNrVonGeaendert,
    required this.onBelegNrBisGeaendert,
  });

  final bool aufgeklappt;
  final bool nurAnzeige;
  final VoidCallback onToggleAufgeklappt;
  final VoidCallback onToggleNurAnzeige;
  final String? scanDatum;
  final String? scanUhrzeit;
  final String? scanBelegNrVon;
  final String? scanBelegNrBis;
  final TextEditingController scanDatumController;
  final TextEditingController scanUhrzeitController;
  final TextEditingController scanBelegNrVonController;
  final TextEditingController scanBelegNrBisController;
  final FocusNode scanDatumFocusNode;
  final FocusNode scanUhrzeitFocusNode;
  final FocusNode scanBelegNrVonFocusNode;
  final FocusNode scanBelegNrBisFocusNode;
  final ValueChanged<String> onDatumGeaendert;
  final ValueChanged<String> onUhrzeitGeaendert;
  final ValueChanged<String> onBelegNrVonGeaendert;
  final ValueChanged<String> onBelegNrBisGeaendert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleAufgeklappt,
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Scan-Metadaten',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppFarben.subtilerText,
                    ),
                  ),
                ),
                if (aufgeklappt)
                  TextButton(
                    onPressed: onToggleNurAnzeige,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      nurAnzeige ? 'Metadaten bearbeiten' : 'Fertig.',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                Icon(
                  aufgeklappt ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: AppFarben.subtilerText,
                ),
              ],
            ),
          ),
          if (aufgeklappt) ...<Widget>[
            const SizedBox(height: 4),
            if (nurAnzeige) ...<Widget>[
              Schritt2MetadatenInfoZeile(label: 'Datum', wert: scanDatum),
              Schritt2MetadatenInfoZeile(label: 'Uhrzeit', wert: scanUhrzeit),
              Schritt2MetadatenInfoZeile(
                  label: 'Beleg-Nr. von', wert: scanBelegNrVon),
              Schritt2MetadatenInfoZeile(
                  label: 'Beleg-Nr. bis', wert: scanBelegNrBis),
            ] else ...<Widget>[
              Schritt2MetadatenEditZeile(
                label: 'Datum',
                controller: scanDatumController,
                focusNode: scanDatumFocusNode,
                onChanged: onDatumGeaendert,
              ),
              Schritt2MetadatenEditZeile(
                label: 'Uhrzeit',
                controller: scanUhrzeitController,
                focusNode: scanUhrzeitFocusNode,
                onChanged: onUhrzeitGeaendert,
              ),
              Schritt2MetadatenEditZeile(
                label: 'Beleg-Nr. von',
                controller: scanBelegNrVonController,
                focusNode: scanBelegNrVonFocusNode,
                onChanged: onBelegNrVonGeaendert,
              ),
              Schritt2MetadatenEditZeile(
                label: 'Beleg-Nr. bis',
                controller: scanBelegNrBisController,
                focusNode: scanBelegNrBisFocusNode,
                onChanged: onBelegNrBisGeaendert,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class Schritt2KartenartenZeile extends StatelessWidget {
  const Schritt2KartenartenZeile({
    super.key,
    required this.zeile,
    required this.istImplausibel,
    required this.dropdownOptionen,
    required this.onNameGeaendert,
    required this.onBetragGeaendert,
  });

  final ZahlungsartZeile zeile;
  final bool istImplausibel;
  final List<String> dropdownOptionen;
  final ValueChanged<String?> onNameGeaendert;
  final ValueChanged<String> onBetragGeaendert;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder? roteBorder = istImplausibel
        ? OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade300),
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: zeile.istUnbekannt
                ? DropdownButton<String?>(
                    value: zeile.name.isEmpty ? null : zeile.name,
                    hint: const Text(
                      'Kartenart?',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    isExpanded: true,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    items: dropdownOptionen
                        .map((String n) => DropdownMenuItem<String?>(
                              value: n,
                              child: Text(n),
                            ))
                        .toList(),
                    onChanged: onNameGeaendert,
                  )
                : Text(
                    zeile.name,
                    style: const TextStyle(fontSize: 13),
                  ),
          ),
          SizedBox(
            width: 104,
            child: TextField(
              controller: zeile.betragController,
              focusNode: zeile.betragFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                CentWaehrungsEingabeFormatter(),
              ],
              textAlign: TextAlign.right,
              cursorColor: zeile.betragFocusNode.hasFocus ? Colors.black : null,
              style: TextStyle(
                fontSize: 13,
                color: zeile.betragFocusNode.hasFocus ? Colors.black : null,
              ),
              decoration: InputDecoration(
                hintText: '0,00',
                isDense: true,
                filled: zeile.betragFocusNode.hasFocus,
                fillColor:
                    zeile.betragFocusNode.hasFocus ? AppFarben.fokusFarbe : null,
                border: const OutlineInputBorder(),
                enabledBorder: roteBorder,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                  maxWidth: 24,
                  maxHeight: 24,
                ),
                suffixIcon: zeile.betragController.text.isEmpty
                    ? null
                    : IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.clear,
                          size: 14,
                          color: clearIconFarbe(zeile.betragFocusNode.hasFocus),
                        ),
                        onPressed: baueClearAktion(
                          controller: zeile.betragController,
                          onChanged: onBetragGeaendert,
                          focusNode: zeile.betragFocusNode,
                        ),
                      ),
              ),
              onChanged: onBetragGeaendert,
            ),
          ),
        ],
      ),
    );
  }
}

class Schritt2KartenartenZeileAnzeige extends StatelessWidget {
  const Schritt2KartenartenZeileAnzeige({
    super.key,
    required this.zeile,
    required this.istImplausibel,
  });

  final ZahlungsartZeile zeile;
  final bool istImplausibel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: zeile.istUnbekannt && zeile.name.isEmpty
                ? const Text(
                    '?',
                    style: TextStyle(fontSize: 13, color: Colors.red),
                  )
                : Text(
                    zeile.name,
                    style: const TextStyle(fontSize: 13),
                  ),
          ),
          SizedBox(
            width: 104,
            child: Text(
              zeile.betragCentWert != null
                  ? TagesabschlussFormatierung.formatiereEuro(
                      zeile.betragCentWert!)
                  : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: istImplausibel ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Schritt2KartenartenEditButton extends StatelessWidget {
  const Schritt2KartenartenEditButton({
    super.key,
    required this.editModus,
    required this.onToggle,
  });

  final bool editModus;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: onToggle,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 28),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            editModus ? 'Fertig.' : 'Belegdaten bearbeiten',
            style: const TextStyle(
                fontSize: 11, decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }
}

// Zweck: Rendert die komplette Kartenarten-Tabelle eines EC-Belegs
// (Kartenart-Zeilen, "+"-Chips fuer noch nicht zugeordnete gescannte Arten,
// Gesamt-Betrag-Zeile mit Plausibilitaets-Hinweisen, Bearbeiten-Button).
class Schritt2ZahlungsartenTabelle extends StatelessWidget {
  const Schritt2ZahlungsartenTabelle({
    super.key,
    required this.zeilen,
    required this.editModus,
    required this.wurdeGescannt,
    required this.gesamtBetragCent,
    required this.tabellenSummeCent,
    required this.summePasstNicht,
    required this.betragMismatch,
    required this.kartenartenHatFokus,
    required this.gesamtBetragHatFokus,
    required this.irgendEineZeileInkonsistent,
    required this.gesamtBetragController,
    required this.gesamtBetragFocusNode,
    required this.gesamtBetragErrorText,
    required this.zeigeKartenartenEditButton,
    required this.istZeileImplausibel,
    required this.dropdownOptionenFuerZeile,
    required this.istBereitsAlsUnbekannteZugeordnet,
    required this.onZeileNameGeaendert,
    required this.onZeileBetragGeaendert,
    required this.onZeileAktivieren,
    required this.onGesamtBetragGeaendert,
    required this.onEditButtonToggle,
  });

  final List<ZahlungsartZeile> zeilen;
  final bool editModus;
  final bool wurdeGescannt;
  final int? gesamtBetragCent;
  final int tabellenSummeCent;
  final bool summePasstNicht;
  final bool betragMismatch;
  final bool kartenartenHatFokus;
  final bool gesamtBetragHatFokus;
  final bool irgendEineZeileInkonsistent;
  final TextEditingController gesamtBetragController;
  final FocusNode? gesamtBetragFocusNode;
  final String? gesamtBetragErrorText;
  final bool zeigeKartenartenEditButton;
  final bool Function(ZahlungsartZeile zeile) istZeileImplausibel;
  final List<String> Function(int zeileIndex) dropdownOptionenFuerZeile;
  final bool Function(String name) istBereitsAlsUnbekannteZugeordnet;
  final void Function(ZahlungsartZeile zeile, String? wert) onZeileNameGeaendert;
  final void Function(ZahlungsartZeile zeile, String wert) onZeileBetragGeaendert;
  final void Function(ZahlungsartZeile zeile) onZeileAktivieren;
  final ValueChanged<String> onGesamtBetragGeaendert;
  final VoidCallback onEditButtonToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: const <Widget>[
                Expanded(
                  child: Text(
                    'Kartenart',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppFarben.subtilerText,
                    ),
                  ),
                ),
                SizedBox(
                  width: 104,
                  child: Text(
                    'Betrag',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppFarben.subtilerText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < zeilen.length; i++)
            if (zeilen[i].zustand != ZeilenZustand.hidden)
              zeilen[i].zustand == ZeilenZustand.editing
                  ? Schritt2KartenartenZeile(
                      zeile: zeilen[i],
                      istImplausibel: istZeileImplausibel(zeilen[i]),
                      dropdownOptionen: dropdownOptionenFuerZeile(i),
                      onNameGeaendert: (String? wert) =>
                          onZeileNameGeaendert(zeilen[i], wert),
                      onBetragGeaendert: (String wert) =>
                          onZeileBetragGeaendert(zeilen[i], wert),
                    )
                  : Schritt2KartenartenZeileAnzeige(
                      zeile: zeilen[i],
                      istImplausibel: istZeileImplausibel(zeilen[i]),
                    ),
          if (wurdeGescannt &&
              zeilen.any((ZahlungsartZeile z) =>
                  z.zustand == ZeilenZustand.hidden &&
                  !istBereitsAlsUnbekannteZugeordnet(z.name)))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (final ZahlungsartZeile zeile in zeilen)
                    if (zeile.zustand == ZeilenZustand.hidden &&
                        !istBereitsAlsUnbekannteZugeordnet(zeile.name))
                      TextButton.icon(
                        onPressed: () => onZeileAktivieren(zeile),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 0),
                          minimumSize: const Size(0, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.add, size: 14),
                        label: Text(
                          zeile.name,
                          style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                ],
              ),
            ),
          const Divider(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      wurdeGescannt ? 'Gesamt (laut Beleg)' : 'Gesamt',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Hilfe',
                        icon: Icon(Icons.help_outline,
                            size: 16, color: Colors.grey.shade600),
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext ctx) => AlertDialog(
                              title: const Text('Gesamtbetrag'),
                              content: const Text(
                                'Die Gesamtsumme wird nicht automatisch berechnet, '
                                'sondern muss selbst eingegeben werden. Sie dient '
                                'der Kontrolle, ob alle Beträge korrekt erfasst '
                                'wurden.',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 104,
                child: !editModus
                    ? Text(
                        gesamtBetragCent != null
                            ? TagesabschlussFormatierung.formatiereEuro(
                                gesamtBetragCent!)
                            : '—',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      )
                    : TextField(
                        controller: gesamtBetragController,
                        focusNode: gesamtBetragFocusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          CentWaehrungsEingabeFormatter(),
                        ],
                        textAlign: TextAlign.right,
                        cursorColor: gesamtBetragHatFokus ? Colors.black : null,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: gesamtBetragHatFokus ? Colors.black : null,
                        ),
                        decoration: InputDecoration(
                          hintText: '0,00',
                          isDense: true,
                          filled: gesamtBetragHatFokus,
                          fillColor: gesamtBetragHatFokus
                              ? AppFarben.fokusFarbe
                              : null,
                          border: const OutlineInputBorder(),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          errorText: gesamtBetragErrorText,
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                            maxWidth: 24,
                            maxHeight: 24,
                          ),
                          suffixIcon: gesamtBetragController.text.isEmpty
                              ? null
                              : IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.clear,
                                    size: 14,
                                    color: clearIconFarbe(gesamtBetragHatFokus),
                                  ),
                                  onPressed: baueClearAktion(
                                    controller: gesamtBetragController,
                                    onChanged: onGesamtBetragGeaendert,
                                    focusNode: gesamtBetragFocusNode,
                                  ),
                                ),
                        ),
                        onChanged: onGesamtBetragGeaendert,
                      ),
              ),
            ],
          ),
          if (betragMismatch && !kartenartenHatFokus && !irgendEineZeileInkonsistent)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Hinweis: Summe der Beträge stimmt nicht mit der erfassten '
                'Gesamtsumme überein.',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
            ),
          if (summePasstNicht &&
              !betragMismatch &&
              !kartenartenHatFokus &&
              !irgendEineZeileInkonsistent)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Hinweis: Kartensumme stimmt nicht mit dem eingetragenen '
                'EC-Gesamtbetrag überein.',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
            ),
          if (zeigeKartenartenEditButton)
            Schritt2KartenartenEditButton(
              editModus: editModus,
              onToggle: onEditButtonToggle,
            ),
        ],
      ),
    );
  }
}
