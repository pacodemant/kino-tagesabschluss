# Project Context

Projekt: Flutter-App „Schauburg Tagesabschluss"  
Version: 0.9.8+332a · Run 332a

Zweck: Unterstützung des Kino-Tagesabschlusses (Kassen- und Bargeldzählung)
für mehrere Standorte der Schauburg GmbH.

Zielplattform: Web (iOS-Safari als primäre Testumgebung, PWA-fähig).

---

## Wichtige Ordner

    lib/                    → Flutter-App-Code
    lib/pages/              → Seiten (Screens)
    lib/pages/tagesabschluss_schritt1/  → Schritt-1-Untermodule (sections, ui, scroll, …)
    lib/models/             → Datenmodelle
    lib/services/           → Services (BelegScan, API-Upload, Konfiguration, …)
    lib/storage/            → LokalerSpeicher (SharedPreferences-Wrapper)
    lib/domain/             → Berechnungslogik, UseCases
    lib/widgets/            → Wiederverwendbare UI-Widgets
    lib/theme/              → AppFarben (appBarRot #7B0000 u. a.)
    lib/utils/              → DatumsHelper (4-Uhr-Knick-Logik),
                              FeldNavigationHelper (Next-Button,
                              Tab/Pfeiltasten-Feldnavigation)
    lib/config/             → FeatureFlags
    config/                 → Asset-Textdateien (Getränkelisten, Zahlungsarten)
    .dev/                   → Entwicklungsworkflow und Run-System
    scripts/                → Entwickler-Skripte

---

## App-Architektur

### Ablauf (4 Schritte)

    StartpruefungSeite  →  KinoauswahlSeite  →  StartmenueSeite
                                                       │
                           Schritt 1: Bargeld zählen (Scheine, Rollen, Lose Münzen, Umschläge)
                                       │
                           Schritt 2: Umsätze eingeben (Kino-SOLL, EC-Belege, Ausgaben)
                                       │
                           Schritt 3: Übertrag auf Umschlag (Differenz, Abschluss)
                                       │
                           StueckelungVorschlagSeite (Schritt 4, optional)

Weitere Seiten:
- VerlaufSeite / VerlaufDetailSeite — gespeicherte Abschlüsse
- EinstellungenSeite — Wechselgeld-Sollwert, Dev-Modus, Auto-Fill
- WechselgeldPruefenSeite — nach Abschluss
- GetraenkeAuffuellenSeite — Getränkenachfüllung nach Abschluss
- DatenschutzSeite, UeberEntwicklerSeite

### Routen (Auswahl)

    /                   → StartpruefungSeite
    /kinoauswahl        → KinoauswahlSeite
    /startmenue         → StartmenueSeite  (arg: kinoId: String)
    /closure-step-1     → Schritt 1        (arg: TagesabschlussSchritt1Argumente)
    /closure-step-2     → Schritt 2
    /closure-step-3     → Schritt 3
    /closure-step-4     → StueckelungVorschlagSeite
    /verlauf            → VerlaufSeite     (arg: initialKinoId: String?)
    /verlauf-detail     → VerlaufDetailSeite
    /einstellungen      → EinstellungenSeite
    /wechselgeld        → WechselgeldPruefenSeite
    /getraenke          → GetraenkeAuffuellenSeite
    /datenschutz        → DatenschutzSeite
    /ueber-entwickler   → UeberEntwicklerSeite

### Persistenz

Zwei Ebenen, kein Backend:

| Box / Key-Präfix              | Inhalt                              |
|-------------------------------|-------------------------------------|
| `box_tagesabschluesse`        | Finale Tagesabschlüsse (Hive)       |
| `box_abrechnung_entwuerfe`    | Schritt-1-Entwürfe (Hive)           |
| `box_schritt2_entwuerfe`      | Schritt-2-Entwürfe (Hive)           |
| `box_getraenke_mengen`        | Getränke-Mengen (Hive)              |
| `box_wechselgeld_entwuerfe`   | Wechselgeld-Entwürfe (Hive)         |
| `box_getraenkeliste`          | Getränkeliste (Hive)                |
| `box_einstellungen`           | Einstellungen (Hive)                |
| SharedPreferences             | Dev-Modus, Auto-Fill, Wechselgeld-Sollwert, `flurbocash_location_id_[kinoId]`, `standort_modus` (Admin-Betriebsmodus, fest eingestelltes Kino oder "Alle") |

Geldberechnung intern **in Cent** (niemals ändern).  
Logischer Abrechnungstag: 4-Uhr-Knick (`DatumsHelper.logischerAbrechnungsTag()`).

### Kinos / Standorte

    kino_01  Schauburg
    kino_02  Gondel
    kino_03  Atlantis
    kino_04  Cinema Ostertor
    kino_05  Bar Tabak  (komplex, noch nicht implementiert)

### Services

- `BelegScanService` — EC-Beleg fotografieren, via Claude AI analysieren → `BelegScanErgebnis` (Betrag, terminal_id, Datum)
- `ApiUploadService` — Upload an Flurbocash-API (2-Call-Flow: ensure + settlements) — **wartet auf IT-Infos**
- `AbrechnungSpeicher` — Entwürfe mit 4-Uhr-Datum-Logik persistieren
- `GetraenkeConfigService` / `WechselgeldConfigService` — Asset-Konfig laden & cachen
- `ZahlungsartenConfigService` — Kartenarten aus `config/zahlungsarten.txt`
- `DevModus` — Dev-Modus (SharedPreferences-Key `dev_modus_aktiv`)
- `PwaInstallService` / `StoragePersistService` — Web-spezifisch (Stub für andere Plattformen)

### Wichtige Widgets

- `GanzzahlEingabefeld` — Ganzzahl-Eingabe mit Clear-Button, Fokus-Hervorhebung
- `BetragCentEingabefeld` — Cent-Eingabe mit automatischem Komma (Supermarktkassen-Format)
- `TagesabschlussScaffold` — gemeinsames Layout (AppBar, Footer-Button, Keyboard-Handling)
- `CollapsibleCardSection` — klappbare Card-Sektion
- `zeigeBelegScanBestaetigenDialog` (`beleg_scan_bestaetigen_dialog.dart`)
  — Bestätigungs-Popup nach EC-Beleg-Scan ("nochmal"/"übernehmen"),
  seit Run 318. Ersetzt NICHT das gleichnamig klingende, in Run 307
  entfernte `BelegScanGegenpruefDialog` (anderer Zweck).

---

## Versionierung

Versionsstring in ZWEI Dateien immer synchron halten:

    lib/pages/startmenue_seite.dart   (ca. Zeile 128)
    lib/pages/kinoauswahl_seite.dart  (ca. Zeile 68)

Format: `'Web App X.X.X · rNNN @ GitHub:'`  
Bei Sub-Runs (275a) den Buchstaben in den Versionsstring eintragen (r275a, nicht r275).

---

## Laufender Entwicklungsstand (Run 331)

Aktuelle Phase: **BelegScan & EC-Kachel (Phase A, Runs 275–280) + Flurbocash-Integration**

- Run 275 ✅ EC-Kachel Layout & Terminal-ID — abgeschlossen
- Run 275a…a10 ✅ Prüf-Popup vereinfacht, EC-Kachel-Korrekturen, Bugfixes — abgeschlossen
- Run 276 ✅ EC-Kachel: Gesamtsumme rechts, "Weiteren Beleg"-Button — abgeschlossen
- Run 277 ✅ EC-Kachel: Unterkacheln pro Beleg — abgeschlossen
- Run 277a…a5 ✅ EC-Kachel Redesign + Fixes: 1-Beleg flach / 2+-Belege Sub-Kacheln — abgeschlossen
- Run 278 ✅ Prüf-Popup: rote Felder, Hinweistext, keine Inline-Korrektur — abgeschlossen
- Run 278a–278d ✅ Prüf-Popup + EC-Kachel UX-Fixes, TID-Editing, Manuell-Bearbeiten — abgeschlossen
- Run 279 ✅ Architektur-Refactor: alle Zahlungsarten-Felder auf per-Beleg-Lists umgestellt.
  Jede Sub-Kachel zeigt jetzt die Kartendaten-Aufschlüsselung ihres eigenen Belegs.
  Persistenz rückwärtskompatibel (altes Format → Beleg 0). — abgeschlossen
- Run 279d ✅ Bugfixes: nichtImScan-Default→true, _kartenartenNurAnzeige-Default→true,
  _kartenartenImplausibel-Gate entfernt, BetragCentEingabefeld aus Header revertiert.
- Run 279e ✅ 1-Beleg-Modus: TID/Betrag nach Scan als Text; unleserliche Felder in Read-Ansicht rot.
- Run 280 ✅ Dev-Modus: „JSON anzeigen"-Button auf Übertrag-Seite (Schritt 3)
- Run 281 ✅ EcTerminalErgebnis-Modell; JSON-Aufbau pro Beleg mit korrekter TID-Zuordnung
- Run 287 ✅ PIN-Schutz für Entwicklermodus (PIN 1929, Session); location_id-Feld in Einstellungen
- Run 290 ✅ ApiUploadService: 2-Call-Flow (ensure + settlements), JSON statt form-encoded, X-API-Key-Header, explizites Kartenart-Mapping, deutsche Fehlertexte, report_id-Persistenz
- Run 291 ✅ FlurbocashConfigService: lädt config/flurbocash_anbindung.json; upload() ohne url/key-Parameter; SharedPrefs-Override für location_id + api_key; Einstellungen-Dev-Bereich mit Config-Anzeige + Override-UI
- Run 292 ✅ FlurbocashConfigService entfernt; ApiUploadService liest ausschließlich SharedPreferences; Einstellungen-Dev-Bereich vereinfacht (kein "Config: –", kein Zurücksetzen); JSON nach secrets/ verschoben
- Run 293 ✅ ApiUploadService: catch (_) → catch (e); CORS-Fehlertext im Exception-Text eingebettet; isCorsArtFehler() greift nun korrekt
- Run 294 ✅ PIN-Dialog (Einstellungen): FocusNode mit requestFocus() nach 100ms Delay → Tastatur erscheint zuverlässig auf Web/iOS
- Run 295 ✅ Auto-Reload bei Tab-Öffnung: SW-Cache + SW deregistrieren + einmaliger Reload via sessionStorage-Guard → immer neueste Version beim App-Start
- Run 296 ✅ Personalgetränke-Checkbox Schritt 2 + EC-Kachel Kartenarten-Fixes (296a–296c)
- Run 297 ✅ EC-Kachel State-Refactor: ZeilenZustand-Enum (hidden/shown/editing) löst nichtImScan + _kartenartenNurAnzeige ab
- Run 298 ✅ Kupfer-Bereich auto-aufklappen beim Laden wenn Kupfer-Werte vorhanden
- Run 298a ✅ Mitarbeitername-Feature entfernt (Einstellungs-Kachel + Schritt-3-Ladeaufruf)
- Run 299 ✅ Stückelung-Legende + Anmerkungsfeld in Schritt 2
- Run 300a ✅ TODO.md aufgeräumt (abgehakte Punkte entfernt, Duplikate zusammengeführt)
- Run 301 ✅ Desktop-Ansicht auf Smartphone-Breite begrenzt (ConstrainedBox maxWidth 430)
- Run 302–302d ✅ Schwarze Feld-Hervorhebungen (Borders, fillColor, Hint, Label) → Kino-Rot
- Run 303 ✅ Textlink „Alle zuklappen"/„Alle aufklappen" für Schritt 1 + Wechselgeld-Prüfen-Seite
- Run 304 ✅ Dev-Dialog „JSON anzeigen" nutzt echte location_id aus SharedPreferences statt Platzhalter 0
- Run 304a ✅ Dev-Dialog nutzt dieselben Body-Builder-Methoden wie der echte Flurbocash-Upload (ApiUploadService.ensureBody/settlementsBody) — garantiert identisch mit dem tatsächlich gesendeten JSON
- Run 304b ✅ Mehrere EC-Terminals/Belege korrekt an Flurbocash gemeldet — ein terminals[]-Eintrag pro TID statt einem Summen-Eintrag über alle Belege
- Run 304c ✅ Anzahl-Felder komplett aus EC-Belege-Erfassung entfernt (BelegScan, Scan-Dialog, Schritt 2, Persistenz) — nur noch Beträge zählen
- Run 304d ✅ Oberes Gesamtbetrag-Feld (1-Beleg-Modus) entfernt, Pflichtfeld auf "Gesamt (laut Beleg)" verlegt; neuer Beleg im Mehrbeleg-Modus startet mit editierbarem TID-Feld
- Run 304d2 ✅ Korrektur: "+ Weiteren Beleg hinzufügen" wieder erst nach erster Eingabe/Scan sichtbar; "Gesamt (laut Beleg)" wieder nur editierbar nach "Belegdaten bearbeiten" bzw. "manuell eingeben"; Kartenart-"+"-Buttons nur noch nach Scan für nicht erkannte Kartenarten
- Run 304d3 ✅ Leere EC-Kachel öffnet Header-Tap/"manuell eingeben" direkt alle Kartenart-Zeilen + Gesamt-Feld zur Bearbeitung; Gesamt-Label "Gesamt" (manuell) vs. "Gesamt (laut Beleg)" (nach Scan) + Hilfe-Icon; rote Hervorhebung korrigiert auf echte Scan-Problemfälle (`nichtPlausibel`) statt Pauschal-Regel
- Run 304d4 ✅ Rote Einfärbung des Gesamt-Betrags bei Summen-Mismatch entfernt (nur noch orangener Hinweistext), damit MA den ganzen Beleg statt nur das Gesamt-Feld prüft
- Run 304d5 ✅ PWA-Update-Erkennung: `visibilitychange`-Listener löst Update-Check beim Zurückkehren aus dem Hintergrund aus; neue Version wird automatisch neu geladen (kein Banner/Button mehr, da Entwürfe laufend persistiert werden)
- Run 314 ✅ Validierungs-Serie aus TODO.md gestartet: "Differenz
  Anfangsbestand > 20 €" als weicher Hinweis umgesetzt (mit
  Unit-Test); zwei weitere Punkte als technisch gegenstandslos
  geprüft und als entfällt markiert. Ab jetzt werden neue
  Validierungsregeln immer mit Unit-Test im selben Run umgesetzt.
