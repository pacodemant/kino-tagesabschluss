# Project Context

Projekt: Flutter-App „Schauburg Tagesabschluss"  
Version: 0.9.87+429a2 · Run 429a2

Zweck: Unterstützung des Kino-Tagesabschlusses (Kassen- und Bargeldzählung)
für mehrere Standorte der Schauburg GmbH.

Zielplattform: Web (iOS-Safari als primäre Testumgebung, PWA-fähig).

---

## Wichtige Ordner

    lib/                    → Flutter-App-Code
    lib/pages/              → Seiten (Screens)
    lib/pages/tagesabschluss_schritt1/  → Schritt-1-Untermodule (sections, ui, scroll, …)
    lib/pages/tagesabschluss_schritt2/  → Schritt-2-Untermodule (seit Run 341;
                                           sections/, ui/, controller/, models/,
                                           scroll/ — wächst weiter)
    lib/pages/tagesabschluss_schritt3/  → Schritt-3-Untermodule (seit Run 354;
                                           sections/ mit 5 statischen Rahmen-
                                           Widgets)
    lib/pages/einstellungen/            → Einstellungen-Untermodule (seit
                                           Run 355; sections/, ui/ — wächst
                                           in weiteren Sub-Runs)
    lib/models/             → Datenmodelle
    lib/services/           → Services (BelegScan, API-Upload, Konfiguration, …)
    lib/storage/            → LokalerSpeicher (SharedPreferences- + Hive-
                                           Wrapper, siehe Persistenz-Tabelle
                                           unten)
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
- `TerminalIdsConfigService` — TIDs pro Standort aus `config/terminal_ids.json`
  (seit Run 399, Warnungs-Abgleich in `ApiUploadService.upload()`;
  seit Run 399a6 zusätzlich im Bestätigungs-Popup direkt nach dem
  BelegScan in Schritt 2, siehe `beleg_scan_bestaetigen_dialog.dart`)
- `DevModus` — Dev-Modus (SharedPreferences-Key `dev_modus_aktiv`)
- `PwaInstallService` / `StoragePersistService` — Web-spezifisch (Stub für andere Plattformen)

### Wichtige Widgets

- `GanzzahlEingabefeld` — Ganzzahl-Eingabe mit Clear-Button, Fokus-
  Hervorhebung; seit Run 336a zusätzlich "+"-Additions-Eingabe
  möglich (z. B. "5+3" → 8 nach Fokusverlust)
- `BetragCentEingabefeld` — Cent-Eingabe mit automatischem Komma
  (Supermarktkassen-Format); seit Run 336 zusätzlich "+"-Additions-
  Eingabe möglich (z. B. "260+20" → 280 nach Fokusverlust)
- `TagesabschlussScaffold` — gemeinsames Layout (AppBar, Footer-Button, Keyboard-Handling)
- `CollapsibleCardSection` — klappbare Card-Sektion
- `zeigeBelegScanBestaetigenDialog` (`beleg_scan_bestaetigen_dialog.dart`)
  — Bestätigungs-Popup nach EC-Beleg-Scan ("nochmal"/"übernehmen"),
  seit Run 318. Ersetzt NICHT das gleichnamig klingende, in Run 307
  entfernte `BelegScanGegenpruefDialog` (anderer Zweck). Seit Run
  399a6 optionaler Parameter `tidKonfigWarnung`: zeigt eine rote
  Warnzeile bei der TID, wenn diese laut
  `config/terminal_ids.json` für den Standort nicht erwartet wird.
- `HeuteBadge` / `NichtGesendetBadge` — Verlauf-Badges (heutiger Tag
  bzw. noch nicht an Flurbocash gesendet, seit Run 387)

---

## Versionierung

Versionsstring in ZWEI Dateien immer synchron halten:

    lib/pages/startmenue_seite.dart   (ca. Zeile 128)
    lib/pages/kinoauswahl_seite.dart  (ca. Zeile 68)

Format: `'Web App X.X.X · rNNN @ GitHub:'`  
Bei Sub-Runs (275a) den Buchstaben in den Versionsstring eintragen (r275a, nicht r275).

---

## Laufender Entwicklungsstand (Run 429)

- Run 429 ✅ Architektur-Run: Ausgaben-Familie in Schritt 2 von 7
  parallelen Listen auf eine List<AusgabenZeile> konsolidiert (neues
  Modell lib/pages/tagesabschluss_schritt2/models/ausgaben_zeile.dart).
  Nach außen (Section-Widget, Fokus-Helper, Persistenz-Format)
  unverändert — reine interne Vereinfachung, ~90 Fundstellen betroffen.
  Neuer Widget-Interaktionstest für Zeile hinzufügen/entfernen. Erster
  Teil einer 2-Run-Serie, EC-Beleg-Familie (15 Listen, ~356 Fundstellen)
  folgt als eigener, größerer Run. Details siehe CHANGELOG.md.

- Run 428 ✅ Verbliebene Hinweis-SnackBars in Schritt 2/3 auf den
  bestehenden zeigeHinweisSnackBar()-Helfer (lib/widgets/
  hinweis_snackbar.dart) umgestellt: 10 Stellen (4x Schritt 2, 6x
  Schritt 3) bauten den ScaffoldMessenger/SnackBar-Boilerplate
  unabhängig vom Helfer nach. Neu ergänzt: zeigeHinweisSnackBarRich()
  im selben File für den TID-Konfigurationsfehler-Fall mit
  hervorgehobenem Teiltext. Rein technisch, kein UI-Unterschied.
  Details siehe CHANGELOG.md.

- Run 427 ✅ Doppel-Versand-Lücke bei Schritt-3-Neuaufbau geschlossen:
  der Signatur-Abgleich beim Öffnen von Schritt 3
  (tagesabschluss_schritt3_seite.dart) setzte bei einer Übereinstimmung
  bisher nur den optischen "gesendet"-Haken, nicht aber die Sperre
  gegen einen erneuten _doApiUpload()-Aufruf. Dadurch konnte eine
  unveränderte Abrechnung bei einem Neuaufbau der Seite (z. B.
  erneuter Durchlauf durch Schritt 1-3 für denselben Tag) ein zweites
  Mal an Flurbocash gesendet werden. Jetzt wird `_apiUploadErledigt`
  im selben Zweig mitgesetzt. Details siehe CHANGELOG.md.

- Run 426 ✅ Geldarten-Hinweise auf Schritt 1 komprimiert: statt zwei
  nacheinander gezeigter Dialoge (erst Scheine, dann lose Münzen)
  zeigt _pruefeEingabenUndWeiterZuSchritt2() jetzt einen einzigen
  AlertDialog mit den fehlenden Angaben nach Scheine/Münzen
  gruppiert. Rollen und "Sonstiges (Umschläge u.a.)" bleiben bewusst
  ungeprüft (unverändert). Kein harter Block: "Korrigieren" bleibt
  auf der Seite, "Bestätigen" füllt fehlende Felder mit 0 und macht
  weiter. Details siehe CHANGELOG.md.

- Run 425 ✅ Vierter Aufräum-Run aus der Code-Qualitäts-Diagnose (Fund
  12): neue Methode DatumsHelper.istGleicherKalendertag() ersetzt 3
  unabhängig gepflegte Jahr/Monat/Tag-Vergleiche in
  SpeichereTagesabschlussUsecase und LokalerSpeicher (ersetzen/
  löschen). Reine Zentralisierung, Verhalten unverändert. Details
  siehe CHANGELOG.md.

- Run 424a ✅ Korrektur zu Run 424: "Kino Soll"-Label war für Cinema
  Ostertor (kein Bistro) noch an 4 weiteren Stellen hartcodiert
  (Schritt3SollSection, verlauf_detail_seite.dart,
  einstellungen_seite.dart Auto-Fill-UI, uebertrag_umschlag_seite.dart)
  und zeigte dort weiterhin "Kino Soll" statt "Gesamt SOLL" wie
  bereits in Schritt 2. Jetzt überall auf Kino.hatBistro umgestellt.
  Details siehe CHANGELOG.md.

