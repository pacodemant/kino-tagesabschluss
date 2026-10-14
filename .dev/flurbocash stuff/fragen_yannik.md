# Fragen an Yannik

Stand: 14.10.2026 (Run 485) · zentrale Tracking-Datei für alle Fragen an Yannik:
Flurbocash-Anbindung, Projektplanung, Vergütung und Persönliches.

**So ist die Datei aufgebaut:**

- Zwei Inhaltsverzeichnisse: **Offene Fragen** und **Beantwortete Fragen**.
- Jeder Abschnitt: kurz der Hintergrund, dann **Frage**, direkt darunter
  die **Antwort** (als Zitat abgesetzt). Bei offenen Fragen steht dort
  „noch offen“ — beim Termin einfach überschreiben.
- Ist eine Frage beantwortet, wandert der Abschnitt in den Teil
  „Beantwortete Fragen“ und der Link ins zweite Inhaltsverzeichnis.
- Die Nummern (1.2, 3.1 …) bleiben fest, weil TODO.md, PROJECT_CONTEXT.md
  und CHANGELOG.md darauf verweisen. Ausführliche alte Fassungen stehen im
  Git-Verlauf (zuletzt vollständig in Run 484).

⏳ offen · ◐ teilweise geklärt · ✅ beantwortet · – entfällt/zurückgestellt

---

## Inhalt: Offene Fragen (17)

In Gesprächsreihenfolge für den Termin am 14.10.2026.

**A. Projektplanung**

