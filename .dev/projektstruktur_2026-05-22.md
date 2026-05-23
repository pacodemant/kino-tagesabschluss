# Projektstruktur – Kino-App (Tagesabschluss)

Stand: 2026-05-22

---

## Einstiegspunkt

| Datei | Zweck |
|-------|-------|
| `lib/main.dart` | App-Start. Initialisiert SharedPreferences und entscheidet, welche Seite zuerst gezeigt wird (Kinoauswahl oder Startmenü). |

---

## Seiten (`lib/pages/`)

Jede Datei = eine Bildschirmseite der App.

| Datei | Zweck |
|-------|-------|
| `kinoauswahl_seite.dart` | Kino auswählen (SB, GO, AT, CO, BT …) |
| `startpruefung_seite.dart` | Prüft beim App-Start, ob ein Kino gesetzt ist |
| `startmenue_seite.dart` | Hauptmenü nach der Kinoauswahl |
| `einstellungen_seite.dart` | Einstellungen (z. B. Kino wechseln) |
| `tagesabschluss_schritt1_seite.dart` | Schritt 1 – Kassenzählung (Einstieg) |
| `tagesabschluss_schritt2_seite.dart` | Schritt 2 – Soll/Ist-Vergleich |
| `tagesabschluss_schritt3_seite.dart` | Schritt 3 – Abschluss & Speichern |
| `wechselgeld_zaehlen_seite.dart` | Wechselgeld zählen |
| `stueckelung_vorschlag_seite.dart` | Vorschlag, wie Wechselgeld aufgeteilt wird |
| `getraenke_auffuellen_seite.dart` | Getränke nachfüllen |
| `verlauf_seite.dart` | Liste aller gespeicherten Abschlüsse |
| `verlauf_detail_seite.dart` | Detailansicht eines einzelnen Abschlusses |
| `platzhalter_seite.dart` | Leere Platzhalterseite |

### Schritt-1-Unterordner (`lib/pages/tagesabschluss_schritt1/`)

Schritt 1 ist komplex und daher in Teilbereiche aufgeteilt:

| Ordner | Zweck |
|--------|-------|
| `controller/` | Zustand der Eingaben (was wurde eingegeben) |
| `orchestrierung/` | Logik, die die Abschnitte koordiniert |
| `scroll/` | Scroll-Verhalten beim Tippen |
| `setup/` | Initialisierung beim Seitenaufruf |
| `sections/` | Die einzelnen UI-Blöcke: Scheine, Münzen-lose, Münzen-Rollen, Umschläge, Übersicht, Hinweise, Header |
| `ui/` | Zusammenbau der Sections zur fertigen Seite |

---

## Modelle (`lib/models/`)

Reine Datenbehälter ohne Logik.

| Datei | Zweck |
|-------|-------|
| `kino.dart` | Was ist ein Kino (Name, Kürzel)? |
| `kassenzeile.dart` | Eine Zeile in der Kassenzählung (Stückelung + Anzahl) |
| `tagesabschluss_final.dart` | Fertig gespeicherter Tagesabschluss |

---

## Domain / Use Cases (`lib/domain/`)

Geschäftslogik – hier passiert die eigentliche Arbeit.

| Datei | Zweck |
|-------|-------|
| `tagesabschluss_berechnung.dart` | Rechnet Soll, Ist, Differenz (intern in Cent) |
| `tagesabschluss_finalisieren_usecase.dart` | Wandelt Entwurf in finalen Abschluss um |
| `usecases/kino_waehlen_usecase.dart` | Kino setzen/lesen |
| `usecases/speichere_tagesabschluss_usecase.dart` | Fertigen Abschluss dauerhaft speichern |
| `usecases/startziel_bestimmen_usecase.dart` | Welche Seite soll beim Start angezeigt werden? |
| `usecases/stueckelung_konfiguration.dart` | Welche Münz-/Schein-Stückelungen gibt es? |

---

## Services (`lib/services/`)

Brücke zwischen App-Logik und externen Quellen.

| Datei | Zweck |
|-------|-------|
| `abrechnung_speicher.dart` | Liest/schreibt fertige Abrechnungen in SharedPreferences |
| `wechselgeld_config_service.dart` | Konfiguration für Wechselgeldbestand pro Kino |
| `getraenke_config_service.dart` | Konfiguration für Getränkebestand |
| `dev_modus.dart` | Flag: läuft die App im Entwicklermodus? |

---

## Storage (`lib/storage/`)

Direkte Schnittstelle zu SharedPreferences.

| Datei | Zweck |
|-------|-------|
| `lokaler_speicher.dart` | Einziger Zugangspunkt für alle Lese-/Schreiboperationen |

---

## Widgets (`lib/widgets/`)

Wiederverwendbare UI-Bausteine.

| Datei | Zweck |
|-------|-------|
| `betrag_cent_eingabefeld.dart` | Eingabefeld für Geldbeträge (arbeitet intern in Cent) |
| `ganzzahl_eingabefeld.dart` | Eingabefeld für ganze Zahlen (Anzahl Münzen etc.) |
| `haus_button.dart` | Der Haus-Button im Footer (→ Startmenü) |
| `tagesabschluss_header.dart` | Kopfzeile auf Tagesabschluss-Seiten |
| `tagesabschluss_scaffold.dart` | Basis-Scaffold mit Standardlayout (Header + Footer) |

---

## Theme & Utils

| Datei | Zweck |
|-------|-------|
| `lib/theme/app_farben.dart` | Alle App-Farben zentral definiert |
| `lib/utils/datums_helper.dart` | Datum-Hilfsfunktionen (z. B. Stichtag 6-Uhr-Grenze) |

---

## Projekt-Infrastruktur

| Datei/Ordner | Zweck |
|--------------|-------|
| `.dev/run_counter.txt` | Aktuelle Run-Nummer (maßgeblich für Versionierung) |
| `.dev/run_template.md` | Vorlage für neue Run-Prompts |
| `.github/workflows/` | CI/CD (GitHub Actions) |
| `pubspec.yaml` | Flutter-Dependencies |
| `CHANGELOG.md` | Änderungsprotokoll je Run |
| `CLAUDE.md` | Arbeitsregeln für Claude Code |

---

## Architekturprinzip

```
Seiten        → zeigen UI
Modelle       → beschreiben Daten
Domain/UseC.  → führen Berechnungen und Geschäftslogik aus
Services      → Brücke zu Konfiguration und externen Quellen
Storage       → liest/schreibt SharedPreferences
Widgets       → wiederverwendbare UI-Bausteine
```

Kein Backend – alles wird lokal auf dem Gerät in SharedPreferences gespeichert.
Geldbeträge werden **intern immer in Cent** gerechnet.
