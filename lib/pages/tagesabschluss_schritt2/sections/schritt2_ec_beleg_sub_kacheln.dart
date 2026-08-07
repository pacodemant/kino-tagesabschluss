import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

// Zweck: Rendert die Liste der EC-Beleg-Sub-Kacheln im 2+-Beleg-Modus
// (eine aufklappbare Kachel je Beleg mit Terminal-ID, Scan-/Löschen-
// Button im Titel sowie Zahlungsarten-Tabelle/Metadaten-Block im
// aufklappbaren Body).
class Schritt2EcBelegSubKacheln extends StatelessWidget {
  const Schritt2EcBelegSubKacheln({
    super.key,
    required this.belegAnzahl,
    required this.belegIds,
    required this.aufgeklapptListe,
    required this.onToggleAufgeklappt,
    required this.editModusListe,
    required this.scanBelegIndex,
    required this.labelController,
    required this.labelFocusNode,
    required this.labels,
    required this.betraegeCent,
    required this.tidUnleserlich,
    required this.scanLaeuft,
    required this.onScanStarten,
    required this.onTidGeaendert,
    required this.onBestaetigtEntfernen,
    required this.hatZahlungsartZeilen,
    required this.hatScanStattgefunden,
    required this.baueZahlungsartenTabelle,
    required this.baueMetadatenBlock,
    required this.onManuellBearbeitenAktivieren,
    required this.onFertig,
  });

  final int belegAnzahl;
  final List<int> belegIds;
  final List<bool> aufgeklapptListe;
  final void Function(int belegIndex) onToggleAufgeklappt;
  final List<bool> editModusListe;
  final int? scanBelegIndex;
  final List<TextEditingController> labelController;
  final List<FocusNode> labelFocusNode;
  final List<String> labels;
  final List<int> betraegeCent;
  final bool Function(int belegIndex) tidUnleserlich;
  final bool scanLaeuft;
  final void Function(int belegIndex) onScanStarten;
  final void Function(int belegIndex, String wert) onTidGeaendert;
  final void Function(int belegIndex) onBestaetigtEntfernen;
  final bool Function(int belegIndex) hatZahlungsartZeilen;
  final bool Function(int belegIndex) hatScanStattgefunden;
  final Widget Function(int belegIndex) baueZahlungsartenTabelle;
  final Widget Function(int belegIndex) baueMetadatenBlock;
  final void Function(int belegIndex) onManuellBearbeitenAktivieren;
  final void Function(int belegIndex) onFertig;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = belegAnzahl - 1; i >= 0; i--)
          KeyedSubtree(
            key: ValueKey<int>(belegIds[i]),
            child: _Schritt2EcBelegSubKachel(
              belegIndex: i,
              aufgeklappt: aufgeklapptListe[i],
              onToggleAufgeklappt: () => onToggleAufgeklappt(i),
              editModus: editModusListe[i],
              zeigtScanLaufend: scanBelegIndex == i,
              labelController: labelController[i],
              labelFocusNode: labelFocusNode[i],
              label: labels[i],
              betragCent: betraegeCent[i],
              tidUnleserlich: tidUnleserlich(i),
              scanLaeuft: scanLaeuft,
              onScanStarten: () => onScanStarten(i),
              onTidGeaendert: (String wert) => onTidGeaendert(i, wert),
              onLoeschenBestaetigt: () => onBestaetigtEntfernen(i),
              hatZahlungsartZeilen: hatZahlungsartZeilen(i),
              hatScanStattgefunden: hatScanStattgefunden(i),
              baueZahlungsartenTabelle: () => baueZahlungsartenTabelle(i),
              baueMetadatenBlock: () => baueMetadatenBlock(i),
              onManuellBearbeiten: () => onManuellBearbeitenAktivieren(i),
              onFertig: () => onFertig(i),
            ),
          ),
      ],
    );
  }
}

class _Schritt2EcBelegSubKachel extends StatelessWidget {
  const _Schritt2EcBelegSubKachel({
    required this.belegIndex,
    required this.aufgeklappt,
    required this.onToggleAufgeklappt,
    required this.editModus,
    required this.zeigtScanLaufend,
    required this.labelController,
    required this.labelFocusNode,
    required this.label,
    required this.betragCent,
    required this.tidUnleserlich,
    required this.scanLaeuft,
    required this.onScanStarten,
    required this.onTidGeaendert,
    required this.onLoeschenBestaetigt,
    required this.hatZahlungsartZeilen,
    required this.hatScanStattgefunden,
    required this.baueZahlungsartenTabelle,
    required this.baueMetadatenBlock,
    required this.onManuellBearbeiten,
    required this.onFertig,
  });

