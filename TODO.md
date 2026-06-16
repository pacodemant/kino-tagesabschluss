# TODO — kino_bar_app
Stand: Juni 2026 · wird fortlaufend ergänzt

---

## 🔴 Blockiert — wartet auf IT (Yannik)

- [ ] **location_id pro Standort** Welche interne Flurbocash-ID hat jeder Standort?
      (Schauburg, Gondel, Atlantis, Cinema Ostertor, Bar Tabak)

- [ ] **Basis-URL Flurbocash-Server** HTTPS-Adresse der API.

- [ ] **X-API-Key** Tatsächlicher Schlüssel — ein Key für alle oder je einer
      pro Standort, nach Yanniks Ermessen.

- [ ] **Registrierte TIDs pro Standort** Welche Terminal-IDs sind in Flurbocash
      für welchen Standort hinterlegt?

- [ ] **CORS-Header** Server muss `Access-Control-Allow-Origin: *` senden.
      Bereits konfiguriert?

- [ ] **6-Uhr-Knick abstimmen** Welches Datum erwartet Flurbocash für
      Nachtabrechnungen (z. B. 1 Uhr nachts) — Kalendertag oder logischer
      Abrechnungstag (= Vortag)?

- [ ] **Weitere Abrechnungsfelder** Sollen Kino-Soll, Bistro-Soll, Ausgaben,
      Mitarbeitername, Differenz an Flurbocash übermittelt werden — oder holt das
      System sie selbst aus dem Kassensystem?

- [ ] **Testumgebung** Gibt es eine Staging-Instanz von Flurbocash?

- [ ] **Konfiguration der Geräte** Wer richtet die Smartphones ein — IT oder MA?
      Wer pflegt Änderungen (neuer API-Key, neue TID)?

- [ ] **Mailversand** Gibt es einen Mailserver/-dienst für die App, oder soll
      die Mail-App des Geräts geöffnet werden (mailto:)?

- [ ] **Stapel-Scanner: Übertragungsformat** Wie sollen gesammelte EC-Belege
      an Flurbocash gehen — einzeln (je ein 2-Call-Flow) oder als Batch?
      Separater Endpunkt oder derselbe wie die Tagesabrechnung?

---

## 🟢 Kleine Fixes (je < 1h, direkt umsetzbar)

- [ ] **Persongetränke zuerst** *(Run 281)* Persogetränke zu Beginn der Abrechnung
      abfragen (nicht am Ende) — verhindert Vergessen, entfernt das Banner auf der
      Kino-Seite.

- [ ] **Kupfer-Bereich auto-aufklappen** *(Run 282)* Haben Kupferfelder einen Inhalt,
      soll der Bereich automatisch aufgeklappt sein.

- [ ] **Mitarbeitername im Verlauf** *(Run 283)* Name in lokalen Verlaufs-Datensätzen
      speichern und anzeigen. Präfix "MitarbeiterIn: ".

- [ ] **Stückelung — Legende + Anmerkungsfeld** *(Run 284)* Unter Stückelungsübersicht
      erklären was eine grüne Zeile bedeutet. Optionales Freitextfeld am Ende der
      Abrechnung.

- [ ] **Desktop-Ansicht begrenzen** *(Run 285)* Inhalte auf Desktop-Browsern auf
      Smartphone-Breite begrenzen.

- [ ] **DEV-Testwerte-Button im Web** *(Run 286)* Funktioniert bisher nur im Simulator.

- [ ] **Beleg-Eingabe: Textbuttons** Buttons zum Hinzufügen als Textbuttons gestalten.

- [ ] **PWA-Install-Button** In Einstellungen: Button führt durch
      Homescreen-Installation.

- [ ] **Getränke-Nachfüllliste persistieren** Lokal speichern wie andere
      Entwurfsdaten. Verhindert Datenverlust bei Absturz.

- [ ] **Immer aktuelle Version laden** Beim Start sicherstellen dass Browser/PWA
      stets die aktuelle Version lädt.

- [ ] **Datenschutz-Hinweis** MA informieren dass alle Daten inkl. Name intern bleiben.

