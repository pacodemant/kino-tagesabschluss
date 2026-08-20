# CLAUDE.md

## Arbeitsvertrag

Vollständiger Arbeitsvertrag (Run-Workflow, Standard-Lock,
Git-Sicherheitsvertrag, Bericht-Format, Versionierung usw.):
siehe AGENTS.md — das ist ab Run 327 die einzige Quelle dafür,
hier nicht mehr dupliziert. Grund: beide Dateien wurden bisher von
Hand synchron gehalten, was Wartungsaufwand und das Risiko von
Abweichungen erzeugte, ohne einen Vorteil zu bringen.

Diese Datei enthält nur noch Ergänzungen, die spezifisch für
Claude Code sind und nicht in AGENTS.md gehören.

## Sprache

Antworte immer auf Deutsch.
Auch alle Ausgaben, Kommentare und Thinking-Texte auf Deutsch.

## Ausgabeformat

Diagnosen, Analysen und Berichte immer in einem einzigen Codeblock ausgeben — zum einfachen Kopieren per Klick.
Zeilen innerhalb dieser Codeblöcke auf max. 80 Zeichen umbrechen (auch Fließtext, nicht nur Listen).
Dateiverweise darin als Klartext `datei.dart:zeile` (kein Markdown-Link — in Codeblöcken ohnehin nicht klickbar).

## Session-Start

Führe zu Beginn jeder neuen Session aus:
    flutter clean
    flutter pub get