- Run 314a ✅ Wechselgeld-Differenz-Prüfung von Hinweis auf
  Bestätigungssperre beim Verlassen umgestellt.
- Run 314a2 ✅ Korrektur von 314a (T1): Differenz-Bestätigung
  erscheint jetzt vor statt nach dem Abschluss-Menü.
- Run 315 ✅ Getränke-Auffüllen: Unterstreichung der Mengenfelder
  nur noch bei "alle anzeigen" sichtbar, bei "nur benötigte
  anzeigen" ausgeblendet + kleinerer Zeilenabstand.
- Run 315a ✅ Zeilenabstand-Feinjustierung (1 → 0,7) + Tippfehler-Fix.
- Run 316 ✅ Schritt 2: Weicher Hinweis "Bistro SOLL höher als
  Kino SOLL" (mit Unit-Test); TODO.md-Punkte "Bistro-Soll >
  Kino-Soll" und "Soll-Felder leer" abgehakt (Letzteres war schon
  vorher umgesetzt).
- Run 316a ✅ Korrektur: Hinweis aus Run 316 wieder entfernt —
  Prämisse (Kino-Umsatz > Bistro-Umsatz) gilt nicht standort-
  übergreifend (Gondel: Restaurant-Umsatz). TODO.md-Punkt wieder
  offen mit Begründung.
