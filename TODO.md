# TODO — kino_bar_app

---

## 🟢 Kleine Fixes (direkt umsetzbar, je < 1h)

- [ ] **Kupfer-Bereich aufklappen:** Bargeld/Wechselgeld zählen — wenn Kupferfelder
      einen Inhalt haben, soll der Kupfer-Bereich automatisch aufgeklappt sein.

- [ ] **Mitarbeitername im Verlauf:** Name auch in lokalen Verlaufs-Datensätzen
      speichern und in Verlaufsansicht anzeigen. Präfix "MitarbeiterIn: " vor dem Namen.

- [ ] **DEV-Button im Web:** Der Button zum Befüllen mit Testwerten soll auch
      in der Web-App funktionieren.

- [ ] **Beleg-Eingabe:** Buttons zum Hinzufügen als Textbuttons gestalten.

- [ ] **Datenschutz-Hinweis:** Mitarbeiter darüber informieren, dass alle Daten
      (inkl. Name) intern bleiben.

- [ ] **Stückelung — Legende:** Unter der Stückelungsübersicht in kleiner Schrift
      erklären, was eine grüne Zeile bedeutet.

- [ ] **Desktop-Ansicht:** Inhalte auf Desktop-Browsern auf eine Breite begrenzen,
      die einer üblichen Smartphone-Displaybreite entspricht.

- [ ] **Anmerkungsfeld:** Tagesabschluss soll um ein optionales Anmerkungsfeld
      ergänzt werden können.

- [ ] **PWA-Install-Button:** In den Einstellungen einen Button anbieten, der den
      Nutzer durch die Installation der Web-App auf dem Smartphone führt.

- [ ] **Getränke-Nachfüllliste persistieren:** Liste lokal speichern (wie andere
      Entwurfsdaten), mit gleichem Reset-Verhalten. Verhindert Datenverlust bei Absturz.

- [ ] **Immer aktuelle Version laden:** Beim App-Start sicherstellen, dass Browser/PWA
      immer die aktuelle Version lädt (Getränkeliste, Wechselgeldbestand etc. aktuell).

- [ ] **Dev-Zeitstempel auf Startseite:** Während der Entwicklung auf der Startseite
      bodenbündig Datum und Uhrzeit anzeigen (Format: "dev: 17:45 (04.06.25)").

- [ ] **Mitarbeitername dauerhaft speichern:** Name soll auf dem jeweiligen Gerät
      gespeichert bleiben — nicht bei jedem Start neu eingeben.

- [ ] **Einstellungen gerätespezifisch speichern:** Alle Einstellungen pro Gerät
      persistent halten.
      
- [ ] **Safari-iOS — Lokale Speicherung unzuverlässig:** Safari löscht localStorage
      und IndexedDB nach 7 Tagen ohne Nutzerinteraktion (ITP). Als PWA installiert
      sind SharedPreferences/localStorage davon betroffen — gespeicherte Daten
      (Entwürfe, Einstellungen, Verlauf) können unbemerkt verschwinden. Lösung:
      robustere Speicherstrategie prüfen (z. B. Warnung bei drohendem Datenverlust,
      Export-Hinweis, oder regelmäßiges Backup in iCloud/Files).