  final int belegIndex;
  final bool aufgeklappt;
  final VoidCallback onToggleAufgeklappt;
  final bool editModus;
  final bool zeigtScanLaufend;
  final TextEditingController labelController;
  final FocusNode labelFocusNode;
  final String label;
  final int betragCent;
  final bool tidUnleserlich;
  final bool scanLaeuft;
  final VoidCallback onScanStarten;
  final ValueChanged<String> onTidGeaendert;
  final VoidCallback onLoeschenBestaetigt;
  final bool hatZahlungsartZeilen;
  final bool hatScanStattgefunden;
  final Widget Function() baueZahlungsartenTabelle;
  final Widget Function() baueMetadatenBlock;
  final VoidCallback onManuellBearbeiten;
  final VoidCallback onFertig;

  bool get _labelIstLesbarUndBefuellt =>
      label.isNotEmpty && label.trim().toLowerCase() != 'unleserlich';

  Future<void> _beiLoeschenGedrueckt(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Beleg löschen?'),
        content: Text('Beleg ${belegIndex + 1} wirklich löschen?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (!context.mounted) {
      return;
    }
    if (ok == true) {
      onLoeschenBestaetigt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Card(
        elevation: 0,
        color: Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Sub-Kachel-Header
            InkWell(
              onTap: onToggleAufgeklappt,
              borderRadius: aufgeklappt
                  ? const BorderRadius.vertical(top: Radius.circular(8))
                  : BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: zeigtScanLaufend
                          ? Text(
                              'In Arbeit …',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            )
                          : (editModus
                                ? SizedBox(
                                    height: 28,
                                    child: TextField(
                                      controller: labelController,
                                      focusNode: labelFocusNode,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: labelFocusNode.hasFocus
                                            ? Colors.black
                                            : null,
                                      ),
                                      cursorColor: labelFocusNode.hasFocus
                                          ? Colors.black
                                          : null,
                                      decoration: InputDecoration(
                                        hintText: tidUnleserlich
                                            ? 'Terminal-ID?'
                                            : 'Terminal-ID',
                                        hintStyle: TextStyle(
                                          color: labelFocusNode.hasFocus
                                              ? Colors.transparent
                                              : (tidUnleserlich
                                                    ? Colors.red
                                                    : null),
                                        ),
                                        isDense: true,
                                        filled: labelFocusNode.hasFocus,
                                        fillColor: AppFarben.fokusFarbe,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: tidUnleserlich
                                                ? Colors.red.shade700
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: tidUnleserlich
                                                ? Colors.red.shade700
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: tidUnleserlich
                                                ? Colors.red.shade700
                                                : AppFarben.appBarRot,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      onChanged: onTidGeaendert,
                                    ),
                                  )
                                : Text(
                                    _labelIstLesbarUndBefuellt
                                        ? 'Terminal: $label'
                                        : 'Beleg ${belegIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: tidUnleserlich
                                          ? Colors.red.shade700
                                          : (_labelIstLesbarUndBefuellt
                                                ? Colors.black87
                                                : Colors.grey.shade500),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                    ),
                    if (betragCent > 0) ...<Widget>[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          TagesabschlussFormatierung.formatiereEuro(betragCent),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    // Kamera-Button: gefüllt, Kino-Rot
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        tooltip: 'Beleg scannen',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: zeigtScanLaufend
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: (label.isNotEmpty || betragCent > 0)
                                    ? Colors.grey.shade400
                                    : AppFarben.appBarRot,
                              ),
                        onPressed: scanLaeuft ? null : onScanStarten,
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        tooltip: 'Beleg entfernen',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: scanLaeuft
                            ? null
                            : () => _beiLoeschenGedrueckt(context),
                      ),
                    ),
                    Icon(
                      aufgeklappt ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
            // Sub-Kachel-Body
            if (aufgeklappt) ...<Widget>[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Kartendaten: per-Beleg-State
                    if (hatZahlungsartZeilen) ...<Widget>[
                      baueZahlungsartenTabelle(),
                      if (hatScanStattgefunden) baueMetadatenBlock(),
                    ] else if (betragCent > 0 ||
                        (label.isNotEmpty && !tidUnleserlich))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Betrag gespeichert. Für Umsatz-Aufschlüsselung '
                          'Beleg erneut scannen.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Noch kein Beleg – Kamera verwenden.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    // TID-Hinweis wenn unleserlich
                    if (tidUnleserlich)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Terminal-ID konnte nicht gelesen werden – oben '
                          'korrigieren.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    // Manuell bearbeiten / Fertig
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: editModus
                            ? TextButton(
                                onPressed: onFertig,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 28),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Fertig.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: onManuellBearbeiten,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 28),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Belegdaten bearbeiten',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