- [ ] **Kartensumme ↔ EC-Gesamtbetrag nach manuellem Nachtrag** Seit Run 274f4
      gibt es in der Kartenarten-Tabelle einen "+ Kartenart"-Button zum
      nachträglichen Einblenden nicht erkannter Kartenarten. Klären: wenn der
      Nachtrag die Kartensumme wieder zum EC-Gesamtbetrag (Hauptfeld) passend
      macht, soll dort etwas automatisch nachgezogen werden? Zurückgestellt,
      da bei sauberen Scans kaum relevant.

---

## 🟡 Mittlere Features (eigenständige Funktionsblöcke)

### BelegScan & EC-Kachel *(Phase A, Runs 275–280)*

- [x] **EC-Kachel: Layout & Terminal-ID** *(Run 275)* Metadaten kompakter,
      Betragszeilen luftiger. "Bezeichnung (optional)" → "Terminal-ID" als Pflichtfeld.
      Bei Scan automatisch befüllt.

- [ ] **EC-Kachel: Summe statt Kamera-Icon + "Weiteren Beleg"-Button** *(Run 276)*
      Zugeklappte Kachel zeigt Gesamtsumme rechts. "Weiteren Beleg hinzufügen"
      erscheint als Textbutton erst nach dem ersten Beleg.

- [ ] **EC-Kachel: Unterkacheln pro Beleg** *(Run 277)* Mehrere Belege pro Kachel
      möglich. Jeder Beleg = eigene Unterkachel (zugklappbar, eigener Papierkorb,
      eigener Foto-Button mit Rückfrage vor erneutem Scan).

- [ ] **Prüf-Popup: Inline-Korrektur** *(Run 278)* Unlesbare/unsichere Werte rot
      hervorgehoben. Tap → kompaktes Eingabefeld ersetzt genau diese Zeile (gleiche
      Höhe, roter Rahmen). Hinweistext: "Rote Felder bitte korrigieren."

- [ ] **"see JSON"-Button im Dev-Modus** *(Run 279)* Im Prüf-Popup sichtbar wenn
      Dev-Modus aktiv. Zeigt JSON des aktuell geprüften Belegs. Dummy-"Senden"-Button
      (Snackbar).

- [ ] **Hilfetext: Belegkopie ziehen** *(Run 280)* Info im Scan-Bereich was zu tun
      ist wenn Beleg fehlt oder unlesbar ist.

### Einstellungen & Konfiguration *(Phase C, Runs 287–288)*

- [ ] **PIN-Schutz Verwaltungsbereich** *(Run 287)* Vierstelliger PIN schützt
      Einstellungen. Felder für location_id, API-Key, Basis-URL, TID-Whitelist
      und Buchhaltungs-E-Mail — vorerst mit Platzhaltern.

- [ ] **TID-Whitelist konfigurierbar** *(Run 288)* Pro Standort in Einstellungen
      editierbar. Prüfung nach BelegScan — Warnung bei unbekannter TID.
      Setzt Run 287 voraus.

- [ ] **Safari-iOS: Lokale Speicherung** Safari löscht localStorage/IndexedDB
      nach 7 Tagen (ITP). Lösung: Warnung bei drohendem Datenverlust oder
      regelmäßiger Export-Hinweis.

- [ ] **Fallback-Export bei fehlgeschlagenem Upload** App bietet automatisch
      an, Abrechnung als Datei zu speichern (iOS Dateien / Android Downloads,
      standortspezifischer Ordner).

### Flurbocash API-Integration *(Phase E, Runs 290–292 — wartet auf IT)*

- [ ] **ApiUploadService Umbau** *(Run 290)* 1 Call → 2 Calls (ensure + settlements),
      JSON statt form-encoded, report_id lokal speichern,
      Fehlerbehandlung für alle HTTP-Statuscodes (400/401/403/404/500).
      Wartet auf: Basis-URL, API-Key, location_ids, 6-Uhr-Knick-Absprache.

- [ ] **location_id ins Kino-Modell** Neues Feld in `kino.dart`. Wert kommt von IT.

- [ ] **"Erneut senden" → Korrektur-Call + Max-4-Fehlermeldung** *(Run 291)*
      `settlement_number: 1` statt neuem Eintrag. Bei `400 "maximum reached"`:
      verständliche Meldung + Textbutton "Info an Buchhaltung senden".
      Nach Tap: Mail an konfigurierte Adresse, Bestätigung "Buchhaltung ist
      informiert — Abrechnung beendet." Setzt Run 290 voraus.

