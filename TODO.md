# TODO — kino_bar_app
Stand: September 2026 · Run 428 · wird fortlaufend ergänzt

Erledigte Punkte stehen nicht mehr hier, sondern in TODO_ERLEDIGT.md
(gleiche Abschnittsstruktur) — sie werden bei jedem Run per Read
abgeglichen, daher hält diese Datei nur die offenen Punkte schlank.
Neu erledigte Punkte beim nächsten Archivierungs-Run dorthin verschieben.

**Aktueller Fokus (Paco, seit 2026-08-30):** korrekte Dateneingabe durch
die MA und klare Benutzerführung (damit MA nicht durch die App irritiert
werden und dadurch Fehler machen) hat Vorrang vor rein technischen
Themen wie der Flurbocash-`settlement_number`-Korrektur-Logik — letztere
bewusst zurückgestellt, bis Paco selbst verschiedene Szenarien in der
Sandbox getestet hat (siehe Punkt "'Erneut senden' → Korrektur-Call"
unten). Runs werden einzeln, nacheinander abgearbeitet statt parallel,
um Durcheinander zu vermeiden.

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
      Siehe auch "TID-Whitelist konfigurierbar + Abgleich beim Scannen"
      weiter unten (UI/Prüf-Logik dafür, unabhängig von dieser
      Datenklärung).

- [ ] **Weitere Abrechnungsfelder** Kino-Soll, Bistro-Soll, Ausgaben,
      Differenz werden laut Yannik NICHT benötigt (Flurbocash zieht
      sich `system_total_cents` selbst aus dem Kassensystem; siehe
      `.dev/flurbocash stuff/fragen_yannik.md`, Frage 2.2, beantwortet).
      Offen bleibt nur noch: Mitarbeitername — laut Frage 2.3 war das
      als zusätzliches freies JSON-Feld mitgeplant (analog zu `note`/
      `sent_at`, seit Run 399a umgesetzt), aber bisher nicht in
      `settlementsBody()` ergänzt.

- [ ] **Konfiguration der Geräte** Wer richtet die Smartphones ein — IT oder MA?
      Wer pflegt Änderungen (neuer API-Key, neue TID)?

- [ ] **Stapel-Scanner: Übertragungsformat** Wie sollen gesammelte EC-Belege
      an Flurbocash gehen — einzeln (je ein 2-Call-Flow) oder als Batch?
      Separater Endpunkt oder derselbe wie die Tagesabrechnung?

---

## 🟢 Kleine Fixes (je < 1h, direkt umsetzbar)

- [ ] **Offline-Hinweis bei BelegScan konkretisieren** Die
      Verbindungsprüfung beim Tap aufs Foto-Icon existiert bereits
      (`_starteEcBelegScan()` in tagesabschluss_schritt2_seite.dart,
      `Connectivity().checkConnectivity()`), zeigt aber nur die
      generische SnackBar "Kein Internet – Scan nicht möglich."
      Ergänzen: Hinweis, dass die Kartenzahlungsdaten stattdessen
      manuell eingegeben werden können/müssen (analog zum
      bestehenden Hinweistext bei unscharfem Foto/Netzwerkfehler,
      Run 329/329a). Siehe auch Roadmap-Punkt "Offline-Hinweis"
      weiter unten (allgemeiner Banner app-weit, anderer Ort/Umfang).

- [ ] **Gesendet-Haken verschwindet nicht über den 6-Uhr-Knick, wenn
      App im Hintergrund bleibt** Der grüne Haken auf dem
      "Kassenabrechnung"-Button im Startmenü wird nur bei
      `initState()` und `didPopNext()` (Rückkehr von einer anderen
      Seite) neu geprüft (`_pruefeAbrechnungHeuteGesendet()` in
      startmenue_seite.dart) — es gibt keinen
      AppLifecycleState-Listener für den Fall, dass die App nur in
      den Hintergrund geschickt ("weggewischt", nicht beendet) und
      über den 6-Uhr-Knick hinweg wieder in den Vordergrund geholt
      wird, ohne dass zwischendurch navigiert wurde. Die Prüfung
      selbst berücksichtigt den logischen Tag korrekt
      (`DatumsHelper.logischesIsoDatum()`), sie wird in diesem Fall
      nur nicht erneut ausgeführt. Beobachtet von Paco: App um 10:45
      geöffnet, grüner Haken noch vom Vortag sichtbar. Nicht zu
      verwechseln mit dem bereits in Run 396a behobenen Fall (Haken
      blieb nach Löschen der heutigen Abrechnung stehen) — hier fehlt
      das erneute Prüfen beim Resume, nicht das Löschen der
      Sende-Signatur.

- [ ] **Sendebestätigung nach Flurbocash-Versand als Popup statt Snackbar**
      Nach erfolgreichem Versand (`_doApiUpload()` in
      tagesabschluss_schritt3_seite.dart, analog `_erneuthSenden()` in
      verlauf_detail_seite.dart) erscheint die Bestätigung
      ("API Upload erfolgreich ✓") nur als SnackBar — kann
      übersehen/weggewischt werden. Gewünscht: eigenes Popup mit
      Pflicht-Bestätigung ("ok"/"verstanden"). NICHT zu verwechseln mit
      der bereits umgesetzten TID-Prüfung im Bestätigungs-Popup VOR der
      Beleg-Übernahme in Schritt 2 (siehe "TID-Whitelist editierbar"
      unten) — hier geht es um die Bestätigung NACH dem tatsächlichen
      Versand. Seit Run 414 gibt es bei erfolgreichem Versand keine
      "... — Achtung: TID-Warnungen" mehr (eine TID-Abweichung
      blockiert den Versand jetzt komplett, statt als Warnung neben
      einem erfolgreichen Versand zu erscheinen) — dieser Punkt betrifft
      also nur noch die reine Erfolgsbestätigung.

