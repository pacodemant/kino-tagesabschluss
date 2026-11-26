# Einrichtung Kassen-Handy (Go-Live)

Stand: Run 514 · 26.11.2026 · für SB, AT, CO (je ein Handy pro Standort)

Zum Abhaken vor Ort. Was mit **(Yannik)** markiert ist, kommt von
Yannik, bevor es losgeht. Dauer: ca. 15 Minuten pro Handy.

---

## A. Vorher (nur wenn das Handy die App schon hatte)

- [ ] In der alten App unter **Verlauf** nachsehen: Steht bei allen
      Abrechnungen das grüne **Gesendet**? Wenn nicht: öffnen und
      **Erneut senden**. Die neue App-Adresse hat einen eigenen,
      leeren Speicher, der alte Verlauf ist dort nicht mehr sichtbar.

## B. App installieren

- [ ] Handy im **internen WLAN** (nicht Gäste-WLAN, das sperrt
      Flurbocash).
- [ ] In **Chrome** die neue Adresse öffnen:
      `https://kassenabrechnung.c137-prime.de` **(Yannik)**
- [ ] Chrome-Menü (⋮) → **App installieren** bzw. **Zum
      Startbildschirm hinzufügen**. Ab jetzt nur noch über das neue
      Symbol starten.

## C. Einstellungen → Admin (PIN)

Startmenü → **Einstellungen** → **Admin** antippen, PIN eingeben.

- [ ] **Standort**: fest auf den Standort stellen (nicht "Alle").
- [ ] **Flurbocash-Anbindung**: an.
- [ ] **Livesystem (SB/AT/CO)**: an. Unterzeile muss lauten: "Abrechnungen
      gehen an das echte Flurbocash".
- [ ] **Upload-URL (Live)**: eintragen **(Yannik)**.
- [ ] **location_id (Live)**: eintragen **(Yannik)**. Bei CO steht
      schon "Standard: 5", dann leer lassen.
- [ ] **API-Key**: Live-Key dieses Standorts eintragen **(Yannik)**.
      Das Feld zeigt nur Punkte, deshalb am besten einfügen statt tippen.
- [ ] **Belegscan → Service-URL**: eintragen (von Paco).
      Feld **Anthropic API-Key** leer lassen, wird nicht benutzt.
- [ ] **TIDs**: alle Kartenterminals des Standorts (SB 3, AT 1, CO 1),
      jeweils **Nr.** wie auf dem Gerät, **KK** anhaken, wenn das Gerät
      an der Kinokasse hängt.
- [ ] **Wechselgeldbestand**: Sollwert des Standorts eintragen.
- [ ] **Dev-Modus (Auto-Fill)**: aus.
- [ ] **Admin-Status halten**: aus.

## D. Außerhalb von Admin

- [ ] **Getränkeliste**: prüfen und an die Regal-Reihenfolge anpassen.

## E. Prüfen

- [ ] Zurück zum Startmenü: Es steht **kein** roter Hinweis
      "Handy nicht fertig eingerichtet" oben. Falls doch: antippen, die
      Liste sagt, was noch fehlt.
- [ ] Versionsnummer unten auf dem Startmenü notieren: __________
- [ ] Die **erste echte Abrechnung** wird normal gesendet. Danach mit
      Yannik in Flurbocash nachsehen, ob sie vollständig angekommen ist:
      Bargeld, EC-Beträge je Terminal, Belegfotos, Kommentar.
      Bis dahin zusätzlich wie bisher auf Papier abrechnen.

---

Probleme? Paco anrufen. Die Abrechnung ist auf dem Handy gespeichert und
geht nicht verloren; senden lässt sie sich auch später noch (Verlauf →
Abrechnung öffnen → Erneut senden).
