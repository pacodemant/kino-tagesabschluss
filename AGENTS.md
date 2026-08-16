# AGENTS.md

## Zweck
Diese Datei ist die einzige Quelle für den verbindlichen Arbeitsvertrag
für KI-Coding-Agenten in diesem Repository. CLAUDE.md verweist hierher
und enthält nur noch Claude-Code-spezifische Ergänzungen (Sprache,
Ausgabeformat, Session-Start) — Workflow-Regeln werden nur noch hier
gepflegt, nicht mehr dupliziert.

Projekt:
- Kino-App (Tagesabschluss)
- Stack: Flutter / Dart
- Repository: kino_bar_app
- Hauptbranch: master
- Persistenz: SharedPreferences (kein Backend)
- Geldberechnung: intern in Cent

## Arbeitsmodus
- Änderungen erfolgen ausschließlich über kleine, kontrollierte Runs.
- Ein Run = genau ein klarer Fokus.
- Keine Nebenbei-Refactors.
- Keine Architekturänderungen ohne expliziten Architektur-Run.
- Stabilität vor Tempo.

## Lösungsansatz-Check

Vor jedem Run-Vorschlag prüfen:
- Löst der beschriebene Ansatz das eigentliche Ziel —
  oder nur das beschriebene Symptom?
- Gibt es einen einfacheren Weg zum selben Ergebnis?
- Ist der Ansatz angemessen für den tatsächlichen Use-Case
  (Nutzerkreis, Häufigkeit, Kontext)?

Bei Zweifeln: die einfachere Alternative zuerst nennen,
bevor der ursprünglich beschriebene Weg umgesetzt wird.

## Verifikationspflicht

Aussagen über Code- oder Framework-Verhalten (Styling-Defaults,
Einführungszeitpunkte, Funktionsweise) nie aus dem Gedächtnis
behaupten. Vor der Aussage im tatsächlichen Code, Git-Log
(`git log -S`, `git blame`) oder offizieller Doku verifizieren.
Ist eine Verifikation nicht möglich: explizit als Vermutung
kennzeichnen, nicht als Fakt formulieren.

## Standard-Lock
Ohne einen expliziten Run-Prompt darf der Agent NICHT:

- Code ändern
- Dateien erstellen, verschieben oder umbenennen
- Klassen, Widgets oder Ordner umbenennen
- Packages hinzufügen oder `pubspec.*` ändern
- Build-, Plattform- oder Tooling-Konfiguration ändern
- Persistenz-Keys, JSON-Strukturen oder Storage-Verträge ändern
- UI außerhalb des Zielbereichs verändern

Erlaubt ohne Run-Prompt:

- Code lesen und verstehen
- Verständnisfragen beantworten
- Risiken oder Unklarheiten benennen
- einen nächsten Mini-Run vorschlagen
- Lesende Shell-Befehle ausführen (cat, sed -n, grep, ls, find, git log, git diff)

## Globale Claude-Skills

Auf diesem Rechner sind global (`~/.claude/skills/`) zusätzliche Skills
installiert (u. a. `tdd`, `diagnosing-bugs`, `code-review`, `domain-modeling`).
Sie sind dem Standard-Lock hier untergeordnet: Vorschläge, Diagnosen und
Risikohinweise sind erlaubt, aber kein automatisches Auslösen von Code-
oder Datei-Änderungen ohne expliziten Run-Prompt.

## Run-Ablauf

1. Agent schlägt einen Run vor (Chattext, kein Code)
2. Paco gibt frei mit: go
3. Agent führt den Run aus
4. Agent berichtet
5. Run gilt erst als abgeschlossen, wenn Paco lokal getestet hat und Testergebnis im Chat dokumentiert ist

## Snapshot-Regel

Zu Beginn einer neuen Session genügt:
1. `.dev/run_counter.txt` lesen — einzige gültige Quelle für die Run-Nummer
2. `git status` prüfen

Das vollständige Snapshot-Skript muss nicht ausgeführt werden.
Paco kann die Run-Nummer auch direkt im Prompt nennen — das hat Vorrang.

## Run-Nummer-Regel

Vor der Planung eines neuen Runs:
1. `.dev/run_counter.txt` lesen
2. die dort enthaltene Run-Nummer als letzte abgeschlossene Run-Nummer behandeln
3. die nächste Run-Nummer daraus ableiten

Die Run-Nummer aus Chat-Kontexten darf nicht als primäre Quelle verwendet werden.
`.dev/run_counter.txt` ist die einzige gültige Quelle — außer Paco nennt die Nummer direkt.

## Direkte Anweisungen ohne Run-Nummer