- Run 424 ✅ Dritter Aufräum-Run aus der Code-Qualitäts-Diagnose (Fund
  4): neues `Kino.hatBistro`-Feld (kino.dart, Muster wie
  hatGetraenke/hatWechselgeld) ersetzt 8 verstreute
  `kinoId == 'kino_04'`-Vergleiche in 5 Dateien. Bewusst nicht
  angefasst: 3 separate `kino_04`-Vergleiche für die
  Personalgetränke-Regel (eigene, seit Run 372a bewusst getrennte
  Fachregel) sowie die Kino-ID-Switch-Blöcke für Testwerte (Fund 3,
  eigener Architektur-Run). Details siehe CHANGELOG.md.

- Run 423 ✅ Zweiter Aufräum-Run aus der Code-Qualitäts-Diagnose (Fund
  1): die 6 EC-Kartenarten waren in api_upload_service.dart an 3
  unabhängigen Stellen hart codiert (Mapping-Zielwerte,
  Summenprüfungs-Liste, JSON-Ausgabe). Jetzt eine Liste
  `_kartenarten` + Alias-Map `_kartenartAliase` als Quelle, Mapping/
  Summenprüfung/JSON-Ausgabe leiten sich davon ab. Verhalten
  unverändert (JSON-Feldreihenfolge ist irrelevant). Bewusst nicht
  angefasst: totes EcTerminalErgebnis-Modell (eigener Fund). Details
  siehe CHANGELOG.md.

- Run 422a ✅ Korrektur zu Run 422: Layout der Personalgetränke-Kachel
  umgestellt (Row aus Text-Column | Checkbox statt Column aus Row |
  Text-Zeilen) — Checkbox jetzt vertikal über alle drei Zeilen
  zentriert, Abstand zwischen allen drei Zeilen einheitlich 4px.

- Run 422 ✅ Personalgetränke-Kachel (Schritt 2) um zwei reine
  Hinweiszeilen ergänzt: "Artikel gestundet?" und "Denk' ans
  Kellnerportemonnaie." (letzte Zeile in Rot). Kein neuer State,
  keine Persistenz-Änderung.

- Run 421 ✅ Code-Qualitäts-Diagnose über lib/ (Fund aus Run 416/419/420
  aufgegriffen: dieselbe Konfiguration an mehreren Stellen von Hand
  synchron gehalten) hat u.a. die SharedPreferences-Keys
  `flurbocash_location_id_$kinoId`/`flurbocash_api_key_$kinoId` als
  rohe String-Literale an 9 Stellen in 3 Dateien gefunden. Jetzt
  zentral in `ApiUploadService.locationIdPrefKey()`/`apiKeyPrefKey()`
  (Key-Werte selbst unverändert, nur die Konstruktion zentralisiert).
  Weitere Diagnose-Funde (Kartenarten-Liste, Kino-ID-Switches,
  Bistro-Flag, u.a.) stehen offen und werden als eigene Runs
  nachgezogen.

- Run 420 ✅ Run-419-Fix verhinderte nur künftigen Datenverlust,
  reparierte bereits kaputte Auto-Fill-Altstände nicht.
  LokalerSpeicher.ladeAutoFillSchritt2() füllt beim Laden jetzt
  automatisch mit Standard-Kartenarten nach, falls der gespeicherte
  Stand keine zahlungsartenNamen enthält. 2 neue Unit-Tests. Details
  siehe CHANGELOG.md.

- Run 419 ✅ Echte Ursache des Run-416-Bugs gefunden:
  `_speichereAutoFillSchritt2()` in `einstellungen_seite.dart` löschte
  beim Speichern der 5 dortigen Auto-Fill-Felder stillschweigend die
  zuvor gespeicherten Kartenarten-Testdaten, weil dafür keine
  Einstellungen-UI existiert. Neuer, testbarer Helper
  `LokalerSpeicher.autoFillSchritt2MitBestehendenZahlungsarten()` führt
  sie jetzt fort. 3 neue Unit-Tests. Details siehe CHANGELOG.md.

- Run 416 ✅ Auto-Fill (DEV-Tools, Schritt 2) füllte bei ungünstigem
  Timing keine Kartenarten-Beträge (Race Condition beim asynchronen
  Laden von `config/zahlungsarten.json`, siehe CHANGELOG.md).
  `_autoFillDev()` wartet jetzt auf den Konfig-Ladevorgang, bevor der
  Namensabgleich läuft.

