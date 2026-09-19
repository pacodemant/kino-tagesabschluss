# E2E-Test der Web-App (Playwright)

Spielt die **gebaute Web-App** im echten Chrome durch, wie ein Mitarbeiter am
Handy (Fenster 390 × 844): komplette Abrechnung Schritt 1 bis 4 mit
Wechselgeldentnahme, danach die Wechselgeldprüfung am selben Tag, am nächsten
Morgen (Browser-Uhr wird verstellt) und nach einem Neuladen (echter
Browser-Speicher). Jeder Schritt wird geprüft, bei einem Fehler bricht der Test
mit Meldung und Screenshot ab.

Ergänzt `flutter test`: die Unit-/Widget-Tests prüfen Regeln und Seiten
einzeln, dieser Test prüft das Zusammenspiel im echten Browser.

## Voraussetzungen

- Node.js (getestet mit v23) und installiertes Google Chrome
- Flutter (zum Bauen der Web-App)

## Ausführen

    flutter build web --release        # im Projektordner
    cd scripts/e2e
    npm install                        # nur beim ersten Mal
    npm test                           # dauert ca. 1,5 Minuten

Optionen:

    node run.js --sichtbar             # Browser sichtbar statt unsichtbar
    node run.js --build=/pfad/zu/web   # anderen Web-Build verwenden
    E2E_BROWSER=chromium npm test      # Playwrights eigenes Chromium statt Chrome
                                       # (vorher: npx playwright install chromium)

Die Screenshots der Schritte liegen danach in `scripts/e2e/output/`
(nicht im Git).

## Wie es funktioniert

Flutter Web zeichnet auf ein Canvas. Bedienbar wird die App über die
Semantik-Ebene (versteckte DOM-Knoten `<flt-semantics>` mit Text). `lib.js`
schaltet sie ein, klickt Knoten per Text und liest den Seitentext zum Prüfen.

Textfelder sind darin nicht als klickbare Knoten vorhanden. Dafür stehen
Klickpunkte in `KLICK` (oben in `szenario_wechselgeldentnahme.js`), gültig für
das feste Fenster. Ändert sich das Layout, schlägt die nächste Prüfung fehl;
dann die Punkte anhand eines Screenshots neu bestimmen.

## Grenzen

- Desktop-Chrome in Handy-Größe, kein echtes Android-Gerät (Tastatur und Touch
  verhalten sich anders).
- Kein Versand an Flurbocash: im frischen Browser ist nichts konfiguriert,
  "Senden" speichert nur lokal.
- Testdaten gelten für den Standort Schauburg mit Wechselgeld-Sollwert 1.400 €
  aus der Konfiguration. Ändert sich der Sollwert, die Zahlen im Szenario
  anpassen.
- Nicht abgedeckt: Beleg-Foto, Getränke, Verlauf, Kupfermünzen mit Werten,
  Ablauf über Mitternacht (0 bis 5 Uhr; das prüfen die Seiten-Tests).

## Neues Szenario

Datei `szenario_….js` anlegen (Vorlage: `szenario_wechselgeldentnahme.js`) und
in `run.js` in `SZENARIEN` eintragen.