- [ ] **Ausgaben-/Sonstiges-Zeilen: Label-Feld breiter, Betrag-Feld
      schmaler** Betrifft zwei Stellen: `_Schritt2AusgabenZeile`
      (schritt2_kino_soll_ausgaben_section.dart, Abschnitt "Ausgaben"
      in Schritt 2) und `Schritt1UmschlaegeSection`
      (schritt1_umschlaege_section.dart, Abschnitt "Sonstiges
      (Umschläge u.a.)" in Schritt 1). Das Betrag-Feld
      (`BetragCentEingabefeld`) zeigt bei Text einen "+"-Additions-Chip
      und einen "x"-Clear-Chip im Suffix; bei den Umschlägen zusätzlich
      ein floatendes Label "Betrag €". Alle drei entfernen, damit das
      feste Betrag-Feld schmaler werden kann und das ohnehin schon
      `Expanded`-Label-Feld mehr Platz bekommt. `zeigeAdditionsButton`
      existiert bereits als Parameter (auf `false` setzen reicht für
      den "+"-Chip); für den Clear-Chip gibt es noch keinen Parameter —
      neuer optionaler Parameter (z. B. `zeigeClearButton`, Default
      `true`) nötig, damit andere Aufrufstellen unverändert bleiben.

- [ ] **CocoaPods → Swift Package Manager migrieren (ios/)**
      KORRIGIERT (Run 398a2): Ursprüngliche Annahme "iOS wird nicht
      gebraucht" war falsch — Paco nutzt die native iOS-App aktiv
      zum schnellen Design-Testen, ein natives iOS-Build bleibt also
      Pflicht. Tatsächlicher Hintergrund des Punkts: Apple/Flutter
      ersetzen CocoaPods durch Swift Package Manager (SPM) als
      Standard-Abhängigkeitsverwaltung für iOS/macOS — ab Flutter
      3.44 (Projekt nutzt 3.44.5) ist SPM bereits Standard, die
      CocoaPods-Registry wird laut Flutter-Team am 2. Dezember 2026
      dauerhaft read-only (Quelle:
      flutter.dev/blog/saying-goodbye-to-cocoapods-swift-package-manager-is-soon-the-default-in-flutter,
      docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers).
      Stand in diesem Projekt (geprüft 2026-08-22): Die
      SPM-Integration ist im Xcode-Projekt bereits vorhanden
      (`FlutterGeneratedPluginSwiftPackage` mehrfach in
      ios/Runner.xcodeproj/project.pbxproj) — vermutlich automatisch
      durch die Flutter-CLI beim letzten `flutter run`/`build` fürs
      iOS-Target ergänzt. `ios/Podfile.lock` listet aktuell nur noch
      den internen "Flutter"-Pod, keinen einzigen echten Plugin-Pod
      mehr — alle aktuellen Dependencies (hive_ce,
      shared_preferences, http, image_picker, connectivity_plus,
      google_fonts) laufen bereits über SPM, CocoaPods läuft
      praktisch leer mit.
      Nächster Schritt: Vor dem Entfernen von `ios/Podfile`,
      `ios/Podfile.lock` und `ios/Pods/` einmal einen echten
      `flutter build ios` (oder App-Start über Xcode, auf echtem
      Gerät/Simulator) durchführen und bestätigen, dass der native
      Build auch ohne Podfile weiterhin sauber läuft — erst danach
      die CocoaPods-Dateien entfernen. Kein Zeitdruck vor Dezember
      2026, aber unkritisch früh erledigbar.

- [ ] **"Bargeldbestand" → "Bar-Umsatz" umbenennen** KLÄRUNGSBEDÜRFTIG
      (Paco-Notiz 2026-08-30): Der Begriff "Bargeldbestand" kommt als
      Literal-String aktuell NIRGENDS im Code vor (geprüft per grep) —
      Paco meint vermutlich den bereinigten Bar-Bestand
      (`barBestandAbzglWechselgeldCent`), den wir im Gespräch selbst so
      genannt haben. Kandidaten dafür in der UI: Schritt 3 "+ bar IST"
      (`schritt3_ist_section.dart:28`) und/oder Verlauf-Detail
      "Bar-Bestand bereinigt" (`verlauf_detail_seite.dart:456`) — beides
      derselbe Wert, unterschiedlich beschriftet. Vor Umsetzung klären:
      welche der beiden (oder beide) soll auf "Bar-Umsatz" geändert
      werden? (Schritt 1 "Kassenbestand gesamt" ist ein ANDERER, noch
      nicht um Wechselgeld bereinigter Wert — vermutlich nicht gemeint.)

- [ ] **"testdaten"-Kommentar verschwindet nicht, wenn Dev-Modus wieder
      ausgeschaltet wird** (Paco-Notiz 2026-08-30, verifiziert) Aktueller
      Stand: `_wendeDevModusKommentarAn()`
      (tagesabschluss_schritt2_seite.dart:867-876) füllt das
      Kommentarfeld nur automatisch, wenn Dev-Modus AN ist und das Feld
      noch leer ist — es LÖSCHT das Feld aber nie, wenn Dev-Modus wieder
      AUS ist. Ein zuvor mit Dev-Modus erzeugter/geladener
      "testdaten HH:mm"-Kommentar (z. B. aus einem gespeicherten
      Entwurf) bleibt also stehen, auch nachdem Dev-Modus deaktiviert
      wurde — Risiko, dass er unbemerkt in eine ECHTE Abrechnung
      mitgesendet wird. Gewünscht: bei Dev-Modus AUS soll kein
      automatisch gesetzter "testdaten"-Text mehr im Feld stehen —
      MA füllt das Kommentarfeld dann bei Bedarf manuell aus. Bei der
      Umsetzung vorsichtig sein: nur automatisch gesetzten Text löschen,
      nicht einen echten, vom MA getippten Kommentar, der zufällig das
      Wort "testdaten" enthält (z. B. eigenes Feld/Flag statt reinem
      Text-Vergleich). Hängt inhaltlich mit dem Punkt "Kommentar:
      Sendezeitpunkt erst unmittelbar beim Senden ergänzen/ersetzen"
      oben zusammen (beide betreffen denselben Mechanismus) — bei
      Umsetzung zusammen betrachten, nicht als zwei unabhängige Patches.

---

## 🟡 Mittlere Features (eigenständige Funktionsblöcke)

### BelegScan & EC-Kachel *(Phase A, Runs 275–281)*

- [ ] **Duplikat-Button** KLÄRUNGSBEDÜRFTIG (Run 364a2): Ursprünglicher
      Zweck ist nicht mehr rekonstruierbar — weder CHANGELOG.md noch
      CHANGELOG_ARCHIV.md noch TODO_ERLEDIGT.md enthalten eine
      funktionale Beschreibung, nur den Werdegang (siehe unten).
      Paco selbst weiß es auf Nachfrage (Run 364a2) nicht mehr. Vor
      einer Umsetzung erst klären, wofür der Button gedacht war/sein
      soll — sonst bleibt offen, ob der Punkt überhaupt noch relevant
      ist oder gestrichen werden kann.
      Werdegang: Ursprünglich zusätzlich als Dummy-Button im
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

- [ ] **TID-Whitelist editierbar** Der eigentliche Abgleich (TID gegen
      `config/terminal_ids.json`) ist seit Run 399 umgesetzt, seit
      Run 399a6 direkt im Bestätigungs-Popup nach dem BelegScan in
      Schritt 2 sichtbar statt erst beim Upload in Schritt 3 — der MA
      sieht eine Abweichung damit sofort. Seit Run 414 ist der Abgleich
      an allen drei Stellen (Scan-Popup, Weiter-Button Schritt 2→3,
      Senden) blockierend statt nur ein weicher Hinweis (Paco-
      Entscheidung: TID ist eindeutig, falsche Ziffer wird abgelehnt).
      Im Scan-Popup bleibt "übernehmen" bei Abweichung aktiv (Run 414a,
      Korrektur zu Run 414), übernimmt dabei aber bewusst nicht die
      erkannte falsche TID — Feld bleibt leer, zeigt automatisch den
      "TID unleserlich"-Zustand (rot) und wird fokussiert, MA trägt die
      TID manuell nach.
      Weiterhin offen: eigene, editierbare Felder pro Standort in den
      Einstellungen statt der statischen JSON-Datei (siehe auch
      blockierten Punkt "Registrierte TIDs pro Standort" oben — Werte
      bis auf SB von Yannik noch nicht bestätigt; da der Abgleich jetzt
      blockierend ist, hat eine falsche/unvollständige Referenzliste
      ein höheres Gewicht als vorher).

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
      VERALTET (Paco-Entscheidung 2026-08-26): kein Mailversand für
      Fallbacks vorgesehen — der Mail-Teil dieses Punkts entfällt.
      Weiterhin offen: welcher Fallback beim 4x-Limit stattdessen
      erscheinen soll (siehe .dev/flurbocash stuff/fragen_yannik.md,
      Frage 3.4).
      KORRIGIERT (2026-08-30, jetzt anhand `.dev/flurbocash stuff/
      EXTERNAL_API_Schauburg_de.md` verifiziert, nicht mehr nur
      vermutet): Die Notiz vom 2026-08-29 hier war falsch. Laut Doku
      (Zeile 64-69) steuert `settlement_number` explizit, was ein PUT
      auf `/settlements` bewirkt — WEGLASSEN legt eine NEUE Abrechnung
      an (naechste freie Nummer, 1-4 pro Tag), nur ein gesetzter Wert
      1-4 UEBERSCHREIBT eine bestehende. `settlementsBody()`
      (api_upload_service.dart) setzt dieses Feld aktuell NIE. Jeder
      Sendevorgang — Erstversand, "Erneut senden" nach einer Korrektur,
      oder ein Doppel-Tap vor dem Run-400-Fix — legt bei Flurbocash also
      tatsaechlich eine ZUSAETZLICHE Abrechnung an statt die vorherige
      zu ersetzen. Die Server-Antwort-Felder `entered_total_cents` (Summe
      ueber ALLE bisher fuer den Tag eingereichten Abrechnungen) und
      `discrepancy_cents` zeigen das direkt: bei Paco am 2026-08-30 mit
      Testdaten beobachtet (entered 3.757,20 € vs. system 1.545,00 €,
      passt zu mehrfachem Testsenden ohne settlement_number).
      Noch nicht Run-reif: Paco will vorher selbst verschiedene
      Szenarien in der Sandbox durchspielen (Korrektur senden,
      versehentlich doppelt senden, neue Abrechnung z. B. bei Bar Tabak
      mit seinen 2 taeglichen Abrechnungen), um zu verstehen was
      tatsaechlich gebraucht wird, bevor ein Loesungsansatz feststeht
      (z. B. "immer settlement_number 1" wuerde fuer Bar Tabak mit 2
      echten Abrechnungen/Tag vermutlich nicht reichen). Aktueller
      Fokus liegt ohnehin auf MA-Bedienfuehrung/Dateneingabe-
      Korrektheit, nicht auf diesem Thema (siehe Hinweis am Dateianfang).
      Ergänzung Paco-Idee (2026-08-22): lokale Verlauf-Seite soll bei
      einer Korrektur nicht nur `gesendetAm` am bestehenden Eintrag
      aktualisieren, sondern einen zusätzlichen, eigenen
      Verlaufseintrag anlegen — mit "Heute"-Badge (falls zutreffend)
      UND einem neuen "Korr."-Badge, damit der ursprüngliche und der
      Korrektur-Versand beide sichtbar und unterscheidbar bleiben.
      Betrifft primär die lokale Datenhaltung/UI (verlauf_seite.dart,
      verlauf_detail_seite.dart, TagesabschlussFinal), weitgehend
      unabhängig von der offenen `settlement_number`-Frage oben — aber
      inhaltlich verwandt, da beides denselben "Erneut senden"-Vorgang
      betrifft. Vor Umsetzung klären, ob/wie sich das mit der
      Mehrfach-Abrechnung-Logik für Kinos mit `maxAbrechnungenProTag`
      > 1 (aktuell nur Bar Tabak) verträgt.
      Zusatz (Run 399b): seit Run 399b zeigt
      `LokalerSpeicher.ladeFinaleTagesabschluesseNeuesteProTag()`
      im Verlauf und auf der Startseite pro Kalendertag grundsätzlich
      nur noch den zuletzt erstellten Eintrag an (Paco-Entscheidung,
      ausgelöst durch einen liegengebliebenen Testdaten-/Korrektur-
      Eintrag im Verlauf). Ein zusätzlicher Korrektur-Verlaufseintrag
      würde bei der Umsetzung dieses Punkts also ebenfalls
      ausgeblendet, sofern er älter ist als der Haupteintrag —
      diese Filterung muss beim Umsetzen entweder mit einbezogen
      oder für Korrektur-Einträge gezielt umgangen werden.

- [ ] **Mechanismus für Verbindungsabbruch waehrend des Uebertragens**
      (Paco-Notiz 2026-08-30) Fall: Verbindung geht ausgerechnet
      waehrend des laufenden Sendevorgangs verloren (nicht vorher — die
      Verbindungspruefung beim BelegScan-Tap deckt nur den Fall vor dem
      Senden ab, siehe "Offline-Hinweis bei BelegScan konkretisieren"
      oben). Aktueller Stand: `http.post`/`http.put` in
      api_upload_service.dart werfen bei einem Verbindungsabbruch
      bereits eine klare Exception ("Keine Verbindung zur
      Flurbocash-API"), die in Schritt 3/Verlauf als Fehlermeldung
      angezeigt wird — die Abrechnung bleibt aber lokal gespeichert,
      MA kann erneut senden. Offen/zu klaeren: reicht das, oder soll es
      einen deutlicheren Hinweis/Mechanismus geben? Haengt jetzt auch
      mit der `settlement_number`-Erkenntnis oben zusammen: ein
      Abbruch mitten im Call, gefolgt von einem Resend, koennte
      serverseitig eine zusaetzliche statt einer korrigierten
      Abrechnung anlegen — nicht isoliert von der "Erneut senden"-Frage
      oben zu loesen.

- [ ] **Kommentar: Sendezeitpunkt erst unmittelbar beim Senden ergaenzen/
      ersetzen** (Paco-Notiz 2026-08-30) Aktueller Stand (verifiziert,
      tagesabschluss_schritt2_seite.dart:825-856): Das "testdaten
      HH:mm"-Kennzeichen wird JETZT schon beim Seitenaufbau von
      Schritt 2 ins sichtbare Kommentarfeld geschrieben
      (`_wendeDevModusKommentarAn()`, laeuft in `initState()`) bzw.
      spaetestens beim Uebergang zu Schritt 3 als Sicherheitsnetz
      (`_anmerkungFuerUebertragung()`) — NICHT erst beim tatsaechlichen
      Sendevorgang in Schritt 3. Ausserdem ersetzt
      `_anmerkungFuerUebertragung()` einen bereits vorhandenen
      Zeitstempel aktuell NICHT (`if (basis.contains(marker)) return
      basis;` — gibt den Text unveraendert zurueck). Paco-Wunsch: der
      Zeitstempel soll erst unmittelbar vor/beim echten Sendevorgang
      (Schritt 3, `_doApiUpload()`/`_erneutSenden()`) gesetzt werden
      und dabei einen ggf. vorhandenen alten Zeitstempel ERSETZEN, nicht
      nur ergaenzen. Wichtig fuer Run 401 (Sende-Signatur): solange der
      Zeitstempel exakt einmal beim Senden geschrieben und danach nicht
      mehr veraendert wird, bleibt die Signatur-Logik aus Run 401
      korrekt (siehe Kommentar dort) — das bei der Umsetzung beachten.

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

### App-Update / PWA

### Verlauf

- [ ] **"JSON anzeigen"-Button im Dev-Modus auch in Verlauf-Detail**
      Existiert in tagesabschluss_schritt3_seite.dart bereits
      (`_zeigeFlurbocashJson()`, gated über `DevModus.istAktiv()`,
      Zeile 778-782) — analog für verlauf_detail_seite.dart ergänzen,
      damit sich auch bei historischen/erneut gesendeten Einträgen das
      tatsächlich gesendete JSON prüfen lässt. Unabhängig vom
      folgenden Punkt umsetzbar.

- [ ] **Verlauf-Seite neu gestalten** KLÄRUNGSBEDÜRFTIG (2026-08-29):
      Paco-Wunsch ohne konkrete Vorgabe, was am aktuellen Design
      (verlauf_seite.dart, verlauf_detail_seite.dart) genau stört oder
      wie es aussehen soll. Vor einer Run-Vergabe erst klären: was
      genau soll anders werden (Layout, Informationsdichte, Sortierung,
      Filter o. Ä.)?

- [ ] **Bargeld-/Kartenzahlungen-Kachel: Unterkategorien einzeln
      klappbar** In der Verlauf-Detailansicht sind "Bargeld" und die
      EC-Aufschlüsselung innerhalb von "Belege" bereits als
      ExpansionTile aufklappbar, aber alle Unterzeilen (Scheine,
      Münzrollen, Lose Münzen, Umschläge bzw. die einzelnen
      Terminal-Zeilen) werden beim Aufklappen komplett auf einmal
      angezeigt statt selbst wieder ein-/ausklappbar zu sein
      (`verlauf_detail_seite.dart`, Abschnitt "Bargeld" mit
      `_scheinUnterzeilen()`/`_rollenUnterzeilen()`/
      `_loseMuenzenUnterzeilen()`/`_umschlagUnterzeilen()`; Abschnitt
      "Belege" mit `_ecBelegUnterzeilen()`).

- [ ] **EC-Kachel: Kartenarten + Beträge pro Beleg auflisten** (Paco-Notiz
      2026-08-30) `_ecBelegUnterzeilen()` (verlauf_detail_seite.dart:
      222-234) zeigt pro Beleg bisher nur EINE Zeile mit Label +
      Gesamtbetrag (z. B. "Beleg 1: 45,00 €") — die Aufschlüsselung nach
      Kartenart (Girocard/Mastercard/Visa/...) aus
      `a.zahlungsartenAufschluesselung` (`ZahlungsartErgebnis`, Felder
      `art`/`betragCent`/`belegIndex`) wird hier nicht angezeigt, obwohl
      sie in den Daten vorhanden ist. Pro Beleg zusätzlich die einzelnen
      Kartenart-Zeilen ergänzen (gefiltert nach `belegIndex` analog zu
      `ApiUploadService._terminalsListe()`).

- [ ] **Grünes "gesendet"-Badge im Verlauf** Aktuell gibt es nur ein
      negatives `NichtGesendetBadge` (angezeigt wenn
      `eintrag.gesendetAm == null`), aber kein positives Badge für
      erfolgreich gesendete Einträge — der Zustand "gesendet" ist nur
      am Fehlen des roten Badges erkennbar. Neues grünes Badge analog
      zu `NichtGesendetBadge`/`HeuteBadge` ergänzen
      (`verlauf_seite.dart`, `verlauf_detail_seite.dart`).
      Zur Klarstellung (Prüfung 2026-08-22): Der frühere Bug
      "erfolgreich gesendete Einträge zeigen weiterhin 'noch nicht
      gesendet'" ist NICHT mehr offen — bereits in Run 396
      vollständig behoben (beide Ursachen: markiereAlsGesendet() im
      falschen mounted-Block + Verlauf-Liste lud nach "Erneut
      senden" nicht neu). Dieser Punkt hier ist rein additiv (neues
      positives Badge), kein Bugfix.

- [ ] **Beleg-Foto im Verlauf exportieren/teilen** Miniaturansicht +
      Vollbild-Zoom ist seit Run 399a da (`verlauf_detail_seite.dart`,
      `_belegFotoZeilen()`/`_zeigeBelegFotoVollbild()`), ein expliziter
      Export-/Teilen-Button fehlt noch. Reine Flutter-Bordmittel
      reichen dafür nicht plattformübergreifend — Standard-Lock
      verlangt vorher Pacos Freigabe für eine von:
      a) neue Dependency `share_plus` (Web + iOS + Android, native
         Share-Sheets), oder
      b) dependency-freier Web-Download über `dart:js_interop`
         (Muster wie `pwa_install_service_web.dart`/
         `sw_update_service_web.dart`), dafür kein Export auf
         nativem iOS/Android (nur PWA-Zielplattform bedient).