- Run 414a3 ✅ Popup-Text weiter vereinfacht (redundantes "Bitte
  pruefen." entfernt). Echter Fund behoben: eine manuell eingetippte
  (nicht gescannte), falsche TID im Mehrbeleg-Modus zeigte nach dem
  Weiter-Block keine Eingabemöglichkeit/Hervorhebung mehr. Neue
  Methoden `_ecBelegHatTidProblem()` (fokus-unabhängig, steuert
  Lese-/Editier-Modus) und ergänztes `_subKachelTidUnleserlich()`
  (Konfig-Abgleich nur bei fehlendem Fokus, Run-374-Konvention) lösen
  das für Ein- und Mehrbeleg-Modus einheitlich. Details siehe
  CHANGELOG.md.

- Run 414a2 ✅ Drei Test-Rückmeldungen zu Run 414a: Popup-Text
  vereinfacht; echter Bug behoben (`_ecBelegHinzufuegen()` klappte
  eine Kachel mit ungelöstem TID-Fehler beim Hinzufügen eines
  weiteren Belegs zu, obwohl ihr roter Bearbeitungsmodus stehen
  blieb — jetzt bleibt sie aufgeklappt); Hint-Text "Terminal-ID?" auf
  "TID eintragen" umbenannt (Ein- und Mehrbeleg-Modus). Details siehe
  CHANGELOG.md.

- Run 414a ✅ Korrektur zu Run 414: Scan-Popup blockiert "übernehmen"
  bei TID-Abweichung nicht mehr komplett (es gab keinen Abbrechen-Weg
  zurück zum Hinweistext). Stattdessen wird die ungültige TID beim
  Übernehmen einfach nicht ins Feld geschrieben — Feld bleibt leer,
  zeigt automatisch den bestehenden "TID unleserlich"-Zustand (rotes
  Hint + roter Rahmen) und wird fokussiert, MA trägt die TID manuell
  nach. Details siehe CHANGELOG.md.

- Run 414 ✅ TID-Prüfung gegen config/terminal_ids.json ist jetzt an
  allen drei Stellen (Scan-Popup, Weiter-Button Schritt 2→3, Senden)
  blockierend statt nur ein weicher Hinweis — Paco-Entscheidung: TID
  ist eindeutig, falsche Ziffer wird abgelehnt. `ApiUploadService.
  upload()` wirft jetzt vor dem eigentlichen Versand, Rückgabetyp
  vereinfacht (kein `warnungen`-Feld mehr, da im Erfolgsfall immer
  leer). Details siehe CHANGELOG.md.

- Run 413a2 ✅ Korrektur zu Run 413a: Objekt-Umstellung pro TID
  wieder zurückgebaut (`terminal_ids` wieder flache String-Liste,
  `TerminalIdsConfigService.laden()` wieder `cast<String>()`) — der
  Alt/Neu-Hinweis steht stattdessen gesammelt im `"_comment"`-Kopf der
  Datei. Zusätzlich CO (Cinema Ostertor) bekommt die 2026-08-30
  entfernte alte TID `54017639` zurück (beide TIDs gültig, bis Paco
  die alten nach vollständiger Terminal-Umstellung manuell entfernt).
  Details siehe CHANGELOG.md.

- Run 413a ✅ `config/terminal_ids.json`: TID-Liste pro Standort von
  flachen Strings auf Objekte `{"tid": ..., "kommentar": ...}`
  umgestellt, damit jede TID dokumentarisch als "alte TID"/"neue TID"
  gekennzeichnet werden kann (Standard-JSON kennt keine echten
  Kommentare). `TerminalIdsConfigService.laden()` entsprechend
  angepasst. Details siehe CHANGELOG.md.
  KORRIGIERT in Run 413a2 (siehe dort) — Objekt-Struktur wieder
  zurückgebaut, Paco wollte den Kommentar nicht als Datenfeld.

- Run 413 ✅ Scan-Metadaten-Block in der EC-Kachel (Schritt 2) wird
  nur noch im Dev-Modus angezeigt, statt immer sichtbar zu sein.
  Reine Sichtbarkeits-Änderung über das bereits vorhandene
  `_devModusAktiv`-Feld. Details siehe CHANGELOG.md.

- Run 412 ✅ Update-Reload passiert nicht mehr mitten in einer offenen
  Abrechnung: neuer `UpdateReloadGuard` (NavigatorObserver) lädt nur
  neu, wenn Kinoauswahl oder Startmenü sichtbar ist. Prüf-Häufigkeit
  (Start/Vordergrund, max. 1x/24h) aus Run 411 unverändert. Details
  siehe CHANGELOG.md.

- Run 411 ✅ Update-Erkennung (`web/index.html`) auf `version.json`-
  Vergleich umgestellt statt Service-Worker-Events — Flutter generiert
  seit 3.44.5 keinen versionierten Service Worker mehr (nur noch
  Aufräum-Stub). Prüfung höchstens 1x/24h, beim Laden und beim
  Zurückkehren aus dem Hintergrund. Details siehe CHANGELOG.md.

- Run 410a ✅ Korrektur zu Run 410: Weiter-Button Schritt 1 → Schritt 2
  zeigte noch "Belege eingeben (2/4)", jetzt "Umsätze eingeben (2/4)".
  Details siehe CHANGELOG.md.

- Run 410 ✅ "Belege" → "Umsätze" umbenannt (reiner Text-Fix, fünf
  Stellen: AppBar-Titel + Hilfetext Schritt 2, Verlauf-Detail-Kachel,
  Kurzeinstieg, Schritt-Wechsel-BottomSheet). EC-Belege-Vorkommen
  bewusst unverändert. Details siehe CHANGELOG.md.

- Run 409 ✅ Auto-Fill (Dev-Modus, Schritt 2) nutzt jetzt die für den
  jeweiligen Standort tatsächlich aktive TID aus
  config/terminal_ids.json statt hart die erste SB-TID zu setzen.
  Neue reine Methode TerminalIdsConfigService.aktiveTid(). Details
  siehe CHANGELOG.md.

- Run 408 ✅ Verlauf-Detail: "Bargeld"-Kachel zeigt im Titelbereich
  jetzt den bereinigten Bar-Bestand statt des ungekürzten
  Kassenbestands (reiner Werte-Austausch). Details siehe CHANGELOG.md.

- Run 407 ✅ Verlauf-Detail: Sende-Button zeigt "Jetzt senden" statt
  "Erneut senden", wenn ein Eintrag noch nie gesendet wurde. Details
  siehe CHANGELOG.md.

- Run 406 ✅ Kino-/Bistro-SOLL-Kachel (Schritt 2): die beiden reinen
  Info-Zeilen "Umsätze gesamt/abzgl. Ausgaben (Info)" entfernt, dabei
  die dadurch toten gesamtUmsatzCent/gesamtNachAusgabenCent-Werte
  komplett durchgereicht entfernt statt totes Durchreichen stehen zu
  lassen. Details siehe CHANGELOG.md.

- Run 405 ✅ EC-Scan: überflüssige Bestätigungs-SnackBar nach
  erfolgreichem Scan entfernt (EC-Kachel zeigt die Daten ohnehin
  direkt aufgeklappt). Fehler-SnackBars unverändert. Details siehe
  CHANGELOG.md.

- Run 404 ✅ Verlauf-Detail: "Ergebnis"-Kachel ist jetzt initial
  aufgeklappt statt eingeklappt (Paco-Wunsch). Reiner Wertewechsel.
  Details siehe CHANGELOG.md.

- Run 403 ✅ Geschäftstag-Cutoff von 6 auf 5 Uhr umgestellt (Yannik-
  Bestätigung für Flurbocash). Reiner Wertewechsel in
  `DatumsHelper._geschaeftstagCutoffStunde`, einzige Quelle für die
  Regel, wirkt automatisch auch für
  `TagesabschlussFinalisierenUsecase.finalisieren()`. Details siehe
  CHANGELOG.md.

- Run 402 ✅ Regression aus Run 401 behoben: das grüne "gesendet"-Häkchen
  im Startmenü erschien nie mehr, da `_pruefeAbrechnungHeuteGesendet()`
  ein `isoDatum`-Feld erwartete, das seit Run 401 nicht mehr Teil der
  Sende-Signatur ist. `LokalerSpeicher.speichereSendeBestaetigung()`
  speichert das logische Sendedatum jetzt separat (eigener
  SharedPreferences-Key), unabhängig von der Signatur selbst. Details
  siehe CHANGELOG.md.

- Run 401 ✅ `_sendeSignatur()` (Schritt 3) auf die FC-relevanten Felder
  verengt: direkt aus `ApiUploadService.settlementsBody()` abgeleitet
  (ohne `sent_at`) statt der kompletten Schritt-1/2-Eingabe. Der grüne
  "gesendet"-Haken verschwindet damit nur noch bei Änderungen, die FC
  tatsächlich betreffen (Bargeldbestand, Kartenumsätze pro Kartenart,
  Belegfoto, Anmerkung) — nicht mehr bei rein lokalen Feldern wie der
  Differenz im Anfangsbestand. Absturzschutz ergänzt (Sentinel bei
  unvollständigen EC-Daten statt Exception). Bestandsdaten mit alter
  Signatur zeigen einmalig "nicht gesendet", korrigiert sich beim
  nächsten Versand von selbst. Details siehe CHANGELOG.md.

- Run 400 ✅ TODO.md durchgesehen und neu sortiert (u. a. drei veraltete
  Mailversand-Referenzen bereinigt, Paco-Entscheidung 2026-08-26: kein
  Mailversand als Fallback). Anschließend die Flurbocash-Sendeszenarien
  "2x versandt"/"korrigiert + erneut versandt"/"gar nicht versandt" per
  Code-Durchspiel geprüft: konkreter Doppel-Versand-Bug in
  tagesabschluss_schritt3_seite.dart gefunden und behoben (Sende-Button
  war nur während des Auto-Saves gesperrt, nicht während des laufenden
  Uploads — `buttonGesperrt` jetzt zusätzlich um `_apiUploadLaeuft`
  erweitert). Zwei weitere Funde nur dokumentiert (kein Bugfix in
  diesem Run, siehe TODO.md): irreführender Button-Text "Erneut senden"
  in verlauf_detail_seite.dart auch bei nie gesendeten Einträgen; sowie
  eine nicht am Server verifizierte Annahme, dass Korrekturen über
  `_ensure()`+PUT bereits idempotent überschrieben werden. Details siehe
  CHANGELOG.md und TODO_ERLEDIGT.md.

- Run 399a8 ✅ Debug-Button "Server-Antwort anzeigen" (Schritt 3,
  neben "JSON anzeigen") ergänzt, um ohne Browser-DevTools zu prüfen,
  was Flurbocash bei mehreren terminals[]-Einträgen gleicher TID
  tatsächlich verbucht (Verdacht: TID ist dort ein Upsert-Schlüssel,
  siehe EXTERNAL_API_Schauburg_de.md "Korrekturen"). Rein additiv,
  kein Sende-Verhalten geändert. Details siehe CHANGELOG.md.

- Run 399b ✅ Direkte Anweisung ohne eigene Run-Nummer (neues Thema,
  daher "b" statt Fortsetzung der "a"-Kette). Paco fand im Verlauf
  zwei Abrechnungen für "heute", "Übertrag auf Umschlag" fragte
  deshalb nach der richtigen. Neue Methode
  `LokalerSpeicher.ladeFinaleTagesabschluesseNeuesteProTag()` zeigt
  in Verlauf und auf der Startseite pro Kalendertag nur noch den
  zuletzt erstellten Eintrag; die dadurch unerreichbare Auswahl-
  BottomSheet-Logik in `startmenue_seite.dart` wurde entfernt.
  `SpeichereTagesabschlussUsecase` bleibt unverändert auf der
  ungefilterten Rohliste. Bewusste Einschränkung (Paco-Entscheidung
  nach Rückfrage): betrifft auch die Bar-Tabak-2-Abrechnungen/Tag-
  Regel und die geplante Korrektur-Badge-Idee — beide noch nicht
  umgesetzt, TODO.md an beiden Stellen um einen Hinweis ergänzt.
  Details siehe CHANGELOG.md.

- Run 399a4 ✅ Direkte Anweisungen ohne eigene Run-Nummer (Ergänzung zu
  Run 399a3), zwei Fixes rund um das Dev-Modus-Kennzeichen "testdaten":
  (1) `_anmerkungFuerUebertragung()` (tagesabschluss_schritt2_seite.dart)
  hängt an das Kennzeichen jetzt Sende-Datum/-Uhrzeit an (Format
  "testdaten 26.9. Mo 12:34"), damit Testabrechnungen auch zeitlich
  zuordenbar sind. (2) `SpeichereTagesabschlussUsecase` zählt
  vorhandene Abschlüsse mit "testdaten" in der Anmerkung nicht mehr
  für die Duplikat-Prüfung pro Kino/Tag mit — Testläufe blockieren
  damit nicht mehr die Duplikat-Prüfung für echte Abrechnungen
  desselben Tages. Kommentarfeld war bereits vom Auto-Fill
  ausgenommen (keine Code-Änderung nötig). Details siehe CHANGELOG.md.
- Run 399a3 ✅ Drei Bugs behoben, die Paco beim Live-Test von Run 399a2
  gefunden hat: (1) zwei EC-Belege mit identischer TID wurden zu einer
  `terminals[]`-Zeile summiert statt als zwei separate Einträge
  gesendet (Yannik-Antwort dazu bereits am 2026-08-26 vorgelegen,
  Code-Fix jetzt umgesetzt: `ZahlungsartErgebnis.belegIndex`,
  `ApiUploadService._terminalsListe()`/`_fotoProGruppe()` gruppieren
  jetzt primär nach Beleg statt nach TID, Fallback für Alt-Daten
  erhalten). (2) Debug-Dialog "JSON anzeigen" stürzte ab, weil das
  komplette Beleg-Foto als ein einziger, sehr langer Base64-String in
  einem SelectableText landete — jetzt für die Anzeige gekürzt, echter
  Versand unverändert. (3) Sichtbares Kommentarfeld blieb trotz
  Dev-Modus leer — jetzt automatisch mit "testdaten" vorbefüllt.
  Details siehe CHANGELOG.md und TODO_ERLEDIGT.md.

- Run 399a2 ✅ Widget-Test für die neue Verlauf-Beleg-Foto-Miniatur
  ergänzt (test/pages/verlauf_detail_seite_test.dart), nachdem Paco
  nach dem tatsächlichen Testnachweis für Run 399a fragte. Kein
  Produktivcode geändert. Details siehe CHANGELOG.md.

- Run 399a ✅ Direkte Anweisung ohne eigene Run-Nummer, Ergänzung zu
  Run 399: Yannik hat den Vertrag für Beleg-Fotos in der
  Flurbocash-Übertragung geliefert. `settlementsBody()` schickt jetzt
  zusätzlich `note` (Kommentar aus Schritt 2, im Dev-Modus automatisch
  mit "testdaten" markiert), `sent_at` (Sende-Zeitstempel) und pro
  Terminal `receipt_photo`/`receipt_media_type` (der beim KI-Beleg-Scan
  bereits kodierte Foto-Base64, bisher nach der KI-Auswertung
  verworfen). `BelegScanService.scan()` gibt dafür ein Record mit
  Ergebnis + Foto zurück; Schritt 2 hält Foto+Media-Type pro
  Beleg-Index parallel zu `_ecBelegLabels`; `TagesabschlussFinal` trägt
  beide neuen Listen dauerhaft. Verlauf-Detailseite zeigt gescannte
  Belege zusätzlich als antippbare Miniatur mit Vollbild-Zoom (reine
  Flutter-Bordmittel, keine neue Dependency). Export/Teilen des Fotos
  bewusst noch nicht umgesetzt — braucht laut Standard-Lock erst Pacos
  Freigabe für eine neue Dependency oder eine Web-Build-Änderung,
  siehe TODO.md. Details siehe CHANGELOG.md und TODO_ERLEDIGT.md.

- Run 399 ✅ Diagnose zu falsch/als 0€ ankommenden Flurbocash-Beträgen.
  Zwei Bugs in `ApiUploadService._terminalsListe()` behoben (Kartenart-
  Mapping ohne Normalisierung verlor Beträge stillschweigend; keine
  Konsistenzprüfung EC-Umsatz vs. Kartenart-Aufschlüsselung). Neu:
  TID-Abgleich gegen `config/terminal_ids.json` als nicht-blockierende
  Warnung (`TerminalIdsConfigService`, `upload()` liefert jetzt
  `Future<List<String>>`). Details siehe CHANGELOG.md und
  TODO_ERLEDIGT.md. Offene Anschlussfragen (nicht in diesem Run
  behoben): `isCorsArtFehler()`-Fallback markiert Uploads bei jedem
  generischen Netzwerkfehler als erfolgreich; `settlement_number` wird
  nirgends gesetzt, jeder erneute Sendeversuch legt eine neue statt
  einer korrigierten Abrechnung an (siehe TODO.md "Erneut senden →
  Korrektur-Call + Max-4-Fehlermeldung").

- Run 398b ✅ Direkte Anweisung ohne eigene Run-Nummer, drei Punkte aus
  Pacos Feedback zu Run 396a: (1) Revert — Löschen der heutigen
  Verlauf-Abrechnung setzt den grünen "gesendet"-Haken im Startmenü
  NICHT mehr zurück (Paco: die Daten wurden ja trotzdem gesendet,
  Run 396a war fachlich falsch gedacht). (2) Verlauf-Löschen (Liste +
  Detailseite) ist jetzt an die bestehende PIN-Admin-Session gekoppelt
  — Löschen-Button nur sichtbar, wenn die Admin-Session (Einstellungen,
  PIN) in dieser App-Session bereits entsperrt wurde. Dafür Admin-
  Session-Flag aus einstellungen_seite.dart in neue Klasse
  AdminSession (lib/services/admin_session.dart) ausgelagert. (3)
  TODO.md um Pacos Idee "Korrektur legt zusätzlichen Verlaufseintrag
  mit Heute+Korr.-Badge an" präzisiert (nur Dokumentation, keine
  Umsetzung). Details siehe CHANGELOG.md.

- Run 397a ✅ Ergänzung zu Run 397: manuell von Paco vorbereitete
  Textänderung nachträglich mitcommittet (ExpansionTile-Titel in
  der Verlauf-Detailansicht: "Geldzählung" → "Bargeld") sowie zwei
  Dev-Notizen (.dev/finale_codeueberpruefung.md, .dev/hilfetexte.md).
  Details siehe CHANGELOG.md.

- Run 397 ✅ Neuer Button "Heutige Abrechnung zurücksetzen (Test)" in
  den Einstellungen (unter "App neu laden", bewusst außerhalb des
  PIN-Admin-Bereichs, rote Button-Farbe + Bestätigungsdialog). Löscht
  für den aktuell gewählten Standort Schritt-1/2-Entwurf,
  Wechselgeld-Zähl-Entwurf und eine finalisierte heutige Abrechnung
  inkl. Gesendet-Status. Nur für die Testphase. Details siehe
  CHANGELOG.md.

- Run 396a ✅ Ergänzung zu Run 396: Löschen der heutigen Abrechnung im
  Verlauf entfernt jetzt auch den grünen "gesendet"-Haken auf dem
  Kassenabrechnung-Button im Startmenü (Sende-Signatur wurde beim
  Löschen bisher nicht mitgelöscht). Details siehe CHANGELOG.md.

- Run 396 ✅ Sende-Status im Verlauf: gesendetAm wurde im Erfolgsfall des
  automatischen Uploads (Schritt 3) nicht persistiert, wenn die Seite vor
  Upload-Ende verlassen wurde (v. a. über "Zurück zur Startseite") —
  markiereAlsGesendet() stand fälschlich in einem if(mounted)-Block.
  Betraf praktisch alle Abrechnungen, obwohl der Upload selbst erfolgreich
  war. Zusätzlich: Verlauf-Liste lud nach Rückkehr aus der Detailseite nur
  bei Löschung neu, nicht nach "Erneut senden". Details siehe CHANGELOG.md.

- Run 395 ✅ Seitenwechsel-Warnung: Schritt 1 und Schritt 2 fragen jetzt
  nach ("Seite verlassen?"), wenn beim Verlassen der Seite (Zurück-Geste,
  Haus-Button oder AppBar-Schritt-Slider — nicht aber der reguläre
  "Weiter"-Button) bereits mindestens ein Feld ungleich 0/leer ist.
  Schritt 3 und Schritt 4 haben keine eigenen Eingabefelder (reine
  Zusammenfassung/Berechnung) und bekamen die Prüfung daher bewusst
  nicht. Details siehe CHANGELOG.md.

- Run 390–394 ✅ 5 kleinere Fixes in einem Rutsch: AppBar-Schritt-Sprung zu
  allen 4 Schritten (auch unausgefüllt), Ladebalken beim Flurbocash-Versand,
  "0" verschwindet bei Fokus in Eingabefeldern, Wechselgeld-prüfen-Altdaten
  vom Morgen-Check werden bei Abend-Prüfung geleert, Kassenabrechnung-Button
  zeigt grauen statt fehlenden Haken vor erfolgreichem Versand. Details
  siehe CHANGELOG.md.

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
  Metadaten-Farbe zwischenzeitlich als Absicht bestätigt, nur
  Admin-Bereich bleibt offen (TODO.md).
- Run 332a2 ✅ Neues Dev-Tool in main.dart: Layout-Begrenzungslinien
  (`debugPaintSizeEnabled`) nur bei `kDebugMode && !kIsWeb` — schnelles
  Layout-Tuning per Hot-Reload im iOS-Simulator, nie sichtbar im
  Web-Build/PWA. Getränke-auffüllen: Checkbox-Zwischenraum bei "nur
  benötigte anzeigen" verkleinert (Checkbox-Spalte auf
  IntrinsicColumnWidth, Eingabefeld-Spalte 72→44).
