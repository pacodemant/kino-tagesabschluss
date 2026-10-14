# Fragen an Yannik

Stand: 14.10.2026 (Termin nach drei Wochen Pause) · zentrale Tracking-Datei
für alle Fragen an Yannik: Flurbocash-Anbindung, Projektplanung, Vergütung
und Persönliches. Wird laufend ergänzt, sobald Antworten reinkommen oder
neue Fragen auftauchen.

Aufbau: Oben die **Agenda** (alle offenen Fragen, eine Zeile pro Frage, nach
Gesprächsreihenfolge sortiert), darunter die **Details zu den offenen
Punkten**, ganz unten das **Archiv** der erledigten Punkte (einzeilig). Die
Nummern (1.2, 3.1 …) bleiben stabil, weil TODO.md, PROJECT_CONTEXT.md und
CHANGELOG.md darauf verweisen. Die ausführlichen alten Fassungen erledigter
Punkte stehen im Git-Verlauf (zuletzt vollständig in Run 484).

⏳ offen · ◐ teilweise geklärt · ✅ beantwortet · – entfällt/zurückgestellt

---

## Agenda 14.10.2026

**A. Projektplanung** *(neu)*

- ⏳ [7.1](#71-deadline) Wollen wir eine Deadline benennen?
- ⏳ [7.2](#72-reihenfolge-der-standorte) Nächste Schritte: erst CO und AT, dann GO, dann BT?

**B. Ausfälle im Betrieb** *(neu)*

- ⏳ [8.1](#81-ki-für-beleg-scan-offline) Was soll die App tun, wenn die KI für den Beleg-Scan offline ist?
- ⏳ [8.2](#82-flurbocash-nicht-erreichbar) Was soll passieren, wenn FC down ist und die Abrechnung nicht gesendet werden kann?
- ⏳ [3.3](#33-verhalten-bei-maximum-reached-4-limit) Was soll passieren, wenn das Limit von 4 Abrechnungen pro Tag erreicht ist?

**C. Terminals & Standortdaten**

- ⏳ [1.2](#12-terminal-ids-pro-standort) Sind die neuen TIDs bei FC hinterlegt, wann fallen die alten weg, und welche TID hat GO?
- ⏳ [1.9](#19-terminal-nummern-fest-mit-tids-koppeln) Die Terminals haben neben der TID eigene Nummern. Koppeln wir die fest mit den TIDs? *(neu)*
- ⏳ [2.7](#27-sb-sonderfall-kartenumsatz-zum-kino-soll-addieren) SB-Sonderfall: Kartenumsatz des angeschlossenen Terminals zum Kino-SOLL addieren — bleibt das so? *(neu)*
- ◐ [1.3](#13-standort-kennung-location_id) Welche location_id haben GO und CO?
- ⏳ [5.3](#53-wlan-für-den-kassenbetrieb) Welches WLAN ist an den einzelnen Standorten für die Kasse freigegeben?

**D. Server & Schnittstelle**

- ◐ [1.8](#18-app-hosting-auf-kino-server-statt-github-pages) Kann die App jetzt auf den Kino-Server umziehen?
- ◐ [2.4](#24-empfangsbestätigung) Ist eure Antwort eine verlässliche Empfangsbestätigung?
- ◐ [3.1](#31-leseweg-für-belegte-settlement_numbers) Gibt es eine Abfrage, welche settlement_numbers für einen Tag schon belegt sind? *(niedrige Priorität)*

**E. Vergütung & Persönliches**

- ⏳ [6.1](#61-vergütung-yannik-höhemodell) Wie hoch soll die Vergütung sein, und nach welchem Modell?
- ◐ [6.2](#62-risiko-scheinselbständigkeit) Besteht ein Risiko der Scheinselbständigkeit? (Steuerbüro)
- ⏳ [6.3](#63-vorschuss) Ich brauche wieder einen Vorschuss. *(neu)*
- ⏳ [6.4](#64-kaffee-flat-in-der-bt) Kaffee-Flat, während ich in der BT an der App arbeite? *(neu)*

---

## Details zu den offenen Punkten

### 1.2 Terminal-IDs pro Standort

**Status:** offen

**Fragen:**

1. Sind die neuen TIDs bei FC korrekt hinterlegt?
2. Wann können die alten TIDs entfernt werden?
3. Welche TID hat GO? (In der App steht dort noch der Platzhalter "XXXX".)

**Stand App (config/terminal_ids.json):** Alte und neue TIDs gelten
während der Umstellung parallel. Keine davon ist bisher von Yannik
bestätigt, alles nur von den Geräten abgelesen.

| Standort | alte TID           | neue TID                     |
|----------|--------------------|------------------------------|
| SB       | 54017635           | 60561994, 60561996, 60561997 |
| AT       | 54069464           | 60561998                     |
| CO       | 54017639           | 60561995                     |
| BT       | 54069493, 54017664 | 60561992, 60561993           |
| GO       | –                  | – (fehlt)                    |

Hintergrund SB (07.09.): Die neuen Terminals können vorerst nur Girocard,
Kreditkarte läuft weiter über das alte Terminal. Davon hängt auch die
geplante Prüfung "alle erwarteten Terminal-Belege gescannt?" ab (TODO.md,
zurückgestellt), siehe auch 1.9 und 2.7.

[↑ zur Agenda](#agenda-14102026)

---

### 1.3 Standort-Kennung (location_id)

**Status:** teilweise geklärt
**Bekannt (Mail Yannik, 12.07.):** SB = 1, AT = 3, BT = 4.
**Offen:** location_id für GO und CO. Yannik wollte sie per Mail
nachschicken (Stand 26.08.), bisher nicht angekommen.

[↑ zur Agenda](#agenda-14102026)

---

### 1.8 App-Hosting auf Kino-Server (statt GitHub Pages)

**Status:** teilweise geklärt
Die App läuft als PWA über GitHub Pages (Pacos privater Account). Infos an
Yannik am 01.09.: SFTP-Upload in einen Ordner, alte Dateien werden ersetzt,
HTTPS ist Pflicht; lokal generalprobt.

**Frage:** Hast du dir das angeschaut? Ist der Umzug jetzt möglich, und
habe ich dann selbst Zugriff für Updates?

**Was du vor dem ersten Upload brauchst bzw. beachten musst (30.09.):**

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

**Zur Info (Paco-Aufgabe):** Durch die neue Adresse ist der Speicher der
App getrennt. Alle Handys müssen die App neu installieren und neu
einrichten (API-Key, TIDs, Verlauf weg). Vorher sicherstellen, dass alle
Abrechnungen bestätigt gesendet sind.

[↑ zur Agenda](#agenda-14102026)

---

### 1.9 Terminal-Nummern fest mit TIDs koppeln

**Status:** offen *(neu, 14.10.)*
Die Terminals haben neben der TID noch eine eigene Gerätenummer. Wollen wir
diese fest mit den TIDs koppeln?

**Wofür das gut wäre:** Die MA kennt das Gerät eher an seiner Nummer als an
der achtstelligen TID. Die App könnte dann z. B. "Terminal 2 (TID …)"
anzeigen, und ein Hinweis wie "Beleg von Terminal 3 fehlt noch" wäre für
die MA verständlich.

**Klären:** Sind die Nummern dauerhaft fest an die Geräte vergeben (auch
bei Tausch/Reparatur)? Wer pflegt die Zuordnung, wenn sich etwas ändert?

[↑ zur Agenda](#agenda-14102026)

---

### 2.4 Empfangsbestätigung

**Status:** teilweise geklärt
Die App wertet eure Antwort auf PUT settlements als Empfangsbestätigung:
Erst bei 2xx zeigt sie "gesendet", und sie merkt sich die settlement_number
aus der Antwort, damit eine spätere Korrektur die richtige Abrechnung
überschreibt (seit Run 477).

**Bitte bestätigen:**

- (a) 2xx kommt erst, wenn die Abrechnung wirklich gespeichert ist, nicht
  schon beim Eingang?
- (b) Die Antwort ist immer JSON und enthält die vergebene
  settlement_number an der jetzigen Stelle
  (`settlements[0].settlement_number`)? In der Sandbox ist das seit 24.09.
  so.

Falls sich daran später etwas ändert, bitte vorher Bescheid geben, sonst
gehen Korrekturen unbemerkt ins Leere. (Fehlt die Nummer, gilt die
Abrechnung trotzdem als gesendet, die MA bekommt aber einen Hinweis, eine
Korrektur mit der IT abzustimmen — seit Run 480.)

[↑ zur Agenda](#agenda-14102026)

---

### 2.7 SB-Sonderfall: Kartenumsatz zum Kino-SOLL addieren

**Status:** offen *(neu, 14.10.)*
Eines der drei neuen SB-Terminals hat Yannik direkt ans Kinokassen-System
angeschlossen, sodass man den Betrag nicht mehr eintippen muss. Seitdem
muss man den Kartenumsatz dieses Terminals und den Kinokarten-Umsatz
addieren und das Ergebnis als Kino-SOLL in die App bzw. auf den Umschlag
eintragen. Warum, ist mir nicht klar.

**Fragen:**

1. Warum ist das so?
2. Ist das ein vorübergehender Workaround, bis das behoben ist, oder
   bleibt das dauerhaft?
3. Falls dauerhaft: Soll die App das selbst rechnen (Kartenumsatz des
   angeschlossenen Terminals aus dem Beleg-Scan automatisch zum Kino-SOLL
   addieren)? Dann bräuchte ich die TID des angeschlossenen Terminals.
4. Kommen weitere angeschlossene Terminals dazu (andere Standorte)?

[↑ zur Agenda](#agenda-14102026)

---

### 3.1 Leseweg für belegte settlement_numbers

**Status:** teilweise geklärt — für den Regelfall gelöst, Rest niedrige
Priorität
**Stand:** FC liefert die vergebene settlement_number in der PUT-Antwort.
Die App merkt sich die Nummer pro Kino und Abrechnungstag und schickt sie
bei jedem weiteren Versand dieses Tages mit (Run 477). Korrekturen
überschreiben damit die richtige Abrechnung.

**Verbleibende Frage:** Gibt es (oder plant ihr) eine Möglichkeit, VOR dem
Senden abzufragen, welche settlement_numbers für einen Tag schon belegt
sind? Nur relevant, wenn die App ihren lokalen Merker verloren hat
(Datenverlust, Korrektur von einem anderen Gerät, Neuinstallation beim
Server-Umzug 1.8).
Vorher selbst prüfen (Dev-Modus "Server-Antwort anzeigen", seit Run 476),
ob die ensure-Antwort die vorhandenen Settlements schon mitliefert — dann
erübrigt sich die Frage.

**Alternative, falls kein Leseweg möglich:** Ein Flag wie
`overwrite_last: true`, mit dem FC selbst die zuletzt eingereichte
Abrechnung des Tages überschreibt, ohne dass die App die Nummer kennen
muss. Laut Doku derzeit nicht vorgesehen.

[↑ zur Agenda](#agenda-14102026)

---

### 3.3 Verhalten bei "maximum reached" (4×-Limit)

**Status:** offen
Ab der 5. Abrechnung pro Tag antwortet FC mit `400` "maximum of 4
settlements per day reached". Ein Mailversand ist nicht vorgesehen (5.1).
Praktisch relevant v. a. für BT (zwei Abrechnungen pro Tag plus
Korrekturen).

**Frage:** Was soll die MA in dem Fall tun? Z. B. Hinweis in der App
"Bitte Büro/IT informieren", oder löscht FC/die Buchhaltung dann eine
Abrechnung? (Abrechnungen lassen sich in FC löschen, außer Nr. 1.)

[↑ zur Agenda](#agenda-14102026)

---

### 5.3 WLAN für den Kassenbetrieb

**Status:** offen
Das Gäste-WLAN sperrt den Kassen-Port (666) und wird für den Kassenbetrieb
nicht genutzt. Welches WLAN ist an den einzelnen Standorten (SB, GO, AT,
CO, BT) für den Flurbocash-Zugriff vorgesehen bzw. freigegeben? Hängt mit
1.8 zusammen (App-Adresse muss aus diesem WLAN erreichbar sein).

(Der zweite Teil von 5.3, die nachträgliche Prüfung nach einem
Verbindungsabbruch, ist zurückgestellt, siehe Archiv.)

[↑ zur Agenda](#agenda-14102026)

---

### 6.1 Vergütung Yannik (Höhe/Modell)

**Status:** offen — beim Termin aktiv ansprechen, nicht nur beiläufig
**Vorschlag Paco:** Vergütung am Einsparpotential orientieren, das die App
gegenüber der bisherigen Abrechnungsweise bringt. Um nicht auf Schätzungen
angewiesen zu sein: alte und neue Abrechnungsweise per Stoppuhr
vergleichen.
**Notiz:** Direkt an Yannik gerichtet — er ist nicht nur IT, sondern auch
Chef-Sohn und Nachfolger.

[↑ zur Agenda](#agenda-14102026)

---

### 6.2 Risiko Scheinselbständigkeit

**Status:** teilweise geklärt — beim Termin nachfassen
**Stand:** Tom sagt: kein Problem. Trotzdem vom Steuerbüro beurteilen
lassen — noch nicht passiert. Hat Yannik das Steuerbüro inzwischen
gefragt?

[↑ zur Agenda](#agenda-14102026)

---

### 6.3 Vorschuss

**Status:** offen *(neu, 14.10.)*
Ich brauche wieder einen Vorschuss. Vorher klären: Höhe und ggf. ab wann,
und wie er mit der Vergütung (6.1) verrechnet wird.

[↑ zur Agenda](#agenda-14102026)

---

### 6.4 Kaffee-Flat in der BT

**Status:** offen *(neu, 14.10.)*
Ist eine Kaffee-Flat möglich, während ich in der BT an der App arbeite?

[↑ zur Agenda](#agenda-14102026)

---

### 7.1 Deadline

**Status:** offen *(neu, 14.10.)*
Wollen wir eine Deadline benennen? Falls ja: für was genau — Produktivstart
aller Standorte, oder je Standort (Umstieg erfolgt je Standort, siehe 1.1
im Archiv)? Hängt an Punkten, die nicht in Pacos Hand liegen (TIDs und
location_ids 1.2/1.3, Server-Umzug 1.8).

[↑ zur Agenda](#agenda-14102026)

---

### 7.2 Reihenfolge der Standorte

**Status:** offen *(neu, 14.10.)*
Vorschlag für die nächsten Schritte: erst CO und AT, dann GO, dann BT? (SB
läuft bereits im Testbetrieb.)

**Gründe für diese Reihenfolge, zum Gegenprüfen:**

- GO: TID und location_id fehlen noch komplett (1.2/1.3).
- BT: Sonderfall mit zwei Abrechnungen pro Tag (Mittag + Tagesende),
  stößt am ehesten an das 4×-Limit (3.3).
- CO: location_id fehlt noch (1.3).

[↑ zur Agenda](#agenda-14102026)

---

### 8.1 KI für Beleg-Scan offline

**Status:** offen *(neu, 14.10.)*
Der KI-Dienst für den Beleg-Scan ist leider nicht selten nicht erreichbar.
Was soll die App dann tun?

**Aktuell:** Die App zeigt die Fehlermeldung und den Hinweis "Beleg kann
auch manuell eingegeben werden." Die MA tippt die Werte dann selbst ab.

**Fragen:**

1. Reicht die manuelle Eingabe als Notlösung, oder ist das für die
   Buchhaltung zu fehleranfällig?
2. Soll die App eine Abrechnung mit manuell eingetragenen Belegdaten
   für die Buchhaltung kennzeichnen (z. B. im Kommentarfeld, wie "test"
   bei 2.4)?
3. Wäre ein zweiter KI-Anbieter als Ausweichlösung gewünscht? Hängt mit
   dem geplanten eigenen Anthropic-Account des Kinos zusammen.

[↑ zur Agenda](#agenda-14102026)

---

### 8.2 Flurbocash nicht erreichbar

**Status:** offen *(neu, 14.10.)*
Was soll passieren, wenn FC down ist und die Abrechnung nicht gesendet
werden kann?

**Aktuell:** Die App zeigt eine Fehlermeldung. Die Abrechnung bleibt
lokal gespeichert, steht im Verlauf als "nicht gesendet", und die MA kann
später erneut senden (seit Run 448 zuverlässig). Ein Mailversand als
Ausweichweg ist nicht vorgesehen (5.1).

**Fragen:**

1. Reicht "später erneut senden"? Wer kümmert sich darum, wenn die MA
   nach Schichtende nach Hause geht — die nächste Schicht, das Büro?
2. Wie lange darf eine Abrechnung nachträglich ankommen, bevor FC den Tag
   als `finalized` markiert (dann keine Schreibzugriffe mehr)?
3. Reicht der Umschlag als Papier-Nachweis, bis die Abrechnung
   nachgesendet ist, oder braucht es mehr?

[↑ zur Agenda](#agenda-14102026)

---

## Archiv: erledigt, entfallen, zurückgestellt

**1. Zugangsdaten & Einrichtung**

- ✅ **1.1** Produktivbetrieb pro Standort oder alle gleichzeitig? → Je
  Standort. Eigene Produktiv-URL von Yannik, Umstieg nach erfolgreichen
  Tests (SB).
- ✅ **1.4** Passwort Schauburg-AP → Keine formelle Frage mehr, Paco klärt
  vor Ort bzw. per Messenger.
- ✅ **1.5** Wer richtet die Geräte ein? → Paco, initial an den Standorten.
- ✅ **1.6** Konfiguration zentral oder je Gerät? → Am Gerät vor Ort.
- ✅ **1.7** Android-Testgerät? → Yannik kauft eins.

**2. Abrechnungsdaten & Format**

- ✅ **2.1** Zwei EC-Belege desselben Terminals? → Jeder Beleg als eigener
  `terminals[]`-Eintrag, FC verarbeitet das korrekt. Umgesetzt (Run 399a3).
- ✅ **2.2** Weitere Daten nötig? → Nein. FC holt die Kassenumsätze selbst,
  die App schickt nur `terminals[]` und `cash_total`. Kino-/Bistro-SOLL,
  Ausgaben und Differenz werden nicht gebraucht.
- ✅ **2.3** Notizen, MA-Name, Sendezeitpunkt mitschicken? → Ja. Eigene
  JSON-Felder sind generell erlaubt (Namen frei wählbar) und werden
  ignoriert, bis FC sie implementiert.
- ✅ **2.4 (Testkennzeichnung)** Tests im Dashboard markieren? → Keine
  Farbmarkierung, stattdessen "test" ins Kommentarfeld. Server-Zeitstempel
  entfällt, die App schickt selbst `sent_at`. (Empfangsbestätigung siehe
  2.4 oben, noch offen.)
- ✅ **2.5** Buchhaltung hat SB-Testübertragungen geprüft? → Stand 26.08.
  noch nicht getestet; als Frage abgeschlossen.
- ✅ **2.6** Datum für Nachtabrechnungen? → Logisches Geschäftsdatum,
  Tageswechsel um 5 Uhr (nicht 6). In der App umgestellt.

**3. Korrektur & Duplikate**

- ✅ **3.1 Mechanismus** → settlement_number weglassen = neue Abrechnung,
  1–4 = bestehende überschreiben. FC liefert die Nummer in der
  PUT-Antwort, die App nutzt sie seit Run 477.
- – **3.1 Dashboard-Sicht (Fragen 1/2)** Sieht die Buchhaltung, ob eine
  Abrechnung korrigiert wurde? → Nur zur Info an FC, keine
  App-Abhängigkeit. Die App schickt settlement_number und `sent_at`, die
  Anzeige entscheidet FC.
- – **3.1 finalized (Frage 4)** → Zurückgestellt (30.09.): Korrekturen
  kommen am selben Abend, die App erkennt `finalized: true` bzw. die 400
  selbst. Taucht im Ausfall-Kontext wieder auf, siehe 8.2.
- – **3.2** Schutz vor versehentlicher Doppel-Übertragung → App-seitig
  gelöst: Die App erkennt anhand der Sende-Signatur, dass schon gesendet
  wurde, und zeigt den Dialog "Du hast die Abrechnung bereits gesendet"
  (Hinweis ergänzt in Run 482). Ein erneuter Versand überschreibt per
  settlement_number dieselbe Abrechnung (Run 477), statt eine neue
  anzulegen. *(Beim Aufräumen am 14.10. ins Archiv verschoben — falls doch
  Yanniks Einschätzung gewünscht, zurück in die Agenda.)*

**4. Beleg-Foto**

- ✅ **4.1** Perspektivisch entzerren? → Nein, muss nur lesbar sein.
- ✅ **4.2** Feld/Format für das Belegfoto? → base64 direkt im JSON,
  Feldname frei wählbar, keine maximale Dateigröße.
- ✅ **4.3** Eigenes Prüfen-Flag oder Dev-Button? → Nein, läuft über das
  Kommentarfeld (2.3).

**5. Sonstiges**

- – **5.1** Mailversand? → Entfällt (Paco-Entscheidung 26.08.). Auch kein
  Mail-Fallback bei Korrektur, 4×-Limit oder FC-Ausfall.
- ✅ **5.2** Stapelscanner für alte Belege? → Nicht benötigt.
- – **5.3 Prüfung nach Verbindungsabbruch** → Zurückgestellt (30.09.):
  Betrifft nur "Abrechnung angekommen, Antwort verloren". Folge ist
  höchstens ein Duplikat bei FC (löschbar außer Nr. 1). Erst nachfragen,
  wenn Duplikate in der Praxis auffallen. (WLAN-Teil weiter offen, siehe
  5.3 oben.)
