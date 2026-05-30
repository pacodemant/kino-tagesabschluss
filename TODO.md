# TODO — kino_bar_app

## Kleine Änderungen
- [ ] Mitarbeitername auch in den lokalen Verlauf-Datensätzen speichern und in der Verlaufsansicht anzeigen.
- [ ] Dieser DEV-Button, der die Felder mit vorgegebenen Werten ausfüllt, soll auch in der Web-App funktionieren.
- [ ] Seite für Beleg-Eingabe: die Buttons zum Hinzufügen sollen zu Textbuttons werden.
- [ ] Die App ist nur für die interne Nutzung — Mitarbeiter sollen darüber aufgeklärt werden, dass sämtliche Daten (auch der Name) innerhalb des Betriebes bleiben.
- [ ] Stückelung: Unten soll in kleiner Schrift erklärt werden, was es bedeutet, wenn eine Zeile grün ist.
- [ ] Wenn die App mit einem Desktop-Browser abgerufen wird, sollen die Inhalte auf einer Breite dargestellt werden, die etwa einer üblichen Displaybreite entspricht.
- [ ] Dem Tagesabschluss soll noch eine Anmerkung beigefügt werden können.

## Größere Änderungen

- [ ] Die Seiten für die Gondel-Abrechnung fehlen noch. 
      - Exakt das selbe Prozedere und die selben Ausgangswerte (also auch in den Einstellungen auf 1400 Wechselgeld eintragen) wie für die Schauburg.
- [ ] Getränke: Audio-Eingabe
      - Audioaufnahme direkt in der App
      - Audio + Getränkeliste werden an KI geschickt
      - KI füllt Felder aus (fuzzy matching)
      - Unsichere Zuordnungen werden gekennzeichnet (Anzahl in Klammern)
- [ ] Frühjahrsputz: Refactoring — wiederkehrende UI-Elemente als Widgets extrahieren,
      Inline-Styling durch Theme-Konstanten ersetzen, Logik aus Widgets in Services auslagern
- [ ] Abschluss-Export: Tagesabrechnung als PDF oder Text exportieren/teilen
      (z.B. per WhatsApp an Kinoleitung schicken)
- [ ] Die Kinoleitung soll die möglichkeit haben, Messages zu versenden, wenn die App geöffnet wird, zb. um zu informieren, wenn sich etwas für die Abrechnung wichtiges ändert, zb. der Wechselgeldbestand (damit der Mitarbeiter nicht irritiert ist und an einen Fehler denkt, wenn er plötzlich einen anderen Wert)
            
## Umfangreiche Änderungen

- [ ] Kinoleitungs-Login: Kinoleitung kann Config-Dateien (Getränkeliste,
      Wechselgeldbestand) selbst bearbeiten
- [ ] Provider einführen: globalen AppState für Händigkeit,
      Login-Status und andere seitenübergreifende Daten

## Spätere Änderungen (nach MVP)
- [ ] Offline-Hinweis: App zeigt Banner wenn keine Netzwerkverbindung
      (relevant für Web-Deployment auf Android)