- Run 333 ✅ Neuer Button "Übertrag auf Umschlag" auf der Kino-
  Startseite — zeigt nachträglich die Übertrag-Werte (gleiches
  Karten-Layout wie Schritt 3) eines heute bereits abgeschlossenen
  Tagesabschlusses, als eigenständige neue, rein lesende Seite
  (uebertrag_umschlag_seite.dart). Ausgegraut (aber antippbar mit
  Hinweis-Dialog) solange heute keine Abrechnung vorliegt; bei
  mehreren Abschlüssen am Tag (Bar Tabak) Auswahl-BottomSheet. Neue
  Helper-Methode LokalerSpeicher.ladeHeutigeFinaleTagesabschluesse().
- Run 333a ✅ Korrektur: Button blieb nach frischer Abrechnung
  ausgegraut (Reload half — Timing-/Rebuild-Problem, keine
  Datenfehler). FutureBuilder mit inline erzeugtem Future durch
  privates StatefulWidget _UebertragUmschlagButton ersetzt, das nur
  einmal in initState() lädt.
- Run 333b ✅ Weiterer Fall desselben Anti-Patterns behoben: Button
  blieb nach Löschen der heutigen Abrechnung im Verlauf fälschlich
  rot (initState() lädt nicht erneut bei pop()-Rückkehr). Auch der
  "Kino wechseln"-FutureBuilder war betroffen. StartmenueSeite jetzt
  StatefulWidget mit RouteAware (neuer globaler RouteObserver,
  route_observer.dart) — didPopNext() lädt beide Werte neu, sobald
  die Seite nach einem pop() wieder sichtbar wird.
