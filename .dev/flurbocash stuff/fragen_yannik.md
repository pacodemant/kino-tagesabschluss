# Fragen an Yannik

Stand: 14.10.2026 (Run 485d) · zentrale Tracking-Datei für alle Fragen an Yannik:
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

## Inhalt: Offene Fragen (24)

In Gesprächsreihenfolge für den Termin am 14.10.2026.

**A. Projektplanung**

- ⏳ [7.1 Wollen wir eine Deadline benennen?](#71-deadline) *(neu)*
- ⏳ [7.2 Nächste Schritte: erst CO und AT, dann GO, dann BT?](#72-reihenfolge-der-standorte) *(neu)*
- ⏳ [7.3 Wer schult die MA, wer ist vor Ort Ansprechpartner?](#73-einführung-schulung-und-ansprechpartner) *(neu)*
- ⏳ [7.4 Wie soll die App heißen?](#74-name-der-app) *(neu)*

**B. Ausfälle im Betrieb**

- ⏳ [8.1 Was soll die App tun, wenn die KI für den Beleg-Scan offline ist?](#81-ki-für-beleg-scan-offline) *(neu)*
- ⏳ [8.2 Was soll passieren, wenn FC down ist und nicht gesendet werden kann?](#82-flurbocash-nicht-erreichbar) *(neu)*
- ⏳ [3.3 Was soll passieren, wenn das 4×-Limit pro Tag erreicht ist?](#33-verhalten-bei-maximum-reached-4-limit)

**C. Terminals & Standortdaten**

- ⏳ [1.9 Terminal-Nummern fest mit den TIDs koppeln?](#19-terminal-nummern-fest-mit-tids-koppeln) *(neu)*
- ⏳ [2.7 SB: Kartenumsatz zum Kino-SOLL addieren — bleibt das so?](#27-sb-sonderfall-kartenumsatz-zum-kino-soll-addieren) *(neu)*
- ⏳ [1.10 Wie lauten die Live-location_ids und Live-Keys für SB, AT und BT?](#110-live-zugangsdaten-für-sb-at-bt) *(neu)*
- ⏳ [2.11 Wie erscheinen Stornos am Terminal auf dem Kassenschnitt?](#211-storno-am-terminal) *(aus 21.06.)*
- ⏳ [1.11 Android-Testgerät da? Bessere Kameras für die Kassen-Handys?](#111-geräte-an-den-kassen-kamera-android-testgerät) *(neu)*
- ◐ [5.3 Welches WLAN ist an GO, AT, CO, BT für die Kasse freigegeben?](#53-wlan-für-den-kassenbetrieb)

**D. Server & Schnittstelle**

- ◐ [1.8 Kann die App jetzt auf den Kino-Server umziehen?](#18-app-hosting-auf-kino-server-statt-github-pages)
- ⏳ [2.8 Foto-Archivierung scheitert: 500 ohne Nummer — erst archivieren oder so lassen?](#28-belegfoto-archivierung-scheitert-500-ohne-nummer) *(neu)*
- ⏳ [2.1 Nur ein Eintrag pro TID — wie gehen mehrere Kassenschnitte und Fotos mit?](#21-zwei-ec-belege-am-selben-terminal) **dringend**
- ⏳ [2.10 BT: zwei Abrechnungen pro Tag — Nr. 1 und 2, Kassenschnitt zurückgesetzt?](#210-bt-zwei-abrechnungen-pro-tag) *(neu)*
- ⏳ [2.9 Trinkgeld auf dem Kassenschnitt — Missverständnis?](#29-trinkgeld-auf-dem-kassenschnitt) *(neu)*
- ◐ [3.1 Abfrage, welche settlement_numbers schon belegt sind?](#31-leseweg-für-belegte-settlement_numbers) *(niedrige Priorität)*

**E. Vergütung & Persönliches**

- ⏳ [6.1 Wie hoch soll die Vergütung sein, nach welchem Modell?](#61-vergütung-yannik-höhemodell)
- ◐ [6.2 Besteht ein Risiko der Scheinselbständigkeit?](#62-risiko-scheinselbständigkeit)
- ⏳ [6.3 Ich brauche wieder einen Vorschuss.](#63-vorschuss) *(neu)*
- ⏳ [6.4 Kaffee-Flat, während ich in der BT an der App arbeite?](#64-kaffee-flat-in-der-bt) *(neu)*
- ⏳ [6.5 Wer bekommt Zugriff auf Code und Repository, wenn ich ausfalle?](#65-übergabe-und-ausfallsicherheit) *(neu)*

## Inhalt: Beantwortete Fragen (23)

**1. Zugangsdaten & Einrichtungpacodemant@icloud.com**

- ✅ [1.1 Produktivbetrieb pro Standort oder alle gleichzeitig?](#11-umstieg-auf-produktivbetrieb)
- ✅ [1.2 Neue TIDs bei FC hinterlegt, TID für GO?](#12-terminal-ids-pro-standort)
- ✅ [1.3 Welche location_id haben GO und CO?](#13-standort-kennung-location_id)
- ✅ [1.4 Passwort Schauburg-AP?](#14-passwort-schauburg-ap)
- ✅ [1.5 Wer richtet die Geräte ein und pflegt sie?](#15-geräte-einrichtung--pflege)
- ✅ [1.6 Konfiguration zentral oder je Gerät?](#16-konfiguration-zentral-oder-je-gerät)
- ✅ [1.7 Wer besorgt ein Android-Testgerät?](#17-android-testgerät)

**2. Abrechnungsdaten & Format**

- ✅ [2.2 Braucht FC außer Kartenumsätzen und Bargeld weitere Daten?](#22-weitere-daten-gewünscht)
- ✅ [2.3 Dürfen Notizen, MA-Name und Sendezeitpunkt mitgeschickt werden?](#23-notizen-ma-name-sendezeitpunkt)
- ✅ [2.4 Ist eure Antwort eine verlässliche Empfangsbestätigung?](#24-empfangsbestätigung)
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

### 1.10 Live-Zugangsdaten für SB, AT, BT

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Die location_id ist nicht in Sandbox und Livesystem
gleich (laut Yannik nicht mehr einfach änderbar). Stand aller Standorte
(**?** = fehlt noch):


| Standort | Sandbox-ID      | Live-ID | Live-Key |
| -------- | --------------- | ------- | -------- |
| SB       | 1               | **?**   | **?**    |
| AT       | 3               | **?**   | **?**    |
| BT       | 4               | **?**   | **?**    |
| GO       | 5               | 3       | **?**    |
| CO       | 6               | 5       | **?**    |

Quellen: SB/AT/BT aus der Mail vom 16.06. (Sandbox-Zugang, nur Sandbox-
IDs; AT kann live nicht die 3 sein, die hat dort GO), GO/CO aus der Mail
vom 08.10. Die Sandbox-Keys stehen in secrets/api_keys.txt
(nicht im Git).

Seit Run 493 stehen die bekannten IDs im Code (kino.dart), ein Schalter
"Livesystem" wählt die Umgebung, das Einstellungsfeld ist Override je
Umgebung. Fehlende Live-IDs (SB/AT/BT) blockieren den Versand, bis sie
im Code oder als Override stehen.

**Frage:**

1. Wie lauten die Live-location_ids für SB, AT und BT?
2. Gibt es für das Livesystem eigene API-Keys pro Standort, und eine
   eigene URL (1.1)?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 1.11 Geräte an den Kassen (Kamera, Android-Testgerät)

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Die Fotos der Tickethandys sind deutlich schlechter als
vom iPhone (meine Mail 10.09.); Yannik (02.10.): „Die Lichtempfindlichkeit
der Kamera ist totaler Scheiß. Wenn das Bild nicht gut ausgeleuchtet ist,
ist die Qualität Mist.“ Das Android-Testgerät wollte Yannik kaufen (1.7).

**Frage:**

1. Ist das Android-Testgerät inzwischen da?
2. Gibt es Pläne, die Kassen-Handys zu ersetzen? Falls ja: auf die
   Kamera achten (Lichtempfindlichkeit, Schärfe bei Nahaufnahmen).
3. Alternativ: Licht an der Kasse verbessern (Lampe beim Fotografieren)?

> **Antwort:** *nualität der Belege genügt, ignorieren.*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

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

> **Antwort (Mail Yannik, 02.10.):** Lieber kein SFTP („kein Loch in
> meine Firewall“). Zwei Vorschläge, Schnittstelle jeweils GitHub:
> (a) Release als GitHub-Release (lokal oder per CI gebaut), sein Server
> holt sich nachts automatisch neue Versionen; (b) CI baut ein
> Container-Image, er startet es per podman. HTTPS über Caddy ist kein
> Problem. Adresse frei wählbar: `[appname].c137-prime.de`.
>
> *Noch offen (Paco):* Variante wählen — (a) liegt am nächsten am
> bisherigen manuellen Ablauf (lokal bauen, nur hochladen) — und den
> App-Namen festlegen. Rückfragen an Yannik: Kommt ein dringendes Update
> bei „nachts“ erst am Folgetag an, oder geht es auch sofort? Wird CORS
> für die neue Adresse ergänzt?

[↑ zum Inhalt](#inhalt-offene-fragen-24)

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

> **Antwort:** *nein*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

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

> **Antwort:** *in App einbauen, Terminal an der Kasse nur für Kinotickets & Co., nicht für Bistro, keine manuelle Eingabe an diesem Gerät möglich.*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 2.1 Zwei EC-Belege am selben Terminal

⏳ offen — **dringend**, möglicher Datenverlust *(14.10.)*

**Hintergrund:** Gemeint sind zwei Kassenschnitte desselben Terminals
(gleiche TID) innerhalb derselben Abrechnung. Die App schickt sie seit
Run 399a3 als zwei getrennte `terminals[]`-Einträge mit gleicher TID.

- 26.08. (Termin): „Jeder Beleg als eigener Datensatz“, FC verarbeitet das
  korrekt.
- 27.08. (meine Mail): „Kann es sein, dass FC bei mehreren EC-Belegen mit
  gleicher TID die ersten durch den jeweils letzten im JSON ersetzt? Ich
  sehe im Dashboard immer nur einen Beleg.“
- 27.08. (Yannik, Antwort darauf): „Pro TID und Settlement kann es nur
  einen Kassenschnitt geben.“ Dazu bat er um zwei JSONs; was er damit
  meinte, konnte er am 08.09. nicht mehr sagen.

Damit ist ziemlich sicher: FC behält pro TID nur den letzten Eintrag, die
Beträge der vorherigen Kassenschnitte derselben TID gehen verloren. Die
App schickt seit Run 399a3 trotzdem getrennte Einträge (TODO.md, Punkt
„Mehrere Kassenschnitte gleicher TID“).

**Vorab selbst prüfbar:** Mit dem Sandbox-Zugang zum FC-Webinterface (Mail
16.06., Zugangsdaten dort) und dem Kassenschnitt-Button in der FC-Oberfläche
(Mail 08.09.) lässt sich testen: eine Abrechnung mit zwei Belegen gleicher
TID senden und nachsehen, ob FC beide Beträge und beide Fotos speichert.
Dann ist die Frage womöglich schon vor dem Termin beantwortet.

**Frage:**

1. Bestätigst du: pro TID und Abrechnung nur ein Eintrag?
2. Dann summiert die App die Beträge mehrerer Kassenschnitte derselben TID
   zu einem Eintrag. Wie sollen dann die mehreren Belegfotos mitgehen —
   als Liste in einem Eintrag (z. B. `receipt_photos: [...]`), oder reicht
   eins?
3. Wann kommt das in der Praxis vor (z. B. Zwischenschnitt am Terminal,
   Terminal-Neustart), und soll die MA das überhaupt so machen?

> **Antwort:** *ignorieren, kommt zu selten vor*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 2.8 Belegfoto-Archivierung scheitert (500 ohne Nummer)

⏳ offen *(neu, aus Mail 02.10.)*

**Hintergrund (Yannik, 02.10.):** Werden die Werte gespeichert, aber die
Archivierung des Belegfotos scheitert, antwortet FC mit 500 „settlement
data was saved, but archiving the receipt photo … failed“ — ohne
settlement_number. Yannik bietet zwei Optionen an:

1. Reihenfolge umdrehen: erst archivieren, dann speichern. Eine 500
   bedeutet dann immer „nichts gespeichert“.
2. So lassen: Die Werte sind sicher, das Foto trägt das Büro nach.

**Was die App heute macht (Code geprüft):** Jede 500 gilt als Fehlschlag
(„Serverfehler bei Flurbocash. Bitte später erneut versuchen.“,
api_upload_service.dart:639), es wird keine Nummer gemerkt. Beim
Erstversand des Tages schickt die MA dann erneut — ohne Nummer — und FC
legt eine **zweite Abrechnung** an. Scheitert das Foto wiederholt, kommt
pro Versuch eine weitere dazu, bis das 4×-Limit greift (3.3). Bei einer
Korrektur (Nummer bekannt) ist es harmlos, dort wird überschrieben.

**Frage:** Option 1 oder 2? Aus App-Sicht ist Option 1 am einfachsten:
erneutes Senden ist dann immer sicher, die App muss nichts ändern.
Option 2 geht nur, wenn FC auch in diesem Fall die settlement_number
mitschickt (oder einen eigenen Statuscode), damit die App „Werte gesendet,
Foto fehlt“ erkennen und sich die Nummer merken kann.

> **Antwort:** *option 1*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 2.9 Trinkgeld auf dem Kassenschnitt

⏳ offen *(neu, aus Mail 02.10.)*

**Hintergrund:** Ich hatte geschrieben: „Trinkgelder auf dem
Kassenschnitt kann die App jetzt auch.“ Yannik: „Auf dem Kassenschnitt
dürften keine Trinkgelder auftauchen. o.O“
Gemeint war Run 452: Die neuen Terminals erlauben eine Trinkgeld-Eingabe
per Karte, das Trinkgeld steht dann als eigener Posten auf dem
Kassenschnitt. Die App erkennt es beim Scan und zeigt es nur an. Es
fließt nicht in Schritt 2 und wird nicht an FC geschickt.

**Frage:** Wie möchtest du Trinkgeld per Karte haben?

1. **Grundsatz:** Sollen Gäste an den Terminals überhaupt Trinkgeld per
   Karte geben können?
   - Falls **nein:** Wer schaltet die Trinkgeld-Abfrage an den neuen
     Terminals ab, und an welchen Standorten ist sie aktiv?
   - Falls **ja:** weiter mit 2–4.
2. **Auszahlung:** Wie kommt das Kartentrinkgeld zum Team — abends bar aus
   der Kasse, oder später über die Lohnabrechnung? Bei Barauszahlung fehlt
   der Betrag im gezählten Bargeld; die App müsste ihn dann als Entnahme
   kennen, sonst entsteht eine Differenz.
3. **Flurbocash:** Sollen die Kartenbeträge an FC so gehen, wie sie auf dem
   Kassenschnitt stehen, oder ohne Trinkgeld? Soll das Trinkgeld als
   eigenes Feld mitgehen (z. B. `tip_total`)?
4. **Kassen-SOLL:** Trinkgeld ist kein Umsatz der Kasse. Ist dir das bei
   deinem Abgleich Kartenumsatz gegen Kassensystem schon aufgefallen, bzw.
   wie soll eine solche Abweichung erklärt werden?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 2.10 BT: zwei Abrechnungen pro Tag

⏳ offen *(neu, 14.10.)*

**Hintergrund:** In der BT wird mittags und am Tagesende abgerechnet, an
denselben Terminals. Geplant ist: Mittag = FC-Abrechnung Nr. 1, Tagesende
= nächste Nummer. Hängt an 2.1 (nur ein Eintrag pro TID und Abrechnung)
und 3.3 (4×-Limit).

**Frage:**

1. Passt das so: zwei getrennte Abrechnungen pro Tag (Nr. 1 und 2)?
2. Enthält der Kassenschnitt am Tagesende nur die Umsätze seit Mittag
   (Terminal-Kassenschnitt setzt zurück)? Sonst würden die Mittagsumsätze
   doppelt gezählt.
3. Bargeld: Wird mittags das Bargeld komplett abgerechnet, und abends nur
   der Rest seitdem?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 2.11 Storno am Terminal

⏳ offen *(aus meiner Mail 21.06., Antwort nicht dokumentiert)*

**Hintergrund:** Am Terminal kann man stornieren, z. B. wenn
versehentlich 1,20 statt 12,00 € eingegeben wurde. Die Frage hatte ich am
21.06. gestellt; eine Antwort ist nicht überliefert (evtl. mündlich).

**Frage:** Wie erscheinen Stornos auf dem Kassenschnitt (als eigener
Posten, oder schon verrechnet), und muss die App bzw. die MA dabei etwas
beachten?

> **Antwort:** *ignorieren, kommt selten vor*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

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

[↑ zum Inhalt](#inhalt-offene-fragen-24)

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

> **Antwort:** *ignorieren*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 5.3 WLAN für den Kassenbetrieb

◐ teilweise geklärt — SB bekannt

**Hintergrund:** Das Gäste-WLAN sperrt den Kassen-Port (666) und wird für
den Kassenbetrieb nicht genutzt. Hängt mit 1.8 zusammen (die App-Adresse
muss aus diesem WLAN erreichbar sein).

**Frage:** Welches WLAN ist an den einzelnen Standorten (SB, GO, AT, CO,
BT) für den Flurbocash-Zugriff vorgesehen bzw. freigegeben?

> **Antwort (teilweise, Mail Yannik 15.07.):** SB: „Du musst in das
> Schauburg-AP Netz. Nicht Bremer Filmkunsttheater. Die Daten sind in dem
> SB Handy gespeichert.“ Eine Änderung des öffentlichen WLANs lehnte er
> ab. GO, AT, CO, BT *noch offen*.

[↑ zum Inhalt](#inhalt-offene-fragen-24)

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

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 6.2 Risiko Scheinselbständigkeit

◐ teilweise geklärt — beim Termin nachfassen

**Frage:** Besteht ein Risiko der Scheinselbständigkeit? Hat das
Steuerbüro es inzwischen beurteilt?

> **Antwort (teilweise):** Tom sagt: kein Problem. Beurteilung durch das
> Steuerbüro *noch offen*.

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 6.3 Vorschuss

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Der letzte Vorschuss ging per Mail klar („Vorschuss geht
klar“, 15.07.) und wurde bar ausgezahlt („Cash only“, 16.07.).

**Frage:** Ich brauche wieder einen Vorschuss. Wie hoch, ab wann, und wie
wird er mit der Vergütung (6.1) verrechnet?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 6.4 Kaffee-Flat in der BT

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Es gilt die Getränkeregelung für Mitarbeitende
(Rundmail 14.04.2026, unterschriebene Kenntnisnahme). Eine Kaffee-Flat wäre
eine Ausnahme davon, solange ich in der BT nicht im Dienst bin, sondern an
der App arbeite.

**Frage:** Ist eine Kaffee-Flat möglich, während ich in der BT an der App
arbeite?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 6.5 Übergabe und Ausfallsicherheit

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Die App liegt in meinem privaten GitHub-Konto, gebaut und
gewartet wird sie nur von mir. Mit dem Server-Umzug über GitHub (1.8)
hängt der Betrieb noch stärker daran. Entwürfe für Lizenzvertrag,
Preisblatt und Übergabe liegen vor (.dev/verkauf/).

**Frage:**

1. Was passiert, wenn ich ausfalle oder aufhöre — wer bekommt Zugriff auf
   Code und Repository?
2. Soll das Repository in ein Konto des Kinos umziehen?
3. Wollen wir das zusammen mit der Vergütung (6.1) in einer Vereinbarung
   regeln (Lizenz/Übergabe)?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 7.1 Deadline

⏳ offen *(neu, 14.10.)*

**Hintergrund:** Der Umstieg erfolgt je Standort (1.1). Ein Termin hängt
an Punkten, die nicht in Pacos Hand liegen (Live-Zugangsdaten 1.10,
Server-Umzug 1.8). Yannik (08.09.): Eine verpflichtende Einführung ist für
ihn ok, vorher aber mit Mello sprechen, und die Schauburg müsste dann an
das echte Flurbocash senden statt an die Sandbox.

**Frage:** Wollen wir eine Deadline benennen? Falls ja: für den
Produktivstart aller Standorte oder je Standort?

> **Antwort:** *2.11.26 für SB, CO und AT, dann wird auch in FC direkt übertragen.*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 7.2 Reihenfolge der Standorte

⏳ offen *(neu, 14.10.)*

**Hintergrund:** SB läuft bereits im Testbetrieb. Gründe für die
vorgeschlagene Reihenfolge, zum Gegenprüfen:

- GO und CO: TIDs, location_id und Sandbox-Key seit 08.10. vorhanden
  (1.2/1.3), Geräte können eingerichtet werden.
- BT: zwei Abrechnungen pro Tag (Mittag + Tagesende), stößt am ehesten an
  das 4×-Limit (3.3).

**Frage:** Nächste Schritte: erst CO und AT, dann GO, dann BT?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 7.3 Einführung, Schulung und Ansprechpartner

⏳ offen *(neu, 14.10.)*

**Hintergrund:** In der SB war ich bei den ersten Abrechnungen dabei;
einige MA haben trotz App manuell abgerechnet (meine Mail 31.08.). Die
Kurzanleitung lesen Mello und Wolfgang gegen (30.09.).

**Frage:**

1. Wer schult die MA an den neuen Standorten — ich vor Ort, Mello, die
   Leitung des Standorts?
2. Wer ist an den Standorten Ansprechpartner, wenn die App klemmt und ich
   nicht erreichbar bin?
3. Wie wird die Pflicht zur App-Abrechnung bekannt gemacht (Rundmail von
   dir, wie bei anderen betrieblichen Regelungen)?

> **Antwort:** *noch offen*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

---

### 7.4 Name der App

⏳ offen *(aus meiner Mail 21.06., Antwort nicht dokumentiert)*

**Hintergrund:** Ich hatte gefragt, ob die App einen an „Flurbocash“
angelehnten Namen bekommen soll (z. B. „FlurboClose“). Wird jetzt
konkret, weil die Server-Adresse `[appname].c137-prime.de` einen Namen
braucht (1.8).

**Frage:** Wie soll die App heißen?

> **Antwort:** *kassenabrechnung*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

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
   dem geplanten eigenen Anthropic-Account des Kinos zusammen — Yannik
   (10.09.): „Wir haben keine Claude API. Kann ich mich am WE
   drumkümmern.“ Stand? Bis dahin laufen die Scans über mein eigenes
   API-Kontingent (ca. 1–2 Cent pro Scan) — wer trägt diese Kosten?

> **Antwort:** *MA muss manuell eingeben*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

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
4. Sollen die MA die Möglichkeit haben, auf dem Umschlag so etwas wie "Übertragung fehlgeschlagen" auswählen können, damit die Buchhaltung weiß, dass sie hier genauer hinschauen soll?

> **Antwort:** *im Verlauf suchen und am nächsten Tag senden*

[↑ zum Inhalt](#inhalt-offene-fragen-24)

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

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 1.2 Terminal-IDs pro Standort

✅ beantwortet

**Hintergrund:** Alte und neue TIDs gelten in der App während der
Umstellung parallel (config/terminal_ids.json).


| Standort | alte TID           | neue TID                               | bestätigt |
| -------- | ------------------ | -------------------------------------- | ---------- |
| SB       | 54017635           | 60561994, 60561996, 60561997           | ja         |
| AT       | 54069464           | 60561998                               | ja         |
| CO       | 54017639           | 60561995                               | ja         |
| BT       | 54069493, 54017664 | 60561992, 60561993                     | ja         |
| GO       | –                 | 60561999, 60562000, 60562001, 60562002 | ja         |

SB (07.09.): Die neuen Terminals können vorerst nur Girocard, Kreditkarte
läuft weiter über das alte Terminal. Siehe auch 1.9 und 2.7.

**Frage:** Sind die neuen TIDs bei FC hinterlegt, wann fallen die alten
weg, und welche TID hat GO?

> **Antwort (Mails Yannik):** Neue TIDs genannt am 26.08. (SB, BT, CO).
> „Schauburg sind drin“ (02.10.). AT, BT, CO und GO bestätigt (08.10.),
> GO in der App eingetragen (Run 485).
> Alte TIDs (Paco, 14.10.): bleiben in der App, bis sie an allen
> Standorten korrekt läuft.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 1.3 Standort-Kennung (location_id)

✅ beantwortet

**Frage:** Welche location_id haben GO und CO?

> **Antwort (Mail Yannik, 08.10.):** GO: Sandbox 5, Live 3.
> CO: Sandbox 6, Live 5. Die Werte unterscheiden sich also zwischen
> Sandbox und Live. Gesamttabelle aller Standorte siehe
> [1.10](#110-live-zugangsdaten-für-sb-at-bt).

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 1.4 Passwort Schauburg-AP

✅ beantwortet

**Frage:** Wie lautet das Passwort für den Schauburg-AP?

> **Antwort:** Keine formelle Frage mehr — Paco klärt das jeweils vor Ort
> bzw. fragt Yannik spontan per Messenger.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 1.5 Geräte-Einrichtung & Pflege

✅ beantwortet

**Frage:** Wer richtet die Geräte ein und pflegt sie?

> **Antwort:** Paco richtet die Apps an den Standorten initial selbst ein.
> Spätere Änderungen (API-Key, TID) direkt am Gerät, siehe 1.6.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 1.6 Konfiguration zentral oder je Gerät

✅ beantwortet

**Frage:** Wird die Konfiguration zentral oder pro Gerät gepflegt?

> **Antwort:** Am Gerät vor Ort, nicht zentral von Yannik verwaltet.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 1.7 Android-Testgerät

✅ beantwortet

**Frage:** Wer besorgt ein Android-Testgerät?

> **Antwort:** Yannik kauft eins.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

## 2. Abrechnungsdaten & Format

### 2.2 Weitere Daten gewünscht?

✅ beantwortet

**Frage:** Braucht FC außer Kartenumsätzen und Bargeld weitere Daten?

> **Antwort:** Nein. FC holt sich die Kassenumsätze selbst aus dem
> Kassensystem. Die App schickt nur `terminals[]` und `cash_total`.
> Kino-SOLL, Bistro-SOLL, Ausgaben und Differenz werden nicht gebraucht.
> Ergänzung (Mail 14.07.): „Deine Seite macht nur IST. Soll kommt erst
> 12 Stunden später aus den Kassen direkt.“

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 2.3 Notizen, MA-Name, Sendezeitpunkt

✅ beantwortet

**Frage:** Dürfen Notizen, MA-Name und Sendezeitpunkt mitgeschickt werden?

> **Antwort:** Ja. Eigene JSON-Felder sind generell erlaubt, Feldnamen
> frei wählbar. FC ignoriert sie, bis sie serverseitig implementiert sind.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 2.4 Empfangsbestätigung

✅ beantwortet — mit einer Ausnahme, siehe 2.8

**Hintergrund:** Die App wertet eure Antwort auf PUT settlements als
Empfangsbestätigung: Erst bei 2xx zeigt sie „gesendet“, und sie merkt sich
die settlement_number aus der Antwort, damit eine spätere Korrektur die
richtige Abrechnung überschreibt (seit Run 477).

**Frage:** Kommt 2xx erst, wenn die Abrechnung wirklich gespeichert ist,
und enthält die Antwort immer die settlement_number?

> **Antwort (Mail Yannik, 02.10.):** „settlement_number kommt immer mit.
> Und ja, 2xx kommt erst nach dem Speichern.“ Korrekturen: „Flurbocash
> arbeitet mit Upsert.“ Ausnahme: Scheitert die Archivierung des
> Belegfotos, kommt eine 500 ohne settlement_number, obwohl die Werte
> gespeichert sind — offen als 2.8.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 2.4a Testkennzeichnung im Dashboard

✅ beantwortet

**Frage:** Könnt ihr Testübertragungen im Dashboard farblich von echten
unterscheidbar machen? Und schickt ihr einen Empfangs-Zeitstempel mit?

> **Antwort:** Keine Farbmarkierung — stattdessen „test“ ins
> Kommentarfeld schreiben, die Buchhaltung erkennt es manuell.
> Ein Server-Zeitstempel entfällt (Paco, 30.09.): Die App schickt selbst
> `sent_at` mit. (Empfangsbestätigung siehe 2.4.)

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 2.5 Validierung der SB-Testübertragungen

✅ beantwortet

**Frage:** Hat die Buchhaltung die SB-Testübertragungen geprüft?

> **Antwort:** Stand 26.08.: noch nicht getestet. Mail Yannik 08.09.:
> „Die Daten für die SB sehen korrekt aus. Stichprobenartig getestet.“
> Die realen AT-Abrechnungen vom 18. und 19.07. (meine Mail 19.07.) sind
> nicht ausdrücklich geprüft worden.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 2.6 Datum für Nachtabrechnungen (5-Uhr-Knick)

✅ beantwortet und umgesetzt

**Frage:** Gilt für Abrechnungen nach Mitternacht das logische
Geschäftsdatum?

> **Antwort:** Ja, logisches Geschäftsdatum. Der Tageswechsel liegt aber
> bei 5 Uhr, nicht bei 6 Uhr. In der App umgestellt.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

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

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 3.1b Korrekturen im Dashboard

– entfällt (nur Info an FC)

**Frage:** Sieht die Buchhaltung einen Unterschied zwischen Erst-
Abrechnung, Korrektur und versehentlichem Doppel-Versand? Wäre ein
„zuletzt geändert“-Hinweis möglich?

> **Antwort (Paco, 30.09.):** Keine App-Frage. Die App schickt
> settlement_number und `sent_at`, ob und wie FC das anzeigt, entscheidet
> Yannik. Korrekturen kommen ohnehin meist am selben Abend.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 3.1c finalized

– zurückgestellt

**Frage:** Wann/wodurch wird ein Tagesbericht als `finalized` markiert?

> **Antwort (Paco, 30.09.):** Für die App nicht nötig — Korrekturen kommen
> am selben Abend, die App erkennt `finalized: true` bzw. die 400 selbst.
> Taucht im Ausfall-Kontext wieder auf, siehe 8.2.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

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

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

## 4. Beleg-Foto

### 4.1 Perspektivische Ausrichtung

✅ beantwortet

**Frage:** Muss das Belegfoto perspektivisch entzerrt werden?

> **Antwort:** Nein, muss nur lesbar sein.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 4.2 Feld und Format für das Belegfoto

✅ beantwortet

**Frage:** In welchem Feld und Format wird das Belegfoto übertragen?

> **Antwort:** base64 direkt im JSON, Feldname frei wählbar (z. B.
> `beleg_foto_base64`). Keine maximale Dateigröße (Yannik, 26.08.).

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 4.3 Prüfen-Flag für die Buchhaltung

✅ beantwortet

**Frage:** Braucht es eine eigene Prüfmarkierung oder einen Dev-Button?

> **Antwort:** Nein, läuft über das Kommentarfeld (2.3).

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

## 5. Sonstiges

### 5.1 Mailversand

– entfällt

**Frage:** Soll die App Mails verschicken?

> **Antwort (Paco, 26.08.):** Nein. Auch kein Mail-Fallback bei
> Korrektur, 4×-Limit oder FC-Ausfall.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 5.2 Stapelscanner

✅ beantwortet

**Frage:** Wird ein Stapelscanner für zurückliegende Belege gebraucht?

> **Antwort:** Nein.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)

---

### 5.3a Prüfung nach Verbindungsabbruch

– zurückgestellt (WLAN-Teil weiter offen, siehe 5.3)

**Frage:** Können wir nachträglich bei euch prüfen, ob eine Abrechnung
angekommen ist, wenn die Verbindung mittendrin abbricht?

> **Antwort (Paco, 30.09.):** Zurückgestellt. Betrifft nur „Abrechnung
> angekommen, Antwort verloren“. Folge ist höchstens ein Duplikat bei FC
> (löschbar außer Nr. 1). Erst nachfragen, wenn Duplikate in der Praxis
> auffallen.

[↑ zum Inhalt](#inhalt-beantwortete-fragen-23)
