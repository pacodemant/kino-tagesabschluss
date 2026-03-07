#!/bin/zsh

# ==================================================
# project_snapshot.sh
#
# Zweck:
# Erstellt einen vollständigen Projekt-Snapshot
# für neue ChatGPT-/Codex-Chats oder Diagnosen.
#
# Enthalten:
# - AGENTS.md
# - pubspec.yaml
# - alle Dart-Dateien aus lib/
# - alle Prompt-Templates aus coding_tools/ai_prompt_templates/
# - alle .sh-Dateien aus coding_tools/
#
# Ausgabe:
# coding_tools/project_snapshot.txt
# ==================================================

OUTPUT_FILE="coding_tools/project_snapshot.txt"

echo "==================================================" > "$OUTPUT_FILE"
echo "PROJECT SNAPSHOT" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"
echo "Datum: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "Git Branch:" >> "$OUTPUT_FILE"
git branch --show-current >> "$OUTPUT_FILE" 2>/dev/null
echo "" >> "$OUTPUT_FILE"

echo "Letzter Commit:" >> "$OUTPUT_FILE"
git log -1 --oneline >> "$OUTPUT_FILE" 2>/dev/null
echo "" >> "$OUTPUT_FILE"

echo "Git Status:" >> "$OUTPUT_FILE"
git status -s >> "$OUTPUT_FILE" 2>/dev/null
echo "" >> "$OUTPUT_FILE"

# --------------------------------------------------
# AGENTS.md
# --------------------------------------------------
if [ -f "AGENTS.md" ]; then
  echo "==================================================" >> "$OUTPUT_FILE"
  echo "FILE: AGENTS.md" >> "$OUTPUT_FILE"
  echo "==================================================" >> "$OUTPUT_FILE"
  cat "AGENTS.md" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# --------------------------------------------------
# pubspec.yaml
# --------------------------------------------------
if [ -f "pubspec.yaml" ]; then
  echo "==================================================" >> "$OUTPUT_FILE"
  echo "FILE: pubspec.yaml" >> "$OUTPUT_FILE"
  echo "==================================================" >> "$OUTPUT_FILE"
  cat "pubspec.yaml" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# --------------------------------------------------
# Prompt Templates
# --------------------------------------------------
if [ -d "coding_tools/ai_prompt_templates" ]; then
  for file in coding_tools/ai_prompt_templates/*; do
    if [ -f "$file" ]; then
      echo "==================================================" >> "$OUTPUT_FILE"
      echo "FILE: $file" >> "$OUTPUT_FILE"
      echo "==================================================" >> "$OUTPUT_FILE"
      cat "$file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    fi
  done
fi

# --------------------------------------------------
# Shell Scripts in coding_tools
# --------------------------------------------------
if [ -d "coding_tools" ]; then
  for file in coding_tools/*.sh; do
    if [ -f "$file" ]; then
      echo "==================================================" >> "$OUTPUT_FILE"
      echo "FILE: $file" >> "$OUTPUT_FILE"
      echo "==================================================" >> "$OUTPUT_FILE"
      cat "$file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    fi
  done
fi

# --------------------------------------------------
# Projektstruktur lib/
# --------------------------------------------------
if [ -d "lib" ]; then
  echo "==================================================" >> "$OUTPUT_FILE"
  echo "PROJECT STRUCTURE: lib/" >> "$OUTPUT_FILE"
  echo "==================================================" >> "$OUTPUT_FILE"
  find lib -type d | sort >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# --------------------------------------------------
# Alle Dart-Dateien aus lib/
# --------------------------------------------------
if [ -d "lib" ]; then
  find lib -type f -name "*.dart" | sort | while IFS= read -r file; do
    echo "==================================================" >> "$OUTPUT_FILE"
    echo "FILE: $file" >> "$OUTPUT_FILE"
    echo "==================================================" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  done
fi

echo "Snapshot erstellt:"
echo "$OUTPUT_FILE"