- Run 334 ✅ BelegScan-Service-URL: hart codierten Fallback
  (`standardWorkerUrl`) aus beleg_scan_service.dart entfernt.
  `ladeWorkerUrl()` liefert nur noch den in SharedPreferences
  gespeicherten Wert; ist er leer, wirft `scan()` jetzt eine klare
  BelegScanException ("Service-URL nicht konfiguriert"), statt still
  auf einen unsichtbaren Code-Default zurückzufallen. Admin-Bereich-
  Hint zeigt nur noch ein Format-Beispiel, keinen echten Wert mehr.
  Betriebs-Konsequenz: Auf jedem Gerät, auf dem das Feld bisher leer
  war, muss die URL jetzt manuell einmalig eingetragen werden.
- Run 334a ✅ Korrektur: Die neue Fehlermeldung aus Run 334 kam nie
  beim Nutzer an, weil der Snackbar-Filter in _starteEcBelegScan
  (tagesabschluss_schritt2_seite.dart) bislang jeden Fehler außer
  Netzwerkfehlern auf den generischen Text "Scan nicht lesbar"
  abbildete. Neue Prüfung `istKonfigurationsFehler` zeigt bei
  fehlender Service-URL jetzt den echten Klartext statt des
  irreführenden Lesbarkeits-Hinweises.
- Run 334a2 ✅ Zwei gebündelte Direkt-Anweisungen: Snackbar-Hinweis
  "Beleg kann auch manuell eingegeben werden." jetzt fett. Kino-
  Startseite: erster Button orange (AppFarben.fokusFarbe), "Einstel-
  lungen"/"Verlauf" in neuem AppFarben.appBarRotGedaempft (50%-Rot)
  statt Theme-Default-Rot.
- Run 335 ✅ Drei Korrekturen im Einstellungen-Admin-Bereich: (1)
  Dev-Modus-Schalter wiederhergestellt (seit Run 287 fehlte der UI-
  Schalter, DevModus.setzen() wurde nirgends mehr aufgerufen) — neuer
  SwitchListTile über dem Testwerte-Block. (2) Redundante orange
  "Gespeichert: ..."-Hinweise unter location_id/Flurbocash-API-Key
  entfernt. (3) Anthropic-API-Key-Feld zeigt den Wert jetzt im
  Klartext, kein Augen-Icon mehr.
- Run 336 ✅ "+"-Additions-Eingabe im `BetragCentEingabefeld`
  (Scheine/Münzen/Rollen/Umschläge/Kassenbons): Ziffernformatter
  erlaubt jetzt zusätzlich "+", jedes Segment wird während der
  Eingabe live formatiert (z. B. "260+20" → "2,60+0,20"); nach
  Fokusverlust wird zum Endbetrag zusammengefasst ("2,80"). Neuer
  "+"-Button im Feld ergänzt die Tastatur-Eingabe (Telefon-Tasten-
  feld statt Zifferblock, da dieses meist ein "+" zeigt) — garantiert
  nutzbar unabhängig vom Tastatur-Layout auf Android. Zentrale Summen-
  Logik (`TagesabschlussBerechnung.parseCentZiffern`) statt der bisher
  im Widget duplizierten Parse-Logik. `GanzzahlEingabefeld`
  (Stückzahl) bewusst unverändert, da der beschriebene Anwendungsfall
  nur Beträge betrifft.
- Run 336a ✅ Korrekturen aus Pacos erstem Gerätetest (iPhone Safari):
  "+"-Button jetzt auch im `GanzzahlEingabefeld` (Stückzahl, z.B.
  Scheine), da die iPhone-Zifferntastatur kein "+" zeigt. Cursor-Fix
  nach Tap auf "+"-Button (Text wurde sonst komplett markiert statt
  Cursor ans Ende zu setzen). Icon-Reihenfolge im Betragsfeld:
  €-Zeichen zuerst, dann "+", dann Löschen-X mit mehr Abstand.
- Run 336a2 ✅ Weitere Korrekturen nach Skizze aus Pacos zweitem
  Gerätetest: "+"/"X" jetzt als graue Button-Chips mit echten
  Trennlinien (neue Helfer in eingabefeld_clear_helper.dart, von
  beiden Eingabefeldern genutzt) statt bloßer Icons mit Abstand.
  Mehrere Felder verbreitert (Scheine-Anzahl, lose Münzen, Umschläge,
  Kassenbons, Ausgaben), damit dreistellige Werte nicht mehr
  abgeschnitten werden. BetragCentEingabefeld: textAlign right statt
  center (Betrag liegt jetzt direkt am €). Keyboard-Dismiss-Bug beim
  "+"-Tap auf bereits fokussiertem Feld adressiert (requestFocus() nur
  noch bei fehlendem Fokus) — Best-Effort, noch nicht auf Gerät
  verifiziert. Bewusst NICHT die volle feldhohe Zellen-Trennung aus
  der Skizze umgesetzt (hätte InputDecoration/labelText/
  fehlermeldungText umgehen müssen).
