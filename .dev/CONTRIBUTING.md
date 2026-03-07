# CONTRIBUTING.md

## Zweck
Diese Datei ist das zentrale Regelwerk für die Zusammenarbeit im Kino-App-Projekt.
Sie beschreibt den Ablauf für ChatGPT/Codex-Runs, Git-Disziplin und die Grenzen einzelner Änderungen.

## Projekt
- Projekt: Kino-App (Tagesabschluss)
- Repository: `kino_bar_app`
- Branch: `master`
- Stack: Flutter / Dart

## Arbeitsprinzip
- Kleine, kontrollierte Runs
- Ein Run hat genau einen klaren Fokus
- Keine Misch-Runs
- Keine Nebenbei-Refactors
- Stabilität vor Tempo

## Run-Erstellung
Verbindlicher Ablauf:
1. Zuerst nur Run-Vorschlag in normalem Chattext
2. User gibt explizit frei (`go`)
3. Erst danach wird der finale Codex-Prompt aus `run_template.md` erzeugt
4. Pro Run-Nummer gibt es genau einen aktiven finalen Prompt
5. Wird ein Prompt wesentlich geändert, bekommt er eine neue Run-Nummer

## Run-Disziplin
Ein Run soll:
- klein genug sein, um schnell testbar zu bleiben
- nur einen fachlichen Schwerpunkt haben
- einen klar definierten Zielbereich nennen
- klare Akzeptanzkriterien enthalten

## Technische Leitplanken
- Interne Berechnung weiterhin in Cent
- Keine neuen Packages ohne ausdrückliche Freigabe
- Keine Änderungen an Persistenz-Keys / JSON-Struktur / Storage-Verträgen ohne Freigabe
- Keine UI-Umgestaltung außerhalb des Zielbereichs
- Keine Änderungen an `pubspec.*`, Pods, Plattform- oder Build-Konfiguration nebenbei

## Run-Typen
### standard
Normale UX-, Logik- oder lokale Strukturänderung im klar abgegrenzten Zielbereich.

### architecture
Struktur- oder Schichtentrennung ohne fachliche Neuerfindung und ohne UI-Redesign.

### documentation
Nur Kommentare oder Dokumentation. Keine Logikänderung, keine UI-Änderung, keine Refactorings.

## Git-Regeln
Wenn ein Run committen soll, gilt verbindlich:
1. `git status`
2. `git add <nur betroffene Dateien>`
3. `git commit -m "Run <NUMMER>: <Kurzbeschreibung>"`
4. `git status`
5. `git push`

### Sicherheitsregel
Wenn `git status` zeigt:
- nicht `master`
- detached HEAD
- unerwartete fremde Änderungen
- unerwartete Deletes
- Merge-/Rebase-Konflikte

Dann gilt:
- nichts automatisch bereinigen
- kein destruktiver Git-Befehl
- nur kurze Diagnose + sichere nächste Schritte

## Test-Regel nach jedem Run
Jeder Run-Bericht enthält:
- Liste der geänderten Dateien
- 3 klare Testschritte
- erwartetes Verhalten pro Testschritt
- Status von `flutter analyze`
- Status von `flutter test` (falls Tests vorhanden)

## Chat-Wechsel
Ein neuer Codex-Chat ist empfohlen, wenn:
- ein klarer Themenwechsel erfolgt
- Git-Komplexität entstanden ist
- mehrere Prompt-Varianten mit gleicher Run-Nummer existieren
- alte Annahmen den aktuellen Stand verfälschen
- mehrere zusammenhängende Runs den Kontext unnötig aufblasen

## Start eines neuen Coding-Chats
Für einen neuen Coding-Chat genügen künftig:
- `AGENTS.md`
- `.dev/run_template.md`
- `.dev/run_counter.txt`
- ein kurzer Chat-Startblock mit aktuellem Kontext im Chat selbst

Es ist keine separate Start-Template-Datei mehr nötig.
