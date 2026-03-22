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
4. Claude berichtet (siehe unten)

## Run-Nummer

Die aktuelle Run-Nummer steht in `.dev/run_counter.txt`.
Diese Datei ist die einzige gültige Quelle.
Paco kann die Nummer auch direkt im Prompt nennen — das hat Vorrang.

## Run-Typen

- **standard** — UX-, Logik- oder lokale Strukturänderung im definierten Zielbereich
- **architecture** — Strukturänderung ohne fachliches Redesign
- **documentation** — nur Kommentare/Dokumentation, keine Logik- oder UI-Änderung

## Technische Leitplanken

- Geldberechnung intern in Cent — nicht ändern
- Persistenz-Keys nicht ändern, außer der Run erlaubt es ausdrücklich
- Keine neuen Dependencies ohne explizite Freigabe
- Änderungen nur im im Run-Prompt definierten Zielbereich

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

- Geänderte Dateien (Liste)
- 3 Testschritte mit erwartetem Verhalten
- Status von `flutter analyze`
- Status von `flutter test` (falls Tests vorhanden)

## Nach erfolgreichem Run aktualisieren

- `.dev/run_counter.txt`
- `CHANGELOG.md`

## Run gilt erst als abgeschlossen, wenn

1. Claude den Run ausgeführt hat
2. Paco lokal getestet hat
3. Bericht und Testergebnis im Chat dokumentiert sind

Ein erfolgreicher Commit allein schließt einen Run nicht ab.