- Run 336a3 ✅ Erstmals per Playwright (Chromium headless) gegen
  lokalen Release-Build selbst visuell geprüft, inkl. Klick-Workflow
  bis Schritt 1. Dabei entdeckt: Die "+"/"X"-Chip-Tippfläche aus
  336a2 war kleiner als sichtbar — selbst gezielte Mausklicks
  brauchten mehrere Anläufe. baueEingabefeldAktionsChip() bekommt
  jetzt eine unsichtbar größere Tippfläche (HitTestBehavior.opaque +
  zusätzliches Padding), Suffix-Höhe in beiden Feldern 26→36 damit
  nichts abgeschnitten wird.
- Run 336a4 ✅ Paco-Feedback: die 36px-Suffix-Höhe aus 336a3 ließ
  Felder mit Wert (Buttons sichtbar) höher wirken als leere Felder —
  unerwünscht, Feldhöhe soll konstant bleiben. Feste SizedBox-Höhe
  komplett entfernt (Zeile sizt sich am größten Kind aus), Chip-
  Vertikal-Padding 6+4→0+2 (nur noch horizontales Tipp-Polster).
  Per Playwright verifiziert: befüllte/leere Zeilen jetzt gleich
  hoch.
- Run 337 ✅ Fünf kleine Paco-Feedback-Korrekturen gebündelt:
  AppBar "<Kino> Abrechnung"; Personalgetränke-Flag jetzt Teil von
  _speichereEntwurf()/_ladeEntwurf() (ging vorher bei Neuladen der
  Seite verloren); DevModus.istAktiv()-Default von `true` auf
  `false` korrigiert (Root-Cause dafür, dass "JSON anzeigen" auf
  vorkonfigurierten Geräten für alle MA sichtbar war);
  AppFarben.footerButtonStyle-Hintergrund weiß→orange (fokusFarbe);
  grünes Häkchen-Icon hinter "Abrechnung an Büro senden" sobald
  Autosave erledigt ist (neues Flag _abrechnungGesendet).
- Run 337a ✅ Korrektur: Sende-Haken aus Run 337 erschien auch bei
  fehlgeschlagenem API-Upload (fire-and-forget `.ignore()` setzte
  ihn unabhängig vom Ergebnis). Haken wird jetzt erst nach
  tatsächlichem Erfolg (oder CORS-Empfang-nicht-bestätigbar)
  asynchron gesetzt; Dialogöffnung bleibt weiterhin sofort ohne
  Wartezeit auf die Netzwerkantwort.
- Run 337a2 ✅ Zwei weitere Korrekturen: Haken stützt sich nicht mehr
  auf den CORS-Fallback (isCorsArtFehler kann echten CORS-Block
  nicht von komplettem Offline-Zustand unterscheiden — im Flugmodus-
  Test zeigte "Empfang nicht bestätigbar" fälschlich Erfolg), nur
  noch echter Upload-Erfolg zeigt den Haken. Zusätzlich Persistenz
  (LokalerSpeicher.speichereSendeBestaetigung/ladeSendeBestaetigung,
  Signatur der Eingabedaten ohne Zeitstempel): Haken übersteht jetzt
  Navigation weg von Schritt 3 und bleibt bestehen, solange sich die
  Abrechnungsdaten seither nicht geändert haben.
- Run 338 ✅ Offline-Start (Flugmodus) repariert: Der Fresh-Tab-Reset
  aus Run 295 (web/index.html) löschte bei jedem Kaltstart
  bedingungslos Cache + Service Worker vor dem erzwungenen Reload —
  danach existierte weder Cache noch SW mehr, wodurch der Reload
  zwingend am Netzwerk scheiterte. Fix: Reset läuft nur noch, wenn
  `navigator.onLine === true` ist. Offline bleibt der vorhandene
  Service-Worker-Cache erhalten, App startet daraus normal weiter.
  Online-Verhalten unverändert.
- Run 339 ✅ Vier kleine Paco-Feedback-Korrekturen gebündelt: Next-
  Buttons (Feld-Sprung) einheitlich weiß/rot; "Anzahl"/"Cent" in den
  Kacheltiteln zusätzlich mit orangenem Textmarker-Hintergrund;
  "Abrechnung an Büro senden" (Schritt 3) jetzt orange;
  "Stückelung (4/4)"-Button bleibt ausgegraut bis _abrechnungGesendet
  true ist, Tap zeigt sonst orange SnackBar; Stückelung-Seite:
  Abschluss-Button heißt nur noch "Fertig." (orange), führt direkt
  zur Startseite statt erneut den Sende-Dialog auszulösen.
- Run 340 ✅ Grüner Haken am "Kassenabrechnung (4 Schritte)"-Button auf
  der Kino-Startseite, wenn die Sende-Bestätigung aus Schritt 3 zum
  heutigen logischen Datum passt (kein neuer Persistenz-Key, nur die
  bestehende JSON-Signatur ausgelesen). Zusätzlich Hinweistext
  "Barumsatz und Belege in den Umschlag tun." über dem "Fertig."-
  Button auf der Stückelung-Seite.
- Run 341 ✅ Architektur-Run (erster Schritt einer Serie, analog zu
  Schritt 1 Run 40–58): tagesabschluss_schritt2_seite.dart (3934
  Zeilen) wird in Untermodule unter lib/pages/tagesabschluss_schritt2/
  aufgeteilt. Run 341 lagert die reinen UI-Bau-Methoden nach ui/
  schritt2_ui_builder.dart aus (9 Widgets) und verschiebt die bisher
  private Klasse _ZahlungsartZeile (umbenannt: ZahlungsartZeile) samt
  ZeilenZustand-Enum nach models/zahlungsart_zeile.dart. Reines
  Verschieben ohne Verhaltensänderung; Datei dadurch auf 3381 Zeilen
  reduziert. Weitere Runs (State/Controller, restlicher UI-Baum)
  folgen; Schritt 3 optional danach als kleinerer Einzel-Run.
- Run 341a ✅ Korrektur: Versionsbump zu Run 341 nachgeholt
  (0.9.15+341a), war im Run vergessen worden.
- Run 342 ✅ Beim Testen von Run 341 entdeckt (keine eigene
  Regression): "Differenz im Anfangsbestand" (Schritt 2) optisch an
  Kino-SOLL/Bistro-SOLL angeglichen (Label links, 190px-Feld statt
  148px mit abgeschnittenem Wert) und Fokus-Reihenfolge korrigiert
  (Feld steht jetzt an erster statt letzter Stelle in
  _fokusReihenfolgeSchritt2(), passend zu seiner visuellen Position
  — "Weiter" sprang vorher gar nicht mehr weiter). Live per
  Playwright gegen den Web-Build verifiziert.
- Run 342a ✅ Korrektur: 190px-Feld aus Run 342 wirkte laut Paco zu
  groß. "+"-Additions-Button (Summen wie "1,00+0,50" eintippen) für
  dieses eine Feld über neuen Parameter zeigeAdditionsButton
  ausgeblendet, Feldbreite auf 160px reduziert. Alle anderen
  Beträge-Felder (Kino-SOLL etc.) unverändert (Parameter-Default
  true). Live verifiziert.
