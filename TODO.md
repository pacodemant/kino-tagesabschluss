# TODO — kino_bar_app
Stand: August 2026 · Run 382 · wird fortlaufend ergänzt

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

- [ ] **TID-Whitelist konfigurierbar** Pro Standort in Einstellungen
      editierbar. Prüfung nach BelegScan — Warnung bei unbekannter TID.

- [ ] **Safari-iOS: Lokale Speicherung** Safari löscht localStorage/IndexedDB
      nach 7 Tagen (ITP). Lösung: Warnung bei drohendem Datenverlust oder
      regelmäßiger Export-Hinweis. *(Vorerst zurückgestellt — Zielplattform
      ist Android an allen Standorten, ITP betrifft nur iOS/Safari und damit
      nur Pacos private Testumgebung.)*

### Flurbocash API-Integration *(Phase E — wartet auf IT)*

- [ ] **Schutz vor doppeltem Versand derselben Abrechnung** Klären: Wie
      verhindern, dass eine Abrechnung mit exakt denselben Werten
      zweimal an Flurbocash gesendet wird (z. B. Doppel-Tap auf
      Senden-Button, oder erneuter Versand nach unklarem
      Netzwerk-Ergebnis)? Einfachster Ansatz vermutlich rein
      client-seitig (Button nach erstem Tap sperren bzw.
      Idempotenz-Check vor dem Call) — kein Backend-/IT-Klärungsbedarf
      vorausgesetzt, vor Umsetzung aber gegenprüfen.

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

### Verlauf

- [ ] **Übertragungs-Flag je Verlaufseintrag** Jeder Verlaufseintrag
      soll erkennbar machen, ob die zugehörige Abrechnung erfolgreich
      an Flurbocash übertragen wurde oder nicht — damit im Verlauf
      sichtbar ist, welche Einträge ggf. erneut gesendet werden
      müssen. Betrifft vermutlich `lokaler_speicher.dart`
      (Verlauf-Modell) und `verlauf_detail_seite.dart` (Anzeige).

### App-Update / PWA

- [ ] **Fallback auf letzte Version bei fehlgeschlagenem Update-Check**
      Kann die App die aktuelle Version nicht laden (z. B. weil kein
      WLAN verfügbar ist), soll sie stillschweigend die zuletzt
      geladene Version weiterverwenden, statt dass der MA davon etwas
      merkt. Prüfen, wie sich das aktuelle Service-Worker-/
      PWA-Verhalten (`sw_update_service_web.dart`, `web/`) dazu
      verhält — Standard-Service-Worker-Caching sollte das eigentlich
      schon so handhaben, ggf. reicht eine Bestätigung statt Umbau.

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
      CHANGELOG.md).
      Geplante nächste Runs (jeweils 1 Fokus pro Run, Reihenfolge
      nach Impact/Risiko):
      383 Stückelungs-Konfiguration zentralisieren (aktuell 3x
      dupliziert) · 384 WechselgeldRollenSection auf
      CollapsibleCardSection umstellen + Schritt3-Card-Wrapper +
      restliche kleine lokale Widget-Extraktionen (Kupfer-Buttons,
      Einstellungen-Zeilen-Builder).
      Weitere geplante Runs aus Codebasis-Analyse (2026-08-16, reiner
      Befundbericht ohne eigenen Run): 385 Fehlendes Auto-Save
      nachziehen — drei Stellen ohne _speichereEntwurf()-Aufruf
      (Schritt 1: Kupfer-Lose/-Rollen entfernen; Schritt 2:
      Kartenart-Einzelbetrag) — eingegebene Werte gehen bei
      App-Neustart verloren. · 386 api_upload_service.dart: Fallback
      auf ecUmsatzGesamtCent ergänzen, wenn
      zahlungsartenAufschluesselung leer ist — sonst wird ein
      0-EUR-Terminal-Eintrag ohne Fehlermeldung an Flurbocash
      hochgeladen. · 387 main.dart: globale Fehlerbehandlung
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
      Zusätzlich entdeckt, noch nicht eingeplant: ca. 11 weitere
      SnackBar-Aufrufe in tagesabschluss_schritt2_seite.dart (5x) und
      tagesabschluss_schritt3_seite.dart (6x), die ebenfalls
      zeigeHinweisSnackBar() nutzen könnten (siehe CHANGELOG Run 374,
      Abschnitt "Neuer Fund beim Umsetzen") — bewusst nicht
      mitgezogen, da außerhalb des kommunizierten Zielbereichs von
      Run 374.
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

