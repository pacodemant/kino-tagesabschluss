# Fragen an Yannik — Flurbocash-Integration

Stand: 22.09.2026 · zentrale Tracking-Datei für alle Fragen rund um die Flurbocash-Anbindung, inkl. bereits erhaltener Antworten. Wird laufend ergänzt/aktualisiert, sobald neue Antworten reinkommen oder neue Fragen auftauchen.

Status-Werte: `offen` · `teilweise geklärt` · `beantwortet` · `entfällt`

## Übersicht

⏳ offen · ◐ teilweise geklärt · ✅ beantwortet · – entfällt

### Noch zu klären (10)

**1. Zugangsdaten & Einrichtung**
- ⏳ [1.2 Sind die neuen TIDs bei FC hinterlegt, und wann fallen die alten weg?](#12-terminal-ids-pro-standort)
- ◐ [1.3 Welche location_id haben GO und CO?](#13-standort-kennung-kinoidlocationid)
- ◐ [1.8 Kann die App jetzt auf den Kino-Server umziehen?](#18-app-hosting-auf-kino-server-statt-github-pages)

**2. Abrechnungsdaten & Format**
- ◐ [2.4 Meldet FC einen Empfangszeitstempel zurück, und wie kennzeichnen wir Tests?](#24-zeitstempel-der-übertragung--testkennzeichnung-im-dashboard-dev-flag)

**3. Korrektur & Duplikate**
- ◐ [3.1 Sieht die Buchhaltung Korrekturen, und gibt es eine Abfrage für belegte settlement_numbers?](#31-korrektur-mechanismus--settlementnumber)
- ⏳ [3.2 Wie verhindern wir, dass eine Abrechnung versehentlich doppelt übertragen wird?](#32-schutz--hinweis-bei-versehentlicher-doppel-übertragung)
- ⏳ [3.3 Was soll passieren, wenn das Limit von 4 Abrechnungen pro Tag erreicht ist?](#33-verhalten-bei-maximum-reached-4-limit)

**5. Sonstiges**
- ⏳ [5.3 Können wir nach einem Verbindungsabbruch prüfen, was angekommen ist, und welches WLAN ist freigegeben?](#53-nachträgliche-prüfung-nach-verbindungsabbruch)

**6. Vergütung & Rolle Yannik**
- ⏳ [6.1 Wie hoch soll Yanniks Vergütung sein, und nach welchem Modell?](#61-vergütung-yannik-höhemodell)
- ◐ [6.2 Besteht ein Risiko der Scheinselbständigkeit?](#62-risiko-scheinselbständigkeit)

### Erledigt (15)

**1. Zugangsdaten & Einrichtung**
- ✅ [1.1 Wird der Produktivbetrieb pro Standort oder für alle gleichzeitig gestartet?](#11-basis-url--umstieg-auf-produktivserver)
- ✅ [1.4 Wie lautet das Passwort für den Schauburg-AP?](#14-passwort-schauburg-ap)
- ✅ [1.5 Wer richtet die Geräte ein und pflegt sie?](#15-geräte-einrichtung--pflege)
- ✅ [1.6 Wird die Konfiguration zentral oder pro Gerät gepflegt?](#16-konfiguration-zentral-oder-je-gerät)
- ✅ [1.7 Wer besorgt ein Android-Testgerät?](#17-android-testgerät)

**2. Abrechnungsdaten & Format**
- ✅ [2.1 Zwei EC-Belege desselben Terminals einzeln übertragen?](#21-zwei-ec-zahlungen-am-selben-terminal-in-einer-abrechnung)
- ✅ [2.2 Braucht FC außer Kartenumsätzen und Bargeld weitere Daten?](#22-weitere-daten-gewünscht)
- ✅ [2.3 Dürfen Notizen, MA-Name und Sendezeitpunkt mitgeschickt werden?](#23-notizen-ma-name-sendezeitpunkt-etc)
- ✅ [2.5 Hat die Buchhaltung die SB-Testübertragungen geprüft?](#25-validierung-der-sb-testübertragungen-aus-buchhaltungssicht)
- ✅ [2.6 Welches Datum gilt für Nachtabrechnungen (Tageswechsel um 5 Uhr)?](#26-datum-für-nachtabrechnungen-6-uhr-knick)

**4. Beleg-Foto**
- ✅ [4.1 Muss das Belegfoto perspektivisch entzerrt werden?](#41-perspektivische-ausrichtung-nötig)
- ✅ [4.2 In welchem Feld und Format wird das Belegfoto übertragen?](#42-base64-beleg-json-genaues-feldformat)
- ✅ [4.3 Braucht es eine eigene Prüfmarkierung oder einen Dev-Button?](#43-prüfen-flag-für-buchhaltung--dev-button-app-intern)

**5. Sonstiges**
- – [5.1 Soll die App Mails verschicken?](#51-mailversand)
- ✅ [5.2 Wird ein Stapelscanner für alte Belege gebraucht?](#52-stapelscanner-für-zurückliegende-belege)

---

## 1. Zugangsdaten & Einrichtung

### 1.1 Basis-URL / Umstieg auf Produktivserver

**Status:** beantwortet
**Bereits klar (Paco):** Die Sandbox-Adresse (sandbox.flurbocash.c137-prime.de:666) ist nicht die Produktiv-Adresse — für den Echtbetrieb bekommen wir eine eigene URL von Yannik. Der Umstieg erfolgt, nachdem die Tests (aktuell in der SB) positiv abgeschlossen sind, nicht an einem festen Datum.
**Frage an Yannik:** Erfolgt der Umstieg auf Produktivbetrieb standortweise nacheinander (erst SB, dann die anderen) oder für alle Standorte gleichzeitig?


**Antwort:** je Standort

[↑ zur Übersicht](#übersicht)

---

### 1.2 Terminal-IDs pro Standort

**Status:** offen

- FC schon auf die neuen TIDs umgestellt?
- wie lauten die neuen TIDs?

**Bereits bekannt (Code-Stand, config/terminal_ids.json):** Aktuell im Code hinterlegte Annahmen — SB: 54017635, AT: 54069464, CO: 54017639, BT: 54069493 + 54017664. Keine davon ist bisher von Yannik bestätigt. Für GO ist noch gar kein Wert eingetragen (Platzhalter "XXXX").

**Antwort:** Noch keine Werte — Yannik schickt die bestätigten TIDs per Mail nach (Stand 2026-08-26).

**Update (2026-09-07):** SB nutzt seither zusätzlich drei neue Terminals (vorerst nur Girocard, Kreditkarte weiterhin über das alte Terminal) — parallel zum alten Terminal, bis komplett umgestellt ist. config/terminal_ids.json enthält dafür bereits neue TIDs (SB: 60561994/60561996/60561997, BT: 60561992/60561993, CO: 60561995) — reine Annahmen aus den Geräten selbst, noch nicht von Yannik bestätigt.

**Neue Frage (2026-09-22):** Sind die neuen TIDs (SB/BT/CO) bei euch korrekt hinterlegt, und wann können die alten TIDs entfernt werden? Für GO fehlen TID und location_id weiterhin komplett.

[↑ zur Übersicht](#übersicht)

---

### 1.3 Standort-Kennung (kino_id/location_id)

**Status:** teilweise geklärt
**Antwort:** Feldname bereits bekannt aus `EXTERNAL_API_Schauburg_de.md`: `location_id` (Integer, Teil des Request-Body von `POST /api/daily-reports/ensure`). Werte teilweise bekannt (Mail Yannik, 2026-07-12, siehe TODO_ERLEDIGT.md): Schauburg (SB) = 1, Atlantis (AT) = 3, Bar Tabak (BT) = 4.
**Noch offen:** Wie lauten die location_id-Werte für GO und CO?

**Antwort:** Noch keine Werte — Yannik schickt die GO/CO-location_id per Mail nach (Stand 2026-08-26).

[↑ zur Übersicht](#übersicht)

---

### 1.4 Passwort Schauburg-AP

**Status:** beantwortet
**Antwort:** Keine formelle Yannik-Frage mehr — Paco findet das WLAN-Passwort jeweils vor Ort selbst heraus bzw. fragt Yannik bei Bedarf spontan über Messenger.

[↑ zur Übersicht](#übersicht)

---

### 1.5 Geräte-Einrichtung & Pflege

**Status:** beantwortet
**Antwort:** Paco richtet die Apps an den Standorten initial selbst ein. Wie spätere Änderungen laufen (neuer API-Key, neue TID), ist bereits in 1.6 beantwortet — Konfiguration erfolgt jeweils direkt am Gerät vor Ort, nicht zentral von Yannik verwaltet.

[↑ zur Übersicht](#übersicht)

---

### 1.6 Konfiguration zentral oder je Gerät

**Status:** beantwortet
**Antwort:** Am Gerät vor Ort (nicht zentral von Yannik verwaltet).

[↑ zur Übersicht](#übersicht)

---

### 1.7 Android-Testgerät

**Status:** beantwortet
**Antwort:** Yannik kauft eins.

[↑ zur Übersicht](#übersicht)

---

### 1.8 App-Hosting auf Kino-Server (statt GitHub Pages)

**Status:** teilweise geklärt
Aktuell läuft die App als PWA über GitHub Pages (Pacos privater GitHub-Account). Wann soll die App stattdessen auf einem Kino-eigenen Server liegen? Hätte Paco dann unbeschränkten Zugriff darauf (z. B. für eigenständige Deploys/Updates), oder würde das über Yannik/die IT laufen?
**Antwort:** Noch nicht final — Yannik braucht zuerst Infos zum aktuellen Deployment, bevor er das einschätzen kann. Offene Zwischenaufgabe (Paco): klären, welche Infos genau nötig sind (z. B. Hosting-Art, Domain, Build-/Deploy-Prozess der aktuellen GitHub-Pages-Lösung) und diese an Yannik liefern.

**Update (2026-09-01):** Infos an Yannik geschickt — SFTP-Upload in einen Ordner, alte Dateien werden ersetzt, HTTPS ist Pflicht; lokal generalprobt.

**Neue Frage (2026-09-22):** Hat Yannik sich das inzwischen angeschaut — wie ist der Stand, ist ein Umzug auf den Kino-Server jetzt möglich?

[↑ zur Übersicht](#übersicht)

---

## ✅ 2. Abrechnungsdaten & Format

### 2.1 Zwei EC-Zahlungen am selben Terminal in einer Abrechnung

**Status:** beantwortet und umgesetzt (siehe TODO_ERLEDIGT.md, Run 399a3)
Präzisierung der ursprünglichen Frage ("zweimal Karte gezogen"): Gemeint sind zwei EC-Zahlungsvorgänge am selben Terminal (gleiche TID) innerhalb derselben Tagesabrechnung/settlement — nicht zwei komplett getrennte Abrechnungen an einem Tag. Getrennte Abrechnungen am selben Tag regelt bereits `settlement_number` 1–4 inkl. Korrektur-Möglichkeit, siehe 3.1 (dort ist auch erklärt, wie FC generell mit mehreren Abrechnungen/Korrekturen umgeht).

**Bereits bekannt (Code-Stand, TODO.md:26-40):** Die App summiert zwei EC-Belege desselben Terminals aktuell stillschweigend zu einer einzigen `terminals[]`-Zeile (`ApiUploadService._terminalsListe()`).

**Fragen an Yannik:**

1. Sollen die beiden Belege stattdessen einzeln aufgeschlüsselt übertragen werden — also zwei `terminals[]`-Einträge mit identischer TID innerhalb desselben settlements-Eintrags? `EXTERNAL_API_Schauburg_de.md` sagt dazu nichts.
2. Falls ja: Verarbeitet/akzeptiert Flurbocash mehrere `terminals[]`-Einträge mit derselben TID in einem einzigen Aufruf korrekt (beide Beträge werden erfasst), oder zählt nur der letzte Eintrag?

**Antwort:** zu 1: jeder Beleg als eigener Datensatz, zu 2: ja.

[↑ zur Übersicht](#übersicht)

---

### 2.2 Weitere Daten gewünscht?

**Status:** beantwortet
**Antwort:** Laut FC-Vorgaben zieht sich Flurbocash die Kassenumsätze selbst aus dem Kassensystem (`EXTERNAL_API_Schauburg_de.md`: `system_total_cents` wird von Flurbocash aus den Kassensystemdaten errechnet). Die App muss zu den EC-Beleg-Kartenumsätzen (`terminals[]`) nur noch den Barumsatz (`cash_total`) übertragen. Kino-Soll, Bistro-Soll, Ausgaben und Differenz werden nicht benötigt.

[↑ zur Übersicht](#übersicht)

---

### 2.3 Notizen, MA-Name, Sendezeitpunkt etc.

**Status:** beantwortet
**Antwort:** Ja, möglich. Zusätzlich erlaubt: Yannik hat generell gesagt, dass wir eigene JSON-Felder einfach hinzufügen können — solange er sie serverseitig in FC nicht implementiert hat, werden sie schlicht ignoriert (siehe auch 4.2). Plan (Paco, 2026-08-26): Name des abrechnenden Mitarbeiters, ein freies Kommentarfeld sowie Sendedatum/-uhrzeit (hilft v. a. beim Entwickeln, um die Reihenfolge der Übertragungen nachzuvollziehen) als zusätzliche Felder mitschicken.

**Feldnamen:** Yannik gibt keine vor — Paco kann sie selbst wählen. Ob der Sendezeitpunkt speziell erwünscht war, ist nicht mehr sicher erinnerlich (möglicherweise nicht) — wird trotzdem mit ins JSON aufgenommen (siehe generelle Ignorieren-Regelung, 4.2).

[↑ zur Übersicht](#übersicht)

---

### 2.4 Zeitstempel der Übertragung + Testkennzeichnung im Dashboard (dev-Flag)

**Status:** teilweise geklärt
Könntet ihr uns bei jeder Übertragung zusätzlich Datum/Uhrzeit der Übertragung mitschicken (hilft bei der Fehlersuche)? Wichtiger: Könnt ihr im Flurbocash-Dashboard testweise gesendete Abrechnungen aus der SB (wo wir aktuell testen) farblich von echten unterscheidbar machen? Zweck: Die Buchhaltung erkennt auf einen Blick, welche Übertragungen echt und zu prüfen sind und welche sie ignorieren kann — und wir können während der Entwicklung frei in der echten Umgebung testen, ohne echte Daten zu verfälschen oder die Buchhaltung zu verwirren.
**Antwort:** Zur Testkennzeichnung: keine separate Farbmarkierung durch FC geplant — stattdessen das Wort "test" über die Kommentarfunktion in der Abrechnung mitschicken (siehe 2.3), damit die Buchhaltung es manuell erkennt.
**Noch offen:** Ob FC bei jeder Übertragung einen eigenen Empfangs-Zeitstempel zurückmeldet, ist damit noch nicht beantwortet.

[↑ zur Übersicht](#übersicht)

---

### 2.5 Validierung der SB-Testübertragungen aus Buchhaltungssicht

**Status:** beantwortet
**Antwort:** Noch nicht getestet (Stand 2026-08-26).

[↑ zur Übersicht](#übersicht)

---

### 2.6 Datum für Nachtabrechnungen (6-Uhr-Knick)

**Status:** beantwortet
**Antwort:** Ja, logisches Geschäftsdatum — Annahme bestätigt. Aber: Der Knick liegt bei 5 Uhr, nicht bei 6 Uhr wie bisher angenommen/in der App implementiert.
**Bug gefunden (2026-08-26):** Die App rechnet aktuell mit einem 6-Uhr-Cutoff (`DatumsHelper._geschaeftstagCutoffStunde`, lib/utils/datums_helper.dart:8) — muss auf 5 Uhr geändert werden. Für Abschlüsse zwischen 5:00 und 5:59 Uhr würde die App sonst das falsche Datum an FC senden. TODO.md-Eintrag angelegt ("Geschäftstag-Cutoff von 6 auf 5 Uhr umstellen").

[↑ zur Übersicht](#übersicht)

---

## 3. Korrektur & Duplikate

### 3.1 Korrektur-Mechanismus / settlement_number

**Status:** teilweise geklärt
**Antwort:** Mechanismus bekannt — settlement_number weglassen = neue Abrechnung, Wert 1–4 = bestehende überschreiben. Noch offen: Sichtbarkeit von Korrekturen im Buchhaltungs-Dashboard, und ob es einen Leseweg gibt, um vorhandene settlement_numbers vor dem Senden abzufragen.

**Bereits bekannt (aus EXTERNAL_API_Schauburg_de.md:64-67):** `settlement_number` ist optional.

- Weglassen → neue Abrechnung, Server vergibt automatisch die nächste freie Nummer (1, dann 2, ...). Max. 4/Tag, danach `400` "maximum of 4 settlements per day reached".
- Wert 1–4 explizit setzen → überschreibt genau diese bestehende Abrechnung an Ort und Stelle (= Korrektur). Zielnummer muss bereits existieren, sonst `400`.

**Verifiziert (2026-08-26, gegen die englische Originaldatei EXTERNAL_API_Schauburg.md, nicht nur die deutsche Übersetzung):** Kein Übersetzungsfehler — beide Fassungen sagen identisch dasselbe. Zitat Original: "Set it to 1–4 to overwrite that existing settlement (correction)." Das heißt: Der **Client** muss die `settlement_number` explizit mitschicken, um eine Korrektur auszulösen — FC erkennt eine Korrektur nicht selbstständig am Inhalt (z. B. gleiche TID/gleicher Tag). Ein Korrektur-Modus ganz ohne Nummer ist laut Doku nicht vorgesehen. Das verschärft die Strukturelle Lücke unten: Die App muss diese Nummer korrekt kennen, kennt sie aber aktuell nicht zuverlässig.

**Bug im eigenen Code gefunden (2026-08-25):** Die App sendet `settlement_number` aktuell nie — weder beim Erstversand noch bei "Erneut senden" (lib/services/api_upload_service.dart:165-174, lib/pages/verlauf_detail_seite.dart:49-96 ruft denselben Pfad ohne Unterscheidung auf). Jedes "Erneut senden" legt dadurch vermutlich eine zusätzliche Abrechnung an statt zu korrigieren, bis die 4er-Grenze erreicht ist. Fix (kein Yannik-Thema, intern umzusetzen): Erstversand weiter ohne `settlement_number` (wird automatisch Nummer 1, solange nur eine Abrechnung/Tag), "Erneut senden" künftig mit `settlement_number: 1` explizit.

**Strukturelle Lücke erkannt (2026-08-25, Rückfrage von Paco):** Weder die Antwort von `POST ensure` (EXTERNAL_API_Schauburg_de.md:45-51) noch die von `PUT settlements` (EXTERNAL_API_Schauburg_de.md:112-121) enthält das Feld `settlement_number` — der Server bestätigt also nie, welche Nummer er tatsächlich vergeben hat. Die App muss die "nächste logische Nummer" rein aus dem eigenen lokalen Zustand ableiten (Sende-Signatur/grüner Haken), ohne Möglichkeit zur Gegenprüfung. Das wird brüchig, sobald dieser lokale Zustand nicht mehr stimmt — bekannte Fälle: der offene Bug "Gesendet-Haken verschwindet nicht über den 6-Uhr-Knick" (TODO.md:75-92), Safaris 7-Tage-Löschung von localStorage/IndexedDB (TODO.md:176-180), oder eine Korrektur von einem anderen Gerät als dem Erstversand.

**Antwort erhalten (2026-08-26):** FC wird künftig die `settlement_number` in den Antworten von `POST ensure`/`PUT settlements` mit zurückgeben. Das löst die Strukturelle Lücke oben für den Regelfall: Die App kann sich die vom Server bestätigte Nummer direkt aus der eigenen Antwort merken, statt sie aus dem lokalen Zustand zu raten. Bleibt relevant für Fälle ohne diesen Anker (Datenverlust, Korrektur von einem anderen Gerät) — siehe Frage 3 unten, die dadurch aber deutlich an Dringlichkeit verliert.

**Verbleibende Fragen an Yannik:**

1. Wenn ihr eine Abrechnung mehrfach für denselben Tag empfangt (per settlement_number überschrieben) — sieht eure Buchhaltung im Dashboard einen Unterschied zwischen **(a) der ursprünglichen Erst-Abrechnung, (b) einer inhaltlich korrigierten Abrechnung und (c) einem versehentlichen Doppel-Versand mit exakt denselben Werten**? Oder sehen alle drei Fälle im Dashboard identisch aus? (Der technische Mechanismus selbst ist uns klar — Server überschreibt in allen drei Fällen gleich, siehe oben. Es geht hier nur um die Sicht der Buchhaltung im Dashboard.)
2. Falls kein Unterschied sichtbar ist: wäre ein "zuletzt geändert"-Hinweis im Dashboard o. Ä. möglich? (Eine separate Meldung per Mail ist nicht vorgesehen, siehe 5.1.)
3. Gibt es (oder plant ihr) eine Möglichkeit, VOR dem Senden abzufragen, welche settlement_numbers für einen Tagesbericht bereits belegt sind und mit welchen Werten? Ohne das muss die App blind auf ihren eigenen lokalen Zustand vertrauen, der nachweislich nicht immer zuverlässig ist (siehe oben). Hängt mit 5.3 zusammen (dort geht es um denselben fehlenden Leseweg, dort im Kontext Verbindungsabbruch).
4. Wann/wodurch wird ein Tagesbericht bei euch als `finalized` markiert (`POST ensure` liefert dann `finalized: true`, keine weiteren Schreibzugriffe/Korrekturen mehr möglich)? Automatisch nach einer bestimmten Zeit, oder manuell durch die Buchhaltung? Relevant, weil eine späte Korrektur sonst plötzlich mit `400` abgelehnt werden könnte, ohne dass wir das vorher wissen — hängt auch mit 2.6 (6-Uhr-Knick) zusammen, falls die Finalisierung an der Kalendertag-Grenze hängt.
5. Alternative zum Nummern-Tracking: Könnte die App bei einer Korrektur stattdessen nur ein Flag senden (z. B. `is_correction: true` oder `overwrite_last: true`), damit FC selbst die zuletzt für den Tag eingereichte Abrechnung überschreibt — ohne dass die App die genaue `settlement_number` kennen muss? Laut aktueller Doku ist das nicht vorgesehen (der Client muss die Nummer explizit angeben, siehe Verifiziert oben), aber vielleicht gibt es das doch oder ihr könntet es ergänzen.

(Ergänzt die alte Frage "Muss die App eine settlement_nummer selbst vergeben?" — durch den Doku-Fund im Kern beantwortet, siehe oben.)

[↑ zur Übersicht](#übersicht)

---

### 3.2 Schutz & Hinweis bei versehentlicher Doppel-Übertragung

**Status:** offen
Zusammengeführt aus den vorherigen, eng zusammengehörenden Fragen "Popup-Hinweis" und "technischer Schutz" — beide behandeln denselben Fall aus zwei Blickwinkeln (UI bzw. Erkennungsmechanismus).

Wie verhindern wir am besten, dass aus Versehen zweimal dieselbe Abrechnung bei euch landet (Doppel-Tap, Verbindungsabbruch)? Unsere Idee: Die App vergleicht vor dem Senden eine Signatur der Daten mit der zuletzt gesendeten Version und zeigt dem Mitarbeiter in dem Fall ein Popup "Du hast das schon geschickt — als Korrektur werten?" Aus unserer Sicht sinnvoll, würden aber trotzdem Yanniks Einschätzung dazu hören wollen.

Hinweis: Sobald 3.1 korrekt implementiert ist (Korrektur immer über dieselbe `settlement_number`), wird ein versehentliches doppeltes Senden für Standorte mit nur einer Abrechnung/Tag ohnehin harmlos — es überschreibt nur mit identischen Werten. Relevant bleibt die Frage v. a. für Bar Tabak (mehrere Abrechnungen/Tag).
**Antwort:**

[↑ zur Übersicht](#übersicht)

---

### 3.3 Verhalten bei "maximum reached" (4×-Limit)

**Status:** offen
Was soll passieren, wenn das Limit erreicht ist? Ein Mailversand ist laut aktueller Planung nicht vorgesehen (siehe 5.1) — welcher Fallback ist stattdessen sinnvoll, z. B. ein Hinweis in der App, dass die Buchhaltung manuell informiert werden muss?
**Antwort:**

[↑ zur Übersicht](#übersicht)

---

## 4. Beleg-Foto

### 4.1 Perspektivische Ausrichtung nötig?

**Status:** beantwortet
**Antwort:** Muss nur lesbar sein, keine Entzerrung nötig.

[↑ zur Übersicht](#übersicht)

---

### 4.2 base64-Beleg-JSON: genaues Feld/Format

**Status:** beantwortet
**Antwort:** Wird als base64 direkt ins zu übertragende JSON eingebettet (kein separater Upload, unsere Entscheidung). Feldname ist unsere eigene Wahl (z. B. `beleg_foto_base64`) — Yannik hat generell erlaubt, zusätzliche Felder im JSON selbst zu benennen und mitzuschicken; bis er sie serverseitig implementiert, werden sie einfach ignoriert. Plan (Paco, 2026-08-26): dieselbe Vorgehensweise auch für Sendedatum/-uhrzeit und den Namen des abrechnenden Mitarbeiters nutzen (siehe 2.3), ggf. auch für eine eigene Referenznummer zur Abrechnung. Keine maximale Dateigröße (Yannik, 2026-08-26).

[↑ zur Übersicht](#übersicht)

---

### 4.3 Prüfen-Flag für Buchhaltung + Dev-Button (App-intern)

**Status:** beantwortet
**Antwort:** Kein eigenes Dev-Flag/Button nötig — läuft stattdessen über die Notizen-/Kommentarfunktion (siehe 2.3).

[↑ zur Übersicht](#übersicht)

---

## 5. Sonstiges

### 5.1 Mailversand

**Status:** entfällt
**Antwort:** Kein Mailversand vorgesehen — nicht benötigt (Paco-Entscheidung, 2026-08-26). Betrifft auch 3.1 (keine separate Korrektur-Meldung per Mail) und 3.3 (kein Mail-Fallback beim 4×-Limit).

[↑ zur Übersicht](#übersicht)

---

### 5.2 Stapelscanner für zurückliegende Belege

**Status:** beantwortet
**Antwort:** Nein, nicht benötigt.

[↑ zur Übersicht](#übersicht)

---

### 5.3 Nachträgliche Prüfung nach Verbindungsabbruch

**Status:** offen
Falls die Verbindung mittendrin abbricht und wir nicht sicher wissen, ob eine Abrechnung angekommen ist — können wir das nachträglich bei euch prüfen? Kontext: WLAN-Probleme am Standort sind bekannt (Gäste-WLAN blockiert den Kassen-Port), kein rein theoretischer Fall. Bestätigt (2026-08-25): Die aktuelle API-Doku kennt nur `POST ensure` und `PUT settlements`, keinen Leseweg (GET) — hängt inhaltlich mit 3.1 (Frage 3) zusammen.

**Zusätzliche Frage:** Das Gäste-WLAN wird für den Kassenbetrieb ohnehin nicht genutzt (sperrt den Kassen-Port). Welches WLAN ist stattdessen an den einzelnen Standorten (SB, GO, AT, CO, BT) für den Flurbocash-Zugriff vorgesehen/freigegeben?

**Antwort:**

[↑ zur Übersicht](#übersicht)

---

## 6. Vergütung & Rolle Yannik

### 6.1 Vergütung Yannik (Höhe/Modell)

**Status:** offen — soll beim nächsten Termin aktiv angesprochen werden, nicht nur beiläufig
**Vorschlag Paco:** Vergütung am Einsparpotential orientieren, das die App-Automatisierung gegenüber der bisherigen Abrechnungsweise bringt. Um das statt auf Annahmen/Schätzungen zu verlassen genau zu beziffern: alte und neue Abrechnungsweise per Stoppuhr miteinander vergleichen.
**Notiz (2026-08-25):** Ursprünglich als "nicht an Yannik" markiert (betrifft seine eigene Rolle), Paco möchte das jetzt aber direkt an ihn richten — er ist nicht nur IT, sondern auch Chef-Sohn und Nachfolger.
**Antwort:**

[↑ zur Übersicht](#übersicht)

---

### 6.2 Risiko Scheinselbständigkeit

**Status:** teilweise beantwortet — Priorität: beim nächsten Termin nachfassen
**Antwort:** Tom sagt: kein Problem. Trotzdem vom Steuerbüro beurteilen lassen — noch nicht final. (Gleicher Kontext wie 6.1 — auch diese Frage wird jetzt direkt an Yannik gerichtet, siehe dortige Notiz.)

[↑ zur Übersicht](#übersicht)