**Vorbedingung:** Diese Regel gilt nur wenn die letzte Haupt-Run-Nummer (NNN)
bereits committed ist — also für Korrekturen oder Ergänzungen *nach* einem
abgeschlossenen Run. Entsteht ein Run erst aus der Diskussion, ohne dass ein
Run NNN bereits existiert, erhält er die volle Nummer NNN (nicht NNNa).

Wenn eine Anweisung ohne explizite Run-Nummer gegeben wird, gilt:

- Änderung als `[letzte Run-Nr]a`, `[letzte Run-Nr]b` usw. bezeichnen
- Weitere Sub-Runs auf einem bereits durch Buchstaben benannten Run
  (z. B. `274f`) werden NICHT mit einem weiteren Buchstaben (`274fb`, `274fc`),
  sondern mit einer Zahl fortgesetzt: `274f2`, `274f3`, `274f4` usw.
  Buchstaben nur für die erste Ebene direkt auf der Run-Nummer.
- Commit mit passender Message erstellen
- Direkt `git push origin master` ausführen
- `run_counter` NICHT erhöhen
- Auf nächstes Prompt warten
- **Bericht trotzdem ausgeben** — im gleichen Codeblock-Format wie § „Bericht nach jedem Run"

## Technische Leitplanken

- Geldberechnung erfolgt intern in Cent — nicht ändern.
- Persistenz-Keys dürfen nicht verändert werden, außer der Run erlaubt es ausdrücklich.
- Keine neuen Dependencies ohne explizite Freigabe.
- Änderungen dürfen nur im Run-Prompt definierten Zielbereich erfolgen.

## Git-Sicherheitsvertrag

Vor jedem Commit `git status` prüfen.

Bei einem dieser Zustände → STOPP, nur Diagnose ausgeben:

- nicht auf Branch `master` *(gilt für lokale/CLI-Sessions ohne
  Branch-Vorgabe. In Remote-Sessions, denen die Umgebung selbst einen
  Feature-Branch zuweist — siehe „Remote-Sessions" unten —, ist dieser
  zugewiesene Branch der erwartete Arbeits-Branch, kein STOPP-Zustand.)*
- detached HEAD
- unerwartete fremde Änderungen
- unerwartete Deletes
- Merge- oder Rebase-Konflikte

Automatisch verbotene destruktive Befehle:

    git reset --hard
    git clean -fd
    git restore .

Commit-Format:

    git add <nur betroffene Dateien> .dev/run_counter.txt
    git commit -m "Run <NUMMER>: <Kurzbeschreibung>"
    git push

`.dev/run_counter.txt` immer im selben Commit wie die Run-Änderungen —
kein separater zweiter Commit, um unnötige CI-Builds zu vermeiden.

## Remote-Sessions (Claude Code Web/App): Merge nach master

Hintergrund: `.github/workflows/deploy.yml` (baut die Web-App nach
GitHub Pages, das ist die URL hinter Pacos installierter PWA) feuert
ausschließlich bei Push auf `master`. Remote-Sessions committen aber
auf einen von der Umgebung zugewiesenen Feature-Branch, nicht direkt
auf `master` — ohne Merge nach `master` gibt es keinen neuen Build,
und Paco sieht auf dem iPhone weiterhin die alte Version, egal wie
oft er die PWA neu lädt.

Deshalb gilt für Remote-Sessions zusätzlich zum normalen Run-Ablauf:

1. Nach jedem committeten und gepushten Run/Sub-Run: PR vom
   zugewiesenen Feature-Branch nach `master` anlegen (falls noch
   nicht vorhanden) bzw. den bestehenden PR weiterverwenden.
2. PR direkt mergen (`merge`, kein Force) — kein zusätzliches
   Nachfragen nötig, das ist bereits die Standing-Freigabe.
3. Danach kurz bestätigen, dass gemerged wurde (Commit-Hash/PR-Nr.),
   damit Paco weiß, dass GitHub Actions jetzt baut.

STOPP-Bedingungen — mergen abbrechen und Paco stattdessen warnen,
NICHT stillschweigend überspringen und NICHT erzwingen:

- PR-`mergeable_state` ist nicht „clean" (Konflikte, fehlgeschlagene
  Checks, Branch-Protection-Blocker, ausstehende Reviews o. Ä.)
- einer der STOPP-Zustände aus dem Git-Sicherheitsvertrag oben
- sonstiger Fehler beim Push/Merge (z. B. Netzwerk, Berechtigung)

In diesen Fällen: PR/Branch unangetastet lassen, den genauen Grund
benennen und auf Anweisung warten.

## Bericht nach jedem Run