- Run 316b ✅ TODO.md-Kopfzeile (war seit Run 313h veraltet) auf
  aktuellen Run-Stand korrigiert; CLAUDE.md/AGENTS.md um Regel
  ergänzt, dass die Kopfzeile künftig bei jedem Run mitgepflegt
  wird.
- Run 316c ✅ ApiUploadService._pruefeStatus: Fehlermeldungen bei
  Flurbocash-Fehlern (400/401/403/404/500) zeigen jetzt zusätzlich
  den tatsächlichen Klartext aus der Server-Antwort an, statt nur
  einer generischen App-Meldung.
- Run 316d ✅ TODO.md-Block "Blockiert — wartet auf IT" mit
  aktuellem Wissensstand abgeglichen (location_id, X-API-Key-
  Modell, Testumgebung beantwortet; CORS-Punkt präzisiert:
  einziger offener Blocker ist X-API-Key in access-control-
  allow-headers). Keine App-Code-Änderung.
- Run 317 ✅ Validierungen Schritt 2 + „Eingabe mit Komma"-
  Einstellung entfernt. Pflichtfeld-Fehler als AlertDialog.
  Neue Checks: Ausgaben mit Label ohne Betrag (V3), Kino-Soll = 0
  (V5, Bestätigung), EC = 0 (V7, Bestätigung). Ziffern-Modus
  jetzt fest. Unit-Tests für 2 neue Validierungsfunktionen.
