# TODO — kino_bar_app

## Kleine Änderungen
- [ ] Dieser DEV-Button, der die Felder mit vorgegebenen Werten ausfüllt, aoll ach in der Web App funktionieren.      
- [ ] Seite für Beleg-Eingabe: die Buttons zum Hinzufügen sollen zu Textbuttons werden
- [ ] In den Einstellungen soll der Mitarbeiter seinen (Vor-)Namen eingeben, der mit die Datensätzen zusammen abgespeichert wird.
- [ ] Die app ist ja nur für die interne Nutzung, dennoch sollten die Mitarbeiter darüber aufgeklärt werden, dass sämtliche Daten, auch der Name, INNERHALB des Betriebes bleiben. Die WebApp kommuniziert nur mit dem Firmeneigenen Server, oder so ähnllich
- [ ] Stückelung: Unten soll in kleiner Schrift erklärt werden, was es bedeutet, wenn eine Zeile grün ist.
- [ ] der Mitarbeiter soll in den Persönlichen einstellungen (eine neue Kachel) neben seinem Namen auch angeben können, wie er die Beträge eingeben will: in Cent oder mit komme, also entweder für 1,50 : entweder "1,50" oder "150". Intern soll aber in Cents gerechnet werden, um rundungsfehlern vorzubeugen
- [ ] wenn die App mit einem Desktop-Browser abgerufen wird, dann sollen die Inhalte auf einer Breite dargestellt werden, die etwa einer üblichen Displaybreite entspricht.
- [ ] Dem Tagesabschluss soll noch eine Anmerkung beigefügt werden.
- [ ] Ich sehe gerade in den Einstellungen für den Bargeldbestand, dass die eingabe nicht dem Prinzip "Centbeträge ohne Komma" nicht folgt und ich ein Komma eingeben muss. Die Tastatur hat hier auch ein Komma im Layout. 1. Auch hier soll das Prinzip der Eingabe "Centbeträge ohne Komma" gelten. 2. In einem späteren Schritt möchte ich, dass der Mitarbeiter einstellen kann, ob er die Beträge mit Komma eingeben möchte (dann muss auch die richtige Tastatur mit Komma angezeigt werden) oder ob der Mitarbeiter die Beträge in Cent eingeben möchte.

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
