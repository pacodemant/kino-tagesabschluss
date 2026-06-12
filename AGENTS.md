# AGENTS.md

## Zweck
Diese Datei definiert den verbindlichen Arbeitsvertrag für KI-Coding-Agenten in diesem Repository.

Projekt:
- Kino-App (Tagesabschluss)
- Stack: Flutter / Dart
- Repository: kino_bar_app
- Hauptbranch: master

## Arbeitsmodus
- Änderungen erfolgen ausschließlich über kleine, kontrollierte Runs.
- Ein Run = genau ein klarer Fokus.
- Keine Nebenbei-Refactors.
- Keine Architekturänderungen ohne expliziten Architektur-Run.

## Standard-Lock
Ohne einen expliziten Run-Prompt darf Claude Code NICHT:

- Code ändern
- Dateien erstellen, verschieben oder umbenennen
- Klassen, Widgets oder Ordner umbenennen
- Packages hinzufügen oder `pubspec.*` ändern
- Build-, Plattform- oder Tooling-Konfiguration ändern
- Persistenz-Keys, JSON-Strukturen oder Storage-Verträge ändern
- UI außerhalb des Zielbereichs verändern

Erlaubt ohne Run-Prompt:

- Code lesen
- Verständnisfragen beantworten
- Risiken oder Unklarheiten benennen
- einen nächsten Mini-Run vorschlagen
- Lesende Shell-Befehle ausführen (cat, sed -n, grep, ls, find, git log, git diff)

## Snapshot-Regel

Zu Beginn einer neuen Session genügt:
1. `.dev/run_counter.txt` lesen
2. `git status` prüfen

Das vollständige Snapshot-Skript muss nicht ausgeführt werden.

## Run-Nummer-Regel

Vor der Planung eines neuen Runs muss der Agent zusätzlich:

1. `.dev/run_counter.txt` lesen
2. die dort enthaltene Run-Nummer als letzte abgeschlossene Run-Nummer behandeln
3. die nächste Run-Nummer daraus ableiten

Die Run-Nummer aus Chat-Kontexten darf nicht als Quelle verwendet werden.
Die Datei `.dev/run_counter.txt` ist die einzige gültige Quelle für die aktuelle Run-Nummer.

## Technische Leitplanken

- Geldberechnung erfolgt intern weiterhin in Cent.
- Persistenz-Keys dürfen nicht verändert werden, außer der Run erlaubt es ausdrücklich.
- Keine neuen Dependencies ohne explizite Freigabe.
- Änderungen dürfen nur im im Run-Prompt definierten Zielbereich erfolgen.

## Git-Sicherheitsvertrag

Wenn ein Agent committen oder pushen soll, muss er zuerst den
Repository-Status prüfen.

Wenn einer der folgenden Zustände auftritt:

- nicht auf Branch `master`
- detached HEAD
- unerwartete fremde Änderungen
- unerwartete Deletes
- Merge- oder Rebase-Konflikte

Dann gilt:

- STOPP
- keine Änderungen ausführen
- nur eine kurze Diagnose + sichere nächste Schritte ausgeben

Automatisch verbotene destruktive Befehle:

git reset --hard
git clean -fd
git restore .

## Run-Typen

- standard — normale UX-/Logik-Änderung im Zielbereich
- architecture — Strukturänderung ohne funktionales Redesign
- documentation — nur Kommentare / Dokumentation

## Bericht nach einem Run

Nach einem erfolgreichen Run muss der Agent berichten:

- tatsächlich geänderte Dateien
- 3 Testschritte
- erwartetes Verhalten
- Status von `flutter analyze`
- Status von `flutter test` (falls vorhanden)

## Counter- und Changelog-Pflege

Nach einem erfolgreichen Run sollen zusätzlich aktualisiert werden:

- `.dev/run_counter.txt`
- `CHANGELOG.md`
## Versionierung

Am Ende jedes Runs die Versionsnummer in `pubspec.yaml` unter `version:` aktualisieren.
Die neue Nummer wird im Run-Prompt vorgegeben. Keine eigene Entscheidung treffen —
nur den vorgegebenen Wert eintragen.

Zusätzlich denselben Versionswert in `lib/pages/startmenue_seite.dart` in den Text
'Web App @ GitHub:' eintragen, sodass er lautet:
'Web App 0.9.6 · r268 @ GitHub:'
Die Versionsnummer und Run-Nummer dabei immer durch die im Run-Prompt vorgegebenen Werte ersetzen. Format: 'Web App X.X.X · rNNN @ GitHub:'

## Antwortverhalten beim Laden dieser Datei

Antworte ausschließlich mit:

Bereit. Warte auf Run-Prompt.