# TODO-ARCHIV — kino_bar_app (erledigte Punkte)

Ausgelagert aus TODO.md (Run 323). Gleiche Abschnittsstruktur wie
TODO.md, aber nur erledigte ([x]) Punkte mit ihrer Begründung/Historie.
Bei Bedarf hier weiter ergänzen, wenn Punkte in TODO.md abgehakt werden.

---

## 🔴 Blockiert — wartet auf IT (Yannik)

- [x] **location_id pro Standort** Welche interne Flurbocash-ID hat jeder Standort?
      (Schauburg, Gondel, Atlantis, Cinema Ostertor, Bar Tabak)
      Teilweise beantwortet (Mail Yannik, 2026-07-12): Schauburg = 1,
      Atlantis = 3, Bar Tabak = 4. Gondel/Cinema Ostertor noch offen —
      laut Plan aber erst relevant, wenn SB vollständig läuft.

- [x] **X-API-Key** Tatsächlicher Schlüssel — ein Key für alle oder je einer
      pro Standort, nach Yanniks Ermessen.
      Beantwortet (Mail Yannik, 2026-07-12): je ein eigener Key pro
      Standort, kein gemeinsamer Key für alle. Die konkreten Key-Werte
      stehen NICHT hier, sondern nur in den App-Einstellungen pro Kino.

- [x] **CORS-Header** Server muss `Access-Control-Allow-Origin: *` senden.
      Bereits konfiguriert?
      Erledigt (Stand 2026-07-14): Yannik hat X-API-Key zu
      access-control-allow-headers ergänzt ("x-api-keys sind nun
      erlaubt"). Erster echter Live-Test für Schauburg (location_id 1)
      erfolgreich — Tagesbericht kam im Flurbocash-Dashboard korrekt
      an (Bargeld + EC-Kartenaufschlüsselung stimmen exakt mit der
      App-Eingabe überein).

- [x] **Testumgebung** Gibt es eine Staging-Instanz von Flurbocash?
      Ja: Sandbox unter https://sandbox.flurbocash.c137-prime.de:666
      (Stand 2026-07-12, wird aktuell für alle Tests genutzt).

---

## 🟢 Kleine Fixes (je < 1h, direkt umsetzbar)

- [x] **Alle SnackBars auf Orange umstellen** Aktuell uneinheitliche
      Farben je nach Kontext. Einheitlich auf Orange
      (App-Akzentfarbe) umstellen.
      *(Run 372a)* Umgesetzt wie beschrieben: alle 16 SnackBar-Aufrufe
      app-weit auf `AppFarben.fokusFarbe` (Hintergrund) +
      `AppFarben.appBarRot` (Text) vereinheitlicht — bewusst auch die
      bisher neutralen Fehler-/Rand-Meldungen (z. B. "Falscher PIN",
      "API Upload fehlgeschlagen"), nicht nur die "führenden"
      Hinweise. Grund (Paco): SnackBars wurden oft übersehen, weil sie
      zu unauffällig waren oder beim Bedienen vom Daumen verdeckt
      wurden — Sichtbarkeit geht hier vor der bisherigen Farbkonvention
      "Orange nur für den glatten Ablauf".

- [x] **Schwarze Hervorhebungen → Kino-Rot** Sämtliche schwarze Feld-Hervorhebungen auf `AppFarben.appBarRot` umstellen. *(Run 302–302d)*

- [x] **Textbutton "zuklappen"** Die Seite soll einen Textlink "alle zuklappen"
      (bzw. aufklappen) bekommen, der alle Kacheln schließt, um dem MA eine bessere Übersicht zu geben.
      *(Run 303 — umgesetzt für Schritt 1 und Wechselgeld-Prüfen-Seite)*

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

- [x] **Pfeiltasten der iOS-Tastaturleiste navigieren nicht** Die
      Werkzeugleiste über der Zifferntastatur (▲▼ + Haken) ist native
      iOS-Safari-Chrome, kein App-Bestandteil. Der Haken ist die
      App-eigene "Weiter"-Aktion (`TextInputAction.next` +
      `FeldNavigationHelper`, seit Run 323/323a korrekt). Die
      Pfeiltasten sind Safaris eigene Vor-/Zurück-Navigation zwischen
      Formularfeldern und laufen ins Leere: Flutter Web nutzt ohne
      `AutofillGroup` (hier nicht verwendet) ein einziges verstecktes
      HTML-Inputfeld für alle Felder — der Browser sieht dadurch kein
      "nächstes Feld" im DOM. Nur mit größerer Architekturänderung
      behebbar (echte Einzel-Inputs je Feld). Kein Blocker: Zielplattform
      ist durchgängig Android, diese iOS-Safari-spezifische Leiste tritt
      dort in dieser Form i. d. R. nicht auf. *(dokumentiert Run 323b)*

- [x] **Kein Screen-Flip** App soll beim Drehen des Smartphones
      hochkant bleiben. Die Manifest-/SystemChrome-Sperre (siehe
      `main.dart`, `web/manifest.json`) wird von iOS/Safari
      unzuverlässig umgesetzt (bestätigt fehlerhaft, Run 319b) — auf
      der eigentlichen Zielplattform (vorkonfigurierte Android-Geräte)
      tritt das Problem laut Paco-Test aber nicht auf. Da iOS nur
      Pacos private Testumgebung ist, gilt der Punkt auf der
      Zielplattform als erledigt. *(Run 357)*

- [x] **Kartensumme ↔ EC-Gesamtbetrag nach manuellem Nachtrag** Seit
      Run 274f4 gibt es in der Kartenarten-Tabelle einen "+
      Kartenart"-Button zum nachträglichen Einblenden nicht erkannter
      Kartenarten. Geklärt (keine Code-Änderung nötig): Der
      Warnhinweis "Kartensumme stimmt nicht mit dem eingetragenen
      EC-Gesamtbetrag überein" (`schritt2_ui_builder.dart`,
      `summePasstNicht`) reagiert bereits live auf den Vergleich und
      verschwindet automatisch, sobald ein Nachtrag beide Werte
      angleicht. Der EC-Gesamtbetrag bleibt bewusst ein unabhängig
      vom Scan eingelesener Wert statt einer berechneten Summe —
      sonst ginge die Kreuzvalidierung gegen Scan-Fehler bei
      einzelnen Kartenarten verloren. *(Run 357)*

