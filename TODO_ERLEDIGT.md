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

- [x] **Geschäftstag-Cutoff von 6 auf 5 Uhr umstellen** Yannik hat
      bestätigt: Flurbocash erwartet den logischen Geschäftstag mit
      Knick um 5 Uhr, nicht 6 Uhr wie bisher in der App.
      *(Run 403)* Umgesetzt wie beschrieben: reiner Wertewechsel
      `DatumsHelper._geschaeftstagCutoffStunde` 6 → 5. Bestehende
      Tests, die die alte Grenze bei 5:59 Uhr prüften
      (datums_helper_test.dart,
      tagesabschluss_finalisieren_usecase_test.dart), auf die neue
      Grenze (4:59 Vortag / 5:00 aktueller Tag) umgestellt statt
      entfernt. Veralteter "6-Uhr-Knick"-Kommentar in
      lokaler_speicher.dart korrigiert.

- [x] **Gesendet-Häkchen im Startmenü erscheint seit Run 401 nie mehr**
      REGRESSION durch Run 401, von Paco bestätigt (2026-08-30): das
      grüne Häkchen fehlte komplett, auch nach einem erfolgreichen
      echten Versand, weil `_pruefeAbrechnungHeuteGesendet()`
      (startmenue_seite.dart) ein `isoDatum`-Feld aus der Sende-Signatur
      las, das seit Run 401 dort nicht mehr vorkommt.
      *(Run 402)* Umgesetzt wie in der Fix-Richtung beschrieben (Option
      "separates Datum"): `LokalerSpeicher.speichereSendeBestaetigung()`
      speichert das logische Sendedatum jetzt in einem eigenen
      SharedPreferences-Key, unabhängig von Inhalt/Format der Signatur.
      `_pruefeAbrechnungHeuteGesendet()` liest dieses Feld direkt statt
      es aus der Signatur zu parsen. Geräte mit einer Signatur aus der
      Zeit vor Run 402 zeigen einmalig "nicht gesendet", bis zum
      nächsten echten Versand — bewusst in Kauf genommen, gleiches
      Verhalten wie beim Formatwechsel in Run 401. Vier neue Tests in
      lokaler_speicher_test.dart.

- [x] **Standort-Wechsel schließt offene Kino-Seite nicht** Ist man auf
      einer Kino-spezifischen Seite (z. B. Atlantis-Startseite) und
      wechselt in den Einstellungen den Standort (z. B. auf Schauburg)
      und geht dann zurück, bleibt die alte Kino-Seite (Atlantis)
      offen, statt zur neu gewählten Standort-Seite (SB) zu wechseln.
      *(Run 379)* Umgesetzt wie beschrieben: _ladeDaten() in
      startmenue_seite.dart (läuft bei initState() und didPopNext())
      leitet jetzt per pushReplacementNamed auf die StartmenueSeite des
      aktuell aktiven Standorts um, sobald der geladene Standort-Modus
      von der Kino-ID der aktuellen Seite abweicht.

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

- [x] **TID-Abgleich gegen config/terminal_ids.json (Warnung)** Ausgelöst
      durch Diagnose zu falsch ankommenden Flurbocash-Beträgen. Neuer
      `TerminalIdsConfigService` lädt config/terminal_ids.json (jetzt als
      Asset gelistet); `ApiUploadService.pruefeTerminalIdsGegenKonfiguration()`
      vergleicht die zu sendenden TIDs damit und liefert Warnungen statt
      zu blockieren — die Referenzliste ist laut Punkt "Registrierte TIDs
      pro Standort" oben noch nicht von Yannik bestätigt, ein harter Block
      hätte also potenziell korrekte Abrechnungen verhindern können.
      `ApiUploadService.upload()` liefert jetzt `Future<List<String>>`
      (Warnungen), Schritt 3 hängt sie an die Erfolgs-SnackBar an, ohne den
      Versand zu stoppen. Abweichung vom ursprünglich geplanten Punkt
      "TID-Whitelist konfigurierbar + Abgleich beim Scannen": Prüfung
      liegt jetzt beim Upload (Schritt 3), nicht beim Scannen (Schritt 2),
      und die TIDs kommen weiterhin aus der statischen JSON-Datei, nicht
      aus editierbaren Einstellungen-Feldern. Diese zwei Teilaspekte
      bleiben als eigener, kleinerer Punkt in TODO.md offen. *(Run 399)*

### Flurbocash API-Integration *(Phase E — wartet auf IT)*

