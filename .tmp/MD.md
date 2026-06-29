Claude Code-Bericht Run 275a5

Geänderte Dateien:
  lib/widgets/beleg_scan_gegenpruef_dialog.dart
    – Komplett neu als StatelessWidget ohne Edit-Modus
    – Alle Controller, FocusNodes, Edit-Flags, Edit-Methoden entfernt
    – Nur noch Anzeige-Branch in _baueMetadatenZeile / _baueZahlungsartZeile / _baueGesamtZeile
    – „Übernehmen" gibt widget.ergebnis direkt zurück, immer aktiv (kein _kannUebernehmen)
    – Tipp-Text mit fettem „Übernehmen" über der Button-Row eingefügt

  lib/pages/tagesabschluss_schritt2_seite.dart
    C) _loescheKartenDaten()-Aufruf + felderGeloescht-Flag aus _starteEcBelegScan() entfernt
    D) _ecKachelAufgeklappt initial false; nach Scan immer true; _ladeEntwurf öffnet Kachel
       wenn Scan, Beleg oder Label vorhanden
    E) _istZeileImplausibel: leere Zeile (beide null) gibt sofort false zurück
    F) „manuell eingeben"-Link aus Expanded herausgelöst; steht jetzt als Spacer-Sibling
       direkt vor dem Foto-Button; sichtbar wenn !aufgeklappt && !scan && ecGesamt == 0
    G) FocusNodes (anzahlFocusNode, betragFocusNode) in _ZahlungsartZeile hinzugefügt;
       Listener in ZahlungsartenConfigService.laden(); _baueKartenartenZeile nutzt sie;
       _baueZahlungsartenTabelle gatet alle drei Warnungen hinter !kartenartenHatFokus;
       summePasstNicht-Text auf Anforderungstext geändert

  lib/pages/startmenue_seite.dart + kinoauswahl_seite.dart
    – Versionsstring auf r275a5 aktualisiert

  CHANGELOG.md – Run 275a5 eingetragen

Manuelle Testschritte:

1. EC-Kachel startet zugeklappt
   → Schritt 2 öffnen → EC-Kachel ist zugeklappt, „EC-Belege" + „manuell eingeben oder: " + 📷 sichtbar
   Erwartet: kein aufgeklappter Inhalt beim ersten Laden

2. Kachel nach Scan öffnet
   → Foto aufnehmen → Dialog bestätigen → Kachel ist danach aufgeklappt
   Erwartet: aufgeklappte Kachel mit befüllten Feldern

3. „manuell eingeben"-Link öffnet Kachel und fokussiert Terminal-ID
   → Link antippen → Kachel öffnet, Cursor im Terminal-ID-Feld
   Erwartet: kein Datenverlust, kein Scan-Löschen

4. Prüf-Popup zeigt nur Anzeige, kein Edit-Modus
   → Scan starten → Prüf-Popup → keine „manuell editieren"-Links sichtbar
   → „Übernehmen" sofort aktiv (auch bei unlesbaren Feldern)
   → Tipp-Text mit fettem „Übernehmen" über den Buttons

5. Bug-Fix: „Fertig." nicht blockiert bei leerer Zeile
   → Scan mit z.B. nur girocard → andere Kartenarten leer lassen
   → „Fertig."-Link drücken → kein Blockieren
   Erwartet: Fertig. funktioniert, leere Zeilen = kein Vorgang = OK

6. Warnungen erst nach Fokus-Verlust
   → Kartenarten-Felder befüllen → solange Fokus im Feld, keine Mismatch-Warnung
   → Feld verlassen → Warnung erscheint (falls Summe nicht passt)

7. Kein Datenlöschen beim Foto-Tippen
   → Felder manuell befüllt, dann Foto-Button → bereits eingetragene Daten bleiben
   (außer der Dialog übernimmt neue Werte)

Status flutter analyze: ✅ No issues found

Status flutter test: keine Tests vorhanden

Letzter Commit-Hash: 2430580 — Run 275a5, vom User vorgegeben

Bestätigung:
  .dev/run_counter.txt: nicht erhöht (Sub-Run)
  CHANGELOG.md: ✅ aktualisiert
  TODO.md: kein Punkt durch diesen Sub-Run direkt abgehakt
