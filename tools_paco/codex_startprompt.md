# Codex Startprompt
Version: 10.03.26, 20:10
Projekt: kino_bar_app

## 1. Kontextdateien prüfen

Bevor du irgendetwas analysierst oder ausführst,
prüfe zuerst, ob folgende Dateien im Prompt enthalten sind:

- AGENTS.md
- CONTRIBUTING.md
- PROJECT_CONTEXT.md
- CHANGELOG.md
- .dev/run_counter.txt
- .dev/run_template.md

Falls eine oder mehrere dieser Dateien fehlen:

1. Stoppe sofort.
2. Liste die fehlenden Dateien auf.
3. Bitte den Entwickler, sie nachzureichen.

Rate nicht über fehlende Inhalte.

---

## 2. Projektkontext einlesen

Lies anschließend alle mitgegebenen Dateien sorgfältig,
um den aktuellen Projektzustand zu verstehen.

Bestätige danach kurz:

"Kontext gelesen. Bereit für Run-Prompt."

Führe **noch keine Codeänderungen,
keine Git-Aktionen und keinen Dev-Run** aus.

---

## 3. Warten auf Run-Prompt

Der eigentliche Run beginnt **erst**, wenn ein Prompt im Format erscheint:

Codex Run <Nummer>: <Titel>

Beispiel:

Codex Run 68: Diagnose Keyboard-Footer-Instabilität

Solange kein solcher Prompt erscheint:

- führe **keine Änderungen**
- **keine Git-Befehle**
- **keinen Snapshot**
- **keine Analyse des Codes**

aus.

---

## 4. Verhalten beim Run-Prompt

Sobald ein gültiger Run-Prompt erscheint:

1. Erzeuge zuerst einen aktuellen Projektsnapshot

scripts/project_snapshot/project_snapshot.sh

2. Lies anschließend die erzeugte Datei vollständig ein

.dev/project_snapshot.generated.txt

3. Analysiere danach den Code und führe den Run aus.

---

## 5. Ziel des Agent-Verhaltens

- klare, kleine Dev-Runs
- minimale Änderungen
- reproduzierbare Tests
- stabile Projektentwicklung