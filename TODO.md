# TODO — kino_bar_app
Stand: Juli 2026 · Run 323a · wird fortlaufend ergänzt

---

## 🔴 Blockiert — wartet auf IT (Yannik)

- [x] **location_id pro Standort** Welche interne Flurbocash-ID hat jeder Standort?
      (Schauburg, Gondel, Atlantis, Cinema Ostertor, Bar Tabak)
      Teilweise beantwortet (Mail Yannik, 2026-07-12): Schauburg = 1,
      Atlantis = 3, Bar Tabak = 4. Gondel/Cinema Ostertor noch offen —
      laut Plan aber erst relevant, wenn SB vollständig läuft.

- [ ] **Basis-URL Flurbocash-Server** HTTPS-Adresse der API.
      Sandbox bekannt: https://sandbox.flurbocash.c137-prime.de:666
      (wird aktuell für alle Tests genutzt). Ob das auch die
      Produktiv-URL ist oder Yannik später eine andere gibt: offen.

- [x] **X-API-Key** Tatsächlicher Schlüssel — ein Key für alle oder je einer
      pro Standort, nach Yanniks Ermessen.
      Beantwortet (Mail Yannik, 2026-07-12): je ein eigener Key pro
      Standort, kein gemeinsamer Key für alle. Die konkreten Key-Werte
      stehen NICHT hier, sondern nur in den App-Einstellungen pro Kino.

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