- [ ] **Fallback-Export bei fehlgeschlagenem Upload:** Schlägt der Daten-Upload
      fehl, bietet die App automatisch an, die Abrechnung als Datei zu speichern.
      Die Datei landet in einem standortspezifischen Ordner (z. B. "Kassenabrechnung
      Schauburg") in iOS Dateien / Android Downloads. Mitarbeiter kann sie von dort
      per Mail weiterleiten.

---

## 🟡 Mittlere Features (eigenständige Funktionsblöcke)

- [ ] **Gondel-Abrechnung (kino_02):** Seiten noch nicht implementiert.
      Gleicher Workflow wie Schauburg, gleiche Ausgangswerte (1.400 € Wechselgeld).

- [ ] **Nachrichten-Button auf Startseite:** Neuer Button pro Kino-Startseite.
      Inaktiv/blass wenn keine Nachrichten vorliegen, vollfarbig wenn welche vorliegen.
      Kinoleitung kann Nachrichten versenden (z. B. Änderung Wechselgeldbestand).
      *(Erfordert Backend-Komponente — Konzept noch offen)*

- [ ] **EC-Belege nach Kartenanbieter aufschlüsseln:**
      Mitarbeiter wählt Kartentyp aus Pulldown (Visa, MasterCard, SEPA-EC, …),
      gibt Teilbeträge ein. App prüft ob Summe mit EC-Gesamtbetrag übereinstimmt.
      Eskalationsstufe: manuell → Foto-OCR (s. Umfangreiche Änderungen).

- [ ] **Abschluss-Export (PDF / Teilen):** Tagesabrechnung als PDF oder Text
      exportieren und z. B. per WhatsApp an die Kinoleitung schicken.

- [ ] **Automatisches Geräte-Backup beim Absenden:** Sobald der MA auf SENDEN
      tippt, wird die Abrechnung sofort als Datei auf dem Gerät gespeichert
      (iOS Dateien / Android Downloads, standortspezifischer Ordner) — unabhängig
      vom Upload-Ergebnis. Schlägt der Upload fehl, versucht die App ihn im
      Hintergrund erneut, sobald wieder eine Verbindung besteht. Das Geräte-Backup
      ist in jedem Fall vorhanden.

- [ ] **BelegScan — Implementierung:** EC-Beleg fotografieren, Anthropic Vision API
      ermittelt Kartenanbieter und Beträge automatisch. Konzept steht (Pilot: Schauburg).

- [ ] 

---

## 🔴 Größere Umbauten & Anpassungen

- [ ] **Bar Tabak (kino_05):** Komplexe Kassenstruktur (Kino-, Bar-, Lotterie-,
      Handy-Kasse; zwei Abschlüsse/Tag). Noch nicht implementiert.

- [ ] **Frühjahrsputz / Refactoring:** Wiederkehrende UI-Elemente als Widgets
      extrahieren, Inline-Styling durch Theme-Konstanten ersetzen,
      Logik aus Widgets in Services auslagern. Inkl. Provider/State-Management
      einführen (Händigkeit, ggf. Login-Status, seitenübergreifende Daten).

- [ ] **Kinoleitungs-Login + Config-Editor:** Kinoleitung kann Getränkeliste
      und Wechselgeldbestand direkt in der App bearbeiten — kein Git-Commit nötig.

- [ ] **Getränke-Audioeingabe:** Aufnahme direkt in der App → Audio + Getränkeliste
      an KI → KI füllt Felder aus (Fuzzy Matching), unsichere Zuordnungen
      werden gekennzeichnet.

- [ ] **Hilfe-System:** Kontextsensitive Hilfe pro Schritt, langfristig mit
      Video-Clips für neue Mitarbeiter.

---

## ✅ Validierungen & Plausibilitätsprüfungen

*(Bereit zur Implementierung — priorisierbar nach Bedarf)*

### Stückelung — Harte Fehler
- [ ] Scheinfeld nicht durch Nennwert teilbar (z. B. 75 € im 50-€-Feld)
- [ ] Negativer Betrag in irgendeinem Zählfeld
- *(Münzfeld-Teilbarkeit: bereits implementiert)*

### Stückelung — Weiche Warnungen
- [ ] 500 € / 200 €-Scheine vorhanden — in Kinokasse sehr ungewöhnlich
- [ ] Gesamtbarbestand nach Wechselgeld überschreitet konfigurierbaren Schwellwert (z. B. 3.000 €)
- [ ] Einzelne Denomination > 80 % des Gesamtbestands — Hinweis auf möglichen Zählfehler

### Soll-Felder
- [ ] Kino-Soll = 0 — Bestätigung erforderlich
- [ ] Bistro-Soll > Kino-Soll — weicher Hinweis
- [ ] Soll-Felder leer beim Abschluss-Start — Pflichtfeld-Prüfung

### EC-Umsatz
- [ ] EC-Betrag > Gesamt-Soll — harter Fehler
- [ ] EC = 0 an normalem Betriebstag — weicher Hinweis

### Differenz / Kassenstand
- [ ] Differenz Soll/Ist überschreitet Schwellwert (± 50 €) — Bestätigung erforderlich
- [ ] Ist > Soll — Warnung mit Erklärungstext
- [ ] Differenz Anfangsbestand > 20 € — weicher Hinweis

### Belege / Ausgaben
- [ ] Beleg angelegt, Betrag = 0 oder leer — Pflichtfeld
- [ ] Ausgaben > Barbestand — harter Fehler

### Zeitliche / kontextuelle Plausibilität
- [ ] Zweite Abrechnung: Soll niedriger als erste — weicher Hinweis
- [ ] Abschluss-Uhrzeit außerhalb Betriebszeiten (3–5 Uhr, vor 6-Uhr-Knick) — weicher Hinweis

### Stufen

| Stufe | Verhalten |
|---|---|
| Harter Fehler | Weiter nicht möglich |
| Bestätigung | Weiter nach explizitem „Ja, stimmt so" |
| Weicher Hinweis | Hinweis angezeigt, Weiter jederzeit möglich |

---

## 💡 Ideen / Post-MVP

- [ ] Offline-Hinweis: Banner wenn keine Netzwerkverbindung
- [ ] Videoclips einer realen Abrechnung mit der App (Onboarding neuer Mitarbeiter)
- [ ] Management-Dashboard: Übersicht alle Standorte, Tagesverläufe, Abweichungen
      *(separates Tool, nicht Teil der Haupt-App)*