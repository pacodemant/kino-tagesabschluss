# Project Context

Projekt: Flutter-App „Schauburg Tagesabschluss"  
Version: 0.9.3+304 · Run 306

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
    lib/utils/              → DatumsHelper (4-Uhr-Knick-Logik)
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
| SharedPreferences             | Dev-Modus, Auto-Fill, Wechselgeld-Sollwert, `flurbocash_location_id_[kinoId]` |

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
- `BelegScanGegenpruefDialog` — Prüf-Popup nach EC-Beleg-Scan

---

## Versionierung

Versionsstring in ZWEI Dateien immer synchron halten:

    lib/pages/startmenue_seite.dart   (ca. Zeile 128)
    lib/pages/kinoauswahl_seite.dart  (ca. Zeile 68)

Format: `'Web App X.X.X · rNNN @ GitHub:'`  
Bei Sub-Runs (275a) den Buchstaben in den Versionsstring eintragen (r275a, nicht r275).

---

## Laufender Entwicklungsstand (Run 304)

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

Blockiert (wartet auf IT / Yannik): Flurbocash-Credentials (location_id, API-Key,
Basis-URL, TID-Whitelist, CORS, 6-Uhr-Knick-Absprache).

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
