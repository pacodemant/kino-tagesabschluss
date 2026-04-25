# Claude Code Startprompt
Projekt: kino_bar_app

## 1. Kontext laden

Lies zuerst folgende Dateien:

- CLAUDE.md
- AGENTS.md
- CONTRIBUTING.md
- CHANGELOG.md
- .dev/run_counter.txt
- .dev/run_template.md

Falls eine dieser Dateien fehlt:
1. Stoppe sofort.
2. Liste die fehlenden Dateien auf.
3. Bitte den Entwickler, sie nachzureichen.

## 2. Snapshot

1. `.dev/run_counter.txt` lesen – das ist die einzige gültige Quelle für die Run-Nummer
2. `git status` prüfen

Bestätige danach kurz:
"Kontext geladen. Bereit für Run-Prompt."

## 3. Warten auf Run-Prompt

Führe keine Änderungen aus, bis ein Prompt im Format erscheint:

Codex Run <Nummer>: <Titel>

## 4. Sprache

Antworte immer auf Deutsch.