- [ ] **"Verlauf löschen"-Button in der AppBar, nur im Dev-Modus**
      (Paco-Notiz 2026-08-30) verlauf_seite.dart hat aktuell keine
      AppBar-`actions`. Gewünscht: Button zum Löschen des KOMPLETTEN
      Verlaufs (alle Einträge dieses Kinos) — anders als der bereits
      vorhandene Einzel-Eintrag-Löschen-Button in verlauf_detail_seite.
      dart, der über `AdminSession.entsperrt` (Admin-PIN) gated ist.
      Dieser neue Button soll stattdessen über `DevModus.istAktiv()`
      gated sein (gleiches Gate wie beim Auto-Fill/"JSON anzeigen") —
      zum schnellen Aufräumen von Testdaten, nicht für den
      Produktivbetrieb gedacht. `LokalerSpeicher` hat aktuell nur
      `loescheFinalenTagesabschluss()` (einzelner Eintrag) — eine
      Bulk-Lösch-Methode für alle Einträge eines Kinos fehlt noch.

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
      Zusatz (Run 399b): Verlauf und Startseite ("Übertrag auf
      Umschlag") zeigen seit Run 399b pro Kalendertag grundsätzlich
      nur noch den zuletzt erstellten Eintrag
      (`ladeFinaleTagesabschluesseNeuesteProTag()` in
      lokaler_speicher.dart) — die als "Zusätzliche Abrechnung"
      gespeicherte erste der beiden BT-Abrechnungen würde damit aktuell
      unsichtbar/nicht anwählbar, sobald die zweite gespeichert ist.
      Muss bei der Umsetzung der zwei Startseiten-Buttons mit gelöst
      werden (z. B. eigene, ungefilterte Ladefunktion für BT statt der
      Pro-Tag-Filterung, oder die beiden Abrechnungen anders
      unterscheiden als nur über den Kalendertag).

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
      die reinen UI-Bau-Methoden ausgelagert (→ 3381 Zeilen), Run 343
      die Fokus-/Navigations-/Scroll-Logik (→ controller/
      schritt2_fokus_helper.dart). Der build()-Baum selbst (>1200
      Zeilen) wird seit Run 345 in einer eigenen Sub-Run-Serie analog
      zu Schritt 1s sections/-Ordner zerlegt: Sub-Run 1 (Run 345)
      hat das Grundgerüst (sections/, ui/schritt2_gruppen_
      orchestrierung.dart, ui/schritt2_body_content.dart) angelegt und
      vier einfache Abschnitte ausgelagert (Kopf, Personalgetränke-
      gebont, Differenz-im-Anfangsbestand, Anmerkung). Sub-Run 2
      (Run 347) hat Kino/Bistro-SOLL + Ausgaben ausgelagert (neues
      Leaf-Widget für die Ausgaben-Zeile). Sub-Run 3 (Run 348) hat
      die EC-Belege-Kachel (Header + aufklappbarer Body-Rahmen +
      1-Beleg-Modus) ausgelagert, inkl. neuem wiederverwendbarem
      Terminal-ID-Zeile-Widget (sections/
      schritt2_ec_beleg_terminal_id_zeile.dart). Sub-Run 4 (Run 350)
      hat den größten/riskantesten Block ausgelagert: die
      EC-Belege-Sub-Kacheln im 2+-Beleg-Modus inkl. der async
      Lösch-Bestätigung (sections/schritt2_ec_beleg_sub_kacheln.dart)
      — damit ist die komplette EC-Belege-Kachel aus build()
      entfernt. Sub-Run 5 (Run 353, finale Verdrahtung) hat die
      restlichen Inline-Closures in benannte Methoden ausgelagert
      und die komplette EC-Belege-Bereich-Konstruktion in eine
      eigene Methode _baueEcBelegeBereich() gebündelt — build()
      damit von ursprünglich >1200 auf ~197 Zeilen geschrumpft
      (appBar/footerChild bleiben wie bei Schritt 1 bewusst inline).
      Die Schritt-2-build()-Zerlegungs-Serie (Run 345/347/348/
      350/353) ist damit abgeschlossen. Run 354 hat das gleiche
      Muster auf tagesabschluss_schritt3_seite.dart angewendet
      (deutlich einfacher als Schritt 2, daher in einem Run statt
      einer Sub-Run-Serie): neuer Ordner lib/pages/
      tagesabschluss_schritt3/sections/ mit 5 StatelessWidgets
      (Kopf, Differenz-Anfangsbestand, SOLL, IST, Differenz) —
      build() dadurch von ~246 auf ~144 Zeilen geschrumpft. Der
      Sende-Aktionen-Block (Button/Dev-JSON-Button/Fehlertext)
      bleibt bewusst inline (eng an mehrere State-Felder gekoppelt,
      analog appBar/footerChild bei Schritt 1/2). Run 355 startet
      eine neue Sub-Run-Serie für einstellungen_seite.dart (build()
      453 Zeilen, größter verbleibender Kandidat): Sub-Run 1 legt
      das Grundgerüst lib/pages/einstellungen/ an und lagert die
      zwei einfachsten Blöcke aus (Getränkeliste-Card, PWA-Install-
      Card) — build() dadurch auf 397 Zeilen. Die PIN-geschützte
      Admin-Card (5 unabhängige Bänder: Standort/Admin-Status,
      Wechselgeldbestand, Flurbocash-Anbindung, KI-Belegscan-Konfig,
      Dev-Modus/Testwerte) ist offen für weitere Sub-Runs. Run 358
      (Sub-Run 2) hat das einfachste Band ausgelagert: KI-Belegscan-
      Konfig (neue Datei sections/einstellungen_belegscan_section.
      dart) — einstellungen_seite.dart dadurch von 1434 auf 1399
      Zeilen geschrumpft. Run 359 (Sub-Run 3) hat das Standort/
      Admin-Status-Band ausgelagert (neue Datei sections/
      einstellungen_standort_admin_section.dart) — Datei dadurch auf
      1346 Zeilen geschrumpft. Run 360 (Sub-Run 4) hat das
      Wechselgeldbestand-Band ausgelagert (neue Datei sections/
      einstellungen_wechselgeld_section.dart) — Datei dadurch auf
      1280 Zeilen geschrumpft. Run 361 (Sub-Run 5) hat das
      Flurbocash-Anbindung-Band ausgelagert (neue Datei sections/
      einstellungen_flurbocash_section.dart) — Datei dadurch auf
      1225 Zeilen geschrumpft. Run 362 (Sub-Run 6, letzter dieser
      Serie) hat den größten/riskantesten Rest-Block ausgelagert:
      Dev-Modus/Testwerte inkl. _baueAutoFillInhalt()-Aufruf (neue
      Datei sections/einstellungen_dev_modus_section.dart) — Datei
      dadurch auf 1168 Zeilen geschrumpft. Damit ist die
      einstellungen_seite.dart-Zerlegungs-Serie (Run 355/358–362)
      abgeschlossen: alle 5 Admin-Card-Bänder plus Getränkeliste-
      und PWA-Install-Card sind jetzt eigene StatelessWidgets unter
      lib/pages/einstellungen/sections/. build() selbst bleibt
      größtenteils Struktur-Gerüst (Scaffold/AppBar/ListView), die
      restlichen ~1168 Zeilen der Datei sind State, Speicher-Logik
      und die Auto-Fill-Builder-Methoden — kein weiterer Kandidat
      für dieses Zerlegungsmuster. Run 363 startet eine neue Serie
      für wechselgeld_pruefen_seite.dart (1378 Zeilen). Anders als
      bei Einstellungen/Schritt 1-3 ist hier build() selbst schon
      kompakt (~183 Zeilen), da die Seite die meisten Gruppen
      (Scheine, lose Münzen, Umschläge) über die bestehende
      Schritt-1-Infrastruktur (Schritt1GruppenOrchestrierung,
      Schritt1BodyContent) bezieht — die Datei ist im Kern eine
      abgespeckte Wiederverwendung von Schritt 1. Die Größe kommt
      von zwei seiteneigenen Blöcken außerhalb dieser Infrastruktur:
      _baueRollenGruppe() (~170 Zeilen, eigene "Aus Zählung von
      vorhin übernehmen"-Logik) und der Zusammenfassungs-Karte.
      Sub-Run 1 (Run 363) hat den einfacheren Block ausgelagert:
      _baueZusammenfassung() + die bereits als eigene Klasse
      abgetrennte _ZusammenfassungsZeile als neues Widget
      WechselgeldZusammenfassungSection (neuer Ordner lib/pages/
      wechselgeld_pruefen/sections/) — Datei dadurch von 1378 auf
      1318 Zeilen geschrumpft. Run 364 (Sub-Run 2, letzter) hat den
      größeren/riskanteren Rest-Block ausgelagert: _baueRollenGruppe()
      (neue Datei sections/wechselgeld_rollen_section.dart) — Datei
      dadurch auf 1167 Zeilen geschrumpft. Damit ist auch diese
      Serie abgeschlossen (nur 2 Sub-Runs nötig, da build() hier
      schon kompakt war und die meisten Gruppen ohnehin über die
      Schritt-1-Infrastruktur laufen). Kandidatensuche nach Run 364
      (Zeilenvergleich aller lib/pages/*.dart): keine der
      verbleibenden unangetasteten Seiten (getraenke_auffuellen_
      seite.dart 525, verlauf_detail_seite.dart 491,
      stueckelung_vorschlag_seite.dart 464 Zeilen) ist groß genug,
      um dieses Zerlegungsmuster zu rechtfertigen (jeweils build()
      unter 260 Zeilen). Einzige weiterhin sehr große Datei ist
      tagesabschluss_schritt2_seite.dart (2619 Zeilen) — deren
      build() bereits zerlegt ist (Runs 345–353), der Rest ist
      State/Fokus-Logik/Speicher-Code. Eine weitere Verkleinerung
      bräuchte einen andersartigen, größeren Architektur-Run (Logik
      in Services/Helper auslagern statt Widgets extrahieren), keinen
      einfachen Sub-Run im bisherigen Muster. Auf Paco-Wunsch
      zurückgestellt (Run 364a) — bei Bedarf später als eigenständiges
      Vorhaben aufgreifen.

- [ ] **Duplikat-/Abstraktions-Audit** (Run 373 gestartet, Serie läuft).
      Umfassende Analyse auf Duplikate/Teilduplikate und unnötige
      Abstraktionen quer durch lib/ (26 Funde in 3 Teilbereichen:
      Schritt1/2/3-Seiten, gemeinsamer Widget-/Service-/Domain-Code,
      restliche Einzelseiten). Ziel: Code bleibt für Paco selbst
      durchsteigbar, möglichst wenig Redundanz/Drift-Risiko (siehe
      z. B. Run 366–369).
      Erledigt: Run 373 (tote Pass-Throughs/Wrapper entfernt — u. a.
      Schritt1StateController, KinoWaehlenUsecase —, ISO-Datum
      vereinheitlicht, Versionsstring zentralisiert in neuer
      lib/config/app_version.dart, AppVersion.text). Run 374/374a/
      374a2 (Dialog-/Snackbar-Helfer vereinheitlicht: neues
      zeigeInfoDialog() + zeigeHinweisSnackBar(), zeigeBestaetigungs
      Dialog() um abbrechenText erweitert; dabei zusätzlich beim
      Testen gefundene Bugs/Wünsche miterledigt: doppeltes
      Wechselgeld-"Was jetzt?"-Popup entfernt, "Clear"-Buttons
      app-weit auf "Löschen" umbenannt, "Wechselgeld stimmt"-Prüfung
      läuft jetzt erst bei Feld-Verlassen/Bestätigung statt bei jedem
      Tastendruck, "Rollen übernehmen" erkennt genullte Zählungen
      jetzt korrekt als "keine Daten vorhanden"). Run 375
      (Fokus-/Scroll-Navigation Schritt1+2 in FeldNavigationHelper
      zusammengeführt: scrolleZurMitteNachFokus(), istLetztesFeld(),
      textInputActionFuer() und die Nutzung von aktivesFeld()/
      feldNachVorne() waren zwischen Schritt1StateController und
      Schritt2FokusHelper 1:1 dupliziert, jetzt zentral in
      lib/utils/feld_navigation_helper.dart. Bewusst nicht
      zusammengeführt: erstesLeeresFeld()/autoFokussiereNachLaden()
      (strukturell unterschiedliche Lösung je Seite) und
      beiEingabeAbgeschlossen() (unterschiedliches Verhalten, keine
      reine Dopplung) — bei Bedarf eigener späterer Run). Run 376
      (Additions-Logik der Eingabefelder als gemeinsames Mixin:
      _fuegeAdditionHinzu() war 1:1 dupliziert zwischen
      betrag_cent_eingabefeld.dart und ganzzahl_eingabefeld.dart,
      jetzt zentral in neuer lib/widgets/eingabefeld_additions_
      mixin.dart, EingabefeldAdditionsMixin<T>. Bewusst Mixin statt
      Top-Level-Funktion wie beim Clear-Helper, da der Cursor-Reset
      im addPostFrameCallback den mounted-Check der jeweiligen
      State-Klasse braucht).
      Run 377 (Config-Service-Basisklasse: initOnAppStart()/
      Update-Check/HTTP-Fetch waren zwischen GetraenkeConfigService
      und WechselgeldConfigService 1:1 dupliziert, jetzt zentral in
      neuer lib/services/remote_config_service_basis.dart,
      abstrakte Basisklasse RemoteConfigServiceBasis<T>
      (Template-Method-Muster) — Unterklassen liefern nur noch
      Parsing/Kodierung/Schlüssel sowie optional den Asset-Fallback,
      den nur Getränke hat).
      Run 378 (Schritt-Auswahl-BottomSheet zusammengeführt:
      Schritt1OrchestrierungHelper.zeigeSchrittAuswahlBottomSheet()
      und die inline _zeigeSchrittSlider()-Methoden in Schritt2,
      Schritt3 und stueckelung_vorschlag_seite.dart/Schritt4 waren
      praktisch 1:1 vierfach dupliziert, jetzt zentral in neuer
      lib/utils/schritt_auswahl_bottom_sheet_helper.dart,
      SchrittAuswahlBottomSheetHelper.zeigeSchrittAuswahlBottomSheet().
      Bewusst über die ursprünglich geplanten Schritte 1-3 hinaus auch
      Schritt 4 einbezogen, da identisches Muster — sonst wäre eine
      vierte Kopie übrig geblieben. Nebenkorrektur dabei: Schritt 1
      zeigte für Schritt 4 bisher "4/4 · Schritt 4" statt
      "4/4 · Stückelung Barumsatz", jetzt einheitlich).
      Run 380 (Body-Content-Wrapper Schritt1+2 zusammengeführt:
      schritt1_body_content.dart und schritt2_body_content.dart
      hatten eine 1:1 identische äußere Hülle — Theme-Override für
      dichte Eingabefelder, NotificationListener für Scroll-Metrik,
      Stack mit Scroll-nach-unten-FAB (nur heroTag unterschiedlich)
      —, jetzt zentral in neuer lib/widgets/
      tagesabschluss_body_wrapper.dart, TagesabschlussBodyWrapper.
      Der eigentliche scrollbare Inhalt (CustomScrollView mit
      Slivern bei Schritt 1 vs. ListView bei Schritt 2) unterscheidet
      sich zu Recht und bleibt bei den jeweiligen BodyContent-
      Widgets. Öffentliche Konstruktoren unverändert, keine
      Aufrufstelle musste angepasst werden — betrifft auch
      wechselgeld_pruefen_seite.dart, das Schritt1BodyContent
      mitbenutzt).
      Ursprünglich als Run 379 geplant — die reale Run-379-Nummer
      wurde stattdessen für einen ungeplanten Bugfix
      (Standort-Wechsel) verbraucht, diese Serie ist dadurch um
      einen Run nach hinten verschoben.
      Erledigt: Run 381 (JSON-Lade/Speicher-Helfer in
      lokaler_speicher.dart — Details siehe CHANGELOG.md). Run 382
      (TagesabschlussScaffold konsequent genutzt — Details siehe
      CHANGELOG.md). Run 383 (Stückelungs-Konfiguration
      zentralisiert: stueckelung_vorschlag_seite.dart nutzte eine
      eigene private _ScheinDef-Klasse für die 5 Scheine statt der
      bereits vorhandenen zentralen StueckelungKonfiguration.scheine
      — entfernt, Schleife greift jetzt direkt auf die zentrale
      Liste zu. einstellungen_seite.dart definierte id+bezeichnung
      für Scheine/Rollen/lose Münzen (Dev-Autofill-Panel) nochmal
      als eigene Record-Listen — jetzt bezieht sie id+bezeichnung
      aus StueckelungKonfiguration, nur die Dev-Test-Default-Werte
      bleiben als eigene kleine Maps lokal. Nebeneffekt: Die
      Rollen-Labels im Dev-Autofill-Panel zeigen jetzt wie überall
      sonst in der App den vollen Rollenwert an (z. B. "2 €
      (50,00 €)" statt vorher verkürzt "2 €") — betrifft nur das
      PIN-geschützte Dev-Panel, keine Endnutzer-Ansicht). Run 384
      (vier kleine lokale Widget-Extraktionen: wechselgeld_rollen_
      section.dart nutzt jetzt die zentrale CollapsibleCardSection
      statt eigener Card/InkWell-Header-Struktur, dafür neuer
      optionaler Parameter `zusatzZeile`; tagesabschluss_schritt3/
      sections/ bekam eine gemeinsame Schritt3InfoCard statt 4x
      identisch dupliziertem Card-Wrapper; schritt1_ui_builder.dart:
      Kupfer-Hinzufügen/Entfernen-Buttons aus Schritt1LoseMuenzenInhalt
      und Schritt1RollenInhalt in zwei private Widgets zusammengeführt;
      einstellungen_seite.dart: _baueStueckzahlZeile/_baueCentZeile
      auf gemeinsame _baueZahlenZeile() zurückgeführt — Details siehe
      CHANGELOG.md).
      Erledigt: Run 428 (die bei der Codebasis-Analyse 2026-08-16
      gefundenen 10 verbliebenen SnackBar-Aufrufe in
      tagesabschluss_schritt2_seite.dart und
      tagesabschluss_schritt3_seite.dart auf das bestehende
      zeigeHinweisSnackBar() umgestellt; neue
      zeigeHinweisSnackBarRich()-Variante für den einen Fall mit
      hervorgehobenem Teiltext ergänzt — Details siehe CHANGELOG.md).
      Kandidatensuche nach Run 384 für weitere Runs dieser Serie noch
      offen — nächster Fokus bei Bedarf über eine neue
      Codebasis-Analyse ermitteln.
      Weitere geplante Runs aus Codebasis-Analyse (2026-08-16, reiner
      Befundbericht ohne eigenen Run): 387 main.dart: globale Fehlerbehandlung
      ergänzen (runZonedGuarded/FlutterError.onError fehlen
      komplett) — App bleibt bei einem Init-Fehler (z. B. Hive.
      openBox) aktuell ohne Diagnose oder Nutzer-Feedback stehen.
      Klärungsbedürftig vor Run-Vergabe (ebenfalls aus der Analyse):
      6-Uhr-Knick beim Finalisieren — tagesabschluss_finalisieren_
      usecase.dart setzt das gespeicherte Abschluss-Datum aus
      DateTime.now() ohne den 6-Uhr-Knick, während Schritt 3 die
      Anzeige korrekt über logischerAbrechnungsTag() bildet
      (Abweichung möglich bei Abschluss zwischen 00:00 und 05:59
      Uhr); soll finalisieren() exakt wie die Anzeige umgestellt
      werden? — lokaler_speicher.dart Datenverlust bei Schreibfehler
      — schlägt das Schreiben der Tagesabschluss-Historie fehl
      (catch(_)), wird die komplette bisherige Historie eines Kinos
      aktuell stillschweigend durch nur den neuen Eintrag ersetzt;
      welches Verhalten ist im Fehlerfall gewünscht (z. B. alten
      Stand behalten + Fehler anzeigen statt überschreiben)? —
      Anthropic-API-Key totes Feld — wird in den Einstellungen
      gespeichert, aber nirgends gelesen (beleg_scan_service.dart
      sendet den Scan-Request ohne API-Key-Header); Feld entfernen
      (da nie genutzt) oder Scan-Request tatsächlich mit API-Key
      versehen?
      Bewusst zurückgestellt: paralleles Listen-Resize-Muster in
      tagesabschluss_schritt2_seite.dart (EC-Beleg-/Ausgaben-Familie)
      — nur bei größerem Schritt-2-Umbau sinnvoll, nicht isoliert
      (bestätigt durch Codebasis-Analyse 2026-08-16, dort als
      "Parallel-Array-Antipattern" beschrieben).
      FeatureFlags/DevModus-Boilerplate — niedrige Priorität, nur bei
      weiteren Flags relevant.
      Offene Abwägungsfrage (Paco-Entscheidung nötig): soll
      einstellungen_gruppen_orchestrierung.dart als reine
      Durchreiche-Schicht bleiben (Konsistenz mit Schritt1/2/3-
      Mustern) oder zurückgebaut werden (mehr Einfachheit, da hier —
      anders als bei Schritt1/2/3 — keine eigene Logik/Verzweigung
      drinsteckt)?

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

