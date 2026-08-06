# TODO — kino_bar_app
Stand: August 2026 · Run 341 · wird fortlaufend ergänzt

Erledigte Punkte stehen nicht mehr hier, sondern in TODO_ERLEDIGT.md
(gleiche Abschnittsstruktur) — sie werden bei jedem Run per Read
abgeglichen, daher hält diese Datei nur die offenen Punkte schlank.
Neu erledigte Punkte beim nächsten Archivierungs-Run dorthin verschieben.

---

## 🔴 Blockiert — wartet auf IT (Yannik)

- [ ] **Basis-URL Flurbocash-Server** HTTPS-Adresse der API.
      Sandbox bekannt: https://sandbox.flurbocash.c137-prime.de:666
      (wird aktuell für alle Tests genutzt). Ob das auch die
      Produktiv-URL ist oder Yannik später eine andere gibt: offen.

- [ ] **Registrierte TIDs pro Standort** Welche Terminal-IDs sind in Flurbocash
      für welchen Standort hinterlegt?
      Für SB steht aktuell "54017635" in config/terminal_ids.json — bisher
      nur Annahme, von Yannik noch nicht bestätigt (Stand 2026-07-12).

- [ ] **Terminals bei doppelter TID am selben Tag** Wenn dieselbe
      physische Terminal-ID an einem Tag zweimal abgerechnet wird
      (z. B. zwei EC-Belege desselben Terminals zu unterschiedlichen
      Zeiten), aktuell werden die Kartenbeträge in der App
      stillschweigend zu einer Terminal-Zeile summiert
      (`ApiUploadService._terminalsListe()`). Laut
      `EXTERNAL_API_Schauburg_de.md` scheint die TID der eindeutige
      Schlüssel je Abrechnung zu sein (Korrektur-Calls "upserten"
      Terminals über die TID) — zwei Terminal-Zeilen mit derselben TID
      innerhalb einer Abrechnung würden bei Flurbocash vermutlich
      ohnehin zusammenfallen. Klären: Sollen zwei Vorgänge derselben
      TID am selben Tag (a) weiterhin zu einer Terminal-Zeile summiert
      werden, oder (b) als zwei separate `settlements[]`-Einträge
      übertragen werden (das Format erlaubt bis zu 4 Abrechnungen/Tag,
      siehe auch "Bar Tabak: 2-Settlement-Logik" unten)?

- [ ] **6-Uhr-Knick abstimmen** Welches Datum erwartet Flurbocash für
      Nachtabrechnungen (z. B. 1 Uhr nachts) — Kalendertag oder logischer
      Abrechnungstag (= Vortag)?

- [ ] **Weitere Abrechnungsfelder** Sollen Kino-Soll, Bistro-Soll, Ausgaben,
      Mitarbeitername, Differenz an Flurbocash übermittelt werden — oder holt das
      System sie selbst aus dem Kassensystem?

- [ ] **Konfiguration der Geräte** Wer richtet die Smartphones ein — IT oder MA?
      Wer pflegt Änderungen (neuer API-Key, neue TID)?

- [ ] **Mailversand** Gibt es einen Mailserver/-dienst für die App, oder soll
      die Mail-App des Geräts geöffnet werden (mailto:)?

- [ ] **Stapel-Scanner: Übertragungsformat** Wie sollen gesammelte EC-Belege
      an Flurbocash gehen — einzeln (je ein 2-Call-Flow) oder als Batch?
      Separater Endpunkt oder derselbe wie die Tagesabrechnung?

---

## 🟢 Kleine Fixes (je < 1h, direkt umsetzbar)

- [ ] **Kartensumme ↔ EC-Gesamtbetrag nach manuellem Nachtrag** Seit Run 274f4
      gibt es in der Kartenarten-Tabelle einen "+ Kartenart"-Button zum
      nachträglichen Einblenden nicht erkannter Kartenarten. Klären: wenn der
      Nachtrag die Kartensumme wieder zum EC-Gesamtbetrag (Hauptfeld) passend
      macht, soll dort etwas automatisch nachgezogen werden? Zurückgestellt,
      da bei sauberen Scans kaum relevant.