- [ ] **Buchhaltungs-E-Mail konfigurierbar** Empfängeradresse in Einstellungen.
      Mailmethode abhängig von Yannik-Antwort.

- [ ] **Bar Tabak: 2-Settlement-Logik** Beide Abrechnungen teilen eine
      `report_id`. Zweiter Call muss `settlement_number: 2` setzen.
      Erst relevant wenn BT implementiert wird.

### Stapel-Scanner *(Phase D/E, Runs 289 + 292)*

- [ ] **Stapel-Scanner: Seite & Grundstruktur** *(Run 289)* Eigene Seite im
      Verwaltungsbereich (hinter PIN). MA scannt reihenweise Belege, gespeichert
      wie Verlauf. Nutzt EC-Kachel-Komponente aus Phase A. Senden-Button als Dummy.
      Setzt Runs 277 und 287 voraus.

- [ ] **Stapel-Scanner: echter Versand** *(Run 292)* Dummy-Button durch echten
      Flurbocash-Call ersetzen. Format abhängig von Yannik-Antwort.
      Setzt Runs 290 und 289 voraus.

### Weitere Features

- [ ] **Gondel-Abrechnung (kino_02)** Workflow wie Schauburg,
      Wechselgeld 1.400 €.

- [ ] **Abschluss-Export (PDF / Teilen)** Tagesabrechnung als PDF oder Text
      per WhatsApp / Mail an Kinoleitung.

- [ ] **Automatisches Geräte-Backup beim Senden** Abrechnung wird beim Antippen
      von SENDEN sofort lokal gespeichert — unabhängig vom Upload-Ergebnis.

- [ ] **Verlauf — 30-Tage-Bereinigung** Abgeschlossene Abrechnungen automatisch
      nach 30 Tagen löschen (Datenschutz).

---

## 🔴 Größere Umbauten

- [ ] **Bar Tabak (kino_05)** Komplexe Kassenstruktur (Kino-, Bar-, Lotterie-,
      Handy-Kasse; 2 Abschlüsse/Tag). Noch nicht implementiert.

- [ ] **Refactoring** Wiederkehrende UI-Elemente als Widgets extrahieren,
      Inline-Styling durch Theme-Konstanten ersetzen, Logik in Services auslagern.
      Provider/State-Management einführen.

- [ ] **Getränke-Audioeingabe** Audio + Getränkeliste → KI → Felder automatisch
      befüllen (Fuzzy Matching). Unsichere Zuordnungen gekennzeichnet.

- [ ] **Hilfe-System** Kontextsensitive Hilfe pro Schritt, langfristig
      Video-Clips für neue Mitarbeiter.

---

## ✅ Validierungen & Plausibilitätsprüfungen

### Stückelung — Harte Fehler
- [ ] Scheinfeld nicht durch Nennwert teilbar (z. B. 75 € im 50-€-Feld)
- [ ] Negativer Betrag in irgendeinem Zählfeld
- *(Münzfeld-Teilbarkeit: bereits implementiert)*

### Stückelung — Weiche Warnungen
- [ ] 500 € / 200 €-Scheine vorhanden
- [ ] Gesamtbarbestand nach Wechselgeld überschreitet Schwellwert (z. B. 3.000 €)
- [ ] Einzelne Denomination > 80 % des Gesamtbestands

### Soll-Felder
- [ ] Kino-Soll = 0 — Bestätigung erforderlich
- [ ] Bistro-Soll > Kino-Soll — weicher Hinweis
- [ ] Soll-Felder leer beim Abschluss-Start — Pflichtfeld

### EC-Umsatz
- [ ] EC-Betrag > Gesamt-Soll — harter Fehler
- [ ] EC = 0 an normalem Betriebstag — weicher Hinweis

### Differenz / Kassenstand
- [ ] Differenz Soll/Ist überschreitet Schwellwert (± 50 €) — Bestätigung
- [ ] Ist > Soll — Warnung mit Erklärungstext
- [ ] Differenz Anfangsbestand > 20 € — weicher Hinweis

### Belege / Ausgaben
- [ ] Beleg angelegt, Betrag = 0 oder leer — Pflichtfeld
- [ ] Ausgaben > Barbestand — harter Fehler

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

## 💡 Roadmap / Post-MVP

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
