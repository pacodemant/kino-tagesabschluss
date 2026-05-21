# CLAUDE.md

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

Format: ein einziger Codeblock, Überschrift „Claude Code-Bericht Run <NUMMER>"

Inhalt:
- Geänderte Dateien (kurze Beschreibung der Änderung)
- Manuelle Testschritte mit erwartetem Verhalten (kein flutter analyze als Testschritt)
  - Nur Tests vorschlagen, die tatsächlich etwas verifizieren, das durch die Änderung hätte brechen können
  - Keine Tests erfinden, nur um eine Mindestzahl zu erreichen
  - Wenn die Änderung mehr als 3 relevante Risiken hat, auch mehr als 3 Tests
- Status von `flutter analyze`
- Status von `flutter test` (falls Tests vorhanden)
- Letzter Commit-Hash
- Bestätigung: `.dev/run_counter.txt` und `CHANGELOG.md` aktualisiert

## Direkte Anweisungen ohne Run-Nummer

Wenn eine Anweisung ohne explizite Run-Nummer gegeben wird, gilt:

- Änderung als `[letzte Run-Nr]a`, `[letzte Run-Nr]b` usw. bezeichnen
- Commit mit passender Message erstellen
- Direkt `git push origin master` ausführen
- `run_counter` NICHT erhöhen
- Auf nächstes Prompt warten

## Ausgabeformat

Diagnosen, Analysen und Berichte immer in einem einzigen Codeblock ausgeben — zum einfachen Kopieren per Klick.

## Sprache

Antworte immer auf Deutsch.

## Session-Start
Führe zu Beginn jeder neuen Session aus:
    flutter clean
    flutter pub get