- Run 317a ✅ CORS-Header-Blocker aufgelöst: Yannik hat X-API-Key
  freigeschaltet. Erster echter Flurbocash-Live-Test (Schauburg,
  location_id 1) erfolgreich. Keine App-Code-Änderung.
- Run 319 ✅ Datenschutzhinweise vorgezogen an den geplanten
  Flurbocash-Belegfoto-Versand angepasst (datenschutz_seite.dart).
  TODO.md-Punkt für die technische Umsetzung (base64-Versand)
  ergänzt — wartet weiterhin auf Yannik-API-Vertrag.
- Run 319d ✅ Widerspruch im Run-319-Text behoben: Satz "Foto
  verlässt nie die interne Kino-IT" widersprach der Anthropic-
  USA-Übermittlung im selben Absatz und wurde entfernt; Hinweis
  auf EU-Standardvertragsklauseln als Rechtsgrundlage ergänzt.
- Run 321 ✅ Datenschutzhinweise-Link zusätzlich auf
  startmenue_seite.dart ergänzt (bisher nur auf
  kinoauswahl_seite.dart), damit er erreichbar bleibt, sobald
  der geplante Standort-Betriebsmodus die Kinoauswahl für MA
  überspringt.
- Run 321a ✅ Datenschutzhinweise-Link auf startmenue_seite.dart
  direkt unter den "Verlauf"-Button verschoben (statt unter den
  QR-Code) — dort ging er vor dem unruhigen Hintergrundbild
  unter.
