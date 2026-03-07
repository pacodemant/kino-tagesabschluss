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
# scripts/project_snapshot/project_snapshot.txt
# ==================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
OUTPUT_FILE="$SCRIPT_DIR/project_snapshot.txt"

if [[ -z "${PROJECT_ROOT}" ]]; then
  echo "Fehler: Dieses Script muss innerhalb eines Git-Repositories ausgeführt werden."
  exit 1
fi

cd "$PROJECT_ROOT"

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

  if [[ -f "AGENTS.md" ]]; then
    echo "=================================================="
    echo "FILE: AGENTS.md"
    echo "=================================================="
    cat "AGENTS.md"
    echo ""
  fi

  if [[ -f "CHANGELOG.md" ]]; then
    echo "=================================================="
    echo "FILE: CHANGELOG.md"
    echo "=================================================="
    cat "CHANGELOG.md"
    echo ""
  fi

  if [[ -f "pubspec.yaml" ]]; then
    echo "=================================================="
    echo "FILE: pubspec.yaml"
    echo "=================================================="
    cat "pubspec.yaml"
    echo ""
  fi

  if [[ -d ".dev" ]]; then
    find ".dev" -maxdepth 1 -type f | sort | while IFS= read -r file; do
      echo "=================================================="
      echo "FILE: $file"
      echo "=================================================="
      cat "$file"
      echo ""
    done
  fi

  if [[ -d "scripts" ]]; then
    find "scripts" -type f -name "*.sh" ! -path "*/project_snapshot.txt" | sort | while IFS= read -r file; do
      echo "=================================================="
      echo "FILE: $file"
      echo "=================================================="
      cat "$file"
      echo ""
    done
  fi

  echo "=================================================="
  echo "PROJECT STRUCTURE: lib/"
  echo "=================================================="
  find "lib" -type d | sort
  echo ""

  find "lib" -type f -name "*.dart" | sort | while IFS= read -r file; do
    echo "=================================================="
    echo "FILE: $file"
    echo "=================================================="
    cat "$file"
    echo ""
  done
} > "$OUTPUT_FILE"

echo "Snapshot erstellt:"
echo "$OUTPUT_FILE"