---

## 🟡 Mittlere Features (eigenständige Funktionsblöcke)

### BelegScan & EC-Kachel *(Phase A, Runs 275–281)*

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

- [x] **Standort-Betriebsmodus (Admin)** Im Verwaltungsbereich einstellbar,
      für welchen Standort das Gerät arbeitet: „Alle" oder ein festes Kino.
      Ist ein einzelner Standort gewählt, entfällt für MA die Kinoauswahl
      UND der Textbutton "Kino wechseln" auf der Startseite wird
      ausgeblendet — er erscheint nur, wenn "Alle" eingestellt ist. Wie
      geplant umgesetzt. Speicherung lokal auf dem Gerät (SharedPreferences,
      kein Backend). Datenschutzhinweise-Link ist seit Run 321 bereits
      zusätzlich auf startmenue_seite.dart vorhanden, bleibt also auch bei
      entfallender Kinoauswahl erreichbar. *(Run 325)*

- [x] **BelegScan-Service-URL editierbar** Neues TextField "Service-URL"
      im Admin-Bereich (Abschnitt "KI-Belegscan (Anthropic)"), über dem
      Anthropic-API-Key-Feld — analog zu Upload-URL/location_id/API-Key.
      `BelegScanService.ladeWorkerUrl()` liest den Wert aus
      SharedPreferences (Key `belegscan_service_url`), Fallback auf
      `standardWorkerUrl` (bisher hart codiert als `_workerUrl`) wenn
      leer/nicht gesetzt. *(Run 332; entdeckt bei Testfeedback zu
      Run 329, dort als eigener TODO-Punkt aufgenommen.)*

