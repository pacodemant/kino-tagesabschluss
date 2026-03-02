# Zusammenarbeit & Run-Regeln – Kino-App Projekt

## 1. Projektkontext
- Projekt: Kino-App (Tagesabschluss)
- Branch: master
- Kleine, kontrollierte Runs
- Keine Nebenbei-Refactors

---

## 2. Chat-Start-Regel
Neuer Chat beginnt immer mit dem Block aus `entwicklungsabschnitt_start.txt`.
Ohne diesen Block wird kein Run gestartet.

---

## 3. Run-Typen

### Standard-Run
Vorlage: `codex_run_standard.txt`
Für UX-/Logikänderungen im klar definierten Zielbereich.

### Architektur-Run
Vorlage: `codex_run_architektur_struktur.txt`
Für Struktur-/Schichtentrennung ohne UI-Redesign.

### Doku-Run
Vorlage: `codex_run_dokumentation.txt`
Nur Kommentare. Keine Logikänderungen.

---

## 4. Run-Disziplin
- Maximal ein klarer Mini-Fokus pro Run
- Testbar in unter 2 Minuten
- Keine Misch-Runs
- Run-Nummern fortlaufend

---

## 5. Git-Regeln (verbindlich)

Vor jedem Commit:
    git status

Wenn:
- detached HEAD
- Branch ≠ master
- fremde unstaged Änderungen
- unerwartete Deletes

→ STOP. Diagnose. Kein automatisches Clean.

Add-Regel:
    git add <nur betroffene Dateien>

Kein `git add .`
Kein `git add -A`
Außer ausdrücklich angewiesen.

Commit-Message:
    Run <NUMMER>: <Kurzbeschreibung>

Reihenfolge:
    git status
    git add <Dateien>
    git commit -m "Run <NUMMER>: <Kurzbeschreibung>"
    git status
    git push

---

## 6. Test-Regel
Nach jedem Run:
- 3 klare Testschritte
- Erwartetes Verhalten definiert
- Erst nach bestandenem Test → Commit

### Ergänzung zu §6 (Run-Bericht)
Jeder Run-Bericht enthält zusätzlich:
- **Empfohlene Test-Aktionen** (mind. 3)
- **Erwartetes Verhalten** pro Test-Aktion (kurz und prüfbar)

ChatGPT weist aktiv darauf hin, wenn ein neuer Codex-Chat empfohlen wird (z. B. bei Kontext-Drift oder Themenwechsel).
---

## 7. Prompt-Regel für Codex
- Prompts stehen immer in kopierbaren Codeblöcken
- Git-Anweisung ist im Prompt enthalten
- Keine verkürzten Anweisungen
- Keine impliziten Annahmen

---

## 8. Technische Leitplanken
- Interne Berechnung in Cent
- Keine neuen Packages ohne Freigabe
- Keine Key-/Persistenz-Änderungen ohne Freigabe
- Keine UI-Umgestaltung außerhalb des Zielbereichs
- Keine pubspec-/Pod-/Build-Änderungen nebenbei

---

## 9. Arbeitsphilosophie
- Kleine Schritte
- Klare Verantwortung
- Stabilität vor Geschwindigkeit
- Kein „Nebenbei“

---

## 10. Neuer Chat wenn:
- Git-Historie verwirrend wird
- Run-Nummern unsauber wirken
- Mehrere Themen vermischt wurden

---

## 11. Run-Erstellung (verbindlicher Ablauf)
1. ChatGPT erstellt zunächst nur einen Run-Vorschlag (ohne Codeblock).
2. User bestätigt mit "ok".
3. Erst danach wird ein einziger finaler Codex-Prompt als Copy-Block erzeugt.
4. Es darf nie mehr als ein aktiver Prompt mit derselben Run-Nummer existieren.
5. Wird ein Prompt angepasst, erhält er eine neue Run-Nummer.

---

## 12. Codex-Chat-Wechsel

Ein neuer Codex-Chat wird **nicht automatisch bei jedem Run** gestartet.

Ein neuer Chat ist empfohlen, wenn:

- ein klarer Kontextwechsel erfolgt (z. B. UI → Architektur, Schritt 1 → neues Feature)
- Git-Komplexität entstanden ist (Merge, Rebase, Reset, Detached HEAD, unerwartete Changes)
- mehrere Prompt-Varianten mit derselben Run-Nummer existieren
- Codex inkonsistent wirkt oder alte Annahmen weiterverwendet
- mehr als ca. 5–8 zusammenhängende Runs ohne Themenwechsel erfolgt sind

---

### Ablauf bei Chat-Wechsel

1. Letzten Run sauber committen und pushen.
2. Neuen Chat mit `entwicklungsabschnitt_start.txt` beginnen.
3. Run-Nummer fortlaufend weiterführen (nicht zurücksetzen).

---

ChatGPT weist aktiv darauf hin, wenn ein neuer Codex-Chat empfohlen wird.