# AGENTS.md – kino_bar_app

## Projekt
Flutter/Dart-Projekt: **kino_bar_app**

## Arbeitsmodus
- Arbeite in kleinen, klar abgegrenzten Runs.
- Ändere nur den im Prompt beschriebenen Zielbereich.
- Keine Nebenbei-Refactors.
- Wenn der Arbeitsbaum nicht sauber ist: STOPP und Rückfrage.

## Git-Regeln
- Vor Änderungen immer `git status` prüfen.
- Nur betroffene Dateien committen.
- Commit-Message exakt so verwenden, wie im Run-Prompt vorgegeben.
- Nach erfolgreichem Run den Run-Counter aktualisieren.
- Wenn unerwartete Änderungen, gelöschte Dateien oder fremde uncommittete Dateien auftauchen: keine Änderungen ausführen, sondern Diagnose ausgeben.

## Refactor-Regeln
- Ziel ist nicht bloß Dateiaufteilung, sondern **echte architektonische Entlastung** der Hauptdateien.
- Für UI-Refactors **keine `part`-Dateien** verwenden.
- Bevorzuge **echte Widgets/Klassen mit `import`**.
- Hauptseiten sollen möglichst **koordinieren statt implementieren**.
- Wenn kein sinnvoller Block mehr existiert, das klar sagen statt künstlich weiter zu splitten.
- Nicht in viele Mikro-Dateien fragmentieren.

## Flutter-Konventionen
- Bestehendes Verhalten muss bei Refactors 1:1 erhalten bleiben.
- Keine neuen Packages ohne ausdrückliche Anweisung.
- Interne Berechnungen weiter in Cent.
- Keine Änderungen an Persistenz-Keys/JSON-Strukturen ohne ausdrückliche Anweisung.
- Kommentare kurz, sachlich und auf Deutsch.

## Benennung
- Bevorzuge **deutsche, sprechende Namen** für neue Variablen, Objekte, Methoden und Hilfsklassen, sofern technisch sinnvoll und konsistent.
- Bestehende öffentliche APIs oder bereits etablierte Strukturen nur dann umbenennen, wenn es ausdrücklich beauftragt wird.

## Tests und Validierung
- Nach relevanten Änderungen immer `flutter analyze` ausführen.
- Wenn Tests vorhanden sind: `flutter test` ausführen.
- Bei Änderungen an Berechnungen oder Summenlogik besonders auf vorhandene Unit-Tests achten.
- Wenn für eine kritische Berechnung noch keine Tests existieren, das im Abschluss kurz benennen.

## Verhalten bei Unsicherheit
- Bei unklarem Prompt erst Rückfrage stellen.
- Lieber stoppen als stillschweigend Architektur oder Verhalten ändern.

## Ziel für große Dateien
- Große Seiten sollen schrittweise in sinnvolle Bausteine zerlegt werden.
- Nicht jede kleine Methode auslagern.
- Lesbarkeit und Wartbarkeit sind wichtiger als eine künstlich niedrige Zeilenzahl.