- [x] **PIN-Schutz Verwaltungsbereich** PIN (1929/Session) + location_id +
      API-Key-Felder in Runs 287/291/292 umgesetzt. Basis-URL-Feld
      ("Upload-URL", SharedPreferences-Key `api_upload_url`) war entgegen
      dem bisherigen TODO.md-Stand bereits seit Run 292 vorhanden — bei
      der Run-329-Recherche festgestellt, TODO.md-Eintrag war veraltet.
      Kein neuer Code nötig. *(Runs 287/291/292; TID-Whitelist +
      Buchhaltungs-E-Mail sind eigene, weiterhin offene Punkte.)*

- [x] **Admin-Passwort** Bleibt bei PIN 1929 (Session) — kein Wechsel zu
      festem Passwort gewünscht.

- [x] **Fallback-Export bei fehlgeschlagenem Upload** Nicht nötig — die
      Abrechnung wird bereits unabhängig vom Upload-Ergebnis automatisch im
      Verlauf gespeichert (siehe "Automatisches Geräte-Backup beim Senden"
      weiter unten). Ein zusätzlicher Datei-Export wäre nur bei konkretem
      Bedarf sinnvoll (z. B. Weitergabe an Buchhaltung bei Langzeitausfall
      des Uploads).

### Flurbocash API-Integration *(Phase E — wartet auf IT)*

### Stapel-Scanner *(Phase D/E — wartet auf IT)*

### Weitere Features

- [x] **Automatisches Geräte-Backup beim Senden** Abrechnung wird
      lokal gespeichert, unabhängig vom Upload-Ergebnis. *(bereits
      umgesetzt — `_autoSaveImHintergrund()` in
      tagesabschluss_schritt3_seite.dart speichert automatisch beim
      Erreichen von Schritt 3, noch vor SENDEN; Schritt 3 hat keine
      editierbaren Felder, die danach noch verloren gehen könnten.)*

- [x] **Verlauf — 30-Tage-Bereinigung** Abgeschlossene Abrechnungen
      automatisch nach 30 Tagen löschen (Datenschutz). *(Run 311)*

- [x] **Getränkeliste: Abhaken bei "nur benötigte anzeigen"** Im
      Filtermodus "nur benötigte anzeigen" bekommt jede Zeile eine
      runde Checkbox; abgehakte Einträge wandern ans Ende der
      gefilterten Liste, unabgehakte behalten ihre Reihenfolge. Bei
      "alle anzeigen" keine Checkbox, Grundreihenfolge unverändert.
      Abhak-Status bewusst nicht persistiert (reine
      Session-Sortierhilfe). *(Run 328)*

---

## 🔴 Größere Umbauten

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

### Soll-Felder
- [x] Kino-Soll = 0 — Bestätigung erforderlich *(Run 317)*

- [x] Soll-Felder leer beim Abschluss-Start — Pflichtfeld: war
      bereits umgesetzt (`_pruefePflichtfelderVorSchritt3()` prüft
      Kino- und Bistro-SOLL), TODO-Punkt war veraltet. *(geprüft
      Run 316)*

### EC-Umsatz
- [x] EC = 0 an normalem Betriebstag — Bestätigung *(Run 317)*

### Differenz / Kassenstand
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

### Zeitliche Plausibilität

### Fehlerstufen

| Stufe | Verhalten |
|---|---|
| Harter Fehler | Weiter nicht möglich |
| Bestätigung | Weiter nach explizitem „Ja, stimmt so" |
| Weicher Hinweis | Hinweis angezeigt, Weiter jederzeit möglich |

---

## ↔️ Roadmap / Post-MVP