- Run 343 ✅ Architektur-Refactor, Fortsetzung der Run-341-Serie:
  Fokus-Reihenfolge/-Navigation und Scroll-zu-Feld-/Scroll-Pfeil-
  Logik aus tagesabschluss_schritt2_seite.dart nach neuer Datei
  lib/pages/tagesabschluss_schritt2/controller/
  schritt2_fokus_helper.dart ausgelagert (Klasse Schritt2FokusHelper,
  const, State per Parameter injiziert — gleiches Muster wie
  schritt1_state_controller.dart). 11 Methoden betroffen, alle
  bleiben als dünne Wrapper in der Hauptdatei, Call-Sites im
  build()-Baum unverändert. Reines Verschieben ohne
  Verhaltensänderung. Zusätzlich gebündelt: Feldbreite "Differenz
  im Anfangsbestand" von 160px (Run 342a) auf 120px reduziert
  (Paco-Wunsch, mit diesem Commit statt eigenem Sub-Run). Nächster
  geplanter Teilschritt der Serie: build()-Baum selbst (~1200
  Zeilen) analog zu Schritt 1s sections/-Ordner zerlegen.
- Run 344 ✅ Zwei beim Testen von Run 343 entdeckte, vorbestehende
  Lücken behoben (keine Regression aus Run 343). (A) Kartenart-
  Betragsfelder (Girocard usw.) waren nie Teil der Fokus-/Weiter-
  Reihenfolge — Schritt2FokusHelper.fokusReihenfolge()/
  .erstesLeeresFeld() um zahlungsartZeilen erweitert (nur
  zustand==editing), _verknuepfeFeldNavigationSchritt2() an allen 4
  Erzeugungsstellen ergänzt. (B) Auf Paco-Wunsch: seitenweiter
  Down-Button wie in Schritt 1 übernommen (neue Datei
  schritt2_scroll_helper.dart), dafür den alten, nicht tippbaren
  Fade-Pfeil an der EC-Kachel (seit Run 274a) komplett entfernt.
- Runs 345–356 (Details siehe CHANGELOG.md): build()-Zerlegungs-Serie
  für tagesabschluss_schritt2_seite.dart abgeschlossen, danach analog
  für tagesabschluss_schritt3_seite.dart (Run 354) und begonnen für
  einstellungen_seite.dart (ab Run 355); diverse Getränkeliste-UX-
  Fixes (Run 356/356a/356a2).
- Run 357 ✅ Zwei TODO.md-Punkte geklärt, keine Code-Änderung nötig:
  "Kein Screen-Flip" (Android bestätigt unproblematisch, Zielplattform)
  und "Kartensumme ↔ EC-Gesamtbetrag nach manuellem Nachtrag"
  (bestehender Warnhinweis reagiert bereits live, EC-Gesamtbetrag
  bleibt bewusst unabhängig vom Scan eingelesen). Zusätzlich Button-
  Text "Neu laden" → "App neu laden" eingecheckt.
- Run 358 ✅ Sub-Run 2 der einstellungen_seite.dart-Zerlegungs-Serie
  (Fortsetzung Run 355): KI-Belegscan-Konfig-Band als eigenes
  StatelessWidget EinstellungenBelegscanSection ausgelagert, über
  EinstellungenGruppenOrchestrierung verdrahtet. Reines Verschieben,
  Datei von 1434 auf 1399 Zeilen geschrumpft. Verbleibend: Standort/
  Admin-Status, Wechselgeldbestand, Flurbocash-Anbindung, Dev-Modus/
  Testwerte.