Ausnahme: Betrifft der Run ausschließlich Dateien unter `config/` und/oder
`.dev/` (keine App-Code-Änderung), reicht eine kurze Bestätigung
(geänderte Dateien + Commit-Hash) statt des vollständigen Berichtsformats.
Spart Tokens, da hier kein Testbedarf am App-Verhalten besteht.

Format (sonst): ein einziger Codeblock, Überschrift „Claude Code-Bericht Run <NUMMER>"

Inhalt:
- Geänderte Dateien (kurze Beschreibung der Änderung)
- Manuelle Testschritte mit erwartetem Verhalten (kein flutter analyze als Testschritt)
  - Genau so viele Tests wie es relevante Risiken gibt — einen pro Risiko, nicht mehr, nicht weniger
  - Keine Tests erfinden, die nichts verifizieren, das durch die Änderung hätte brechen können
- Status von `flutter analyze`
- Status von `flutter test` (falls Tests vorhanden)
- Letzter Commit-Hash — daneben: Run-Nummer und ob sie vom User vorgegeben oder von Claude selbst abgeleitet wurde (z. B. „Run 203 – vom User vorgegeben" oder „Run 203 – aus run_counter.txt abgeleitet")
- Bestätigung: `.dev/run_counter.txt`, `CHANGELOG.md`, `TODO.md` und `PROJECT_CONTEXT.md` aktualisiert
  - CHANGELOG.md vor dem Schreiben per Read prüfen — nie behaupten, sie existiere nicht, ohne vorher nachgesehen zu haben.
    Neue Einträge kommen an den Anfang von CHANGELOG.md (aktuelle Runs), nicht ins
    CHANGELOG_ARCHIV.md. Wenn CHANGELOG.md wieder über ~60-70 Runs anwächst: ältere
    Runs analog zu Run 323 erneut nach CHANGELOG_ARCHIV.md verschieben (siehe
    Hinweis am Kopf von CHANGELOG.md).
  - TODO.md nach jedem Run abgleichen: per Read prüfen, ob der Run einen dort
    gelisteten Punkt erledigt hat (insbesondere Punkte mit passender
    *(Run NNN)*-Markierung). Erledigten Punkt NICHT nur mit `[x]` markieren,
    sondern vollständig aus TODO.md entfernen und mit `[x]` sowie einer
    kurzen Notiz zum tatsächlichen Ergebnis in TODO_ERLEDIGT.md eintragen
    (im gleichen Abschnitt/Unterabschnitt wie in TODO.md, damit die Struktur
    beider Dateien vergleichbar bleibt). So bleibt TODO.md dauerhaft auf die
    offenen Punkte beschränkt, statt mit der Zeit wieder mit erledigten
    Punkten anzuwachsen.
    Wenn das Ergebnis vom ursprünglich geplanten Punkt abweicht (Variante,
    Einschränkung, Entfall), eine kurze Notiz hinter den Eintrag schreiben,
    damit TODO_ERLEDIGT.md dokumentiert was tatsächlich gemacht wurde.
    Keine anderen TODO.md-Inhalte umformulieren oder verschieben.
    Kopfzeile (Zeile 2, „Stand: ... · Run NNN") bei jedem Run — auch
    Sub-Runs — auf die aktuelle Run-Nummer aktualisieren.
  - PROJECT_CONTEXT.md: Kopfzeile (Version + Run), Entwicklungsstand und bei
    Bedarf betroffene Architekturabschnitte aktualisieren.

## Run-Typen

- standard — normale UX-/Logik-Änderung im Zielbereich
- architecture — Strukturänderung ohne funktionales Redesign
- documentation — nur Kommentare / Dokumentation
- tests — Testabdeckung erweitern, ohne App-Verhalten zu ändern

## Versionierung

Am Ende jedes Runs die Versionsnummer in `pubspec.yaml` unter `version:` aktualisieren.
Die neue Nummer wird im Run-Prompt vorgegeben.

Zusätzlich denselben Versionswert und die Run-Nummer in
`lib/config/app_version.dart` (`AppVersion.text`, einzige Quelle seit
Run 373) eintragen, sodass er lautet:
`'Web App X.X.X · rNNN'`

`startmenue_seite.dart` und `kinoauswahl_seite.dart` zeigen diesen
Wert nur noch über `AppVersion.text` an — keine eigenen
String-Literale mehr, dort ist nichts zu ändern.

Bei Sub-Runs (z. B. 275a) den Buchstaben ebenfalls eintragen: `r275a`, nicht `r275`.
`app_version.dart` bei jedem Commit (auch Sub-Runs und Korrekturen) aktualisieren.

## Antwortverhalten beim Laden dieser Datei

Antworte ausschließlich mit:

Bereit. Warte auf Run-Prompt.