- ⏳ [7.1 Wollen wir eine Deadline benennen?](#71-deadline) *(neu)*
- ⏳ [7.2 Nächste Schritte: erst CO und AT, dann GO, dann BT?](#72-reihenfolge-der-standorte) *(neu)*

**B. Ausfälle im Betrieb**

- ⏳ [8.1 Was soll die App tun, wenn die KI für den Beleg-Scan offline ist?](#81-ki-für-beleg-scan-offline) *(neu)*
- ⏳ [8.2 Was soll passieren, wenn FC down ist und nicht gesendet werden kann?](#82-flurbocash-nicht-erreichbar) *(neu)*
- ⏳ [3.3 Was soll passieren, wenn das 4×-Limit pro Tag erreicht ist?](#33-verhalten-bei-maximum-reached-4-limit)

**C. Terminals & Standortdaten**

- ◐ [1.2 Sind die SB-TIDs bei FC hinterlegt?](#12-terminal-ids-pro-standort)
- ⏳ [1.9 Terminal-Nummern fest mit den TIDs koppeln?](#19-terminal-nummern-fest-mit-tids-koppeln) *(neu)*
- ⏳ [2.7 SB: Kartenumsatz zum Kino-SOLL addieren — bleibt das so?](#27-sb-sonderfall-kartenumsatz-zum-kino-soll-addieren) *(neu)*
- ⏳ [1.10 Wie lauten die Live-location_ids und Live-Keys für SB, AT und BT?](#110-live-zugangsdaten-für-sb-at-bt) *(neu)*
- ⏳ [5.3 Welches WLAN ist an den Standorten für die Kasse freigegeben?](#53-wlan-für-den-kassenbetrieb)

**D. Server & Schnittstelle**

- ◐ [1.8 Kann die App jetzt auf den Kino-Server umziehen?](#18-app-hosting-auf-kino-server-statt-github-pages)
- ◐ [2.4 Ist eure Antwort eine verlässliche Empfangsbestätigung?](#24-empfangsbestätigung)
- ◐ [3.1 Abfrage, welche settlement_numbers schon belegt sind?](#31-leseweg-für-belegte-settlement_numbers) *(niedrige Priorität)*

**E. Vergütung & Persönliches**

- ⏳ [6.1 Wie hoch soll die Vergütung sein, nach welchem Modell?](#61-vergütung-yannik-höhemodell)
- ◐ [6.2 Besteht ein Risiko der Scheinselbständigkeit?](#62-risiko-scheinselbständigkeit)
- ⏳ [6.3 Ich brauche wieder einen Vorschuss.](#63-vorschuss) *(neu)*
- ⏳ [6.4 Kaffee-Flat, während ich in der BT an der App arbeite?](#64-kaffee-flat-in-der-bt) *(neu)*

## Inhalt: Beantwortete Fragen (22)

**1. Zugangsdaten & Einrichtung**

- ✅ [1.1 Produktivbetrieb pro Standort oder alle gleichzeitig?](#11-umstieg-auf-produktivbetrieb)
- ✅ [1.3 Welche location_id haben GO und CO?](#13-standort-kennung-location_id)
- ✅ [1.4 Passwort Schauburg-AP?](#14-passwort-schauburg-ap)
- ✅ [1.5 Wer richtet die Geräte ein und pflegt sie?](#15-geräte-einrichtung--pflege)
- ✅ [1.6 Konfiguration zentral oder je Gerät?](#16-konfiguration-zentral-oder-je-gerät)
- ✅ [1.7 Wer besorgt ein Android-Testgerät?](#17-android-testgerät)

**2. Abrechnungsdaten & Format**

- ✅ [2.1 Zwei EC-Belege desselben Terminals einzeln übertragen?](#21-zwei-ec-belege-am-selben-terminal)
- ✅ [2.2 Braucht FC außer Kartenumsätzen und Bargeld weitere Daten?](#22-weitere-daten-gewünscht)
- ✅ [2.3 Dürfen Notizen, MA-Name und Sendezeitpunkt mitgeschickt werden?](#23-notizen-ma-name-sendezeitpunkt)
- ✅ [2.4a Wie kennzeichnen wir Testübertragungen im Dashboard?](#24a-testkennzeichnung-im-dashboard)
- ✅ [2.5 Hat die Buchhaltung die SB-Testübertragungen geprüft?](#25-validierung-der-sb-testübertragungen)
- ✅ [2.6 Welches Datum gilt für Nachtabrechnungen?](#26-datum-für-nachtabrechnungen-5-uhr-knick)

**3. Korrektur & Duplikate**

- ✅ [3.1a Wie funktioniert die Korrektur per settlement_number?](#31a-korrektur-mechanismus)
- – [3.1b Sieht die Buchhaltung Korrekturen im Dashboard?](#31b-korrekturen-im-dashboard)
- – [3.1c Wann wird ein Tag als finalized markiert?](#31c-finalized)
- – [3.2 Wie verhindern wir doppelte Übertragungen?](#32-schutz-vor-doppel-übertragung)

**4. Beleg-Foto**

- ✅ [4.1 Muss das Belegfoto entzerrt werden?](#41-perspektivische-ausrichtung)
- ✅ [4.2 In welchem Feld und Format wird das Foto übertragen?](#42-feld-und-format-für-das-belegfoto)
- ✅ [4.3 Braucht es ein Prüfen-Flag oder einen Dev-Button?](#43-prüfen-flag-für-die-buchhaltung)

**5. Sonstiges**

- – [5.1 Soll die App Mails verschicken?](#51-mailversand)
- ✅ [5.2 Wird ein Stapelscanner für alte Belege gebraucht?](#52-stapelscanner)
- – [5.3a Nachträgliche Prüfung nach Verbindungsabbruch?](#53a-prüfung-nach-verbindungsabbruch)

---
---

# Teil 1: Offene Fragen

### 1.2 Terminal-IDs pro Standort

◐ teilweise geklärt — nur SB offen

**Hintergrund:** Alte und neue TIDs gelten in der App während der
Umstellung parallel (config/terminal_ids.json).

| Standort | alte TID           | neue TID                                   | bestätigt |
|----------|--------------------|--------------------------------------------|-----------|
| SB       | 54017635           | 60561994, 60561996, 60561997               | nein      |
| AT       | 54069464           | 60561998                                   | ja        |
| CO       | 54017639           | 60561995                                   | ja        |
| BT       | 54069493, 54017664 | 60561992, 60561993                         | ja        |
| GO       | –                  | 60561999, 60562000, 60562001, 60562002     | ja        |

SB (07.09.): Die neuen Terminals können vorerst nur Girocard, Kreditkarte
läuft weiter über das alte Terminal. Siehe auch 1.9 und 2.7.

**Frage:**

1. Sind die neuen TIDs bei FC korrekt hinterlegt?
2. Wann können die alten TIDs entfernt werden?
3. Welche TID hat GO?
4. *(Rest)* Sind die SB-TIDs (alt und neu) bei FC korrekt hinterlegt?

> **Antwort (Mail Yannik, 14.10.):** Zu 1 und 3: Neue TIDs für AT, BT, CO
> und GO bestätigt, siehe Tabelle. GO in der App eingetragen (Run 485).
> Zu 2 (Paco, 14.10.): Die alten TIDs bleiben in der App, bis sie an
> allen Standorten korrekt läuft — keine Frage an Yannik mehr.
> Zu 4: *noch offen* — SB kam in der Mail nicht vor.

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 1.10 Live-Zugangsdaten für SB, AT, BT

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Die location_id ist nicht in Sandbox und Livesystem
gleich (laut Yannik nicht mehr einfach änderbar). Für GO und CO kennen wir
beide Werte (1.3). Die bisherigen Werte für SB (1), AT (3) und BT (4) sind
vermutlich Sandbox-Werte — AT kann live nicht die 3 sein, die hat dort GO.
Die location_id wird pro Gerät in den Einstellungen eingetragen, nicht im
Code. Ein falscher Wert beim Live-Umstieg würde die Abrechnung beim
falschen Kino verbuchen.

**Frage:**

1. Wie lauten die Live-location_ids für SB, AT und BT?
2. Gibt es für das Livesystem eigene API-Keys pro Standort, und eine
   eigene URL (1.1)?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 1.8 App-Hosting auf Kino-Server (statt GitHub Pages)

◐ teilweise geklärt

**Hintergrund:** Die App läuft als PWA über GitHub Pages (Pacos privater
Account). Infos an Yannik am 01.09.: SFTP-Upload in einen Ordner, alte
Dateien werden ersetzt, HTTPS ist Pflicht; lokal generalprobt.

Was Yannik vor dem ersten Upload wissen muss (30.09.):

- **Adresse/Pfad:** Domain und ggf. Unterordner. Wird beim Build fest als
  `--base-href` eingetragen (aktuell `/kino-tagesabschluss/`).
- **CORS:** Die FC-API erlaubt derzeit nur `https://pacodemant.github.io`.
  Die neue App-Adresse muss auf Sandbox UND Produktivservern ergänzt
  werden, sonst blockiert der Browser jeden Upload (entfällt bei gleicher
  Adresse wie die API).
- **WLAN:** Die App-Adresse muss aus dem Kassen-WLAN erreichbar sein
  (Gäste-WLAN sperrt z. B. Port 666), idealerweise Port 443.
- Optional: kein langes Browser-Caching für index.html,
  flutter_bootstrap.js und main.dart.js (`Cache-Control: no-cache`).

Zur Info (Paco-Aufgabe): Durch die neue Adresse ist der Speicher der App
getrennt. Alle Handys müssen die App neu installieren und neu einrichten
(API-Key, TIDs, Verlauf weg). Vorher sicherstellen, dass alle Abrechnungen
bestätigt gesendet sind.

**Frage:** Hast du dir das angeschaut? Ist der Umzug jetzt möglich, und
habe ich dann selbst Zugriff für Updates?

> **Antwort:** *noch offen* — bisheriger Stand: Yannik brauchte erst Infos
> zum aktuellen Deployment (am 01.09. geliefert).

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 1.9 Terminal-Nummern fest mit TIDs koppeln

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Die Terminals haben neben der TID noch eine eigene
Gerätenummer. Die MA kennt das Gerät eher an dieser Nummer als an der
achtstelligen TID. Die App könnte dann z. B. „Terminal 2 (TID …)“
anzeigen, und ein Hinweis wie „Beleg von Terminal 3 fehlt noch“ wäre für
die MA verständlich.

**Frage:**

1. Wollen wir die Gerätenummern fest mit den TIDs koppeln?
2. Sind die Nummern dauerhaft an die Geräte vergeben (auch bei Tausch oder
   Reparatur)?
3. Wer pflegt die Zuordnung, wenn sich etwas ändert?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 2.4 Empfangsbestätigung

◐ teilweise geklärt

**Hintergrund:** Die App wertet eure Antwort auf PUT settlements als
Empfangsbestätigung: Erst bei 2xx zeigt sie „gesendet“, und sie merkt sich
die settlement_number aus der Antwort, damit eine spätere Korrektur die
richtige Abrechnung überschreibt (seit Run 477). Fehlt die Nummer, gilt
die Abrechnung trotzdem als gesendet, die MA bekommt aber einen Hinweis,
eine Korrektur mit der IT abzustimmen (seit Run 480).

**Frage:** Könnt ihr bestätigen:

- (a) 2xx kommt erst, wenn die Abrechnung wirklich gespeichert ist, nicht
  schon beim Eingang?
- (b) Die Antwort ist immer JSON und enthält die vergebene
  settlement_number an der jetzigen Stelle
  (`settlements[0].settlement_number`)?

Falls sich daran später etwas ändert, bitte vorher Bescheid geben, sonst
gehen Korrekturen unbemerkt ins Leere.

> **Antwort:** *noch offen* — beobachtet (Sandbox, 24.09.): (b) ist
> derzeit so, aber nicht von Yannik bestätigt.

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 2.7 SB-Sonderfall: Kartenumsatz zum Kino-SOLL addieren

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Eines der drei neuen SB-Terminals hat Yannik direkt ans
Kinokassen-System angeschlossen, sodass man den Betrag nicht mehr
eintippen muss. Seitdem muss man den Kartenumsatz dieses Terminals und den
Kinokarten-Umsatz addieren und das Ergebnis als Kino-SOLL in die App bzw.
auf den Umschlag eintragen. Warum, ist mir nicht klar.

**Frage:**

1. Warum ist das so?
2. Ist das ein vorübergehender Workaround, bis das behoben ist, oder
   bleibt das dauerhaft?
3. Falls dauerhaft: Soll die App das selbst rechnen (Kartenumsatz des
   angeschlossenen Terminals aus dem Beleg-Scan automatisch zum Kino-SOLL
   addieren)? Dann bräuchte ich die TID des angeschlossenen Terminals.
4. Kommen an anderen Standorten weitere angeschlossene Terminals dazu?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 3.1 Leseweg für belegte settlement_numbers

◐ teilweise geklärt — für den Regelfall gelöst, Rest niedrige Priorität

**Hintergrund:** FC liefert die vergebene settlement_number in der
PUT-Antwort. Die App merkt sich die Nummer pro Kino und Abrechnungstag und
schickt sie bei jedem weiteren Versand dieses Tages mit (Run 477).
Problematisch bleibt nur der Fall, dass die App ihren lokalen Merker
verloren hat (Datenverlust, Korrektur von einem anderen Gerät,
Neuinstallation beim Server-Umzug 1.8).

Vorher selbst prüfen (Dev-Modus „Server-Antwort anzeigen“, seit Run 476),
ob die ensure-Antwort die vorhandenen Settlements schon mitliefert — dann
erübrigt sich die Frage.

**Frage:** Gibt es (oder plant ihr) eine Möglichkeit, VOR dem Senden
abzufragen, welche settlement_numbers für einen Tag schon belegt sind?
Falls nicht: Wäre ein Flag wie `overwrite_last: true` möglich, mit dem FC
selbst die zuletzt eingereichte Abrechnung des Tages überschreibt?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 3.3 Verhalten bei „maximum reached“ (4×-Limit)

⏳ offen

**Hintergrund:** Ab der 5. Abrechnung pro Tag antwortet FC mit `400`
„maximum of 4 settlements per day reached“. Ein Mailversand ist nicht
vorgesehen (5.1). Praktisch relevant v. a. für BT (zwei Abrechnungen pro
Tag plus Korrekturen). Abrechnungen lassen sich in FC löschen, außer Nr. 1.

**Frage:** Was soll die MA in dem Fall tun? Z. B. Hinweis in der App
„Bitte Büro/IT informieren“, oder löscht FC/die Buchhaltung dann eine
Abrechnung?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 5.3 WLAN für den Kassenbetrieb

⏳ offen

**Hintergrund:** Das Gäste-WLAN sperrt den Kassen-Port (666) und wird für
den Kassenbetrieb nicht genutzt. Hängt mit 1.8 zusammen (die App-Adresse
muss aus diesem WLAN erreichbar sein).

**Frage:** Welches WLAN ist an den einzelnen Standorten (SB, GO, AT, CO,
BT) für den Flurbocash-Zugriff vorgesehen bzw. freigegeben?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 6.1 Vergütung Yannik (Höhe/Modell)

⏳ offen — beim Termin aktiv ansprechen, nicht nur beiläufig

**Hintergrund:** Direkt an Yannik gerichtet — er ist nicht nur IT, sondern
auch Chef-Sohn und Nachfolger.
Vorschlag Paco: Vergütung am Einsparpotential orientieren, das die App
gegenüber der bisherigen Abrechnungsweise bringt. Um nicht auf Schätzungen
angewiesen zu sein: alte und neue Abrechnungsweise per Stoppuhr
vergleichen.

**Frage:** Wie hoch soll die Vergütung sein, und nach welchem Modell?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 6.2 Risiko Scheinselbständigkeit

◐ teilweise geklärt — beim Termin nachfassen

**Frage:** Besteht ein Risiko der Scheinselbständigkeit? Hat das
Steuerbüro es inzwischen beurteilt?

> **Antwort (teilweise):** Tom sagt: kein Problem. Beurteilung durch das
> Steuerbüro *noch offen*.

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 6.3 Vorschuss

⏳ offen *(neu, 14.10.)*

**Frage:** Ich brauche wieder einen Vorschuss. Wie hoch, ab wann, und wie
wird er mit der Vergütung (6.1) verrechnet?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 6.4 Kaffee-Flat in der BT

⏳ offen *(neu, 14.10.)*

**Frage:** Ist eine Kaffee-Flat möglich, während ich in der BT an der App
arbeite?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 7.1 Deadline

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Der Umstieg erfolgt je Standort (1.1). Ein Termin hängt
an Punkten, die nicht in Pacos Hand liegen (Live-Zugangsdaten 1.10,
Server-Umzug 1.8).

**Frage:** Wollen wir eine Deadline benennen? Falls ja: für den
Produktivstart aller Standorte oder je Standort?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 7.2 Reihenfolge der Standorte

⏳ offen *(neu, 14.10.)*

**Hintergrund:** SB läuft bereits im Testbetrieb. Gründe für die
vorgeschlagene Reihenfolge, zum Gegenprüfen:

- GO und CO: TIDs, location_id und Sandbox-Key seit 14.10. vorhanden
  (1.2/1.3), Geräte können eingerichtet werden.
- BT: zwei Abrechnungen pro Tag (Mittag + Tagesende), stößt am ehesten an
  das 4×-Limit (3.3).

**Frage:** Nächste Schritte: erst CO und AT, dann GO, dann BT?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 8.1 KI für Beleg-Scan offline

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Der KI-Dienst für den Beleg-Scan ist leider nicht selten
nicht erreichbar. Aktuell zeigt die App dann die Fehlermeldung und den
Hinweis „Beleg kann auch manuell eingegeben werden.“ Die MA tippt die
Werte dann selbst ab.

**Frage:**

1. Reicht die manuelle Eingabe als Notlösung, oder ist das für die
   Buchhaltung zu fehleranfällig?
2. Soll die App eine Abrechnung mit manuell eingetragenen Belegdaten für
   die Buchhaltung kennzeichnen (z. B. im Kommentarfeld, wie „test“ bei
   2.4a)?
3. Wäre ein zweiter KI-Anbieter als Ausweichlösung gewünscht? Hängt mit
   dem geplanten eigenen Anthropic-Account des Kinos zusammen.

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---

### 8.2 Flurbocash nicht erreichbar

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Aktuell zeigt die App eine Fehlermeldung. Die Abrechnung
bleibt lokal gespeichert, steht im Verlauf als „nicht gesendet“, und die
MA kann später erneut senden (seit Run 448 zuverlässig). Ein Mailversand
als Ausweichweg ist nicht vorgesehen (5.1).

**Frage:**

1. Reicht „später erneut senden“? Wer kümmert sich darum, wenn die MA
   nach Schichtende nach Hause geht — die nächste Schicht, das Büro?
2. Wie lange darf eine Abrechnung nachträglich ankommen, bevor FC den Tag
   als `finalized` markiert (dann keine Schreibzugriffe mehr)?
3. Reicht der Umschlag als Papier-Nachweis, bis die Abrechnung
   nachgesendet ist, oder braucht es mehr?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-17)

---
---

# Teil 2: Beantwortete Fragen

## 1. Zugangsdaten & Einrichtung

### 1.1 Umstieg auf Produktivbetrieb

✅ beantwortet

**Hintergrund:** Die Sandbox-Adresse ist nicht die Produktiv-Adresse; für
den Echtbetrieb gibt es eine eigene URL von Yannik. Umstieg nach
erfolgreichen Tests (SB), nicht an einem festen Datum.

**Frage:** Erfolgt der Umstieg standortweise nacheinander oder für alle
gleichzeitig?

> **Antwort:** Je Standort.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 1.3 Standort-Kennung (location_id)

✅ beantwortet

**Frage:** Welche location_id haben GO und CO?

> **Antwort (Mail Yannik, 14.10.):** Unterschiedlich in Sandbox und Live:
>
> | Standort | Sandbox | Live |
> |----------|---------|------|
> | GO       | 5       | 3    |
> | CO       | 6       | 5    |
>
> Zum Vergleich (Mail 12.07.): SB = 1, AT = 3, BT = 4, vermutlich Sandbox.
> Live-Werte dafür siehe 1.10. Die API-Keys stehen in
> secrets/api_keys.txt (nicht im Git).

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 1.4 Passwort Schauburg-AP

✅ beantwortet

**Frage:** Wie lautet das Passwort für den Schauburg-AP?

> **Antwort:** Keine formelle Frage mehr — Paco klärt das jeweils vor Ort
> bzw. fragt Yannik spontan per Messenger.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 1.5 Geräte-Einrichtung & Pflege

✅ beantwortet

**Frage:** Wer richtet die Geräte ein und pflegt sie?

> **Antwort:** Paco richtet die Apps an den Standorten initial selbst ein.
> Spätere Änderungen (API-Key, TID) direkt am Gerät, siehe 1.6.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 1.6 Konfiguration zentral oder je Gerät

✅ beantwortet

**Frage:** Wird die Konfiguration zentral oder pro Gerät gepflegt?

> **Antwort:** Am Gerät vor Ort, nicht zentral von Yannik verwaltet.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 1.7 Android-Testgerät

✅ beantwortet

**Frage:** Wer besorgt ein Android-Testgerät?

> **Antwort:** Yannik kauft eins.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

## 2. Abrechnungsdaten & Format

### 2.1 Zwei EC-Belege am selben Terminal

✅ beantwortet und umgesetzt (Run 399a3)

**Hintergrund:** Gemeint sind zwei EC-Zahlungsvorgänge am selben Terminal
(gleiche TID) innerhalb derselben Abrechnung. Die App hatte sie früher zu
einer `terminals[]`-Zeile zusammengefasst.

**Frage:** Sollen beide Belege einzeln übertragen werden (zwei
`terminals[]`-Einträge mit gleicher TID), und verarbeitet FC das korrekt?

> **Antwort:** Ja, jeder Beleg als eigener Datensatz, und FC verarbeitet
> das korrekt.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 2.2 Weitere Daten gewünscht?

✅ beantwortet

**Frage:** Braucht FC außer Kartenumsätzen und Bargeld weitere Daten?

> **Antwort:** Nein. FC holt sich die Kassenumsätze selbst aus dem
> Kassensystem. Die App schickt nur `terminals[]` und `cash_total`.
> Kino-SOLL, Bistro-SOLL, Ausgaben und Differenz werden nicht gebraucht.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 2.3 Notizen, MA-Name, Sendezeitpunkt

✅ beantwortet

**Frage:** Dürfen Notizen, MA-Name und Sendezeitpunkt mitgeschickt werden?

> **Antwort:** Ja. Eigene JSON-Felder sind generell erlaubt, Feldnamen
> frei wählbar. FC ignoriert sie, bis sie serverseitig implementiert sind.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 2.4a Testkennzeichnung im Dashboard

✅ beantwortet

**Frage:** Könnt ihr Testübertragungen im Dashboard farblich von echten
unterscheidbar machen? Und schickt ihr einen Empfangs-Zeitstempel mit?

> **Antwort:** Keine Farbmarkierung — stattdessen „test“ ins
> Kommentarfeld schreiben, die Buchhaltung erkennt es manuell.
> Ein Server-Zeitstempel entfällt (Paco, 30.09.): Die App schickt selbst
> `sent_at` mit. (Empfangsbestätigung siehe 2.4 bei den offenen Fragen.)

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 2.5 Validierung der SB-Testübertragungen

✅ beantwortet

**Frage:** Hat die Buchhaltung die SB-Testübertragungen geprüft?

> **Antwort:** Noch nicht getestet (Stand 26.08.).

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 2.6 Datum für Nachtabrechnungen (5-Uhr-Knick)

✅ beantwortet und umgesetzt

**Frage:** Gilt für Abrechnungen nach Mitternacht das logische
Geschäftsdatum?

> **Antwort:** Ja, logisches Geschäftsdatum. Der Tageswechsel liegt aber
> bei 5 Uhr, nicht bei 6 Uhr. In der App umgestellt.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

## 3. Korrektur & Duplikate

### 3.1a Korrektur-Mechanismus

✅ beantwortet und umgesetzt (Run 477)

**Frage:** Wie korrigiert die App eine bereits gesendete Abrechnung, und
erfährt sie, welche settlement_number vergeben wurde?

> **Antwort:** settlement_number weglassen = neue Abrechnung, Wert 1–4 =
> bestehende überschreiben (FC erkennt Korrekturen nicht selbst am
> Inhalt). FC liefert die vergebene Nummer in der PUT-Antwort mit
> (`settlements[0].settlement_number`).

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 3.1b Korrekturen im Dashboard

– entfällt (nur Info an FC)

**Frage:** Sieht die Buchhaltung einen Unterschied zwischen Erst-
Abrechnung, Korrektur und versehentlichem Doppel-Versand? Wäre ein
„zuletzt geändert“-Hinweis möglich?

> **Antwort (Paco, 30.09.):** Keine App-Frage. Die App schickt
> settlement_number und `sent_at`, ob und wie FC das anzeigt, entscheidet
> Yannik. Korrekturen kommen ohnehin meist am selben Abend.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 3.1c finalized

– zurückgestellt

**Frage:** Wann/wodurch wird ein Tagesbericht als `finalized` markiert?

> **Antwort (Paco, 30.09.):** Für die App nicht nötig — Korrekturen kommen
> am selben Abend, die App erkennt `finalized: true` bzw. die 400 selbst.
> Taucht im Ausfall-Kontext wieder auf, siehe 8.2.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 3.2 Schutz vor Doppel-Übertragung

– entfällt (app-seitig gelöst, beim Aufräumen am 14.10. eingestuft)

**Frage:** Wie verhindern wir, dass dieselbe Abrechnung versehentlich
doppelt bei FC landet (Doppel-Tap, Verbindungsabbruch)?

> **Antwort:** App-seitig gelöst: Die App erkennt anhand der
> Sende-Signatur, dass schon gesendet wurde, und zeigt den Dialog „Du hast
> die Abrechnung bereits gesendet“ (Hinweis ergänzt in Run 482). Ein
> erneuter Versand überschreibt per settlement_number dieselbe Abrechnung
> (Run 477). Falls doch Yanniks Einschätzung gewünscht: zurück zu den
> offenen Fragen.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

## 4. Beleg-Foto

### 4.1 Perspektivische Ausrichtung

✅ beantwortet

**Frage:** Muss das Belegfoto perspektivisch entzerrt werden?

> **Antwort:** Nein, muss nur lesbar sein.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 4.2 Feld und Format für das Belegfoto

✅ beantwortet

**Frage:** In welchem Feld und Format wird das Belegfoto übertragen?

> **Antwort:** base64 direkt im JSON, Feldname frei wählbar (z. B.
> `beleg_foto_base64`). Keine maximale Dateigröße (Yannik, 26.08.).

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 4.3 Prüfen-Flag für die Buchhaltung

✅ beantwortet

**Frage:** Braucht es eine eigene Prüfmarkierung oder einen Dev-Button?

> **Antwort:** Nein, läuft über das Kommentarfeld (2.3).

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

## 5. Sonstiges

### 5.1 Mailversand

– entfällt

**Frage:** Soll die App Mails verschicken?

> **Antwort (Paco, 26.08.):** Nein. Auch kein Mail-Fallback bei
> Korrektur, 4×-Limit oder FC-Ausfall.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 5.2 Stapelscanner

✅ beantwortet

**Frage:** Wird ein Stapelscanner für zurückliegende Belege gebraucht?

> **Antwort:** Nein.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)

---

### 5.3a Prüfung nach Verbindungsabbruch

– zurückgestellt (WLAN-Teil weiter offen, siehe 5.3)

**Frage:** Können wir nachträglich bei euch prüfen, ob eine Abrechnung
angekommen ist, wenn die Verbindung mittendrin abbricht?

> **Antwort (Paco, 30.09.):** Zurückgestellt. Betrifft nur „Abrechnung
> angekommen, Antwort verloren“. Folge ist höchstens ein Duplikat bei FC
> (löschbar außer Nr. 1). Erst nachfragen, wenn Duplikate in der Praxis
> auffallen.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-22)
