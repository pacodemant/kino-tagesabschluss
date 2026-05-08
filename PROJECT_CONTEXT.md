# Project Context

Projekt: Flutter-App „Schauburg Tagesabschluss“

Zweck:
Unterstützung des Kino-Tagesabschlusses (Kassen- und Bargeldzählung).

## Wichtige Ordner

lib/ → Flutter-App-Code  
.dev/ → Entwicklungsworkflow und Run-System  
scripts/ → Entwickler-Skripte

## Session-Start

Zu Beginn einer neuen Session:
1. `.dev/run_counter.txt` lesen
2. `git status` prüfen

## Flutter Maintenance

Skript für häufige Wartungsaufgaben:

    ./scripts/flutter_maintenance.sh           # clean (Standard)
    ./scripts/flutter_maintenance.sh upgrade   # nach flutter upgrade
    ./scripts/flutter_maintenance.sh clean     # bei mysteriösen Fehlern
    ./scripts/flutter_maintenance.sh doctor    # Systemcheck

Manuelle Kurzreferenz:

Nach flutter upgrade:
    flutter pub upgrade
    flutter pub get
    flutter clean
    flutter pub get
    flutter doctor

Bei mysteriösen Fehlern:
    flutter clean
    flutter pub get

Systemcheck:
    flutter doctor
    flutter config --enable-web