- Run 359 ✅ Sub-Run 3 der einstellungen_seite.dart-Zerlegungs-Serie:
  Standort/Admin-Status-Band (Standort-Dropdown + "Admin-Status
  halten"-Switch) als eigenes StatelessWidget
  EinstellungenStandortAdminSection ausgelagert. Reines Verschieben,
  Datei von 1399 auf 1346 Zeilen geschrumpft. Verbleibend:
  Wechselgeldbestand, Flurbocash-Anbindung, Dev-Modus/Testwerte.
- Run 360 ✅ Sub-Run 4 der einstellungen_seite.dart-Zerlegungs-Serie:
  Wechselgeldbestand-Band (aufklappbare Zeile mit Betrags-Vorschau +
  Eingabefeld) als eigenes StatelessWidget
  EinstellungenWechselgeldSection ausgelagert. Reines Verschieben,
  Datei von 1346 auf 1280 Zeilen geschrumpft. Verbleibend:
  Flurbocash-Anbindung, Dev-Modus/Testwerte.
- Run 361 ✅ Sub-Run 5 der einstellungen_seite.dart-Zerlegungs-Serie:
  Flurbocash-Anbindung-Band (Switch + 3 Konfigfelder inkl.
  FocusNodes) als eigenes StatelessWidget
  EinstellungenFlurbocashSection ausgelagert. Reines Verschieben,
  Datei von 1280 auf 1225 Zeilen geschrumpft. Verbleibend: nur noch
  Dev-Modus/Testwerte (letzter, aufwendigster Sub-Run der Serie).
- Run 362 ✅ Sub-Run 6 (letzter) der einstellungen_seite.dart-
  Zerlegungs-Serie: Dev-Modus/Testwerte-Band (Switch, Aufklapp-
  Bereich, Standard-Testwerte-Button, _baueAutoFillInhalt()) als
  eigenes StatelessWidget EinstellungenDevModusSection ausgelagert.
  Reines Verschieben, Datei von 1225 auf 1168 Zeilen geschrumpft.
  Serie damit abgeschlossen — alle 5 Admin-Card-Bänder plus
  Getränkeliste-/PWA-Install-Card sind eigene Widgets unter
  lib/pages/einstellungen/sections/.
- Run 363 ✅ Sub-Run 1 (Grundgerüst) einer neuen Zerlegungs-Serie
  für wechselgeld_pruefen_seite.dart (1378 Zeilen). Zusammenfassungs-
  Karte (_baueZusammenfassung() + _ZusammenfassungsZeile) als
  eigenes Widget WechselgeldZusammenfassungSection ausgelagert
  (neuer Ordner lib/pages/wechselgeld_pruefen/sections/, direkt
  instanziiert ohne Orchestrierungs-Layer). Datei von 1378 auf
  1318 Zeilen geschrumpft. Verbleibend: _baueRollenGruppe()
  (~170 Zeilen, für Sub-Run 2).
- Run 364 ✅ Sub-Run 2 (letzter) der wechselgeld_pruefen_seite.dart-
  Zerlegungs-Serie: _baueRollenGruppe() (inkl. Hilfe-Dialog und
  "Aus Zählung von vorhin übernehmen"-Logik) als eigenes Widget
  WechselgeldRollenSection ausgelagert. Datei von 1318 auf 1167
  Zeilen geschrumpft. Serie damit abgeschlossen.
- Run 364a ✅ Kandidatensuche nach weiteren Zerlegungs-Zielen: keine
  der übrigen Seiten groß genug. tagesabschluss_schritt2_seite.dart
  (2619 Zeilen, build() bereits zerlegt) als eigener, größerer
  Architektur-Run in TODO.md dokumentiert und zurückgestellt. Keine
  App-Code-Änderung.
- Runs 365–378a2 (Details siehe CHANGELOG.md): u. a. Duplikat-Audit-
  Serie (Schritt-Auswahl-BottomSheet in Run 378 zusammengeführt),
  Dev-Modus-Bypass für Stückelung-Button (Run 378a), Absturzfix im
  Admin-PIN-Dialog (Run 378a2).
- Run 379 ✅ Standort-Wechsel in den Einstellungen leitet eine bereits
  offene Kino-Startseite (StartmenueSeite) jetzt automatisch auf den
  aktuell aktiven Standort um (_ladeDaten() prüft Standort-Modus
  gegen kino.id, pushReplacementNamed bei Abweichung), statt dass die
  alte Standort-Seite ohne Ausweg stehen blieb.
- Run 380 ✅ Duplikat-Audit-Serie: Body-Content-Wrapper Schritt1+2
  zusammengeführt. Neue lib/widgets/tagesabschluss_body_wrapper.dart
  (TagesabschlussBodyWrapper) kapselt die bisher 1:1 duplizierte
  äußere Hülle (Theme-Override, Scroll-Metrik-Listener, Down-Scroll-
  FAB) von schritt1_body_content.dart und schritt2_body_content.dart;
  der jeweils unterschiedliche scrollbare Inhalt (Slivers vs.
  ListView) bleibt getrennt. Öffentliche Konstruktoren unverändert.
- Run 381 ✅ Duplikat-Audit-Serie: JSON-Lade/Speicher-Helfer in
  lokaler_speicher.dart. Neue private generische Helfer _ladeJson()/
  _speichereJson() lösen das 4× 1:1 duplizierte Muster "Hive-Box:
  String holen → jsonDecode mit try/catch → Map/Liste oder null" ab
  (ladeGetraenkeMengen/speichereGetraenkeMengen, ladeGetraenkeliste/
  speichereGetraenkeliste, ladeSchritt2Entwurf/speichereSchritt2Entwurf,
  ladeWechselgeldZaehlEntwurf/speichereWechselgeldZaehlEntwurf).
  Bewusst nicht angefasst: die TagesabschlussFinal-Familie (eigene
  Filter-/Sortier-/Dedupe-Logik, keine reine Dopplung) und
  ladeAutoFillSchritt1/2 (SharedPreferences + Default-Werte-Fallback,
  anderes Muster). Persistenz-Keys/Boxen unverändert.
- Run 382 ✅ Duplikat-Audit-Serie: TagesabschlussScaffold konsequent
  genutzt. Vier Seiten (einstellungen_seite.dart, verlauf_seite.dart,
  verlauf_detail_seite.dart, uebertrag_umschlag_seite.dart) bauten
  Scaffold + Footer noch von Hand (Container mit
  AppFarben.footerDecoration + HausButton() als bottomNavigationBar,
  1:1 dupliziert bzw. als eigene _hausFooter()-Methode) statt das
  bestehende TagesabschlussScaffold-Widget zu nutzen. Jetzt
  umgestellt: eigene AppBars (Kinoname+Titel bzw. Datum+Kinoname+
  HeuteBadge) laufen über den appBar-Parameter, einfache String-Titel
  über den title-Parameter, der manuelle Footer-Container entfällt.
  Öffentliche Konstruktoren unverändert.
- Run 383 ✅ Duplikat-Audit-Serie: Stückelungs-Konfiguration
  zentralisiert (war 3x dupliziert). stueckelung_vorschlag_seite.dart
  nutzt jetzt StueckelungKonfiguration.scheine statt eigener privater
  _ScheinDef-Klasse; einstellungen_seite.dart bezieht id+bezeichnung
  für Scheine/Rollen/lose Münzen (Dev-Autofill-Panel) ebenfalls aus
  StueckelungKonfiguration statt eigener Record-Listen — nur die
  Dev-Test-Default-Werte bleiben als zwei kleine lokale Maps.
  Nebeneffekt: Rollen-Labels im Dev-Panel zeigen jetzt den vollen
  Rollenwert wie überall sonst in der App (z. B. "2 € (50,00 €)").
- Run 384 ✅ Duplikat-Audit-Serie: vier kleine lokale
  Widget-Extraktionen. wechselgeld_rollen_section.dart nutzt jetzt
  die zentrale CollapsibleCardSection statt eigener Card/InkWell-
  Header-Struktur (neuer optionaler `zusatzZeile`-Parameter dort für
  die Wechselgeld-spezifische Übernehmen/Löschen-Zeile).
  tagesabschluss_schritt3/sections/ bekam eine gemeinsame
  Schritt3InfoCard statt 4x identisch dupliziertem Card-Wrapper
  (Soll/Ist/Differenz/Differenz-Anfangsbestand). schritt1_ui_builder.
  dart: die Kupfer-Hinzufügen/Entfernen-Buttons aus
  Schritt1LoseMuenzenInhalt und Schritt1RollenInhalt in zwei private
  Widgets zusammengeführt. einstellungen_seite.dart:
  _baueStueckzahlZeile/_baueCentZeile auf gemeinsame
  _baueZahlenZeile() zurückgeführt. Alle öffentlichen Konstruktoren
  unverändert.
- Run 385 ✅ Fehlendes Auto-Save nachgezogen: drei Stellen ohne
  _speichereEntwurf()-Aufruf ergänzt (Codebasis-Analyse 2026-08-16).
  Schritt 1: _entferneKupferLose()/_entferneKupferRollen() speichern
  jetzt (await _speichereEntwurf(), Methoden dafür async). Schritt 2:
  onZeileBetragGeaendert (Kartenart-Einzelbetrag-Feld) speichert jetzt
  (Fire-and-forget, analog zu den benachbarten Zeilen-Callbacks).
  Vorher gingen dort eingegebene Werte bei App-Neustart verloren.
- Run 386 ✅ api_upload_service.dart: _terminalsListe() wirft jetzt
  eine Exception statt einen 0-EUR-Terminal-Eintrag hochzuladen,
  wenn EC-Umsatz > 0 aber zahlungsartenAufschluesselung leer ist
  (harter Fehler, läuft über den bestehenden Catch/SnackBar in
  Schritt 3). Bundle-Fix: reine Bargeldtage (kein EC-Umsatz) senden
  jetzt ein leeres terminals-Array statt eines Phantom-Eintrags mit
  leerer Terminal-ID. Neuer Unit-Test test/services/
  api_upload_service_test.dart deckt alle drei Fälle ab.
- Run 387 ✅ Verlauf zeigt "Noch nicht gesendet"-Badge für Einträge,
  deren Abrechnung noch nicht erfolgreich an Flurbocash übertragen
  wurde. Neues Feld `gesendetAm` (DateTime?) in TagesabschlussFinal;
  neue Methode LokalerSpeicher.markiereAlsGesendet(kinoId, createdAt,
  zeitpunkt) setzt es am gespeicherten Eintrag (Abgleich über
  createdAt, wegen Kinos mit mehreren Abrechnungen/Tag). Wird sowohl
  nach dem Senden in Schritt 3 als auch nach "Erneut senden" im
  Verlauf-Detail aufgerufen (inkl. CORS-Sonderfall). Neues Widget
  NichtGesendetBadge (nicht_gesendet_badge.dart). Alte Einträge vor
  diesem Run haben gesendetAm == null und gelten daher pauschal als
  "noch nicht gesendet" — rückwirkend nicht rekonstruierbar.
- Run 388 ✅ Geschäftstag-Cutoff: Abschluss zwischen 00:00 und
  05:59 Uhr zählt automatisch als Vortag (Spätvorstellungen enden
  teils nach Mitternacht). Neue Konstante
  _geschaeftstagCutoffStunde (6) in
  TagesabschlussFinalisierenUsecase.finalisieren(); betrifft nur
  `datum`, nicht `createdAt`. Damit auch das an Flurbocash
  übertragene JSON-Feld `date` korrekt.
- Run 388a ✅ Korrektur an Run 388: Cutoff-Regel war doppelt
  implementiert (bereits vorher in DatumsHelper.
  logischerAbrechnungsTag() vorhanden, an 12 Stellen genutzt).
  Jetzt einzige Quelle in DatumsHelper (neuer optionaler
  jetzt-Parameter fuer Testbarkeit), Usecase ruft sie nur noch
  auf. Neue Unit-Tests: datums_helper_test.dart,
  stueckelung_konfiguration_test.dart,
  speichere_tagesabschluss_usecase_test.dart (echte Hive-Box im
  Temp-Verzeichnis).
- Run 388c ✅ Weitere empfohlene Unit-Tests (Fortsetzung 388a;
  "388b" zwischenzeitlich von paralleler Session belegt, siehe
  CHANGELOG.md): wechselgeld_config_service_test.dart +
  getraenke_config_service_test.dart (parseInhalt-Parser),
  abrechnung_speicher_test.dart, startziel_bestimmen_usecase_test.dart
  (SharedPreferences.setMockInitialValues statt echtem I/O).
  AbrechnungSpeicher.abrechnungsDatumKey() bekommt optionalen
  jetzt-Parameter fuer Testbarkeit.
- Run 389 ✅ Neue Seite kurzeinstieg_seite.dart: Kurzerklärung des
  4-Schritte-Ablaufs (Bargeld zählen, Belege, Übertrag auf
  Umschlag, Stückelung Barumsatz), Texte wörtlich aus den
  bestehenden HelpButton-Texten der Schritt-Seiten übernommen.
  Auf der Kino-Home-Seite neuer Button "Hilfe" nach dem
  Verlauf-Button, öffnet die neue Seite.

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
