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
- Stabilität vor Tempo.

## Standard-Lock
Ohne einen expliziten Run-Prompt darf der Agent NICHT:

- Code ändern
- Dateien erstellen, verschieben oder umbenennen
- Klassen, Widgets oder Ordner umbenennen
- Packages hinzufügen oder `pubspec.*` ändern
- Build-, Plattform- oder Tooling-Konfiguration ändern
- Persistenz-Keys, JSON-Strukturen oder Storage-Verträge ändern
- UI außerhalb des Zielbereichs verändern

Erlaubt ohne Run-Prompt:

- Code lesen und verstehen
- Verständnisfragen beantworten
- Risiken oder Unklarheiten benennen
- einen nächsten Mini-Run vorschlagen
- Lesende Shell-Befehle ausführen (cat, sed -n, grep, ls, find, git log, git diff)

## Run-Ablauf

1. Agent schlägt einen Run vor (Chattext, kein Code)
2. Paco gibt frei mit: go
3. Agent führt den Run aus
4. Agent berichtet
5. Run gilt erst als abgeschlossen, wenn Paco lokal getestet hat und Testergebnis im Chat dokumentiert ist

## Snapshot-Regel

Zu Beginn einer neuen Session genügt:
1. `.dev/run_counter.txt` lesen — einzige gültige Quelle für die Run-Nummer
2. `git status` prüfen

Das vollständige Snapshot-Skript muss nicht ausgeführt werden.
Paco kann die Run-Nummer auch direkt im Prompt nennen — das hat Vorrang.

## Run-Nummer-Regel

Vor der Planung eines neuen Runs:
1. `.dev/run_counter.txt` lesen
2. die dort enthaltene Run-Nummer als letzte abgeschlossene Run-Nummer behandeln
3. die nächste Run-Nummer daraus ableiten

Die Run-Nummer aus Chat-Kontexten darf nicht als primäre Quelle verwendet werden.
`.dev/run_counter.txt` ist die einzige gültige Quelle — außer Paco nennt die Nummer direkt.

## Direkte Anweisungen ohne Run-Nummer

Wenn eine Anweisung ohne explizite Run-Nummer gegeben wird, gilt:

- Änderung als `[letzte Run-Nr]a`, `[letzte Run-Nr]b` usw. bezeichnen
- Weitere Sub-Runs auf einem bereits durch Buchstaben benannten Run
  (z. B. `274f`) werden NICHT mit einem weiteren Buchstaben (`274fb`, `274fc`),
  sondern mit einer Zahl fortgesetzt: `274f2`, `274f3`, `274f4` usw.
  Buchstaben nur für die erste Ebene direkt auf der Run-Nummer.
- Commit mit passender Message erstellen
- Direkt `git push origin master` ausführen
- `run_counter` NICHT erhöhen

## Technische Leitplanken

- Geldberechnung erfolgt intern in Cent — nicht ändern.
- Persistenz-Keys dürfen nicht verändert werden, außer der Run erlaubt es ausdrücklich.
- Keine neuen Dependencies ohne explizite Freigabe.
- Änderungen dürfen nur im im Run-Prompt definierten Zielbereich erfolgen.

## Git-Sicherheitsvertrag

Vor jedem Commit `git status` prüfen.

Bei einem dieser Zustände → STOPP, nur Diagnose ausgeben:

- nicht auf Branch `master`
- detached HEAD
- unerwartete fremde Änderungen
- unerwartete Deletes
- Merge- oder Rebase-Konflikte

Automatisch verbotene destruktive Befehle:

    git reset --hard
    git clean -fd
    git restore .

Commit-Format:

    git add <nur betroffene Dateien>
    git commit -m "Run <NUMMER>: <Kurzbeschreibung>"
    git push

## Bericht nach einem Run

Nach einem erfolgreichen Run muss der Agent berichten (ein einziger Codeblock,
Überschrift „Claude Code-Bericht Run <NUMMER>"):

- Tatsächlich geänderte Dateien (kurze Beschreibung der Änderung)
- Manuelle Testschritte mit erwartetem Verhalten
  - Genau so viele Tests wie es relevante Risiken gibt — einen pro Risiko, nicht mehr, nicht weniger
  - Keine Tests erfinden, die nichts verifizieren, das durch die Änderung hätte brechen können
- Status von `flutter analyze`
- Status von `flutter test` (falls Tests vorhanden)
- Letzter Commit-Hash + Run-Nummer

Ausnahme: Betrifft der Run ausschließlich Dateien unter `config/` und/oder `.dev/`
(keine App-Code-Änderung), reicht eine kurze Bestätigung statt des vollständigen Formats.

## Counter- und Changelog-Pflege

Nach einem erfolgreichen Run aktualisieren:

1. `.dev/run_counter.txt`
2. `CHANGELOG.md` — neuen Eintrag hinzufügen
3. `TODO.md` — erledigte Punkte abhaken (`[x]`), neue Punkte eintragen wenn besprochen
4. `PROJECT_CONTEXT.md` — Kopfzeile (Version + Run), Entwicklungsstand,
   bei strukturellen Änderungen betroffene Abschnitte aktualisieren
5. `AGENTS.md` — bei Änderungen an Workflow-Regeln synchron mit CLAUDE.md halten

Alle Dateien nur aktualisieren wenn der Run vollständig abgeschlossen ist.
Bei Abbruch: keine Änderungen.

## Run-Typen

- standard — normale UX-/Logik-Änderung im Zielbereich
- architecture — Strukturänderung ohne funktionales Redesign
- documentation — nur Kommentare / Dokumentation

## Versionierung

Am Ende jedes Runs die Versionsnummer in `pubspec.yaml` unter `version:` aktualisieren.
Die neue Nummer wird im Run-Prompt vorgegeben.

Zusätzlich denselben Versionswert und die Run-Nummer in BEIDEN folgenden Dateien
in den Versionsstring eintragen, sodass er lautet:
`'Web App X.X.X · rNNN @ GitHub:'`

- `lib/pages/startmenue_seite.dart`
- `lib/pages/kinoauswahl_seite.dart`

Bei Sub-Runs (z. B. 275a) den Buchstaben ebenfalls eintragen: `r275a`, nicht `r275`.
Beide Dateien bei jedem Commit (auch Sub-Runs und Korrekturen) aktualisieren.

## Antwortverhalten beim Laden dieser Datei

Antworte ausschließlich mit:

Bereit. Warte auf Run-Prompt.
