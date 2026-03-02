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
- Mindestens 3 klare Test-Aktionen
- Erwartetes Verhalten pro Test definiert
- Erst nach bestandenem Test → Commit

---

## 7. Prompt-Regel für Codex
- Prompts stehen immer in EINER kopierbaren Code-Box
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
1. ChatGPT erstellt zunächst nur einen Run-Vorschlag (ohne finalen Copy-Prompt).
2. User bestätigt mit „ok“ (oder „go“).
3. Erst danach wird ein einziger finaler Codex-Prompt als Copy-Block erzeugt.
4. Es darf nie mehr als ein aktiver Prompt mit derselben Run-Nummer existieren.
5. Wird ein Prompt angepasst, erhält er eine neue Run-Nummer.

---

## 12. Codex-Chat-Wechsel
- ChatGPT weist aktiv darauf hin, wenn ein neuer Codex-Chat empfohlen wird.
- Empfohlen bei Themenwechsel (UI → Architektur), bei Kontext-Verwirrung, oder wenn der Codex-Chat sehr lang geworden ist.
- Spätestens vor einem Architektur-Run: neuer Codex-Chat.

---

## 13. Run-Report-Pflicht (verbindlich)
Jeder Run endet mit einem Run-Report, der mindestens enthält:
- Geänderte Dateien (nur die tatsächlich geänderten)
- Exakte Änderungen (Bulletpoints)
- `flutter analyze` Ergebnis
- Empfohlene Test-Aktionen + Ergebnis (Ist vs. Erwartung)
- Git-Sequenz + Commit-Hash