- Run 318 ✅ Bestätigungs-Popup nach EC-Beleg-Scan
  (`beleg_scan_bestaetigen_dialog.dart`): Datum/TID/Kartenarten/
  Gesamtsumme, Aktionen "nochmal"/"übernehmen". Formularübernahme
  passiert jetzt erst nach "übernehmen" statt automatisch.
- Run 321b ✅ Popup-Hinweistext bei unlesbaren Daten (Nachtragen
  oder neu scannen); Kachel öffnet sich danach zur Bearbeitung;
  TID- und Kartenart-Markierung rot statt orange.
- Run 321b2 ✅ Korrektur aus Testfeedback: nur die tatsächlich
  betroffenen Kartenart-Zeilen öffnen sich automatisch (nicht alle
  — Kartenarten ohne Umsatz blieben sonst fälschlich sichtbar);
  "Kartenart?"-Dropdown dadurch wieder funktionsfähig, zugehöriger
  "+"-Chip verschwindet bei Auswahl; "Terminal-ID?" bei unlesbarer
  TID.
- Run 322 ✅ Getränke-Auffüllen: grauer "Original-Name"-Hinweis
  (zweites Namensfeld bei Zentrale-Umbenennungen) entfernt,
  inkl. totem Code (_originalNamen, ladeOriginalNamen()).
- Run 323 ✅ Next-Button in Schritt 1, Schritt 2 und
  Wechselgeld-Prüfen springt jetzt zum nächsten Feld.
- Run 323a ✅ Next-Button-Korrektur: TapRegion(groupId:
  EditableText) verhindert automatisches Tastatur-Schließen;
  Getränke-Auffüllen-Seite komplett neu mit Feld-Navigation
  verdrahtet.
- Run 323b ✅ Reine Doku-Änderung: iOS-Safari-Pfeiltasten der
  Tastatur-Werkzeugleiste als bekannt/kein Blocker
  dokumentiert (natives Browser-Verhalten, kein App-Bug).
