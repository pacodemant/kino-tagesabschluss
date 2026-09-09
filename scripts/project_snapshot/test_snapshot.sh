#!/bin/zsh
set -euo pipefail

# ==================================================
# test_snapshot.sh
#
# Zweck:
# Erstellt einen vollständigen Snapshot der Unit-Tests
# für neue Claude-Code-Chats oder Diagnosen.
#
# Ausgabe:
# .dev/test_snapshot.generated.txt
# ==================================================

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$PROJECT_ROOT" ]]; then
  echo "Fehler: Dieses Skript muss innerhalb eines Git-Repositories ausgeführt werden."
  exit 1
fi

cd "$PROJECT_ROOT"

OUTPUT_DIR="$PROJECT_ROOT/.dev"
OUTPUT_FILE="$OUTPUT_DIR/test_snapshot.generated.txt"

if [[ ! -f "pubspec.yaml" ]]; then
  echo "Fehler: pubspec.yaml nicht gefunden. Das sieht nicht nach einem Flutter/Dart-Projekt aus."
  exit 1
fi

if [[ ! -d "test" ]]; then
  echo "Fehler: test/ nicht gefunden."
  exit 1
fi

if ! find "test" -type f -name "*.dart" | grep -q .; then
  echo "Fehler: Keine Dart-Dateien in test/ gefunden."
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
  echo "TEST SNAPSHOT"
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

{
  echo "=================================================="
  echo "PROJECT STRUCTURE: test/"
  echo "=================================================="
  find "test" -type d | sort
  echo ""
} >> "$OUTPUT_FILE"

find "test" -type f -name "*.dart" | sort | while IFS= read -r file; do
  append_file "$file"
done

echo "Test-Snapshot erstellt:"
echo "$OUTPUT_FILE"