- [x] **0-EUR-Terminal-Upload ohne Fehlermeldung** In
      `api_upload_service.dart` (`_terminalsListe()`) wurde bei
      leerer `zahlungsartenAufschluesselung` bisher immer ein
      Terminal-Eintrag mit lauter 0-Beträgen hochgeladen — auch
      wenn `ecUmsatzGesamtCent > 0` war (z. B. MA trägt beim
      EC-Beleg nur den Gesamtbetrag ein, ohne je eine
      Kartenart-Zeile auszufüllen). Jetzt harter Fehler: Exception
      mit Betrag in der Meldung, läuft über den bestehenden
      Catch-Block in Schritt 3 als SnackBar. Bundle-Fix im selben
      Codepfad: reine Bargeldtage senden jetzt ein leeres
      terminals-Array statt eines Phantom-Eintrags mit leerer
      Terminal-ID. Kein Fallback auf ein geschätztes Kartenfeld
      (bewusst verworfen — die API hat kein "unbekannt"-Feld,
      eine feste Kartenart zu raten wäre falsche Buchhaltungsdaten).
      *(Run 386; entdeckt bei Codebasis-Analyse 2026-08-16.)*

- [x] **Belegfoto als base64 an Flurbocash** Yannik hat den Vertrag per
      Beispiel-PUT geliefert (2026-08-26): `terminals[].receipt_photo`
      (base64, unveränderte JPEG-Rohbytes vom Kamera-Foto) +
      `terminals[].receipt_media_type`. `BelegScanService.scan()` gibt
      das beim KI-Call bereits kodierte Foto jetzt mit zurück (Record
      statt nur `BelegScanErgebnis`), Schritt 2 hält es pro Beleg-Index
      parallel zu `_ecBelegLabels` (TID) vor, `TagesabschlussFinal` trägt
      es dauerhaft (auch für Verlauf/Wiederversand). In
      `api_upload_service.dart` wird das Foto pro TID zugeordnet
      (`_fotoProTid()`) und nur mitgeschickt, wenn eins vorliegt; bei
      zwei Beleg-Scans derselben TID gewinnt der zuletzt gescannte
      (nicht summierbar wie die Kartenbeträge). Zusätzlich im selben Run
      ergänzt, weil fachlich zusammengehörig: `note` (Kommentarfeld,
      im Dev-Modus automatisch um "testdaten" ergänzt, damit
      Auto-Fill-Testabrechnungen für Yannik erkennbar bleiben) und
      `sent_at` (ISO-Zeitstempel des Sendevorgangs, laut Yannik
      serverseitig ignoriert falls FC das Feld nicht braucht).
      `EXTERNAL_API_Schauburg_de.md` entsprechend aktualisiert. Verlauf
      zeigt gescannte Belege zusätzlich als antippbare Miniaturansicht
      mit Vollbild-Zoom (`verlauf_detail_seite.dart`); ein Export/Teilen-
      Button dafür ist noch offen — siehe TODO.md, wartet auf Freigabe
      für ein Umsetzungsdetail (neue Dependency vs. Web-Download).
      *(Run 399a)*

- [x] **Terminals bei doppelter TID am selben Tag** Von Yannik
      beantwortet (`.dev/flurbocash stuff/fragen_yannik.md`, Frage 2.1,
      2026-08-26): zwei EC-Belege derselben TID sollen als zwei
      separate `terminals[]`-Einträge übertragen werden, nicht zu
      einer Zeile summiert. Beim Live-Test von Run 399a durch Paco
      (zwei Belege TID 54017635, SB) tatsächlich als Bug aufgefallen:
      `_terminalsListe()` summierte beide Belege in eine Zeile. Fix:
      `ZahlungsartErgebnis` bekommt ein neues `belegIndex`-Feld
      (gesetzt in `_baueZahlungsartenListe()`), `_terminalsListe()`
      gruppiert primär danach statt nach TID-Text — jeder Beleg wird
      ein eigener Eintrag, auch bei gleicher TID. `_fotoProTid()` zu
      `_fotoProGruppe()` erweitert (gleiches Schema), wodurch auch die
      "letztes Foto gewinnt bei gleicher TID"-Unschärfe aus Run 399a
      für neue Daten entfällt — jeder Beleg hat jetzt ohnehin nur sein
      eigenes Foto. Für vor diesem Fix gespeicherte Abrechnungen ohne
      `belegIndex` (z. B. "Erneut senden" aus dem Verlauf) bleibt die
      alte TID-Gruppierung als Fallback erhalten. *(Run 399a3)*

