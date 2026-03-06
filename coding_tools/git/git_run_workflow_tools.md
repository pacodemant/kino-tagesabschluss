
# Git-Kurzreferenz für den Run‑Workflow (Kino‑App Projekt)

Diese Datei enthält Git‑Kommandos, die im Projekt häufig nützlich sind – besonders im Run‑Workflow mit Codex.

---

# 1. Änderungen anzeigen

## Alle Änderungen im Arbeitsverzeichnis
```bash
git diff
```

Zeigt den exakten Code‑Unterschied zwischen aktuellem Arbeitsstand und letztem Commit.

## Änderungen einer bestimmten Datei
```bash
git diff <dateipfad>
```

Beispiel:
```bash
git diff ai_prompt_templates/codex_run_standard.txt
```

Nutzen:
- prüfen, ob wirklich nur gewünschte Änderungen enthalten sind
- Kontrolle vor einem Commit

---

# 2. Commit‑Historie anzeigen

## Kompakte Übersicht
```bash
git log --oneline
```

Beispielausgabe:
```
a2b1077 Run 41: Header extrahiert
119bd44 Run 40: UI‑Sections ausgelagert
```

## Nur bestimmte Commits finden (z. B. Runs)
```bash
git log --oneline --grep "Run"
```

Sehr hilfreich, um schnell zu bestimmten Runs zu springen.

---

# 3. Commit anzeigen

## Vollständige Details eines Commits
```bash
git show <commit-id>
```

Beispiel:
```bash
git show a2b1077
```

Zeigt:
- Commit‑Text
- geänderte Dateien
- Diff

## Nur Dateiliste anzeigen
```bash
git show --name-only <commit-id>
```

---

# 4. Datei‑Historie anzeigen

## Nur Änderungen einer bestimmten Datei
```bash
git log --oneline <dateipfad>
```

Beispiel:
```bash
git log --oneline ai_prompt_templates/codex_run_standard.txt
```

Damit sieht man sofort:
- wann die Datei geändert wurde
- in welchem Run

---

# 5. Commit + Änderungen zusammen sehen

```bash
git log -p
```

Oder nur für eine Datei:

```bash
git log -p <dateipfad>
```

Beispiel:

```bash
git log -p ai_prompt_templates/codex_run_standard.txt
```

Nutzen:
- zeigt Commit‑Text UND Codeänderungen
- sehr hilfreich zur Analyse alter Runs

---

# 6. Zeilen‑Historie (git blame)

```bash
git blame <dateipfad>
```

Beispiel:
```bash
git blame lib/pages/tagesabschluss_schritt1_seite.dart
```

Zeigt:
- welcher Commit
- wann
- welche Zeile geändert hat

Sehr hilfreich beim Debuggen.

---

# 7. Commit‑Struktur visualisieren

```bash
git log --oneline --graph --decorate
```

Beispiel:
```
* a2b1077 (HEAD -> master) Run 41
* 119bd44 Run 40
* 83a19f0 Run 39
```

Nutzen:
- schnelle Übersicht über die Entwicklung

---

# 8. Änderungen einer Datei aus einem alten Commit wiederherstellen

```bash
git restore --source <commit-id> <dateipfad>
```

Beispiel:

```bash
git restore --source a2b1077 ai_prompt_templates/codex_run_standard.txt
```

Danach committen:

```bash
git add <dateipfad>
git commit -m "Restore previous version"
git push
```

---

# 9. Schnelle Suche im Git‑Log

```bash
git log --oneline
```

Navigation im Pager:

| Taste | Funktion |
|-----|-----|
| j | runter |
| k | hoch |
| / | Suche |
| q | verlassen |

Beispiel Suche:
```
/Run 41
```

---

# 10. Run‑Workflow Quick‑Check

Vor einem neuen Run:

```bash
git status -sb
```

Erwartete Ausgabe:

```
## master...origin/master
```

Dann ist das Repository sauber.

---

# Merksatz

Git braucht nicht die komplette Commit‑ID – nur so viele Zeichen, bis sie eindeutig ist.
Meist reichen **7 Zeichen**.

Beispiel:

```
a2b1077
```
