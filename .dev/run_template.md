# Run Template

Dieses Template ist die einzige Vorlage für neue Codex-Runs.
Der Run-Typ steuert die Zusatzregeln.

---

Codex Run <NUMMER>: <Kurzbeschreibung>

Run-Typ: <standard | architecture | documentation>

WICHTIG (Run-Nummer):
- Die Run-Nummer MUSS `next_run` aus `.dev/run_counter.txt` entsprechen.
- Wenn das nicht passt: STOPP und kurze Rückfrage.

Snapshot-Pflicht:
1. Skript ausführen:
   ./scripts/project_snapshot/project_snapshot.sh
2. Danach die erzeugte Datei vollständig lesen:
   .dev/project_snapshot.generated.txt
3. Snapshot-Frische prüfen:
   - Git Branch aus dem Snapshot prüfen
   - letzten Commit aus dem Snapshot prüfen
   - Git-Status aus dem Snapshot prüfen
4. Zusätzlich `.dev/run_counter.txt` lesen
5. Erst danach Änderungen planen

## Scope-Check (verbindlich)

1. Liste zuerst die Dateien auf, die voraussichtlich geändert werden müssen.
2. Prüfe, ob diese Dateien zum beschriebenen Zielbereich passen.
3. Wenn mehr als 5 Dateien betroffen wären oder Dateien außerhalb des Zielbereichs nötig erscheinen:
   STOPP und gib nur eine kurze Diagnose aus.
4. Erst danach mit der eigentlichen Umsetzung beginnen.

Kontext:
- Projekt: Kino-App (Tagesabschluss)
- Repository: `kino_bar_app`
- Branch: `master`
- Aktueller Stand in 3–6 Stichpunkten
- Betroffene Screens/Dateien/Ordner: <Liste>
- Was existiert bereits? <kurz>
- Was darf NICHT neu gedacht werden? <kurz>

Ziel:
- In 1–3 Sätzen: Was ist nachher konkret anders?

Akzeptanzkriterien:
1. <Kriterium 1>
2. <Kriterium 2>
3. <Kriterium 3>

Verbindliche fachliche Regeln:
1. <Regel 1>
2. <Regel 2>

Allgemeine technische Vorgaben:
- Interne Berechnung weiterhin in Cent.
- Keine neuen Packages, außer ausdrücklich gefordert.
- Keine Umbenennung von Dateien/Klassen ohne ausdrückliche Anweisung.
- Keine Änderung an Persistenz-Keys/JSON-Struktur ohne ausdrückliche Anweisung.
- Änderungen strikt auf den beschriebenen Zielbereich begrenzen.

Zusatzregeln je Run-Typ:

Wenn `Run-Typ: standard`
- Normale lokale Änderung im Zielbereich erlaubt.
- Kein Refactoring außerhalb des Zielbereichs.
- Keine UI-Umgestaltung außerhalb des Zielbereichs.

Wenn `Run-Typ: architecture`
- Keine UI-Änderungen außer nötiger Verkabelung.
- Keine Key-/JSON-Änderungen.
- Keine fachliche Logik neu erfinden; nur trennen, verschieben oder kapseln.
- Neue Dateien nur, wenn wirklich nötig und dann minimal.

Wenn `Run-Typ: documentation`
- KEINE Logikänderungen.
- KEINE UI-Änderungen.
- KEINE Refactorings.
- KEINE neuen Funktionen.
- Sprache in Kommentaren: Deutsch, kurz, sachlich.

Kommentierpflicht (außer reiner Doku-Run, wenn unnötig):
- Neue oder fachlich relevante Klassen/Methoden kurz und sachlich auf Deutsch kommentieren.
- Keine Kommentare zu trivialem Flutter-Standardcode.

Nicht erlaubt:
- Keine Nebenbei-Änderungen an `pubspec.*`, Pods, Build- oder Plattform-Konfiguration.
- Keine Änderungen außerhalb des beschriebenen Zielbereichs.
- Keine stillen Architekturwechsel.

Erwartetes Ergebnis:
- Kurz beschreiben, wie es nachher aussieht.
- Liste der voraussichtlich angepassten Dateien.

Abschluss (deine Antwort):
- Liste der tatsächlich geänderten Dateien.
- 3 klare Testschritte.
- Erwartetes Verhalten je Testschritt.
- `flutter analyze` muss sauber sein.
- `flutter test` muss grün sein (falls Tests vorhanden).

GIT (verbindlich – von dir auszuführen):
- Führe die Git-Befehle selbst aus.
- Commit-Message exakt: `Run <NUMMER>: <Kurzbeschreibung>`
- Sicherheitsregel: Wenn `git status` nicht sauber oder nicht erwartbar ist, STOPP und nur Diagnose + sichere Schritte.

Reihenfolge:
1. `git status`
2. `git add <nur betroffene Dateien>`
3. `git commit -m "Run <NUMMER>: <Kurzbeschreibung>"`
4. `git status`
5. `git push`

Nach erfolgreichem Commit zusätzlich:
1. Öffne `.dev/run_counter.txt`
2. Aktualisiere:
   - `last_run`
   - `next_run`
   - `last_run_title`
   - `last_commit`
3. Ergänze `CHANGELOG.md` unter `Unreleased` oder in einem neuen Abschnitt
4. Committe diese Meta-Änderungen separat:
   - `git add .dev/run_counter.txt CHANGELOG.md`
   - `git commit -m "Update run metadata after Run <NUMMER>"`
   - `git push`
