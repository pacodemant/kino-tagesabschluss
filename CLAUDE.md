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

## Snapshot-Regel

Zu Beginn einer neuen Session genügt:
1. `.dev/run_counter.txt` lesen
2. `git status` prüfen

Das vollständige Snapshot-Skript muss nicht ausgeführt werden.
Die Run-Nummer aus `.dev/run_counter.txt` ist die einzige gültige Quelle.

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

- Geänderte Dateien (Liste mit kurzer Beschreibung der Änderung)
- 3 Testschritte mit erwartetem Verhalten
- Status von `flutter analyze`
- Status von `flutter test` (falls Tests vorhanden)
- Letzter Commit-Hash dieses Runs
- Bestätigung, dass `.dev/run_counter.txt` und `CHANGELOG.md` aktualisiert wurden

## Bericht-Formatierung

- Die Überschrift des Abschlussberichts lautet immer:
  „Claude Code-Bericht Run <NUMMER>"
- Der gesamte Abschlussbericht wird immer in einem einzigen Codeblock ausgegeben,
  damit er einfach in die Zwischenablage kopiert werden kann.

## Nach erfolgreichem Run aktualisieren

- `.dev/run_counter.txt`
- `CHANGELOG.md`

## Run gilt erst als abgeschlossen, wenn

1. Claude den Run ausgeführt hat
2. Paco lokal getestet hat
3. Bericht und Testergebnis im Chat dokumentiert sind

Ein erfolgreicher Commit allein schließt einen Run nicht ab.

## Sprache
Antworte immer auf Deutsch.

## Automatischer Chat-Start

Claude Code liest diese Datei automatisch beim Start eines neuen Chats.
Folgende Schritte sind dann verbindlich auszuführen, bevor auf einen
Run-Prompt gewartet wird:

### Schritt 1: Kontextdateien laden

Lies folgende Dateien vollständig:

- CLAUDE.md (bereits geladen)
- AGENTS.md
- CONTRIBUTING.md
- CHANGELOG.md
- .dev/run_counter.txt
- .dev/run_template.md

Falls eine dieser Dateien fehlt:
1. Sofort stoppen.
2. Fehlende Dateien auflisten.
3. Entwickler bitten, sie nachzureichen.

### Schritt 2: Snapshot

1. `.dev/run_counter.txt` lesen – einzige gültige Quelle für die Run-Nummer
2. `git status` prüfen

### Schritt 3: Bereitschaft bestätigen

Nach dem Laden kurz bestätigen:
"Kontext geladen. Bereit für Run-Prompt."

### Schritt 4: Warten

Keine Codeänderungen, keine Git-Befehle, keine Analyse –
bis ein Prompt im Format erscheint:

Claude Code Run <Nummer>: <Titel>

### Sprache

Antworte immer auf Deutsch.