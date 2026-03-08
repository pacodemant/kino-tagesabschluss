#!/bin/zsh
set -euo pipefail

# ==================================================
# project_snapshot.sh
#
# Zweck:
# Erstellt einen vollständigen Projekt-Snapshot
# für neue ChatGPT-/Codex-Chats oder Diagnosen.
#
# Ausgabe:
# .dev/project_snapshot.generated.txt
# ==================================================

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$PROJECT_ROOT" ]]; then
  echo "Fehler: Dieses Skript muss innerhalb eines Git-Repositories ausgeführt werden."
  exit 1
fi

cd "$PROJECT_ROOT"

OUTPUT_DIR="$PROJECT_ROOT/.dev"
OUTPUT_FILE="$OUTPUT_DIR/project_snapshot.generated.txt"

if [[ ! -f "pubspec.yaml" ]]; then
  echo "Fehler: pubspec.yaml nicht gefunden. Das sieht nicht nach einem Flutter/Dart-Projekt aus."
  exit 1
fi

if [[ ! -d "lib" ]]; then
  echo "Fehler: lib/ nicht gefunden."
  exit 1
fi

if ! find "lib" -type f -name "*.dart" | grep -q .; then
  echo "Fehler: Keine Dart-Dateien in lib/ gefunden."
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
: > "$OUTPUT_FILE"

append_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  {
    echo "=================================================="
    echo "FILE: $file"
    echo "=================================================="
    cat "$file"
    echo ""
  } >> "$OUTPUT_FILE"
}

{
  echo "=================================================="
  echo "PROJECT SNAPSHOT"
  echo "=================================================="
  echo "Datum: $(date)"
  echo "Projektwurzel: $PROJECT_ROOT"
  echo ""

  echo "Git Branch:"
  git branch --show-current 2>/dev/null || true
  echo ""

  echo "Letzter Commit:"
  git log -1 --oneline 2>/dev/null || true
  echo ""

  echo "Git Status:"
  git status -s 2>/dev/null || true
  echo ""
} >> "$OUTPUT_FILE"

# Root-Dateien
append_file "AGENTS.md"
append_file "CONTRIBUTING.md"
append_file "CHANGELOG.md"
append_file "pubspec.yaml"

# Nur gezielt relevante .dev-Dateien einlesen
append_file ".dev/AGENTS.md"
append_file ".dev/CONTRIBUTING.md"
append_file ".dev/run_template.md"
append_file ".dev/run_counter.txt"
append_file ".dev/project_context.md"
append_file ".dev/project_snapshot.readme.md"

# Shell-Skripte unter scripts/ einlesen
if [[ -d "scripts" ]]; then
  find "scripts" -type f -name "*.sh" | sort | while IFS= read -r file; do
    append_file "$file"
  done
fi

{
  echo "=================================================="
  echo "PROJECT STRUCTURE: lib/"
  echo "=================================================="
  find "lib" -type d | sort
  echo ""
} >> "$OUTPUT_FILE"

find "lib" -type f -name "*.dart" | sort | while IFS= read -r file; do
  append_file "$file"
done

echo "Snapshot erstellt:"
echo "$OUTPUT_FILE"