- [x] **CORS-Header** Server muss `Access-Control-Allow-Origin: *` senden.
      Bereits konfiguriert?
      Erledigt (Stand 2026-07-14): Yannik hat X-API-Key zu
      access-control-allow-headers ergänzt ("x-api-keys sind nun
      erlaubt"). Erster echter Live-Test für Schauburg (location_id 1)
      erfolgreich — Tagesbericht kam im Flurbocash-Dashboard korrekt
      an (Bargeld + EC-Kartenaufschlüsselung stimmen exakt mit der
      App-Eingabe überein).

- [ ] **6-Uhr-Knick abstimmen** Welches Datum erwartet Flurbocash für
      Nachtabrechnungen (z. B. 1 Uhr nachts) — Kalendertag oder logischer
      Abrechnungstag (= Vortag)?

- [ ] **Weitere Abrechnungsfelder** Sollen Kino-Soll, Bistro-Soll, Ausgaben,
      Mitarbeitername, Differenz an Flurbocash übermittelt werden — oder holt das
      System sie selbst aus dem Kassensystem?

- [x] **Testumgebung** Gibt es eine Staging-Instanz von Flurbocash?
      Ja: Sandbox unter https://sandbox.flurbocash.c137-prime.de:666
      (Stand 2026-07-12, wird aktuell für alle Tests genutzt).

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

- [x] **"Eingabe mit Komma"-Einstellung entfernen** App-weit fest auf
      Eingabe ohne Komma (230 statt 2,30). Bereits erledigt: Die
      Einstellung (`eingabe_mit_komma`) wurde in Run 317 vollständig
      entfernt — kein Vorkommen mehr im Code, `mitKomma` ist überall
      fest auf `false`. *(geprüft Run 319b)*

- [x] **Admin-Bereich entsperrt zu lange** `_devAufgeklappt` in
      `einstellungen_seite.dart` war als `static` deklariert statt
      als normales State-Feld — Verwaltungsbereich blieb für die
      gesamte App-Sitzung entsperrt, auch nach Verlassen und
      erneutem Aufrufen der Einstellungsseite. Fix: `static`
      entfernt (normales Instanzfeld) — PIN wird bei jedem erneuten
      Öffnen der Seite wieder verlangt. Offen bleibt der Edge-Case
      "Seite bleibt im Hintergrund geöffnet, MA wechselt kurz die
      App" (State wird dabei nicht disposed, PIN bliebe entsperrt) —
      bewusst zurückgestellt, Praxis-Relevanz unklar. *(Run 320)*

---

## 🟡 Mittlere Features (eigenständige Funktionsblöcke)

### BelegScan & EC-Kachel *(Phase A, Runs 275–281)*

- [ ] **Hilfetext & Duplikat-Button** Info im Scan-Bereich was zu tun
      ist wenn Beleg fehlt oder unlesbar ist. Ursprünglich zusätzlich
      als Dummy-Button im Prüf-Popup geplant — Popup existierte
      zwischen Run 307 und Run 318 nicht. Seit Run 318 gibt es
      wieder ein Prüf-Popup (`beleg_scan_bestaetigen_dialog.dart`,
      anderer Zweck als vor Run 307: bewusste Bestätigung vor der
      Übernahme statt Fehlerprüfung) — könnte wieder als Ort in
      Frage kommen, Hilfetext/Duplikat-Button selbst sind dort
      aber nicht umgesetzt.
      Vorbereitung für spätere Tutorial-Videos oder Texte.
      Teilschritt erledigt (Run 319a): Die Fehlermeldung bei
      unscharfem Foto/Netzwerkproblem weist jetzt zusätzlich auf die
      manuelle Eingabe hin. Ein dauerhaft sichtbarer Hilfetext im
      Scan-Bereich selbst bleibt offen.

- [x] **Prüf-Popup entfernen — Fehler direkt in der Kachel** Fragliche
      Daten werden in der Sub-Kachel direkt hervorgehoben und
      korrigierbar gemacht. *(Run 304d3/304d4 — Hervorhebung; Run 307 —
      Popup selbst entfernt. Das "Fertig-Button ausgegraut"-Verhalten
      bleibt offen, siehe "Fertig-Button-Gate" unten.)* Hinweis: Seit
      Run 318 gibt es ein neues, anders motiviertes Prüf-Popup
      (Bestätigung vor der Übernahme, nicht Fehlerprüfung) — kein
      Widerspruch zu diesem abgehakten Punkt, siehe CHANGELOG Run 318.

- [x] **Fertig-Button-Gate** Fertig-Button bleibt ausgegraut solange ein Datenfeld
      leer oder nicht korrekt ist. Tap auf ausgegrauten Button: Hinweis
      "Daten noch nicht vollständig — bitte korrigieren." — Variante: Button
      ausgrauen entfiel, da der "Weiter"-Button bereits reaktiv auf leere
      Pflichtfelder prüft. Stattdessen echte Lücke geschlossen: die
      Pflichtfeld-Prüfung lief bisher nur für den ersten EC-Beleg
      (`.first`); im Mehrbeleg-Modus wurden TID/Gesamt-Betrag weiterer
      Belege vor "Weiter" gar nicht geprüft. `_pruefePflichtfelderVorSchritt3()`
      prüft jetzt alle vorhandenen EC-Belege. *(Run 313e)*

- [x] **Plausibilitätsprüfung deaktivierbar** Nicht mehr nötig — die Prüfung
      (Kartensumme = Gesamtbetrag laut Beleg) ist bereits nur ein weicher
      Hinweis, kein Blocker (seit Run 304d4). Eine Deaktivierung hätte nur
      kosmetischen Effekt. Aktiv gelassen, da sie verhindert, dass eine
      falsche Kartenaufschlüsselung unbemerkt an Flurbocash geht.

- [ ] **Prüfen-Flag für Buchhaltung** Erst mit IT klären ob gewünscht und
      wie es übermittelt wird (Flurbocash-Feld, E-Mail o. Ä.). Dann einplanen.

- [ ] **Storno auf Belegen** Noch nie vorgekommen, aber die App muss
      Stornos erkennen können.

- [x] **Belegscan Metadaten** zuklappbar machen. *(bereits umgesetzt —
      `_baueMetadatenBlock()` mit `_metadatenAufgeklappt`-Toggle)*

- [x] **KI-Prompt verbessern** KI soll nur relevante Daten lesen, nichts
      hineininterpretieren und keine Bemerkungen zu Schreibgerät, Belegrissen o. Ä.
      Im Prompt auf Zeilen-Zuordnung hinweisen — manchmal rutscht ein Kartenbetrag
      zu einer falschen Kartenart. Bereits umgesetzt: aktueller System-Prompt
      (`beleg_scan_service.dart`) verbietet Schätzen/Interpolieren/Ergänzen
      explizit, verlangt strikte Zeilen-Zuordnung ("nicht anhand von
      Reihenfolge... zuordnen") und beschränkt "hinweis" ausschließlich
      auf den Summen-Abgleich (kein Freitext, keine visuellen
      Einschätzungen). *(geprüft Run 319b)*

### Einstellungen & Konfiguration *(Phase C)*

- [ ] **PIN-Schutz Verwaltungsbereich** PIN (1929/Session) + location_id +
      API-Key-Felder bereits in Runs 287/291/292 umgesetzt. Noch offen:
      Basis-URL-Feld in Einstellungen-UI. *(TID-Whitelist + Buchhaltungs-E-Mail
      → eigene Punkte unten)*

- [ ] **Standort-Betriebsmodus (Admin)** Im Verwaltungsbereich einstellbar,
      für welchen Standort das Gerät arbeitet: „Alle", SB, CO, AT, GO
      oder BT. Ist ein einzelner Standort gewählt, entfällt für MA die
      Kinoauswahl (Erweiterung von "Standort vorauswählen", siehe unten)
      UND der Textbutton "Kino wechseln" auf der Startseite
      (`startmenue_seite.dart`) wird ausgeblendet — er erscheint nur,
      wenn "Alle" eingestellt ist. So verstanden; bitte gegenprüfen,
      falls die gewünschte Logik anders gemeint war. *(Zurückgestellt —
      an der Einstellungsseite stehen ohnehin noch weitere Anpassungen
      an, dann zusammen angehen. Datenschutzhinweise-Link ist seit
      Run 321 bereits zusätzlich auf startmenue_seite.dart vorhanden,
      bleibt also auch bei entfallender Kinoauswahl erreichbar.)*

- [x] **Admin-Passwort** Bleibt bei PIN 1929 (Session) — kein Wechsel zu
      festem Passwort gewünscht.

- [ ] **TID-Whitelist konfigurierbar** Pro Standort in Einstellungen
      editierbar. Prüfung nach BelegScan — Warnung bei unbekannter TID.

- [ ] **Safari-iOS: Lokale Speicherung** Safari löscht localStorage/IndexedDB
      nach 7 Tagen (ITP). Lösung: Warnung bei drohendem Datenverlust oder
      regelmäßiger Export-Hinweis. *(Vorerst zurückgestellt — Zielplattform
      ist Android an allen Standorten, ITP betrifft nur iOS/Safari und damit
      nur Pacos private Testumgebung.)*

- [x] **Fallback-Export bei fehlgeschlagenem Upload** Nicht nötig — die
      Abrechnung wird bereits unabhängig vom Upload-Ergebnis automatisch im
      Verlauf gespeichert (siehe "Automatisches Geräte-Backup beim Senden"
      weiter unten). Ein zusätzlicher Datei-Export wäre nur bei konkretem
      Bedarf sinnvoll (z. B. Weitergabe an Buchhaltung bei Langzeitausfall
      des Uploads).

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

- [ ] **Getränkeliste: Abhaken bei "nur benötigte anzeigen"** Im
      Filtermodus "nur benötigte anzeigen" (`getraenke_auffuellen_seite.dart`,
      `_nurBenoetigte`) sollen Einträge zusätzlich eine runde Checkbox
      bekommen. Hakt der MA einen Eintrag ab, wandert er ans Ende der
      (gefilterten) Liste. Beim Zurückschalten auf "alle anzeigen"
      wird wieder die ursprüngliche Reihenfolge angezeigt — das
      Abhaken beeinflusst also nur die Sortierung im gefilterten Modus,
      nicht die Grundreihenfolge der Liste.

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
      Sicherheitsnetz bereits vorhanden (Run 319a): `Kino.maxAbrechnungenProTag`
      (Standard 1, Bar Tabak 2) verhindert in
      `SpeichereTagesabschlussUsecase`, dass eine zweite Abrechnung am
      selben Tag die erste stillschweigend überschreibt — stattdessen
      Rückfrage "Ersetzen" vs. "Zusätzliche Abrechnung". Ersetzt NICHT
      die eigentliche Umbau-Idee mit den zwei Startseiten-Buttons, die
      bleibt offen.

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
- [x] Scheinfeld nicht durch Nennwert teilbar (z. B. 75 € im 50-€-Feld) —
      entfällt: Scheine/Rollen werden als Stückzahl (Ganzzahl) erfasst,
      nicht als Betrag. Bei einem Stückzahl-Feld ist eine nicht durch
      den Nennwert teilbare Eingabe technisch nicht möglich.
      *(geprüft Run 313d)*
- [x] Negativer Betrag in irgendeinem Zählfeld — entfällt:
      `GanzzahlEingabefeld` filtert Eingaben mit
      `FilteringTextInputFormatter.digitsOnly` (auch bei Paste) —
      ein Minuszeichen kann im Stückzahl-Feld technisch nicht
      eingegeben werden. Einziger Verwendungsort:
      `schritt1_ui_builder.dart`. *(geprüft Run 314)*
- *(Münzfeld-Teilbarkeit: bereits implementiert)*

### Stückelung — Weiche Warnungen
- [x] 500 € / 200 €-Scheine vorhanden — entfällt: Die App kennt in
      `StueckelungKonfiguration.scheine` gar keine 200-€- oder
      500-€-Denomination (nur 100/50/20/10/5 €) — ein solcher
      Schein kann nirgends erfasst werden. *(geprüft Run 314)*
- [ ] Gesamtbarbestand nach Wechselgeld überschreitet Schwellwert (z. B. 3.000 €)
      *(Run 317: bewusst weggelassen — Schritt-1-Übersicht macht den Wert
      bereits sichtbar, Dialog wäre meist falsch-positiv.)*
- [ ] Einzelne Denomination > 80 % des Gesamtbestands
      *(Run 317: bewusst weggelassen — beim physischen Zählen offensichtlich,
      zu edge-case für MA-Alltag.)*

### Soll-Felder
- [x] Kino-Soll = 0 — Bestätigung erforderlich *(Run 317)*
- [ ] Bistro-Soll > Kino-Soll — weicher Hinweis: in Run 316
      umgesetzt, in Run 316a wieder entfernt. Grund: Prämisse
      trifft nicht standortübergreifend zu — in der Gondel gibt
      es Restaurant-Umsatz aus der Küche, dort kann Bistro-Soll
      legitim höher sein als Kino-Soll. Vorerst bewusst offen
      gelassen (MA prüfen Eingabe manuell); bei Bedarf durch die
      Kino-Leitung ggf. später standortabhängig wieder einführen.
- [x] Soll-Felder leer beim Abschluss-Start — Pflichtfeld: war
      bereits umgesetzt (`_pruefePflichtfelderVorSchritt3()` prüft
      Kino- und Bistro-SOLL), TODO-Punkt war veraltet. *(geprüft
      Run 316)*

### EC-Umsatz
- [ ] EC-Betrag > Gesamt-Soll — harter Fehler
      *(Run 317: weggelassen — im Ziffern-Modus kein realistisches Risiko.)*
- [x] EC = 0 an normalem Betriebstag — Bestätigung *(Run 317)*

### Differenz / Kassenstand
- [ ] Differenz Soll/Ist überschreitet Schwellwert (± 50 €) — Bestätigung
      *(Run 317: weggelassen — Schritt 3 zeigt Differenz bereits rot/grün,
      Dialog wäre redundante Friction.)*
- [ ] Ist > Soll — Warnung mit Erklärungstext
      *(Run 317: weggelassen — grüne Differenz in Schritt 3 reicht.)*
- [x] Differenz Anfangsbestand ≠ 0 — abweichend von der
      ursprünglichen Planung (weicher Hinweis > 20 € beim Zählen)
      auf Bestätigungssperre umgestellt: Ein passiver Hinweis beim
      Zählen hätte das eigentliche Problem (MA übersieht/ignoriert
      die Differenz) nicht gelöst. Stattdessen prüft
      `_pruefeDifferenzUndBestaetigeVerlassen()` in
      `wechselgeld_pruefen_seite.dart` beim Verlassen der Seite, ob
      die Differenz zum Wechselgeld-Sollwert exakt 0 ist — jede
      Abweichung, kein Schwellwert. Bei Abweichung: Bestätigungsdialog
      "Trotzdem fortfahren?". Der Dialog öffnet sich vor (nicht nach)
      dem Abschluss-Menü "Was möchtest du als nächstes tun?".
      Deckte ursprünglich nur den Fertig-Button ab — Zurück-Pfeil und
      Haus-Button umgingen die Prüfung komplett. Seit Run 319a via
      `PopScope` (Zurück-Pfeil/System-Zurück) und geprüftem
      Haus-Button auf allen drei Ausgängen der Seite aktiv.
      *(Run 314 → korrigiert in Run 314a, Timing korrigiert in
      Run 314a2)*

### Belege / Ausgaben
- [x] Beleg angelegt, Betrag = 0 oder leer — Pflichtfeld *(Run 317)*
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