- [x] **Schutz vor doppeltem Versand derselben Abrechnung** Konkreter
      Bug beim Code-Durchspiel der Szenarien "2x versandt"/"korrigiert +
      erneut versandt"/"gar nicht versandt" gefunden (2026-08-29): In
      tagesabschluss_schritt3_seite.dart war der Sende-Button nur
      während des Auto-Saves gesperrt (`buttonGesperrt =
      _autoSaveLaeuft`), nicht während des laufenden Uploads. Ein
      zweiter, schneller Tap während die erste Anfrage noch offen war,
      löste tatsächlich einen zweiten, parallelen `_doApiUpload()`-Aufruf
      aus. Fix: `buttonGesperrt` um `_apiUploadLaeuft` erweitert, analog
      zum bereits korrekten Muster in verlauf_detail_seite.dart
      (`_erneutSenden()`, dort schon immer über `_sendet` gesperrt).
      EINSCHRÄNKUNG: Der Fall "erneuter Versand nach unklarem
      Netzwerk-Ergebnis" (App neu geöffnet, Status unklar) ist damit
      NICHT abgedeckt.
      KORRIGIERT (2026-08-30): Die ursprüngliche Notiz hier ("Flurbocash
      scheint das gutmütig zu behandeln, PUT überschreibt denselben
      reportId") war eine unverifizierte Vermutung und ist FALSCH — per
      `.dev/flurbocash stuff/EXTERNAL_API_Schauburg_de.md` bestätigt:
      ohne explizit gesetztes `settlement_number` legt jeder PUT-Aufruf
      eine ZUSÄTZLICHE Abrechnung an (bis zu 4/Tag), überschreibt NICHT
      die vorherige. Ein erneuter Versand nach unklarem Ergebnis ist
      also serverseitig NICHT automatisch harmlos. Siehe TODO.md,
      Punkt "'Erneut senden' → Korrektur-Call" — dort mit den Details
      und dem Hinweis, dass ein Fix erst nach Pacos eigenen
      Sandbox-Tests verschiedener Szenarien angegangen wird. *(Run 400,
      Korrektur 2026-08-30)*

### Stapel-Scanner *(Phase D/E — wartet auf IT)*

### Verlauf

- [x] **Übertragungs-Flag je Verlaufseintrag** Neues Feld `gesendetAm`
      (DateTime?, nullable) in `TagesabschlussFinal`. Wird nach
      erfolgreichem Upload (inkl. CORS-Sonderfall, der schon vorher
      als "gesendet" galt) über die neue Methode
      `LokalerSpeicher.markiereAlsGesendet(kinoId, createdAt,
      zeitpunkt)` am gespeicherten Eintrag gesetzt — Abgleich über
      `createdAt`, damit Kinos mit mehreren Abrechnungen/Tag (z. B.
      Bar Tabak) den richtigen Eintrag treffen. Neues Badge
      "Noch nicht gesendet" (`nicht_gesendet_badge.dart`, neutrales
      Grau statt Orange, da Orange als Führungsfarbe reserviert ist)
      in `verlauf_seite.dart` (Liste) und `verlauf_detail_seite.dart`
      (Detail-Titel). Alte, vor diesem Run gespeicherte Einträge
      haben `gesendetAm == null` und erscheinen daher pauschal als
      "noch nicht gesendet", unabhängig vom tatsächlichen früheren
      Sende-Erfolg — rückwirkend nicht rekonstruierbar. *(Run 387)*

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

- [x] **Fehlendes Auto-Save nachziehen** Codebasis-Analyse (2026-08-16)
      fand drei Stellen ohne `_speichereEntwurf()`-Aufruf — eingegebene
      Werte gingen dort bei App-Neustart verloren: Schritt 1
      `_entferneKupferLose()`/`_entferneKupferRollen()` (setzten
      Kupfer-Werte auf 0 zurück, ohne den Entwurf zu speichern) und
      Schritt 2 `onZeileBetragGeaendert` (Kartenart-Einzelbetrag-Feld
      in der aufgeklappten Kartenarten-Tabelle). Alle drei ergänzt —
      Schritt 1 analog zum bestehenden Muster als `await
      _speichereEntwurf()` in den jetzt async Methoden, Schritt 2
      analog zu den benachbarten Zeilen-Callbacks als
      Fire-and-forget-Aufruf ohne await. *(Run 385)*

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

