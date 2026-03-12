# Codex Run Template

Dieses Template ist die einzige Vorlage für neue Codex-Runs.  
Der Run-Typ steuert zusätzliche Regeln.

---

# Run-Kopf

Codex Run <NUMMER>: <Kurzbeschreibung>

Run-Typ: <standard | architecture | documentation>

---

# Run-Nummer prüfen

Die Run-Nummer MUSS `next_run` aus `.dev/run_counter.txt` entsprechen.

Wenn das nicht passt:

STOPP und kurze Rückfrage.

---

# Snapshot-Pflicht

Erst wenn die Run-Nummer korrekt ist, darf ein Snapshot erzeugt werden.

Vor jeder Analyse muss ein aktueller Projektsnapshot erzeugt werden.

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

---

# Scope-Check (verbindlich)

Wenn Kontext, Ziel oder betroffene Dateien unklar sind:
STOPP und kurze Rückfrage statt Codeänderungen.

1. Liste zuerst die Dateien auf, die voraussichtlich geändert werden müssen.
2. Prüfe, ob diese Dateien zum beschriebenen Zielbereich passen.
3. Wenn mehr als 5 Dateien betroffen wären oder Dateien außerhalb des Zielbereichs nötig erscheinen:

STOPP und gib nur eine kurze Diagnose aus.

4. Erst danach mit der eigentlichen Umsetzung beginnen.

---

# Kontext

- Projekt: Kino-App (Tagesabschluss)
- Repository: `kino_bar_app`
- Branch: `master`

Beschreibe kurz:

- aktuellen Stand (3–6 Stichpunkte)
- betroffene Screens / Dateien / Ordner
- was bereits existiert
- was **nicht neu gedacht werden darf**

---

# Ziel

Beschreibe in **1–3 Sätzen**, was nach dem Run konkret anders sein soll.

---

# Optional: Diagnose-Modus

Wenn die Ursache des Problems unklar ist:

führe zuerst einen Diagnose-Run durch  
und ändere keinen Code.

---

# Zielbereich (optional)

Grenze den Run möglichst klar ein.

Beispiele:

**Betroffene Oberfläche / Seite**

**Voraussichtlich relevante Dateien**

- lib/pages/tagesabschluss_schritt1_seite.dart
- lib/widgets/ganzzahl_eingabefeld.dart
- lib/widgets/betrag_cent_eingabefeld.dart

**Nicht ändern**

- Persistenz
- Geldberechnung
- Down-FAB-Logik
- andere Screens

---

# Akzeptanzkriterien

1. <Kriterium 1>
2. <Kriterium 2>
3. <Kriterium 3>

---

# Verbindliche fachliche Regeln

1. <Regel 1>
2. <Regel 2>

---

# Allgemeine technische Vorgaben

- Interne Berechnung weiterhin in Cent.
- Keine neuen Packages, außer ausdrücklich gefordert.
- Keine Umbenennung von Dateien/Klassen ohne ausdrückliche Anweisung.
- Keine Änderung an Persistenz-Keys oder JSON-Struktur ohne ausdrückliche Anweisung.
- Änderungen strikt auf den beschriebenen Zielbereich begrenzen.

---

# Zusatzregeln je Run-Typ

## Run-Typ: standard

- Normale lokale Änderung im Zielbereich erlaubt.
- Kein Refactoring außerhalb des Zielbereichs.
- Keine UI-Umgestaltung außerhalb des Zielbereichs.

---

## Run-Typ: architecture

- Keine UI-Änderungen außer nötiger Verkabelung.
- Keine Key- oder JSON-Änderungen.
- Keine fachliche Logik neu erfinden.
- Nur trennen, verschieben oder kapseln.
- Neue Dateien nur wenn wirklich nötig.

---

## Run-Typ: documentation

- KEINE Logikänderungen
- KEINE UI-Änderungen
- KEINE Refactorings
- KEINE neuen Funktionen

Sprache der Kommentare:

Deutsch, kurz, sachlich.

---

# Kommentierpflicht

(gilt nicht für reine Dokumentations-Runs)

Neue oder fachlich relevante Klassen / Methoden:

- kurz
- sachlich
- auf Deutsch kommentieren

Keine Kommentare zu trivialem Flutter-Standardcode.

---

# Nicht erlaubt

- keine Nebenbei-Änderungen an `pubspec.*`
- keine Änderungen an Pods / Build / Plattform-Konfiguration
- keine Änderungen außerhalb des Zielbereichs
- keine stillen Architekturwechsel

---

# Erwartetes Ergebnis

Kurz beschreiben:

- wie das Ergebnis nach dem Run aussieht
- welche Dateien voraussichtlich angepasst werden

---

# Abschlussbericht
Beginne den Abschlussbericht mit:
Codex-Bericht Run <NUMMER>

Die Antwort muss enthalten:

- Liste der tatsächlich geänderten Dateien
- 3 klare Testschritte
- erwartetes Verhalten je Testschritt

Außerdem:

- `flutter analyze` muss sauber sein
- `flutter test` muss grün sein (falls Tests vorhanden)

---

# Git-Ausführung (verbindlich)

Codex führt die Git-Befehle selbst aus.

Commit-Message exakt:

Run <NUMMER>: <Kurzbeschreibung>

Sicherheitsregel:

Wenn `git status` nicht sauber oder unerwartet ist:

STOPP  
nur Diagnose + sichere nächste Schritte.

---

# Git-Reihenfolge

1. git status  
2. git add <nur betroffene Dateien>  
3. git commit -m "Run <NUMMER>: <Kurzbeschreibung>"  
4. git status  
5. git push  

---

# Run-Metadaten aktualisieren

Nach erfolgreichem Abschluss eines Runs müssen die Metadaten aktualisiert werden.

Zu aktualisieren sind:

- `.dev/run_counter.txt`
- `CHANGELOG.md`

In `.dev/run_counter.txt` müssen folgende Felder angepasst werden:

- `last_run`
- `next_run`
- `last_run_title`
- `last_commit`

Regeln:

- `last_run` wird auf die aktuelle Run-Nummer gesetzt.
- `next_run` wird auf die nächste Run-Nummer erhöht.
- `last_run_title` enthält die Run-Nummer **und eine kurze Beschreibung**, z. B.:

  `Run 68: Diagnose des Keyboard-/Footer-Wuselns in Schritt 1`

- `last_commit` enthält den Commit-Hash des letzten Code-Commits dieses Runs.

Diagnose-Runs ohne Codeänderung:

Auch Diagnose-Runs ohne Codeänderung oder ohne Commit zählen als abgeschlossener Run,
wenn sie einen verwertbaren Abschlussbericht mit klarer Ursache oder klarer Folgeempfehlung liefern.

In diesem Fall gilt ebenfalls:

- `last_run` erhöhen
- `next_run` erhöhen
- `last_run_title` setzen
- `CHANGELOG.md` ergänzen

Wenn **kein neuer Git-Commit entstanden ist**:

- `last_commit` unverändert lassen
- im Abschlussbericht ausdrücklich angeben, dass kein Commit erfolgt ist