- Run 324 ✅ Neu-Laden-Button in Einstellungen (außerhalb
  Admin-Kachel), nutzt vorhandenen reloadPage()-Service.
- Run 325 ✅ Standort-Betriebsmodus im Admin-Bereich:
  Dropdown "Alle"/festes Kino, Speicherung lokal auf dem
  Gerät (SharedPreferences). Bei festem Kino entfällt für MA
  Kinoauswahl + "Kino wechseln"-Button.
- Run 325a ✅ Neu-Laden-Button aus eigener Card gelöst, steht
  jetzt nackt ganz unten auf der Einstellungen-Seite.
- Run 326 ✅ Einstellungen-Feinschliff: Getränkeliste-Card-
  Titel zeigt Standortkürzel; neuer Schalter "Admin-Status
  halten" (übersteht Seitenwechsel im selben App-Lauf, nicht
  aber echtes Neuladen); zusammengehörende Admin-Einstellungen
  in abwechselnd getönten Bändern gruppiert.
- Run 326a ✅ "Neu laden"-Button (Run 324) wirkte trotz Tap
  wirkungslos, da nur ein einfacher Reload ausgelöst wurde —
  der Service Worker lieferte weiter seinen alten Cache aus.
  _reloadPage() löscht jetzt vorher Caches + meldet den
  Service Worker ab (dieselbe Logik wie der Fresh-Tab-Reset),
  betrifft auch den bestehenden Auto-Reload bei SW-Update.
- Run 328 ✅ Getränke-Auffüllen: Abhaken im Filtermodus "nur
  benötigte anzeigen" (runde Checkbox pro Zeile, abgehakte
  Einträge wandern ans Ende der gefilterten Liste). Nicht
  persistiert, nur Session-Sortierhilfe.
- Run 328a ✅ Korrektur aus Testfeedback: Checkbox-Farben grau/
  grün (abgehakt), Checkbox im Rechtshänder-Modus an den
  randnah verankerten Zeilenanfang verlegt (statt unverankertes
  Zeilenende), Feld-Leerung bei Fokus nur noch im Filtermodus
  aktiv (nicht mehr bei "alle anzeigen").
- Run 328a2 ✅ Korrektur: Feld-Leerung bei Fokus war in 328a
  genau umgekehrt umgesetzt — jetzt korrekt: leert sich bei
  "alle anzeigen", bleibt gefüllt bei "nur benötigte anzeigen".
- Run 328a3 ✅ AGENTS.md: feste Regel für Remote-Sessions ergänzt
  — PRs werden nach jedem Run/Sub-Run automatisch nach master
  gemergt (löst den GitHub-Pages-Deploy für Pacos PWA aus), mit
  klaren STOPP-Bedingungen bei Konflikten/fehlgeschlagenen Checks.
  Reine Doku-Änderung, kein App-Code betroffen.
