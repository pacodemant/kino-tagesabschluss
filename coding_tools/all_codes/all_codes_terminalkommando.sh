#!/bin/bash

# ==================================================
# all_codes_terminalkommando.sh
#
# Zweck:
# Dieses Script erstellt einen vollständigen Code-
# Snapshot des aktuellen Projekts für KI-Analysen
# (z.B. ChatGPT oder Codex).
#
# Es sammelt:
# - aktuellen Git-Branch
# - letzten Commit
# - Git-Status
# - Projektstruktur von lib/
# - alle Dart-Dateien aus dem Ordner lib/
#
# Das Ergebnis wird gespeichert in:
# coding_tools/all_codes/all_codes_snapshot.txt
#
# Diese Datei kann anschließend in einen KI-Chat
# kopiert werden, damit die KI den vollständigen
# Projektstand analysieren kann.
# ==================================================


# --------------------------------------------------
# Sicherheitscheck: Git-Repository vorhanden
# --------------------------------------------------

if [ ! -d ".git" ]; then
  echo "Fehler: Kein Git-Repository gefunden."
  echo "Dieses Script muss im Projektordner ausgeführt werden."
  exit 1
fi


# --------------------------------------------------
# Sicherheitscheck: richtiges Repository
# --------------------------------------------------

REPO_NAME=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)")

if [ "$REPO_NAME" != "kino_bar_app" ]; then
  echo "Warnung: Dieses Script scheint nicht im Repository 'kino_bar_app' zu laufen."
  echo "Aktuelles Repository: $REPO_NAME"
  echo "Abbruch zur Sicherheit."
  exit 1
fi


# --------------------------------------------------
# Sicherheitscheck: lib/ Ordner vorhanden
# --------------------------------------------------

if [ ! -d "lib" ]; then
  echo "Fehler: Ordner 'lib/' nicht gefunden."
  echo "Dieses Script erwartet ein Flutter/Dart-Projekt."
  exit 1
fi


# --------------------------------------------------
# Sicherheitscheck: Dart-Dateien vorhanden
# --------------------------------------------------

DART_COUNT=$(find lib -type f -name "*.dart" | wc -l)

if [ "$DART_COUNT" -eq 0 ]; then
  echo "Fehler: Keine Dart-Dateien im Ordner 'lib/' gefunden."
  echo "Snapshot würde leer sein. Abbruch."
  exit 1
fi


# --------------------------------------------------
# Snapshot-Datei (im coding_tools/all_codes Ordner)
# --------------------------------------------------

mkdir -p coding_tools/all_codes
OUTPUT="coding_tools/all_codes/all_codes_snapshot.txt"


echo "==================================================" > "$OUTPUT"
echo "CODE SNAPSHOT" >> "$OUTPUT"
echo "==================================================" >> "$OUTPUT"
echo "Datum: $(date)" >> "$OUTPUT"
echo "" >> "$OUTPUT"


# --------------------------------------------------
# Run-Nummer aus run_counter.txt (optional)
# --------------------------------------------------

RUN_COUNTER_FILE="coding_tools/ai_prompt_templates/run_counter.txt"

if [ -f "$RUN_COUNTER_FILE" ]; then
  echo "Run Counter:" >> "$OUTPUT"
  grep "Nächster Run:" "$RUN_COUNTER_FILE" >> "$OUTPUT"
  echo "" >> "$OUTPUT"
fi


# --------------------------------------------------
# Git-Informationen
# --------------------------------------------------

echo "Git Branch:" >> "$OUTPUT"
git branch --show-current >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "Letzter Commit:" >> "$OUTPUT"
git log -1 --oneline >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "Git Status:" >> "$OUTPUT"
git status -s >> "$OUTPUT"
echo "" >> "$OUTPUT"


# --------------------------------------------------
# Projektstruktur anzeigen
# --------------------------------------------------

echo "==================================================" >> "$OUTPUT"
echo "PROJECT STRUCTURE (lib/)" >> "$OUTPUT"
echo "==================================================" >> "$OUTPUT"

find lib -type d | sort >> "$OUTPUT"

echo "" >> "$OUTPUT"


# --------------------------------------------------
# Dart-Dateien aus lib/
# --------------------------------------------------

echo "==================================================" >> "$OUTPUT"
echo "LIB DIRECTORY SNAPSHOT" >> "$OUTPUT"
echo "==================================================" >> "$OUTPUT"
echo "" >> "$OUTPUT"

find lib -type f -name "*.dart" | sort | while IFS= read -r file; do
{
  echo "--------------------------------------------------"
  echo "FILE: $file"
  echo "--------------------------------------------------"
  cat "$file"
  echo
} >> "$OUTPUT"
done


# --------------------------------------------------
# Abschlussmeldung
# --------------------------------------------------

echo "" >> "$OUTPUT"
echo "Snapshot erstellt: $OUTPUT"

echo ""
echo "Fertig."
echo "Snapshot gespeichert in:"
echo "$OUTPUT"