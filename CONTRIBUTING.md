# CONTRIBUTING.md

## Zweck
Diese Datei ist das zentrale Regelwerk für die Zusammenarbeit im Kino-App-Projekt.
Sie beschreibt den Ablauf für Claude Code-Runs, Git-Disziplin und die Grenzen einzelner Änderungen.

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
3. Erst danach wird der finale Run-Prompt aus `run_template.md` erzeugt
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

### Commit bedeutet nicht Run-Abschluss
Ein erfolgreicher Commit oder Push beendet einen Dev-Run nicht automatisch.

Ein Run gilt erst als abgeschlossen, wenn:
1. Claude Code den Run ausgeführt hat
2. der Entwickler lokal getestet hat
3. der Claude Code-Bericht und die Testergebnisse im Chat dokumentiert wurden

Der Chat bestätigt damit den tatsächlichen Abschluss eines Runs.
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

1. Claude Code den Run vollständig ausgeführt hat (inkl. Code-Commit und Meta-Commit).
2. Der Entwickler das Ergebnis lokal getestet hat.
3. Der Claude Code-Bericht und die Testergebnisse im Chat dokumentiert wurden.

Wichtig:
Der Chat dient als Kontrollinstanz für den tatsächlichen Abschluss eines Runs.
Ein erfolgreicher Commit oder grüne Tests allein bedeuten noch nicht,
dass ein Run fachlich abgeschlossen ist.

## Chat-Wechsel
Ein neuer Claude Code-Chat ist empfohlen, wenn:
- ein klarer Themenwechsel erfolgt
- Git-Komplexität entstanden ist
- mehrere Prompt-Varianten mit gleicher Run-Nummer existieren
- alte Annahmen den aktuellen Stand verfälschen
- mehrere zusammenhängende Runs den Kontext unnötig aufblasen

## Start eines neuen Coding-Chats
Für einen neuen Coding-Chat genügen künftig:

- AGENTS.md
- .dev/run_template.md
- .dev/run_counter.txt
- ein kurzer Chat-Startblock mit aktuellem Kontext im Chat selbst

Es ist keine separate Start-Template-Datei mehr nötig.

### Snapshot-Regel

Zu Beginn eines neuen Coding-Chats genügt:
1. `.dev/run_counter.txt` lesen
2. `git status` prüfen

Das vollständige Snapshot-Skript muss nicht ausgeführt werden.