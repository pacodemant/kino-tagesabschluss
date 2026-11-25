# Go-Live-Plan SB / AT / CO

Stand: 25.11.2026 · Run 509 · Regie: Claude Code

Diese Datei ist der Einstiegspunkt für jede Session. Claude liest sie
zuerst, aktualisiert den Status nach jedem Schritt und hält oben fest,
was gerade von Paco gebraucht wird.

---

## ▶ Was gerade von Paco gebraucht wird

1. **Mail an Yannik senden**: Entwurf unten (Abschnitt "Mail an
   Yannik"), einfach kopieren und absenden.
2. **Ausgabenlimit im Anthropic-Konto setzen** (Belegscan-Kosten,
   Audit A1): console.anthropic.com → Settings → Limits → monatliches
   Limit, z. B. 20 $. Ca. 5 Minuten.
3. Sonst nichts. Phase 1 erledigt Claude allein. Handy-Tests werden
   gesammelt und kommen als ein Test-Termin.

---

## Arbeitsvereinbarung (Paco, 25.11.2026)

- "go Plan, Variante a": Ein go gilt für alle Runs aus Phase 1 unten.
  Claude führt sie nacheinander aus, testet selbst (Unit-/Widget-Tests,
  E2E im Browser) und berichtet kurz.
- Was nur auf einem echten Handy prüfbar ist, sammelt Claude in der
  Liste "Handy-Test-Termin" unten, statt nach jedem Run zu fragen.
- Alles außerhalb dieses Plans fragt Claude weiterhin vorher
  (Standard-Lock aus AGENTS.md gilt sonst unverändert).
- Rückkehrpunkt vor dem Plan: Git-Tag `v0.9.161-r507`.

## Technische Leitplanken für diesen Plan

- **pubspec.lock und analysis_options.yaml NICHT committen.** Lokal
  läuft Flutter 3.50.1, der GitHub-Build (deploy.yml) nutzt 3.44.0.
  `flutter pub get` hebt die Lock-Datei lokal auf Pakete, die Dart
  ≥ 3.13 verlangen; committet würde der GitHub-Build vermutlich
  brechen. Bleiben lokal geändert, bis die Flutter-Version in
  deploy.yml bewusst angehoben wird (eigener Run, nicht vor Go-Live).
- Bis zum Umzug auf den Kino-Server läuft die App weiter über GitHub
  Pages, nur für Tests (Sandbox).

---

## Phase 1 – Claude allein (Status)

| Run | Inhalt | Status |
|-----|--------|--------|
| 508 | Diese Plan-Datei, veraltete Doku korrigiert | erledigt |
| 509 | App-Start ohne Internet: Abruf von Getränkeliste/Wechselgeld aus dem Repo entfällt (Werte werden live vor Ort von Hand eingetragen, mitgelieferte Liste bleibt Startwert). Behebt Audit D2. | erledigt |
| 510 | Sendeablauf an Flurbocash mit Tests absichern (Erstversand, Korrektur, Fehlerfälle), Audit G1 | IN ARBEIT: Test-Einstieg `ApiUploadService.testClient` eingebaut (uncommittet, analyze ok), Tests fehlen noch |
| 511 | Online-Versand aus → App meldet NIE "gesendet" (Paco-Vorgabe 25.11.); dazu Hinweis, wenn ein Handy unvollständig eingerichtet ist | offen |
| 512 | Sendestatus: kein rotes Icon während des Sendens; geänderter Kommentar nach dem Senden geht als Korrektur raus | offen |
| 513 | API-Key-Feld in den Einstellungen verdeckt (wie Passwort); echte Belegfotos aus .dev/ entfernen (ohne History-Rewrite, Repo wird später privat) | offen |
| 514 | Einrichtungs-Checkliste für die Handys (eine Seite, zum Abhaken vor Ort) | offen |

## Laufende Nebenarbeit (Wiedereinstieg)

- Browser-Test scripts/e2e/szenario_wechselgeldentnahme.js wird an die
  Oberfläche seit Run 492 angepasst (uncommittet). Stand: Schritt 1
  und 2 laufen durch, Schritt 3 scheitert an veralteten Texten
  ("Gesamt Soll", "bar IST", "Differenz Kassenabrechnung").
  Aufruf: flutter build web --release, dann cd scripts/e2e && npm test.
- Beobachtung für Run 511: Schritt 3 zeigt in frischem Browser schon
  VOR dem Senden einen grauen Haken im Senden-Knopf. Prüfen.
- flutter analyze: 114 Infos "material.dart deprecated" kommen nur von
  Flutter 3.50.1 lokal, nicht von uns. Ignorieren bis Flutter-Upgrade.

## Phase 2 – Paco (siehe oben "Was gerade gebraucht wird")

- [ ] Mail an Yannik gesendet
- [ ] Ausgabenlimit Anthropic gesetzt
- [x] Hosting-Variante entschieden: (a) GitHub-Release, Yanniks Server
      holt die Releases mit Leseschlüssel (Paco, 25.11.)

## Phase 3 – nach Yanniks Antwort

- [ ] Live-Zugangsdaten da: Live-URL, API-Keys SB/AT/CO,
      Live-location_id SB + AT (CO = 5 bekannt)
- [ ] Yannik hat Server eingerichtet (kassenabrechnung.c137-prime.de)
      und die Adresse für Uploads freigegeben (CORS, Sandbox + Live)
- [ ] Claude: Release-Build für die neue Adresse (neuer base-href),
      erstes GitHub-Release
- [ ] Leseschlüssel für Yannik anlegen (Claude sagt Paco, wo klicken)
- [ ] SB: alte Abrechnungen bestätigt gesendet, Handy nach Checkliste
      neu eingerichtet, ein echter Testversand ins Livesystem
- [ ] AT, CO: sobald die Handys da sind, gleiche Checkliste
- [ ] Danach: GitHub Pages abschalten, Repo auf privat stellen

## Handy-Test-Termin (wird gesammelt)

- (noch leer)

## Nach dem Go-Live (bewusst zurückgestellt)

- Eigene Admin-PIN pro Gerät (Audit A3)
- Flutter-Version in deploy.yml anheben
- Übrige Audit-Punkte aus TODO.md (B, C, E, F, G2)

---

## Mail an Yannik (Entwurf, von Paco zu senden)

Betreff: Kassenabrechnung – was für den Start noch fehlt

Hallo Yannik,

die App ist für den Start in SB, AT und CO so weit fertig. Damit wir
live gehen können, brauche ich noch vier Dinge von dir:

1. Hosting: Ich nehme deinen Vorschlag (a). Ich stelle jede neue
   Version als Release in mein GitHub-Repo, dein Server holt sie sich.
   Adresse: kassenabrechnung.c137-prime.de. Das Repo stelle ich nach
   dem Umzug auf privat, du bekommst dafür von mir einen Schlüssel,
   der nur dieses Repo lesen darf.
   Zwei Fragen dazu: Kann dein Server ein dringendes Update auch
   sofort holen, nicht erst nachts? Und kannst du die neue Adresse in
   Flurbocash für Uploads freigeben (CORS), in der Sandbox und im
   Livesystem? Sonst blockiert der Browser jeden Versand.

2. Live-Zugangsdaten: die Live-URL von Flurbocash (über Port 443?
   Port 666 ist im Gäste-WLAN gesperrt), die Live-API-Keys für SB,
   AT und CO, und die Live-location_ids für SB und AT (CO hat die 5,
   hast du mir schon geschickt).

3. Smartphones für AT und CO: Welches Modell, und wann sind sie da?
   Bekommt die SB auch ein neues?

4. Termin: Sobald 1 und 2 stehen, brauche ich ein paar Tage zum
   Einrichten und Testen. Wollen wir dann einen festen Starttermin
   für die SB ausmachen? AT und CO folgen, sobald die Handys da sind.

Viele Grüße
Paco
