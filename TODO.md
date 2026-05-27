# TODO — kino_bar_app

## Kleine Änderungen

- [ ] Offline-Hinweis: App zeigt Banner wenn keine Netzwerkverbindung
      (relevant für Web-Deployment auf Android)

## Größere Änderungen

- [ ] Getränke: Mitarbeiter kann Getränkenamen umbenennen (Kurzname für Alltag)
      - Original-Name (von Kinoleitung) bleibt sichtbar, klein und grau neben dem Kurznamen
- [ ] Getränke: Audio-Eingabe
      - Audioaufnahme direkt in der App
      - Audio + Getränkeliste werden an KI geschickt
      - KI füllt Felder aus (fuzzy matching)
      - Unsichere Zuordnungen werden gekennzeichnet (Anzahl in Klammern)
- [ ] Frühjahrsputz: Refactoring — wiederkehrende UI-Elemente als Widgets extrahieren,
      Inline-Styling durch Theme-Konstanten ersetzen, Logik aus Widgets in Services auslagern
- [ ] Abschluss-Export: Tagesabrechnung als PDF oder Text exportieren/teilen
      (z.B. per WhatsApp an Kinoleitung schicken)
            
## Umfangreiche Änderungen

- [ ] Kinoleitungs-Login: Kinoleitung kann Config-Dateien (Getränkeliste,
      Wechselgeldbestand) selbst bearbeiten
- [ ] Provider einführen: globalen AppState für Händigkeit,
      Login-Status und andere seitenübergreifende Daten
