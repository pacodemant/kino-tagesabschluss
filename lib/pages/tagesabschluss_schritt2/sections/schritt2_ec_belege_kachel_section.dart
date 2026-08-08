import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

// Zweck: Rendert die komplette EC-Belege-Kachel (Header mit Aufklapp-
// Toggle/Scan-Button/Löschen-Button/Zusammenfassung sowie den
// aufklappbaren Body-Rahmen mit Leerzustand-Hinweis bzw.
// "Weiteren Beleg hinzufügen"-Button). Der eigentliche Beleg-Inhalt
// (1-Beleg-Modus oder Sub-Kacheln im 2+-Beleg-Modus) wird als fertiges
// Widget durchgereicht (belegInhalt).
class Schritt2EcBelegeKachelSection extends StatelessWidget {
  const Schritt2EcBelegeKachelSection({
    super.key,
    required this.aufgeklappt,
    required this.onToggleAufgeklappt,
    required this.zeigeManuellEingebenLink,
    required this.onManuellEingebenTap,
    required this.scanLaeuft,
    required this.hatEcBelege,
    required this.belegeWithData,
    required this.ecGesamtCent,
    required this.onScanStarten,
    required this.onKartenDatenLoeschen,
    required this.belegdatenBearbeitenRecognizer,
    required this.onBelegdatenBearbeitenTap,
    required this.onEcBelegHinzufuegen,
    required this.belegInhalt,
  });

  final bool aufgeklappt;
  final VoidCallback onToggleAufgeklappt;
  final bool zeigeManuellEingebenLink;
  final VoidCallback onManuellEingebenTap;
  final bool scanLaeuft;
  final bool hatEcBelege;
  final int belegeWithData;
  final int ecGesamtCent;
  final VoidCallback onScanStarten;
  final VoidCallback onKartenDatenLoeschen;
  final TapGestureRecognizer belegdatenBearbeitenRecognizer;
  final VoidCallback onBelegdatenBearbeitenTap;
  final VoidCallback onEcBelegHinzufuegen;
  final Widget belegInhalt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header
          InkWell(
            onTap: onToggleAufgeklappt,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: Row(
                children: <Widget>[
                  const Text(
                    'EC-Belege',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (zeigeManuellEingebenLink)
                    GestureDetector(
                      onTap: onManuellEingebenTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'manuell eingeben',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppFarben.appBarRot,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const Text(
                              ' oder: ',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (scanLaeuft)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        'in Arbeit …',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  if (hatEcBelege)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${belegeWithData == 1 ? '1 Beleg' : '$belegeWithData Belege'} / ${TagesabschlussFormatierung.formatiereEuro(ecGesamtCent)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppFarben.appBarRot,
                        ),
                      ),
                    ),
                  if (!hatEcBelege)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppFarben.fokusFarbe,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppFarben.fokusFarbe,
                        disabledForegroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: scanLaeuft ? null : onScanStarten,
                      child: scanLaeuft
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.camera_alt_outlined, size: 20),
                    ),
                  if (hatEcBelege) ...<Widget>[
                    const SizedBox(width: 2),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        tooltip: 'Kartendaten löschen',
                        padding: EdgeInsets.zero,
                        onPressed: onKartenDatenLoeschen,
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppFarben.appBarRot,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(aufgeklappt ? Icons.expand_less : Icons.expand_more),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          if (aufgeklappt) ...<Widget>[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (!hatEcBelege)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                          children: <InlineSpan>[
                            const TextSpan(
                              text:
                                  'Beleg fehlt oder ist '
                                  'unlesbar? Fehlende Felder '
                                  'unten einfach manuell '
                                  'eintragen. Tippe auf ',
                            ),
                            TextSpan(
                              text: 'Belegdaten bearbeiten',
                              style: const TextStyle(
                                color: AppFarben.appBarRot,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: belegdatenBearbeitenRecognizer
                                ..onTap = onBelegdatenBearbeitenTap,
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  if (hatEcBelege)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        onPressed: scanLaeuft ? null : onEcBelegHinzufuegen,
                        child: const Text('+ Weiteren Beleg hinzufügen'),
                      ),
                    ),
                  belegInhalt,
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
