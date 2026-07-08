# TODO — kino_bar_app
Stand: Juli 2026 · Run 312 · wird fortlaufend ergänzt

---

## 🔴 Blockiert — wartet auf IT (Yannik)

- [ ] **location_id pro Standort** Welche interne Flurbocash-ID hat jeder Standort?
      (Schauburg, Gondel, Atlantis, Cinema Ostertor, Bar Tabak)

- [ ] **Basis-URL Flurbocash-Server** HTTPS-Adresse der API.

- [ ] **X-API-Key** Tatsächlicher Schlüssel — ein Key für alle oder je einer
      pro Standort, nach Yanniks Ermessen.

- [ ] **Registrierte TIDs pro Standort** Welche Terminal-IDs sind in Flurbocash
      für welchen Standort hinterlegt?

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

- [ ] **Kartensumme ↔ EC-Gesamtbetrag nach manuellem Nachtrag** Seit Run 274f4
      gibt es in der Kartenarten-Tabelle einen "+ Kartenart"-Button zum
      nachträglichen Einblenden nicht erkannter Kartenarten. Klären: wenn der
      Nachtrag die Kartensumme wieder zum EC-Gesamtbetrag (Hauptfeld) passend
      macht, soll dort etwas automatisch nachgezogen werden? Zurückgestellt,
      da bei sauberen Scans kaum relevant.

- [x] **Schwarze Hervorhebungen → Kino-Rot** Sämtliche schwarze Feld-Hervorhebungen auf `AppFarben.appBarRot` umstellen. *(Run 302–302d)*

- [x] **Textbutton "zuklappen"** Die Seite soll einen Textlink "alle zuklappen"
      (bzw. aufklappen) bekommen, der alle Kacheln schließt, um dem MA eine bessere Übersicht zu geben.
      *(Run 303 — umgesetzt für Schritt 1 und Wechselgeld-Prüfen-Seite)*

---

## 🟡 Mittlere Features (eigenständige Funktionsblöcke)

### BelegScan & EC-Kachel *(Phase A, Runs 275–281)*

- [ ] **Hilfetext & Duplikat-Button** Info im Scan-Bereich was zu tun
      ist wenn Beleg fehlt oder unlesbar ist. Ursprünglich zusätzlich
      als Dummy-Button im Prüf-Popup geplant — Popup existiert seit
      Run 307 nicht mehr, neuer Ort muss geklärt werden.
      Vorbereitung für spätere Tutorial-Videos oder Texte.

- [x] **Prüf-Popup entfernen — Fehler direkt in der Kachel** Fragliche
      Daten werden in der Sub-Kachel direkt hervorgehoben und
      korrigierbar gemacht. *(Run 304d3/304d4 — Hervorhebung; Run 307 —
      Popup selbst entfernt. Das "Fertig-Button ausgegraut"-Verhalten
      bleibt offen, siehe "Fertig-Button-Gate" unten.)*

- [ ] **Fertig-Button-Gate** Fertig-Button bleibt ausgegraut solange ein Datenfeld
      leer oder nicht korrekt ist. Tap auf ausgegrauten Button: Hinweis
      "Daten noch nicht vollständig — bitte korrigieren."

- [ ] **Plausibilitätsprüfung deaktivierbar** Standardmäßig deaktiviert.
      Im Dev-Modus per Toggle einschaltbar. Das wird später noch weiterentwickelt.

- [ ] **Prüfen-Flag für Buchhaltung** Erst mit IT klären ob gewünscht und
      wie es übermittelt wird (Flurbocash-Feld, E-Mail o. Ä.). Dann einplanen.

- [ ] **Storno auf Belegen** Noch nie vorgekommen, aber die App muss
      Stornos erkennen können.

- [x] **Belegscan Metadaten** zuklappbar machen. *(bereits umgesetzt —
      `_baueMetadatenBlock()` mit `_metadatenAufgeklappt`-Toggle)*

- [ ] **KI-Prompt verbessern** KI soll nur relevante Daten lesen, nichts
      hineininterpretieren und keine Bemerkungen zu Schreibgerät, Belegrissen o. Ä.
      Im Prompt auf Zeilen-Zuordnung hinweisen — manchmal rutscht ein Kartenbetrag
      zu einer falschen Kartenart.

### Einstellungen & Konfiguration *(Phase C)*

- [ ] **PIN-Schutz Verwaltungsbereich** PIN (1929/Session) + location_id +
      API-Key-Felder bereits in Runs 287/291/292 umgesetzt. Noch offen:
      Basis-URL-Feld in Einstellungen-UI. *(TID-Whitelist + Buchhaltungs-E-Mail
      → eigene Punkte unten)*

- [ ] **Standort vorauswählen (Admin)** Admin stellt in den Einstellungen den
      Standort ein, damit MA nicht erst auswählen müssen.

- [ ] **Admin-Passwort** Admin-Modus mit festem Passwort "flrbcsh" schützen
      (aktuell: PIN 1929/Session).

- [ ] **TID-Whitelist konfigurierbar** Pro Standort in Einstellungen
      editierbar. Prüfung nach BelegScan — Warnung bei unbekannter TID.

- [ ] **Safari-iOS: Lokale Speicherung** Safari löscht localStorage/IndexedDB
      nach 7 Tagen (ITP). Lösung: Warnung bei drohendem Datenverlust oder
      regelmäßiger Export-Hinweis.

- [ ] **Fallback-Export bei fehlgeschlagenem Upload** App bietet automatisch
      an, Abrechnung als Datei zu speichern (iOS Dateien / Android Downloads,
      standortspezifischer Ordner).

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

- [x] **Automatisches Geräte-Backup beim Senden** Abrechnung wird
      lokal gespeichert, unabhängig vom Upload-Ergebnis. *(bereits
      umgesetzt — `_autoSaveImHintergrund()` in
      tagesabschluss_schritt3_seite.dart speichert automatisch beim
      Erreichen von Schritt 3, noch vor SENDEN; Schritt 3 hat keine
      editierbaren Felder, die danach noch verloren gehen könnten.)*

- [x] **Verlauf — 30-Tage-Bereinigung** Abgeschlossene Abrechnungen
      automatisch nach 30 Tagen löschen (Datenschutz). *(Run 311)*

---

## 🔴 Größere Umbauten

- [ ] **Bar Tabak (kino_05)** Komplexe Kassenstruktur (Kino-, Bar-, Lotterie-,
      Handy-Kasse; 2 Abschlüsse/Tag). Noch nicht implementiert.
      Startseite: zwei Buttons „1. Abrechnung" und „2. Abrechnung".

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
