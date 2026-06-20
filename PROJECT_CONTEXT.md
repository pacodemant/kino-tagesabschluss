# Project Context

Projekt: Flutter-App „Schauburg Tagesabschluss"  
Version: 0.10.1+277a4 · Run 277a4

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
| SharedPreferences             | Dev-Modus, Auto-Fill, Wechselgeld-Sollwert |

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

## Laufender Entwicklungsstand (Run 277a4)

Aktuelle Phase: **BelegScan & EC-Kachel (Phase A, Runs 275–280)**

- Run 275 ✅ EC-Kachel Layout & Terminal-ID — abgeschlossen
- Run 275a…a10 ✅ Prüf-Popup vereinfacht, EC-Kachel-Korrekturen, Bugfixes, Dropdown für unbekannte Kartenart, UX-Verbesserungen — abgeschlossen
- Run 276 ✅ EC-Kachel: Gesamtsumme rechts statt Kamera-Icon (zugeklappt + Belege vorhanden); „Weiteren Beleg hinzufügen"-TextButton erst nach erstem Beleg — abgeschlossen
- Run 277 ✅ EC-Kachel: Unterkacheln pro Beleg — abgeschlossen
- Run 277a ✅ EC-Kachel Redesign: 1-Beleg flach / 2+-Belege Sub-Kacheln mit Edit/Read-Modus — abgeschlossen
- Run 277a2 ✅ EC-Kachel Sub-Kacheln — Fixes + Zahlungsarten + UX — abgeschlossen
- Run 277a3 ✅ EC-Kachel Sub-Kacheln — Fixes & UX Runde 2 — abgeschlossen
- Run 277a4 ✅ EC-Kachel Betrag-Vergleich-Fix + Button-Rename — abgeschlossen
- Run 278 ⬜ Prüf-Popup: Inline-Korrektur
- Run 279 ⬜ Dev-Modus: "see JSON"-Button im Prüf-Popup
- Run 280 ⬜ Hilfetext: Belegkopie ziehen

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