- [ ] **Kein Screen-Flip** App soll beim Drehen des Smartphones hochkant
      bleiben. Code-seitig vorhanden: `main.dart` sperrt via
      `SystemChrome.setPreferredOrientations` auf `portraitUp`;
      zusätzlich `web/manifest.json` mit `"orientation":
      "portrait-primary"`. Test (Run 319b, Pacos iPhone-PWA): Screen
      flippt trotzdem weiterhin — die Manifest-Sperre wird von iOS/
      WebKit bekanntermaßen unzuverlässig bis gar nicht umgesetzt,
      auch für installierte PWAs. Da Zielplattform vorkonfigurierte
      Android-Geräte sind (dort wird die Manifest-Sperre von Chrome/
      Android zuverlässiger unterstützt): auf einem echten Android-Gerät
      (als installierte PWA) testen, bevor als erledigt gilt. Bleibt bis
      dahin offen. *(getestet Run 319b — iOS bestätigt fehlerhaft)*

---

## 🟡 Mittlere Features (eigenständige Funktionsblöcke)

### BelegScan & EC-Kachel *(Phase A, Runs 275–281)*

- [ ] **Duplikat-Button** Ursprünglich zusätzlich als Dummy-Button im
      Prüf-Popup geplant — Popup existierte zwischen Run 307 und
      Run 318 nicht. Seit Run 318 gibt es wieder ein Prüf-Popup
      (`beleg_scan_bestaetigen_dialog.dart`, anderer Zweck als vor
      Run 307: bewusste Bestätigung vor der Übernahme statt
      Fehlerprüfung) — könnte als Ort in Frage kommen, ist dort
      aber nicht umgesetzt.
      Teilschritt erledigt (Run 319a): Die Fehlermeldung bei
      unscharfem Foto/Netzwerkproblem weist zusätzlich auf die
      manuelle Eingabe hin.
      Teilschritt erledigt (Run 329/329a): Dauerhaft sichtbarer
      Hilfetext im Scan-Bereich ("Beleg fehlt oder ist unlesbar?
      Fehlende Felder unten einfach manuell eintragen. Tippe auf
      Belegdaten bearbeiten.") mit zusätzlichem kursivem Text-Link,
      der auf das Terminal-ID-Feld fokussiert; Hinweis verschwindet
      sobald mind. ein Beleg Daten hat (`hatEcBelege`). Nur der
      Duplikat-Button selbst bleibt offen.

- [ ] **Prüfen-Flag für Buchhaltung** Erst mit IT klären ob gewünscht und
      wie es übermittelt wird (Flurbocash-Feld, E-Mail o. Ä.). Dann einplanen.

- [ ] **Storno auf Belegen** Noch nie vorgekommen, aber die App muss
      Stornos erkennen können.

### Einstellungen & Konfiguration *(Phase C)*

- [x] **Standort-Betriebsmodus (Admin)** Im Verwaltungsbereich einstellbar,
      für welchen Standort das Gerät arbeitet: „Alle" oder ein festes Kino.
      Ist ein einzelner Standort gewählt, entfällt für MA die Kinoauswahl
      UND der Textbutton "Kino wechseln" auf der Startseite wird
      ausgeblendet — er erscheint nur, wenn "Alle" eingestellt ist. Wie
      geplant umgesetzt. Speicherung lokal auf dem Gerät (SharedPreferences,
      kein Backend). Datenschutzhinweise-Link ist seit Run 321 bereits
      zusätzlich auf startmenue_seite.dart vorhanden, bleibt also auch bei
      entfallender Kinoauswahl erreichbar. *(Run 325)*

- [ ] **TID-Whitelist konfigurierbar** Pro Standort in Einstellungen
      editierbar. Prüfung nach BelegScan — Warnung bei unbekannter TID.

- [ ] **Safari-iOS: Lokale Speicherung** Safari löscht localStorage/IndexedDB
      nach 7 Tagen (ITP). Lösung: Warnung bei drohendem Datenverlust oder
      regelmäßiger Export-Hinweis. *(Vorerst zurückgestellt — Zielplattform
      ist Android an allen Standorten, ITP betrifft nur iOS/Safari und damit
      nur Pacos private Testumgebung.)*

### Flurbocash API-Integration *(Phase E — wartet auf IT)*

- [ ] **location_id ins Kino-Modell** Neues Feld in `kino.dart`. Wert kommt von IT.

- [ ] **"Erneut senden" → Korrektur-Call + Max-4-Fehlermeldung**
      `settlement_number: 1` statt neuem Eintrag. Bei `400 "maximum reached"`:
      verständliche Meldung + Textbutton "Info an Buchhaltung senden".
      Nach Tap: Mail an konfigurierte Adresse, Bestätigung "Buchhaltung ist
      informiert — Abrechnung beendet." Setzt CORS-Freigabe voraus.

- [ ] **Buchhaltungs-E-Mail konfigurierbar** Empfängeradresse in Einstellungen.
      Mailmethode abhängig von Yannik-Antwort.

- [ ] **Bar Tabak: 2-Settlement-Logik** Beide Abrechnungen teilen eine
      `report_id`. Zweiter Call muss `settlement_number: 2` setzen.
      Erst relevant wenn BT implementiert wird.

- [ ] **Belegfoto als base64 an Flurbocash** Yannik übernimmt die
      PDF-Wandlung serverseitig, App muss nur base64 mitschicken
      (Konvertierung bereits vorhanden in `BelegScanService.scan()`,
      muss aber bis zum Upload durchgereicht werden — aktuell wird
      das Foto nach der KI-Auswertung verworfen). API-Vertrag
      (Feld/Endpunkt) noch nicht in `EXTERNAL_API_Schauburg_de.md`
      definiert — wartet auf Yannik. Datenschutzhinweise dafür
      bereits vorgezogen angepasst *(Run 319)*.

### Stapel-Scanner *(Phase D/E — wartet auf IT)*

- [ ] **Stapel-Scanner: Seite & Grundstruktur** Eigene Seite im
      Verwaltungsbereich (hinter PIN). MA scannt reihenweise Belege, gespeichert
      wie Verlauf. Nutzt EC-Kachel-Komponente aus Phase A. Senden-Button als Dummy.
      Setzt TID-Whitelist und CORS-Freigabe voraus.

- [ ] **Stapel-Scanner: echter Versand** Dummy-Button durch echten
      Flurbocash-Call ersetzen. Format abhängig von Yannik-Antwort.

### Weitere Features

- [ ] **Gondel-Abrechnung (kino_02)** Workflow wie Schauburg,
      Wechselgeld 1.400 €.

- [ ] **Abschluss-Export (PDF / Teilen)** Tagesabrechnung als PDF oder Text
      per WhatsApp / Mail an Kinoleitung.

---

## 🔴 Größere Umbauten

- [ ] **Bar Tabak (kino_05)** Komplexe Kassenstruktur (Kino-, Bar-, Lotterie-,
      Handy-Kasse; 2 Abschlüsse/Tag). Noch nicht implementiert.
      Startseite: zwei Buttons „1. Abrechnung" und „2. Abrechnung".
      Sicherheitsnetz bereits vorhanden (Run 319a): `Kino.maxAbrechnungenProTag`
      (Standard 1, Bar Tabak 2) verhindert in
      `SpeichereTagesabschlussUsecase`, dass eine zweite Abrechnung am
      selben Tag die erste stillschweigend überschreibt — stattdessen
      Rückfrage "Ersetzen" vs. "Zusätzliche Abrechnung". Ersetzt NICHT
      die eigentliche Umbau-Idee mit den zwei Startseiten-Buttons, die
      bleibt offen.

- [ ] **Refactoring** Wiederkehrende UI-Elemente als Widgets extrahieren,
      Inline-Styling durch Theme-Konstanten ersetzen, Logik in Services auslagern.
      Provider/State-Management einführen. Erste kleine Schritte bereits:
      Run 330 (Fokus-Füllfarbe von Eingabefeldern über eigene Konstante
      `AppFarben.fokusFarbe` zentralisiert statt appBarRot mitzunutzen),
      Run 331 (Footer-Deko in einstellungen_seite.dart und 10× rohes
      Colors.black54 auf bereits bestehende Theme-Konstanten umgestellt).
      Größeres Vorhaben seit Run 341: tagesabschluss_schritt2_seite.dart
      (3934 Zeilen) wird analog zu Schritt 1 (Run 40–58) in Untermodule
      unter lib/pages/tagesabschluss_schritt2/ aufgeteilt — Run 341 hat
      die reinen UI-Bau-Methoden ausgelagert (→ 3381 Zeilen), weitere
      Runs für State/Controller und den restlichen UI-Baum folgen.
      Schritt 3 (825 Zeilen) optional danach als kleinerer Abschluss-Run.

- [ ] **Fokus-Farbe Admin-Bereich (einstellungen_seite.dart)**
      Sämtliche Admin-Bereich-Felder (Upload-URL, location_id,
      API-Key, BelegScan-Service-URL, Getränkeliste-Verwaltung,
      Testwerte, Wechselgeld) haben gar keine Fokus-Füllfarbe — nicht
      MA-sichtbar (PIN-geschützt), daher geringere Priorität. Klären:
      ebenfalls auf Orange umstellen, oder bewusst als Ausnahme
      belassen? (Die vier Metadaten-Felder in
      tagesabschluss_schritt2_seite.dart mit hellgelber Fokus-Füllung
      sind KEIN offener Punkt mehr — laut Paco Absicht, Run 332a.)

- [ ] **Getränke-Audioeingabe** Audio + Getränkeliste → KI → Felder automatisch
      befüllen (Fuzzy Matching). Unsichere Zuordnungen gekennzeichnet.

- [ ] **Hilfe-System** Kontextsensitive Hilfe pro Schritt, langfristig
      Video-Clips für neue Mitarbeiter.

---

## ✅ Validierungen & Plausibilitätsprüfungen

### Stückelung — Harte Fehler
- *(Münzfeld-Teilbarkeit: bereits implementiert)*

### Stückelung — Weiche Warnungen
- [ ] Gesamtbarbestand nach Wechselgeld überschreitet Schwellwert (z. B. 3.000 €)
      *(Run 317: bewusst weggelassen — Schritt-1-Übersicht macht den Wert
      bereits sichtbar, Dialog wäre meist falsch-positiv.)*

- [ ] Einzelne Denomination > 80 % des Gesamtbestands
      *(Run 317: bewusst weggelassen — beim physischen Zählen offensichtlich,
      zu edge-case für MA-Alltag.)*

### Soll-Felder
- [ ] Bistro-Soll > Kino-Soll — weicher Hinweis: in Run 316
      umgesetzt, in Run 316a wieder entfernt. Grund: Prämisse
      trifft nicht standortübergreifend zu — in der Gondel gibt
      es Restaurant-Umsatz aus der Küche, dort kann Bistro-Soll
      legitim höher sein als Kino-Soll. Vorerst bewusst offen
      gelassen (MA prüfen Eingabe manuell); bei Bedarf durch die
      Kino-Leitung ggf. später standortabhängig wieder einführen.

### EC-Umsatz
- [ ] EC-Betrag > Gesamt-Soll — harter Fehler
      *(Run 317: weggelassen — im Ziffern-Modus kein realistisches Risiko.)*

### Differenz / Kassenstand
- [ ] Differenz Soll/Ist überschreitet Schwellwert (± 50 €) — Bestätigung
      *(Run 317: weggelassen — Schritt 3 zeigt Differenz bereits rot/grün,
      Dialog wäre redundante Friction.)*

- [ ] Ist > Soll — Warnung mit Erklärungstext
      *(Run 317: weggelassen — grüne Differenz in Schritt 3 reicht.)*

### Belege / Ausgaben
- [ ] Ausgaben > Barbestand — harter Fehler
      *(Run 317: weggelassen — im Ziffern-Modus kein realistisches Risiko.)*

### Zeitliche Plausibilität
- [ ] Zweite Abrechnung: Soll niedriger als erste — weicher Hinweis

- [ ] Abschluss-Uhrzeit außerhalb Betriebszeiten (3–5 Uhr) — weicher Hinweis

### Fehlerstufen

| Stufe | Verhalten |
|---|---|
| Harter Fehler | Weiter nicht möglich |
| Bestätigung | Weiter nach explizitem „Ja, stimmt so" |
| Weicher Hinweis | Hinweis angezeigt, Weiter jederzeit möglich |

---

## ↔️ Roadmap / Post-MVP

- [ ] **Offline-Hinweis** Banner wenn keine Netzwerkverbindung

- [ ] **Onboarding-Videos** Reale Abrechnung mit der App für neue Mitarbeiter

- [ ] **Nachrichten der Kinoleitung** Mitteilungen direkt in die App
      (erfordert Backend-Komponente)

- [ ] **Management-Dashboard** Übersicht alle Standorte, Tagesverläufe,
      Abweichungen — separates Tool

- [ ] **Remote-Konfigurationsdashboard** Zentrales Dashboard für Yannik
      zum Verwalten aller Geräte ohne Vor-Ort-Einrichtung — eigenständiges
      zweites System, nicht V1

- [ ] **Admin-Dashboard für Kino-IT** API-Key-Verwaltung, Konfiguration

