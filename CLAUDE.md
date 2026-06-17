# CLAUDE.md

## Run-Protokollierung

Die Run-Nummer wird vom Nutzer im Prompt-Header vorgegeben ("Run 287:").

Nach jedem erfolgreich abgeschlossenen Run (nach flutter analyze):

1. **CHANGELOG.md** — neuen Eintrag hinzufügen:
   - Run-Nummer, kurze Beschreibung, geänderte Dateien

2. **TODO.md** — abgehakte Punkte markieren (`[x]`),
   neue Punkte eintragen wenn im Run besprochen

3. **PROJECT_CONTEXT.md** — folgende Felder aktualisieren:
   - Versionsnummer und Run-Nummer in der Kopfzeile
   - Laufender Entwicklungsstand (erledigter Run als ✅, nächste Runs anpassen)
   - Bei strukturellen Änderungen (neue Seiten, Services, Routen, Modelle):
     die betroffenen Abschnitte aktualisieren

Alle drei Dateien werden nur aktualisiert wenn der Run vollständig
abgeschlossen ist. Bei Abbruch: keine Änderungen an diesen Dateien.

## Projekt

- Name: Kino-App (Tagesabschluss)
- Repository: kino_bar_app
- Stack: Flutter / Dart
- Branch: master
- Persistenz: SharedPreferences (kein Backend)
- Geldberechnung: intern in Cent

## Arbeitsmodus

Änderungen erfolgen ausschließlich über kleine, kontrollierte Runs.

- Ein Run = genau ein klarer Fokus
- Keine Nebenbei-Refactors
- Keine Architekturänderungen ohne expliziten Architektur-Run
- Stabilität vor Tempo

## Standard-Lock

Ohne expliziten Run-Prompt darf Claude NICHT:

- Code ändern
- Dateien erstellen, verschieben oder umbenennen
- Klassen, Widgets oder Ordner umbenennen
- Packages hinzufügen oder pubspec.* ändern
- Build-, Plattform- oder Tooling-Konfiguration ändern
- Persistenz-Keys, JSON-Strukturen oder Storage-Verträge ändern
- UI außerhalb des Zielbereichs verändern

Ohne Run-Prompt erlaubt:

- Code lesen und verstehen
- Verständnisfragen beantworten
- Risiken oder Unklarheiten benennen
- Nächsten Mini-Run vorschlagen
- Lesende Shell-Befehle ausführen (cat, sed -n, grep, ls, find, git log, git diff)

## Run-Ablauf

1. Claude schlägt einen Run vor (Chattext, kein Code)
2. Paco gibt frei mit: go
3. Claude führt den Run aus
4. Claude berichtet
5. Run gilt erst als abgeschlossen, wenn Paco lokal getestet hat und Testergebnis im Chat dokumentiert ist

## Snapshot-Regel

Zu Beginn einer neuen Session:
1. `.dev/run_counter.txt` lesen — einzige gültige Quelle für die Run-Nummer
2. `git status` prüfen

Das vollständige Snapshot-Skript wird nicht ausgeführt.
Paco kann die Run-Nummer auch direkt im Prompt nennen — das hat Vorrang.

## Technische Leitplanken

- Geldberechnung intern in Cent — nicht ändern
- Persistenz-Keys nicht ändern, außer der Run erlaubt es ausdrücklich
- Keine neuen Dependencies ohne explizite Freigabe
- Änderungen nur im Run-Prompt definierten Zielbereich

## Git-Sicherheitsvertrag

Vor jedem Commit: `git status` prüfen.

Bei einem dieser Zustände → STOPP, nur Diagnose ausgeben:

- Nicht auf Branch `master`
- Detached HEAD
- Unerwartete fremde Änderungen
- Unerwartete Deletes
- Merge- oder Rebase-Konflikte

Verbotene Befehle (nie ausführen):

    git reset --hard
    git clean -fd
    git restore .

Commit-Format:

    git add <nur betroffene Dateien>
    git commit -m "Run <NUMMER>: <Kurzbeschreibung>"
    git push

## Bericht nach jedem Run

Ausnahme: Betrifft der Run ausschließlich Dateien unter `config/` und/oder
`.dev/` (keine App-Code-Änderung), reicht eine kurze Bestätigung
(geänderte Dateien + Commit-Hash) statt des vollständigen Berichtsformats.
Spart Tokens, da hier kein Testbedarf am App-Verhalten besteht.

Format (sonst): ein einziger Codeblock, Überschrift „Claude Code-Bericht Run <NUMMER>"

Inhalt:
- Geänderte Dateien (kurze Beschreibung der Änderung)
- Manuelle Testschritte mit erwartetem Verhalten (kein flutter analyze als Testschritt)
  - Genau so viele Tests wie es relevante Risiken gibt — einen pro Risiko, nicht mehr, nicht weniger
  - Keine Tests erfinden, die nichts verifizieren, das durch die Änderung hätte brechen können
- Status von `flutter analyze`
- Status von `flutter test` (falls Tests vorhanden)
- Letzter Commit-Hash — daneben: Run-Nummer und ob sie vom User vorgegeben oder von Claude selbst abgeleitet wurde (z. B. „Run 203 – vom User vorgegeben" oder „Run 203 – aus run_counter.txt abgeleitet")
- Bestätigung: `.dev/run_counter.txt`, `CHANGELOG.md`, `TODO.md` und `PROJECT_CONTEXT.md` aktualisiert
  - CHANGELOG.md vor dem Schreiben per Read prüfen — nie behaupten, sie existiere nicht, ohne vorher nachgesehen zu haben
  - TODO.md nach jedem Run abgleichen: per Read prüfen, ob der Run einen dort
    gelisteten Punkt erledigt hat (insbesondere Punkte mit passender
    *(Run NNN)*-Markierung) — erledigten Punkt abhaken oder entfernen.
    Keine anderen TODO.md-Inhalte umformulieren oder verschieben.
  - PROJECT_CONTEXT.md: Kopfzeile (Version + Run), Entwicklungsstand und bei
    Bedarf betroffene Architekturabschnitte aktualisieren.
  - AGENTS.md: synchron mit CLAUDE.md halten wenn sich Workflow-Regeln ändern
    (nicht nach jedem Run — nur bei Regeländerungen).

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
- Auf nächstes Prompt warten
- **Bericht trotzdem ausgeben** — im gleichen Codeblock-Format wie § „Bericht nach jedem Run"

## Ausgabeformat

Diagnosen, Analysen und Berichte immer in einem einzigen Codeblock ausgeben — zum einfachen Kopieren per Klick.

## Sprache

Antworte immer auf Deutsch.
Auch alle Ausgaben, Kommentare und Thinking-Texte auf Deutsch.


## Session-Start
Führe zu Beginn jeder neuen Session aus:
    flutter clean
    flutter pub get

## Versionierung

Am Ende jedes Runs die Versionsnummer in `pubspec.yaml` unter `version:`
aktualisieren. Die neue Nummer wird im Run-Prompt vorgegeben.

Zusätzlich denselben Versionswert und die Run-Nummer in BEIDEN folgenden
Dateien in den Versionsstring eintragen, sodass er lautet:
'Web App X.X.X · rNNN @ GitHub:'

- `lib/pages/startmenue_seite.dart`
- `lib/pages/kinoauswahl_seite.dart`

Versionsnummer und Run-Nummer immer durch die im Run-Prompt
vorgegebenen Werte ersetzen. Bei jedem Commit (auch Sub-Runs und
Korrekturen) beide Dateien aktualisieren, damit der angezeigte
Versionsstring immer dem letzten Push entspricht.