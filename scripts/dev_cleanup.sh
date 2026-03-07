#!/bin/zsh
set -euo pipefail

print_step() {
  echo "==> $1"
}

safe_remove_dir_contents() {
  local target="$1"
  if [[ -d "$target" ]]; then
    rm -rf -- "$target"/*
    echo "   cleaned: $target"
  else
    echo "   skipped (not found): $target"
  fi
}

print_step "Starting developer cleanup"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is intended for macOS. Aborting."
  exit 1
fi

if command -v xcrun >/dev/null 2>&1; then
  print_step "Cleaning Xcode DerivedData"
  rm -rf ~/Library/Developer/Xcode/DerivedData

  print_step "Removing unavailable simulators"
  xcrun simctl delete unavailable || true

  print_step "Cleaning old DeviceSupport files"
  safe_remove_dir_contents ~/Library/Developer/Xcode/iOS\ DeviceSupport
else
  echo "xcrun not found — skipping Xcode / Simulator cleanup"
fi

print_step "Cleaning Flutter/Dart caches"
if command -v flutter >/dev/null 2>&1; then
  flutter pub cache clean || true
else
  echo "flutter not found — skipping flutter pub cache clean"
fi

if command -v dart >/dev/null 2>&1; then
  dart pub cache clean || true
else
  echo "dart not found — skipping dart pub cache clean"
fi

print_step "Cleaning project-local Flutter build artifacts (if script is run inside a Flutter repo)"
if [[ -f "pubspec.yaml" ]]; then
  rm -rf .dart_tool build
  echo "   cleaned: .dart_tool and build"
else
  echo "   skipped (no pubspec.yaml in current directory)"
fi

print_step "Done"