- Run 328a4 ✅ Ladebalken im Splash-Screen (web/index.html):
  animierter Balken (25vw Breite, orange #FF9800) unter dem
  App-Icon, sichtbar bei jedem Laden/Neu-Laden der Seite (App-
  Start, "Neu laden"-Button, Auto-Update, Fresh-Tab-Reset) —
  verschwindet zusammen mit dem Icon beim ersten Flutter-Frame.
  Reine HTML/CSS-Änderung, kein Dart-Code betroffen.
- Run 329 ✅ Dauerhaft sichtbarer Hilfetext im Scan-Bereich der
  EC-Belege-Kachel (Schritt 2), immer sichtbar sobald die Kachel
  aufgeklappt ist. Bei der Recherche festgestellt: das ebenfalls
  geplante Basis-URL-Feld in den Einstellungen existierte bereits
  seit Run 292 ("Upload-URL", Key `api_upload_url`) — TODO.md war
  veraltet, kein Code dafür nötig.
- Run 329a ✅ Korrektur aus Testfeedback: Hilfetext um Text-Link
  "Belegdaten bearbeiten" ergänzt (kursiv, fokussiert Terminal-ID-
  Feld), verschwindet jetzt sobald mind. ein Beleg Daten hat.
  TODO.md: neuer Punkt "BelegScan-Service-URL editierbar" (Worker-
  URL in beleg_scan_service.dart, aktuell hart codiert) — Paco
  meinte damit ursprünglich die KI-Scan-URL, nicht die Flurbocash-
  Upload-URL. Als Run 330 vorgeschlagen.
- Run 329a2 ✅ Korrektur: Hinweistext von Wrap auf Text.rich
  (TextSpan + TapGestureRecognizer) umgestellt, damit der Link
  "Belegdaten bearbeiten" direkt im Fließtext hinter "Tippe auf"
  steht statt in einer neuen Zeile; gesamter Hinweis durchgehend
  kursiv.
- Run 330 ✅ Fokus-Füllfarbe von Eingabefeldern zentralisiert: neue
  Konstante AppFarben.fokusFarbe (Orange, wie Splash-Ladebalken)
  ersetzt AppFarben.appBarRot an den 5 Stellen, an denen ein Feld
  beim Fokus farbig gefüllt wird (betrag_cent_eingabefeld.dart,
  ganzzahl_eingabefeld.dart, 3× tagesabschluss_schritt2_seite.dart).
  Ränder bleiben bewusst rot (appBarRot), da Ruhezustand-Farbe,
  kein Fokus-Verhalten.
- Run 330a ✅ Korrektur: Textfarbe in orange gefüllten Feldern von
  Weiß auf Schwarz (Kontrast zu schwach). Zentraler Helfer
  clearIconFarbe() ebenfalls auf Schwarz — behebt nebenbei ein
  Kontrastproblem auf einem weiteren, hellgelben Feld.
- Run 331 ✅ Zwei weitere Stellen auf bereits bestehende
  Theme-Konstanten umgestellt (reine Konsistenz, keine optische
  Änderung): einstellungen_seite.dart nutzt jetzt
  AppFarben.footerDecoration statt eigener Kopie; 10× rohes
  Colors.black54 durch AppFarben.subtilerText ersetzt. Dritter
  Kandidat (Dev-Tools-Panel-Gelb) bewusst ausgelassen — Dev-Modus
  fliegt später komplett raus.
- Run 332 ✅ BelegScan-Service-URL im Admin-Bereich editierbar
  (Abschnitt "KI-Belegscan (Anthropic)", TextField "Service-URL" über
  dem API-Key-Feld). SharedPreferences-Key `belegscan_service_url`,
  Fallback auf bisherigen hart codierten Wert. Löst länger offenen
  TODO-Punkt aus Run 329.
- Run 332a ✅ Fokus-Orange-Konsistenz (Run 330/330a) in weiteren
  MA-sichtbaren Feldern nachgezogen: Getränke-auffüllen-Mengenfeld
  (war schwarz/weiß), Umschlag-Label (Schritt 1), Zahlungsart-Betrag/
  Gesamtbetrag/Anmerkung (Schritt 2). Bewusst offen gelassen:
  Metadaten-Felder (hellgelb statt orange) und Admin-Bereich-Felder —
  Rücksprache mit Paco nötig, ob dort ebenfalls vereinheitlicht wird.

Blockiert (wartet auf IT / Yannik): Basis-URL (Sandbox bekannt,
Produktiv-URL offen), TID-Bestätigung, 6-Uhr-Knick-Absprache.

---

## Session-Start

Zu Beginn einer neuen Session:
1. `.dev/run_counter.txt` lesen — einzige gültige Quelle für die Run-Nummer
2. `git status` prüfen
3. `flutter clean && flutter pub get` ausführen

---

## Flutter Maintenance

Skript für häufige Wartungsaufgaben:

    ./scripts/flutter_maintenance.sh           # clean (Standard)
    ./scripts/flutter_maintenance.sh upgrade   # nach flutter upgrade
    ./scripts/flutter_maintenance.sh clean     # bei mysteriösen Fehlern
    ./scripts/flutter_maintenance.sh doctor    # Systemcheck

Manuelle Kurzreferenz:

Nach flutter upgrade:
    flutter pub upgrade
    flutter pub get
    flutter clean
    flutter pub get
    flutter doctor

Bei mysteriösen Fehlern:
    flutter clean
    flutter pub get

Systemcheck:
    flutter doctor
    flutter config --enable-web
