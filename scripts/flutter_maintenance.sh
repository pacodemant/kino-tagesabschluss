#!/bin/zsh
set -euo pipefail

print_step() {
  echo "==> $1"
}

MODE="${1:-clean}"

case "$MODE" in
  upgrade)
    print_step "flutter pub upgrade"
    flutter pub upgrade

    print_step "flutter pub get"
    flutter pub get

    print_step "flutter clean"
    flutter clean

    print_step "flutter pub get (nach clean)"
    flutter pub get

    print_step "flutter doctor"
    flutter doctor
    ;;

  clean)
    print_step "flutter clean"
    flutter clean

    print_step "flutter pub get"
    flutter pub get
    ;;

  doctor)
    print_step "flutter doctor"
    flutter doctor

    print_step "flutter config --enable-web"
    flutter config --enable-web
    ;;

  *)
    echo "Unbekanntes Argument: $MODE"
    echo "Verwendung: flutter_maintenance.sh [upgrade|clean|doctor]"
    exit 1
    ;;
esac

print_step "Fertig ($MODE)"
