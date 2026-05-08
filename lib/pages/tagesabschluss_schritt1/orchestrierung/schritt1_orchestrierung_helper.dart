import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/usecases/kassenstand_entwurf_usecase.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';

// Zweck: Bündelt Orchestrierungs-, Navigations- und DevTools-Helfer für Schritt 1.
class Schritt1OrchestrierungHelper {
  const Schritt1OrchestrierungHelper();

  int zufallszahl(Random zufall, int min, int max) {
    return min + zufall.nextInt(max - min + 1);
  }

  void autoFillDev({
    required Random zufall,
    required List<Kassenzeile> scheine,
    required List<Kassenzeile> rollenSichtbar,
    required List<Kassenzeile> loseMuenzarten,
    required Map<String, int> stueckzahlen,
    required Map<String, int> loseMuenzenNachArtCent,
    required void Function(List<UmschlagEintrag> umschlaege)
    uebernehmeUmschlagEntwurf,
    required VoidCallback sichereMindestensEinenUmschlag,
    required VoidCallback synchronisiereControllerAusState,
  }) {
    stueckzahlen['note_100'] = 0;
    stueckzahlen['note_50']  = 8;
    stueckzahlen['note_20']  = 4;
    stueckzahlen['note_10']  = 29;
    stueckzahlen['note_5']   = 13;
    stueckzahlen['roll_2e']  = 0;
    stueckzahlen['roll_1e']  = 0;
    stueckzahlen['roll_50c'] = 1;
    stueckzahlen['roll_20c'] = 1;
    stueckzahlen['roll_10c'] = 1;
    stueckzahlen['roll_5c']  = 0;
    stueckzahlen['roll_2c']  = 0;
    stueckzahlen['roll_1c']  = 0;

    loseMuenzenNachArtCent['coin_2e']  = 3800;
    loseMuenzenNachArtCent['coin_1e']  = 2500;
    loseMuenzenNachArtCent['coin_50c'] = 700;
    loseMuenzenNachArtCent['coin_20c'] = 40;
    loseMuenzenNachArtCent['coin_10c'] = 50;
    loseMuenzenNachArtCent['coin_5c']  = 0;
    loseMuenzenNachArtCent['coin_2c']  = 0;
    loseMuenzenNachArtCent['coin_1c']  = 0;

    uebernehmeUmschlagEntwurf(<UmschlagEintrag>[]);
    sichereMindestensEinenUmschlag();
    synchronisiereControllerAusState();
  }

  void leereAlleFelder({
    required List<Kassenzeile> alleStueckzahlZeilen,
    required List<Kassenzeile> loseMuenzarten,
    required Map<String, int> stueckzahlen,
    required Map<String, int> loseMuenzenNachArtCent,
    required VoidCallback leereUmschlagFelder,
    required VoidCallback sichereMindestensEinenUmschlag,
    required VoidCallback synchronisiereControllerAusState,
  }) {
    for (final Kassenzeile zeile in alleStueckzahlZeilen) {
      stueckzahlen[zeile.id] = 0;
    }
    for (final Kassenzeile zeile in loseMuenzarten) {
      loseMuenzenNachArtCent[zeile.id] = 0;
    }
    leereUmschlagFelder();
    sichereMindestensEinenUmschlag();
    synchronisiereControllerAusState();
  }

  Widget baueDevToolsPanel({
    required VoidCallback autoFillDev,
    required VoidCallback leereAlleFelderDev,
  }) {
    return Card(
      color: const Color(0xFFFFF8E1),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'DEV-Tools (nur Debug/Profile)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton(
              onPressed: autoFillDev,
              child: const Text('Auto-Fill'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: leereAlleFelderDev,
              child: const Text('Alles leeren'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> bestaetigeUndLeereEingaben({
    required BuildContext context,
    required bool Function() isMounted,
    required VoidCallback unfocus,
    required void Function(VoidCallback callback) mutateState,
    required VoidCallback resetStateData,
    required Future<void> Function() speichereEntwurf,
  }) async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogKontext) {
        return AlertDialog(
          title: const Text('Eingaben wirklich löschen?'),
          content: const Text(
            'Alle Eingaben in Schritt 1 werden zurückgesetzt.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogKontext).pop(false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogKontext).pop(true),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );

    if (bestaetigt != true || !isMounted()) {
      return;
    }
    unfocus();
    mutateState(resetStateData);
    await speichereEntwurf();
  }

  Future<void> weiterZuSchritt2({
    required BuildContext context,
    required KassenstandEntwurfUsecase usecase,
    required int kassenbestandGesamtCent,
    required Future<void> Function() speichereEntwurf,
    required bool Function() isMounted,
    required VoidCallback navigiereZuSchritt2,
  }) async {
    if (usecase.bestaetigungNoetigFuerNullbetrag(kassenbestandGesamtCent)) {
      final bool? bestaetigt = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogKontext) {
          return AlertDialog(
            title: const Text('0 € übernehmen?'),
            content: const Text(
              'Es wurde noch kein Betrag erfasst. Willst du mit 0 € fortfahren?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogKontext).pop(false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogKontext).pop(true),
                child: const Text('Fortfahren'),
              ),
            ],
          );
        },
      );

      if (bestaetigt != true) {
        return;
      }
    }

    await speichereEntwurf();
    if (!isMounted()) {
      return;
    }
    navigiereZuSchritt2();
  }

  Future<void> zeigeSchrittAuswahlBottomSheet({
    required BuildContext context,
    required Future<void> Function() weiterZuSchritt2,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text(
                  '1/4 · Bargeldzählung',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Aktueller Schritt'),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.arrow_forward),
                title: const Text('2/4 · Einnahmen/Abschluss'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  weiterZuSchritt2();
                },
              ),
              const ListTile(title: Text('3/4 · Finalisieren'), enabled: false),
              const ListTile(title: Text('4/4 · Schritt 4'), enabled: false),
            ],
          ),
        );
      },
    );
  }
}
