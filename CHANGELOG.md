# CHANGELOG

Alle relevanten Änderungen am Projekt werden hier kurz dokumentiert.

Diese Datei enthält Run 270 bis zum aktuellen Run. Ältere Einträge
(Run 63–269) stehen in CHANGELOG_ARCHIV.md. Archivierung nach Bedarf
fortsetzen (z. B. wieder ab ~50–60 Runs), damit diese Datei nicht
unbegrenzt wächst — sie wird vor jedem Eintrag vollständig gelesen.

## Unreleased

- Run 361: Sub-Run 5 der build()-Zerlegungs-Serie für
  einstellungen_seite.dart (Fortsetzung von Run 355/358/359/360).
  Flurbocash-Anbindung-Band ausgelagert: An/Aus-Switch + die drei
  Konfigfelder (Upload-URL, location_id mit Ziffern-Formatter,
  API-Key) inkl. FocusNodes als neues eigenständiges
  StatelessWidget EinstellungenFlurbocashSection (neue Datei
  sections/einstellungen_flurbocash_section.dart), über
  EinstellungenGruppenOrchestrierung verdrahtet. Reines Verschieben
  ohne Verhaltensänderung. Datei dadurch von 1280 auf 1225 Zeilen
  geschrumpft. Verbleibend: nur noch Dev-Modus/Testwerte — der
  größte/riskanteste Rest-Block wegen _baueAutoFillInhalt(), damit
  letzter Sub-Run dieser Serie. Version 0.9.35+361. Dateien:
  einstellungen_seite.dart, einstellungen_gruppen_orchestrierung.dart,
  einstellungen_flurbocash_section.dart (neu), pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, TODO.md.

- Run 360: Sub-Run 4 der build()-Zerlegungs-Serie für
  einstellungen_seite.dart (Fortsetzung von Run 355/358/359).
  Wechselgeldbestand-Band ausgelagert: aufklappbare ListTile mit
  Betrags-Vorschau + Eingabefeld für den Wechselgeld-Sollwert als
  neues eigenständiges StatelessWidget
  EinstellungenWechselgeldSection (neue Datei sections/
  einstellungen_wechselgeld_section.dart), über
  EinstellungenGruppenOrchestrierung verdrahtet. Reines Verschieben
  ohne Verhaltensänderung — der Aufklapp-Toggle bleibt wie beim
  Getränkeliste-Muster als Callback aus der Page injiziert. Datei
  dadurch von 1346 auf 1280 Zeilen geschrumpft. Verbleibend für
  weitere Sub-Runs: Flurbocash-Anbindung, Dev-Modus/Testwerte
  (Letzteres voraussichtlich der größte/riskanteste Rest-Block wegen
  _baueAutoFillInhalt()). Version 0.9.34+360. Dateien:
  einstellungen_seite.dart, einstellungen_gruppen_orchestrierung.dart,
  einstellungen_wechselgeld_section.dart (neu), pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, TODO.md.

- Run 359: Sub-Run 3 der build()-Zerlegungs-Serie für
  einstellungen_seite.dart (Fortsetzung von Run 355/358). Zweites
  Band der Admin-Card ausgelagert: Standort-Betriebsmodus-Dropdown +
  "Admin-Status halten"-Switch als neues eigenständiges
  StatelessWidget EinstellungenStandortAdminSection (neue Datei
  sections/einstellungen_standort_admin_section.dart), über
  EinstellungenGruppenOrchestrierung verdrahtet. Reines Verschieben
  ohne Verhaltensänderung. Datei dadurch von 1399 auf 1346 Zeilen
  geschrumpft. Verbleibend für weitere Sub-Runs: Wechselgeldbestand,
  Flurbocash-Anbindung, Dev-Modus/Testwerte. Version 0.9.33+359.
  Dateien: einstellungen_seite.dart,
  einstellungen_gruppen_orchestrierung.dart,
  einstellungen_standort_admin_section.dart (neu), pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, TODO.md.

- Run 358: Sub-Run 2 der build()-Zerlegungs-Serie für
  einstellungen_seite.dart (Fortsetzung von Run 355). Das einfachste
  der 5 Admin-Card-Bänder ausgelagert: KI-Belegscan-Konfig
  (Service-URL + Anthropic-API-Key-Felder) als neues eigenständiges
  StatelessWidget EinstellungenBelegscanSection (neue Datei
  sections/einstellungen_belegscan_section.dart), über
  EinstellungenGruppenOrchestrierung verdrahtet. Reines Verschieben
  ohne Verhaltensänderung — Controller, Speicher-Methoden und State
  bleiben unverändert in einstellungen_seite.dart, nur der
  Widget-Bau wurde ausgelagert. Datei dadurch von 1434 auf 1399
  Zeilen geschrumpft. Verbleibend für weitere Sub-Runs: Standort/
  Admin-Status, Wechselgeldbestand, Flurbocash-Anbindung, Dev-Modus/
  Testwerte. Version 0.9.32+358. Dateien: einstellungen_seite.dart,
  einstellungen_gruppen_orchestrierung.dart,
  einstellungen_belegscan_section.dart (neu), pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, TODO.md.

- Run 357: Zwei TODO.md-Punkte geklärt, ohne dass eine Code-Änderung
  nötig war. (A) "Kein Screen-Flip": Paco bestätigt, dass auf den
  eingesetzten Android-Geräten (Zielplattform) das Drehproblem nicht
  auftritt — nur Pacos private iOS-Testumgebung war betroffen
  (bereits als iOS-spezifisch bekannt, Run 319b). Punkt als erledigt
  nach TODO_ERLEDIGT.md verschoben. (B) "Kartensumme ↔
  EC-Gesamtbetrag nach manuellem Nachtrag": Der bestehende
  Warnhinweis in schritt2_ui_builder.dart (summePasstNicht) reagiert
  bereits live auf den Vergleich zwischen Kartensumme und
  EC-Gesamtbetrag und verschwindet automatisch, sobald ein "+
  Kartenart"-Nachtrag beide Werte wieder angleicht. Der
  EC-Gesamtbetrag bleibt bewusst ein unabhängig vom Scan eingelesener
  Wert statt einer berechneten Summe, da sonst die Kreuzvalidierung
  gegen Scan-Fehler bei einzelnen Kartenarten verloren ginge. Ebenfalls
  geklärt, ebenfalls nach TODO_ERLEDIGT.md verschoben. Zusätzlich zwei
  liegen gebliebene Kleinigkeiten mit eingecheckt: Button-Text "Neu
  laden" → "App neu laden" (einstellungen_seite.dart) sowie ein
  zusätzlicher Dummy-EC-Beleg-Scan (IMG_3714.jpeg) in der lokalen
  HTML-Testsimulation sowie ein Tippfehler-Fix in AGENTS.md ("im im"
  → "im"). Version 0.9.31+357. Dateien: einstellungen_seite.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart,
  TODO.md, TODO_ERLEDIGT.md, AGENTS.md,
  .dev/kassenberichte dummies/html/ec_belege_scans.html,
  .dev/kassenberichte dummies/img/IMG_3714.jpeg.

- Run 356a2: "+"-Button neben dem Papierkorb in jeder Getränkeliste-
  Zeile (Einstellungen) ergänzt. Fügt eine neue leere Zeile direkt
  unterhalb der angeklickten Zeile ein (_fuegeGetraenkNachIndexEin(
  index), ersetzt die alte _fuegeGetraenkHinzu(), die immer ans Ende
  der Liste angehängt hat). Zweck (Paco): MA musste bisher zum
  Hinzufügen ganz nach unten scrollen und das neue Getränk danach
  manuell an die richtige Regal-Position ziehen — mit dem Button pro
  Zeile landet die neue Zeile direkt in der Nähe der richtigen
  Position, kein Scrollen nötig. Der alte Button "+ Getränk
  hinzufügen" ganz unten ist damit entfallen (weggefallen statt nur
  ausgeblendet, keine doppelte Funktion). Version 0.9.30+356a2.
  Dateien: einstellungen_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 356a: Zwei Paco-Wünsche aus dem Run-356-Test. (A) Text-Button
  "Standard-Liste herunterladen" samt Hilfe-Icon aus der
  Getränkeliste-Kachel (Einstellungen) entfernt — beide gehörten
  zusammen (das Hilfe-Icon erklärte nur diesen Button), daher beide
  entfernt statt nur eines verwaist stehen zu lassen. Die dahinter
  liegenden, jetzt unreferenzierten Methoden _zeigeStandardListeHilfe
  und _ladeStandardListe (inkl. GetraenkeConfigService.
  updateFromRemote()-Aufruf) mit entfernt, kein toter Code übrig.
  (B) Zeile "Reihenfolge = Regal-Reihenfolge" von zentriert auf
  linksbündig umgestellt (crossAxisAlignment: CrossAxisAlignment.
  start auf der Card-Column in EinstellungenGetraenkelisteSection —
  betrifft dadurch auch die ReorderableListView darunter, die aber
  ohnehin schon die volle Breite nutzt, also ohne sichtbaren
  Unterschied dort). Version 0.9.30+356a. Dateien:
  einstellungen_seite.dart,
  einstellungen_getraenkeliste_section.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 356: Bugfix für den "seltsam überlagert" aussehenden Papierkorb-
  Button in der Getränkeliste (Einstellungen). Root Cause per lokalem
  Flutter-Web-Release-Build + Playwright isoliert verifiziert: die
  ReorderableListView.builder in _baueGetraenkelisteInhalt() nutzte
  die Standard-Einstellung buildDefaultDragHandles: true, wodurch
  Flutter die komplette Zeile mit einer eigenen Drag-Gesten-Erkennung
  umschließt — das verursacht auf Flutter Web einen Render-Fehler
  (verdoppelte/überlagerte Darstellung) bei Icons innerhalb dieser
  Zeile, obwohl bereits ein eigenes Drag-Handle-Icon (☰) existierte.
  Ausgeschlossen wurden zuvor: Browser-Cache (reproduziert auch in
  frischem Tab/Release-Build), Icon-Tree-Shaking (reproduziert auch
  mit --no-tree-shake-icons), das Icon selbst (isoliert einwandfrei)
  und reines Compositing (RepaintBoundary ändert nichts). Fix:
  buildDefaultDragHandles: false gesetzt und Icons.drag_handle mit
  ReorderableDragStartListener(index: index, ...) umschlossen —
  dadurch zieht jetzt gezielt nur noch das Handle-Icon statt der
  ganzen Zeile, was auch näher an der ursprünglichen Absicht liegt.
  Reiner Bugfix, keine sonstige Verhaltensänderung. Version
  0.9.30+356. Dateien: einstellungen_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 355: Sub-Run 1 einer neuen build()-Zerlegungs-Serie für
  einstellungen_seite.dart (build() 453 Zeilen, kein sections/-
  Ordner bisher, größter verbleibender Kandidat nach Schritt 1-3).
  Grundgerüst lib/pages/einstellungen/ (sections/, ui/) angelegt,
  analog zu tagesabschluss_schritt2/. Zwei einfache, eigenständige
  Blöcke ausgelagert: EinstellungenGetraenkelisteSection (auf-/
  zuklappbare Card, Inhalt weiterhin über die bestehende Methode
  _baueGetraenkelisteInhalt() im State) und
  EinstellungenPwaInstallSection (bedingte Install-Card). Neue
  ui/einstellungen_gruppen_orchestrierung.dart bündelt beide
  Sections (EinstellungenGruppenOrchestrierung.baueSections(...) →
  EinstellungenSectionWidgets), analog zu
  Schritt2GruppenOrchestrierung. build() dadurch von 453 auf
  397 Zeilen geschrumpft. Die große PIN-geschützte Admin-Card
  (5 unabhängige Bänder: Standort/Admin-Status, Wechselgeldbestand,
  Flurbocash-Anbindung, KI-Belegscan-Konfiguration, Dev-Modus/
  Testwerte) bleibt unverändert inline — Kandidat für die nächsten
  Sub-Runs dieser Serie, analog zur EC-Belege-Kachel bei Schritt 2.
  Reines Verschieben, keine Verhaltensänderung. Version 0.9.29+355.
  Dateien: einstellungen_seite.dart, sections/
  einstellungen_getraenkeliste_section.dart, sections/
  einstellungen_pwa_install_section.dart,
  einstellungen_gruppen_orchestrierung.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 354a2: Zweite Info-Zeile "Umsätze abzgl. Ausgaben (Info)" unter
  die in Run 354a ergänzte "Umsätze gesamt (Info)"-Zeile in der Kino-
  SOLL/Bistro-SOLL/Ausgaben-Kachel (Schritt 2) gesetzt — zeigt
  Kino-SOLL + Bistro-SOLL abzüglich der Summe aller erfassten
  Ausgaben-Beträge, live während der Eingabe. Neuer Parameter
  gesamtNachAusgabenCent durchgereicht: tagesabschluss_schritt2_
  seite.dart → ui/schritt2_gruppen_orchestrierung.dart → sections/
  schritt2_kino_soll_ausgaben_section.dart. Version 0.9.28+354a2.
  Dateien: tagesabschluss_schritt2_seite.dart,
  schritt2_gruppen_orchestrierung.dart,
  schritt2_kino_soll_ausgaben_section.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 354a: Auf Paco-Wunsch nach dem Run-354-Test eine reine Info-
  Zeile "Umsätze gesamt (Info)" am unteren Ende der Kino-SOLL/
  Bistro-SOLL/Ausgaben-Kachel in Schritt 2 ergänzt — zeigt Kino-SOLL
  + Bistro-SOLL (ohne Abzug der Ausgaben) als Live-Summe, während
  eingegeben wird. Für kino_04 (kein Bistro-SOLL-Feld) entspricht
  das schlicht dem Kino-SOLL. Neuer Parameter gesamtUmsatzCent
  durchgereicht: tagesabschluss_schritt2_seite.dart → ui/
  schritt2_gruppen_orchestrierung.dart → sections/
  schritt2_kino_soll_ausgaben_section.dart. Version 0.9.28+354a.
  Dateien: tagesabschluss_schritt2_seite.dart,
  schritt2_gruppen_orchestrierung.dart,
  schritt2_kino_soll_ausgaben_section.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 354: build()-Zerlegung für Schritt 3, analog zur Schritt-2-
  Serie (Run 345/347/348/350/353), aber in einem einzigen Run —
  Schritt 3 hat keine verschachtelten Listen oder async-Closures
  wie die EC-Belege bei Schritt 2, sondern nur vier statische
  Card-„Rahmen" ohne eigene Callback-Logik, daher reichte hier
  keine Sub-Run-Serie. Neuer Ordner lib/pages/
  tagesabschluss_schritt3/sections/ mit 5 StatelessWidgets:
  Schritt3KopfSection (Kinoname + Datum), Schritt3
  DifferenzAnfangsbestandSection, Schritt3SollSection (inkl.
  bedingter Bistro-Soll-Zeile), Schritt3IstSection,
  Schritt3DifferenzSection. build() in
  tagesabschluss_schritt3_seite.dart ruft diese jetzt auf statt
  die Cards inline zu bauen — dadurch von ~246 auf ~144 Zeilen
  geschrumpft. Der Sende-Aktionen-Block (Abrechnung-senden-Button,
  Dev-JSON-Button, Autosave-Fehlertext) bleibt bewusst inline, da
  eng an mehrere State-Felder (_autoSaveLaeuft, _abrechnungGesendet,
  _devModusAktiv, _autoSaveFehler) gekoppelt — Auslagerung hätte die
  Komplexität nur verschoben, nicht gesenkt (analog dazu, dass
  Schritt 1/2 appBar/footerChild bewusst inline lassen). Reines
  Verschieben ohne Verhaltensänderung. Version 0.9.28+354. Dateien:
  tagesabschluss_schritt3_seite.dart, sections/
  schritt3_kopf_section.dart, sections/
  schritt3_differenz_anfangsbestand_section.dart, sections/
  schritt3_soll_section.dart, sections/schritt3_ist_section.dart,
  sections/schritt3_differenz_section.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 353: Sub-Run 5 (Abschluss) der build()-Zerlegungs-Serie für
  Schritt 2 — finale Verdrahtung. Drei bisher inline gebliebene
  onChanged-Closures (Differenz-im-Anfangsbestand, Kino-SOLL,
  Bistro-SOLL) sowie die kleinen Personalgetränke-/Anmerkung-
  Callbacks in benannte Methoden ausgelagert
  (_beiDifferenzAnfangsbestandGeaendert, _beiKinoSollGeaendert,
  _beiBistroSollGeaendert, _beiPersonalgetraenkeGeaendert,
  _beiAnmerkungGeaendert) — analog zum bereits etablierten Muster
  aus Run 347/348/350. Die komplette EC-Belege-Bereich-Konstruktion
  (Read-Modus-Berechnung, belegInhalt-Ternary, Kachel- und
  Sub-Kacheln-Aufruf, äußere Widget-Liste inkl. Scan-Overlay und
  "Weiteren Beleg hinzufügen"-Link) wurde unverändert in eine neue
  Methode _baueEcBelegeBereich() verschoben, die build() nur noch
  mit einem Einzeiler aufruft. Geprüft: keine toten privaten
  `_baue…`-Methoden mehr vorhanden, alle drei verbleibenden
  (_baueEingabeZeile, _baueMetadatenBlock, _baueZahlungsartenTabelle)
  werden weiterhin aktiv gebraucht. build() schrumpft dadurch von
  ~345 auf ~197 Zeilen (Zielkorridor ~150–200 war explizit appBar/
  footerChild-inklusive gedacht, analog zum bereits fertigen
  Schritt-1-Vorbild, das diese beiden Blöcke ebenfalls nicht
  auslagert). Reines Verschieben ohne Verhaltensänderung — damit ist
  die komplette build()-Zerlegungs-Serie für Schritt 2 (Run 345,
  347, 348, 350, 353) abgeschlossen. Version 0.9.27+353. Dateien:
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 352: Zwei Paco-Wünsche aus dem Run-351-Test. (A) Foto-Buttons
  (EC-Belege-Kachel: runder Scan-Button im Header; jede EC-Beleg-
  Sub-Kachel: Kamera-Icon im Titel) von appBarRot (Kino-Rot) auf
  AppFarben.fokusFarbe (das bereits bestehende Orange, sonst für
  die Fokus-Füllfarbe von Eingabefeldern genutzt) umgestellt. (B)
  Zuklappen der EC-Belege-Hauptkachel klappt jetzt alle Sub-Kacheln
  und offenen Scan-Metadaten-Blöcke mit zu (_ecKachelToggleAuf-
  geklappt() in tagesabschluss_schritt2_seite.dart) — vorher blieben
  sie im Hintergrund aufgeklappt und waren beim nächsten Öffnen der
  Hauptkachel wieder sichtbar offen. Zusätzlich: manuelle Korrektur
  von Paco vor diesem Run übernommen — Label "3/4 · Finalisieren" in
  den Schritt-Wechsel-Bottom-Sheets von Schritt 1/2/3/4 auf
  "3/4 · Übertrag auf Umschlag" vereinheitlicht (4 Dateien: stueckelung_
  vorschlag_seite.dart, schritt1_orchestrierung_helper.dart,
  tagesabschluss_schritt2_seite.dart, tagesabschluss_schritt3_seite.dart).
  Version 0.9.26+352. Dateien: tagesabschluss_schritt2_seite.dart,
  sections/schritt2_ec_belege_kachel_section.dart, sections/
  schritt2_ec_beleg_sub_kacheln.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart,
  stueckelung_vorschlag_seite.dart,
  schritt1_orchestrierung_helper.dart, tagesabschluss_schritt3_seite.dart.

- Run 351: Korrektur aus dem Run-350-Test. Beim Zuklappen einer
  EC-Beleg-Sub-Kachel (2+-Beleg-Modus) blieb ein noch offener
  Scan-Metadaten-Block (_metadatenAufgeklappt) im Hintergrund
  aufgeklappt und war beim nächsten Aufklappen der Sub-Kachel
  weiterhin offen. _ecUnterkachelToggleAufgeklappt() in
  tagesabschluss_schritt2_seite.dart klappt jetzt beim Schließen der
  Sub-Kachel den zugehörigen Metadaten-Block ebenfalls zu. Version
  0.9.25+351. Datei: tagesabschluss_schritt2_seite.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 350: Sub-Run 4 der build()-Zerlegungs-Serie für Schritt 2
  (Fortsetzung von Run 345/347/348) — größter/riskantester Block der
  Serie. Neue Datei sections/schritt2_ec_beleg_sub_kacheln.dart:
  Schritt2EcBelegSubKacheln (Liste, rendert die Sub-Kacheln-Schleife
  für den 2+-Beleg-Modus) und privates Leaf-Widget
  _Schritt2EcBelegSubKachel (eine einzelne Sub-Kachel: Titel mit
  Terminal-ID/Betrag/Scan-Button/Löschen-Button, aufklappbarer Body
  mit Zahlungsarten-Tabelle/Metadaten-Block). Die async
  Lösch-Bestätigung (showDialog + Guard gegen Verwendung nach
  Await) lebt jetzt direkt im Leaf-Widget und nutzt dafür
  context.mounted statt des bisherigen State.mounted der Page —
  beides prüft dieselbe Bedingung (Element noch im Baum), nur
  bezogen auf den jeweils eigenen BuildContext; funktional
  gleichwertig, keine Verhaltensänderung. Zahlungsarten-Tabelle/
  Metadaten-Block werden weiterhin als Builder-Funktionen (nicht
  vorgebaute Widgets) durchgereicht, damit sie wie zuvor nur bei
  aufgeklappter Kachel mit vorhandenen Zahlungsart-Zeilen tatsächlich
  gebaut werden (keine unnötige Arbeit bei eingeklappten Kacheln).
  Vier neue kleine Methoden in der Page
  (_ecUnterkachelToggleAufgeklappt, _beiSubKachelTidGeaendert,
  _hatZahlungsartZeilenFuerBeleg, _hatScanStattgefundenFuerBeleg,
  _ecUnterkachelFertig) ersetzen bisherige Inline-Closures.
  Schritt2GruppenOrchestrierung um baueEcBelegSubKacheln()
  erweitert. Reines Verschieben ohne Verhaltensänderung — damit ist
  die komplette EC-Belege-Kachel (Sub-Runs 3+4) jetzt aus der
  Page-build()-Methode ausgelagert. Version 0.9.24+350. Dateien:
  tagesabschluss_schritt2_seite.dart, ui/
  schritt2_gruppen_orchestrierung.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart; neu: sections/
  schritt2_ec_beleg_sub_kacheln.dart.

- Run 349: Zwei kleine UI-Korrekturen aus dem Run-348-Test.
  (A) Konsistenz-Wunsch: Die Wertefelder für Kartenzahlungen
  (Kartenart-Betrag je Zeile in Schritt2KartenartenZeile sowie das
  Gesamtbetrag-Feld in Schritt2ZahlungsartenTabelle,
  ui/schritt2_ui_builder.dart) hatten als einzige Geldfelder der
  App keinen "×"-Löschen-Button, da sie als rohe TextFields gebaut
  sind statt über BetragCentEingabefeld (das serienmäßig einen
  Clear-Chip zeigt). Jetzt beide mit suffixIcon + baueClearAktion()/
  clearIconFarbe() aus dem bereits vorhandenen
  eingabefeld_clear_helper.dart ergänzt — analog zum bestehenden
  Muster in Schritt2MetadatenEditZeile. (B) In den EC-Beleg-
  Sub-Kacheln (2+-Beleg-Modus, tagesabschluss_schritt2_seite.dart)
  stieß das Expanded-Terminal-ID-Feld im Titel direkt an den
  Gesamtbetrag. Neues SizedBox(width: 8) zwischen Feld und Betrag
  sorgt für sichtbaren Abstand (Feld wird dadurch faktisch etwas
  schmaler, da Expanded den verbleibenden Platz beansprucht).
  Version 0.9.23+349. Dateien: ui/schritt2_ui_builder.dart,
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 348: Sub-Run 3 der build()-Zerlegungs-Serie für Schritt 2
  (Fortsetzung von Run 345/347). Zwei neue Dateien: sections/
  schritt2_ec_beleg_terminal_id_zeile.dart
  (Schritt2EcBelegTerminalIdZeile — Read-Modus-Anzeige nach Scan
  bzw. editierbares Terminal-ID-Feld, wiederverwendbar für einen
  künftigen Sub-Run 4 an den Sub-Kacheln) und sections/
  schritt2_ec_belege_kachel_section.dart
  (Schritt2EcBelegeKachelSection — Card mit Header
  [Aufklapp-Toggle, Scan-Button, Kartendaten-löschen-Button,
  Belege-/Summe-Anzeige] und aufklappbarem Body-Rahmen
  [Leerzustand-Hinweis bzw. "Weiteren Beleg hinzufügen"-Button]).
  Der eigentliche Beleg-Inhalt (1-Beleg-Modus oder Sub-Kacheln im
  2+-Beleg-Modus) wird als fertiges Widget durchgereicht
  (belegInhalt) — die Sub-Kacheln-Schleife für den 2+-Beleg-Modus
  bleibt unverändert und wird erst in einem künftigen Sub-Run 4
  ausgelagert (größter/riskantester Block, enthält eine async
  Lösch-Bestätigung mit mounted-Check). Vier neue kleine Methoden
  in der Page (_ecKachelToggleAufgeklappt, _manuellEingebenTap,
  _beiEcBelegLabel1Geaendert, _ecBelegLabel1Loeschen) ersetzen
  bisherige Inline-Closures. Schritt2GruppenOrchestrierung um
  baueEcBelegeKachel() erweitert. Reines Verschieben ohne
  Verhaltensänderung. Version 0.9.22+348. Dateien:
  tagesabschluss_schritt2_seite.dart, ui/
  schritt2_gruppen_orchestrierung.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart; neu: sections/
  schritt2_ec_beleg_terminal_id_zeile.dart, sections/
  schritt2_ec_belege_kachel_section.dart.

- Run 347: Sub-Run 2 der build()-Zerlegungs-Serie für Schritt 2
  (Fortsetzung von Run 345). Neue Datei sections/
  schritt2_kino_soll_ausgaben_section.dart: Schritt2KinoSollUnd-
  AusgabenSection (Card mit Kino-SOLL/Bistro-SOLL + Ausgaben-Liste)
  und neues privates Leaf-Widget _Schritt2AusgabenZeile (Bezeichnung-
  Feld + Betrag-Feld + optionaler Löschen-Button pro Ausgabe,
  analog zum Umschläge-Zeilen-Muster aus Schritt 1). Kino-SOLL- und
  Bistro-SOLL-Eingabezeilen werden weiterhin per _baueEingabeZeile()
  in der Page gebaut und als fertige Widgets übergeben (Bistro-SOLL
  null bei kino_04, analog zum Fokus-Filter aus Run 346). Drei neue
  kleine Callback-Methoden in der Page
  (_beiAusgabenLabelGeaendert, _ausgabenLabelLoeschen,
  _beiAusgabenBetragGeaendert) ersetzen die bisherigen Inline-
  Closures. Schritt2GruppenOrchestrierung.baueSections() und
  Schritt2SectionWidgets um kinoSollUndAusgaben erweitert. Reines
  Verschieben ohne Verhaltensänderung. Version 0.9.21+347. Dateien:
  tagesabschluss_schritt2_seite.dart, ui/
  schritt2_gruppen_orchestrierung.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart; neu: sections/
  schritt2_kino_soll_ausgaben_section.dart.

- Run 346: Zwei beim Testen von Run 345 entdeckte, vorbestehende
  Next-Button-Bugs behoben (keine Regression aus Run 345, siehe
  Diagnose davor). (A) Der "Next"-Button im Footer von Schritt 1
  UND Schritt 2 wurde bisher nur angezeigt, wenn die native
  virtuelle Tastatur eingeblendet war (`tastaturOffen`, basiert auf
  `MediaQuery.viewInsets.bottom`) — im Desktop-Browser gibt es keine
  virtuelle Tastatur, der Button erschien dort nie. Fix: neue
  Bedingung `feldFokussiert` (prüft, ob ein FocusNode aus der
  jeweiligen Fokus-Reihenfolge `hasFocus` ist) zusätzlich zu
  `tastaturOffen` verknüpft; damit ein Fokuswechsel überhaupt einen
  Rebuild auslöst, wurde in beiden Seiten ein globaler
  `FocusManager.instance`-Listener (`_beiGlobalerFokusAenderung`) in
  initState registriert und in dispose() wieder entfernt. (B) Auf
  der Kino-SOLL-Card von Schritt 2 sprang "Weiter" beim Standort
  Cinema Ostertor (kino_04, Kürzel "CO" — hat kein Bistro-SOLL-Feld)
  von Kino-SOLL aus nirgendwohin: `Schritt2FokusHelper.
  fokusReihenfolge()` nahm `bistroSollFocusNode` bedingungslos in die
  Liste auf, obwohl das zugehörige Widget für kino_04 gar nicht
  gebaut wird. Fix: `_fokusReihenfolgeSchritt2()` in
  tagesabschluss_schritt2_seite.dart entfernt `_bistroSollFocusNode`
  jetzt aus der vom Helper gelieferten Liste, wenn
  `widget.kinoId == 'kino_04'` ist (analog zum bereits vorhandenen
  Kupfer-Rollen-Filtermuster aus Schritt 1). Version 0.9.20+346.
  Dateien: tagesabschluss_schritt1_seite.dart,
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 345: Sub-Run 1 der build()-Zerlegungs-Serie für Schritt 2
  (analog zu Schritt 1s sections/-Ordner, Fortsetzung der
  Run-341–344-Serie). Neuer Ordner
  lib/pages/tagesabschluss_schritt2/sections/ mit vier eigenständigen
  Section-Widgets: Schritt2KopfSection (Titel + Datum),
  Schritt2PersonalgetraenkeSection, Schritt2DifferenzAnfangsbestand-
  Section, Schritt2AnmerkungSection. Neue Datei ui/
  schritt2_gruppen_orchestrierung.dart (Schritt2GruppenOrchestrierung,
  const, analog zu schritt1_gruppen_orchestrierung.dart) baut diese
  vier Sections aus State/Callbacks der Page zusammen
  (Schritt2SectionWidgets-Bündel). Neue Datei ui/
  schritt2_body_content.dart (Schritt2BodyContent) übernimmt den
  äußeren Stack/Theme/NotificationListener/ListView/Down-Button-Aufbau
  vollständig von der Page — noch nicht ausgelagerte Bereiche (Kino-/
  Bistro-SOLL+Ausgaben-Card, EC-Belege-Kachel) werden unverändert als
  fertige Widgets/Widget-Liste durchgereicht und in den nächsten
  Sub-Runs schrittweise ersetzt. Reines Verschieben ohne
  Verhaltensänderung — build() in tagesabschluss_schritt2_seite.dart
  schrumpft dadurch nur um die vier extrahierten Abschnitte, der Rest
  bleibt inhaltlich identisch (nur als lokale Variablen vor dem
  return statt inline in der Widget-Liste). Version 0.9.19+345.
  Dateien: tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart; neu: sections/
  schritt2_kopf_section.dart, schritt2_personalgetraenke_section.dart,
  schritt2_differenz_anfangsbestand_section.dart,
  schritt2_anmerkung_section.dart, ui/
  schritt2_gruppen_orchestrierung.dart, ui/schritt2_body_content.dart.

- Run 344: Zwei beim Testen von Run 343 entdeckte Lücken behoben
  (keine Regression aus Run 343, beide bestanden schon vorher —
  siehe Diagnose im Chat). (A) Kartenart-Betragsfelder (Girocard
  usw.) fehlten komplett in der Fokus-/Weiter-Reihenfolge: TID
  sprang direkt zum Gesamtbetrag, "Weiter" aus einer Kartenart-Zeile
  landete zufällig beim ersten Feld der Seite (Flutters Default-
  Traversal, da kein eigenes onKeyEvent gesetzt war). Fix:
  Schritt2FokusHelper.fokusReihenfolge() und .erstesLeeresFeld()
  um zahlungsartZeilen-Parameter erweitert (nur Zeilen mit
  zustand==editing zählen); _verknuepfeFeldNavigationSchritt2() wird
  jetzt an allen 4 Erzeugungsstellen von ZahlungsartZeile aufgerufen
  (initState-Konfigladung, _ecBelegHinzufuegen,
  _setzeEcBelegAnzahl, _preFillZahlungsartenFromScan). (B) Auf
  Paco-Wunsch: Seitenweiter Down-Button wie in Schritt 1 (kleiner
  FloatingActionButton unten links, springt ans Seitenende)
  übernommen — neue Datei tagesabschluss_schritt2/scroll/
  schritt2_scroll_helper.dart (Schritt2ScrollHelper, analog zu
  schritt1_scroll_helper.dart). ListView jetzt in
  NotificationListener<ScrollMetricsNotification> + Stack gewickelt.
  Der bisherige passive Fade-Pfeil am unteren Rand der EC-Kachel
  (seit Run 274a, nicht tippbar, RenderObject-basiert) wurde dafür
  komplett entfernt (Feld _ecKachelZeigeScrollPfeil, _ecKachelKey,
  Methode _aktualisiereScrollPfeil, zugehörige Helper-Methode in
  Schritt2FokusHelper, alle Aufrufstellen, der Positioned-Block in
  build()) — auf Paco-Wunsch durch den neuen Button ersetzt statt
  parallel behalten. Version 0.9.18+344. Dateien:
  tagesabschluss_schritt2_seite.dart, schritt2_fokus_helper.dart,
  neu: schritt2_scroll_helper.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 343: Architektur-Refactor (Fortsetzung der Run-341-Serie):
  Fokus-Reihenfolge/-Navigation und Scroll-zu-Feld-/Scroll-Pfeil-
  Logik aus tagesabschluss_schritt2_seite.dart nach neuer Datei
  lib/pages/tagesabschluss_schritt2/controller/schritt2_fokus_helper.dart
  ausgelagert (Klasse Schritt2FokusHelper, const, State wird per
  Parameter injiziert — analog zu schritt1_state_controller.dart).
  Betroffen: _fokusReihenfolgeSchritt2, _istLetztesFeldSchritt2,
  _naechstesFeldSchritt2, _textInputActionFuerSchritt2,
  _beiEingabeAbgeschlossenSchritt2, _fokussiereFeldSchritt2,
  _verknuepfeFeldNavigationSchritt2, _scrolleZurMitteNachFokus,
  _erstesLeeresFeld, _autoFokussiereNachLaden,
  _aktualisiereScrollPfeil — alle bleiben als dünne Wrapper-
  Methoden in der Hauptdatei erhalten, Call-Sites im build()-Baum
  unverändert. Reines Verschieben ohne Verhaltensänderung; einzige
  Ausnahme technischer Natur: der mounted-Check in
  scrolleZurMitteNachFokus wird jetzt über eine Closure
  (istMounted: () => mounted) statt eines zur Aufrufzeit
  eingefrorenen bool-Werts geprüft, damit der Check nach dem
  500ms-Delay weiterhin den aktuellen State liest (vorher bereits
  so beabsichtigt, jetzt explizit gemacht). Zusätzlich gebündelt
  (auf Paco-Wunsch mit diesem Commit statt eigenem Sub-Run):
  Feldbreite "Differenz im Anfangsbestand" (Fortsetzung Run 342a)
  von 160px auf 120px reduziert. Version 0.9.17+343. Dateien:
  tagesabschluss_schritt2_seite.dart, neu:
  tagesabschluss_schritt2/controller/schritt2_fokus_helper.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 342a: Korrektur zu Run 342 nach Paco-Feedback — das auf
  190px verbreiterte Feld "Differenz im Anfangsbestand" wirkte zu
  groß. Neuer Parameter zeigeAdditionsButton (Default true) in
  BetragCentEingabefeld, Schritt2EingabeZeile und _baueEingabeZeile
  durchgereicht: für dieses Feld auf false gesetzt, da eine einzelne
  Differenz ohnehin nicht wie ein Münzstapel aus mehreren addierten
  Teilbeträgen erfasst wird. Dadurch fällt der "+"-Chip weg und das
  Feld kann auf 160px schrumpfen, ohne dass der Wert wieder
  abgeschnitten wird ("X"-Löschen-Chip bleibt). Alle anderen
  BetragCentEingabefeld-Stellen (Kino-SOLL, Bistro-SOLL, Ausgaben
  etc.) unverändert, da Default true. Live mit Playwright verifiziert
  (Wert vollständig sichtbar, Fokussprung zu Kino-SOLL weiterhin ok).
- Run 342: Zwei Korrekturen am Feld "Differenz im Anfangsbestand"
  (Schritt 2), beim Testen von Run 341 entdeckt (selbst keine
  Regression aus Run 341, siehe Diagnose davor). (1) Optik an
  Kino-SOLL/Bistro-SOLL angeglichen: Label links, 190px breites
  Eingabefeld rechts (statt Label darüber + 148px schmaler Box, in
  der der eingegebene Wert im fokussierten Zustand neben "+"/"×"
  abgeschnitten wurde). Der "±"-Vorzeichen-Button bleibt zusätzlich
  daneben erhalten. (2) Fokus-Reihenfolge korrigiert:
  _fokusReihenfolgeSchritt2() führte dieses Feld bisher als LETZTES,
  obwohl es visuell ZUERST auf dem Screen steht — "Weiter" von dort
  aus schloss dadurch nur die Tastatur, statt zu Kino-SOLL zu
  springen. Jetzt an erster Stelle der Liste, Fokus springt korrekt
  weiter. Live mit Playwright gegen den gebauten Web-Build verifiziert
  (Screenshot vor/nach, Fokuswechsel nach Enter bestätigt).
- Run 341a: Korrektur zu Run 341 — Versionsbump vergessen. pubspec.yaml
  und der Versionsstring in startmenue_seite.dart/kinoauswahl_seite.dart
  jetzt auf 0.9.15+341a aktualisiert (Präzedenzfall Run 330 zeigt: auch
  rein interne Refactoring-Runs ohne Nutzer-sichtbare Änderung bekommen
  einen Versionsbump — die gegenteilige Annahme in Run 341 war falsch).
  Keine weiteren Code-Änderungen.
- Run 341: Architektur-Run, erster Schritt einer Serie: Schritt 2
  (tagesabschluss_schritt2_seite.dart, zuvor 3934 Zeilen) analog zu
  Schritt 1 (Run 40–58) in Untermodule aufgeteilt. Reine
  Widget-Bau-Methoden ohne Logikänderung ausgelagert nach
  lib/pages/tagesabschluss_schritt2/ui/schritt2_ui_builder.dart
  (Schritt2DevToolsPanel, Schritt2EingabeZeile,
  Schritt2MetadatenInfoZeile, Schritt2MetadatenEditZeile,
  Schritt2MetadatenBlock, Schritt2KartenartenZeile,
  Schritt2KartenartenZeileAnzeige, Schritt2KartenartenEditButton,
  Schritt2ZahlungsartenTabelle). Die bisher private Klasse
  _ZahlungsartZeile wurde dafür nach ZahlungsartZeile umbenannt und
  zusammen mit ZeilenZustand in ein eigenes Modell
  lib/pages/tagesabschluss_schritt2/models/zahlungsart_zeile.dart
  verschoben (verhindert einen zirkulären Import). Kein
  UI-/Verhaltensunterschied beabsichtigt — reines Verschieben von
  Code, nur mit expliziten Konstruktor-Parametern statt direktem
  Zugriff auf private State-Felder. Datei dadurch von 3934 auf 3381
  Zeilen reduziert; weitere Runs der Serie folgen (State/Controller,
  restlicher UI-Baum). Kein Versionsbump, da reines Refactoring ohne
  Nutzer-sichtbare Änderung (analog zu den Schritt-1-Auslager-Runs).
- Run 340a: Zwei Text-Links hatten keine eigene Tap-Fläche (nur so
  groß wie der Text selbst) und lagen direkt in einem größeren,
  konkurrierenden InkWell/GestureDetector (Kachel-Header, der beim
  Antippen auf-/zuklappt). Bei knapp danebengesetzten Taps gewann
  der äußere Header-Klick — bei "Aus Zählung von vorhin übernehmen"
  (Rollen-Kachel, wechselgeld_pruefen_seite.dart) klappte dadurch
  die Kachel zu, statt die Werte zu übernehmen. Fix: beide Links
  ("Aus Zählung von vorhin übernehmen" / "Geldrollen löschen" in
  wechselgeld_pruefen_seite.dart sowie "manuell eingeben" bei den
  EC-Belegen in tagesabschluss_schritt2_seite.dart) haben jetzt
  eigenes Padding um die Tap-Fläche, damit sie zuverlässiger treffen.
- Run 340: Zwei Paco-Wünsche aus dem Run-339-Test umgesetzt. (1) Der
  Button "Kassenabrechnung (4 Schritte)" auf der Kino-Startseite zeigt
  jetzt einen grünen Haken, wenn für dieses Kino heute schon
  "Abrechnung an Büro senden" erfolgreich war. Kein neuer
  Persistenz-Key nötig: die bereits vorhandene Sende-Bestätigung
  (LokalerSpeicher.ladeSendeBestaetigung, JSON-Signatur aus Schritt 3
  mit 'isoDatum'-Feld) wird ausgelesen und deren isoDatum gegen das
  aktuelle logische Datum verglichen. (2) Auf der Stückelung-Seite
  steht jetzt ein Hinweistext ("Barumsatz und Belege in den Umschlag
  tun.") direkt über dem "Fertig."-Button — kein Tracking der
  physischen Übertragung, die ergibt sich laut Paco von selbst aus dem
  Hinweis. Version 0.9.14+340. Dateien: startmenue_seite.dart,
  stueckelung_vorschlag_seite.dart, pubspec.yaml, kinoauswahl_seite.dart.

- Run 339: Vier kleine UI-Korrekturen. (1) Die kleinen "Next"-Buttons
  (Feld-Sprung beim Tippen) hatten in drei Dateien vertauschte Farben
  (rot/weiß statt weiß/rot wie in getraenke_auffuellen_seite.dart) —
  jetzt überall einheitlich weißer Hintergrund, rote Schrift. (2) Die
  Wörter "Anzahl" und "Cent" in den Kacheltiteln von Schritt 1 und der
  Wechselgeldkasse haben jetzt einen orangenen Textmarker-Hintergrund
  (AppFarben.fokusFarbe) zusätzlich zur bisherigen roten Fettschrift.
  (3) Auf der Seite "Übertrag auf Umschlag" (Schritt 3) ist der Button
  "Abrechnung an Büro senden" jetzt orange statt dunkelrot. Der Button
  "Stückelung (4/4)" bleibt ausgegraut, bis die Abrechnung gesendet
  wurde (geprüft über das bestehende _abrechnungGesendet-Flag); ein
  Tap im ausgegrauten Zustand zeigt eine orange SnackBar mit Hinweis
  ("Bitte zuerst die Abrechnung senden."). (4) Auf der Stückelung-Seite
  heißt der Abschluss-Button jetzt nur noch "Fertig." (orange/dunkelrot)
  und führt direkt zur Startseite (Navigator.popUntil auf Startmenue),
  statt erneut den Sende-Dialog auszulösen — beide bisherigen Wege zu
  dieser Seite (Schritt-3-Footer, "Was möchtest du als Nächstes"-Dialog)
  sind ohnehin nur nach erfolgreichem Senden erreichbar. Der dadurch
  ungenutzte onAbschliessen-Callback wurde aus StueckelungVorschlag-
  Argumente entfernt. Version 0.9.14+339. Dateien:
  tagesabschluss_schritt1_seite.dart, tagesabschluss_schritt2_seite.dart,
  wechselgeld_pruefen_seite.dart, schritt1_scheine_section.dart,
  schritt1_muenzen_rollen_section.dart, schritt1_muenzen_lose_section.dart,
  schritt1_gruppen_orchestrierung.dart, tagesabschluss_schritt3_seite.dart,
  stueckelung_vorschlag_seite.dart, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 338: App startete im Flugmodus (offline) nicht mehr, obwohl
  vorher schon alles korrekt im Service-Worker-Cache lag. Ursache:
  der Fresh-Tab-Reset aus Run 295 (`web/index.html`) löscht bei
  jedem Kaltstart bedingungslos ALLE Caches und meldet den Service
  Worker ab, bevor er einen `location.reload()` erzwingt — nach
  dem Löschen existiert weder Cache noch Service Worker mehr, der
  Reload muss also zwingend das Netzwerk erreichen. Im Flugmodus
  schlägt das fehl, die App bleibt am Splash-Screen hängen. Fix:
  der Reset läuft jetzt nur noch, wenn `navigator.onLine === true`
  ist. Offline bleibt der bestehende Service-Worker-Cache erhalten,
  die App startet normal daraus. Online-Verhalten (immer neueste
  Version) unverändert. Voraussetzung bleibt, dass das Gerät die
  App mindestens einmal online geladen hat (bei den vorkonfiguriert
  ausgelieferten Geräten ohnehin gegeben). Version 0.9.14+338.
  Datei: web/index.html, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 337a2: Zwei weitere Korrekturen aus Pacos iPhone-PWA-Test von
  337a. (1) Flugmodus-Test enthüllte Kernproblem der bisherigen
  Logik: `ApiUploadService.isCorsArtFehler()` erkennt anhand reiner
  Fehlertext-Heuristiken ("Failed to fetch", "NetworkError", "Load
  failed") — dieselben Texte liefert der Browser aber sowohl bei
  echter CORS-Blockade (Request kam beim Server an, nur die Antwort
  ist nicht lesbar) als auch bei komplettem Verbindungsausfall
  (Request hat das Gerät nie verlassen, z. B. Flugmodus). Beide
  Fälle sind aus dem Fehlertext heraus nicht zuverlässig
  unterscheidbar. Der grüne Haken darf sich daher nicht mehr auf
  diesen Fallback-Fall stützen — er erscheint jetzt ausschließlich
  beim echten, eindeutigen Upload-Erfolg (kein Exception). Beim
  CORS-Fallback bleibt weiterhin nur die SnackBar "Upload gesendet —
  Empfang nicht bestätigbar", ohne Haken. (2) Der Haken verschwand
  bisher beim Verlassen der Seite (reiner In-Memory-State). Neue
  Persistenz `LokalerSpeicher.speichereSendeBestaetigung()` /
  `ladeSendeBestaetigung()` (SharedPreferences, Key pro Kino)
  speichert eine Signatur der gesendeten Eingabedaten (alle
  Cent-Beträge, Stückzahlen, Labels, Anmerkung — bewusst ohne
  Zeitstempel). Schritt 3 vergleicht beim Laden die aktuelle
  Signatur mit der gespeicherten: stimmen sie überein, bleibt der
  Haken sichtbar; wurde seither eine Eingabe geändert (andere
  Signatur) oder wurde noch nie erfolgreich gesendet, bleibt er aus
  — ohne dass eine explizite "Änderungserkennung" nötig ist. Version
  0.9.13+337a2. Dateien: tagesabschluss_schritt3_seite.dart,
  lokaler_speicher.dart, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 337a: Korrektur aus Pacos iPhone-PWA-Test von Run 337: der
  grüne Sende-Haken (Punkt 5 aus Run 337) erschien auch dann, wenn
  der Flurbocash-API-Upload laut SnackBar fehlgeschlagen war.
  Ursache: `_doApiUpload().ignore()` ist bewusst fire-and-forget
  (Dialog soll sofort öffnen, nicht auf die Netzwerkantwort
  warten) — der Haken wurde direkt danach gesetzt, unabhängig vom
  tatsächlichen Ergebnis. Fix: Haken wird jetzt asynchron erst
  gesetzt, wenn `_doApiUpload()` abgeschlossen ist UND
  `_apiUploadErledigt` tatsächlich true ist (Erfolg oder der
  bereits bestehende CORS-Empfang-nicht-bestätigbar-Fall) — bei
  echtem Fehler bleibt er aus. Ist die API-Upload-Funktion für ein
  Kino gar nicht aktiv (FeatureFlags.apiUploadAktiv() == false,
  aktuell der Regelfall), erscheint der Haken weiterhin sofort,
  da dort lediglich die bereits erfolgte lokale Speicherung
  gemeint ist. Dialogöffnung bleibt unverändert sofort, keine
  zusätzliche Wartezeit. Version 0.9.13+337a. Datei:
  tagesabschluss_schritt3_seite.dart.

- Run 337: Fünf kleine Korrekturen aus Paco-Feedback, gebündelt in
  einem Run (unabhängige, risikoarme Änderungen). (1) AppBar der
  Kino-Homepage zeigt jetzt "<Kinoname> Abrechnung" statt nur den
  Kinonamen (startmenue_seite.dart). (2) Personalgetränke-Flag
  ("Personalgetränke gebont?" in Schritt 2) wurde nirgends
  persistiert und ging bei Verlassen/Neuladen der Seite verloren —
  jetzt Teil von _speichereEntwurf()/_ladeEntwurf() (additiv,
  rückwärtskompatibel: alte Entwürfe ohne das Feld laden mit Default
  false). (3) Root-Cause für "JSON anzeigen" außerhalb des Dev-Modus
  gefunden: DevModus.istAktiv() hatte Default `?? true` — auf jedem
  vorkonfiguriert ausgelieferten Gerät, auf dem der Schalter nie
  manuell umgelegt wurde, war der Dev-Modus damit für alle MA aktiv.
  Default auf `false` korrigiert (dev_modus.dart). (4) Die
  "Weiter"-Footer-Buttons (Schritt 1/2/3, Getränke auffüllen,
  Wechselgeld prüfen) waren weiß mit rotem Text; AppFarben.
  footerButtonStyle-Hintergrund zentral auf das bereits vorhandene
  Orange (fokusFarbe) umgestellt. (5) Nach Tap auf "Abrechnung an
  Büro senden" (Schritt 3) erscheint jetzt ein grünes Häkchen-Icon
  hinter dem Button-Text, sobald der Autosave sicher erledigt ist
  und der Folge-Dialog geöffnet wird (neues Flag
  _abrechnungGesendet) — unabhängig vom API-Upload-Feature-Flag.
  Version 0.9.13+337. Dateien: startmenue_seite.dart,
  kinoauswahl_seite.dart, tagesabschluss_schritt2_seite.dart,
  tagesabschluss_schritt3_seite.dart, dev_modus.dart,
  app_farben.dart, pubspec.yaml.

- Run 336a4: Paco-Feedback: Eingabefelder wurden höher, sobald ein
  Wert (und damit die "+"/"X"-Buttons) drinstand — unerwünscht,
  Vorgabe: Feldhöhe soll konstant bleiben, Ränder dürfen näher an die
  Buttons rücken. Ursache: GanzzahlEingabefeld erzwang den Suffix nur
  bei hatText mit fester Höhe 36 (SizedBox), leeres Feld hatte gar
  keinen Suffix → sichtbarer Sprung beim ersten Zeichen.
  BetragCentEingabefeld hatte durch dieselbe feste Höhe 36 zwar
  durchgängig, aber gegenüber vorher unnötig viel Platz. Fix: feste
  SizedBox-Höhe komplett entfernt (Row sizt sich jetzt natürlich an
  ihrem größten Kind aus), Chip-Vertikal-Padding von
  baueEingabefeldAktionsChip() von 6+4 auf 0+2 reduziert (nur noch
  horizontal zusätzliches Tipp-Polster, das die Höhe nicht
  beeinflusst). Per Playwright gegen einen lokalen Release-Build
  verifiziert: befüllte und leere Zeilen (Scheine, lose Münzen)
  jetzt sichtbar gleich hoch. Version 0.9.12+336a4. Dateien:
  eingabefeld_clear_helper.dart, betrag_cent_eingabefeld.dart,
  ganzzahl_eingabefeld.dart, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 336a3: Diesmal per Playwright gegen einen lokalen Release-Build
  selbst visuell geprüft (Build + Python-http.server + Chromium-
  Screenshots über mehrere Bildschirme bis Schritt 1). Dabei zwei
  eigene Erkenntnisse ohne neue Paco-Rückmeldung umgesetzt: (1) Beim
  Klick-Testen der neuen "+"/"X"-Chips aus Run 336a2 brauchte selbst
  ein pixelgenauer Mausklick mehrere Anläufe, um zu treffen — die
  tatsächliche Tippfläche war kleiner als sichtbar. baueEingabefeld-
  AktionsChip() bekommt jetzt eine unsichtbar größere Tippfläche
  (GestureDetector mit HitTestBehavior.opaque + zusätzlichem Padding)
  ohne den sichtbaren Chip zu vergrößern; Trennlinien-Rand von 6 auf 4
  reduziert, um die Zeile nicht unnötig breiter zu machen. Suffix-
  Höhe in beiden Feldern von 26 auf 36 erhöht, damit die größere
  Tippfläche nicht abgeschnitten wird. (2) Alle Layout-Änderungen aus
  336a/336a2 (Chip-Design, Feldbreiten, Cursor-Position,
  Additions-Workflow in Betrags- UND Anzahlfeld) end-to-end mit
  echten Klicks nachgestellt und per Screenshot bestätigt — keine
  Overflow- oder Konsolenfehler. Version 0.9.12+336a3. Dateien:
  eingabefeld_clear_helper.dart, betrag_cent_eingabefeld.dart,
  ganzzahl_eingabefeld.dart, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 336a2: Fünf Korrekturen aus Pacos zweitem Gerätetest von Run
  336/336a (mit Skizze). (1) "+"/"X" jetzt als eigene graue Button-
  Chips (Hintergrund + Rundung) statt bloßer Icons, echte Trennlinien
  zwischen Wert/€, "+" und "X" statt nur SizedBox-Abstand — neue
  gemeinsame Helfer baueEingabefeldTrennlinie()/
  baueEingabefeldAktionsChip() in eingabefeld_clear_helper.dart, von
  BetragCentEingabefeld UND GanzzahlEingabefeld genutzt. Bewusst NICHT
  die im Sketch gezeigte volle feldhohe Zellen-Trennung umgesetzt, da
  das InputDecoration (labelText/fehlermeldungText) hätte umgangen
  werden müssen. (2) Eingabefelder verbreitert, damit dreistellige
  Zahlen/Beträge nicht mehr abgeschnitten werden: Scheine-Anzahl
  96→140, lose Münzen 148→190, Umschläge 132→172, Kassenbons-Betrag
  148→190, Ausgaben-Betrag 120→155. (3) BetragCentEingabefeld:
  textAlign von center auf right geändert, damit der Betrag direkt am
  Eurozeichen anliegt statt durch Zentrierung Abstand zu bekommen.
  (4) Keyboard-Dismiss-Bug: Tippen auf "+" bei bereits fokussiertem
  Feld ließ die virtuelle Tastatur auf iOS Safari verschwinden;
  requestFocus() wird jetzt nur noch aufgerufen, wenn das Feld vorher
  NICHT fokussiert war (Best-Effort-Fix, auf echtem Gerät noch zu
  verifizieren). Version 0.9.12+336a2. Dateien:
  eingabefeld_clear_helper.dart, betrag_cent_eingabefeld.dart,
  ganzzahl_eingabefeld.dart, schritt1_ui_builder.dart,
  schritt1_umschlaege_section.dart, tagesabschluss_schritt2_seite.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 336a: Drei Korrekturen aus Pacos erstem Gerätetest (iPhone
  Safari) von Run 336. (1) Die numerische iPhone-Tastatur zeigt kein
  "+", betraf aber auch das Stückzahl-Feld (GanzzahlEingabefeld, z.B.
  Scheine-Anzahl) — dort gab es noch gar keinen "+"-Button. Neuer
  GanzzahlSegmentLaengeFormatter begrenzt jedes "+"-Segment einzeln
  auf maxLaenge statt die Gesamtlänge zu deckeln (sonst würde z.B.
  bei maxLaenge 3 "12+3" zu "12+" abgeschnitten); neue
  TagesabschlussBerechnung.parseGanzzahlSumme summiert "+"-getrennte
  Ganzzahlen, Schritt1StateController.parseGanzzahl nutzt sie jetzt
  statt eigener Parse-Logik. (2) Tippen auf den "+"-Button markierte
  den kompletten Bestandstext (Browser/iOS wählt beim programmatischen
  Fokussieren teils alles an) — Cursor wird jetzt nach dem Frame per
  addPostFrameCallback erneut ans Ende gesetzt, damit direkt weiter-
  getippt werden kann. Betrifft BetragCentEingabefeld UND
  GanzzahlEingabefeld. (3) Icon-Reihenfolge im Betragsfeld-Suffix
  korrigiert: Eurozeichen jetzt zuerst (direkt nach dem Betrag), dann
  "+"-Button, dann Löschen-X — mit größerem Abstand zwischen "+" und
  X, da diese sonst schlecht einzeln zu treffen waren. Version
  0.9.12+336a. Dateien: ganzzahl_eingabefeld.dart,
  betrag_cent_eingabefeld.dart, tagesabschluss_berechnung.dart,
  schritt1_state_controller.dart, tagesabschluss_berechnung_test.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 336: "+"-Additions-Eingabe im BetragCentEingabefeld (Scheine,
  Rollen, lose Münzen, Umschläge, Kassenbons/Wechselgeld). Auslöser:
  Frage, ob man beim Zählen (z. B. Geldscheine in zwei Etappen, oder
  nachträglich gefundene Münzen) einfach "260+20" statt selbst
  ausrechnen könnte. CentWaehrungsEingabeFormatter formatiert jetzt
  jedes "+"-getrennte Segment live (z. B. "260+20" → "2,60+0,20"
  während der Eingabe); nach Fokusverlust wird zum Endbetrag
  zusammengefasst ("2,80"). Neuer "+"-Button im Feld (neben dem
  bestehenden Clear-Icon), da Android-Zifferntastaturen meist kein
  "+" haben — zusätzlich Tastatur auf TextInputType.phone umgestellt
  als Fallback, da diese üblicherweise ein "+" zeigt. Zentrale Summen-
  Logik: TagesabschlussBerechnung.parseCentZiffern summiert jetzt
  "+"-getrennte Teilbeträge; das Widget nutzt diese Funktion jetzt
  auch intern (_parseCentAusText) statt eigener doppelter Parse-Logik.
  GanzzahlEingabefeld (Stückzahl) bewusst unverändert, da der Anwen-
  dungsfall nur Beträge betrifft. Neuer Unit-Test für die Summierung.
  Version 0.9.12+336. Dateien: tagesabschluss_berechnung.dart,
  betrag_cent_eingabefeld.dart, tagesabschluss_berechnung_test.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 335: Drei Korrekturen im Einstellungen-Admin-Bereich aus
  Testfeedback. (1) Dev-Modus-Schalter wiederhergestellt: Der
  DevModus-Service (dev_modus.dart, Key "dev_modus_aktiv") steuert
  das DEV-Tools-Panel (Auto-Fill/Alles-leeren) auf Schritt 1-3,
  hatte aber seit Run 287 keinen UI-Schalter mehr — DevModus.setzen()
  wurde seither nirgends mehr aufgerufen. Neuer SwitchListTile
  "Dev-Modus (Auto-Fill)" im PIN-geschützten Admin-Bereich, direkt
  über dem Testwerte-Block, verbunden mit DevModus.istAktiv()/
  setzen(). (2) Zwei redundante orangefarbene "Gespeichert: ..."
  Hinweise unter den Feldern location_id und Flurbocash-API-Key
  entfernt (Wert war bereits im Feld selbst sichtbar); zugehörige
  State-Felder _overrideLocationId/_overrideApiKey mit entfernt,
  _speichereLocationId()/_speichereFlurbocashApiKey() dadurch auf
  reines Speichern vereinfacht. (3) Anthropic-API-Key-Feld zeigt
  den Wert jetzt im Klartext (obscureText + Augen-Icon-Button
  entfernt, Feld _anthropicKeyVerdeckt entfernt). Version 0.9.11+335.
  Dateien: einstellungen_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 334a2: Zwei direkte Anweisungen ohne eigene Run-Nummer,
  gebündelt. (1) Snackbar-Hinweistext bei Netzwerk-/
  Konfigurationsfehlern (_starteEcBelegScan,
  tagesabschluss_schritt2_seite.dart): Satz "Beleg kann auch manuell
  eingegeben werden." jetzt fett dargestellt (Text.rich mit zwei
  TextSpans statt einfachem Text) — hebt die Ausweich-Option optisch
  hervor. (2) Button-Farben auf der Kino-Startseite
  (startmenue_seite.dart): Erster Button ("Kassenabrechnung (4
  Schritte)") jetzt AppFarben.fokusFarbe (Orange, gleiche Farbe wie
  die bestehende Fokus-Füllfarbe) mit schwarzem Text statt
  Theme-Default-Rot. Die beiden letzten Buttons ("Einstellungen",
  "Verlauf") jetzt mit neuer Konstante AppFarben.appBarRotGedaempft
  (appBarRot bei 50% Alpha, Color(0x805C0A0A)) — bewusst
  nachrangig/gedämpft gegenüber den übrigen Aktions-Buttons. Version
  0.9.10+334a2. Dateien: tagesabschluss_schritt2_seite.dart,
  app_farben.dart, startmenue_seite.dart, pubspec.yaml,
  kinoauswahl_seite.dart.

- Run 334a: Korrektur aus Testfeedback zu Run 334, direkte Anweisung
  ohne eigene Run-Nummer. Testbefund: Die neue, sprechende
  BelegScanException ("Service-URL nicht konfiguriert – bitte in den
  Einstellungen eintragen.") kam nie beim Nutzer an — der
  Snackbar-Filter in _starteEcBelegScan (tagesabschluss_schritt2_seite.dart,
  seit Run 274e2) unterschied bisher nur zwischen Netzwerkfehlern
  (Text beginnt mit "Keine Internet"/"HTTP ") und "allem anderen",
  und zeigte für "alles andere" immer den generischen Text
  "Scan nicht lesbar – bitte erneut versuchen (z.B. unscharf, zu
  dunkel oder kein Beleg)" — fachlich falsch bei fehlender
  Konfiguration, weil das eine Foto-Qualität suggeriert statt eines
  Einstellungs-Problems. Neue Prüfung `istKonfigurationsFehler`
  (Text beginnt mit "Service-URL nicht konfiguriert") ergänzt;
  zeigt jetzt wie bei Netzwerkfehlern den echten Klartext der
  Exception plus Hinweis auf manuelle Eingabe, statt des generischen
  Lesbarkeits-Texts. Version 0.9.10+334a. Datei:
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 334: BelegScan-Service-URL: hart codierten Fallback aus dem
  Code entfernt, rein aus der Einstellung gelesen. Auslöser:
  Paco hatte im Admin-Bereich ("KI-Belegscan") nachgesehen und dort
  ein leeres Feld vorgefunden — der zuvor gespeicherte Eindruck
  "hardcoded" war berechtigt, weil die tatsächlich aktive URL nie
  als echter Feldinhalt sichtbar war, sondern nur als grauer
  Hint-Text (seit Run 332). `BelegScanService.standardWorkerUrl`
  (Konstante mit dem Cloudflare-Worker-Default) entfernt;
  `ladeWorkerUrl()` liefert jetzt ausschließlich den in
  SharedPreferences gespeicherten Wert (Key `belegscan_service_url`,
  getrimmt), ohne Fallback. `scan()` wirft eine sprechende
  BelegScanException ("Service-URL nicht konfiguriert – bitte in den
  Einstellungen eintragen."), wenn die URL leer ist, statt mit einer
  leeren URI zu scheitern. einstellungen_seite.dart: Hint-Text des
  Felds "Service-URL" zeigt nur noch ein Format-Beispiel
  ("z. B. https://…workers.dev"), keinen echten Wert mehr.
  **Betriebs-Konsequenz:** Da die URL lokal pro Gerät in
  SharedPreferences liegt (kein Server-Abgleich zwischen Standorten),
  funktioniert der Scan ab sofort auf JEDEM Gerät nicht mehr, auf dem
  das Feld bisher leer war (verließ sich auf den jetzt entfernten
  Code-Fallback) — dort muss die URL
  (https://kartenzahlungsbelegscan.pacodemant.workers.dev) einmalig
  manuell im Admin-Bereich nachgetragen werden. Version 0.9.10+334.
  Dateien: beleg_scan_service.dart, einstellungen_seite.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 333b: Korrektur aus Testfeedback zu Run 333a, direkte
  Anweisung ohne eigene Run-Nummer. Testbefund: Nach Löschen der
  aktuellen (heutigen) Abrechnung im Verlauf blieb der Button
  "Übertrag auf Umschlag" weiterhin rot (aktiv), obwohl der
  Hinweis-Dialog beim Tippen korrekt "Du musst erst eine Abrechnung
  durchführen" zeigte — Style und Verhalten liefen auseinander.
  Ursache: Kehrt man von VerlaufSeite per Zurück-Pfeil (pop()) zur
  Startseite zurück, wird die StartmenueSeite-Instanz NICHT neu
  erzeugt (kein neuer initState()-Aufruf) — der in Run 333a
  eingeführte, nur einmalig ladende Button-State blieb daher auf dem
  Stand von vor dem Löschen hängen, während der Klick-Handler jedes
  Mal frisch nachlud. Gleichzeitig als Anti-Pattern identifiziert (auf
  Nachfrage): der FutureBuilder für den "Kino wechseln"-Button
  (ladeStandortModus() inline im build()) hatte dasselbe
  Grundproblem, nur harmloser (kurzes Aufblitzen statt Dauerzustand).
  Beides gemeinsam behoben: StartmenueSeite von StatelessWidget auf
  StatefulWidget mit RouteAware umgestellt (neuer globaler
  RouteObserver in route_observer.dart, registriert in main.dart über
  navigatorObservers). didPopNext() lädt beide Werte (heutige
  Abschlüsse + Standort-Modus) neu, sobald die Seite nach einem pop()
  wieder sichtbar wird — behebt beide Anti-Pattern-Stellen einheitlich
  und hält Button-Style und Klick-Verhalten konsistent (beide nutzen
  denselben State). Version 0.9.9+333b. Dateien: startmenue_seite.dart,
  route_observer.dart (neu), main.dart, pubspec.yaml,
  kinoauswahl_seite.dart.

- Run 333a: Korrektur aus Testfeedback zu Run 333, direkte Anweisung
  ohne eigene Run-Nummer. Testbefund: Button "Übertrag auf Umschlag"
  blieb nach frisch abgeschlossener Abrechnung ausgegraut, wurde erst
  nach manuellem Neu-Laden korrekt aktiv/rot — spricht für ein
  Timing-/Rebuild-Problem, nicht für falsch gespeicherte Daten (Reload
  behebt es). Ursache: Der FutureBuilder in startmenue_seite.dart
  erzeugte das Future (ladeHeutigeFinaleTagesabschluesse) direkt
  inline im build() — bei jedem Rebuild der Seite entsteht dadurch ein
  neues Future, wodurch der Button auf den "waiting"-Zustand (=
  ausgegraut) zurückfällt. Behoben durch neues privates StatefulWidget
  _UebertragUmschlagButton, das nur einmal in initState() lädt statt
  bei jedem Elternteil-Rebuild neu. Version 0.9.9+333a. Dateien:
  startmenue_seite.dart, pubspec.yaml, kinoauswahl_seite.dart.

- Run 333: Neuer Button "Übertrag auf Umschlag" auf der Kino-
  Startseite. Zeigt nachträglich die Übertrag-Werte eines heute
  bereits abgeschlossenen Tagesabschlusses — gleiches Karten-Layout
  wie tagesabschluss_schritt3_seite.dart (Differenz Anfangsbestand,
  SOLL, IST, Differenz Kassenabrechnung), aber als eigenständige,
  rein lesende neue Datei (uebertrag_umschlag_seite.dart) statt
  Eingriff in Schritt 3 — dort hängen Auto-Save, Duplikat-Dialog und
  die Buttons "Kassenabrechnung senden"/"Stückelung" am aktiven
  Abrechnungs-Flow, für eine reine Nachträglich-Anzeige ungeeignet
  bis riskant. Neue Methode
  LokalerSpeicher.ladeHeutigeFinaleTagesabschluesse(kinoId) liefert
  die Abschlüsse des aktuellen logischen Tages (6-Uhr-Knick), ohne
  die bestehende "ist heute"-Logik in verlauf_seite.dart bzw.
  speichere_tagesabschluss_usecase.dart anzufassen. Button-
  Verhalten: kein heutiger Abschluss → optisch ausgegraut (grauer
  ElevatedButton-Style, bleibt aber antippbar), Tap zeigt Dialog "Du
  musst erst eine Abrechnung durchführen."; genau ein Abschluss →
  Tap navigiert direkt zur neuen Seite; mehrere Abschlüsse (nur Bar
  Tabak möglich, max. 2/Tag) → Tap zeigt Auswahl-BottomSheet
  (Uhrzeit + Mitarbeitername), danach Navigation. Neue Route
  '/uebertrag-umschlag' in main.dart. Version 0.9.9+333. Dateien:
  uebertrag_umschlag_seite.dart (neu), lokaler_speicher.dart,
  startmenue_seite.dart, main.dart, pubspec.yaml,
  kinoauswahl_seite.dart.

- Run 332a2: Korrektur aus Testfeedback zu Run 332a, direkte
  Anweisung ohne eigene Run-Nummer (von Paco selbst lokal umgesetzt,
  hier nur getestet/dokumentiert/committed). (1) main.dart: neues
  Dev-Tool — `debugPaintSizeEnabled = true` zeigt Layout-
  Begrenzungslinien, aber nur wenn `kDebugMode && !kIsWeb` (Simulator/
  Gerät im Debug-Build ja, Web-Build/PWA nie), damit schnelles
  Layout-Tuning per Hot-Reload im iOS-Simulator möglich ist, ohne dass
  das Overlay je in der echten PWA auftaucht. (2)
  getraenke_auffuellen_seite.dart: Zwischenraum zwischen Checkbox und
  Folgetext bei "nur benötigte anzeigen" verkleinert — Checkbox-Spalte
  von FixedColumnWidth(36) auf IntrinsicColumnWidth() (Transform.scale
  verkleinert nur die Optik, nicht die Layout-Box; IntrinsicColumnWidth
  lässt die Spalte der tatsächlichen Checkbox-Größe folgen),
  Eingabefeld-Spalte von FixedColumnWidth(72) auf FixedColumnWidth(44)
  (beide Händigkeits-Varianten). Version 0.9.8+332a2. Dateien:
  main.dart, getraenke_auffuellen_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 332a: Korrektur aus Testfeedback, direkte Anweisung ohne eigene
  Run-Nummer. Fehlende Fokus-Orange-Konsistenz (Run 330/330a) in
  mehreren MA-sichtbaren Eingabefeldern nachgezogen, die außerhalb der
  zentralen Widgets BetragCentEingabefeld/GanzzahlEingabefeld liegen
  und daher bei der Umstellung nicht erfasst wurden: (1)
  getraenke_auffuellen_seite.dart — Mengenfeld war bei Fokus schwarz
  gefüllt mit weißer Schrift (älterer, eigenständiger Stil), jetzt
  AppFarben.fokusFarbe + schwarze Schrift. (2)
  schritt1_umschlaege_section.dart — Umschlag-Label-Feld hatte gar
  keine Fokus-Füllung; da das Feld in einem StatelessWidget ohne
  eigenen Rebuild-Mechanismus liegt, zusätzlich in ListenableBuilder
  gewrappt, damit der Fokuswechsel überhaupt sichtbar wird. (3)
  tagesabschluss_schritt2_seite.dart — drei Felder ohne Fokus-Füllung:
  Zahlungsart-Betrag in der Kartenarten-Tabelle (Listener existierte
  bereits), Kartenarten-Gesamtbetrag und Anmerkung/Kommentar-Feld
  (für beide neu: FocusNode-Listener mit `setState`, da bisher kein
  Rebuild bei Fokuswechsel ausgelöst wurde). Bewusst NICHT angefasst:
  die vier Metadaten-Felder (Datum/Uhrzeit/Beleg-Nr., hellgelbes
  Color(0xFFFFF8E1) statt Orange bei Fokus) sowie sämtliche
  Admin-Bereich-Felder in einstellungen_seite.dart (Upload-URL,
  location_id, API-Key, Service-URL, Getränkeliste-Verwaltung,
  Testwerte, Wechselgeld) — beides ohne Rücksprache mit Paco, ob das
  ebenfalls vereinheitlicht werden soll oder bewusst abweicht. Version
  0.9.8+332a. Dateien: getraenke_auffuellen_seite.dart,
  schritt1_umschlaege_section.dart, tagesabschluss_schritt2_seite.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 332: BelegScan-Service-URL im Admin-Bereich editierbar gemacht.
  `BelegScanService._workerUrl` (hart codiert) durch
  `standardWorkerUrl` (Fallback-Default) ersetzt; neue Methode
  `ladeWorkerUrl()` liest die URL zur Laufzeit aus SharedPreferences
  (Key `belegscan_service_url`), fällt bei leerem/fehlendem Wert auf
  den Default zurück. `scan()` nutzt sie entsprechend. Einstellungen
  Admin-Bereich, Abschnitt "KI-Belegscan (Anthropic)": neues TextField
  "Service-URL" über dem Anthropic-API-Key-Feld, Hint zeigt den
  Default, Speicherung bei jeder Änderung, Leerfeld = Default. Löst
  TODO-Punkt "BelegScan-Service-URL editierbar" (Testfeedback zu
  Run 329). Version 0.9.8+332. Dateien: beleg_scan_service.dart,
  einstellungen_seite.dart, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 331: Zwei weitere Stellen auf bereits bestehende
  Theme-Konstanten umgestellt (reine Konsistenz, keine optische
  Änderung möglich — identische Werte). (1) einstellungen_seite.dart
  `_hausFooter` baute die Footer-BoxDecoration (schwarz + weißer
  Rand + Schatten) Byte-für-Byte per Hand nach, obwohl dafür bereits
  AppFarben.footerDecoration existiert (genutzt in verlauf_seite.dart,
  verlauf_detail_seite.dart, tagesabschluss_scaffold.dart) — jetzt
  ebenfalls darauf umgestellt. (2) 10 Stellen mit rohem
  Colors.black54 (tagesabschluss_schritt2_seite.dart: 6×,
  beleg_scan_bestaetigen_dialog.dart: 4×) durch die bereits
  existierende, wertgleiche Konstante AppFarben.subtilerText ersetzt
  (bisher nur in startmenue_seite.dart/kinoauswahl_seite.dart
  genutzt). Ein dritter Kandidat (Color(0xFFFFF8E1), Dev-Tools-Panel-
  Hintergrund) bewusst nicht angefasst — gehört zum Dev-Modus, der
  laut Paco später komplett entfernt wird. Version 0.9.7+331.
  Dateien: einstellungen_seite.dart, tagesabschluss_schritt2_seite.dart,
  beleg_scan_bestaetigen_dialog.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 330a: Korrektur aus Testfeedback zu Run 330, direkte Anweisung
  ohne eigene Run-Nummer. Textfarbe innerhalb orange gefüllter Felder
  von Weiß auf Schwarz umgestellt (Kontrast auf Orange war zu
  schwach). Betroffen: cursorColor + style-color in
  betrag_cent_eingabefeld.dart und ganzzahl_eingabefeld.dart;
  cursorColor + style-color + "X"-Clear-Icon in
  tagesabschluss_schritt2_seite.dart an allen 3 in Run 330
  umgestellten Feldern (Ausgaben-Bezeichnung, Terminal-ID 1-Beleg-
  Modus, Terminal-ID Sub-Kachel); zusätzlich zentraler Helfer
  clearIconFarbe() (eingabefeld_clear_helper.dart) auf Schwarz
  umgestellt — behebt nebenbei auch ein bereits vorher bestehendes
  Kontrastproblem des Clear-Icons auf dem hellgelben
  Kartenarten-Betrag-Feld (Color(0xFFFFF8E1)), das denselben Helfer
  nutzt. Version 0.9.6+330a. Dateien: betrag_cent_eingabefeld.dart,
  ganzzahl_eingabefeld.dart, eingabefeld_clear_helper.dart,
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 330: Fokus-Füllfarbe von Eingabefeldern zentralisiert und von
  Rot auf Orange umgestellt. Neue Konstante AppFarben.fokusFarbe
  (Color(0xFFFF9800), identischer Ton wie der Splash-Ladebalken aus
  Run 328a4) in lib/theme/app_farben.dart ergänzt. Bisher nutzte die
  Fokus-Füllung dieselbe Konstante AppFarben.appBarRot wie AppBar/
  Buttons/Ränder — ein direktes Umfärben von appBarRot hätte auch
  diese mit eingefärbt. Stattdessen gezielt an den 5 Stellen ersetzt,
  an denen ein Feld beim Fokus mit appBarRot gefüllt wurde: (1)
  betrag_cent_eingabefeld.dart (Euro-Beträge, App-weit), (2)
  ganzzahl_eingabefeld.dart (Stückzahlen, App-weit), (3)-(5)
  tagesabschluss_schritt2_seite.dart (Ausgaben-Bezeichnung,
  Terminal-ID 1-Beleg-Modus, Terminal-ID Sub-Kachel Mehrbeleg-Modus).
  Ränder (border/enabledBorder) bleiben bewusst unverändert rot —
  das ist die Randfarbe im Ruhezustand, kein Fokus-Verhalten. Weißer
  Text/Cursor auf dem gefüllten Feld bleibt unverändert; Kontrast auf
  Orange ist geringer als vorher auf Dunkelrot — bei Bedarf als
  kleine Korrektur nachziehbar. Version 0.9.6+330. Dateien:
  app_farben.dart, betrag_cent_eingabefeld.dart,
  ganzzahl_eingabefeld.dart, tagesabschluss_schritt2_seite.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 329a2: Korrektur aus Testfeedback zu Run 329a, Fortsetzung mit
  Zahlensuffix (329a ist bereits durch Buchstaben benannt). Hinweis
  im Scan-Bereich von Wrap (Text + GestureDetector + Text) auf
  Text.rich (TextSpan + TapGestureRecognizer) umgestellt: Wrap
  brach den Link "Belegdaten bearbeiten" auf eine eigene Zeile um,
  sobald der Hinweistext allein schon die Zeile füllte — Text.rich
  lässt den kompletten Satz inkl. Link als einen zusammenhängenden
  Fließtext umbrechen, der Link folgt jetzt direkt hinter "Tippe
  auf" statt in der nächsten Zeile. Ganzer Hinweistext (inkl. Link)
  jetzt durchgehend kursiv (Paco hatte den ersten Teil bereits
  selbst in tagesabschluss_schritt2_seite.dart korrigiert — war
  bereits richtig). Neues Feld _belegdatenBearbeitenRecognizer
  (TapGestureRecognizer) mit Dispose in dispose(); neuer Import
  package:flutter/gestures.dart. Version 0.9.5+329a2. Dateien:
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, CHANGELOG.md,
  PROJECT_CONTEXT.md.

- Run 329a: Korrektur aus Testfeedback zu Run 329, direkte Anweisung
  ohne eigene Run-Nummer. Hilfetext im Scan-Bereich der EC-Belege-
  Kachel um zusätzlichen Text-Link "Belegdaten bearbeiten" ergänzt
  (kursiv, unterstrichen, Kino-Rot; fokussiert beim Tap das
  Terminal-ID-Feld des ersten Belegs). Hinweistext samt Link
  verschwindet jetzt, sobald mindestens ein Beleg Daten hat
  (`hatEcBelege`) — vorher war er unbedingt sichtbar. Außerdem
  TODO.md um neuen Punkt "BelegScan-Service-URL editierbar" ergänzt:
  Paco meinte mit der ursprünglichen Basis-URL-Anfrage die Worker-URL
  des KI-Belegscans (`_workerUrl` in beleg_scan_service.dart,
  aktuell hart codiert), nicht die Flurbocash-Upload-URL — noch
  nicht umgesetzt, als Run 330 vorgeschlagen. Version 0.9.5+329a.
  Dateien: tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, TODO.md,
  CHANGELOG.md, PROJECT_CONTEXT.md.

- Run 329: Dauerhaft sichtbarer Hilfetext im Scan-Bereich der EC-Belege-
  Kachel (Schritt 2) ergänzt — Text "Beleg fehlt oder ist unlesbar?
  Fehlende Felder unten einfach manuell eintragen." erscheint immer,
  sobald die Kachel aufgeklappt ist (1-Beleg- und Mehrbeleg-Modus).
  Schließt den TODO-Punkt "Hilfetext" ab (Duplikat-Button bleibt offen).
  Bei der Recherche zum ursprünglich zweiten Run-Bestandteil
  (Basis-URL-Feld in den Einstellungen) festgestellt: das Feld
  existiert bereits ("Upload-URL", `einstellungen_seite.dart`,
  SharedPreferences-Key `api_upload_url`, im PIN-geschützten
  Admin-Bereich) — seit Run 292 vorhanden, TODO.md-Eintrag war
  veraltet. Kein Code dafür nötig; TODO.md/TODO_ERLEDIGT.md
  entsprechend korrigiert. Version 0.9.5+329. Dateien:
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, TODO.md,
  TODO_ERLEDIGT.md.

- Run 328a4: Ladebalken im Splash-Screen ergänzt — direkte
  Anweisung ohne eigene Run-Nummer, Fortsetzung von 328a3 mit
  Zahlensuffix. Anlass: sichtbares Feedback beim App-Start bzw.
  bei jedem Neu-Laden (Button, Auto-Update, Fresh-Tab-Reset) fehlte
  bisher — nur Icon, kein Fortschrittshinweis. In `web/index.html`
  unter dem Icon im `#splash`-Div einen animierten, unbestimmten
  Ladebalken ergänzt: 25vw breit (Vorgabe: 1/4 der Displaybreite),
  Farbe Orange (#FF9800) auf halbtransparenter weißer Spur. Rein
  CSS-animiert (kein echter Ladefortschritt aus Flutter verdrahtet),
  verschwindet wie das Icon beim `flutter-first-frame`-Event. Reine
  HTML/CSS-Änderung, kein Dart-Code betroffen. Dateien: web/index.html,
  pubspec.yaml, lib/pages/startmenue_seite.dart,
  lib/pages/kinoauswahl_seite.dart, CHANGELOG.md, PROJECT_CONTEXT.md.

- Run 328a3: AGENTS.md um festen Abschnitt "Remote-Sessions (Claude
  Code Web/App): Merge nach master" ergänzt, direkte Anweisung ohne
  eigene Run-Nummer. Anlass: `.github/workflows/deploy.yml` (Build →
  GitHub Pages, die URL hinter Pacos installierter PWA) feuert nur
  bei Push auf `master`; Remote-Sessions committen aber auf einen
  von der Umgebung zugewiesenen Feature-Branch, wodurch Pacos "Neu
  laden" auf dem iPhone ohne Merge nach master wirkungslos blieb.
  Neue Standing-Regel: Remote-Sessions legen nach jedem Run/Sub-Run
  eine PR an bzw. nutzen die bestehende und mergen direkt nach
  master, ohne erneut nachzufragen — mit klaren STOPP-Bedingungen
  (Merge-Konflikte, fehlgeschlagene Checks, Branch-Protection-
  Blocker, Git-Sicherheitsvertrag-STOPP-Zustände), bei denen
  stattdessen gewarnt statt gemergt wird. Bestehende "nicht auf
  Branch master"-STOPP-Bedingung im Git-Sicherheitsvertrag um
  Klarstellung ergänzt, dass sie nur für lokale/CLI-Sessions gilt.
  Reine Dokumentationsänderung, keine App-Code-Änderung. PR #6 (Run
  328a/328a2) und PR #7 (Run 328a3 selbst) im Zuge dessen nach
  master gemergt. Dateien: AGENTS.md, CHANGELOG.md,
  PROJECT_CONTEXT.md.

- Run 328a2: Korrektur aus Testfeedback zu Run 328a (Punkt 3) —
  direkte Anweisung ohne eigene Run-Nummer, Fortsetzung von 328a
  daher mit Zahlensuffix statt neuem Buchstaben. Die Bedingung war
  genau umgekehrt: das Feld soll sich bei Fokus im Modus "alle
  anzeigen" leeren, im Modus "nur benötigte anzeigen" dagegen NICHT
  — vorherige Umsetzung (328a) hatte es andersherum. Ein Zeichen
  geändert: `!_nurBenoetigte` statt `_nurBenoetigte` im
  Fokus-Listener. `flutter analyze`/`flutter test` weiterhin nicht
  ausführbar (kein Flutter-SDK in dieser Remote-Umgebung). Dateien:
  getraenke_auffuellen_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, CHANGELOG.md,
  PROJECT_CONTEXT.md.

- Run 328a: Korrektur aus Testfeedback zu Run 328 (Getränkeliste-
  Abhaken), direkte Anweisung ohne eigene Run-Nummer. (1) Runde
  Checkboxen: `fillColor` per `WidgetStateProperty.resolveWith`
  auf Grau (nicht abgehakt) bzw. Grün (abgehakt) gesetzt, weißes
  Häkchen (`checkColor`). (2) Checkbox-Position im Rechtshänder-
  Modus von ganz rechts (unverankertes Zeilenende, dadurch weit
  vom Rand bzw. teils außerhalb der sichtbaren Breite) auf den
  Zeilenanfang/links verlegt — dort ist die Zeile durch
  `mainAxisAlignment.start` + linkem Seiten-Padding ohnehin schon
  randnah verankert, kein zusätzlicher Abstand nötig. Linkshänder-
  Modus unverändert (Checkbox am Zeilenende, das dort bereits
  durch `mainAxisAlignment.end` + rechtem Padding randnah liegt).
  `spaltenBreiten`/Gesamtzeile entsprechend auf die neue
  Spaltenreihenfolge umgestellt. (3) Bug behoben: Antippen eines
  Mengenfelds leerte das Feld bisher in JEDEM Modus (Listener seit
  Run 311, ursprünglich wohl nur für den Filtermodus gedacht) —
  jetzt nur noch, wenn `_nurBenoetigte` aktiv ist; in "alle
  anzeigen" bleibt der vorhandene Wert beim Antippen erhalten.
  `flutter analyze`/`flutter test` weiterhin nicht ausführbar
  (kein Flutter-SDK in dieser Remote-Umgebung). Dateien:
  getraenke_auffuellen_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, CHANGELOG.md,
  PROJECT_CONTEXT.md.

- Run 328: Getränkeliste — Abhaken im Filtermodus "nur benötigte
  anzeigen" umgesetzt (`getraenke_auffuellen_seite.dart`). Jede
  Zeile bekommt in diesem Modus zusätzlich eine runde Checkbox
  (`Checkbox` mit `CircleBorder`). Abgehakte Einträge wandern ans
  Ende der gefilterten Liste, unabgehakte behalten ihre
  ursprüngliche Reihenfolge — Sortierung erfolgt in
  `_gezeigteIndizes` durch Partitionierung nach `_abgehakt`-Set,
  Zuordnung über den festen Listenindex (nicht die Anzeigeposition),
  daher robust gegenüber Auf-/Abhaken in beliebiger Reihenfolge. Bei
  "alle anzeigen" bleibt die Grundreihenfolge unverändert und keine
  Checkbox sichtbar — Abhak-Status wirkt sich nur auf die Sortierung
  im gefilterten Modus aus, wie in TODO.md gefordert. "Clear"-Button
  setzt `_abgehakt` zusätzlich zu den Mengenfeldern zurück, da
  abgehakte Einträge ohne Menge ohnehin aus dem Filter fallen würden.
  Tabellenspalten (`spaltenBreiten`, Kopf-/Gesamtzeile) um eine
  bedingte Checkbox-Spalte erweitert, nur wenn der Filter aktiv ist.
  Abhak-Status ist bewusst nicht persistiert (SharedPreferences) —
  reine Session-Sortierhilfe beim Auffüllen, TODO.md verlangte keine
  Persistenz und Persistenz-Verträge sind laut AGENTS.md ohne
  ausdrückliche Freigabe tabu. `flutter analyze`/`flutter test`
  konnten in dieser Remote-Umgebung nicht ausgeführt werden (kein
  Flutter-SDK installiert) — Paco muss lokal testen. Dateien:
  getraenke_auffuellen_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart, CHANGELOG.md,
  TODO.md, TODO_ERLEDIGT.md, PROJECT_CONTEXT.md,
  .dev/run_counter.txt.

- Run 327: Token-Kosten-Optimierungen am Projekt-Workflow selbst
  umgesetzt (Anlass: Analyse eines Videos über Token-Abrechnung/
  Cache-Misses). (1) CHANGELOG.md aufgeteilt: Run 63–269 nach
  CHANGELOG_ARCHIV.md ausgelagert (neue Datei), CHANGELOG.md enthält
  nur noch Run 270 bis aktuell — wurde bisher bei jedem Run
  vollständig gelesen und wuchs unbegrenzt. (2) TODO.md aufgeteilt:
  alle 25 erledigten `[x]`-Punkte samt Begründung nach
  TODO_ERLEDIGT.md ausgelagert (neue Datei, gleiche
  Abschnittsstruktur), TODO.md enthält nur noch die 46 offenen
  Punkte. AGENTS.md-Bericht-Regel entsprechend ergänzt: erledigte
  Punkte künftig nach TODO_ERLEDIGT.md verschieben statt nur
  `[x]` zu setzen, damit TODO.md dauerhaft schlank bleibt. (3)
  CLAUDE.md und AGENTS.md waren zu ca. 85% wortgleich (Standard-Lock,
  Run-Ablauf, Git-Sicherheitsvertrag, Versionierung usw.), wurden
  aber beide bei jeder Session geladen und von Hand synchron
  gehalten. AGENTS.md ist jetzt die einzige Quelle für den
  vollständigen Arbeitsvertrag (inkl. dem bisher nur in CLAUDE.md
  stehenden Lösungsansatz-Check); CLAUDE.md enthält nur noch
  Claude-Code-spezifische Ergänzungen (Sprache, Ausgabeformat,
  Session-Start) plus Verweis auf AGENTS.md. Neuer Run-Typ „tests"
  in AGENTS.md ergänzt. (4) `parseCentKomma` in
  `tagesabschluss_berechnung.dart` hatte bisher keinerlei
  Testabdeckung (im Gegensatz zu `parseCentZiffern`) — 7 neue Tests
  in `tagesabschluss_berechnung_test.dart` ergänzt (einfache Werte,
  einstellige Cent-Angabe, Punkt als Dezimaltrenner, Euro-Zeichen/
  Leerraum, deutsches Tausenderformat „1.234,56"). Dabei eine
  bestehende Einschränkung dokumentiert (nicht behoben, da Run auf
  Tests beschränkt): reiner Tausenderpunkt ohne Komma (z. B.
  „1.400") wird als Dezimaltrenner interpretiert und ergibt 1,40 €
  statt 1.400,00 € — aktuell folgenlos, da `mitKomma` seit Run 317
  app-weit fest auf `false` steht und dieser Codepfad dadurch nicht
  erreichbar ist; Test dokumentiert das Verhalten, damit eine
  künftige Reaktivierung der Komma-Eingabe nicht stillschweigend in
  diese Falle läuft. Keine funktionale App-Code-Änderung, daher
  keine Versionsstring-Aktualisierung (analog Run 316b/319b).
  Dateien: CHANGELOG.md, CHANGELOG_ARCHIV.md (neu), TODO.md,
  TODO_ERLEDIGT.md (neu), CLAUDE.md, AGENTS.md,
  tagesabschluss_berechnung_test.dart, PROJECT_CONTEXT.md,
  .dev/run_counter.txt.

- Run 326a: Korrektur aus Testfeedback — der "Neu laden"-Button
  (Run 324) brachte trotz Tap weiterhin die alte Version, da er
  nur einen einfachen window.location.reload() auslöste. Ein
  einfacher Reload wird aber weiterhin vom (evtl. veralteten)
  Service-Worker-Cache bedient statt vom Server, da der Service
  Worker die Anfrage abfängt. Fix: neue gemeinsame JS-Funktion
  _purgeCachesUndSw() (Caches löschen + Service Worker
  abmelden) — bisher nur vom Fresh-Tab-Reset genutzt — wird
  jetzt auch von _reloadPage() vor dem Reload aufgerufen.
  Betrifft damit sowohl den manuellen Button als auch den
  bestehenden automatischen Reload bei erkanntem SW-Update
  (initSwUpdateWatcher in main.dart), da beide dieselbe
  _reloadPage()-Funktion nutzen. Versionsstring r326a.
  Dateien: web/index.html, startmenue_seite.dart,
  kinoauswahl_seite.dart, pubspec.yaml.

- Run 326: Einstellungen-Seite Feinschliff, drei Teile.
  (1) Getränkeliste-Card-Titel zeigt jetzt das Standortkürzel
  des aktiven Kinos ("Getränkeliste SB" statt nur
  "Getränkeliste"). (2) Neuer Schalter "Admin-Status halten"
  in der Admin-Kachel: Schalterstellung wird gespeichert
  (SharedPreferences); ist er aktiv, bleibt der entsperrte
  Admin-Status beim Verlassen/Wiederöffnen der Einstellungen-
  Seite erhalten (statisches Feld, überlebt neue State-
  Instanzen im selben App-Lauf) und verfällt erst bei echtem
  Neuladen der App. (3) Zusammengehörende Einstellungen
  innerhalb der Admin-Kachel (Standort+Admin-Status-Halten /
  Wechselgeldbestand / Flurbocash-Anbindung / KI-Belegscan /
  Testwerte) sind jetzt in abwechselnd getönte Container
  gruppiert (neue Farben AppFarben.gruppierungBandA/B),
  ähnlich Zeilenfarbwechsel in einer Tabellenkalkulation.
  Versionsstring r326.
  Dateien: einstellungen_seite.dart, app_farben.dart,
  startmenue_seite.dart, kinoauswahl_seite.dart, pubspec.yaml.

- Run 325a: Korrektur aus Testfeedback zu Run 324 — der
  "Neu laden"-Button stand in einer eigenen Card. Card entfernt,
  Button steht jetzt nackt (kein Titel, kein Beschreibungstext)
  ganz unten auf der Einstellungen-Seite, nach der Admin-Kachel.
  Versionsstring r325a.
  Dateien: einstellungen_seite.dart, startmenue_seite.dart,
  kinoauswahl_seite.dart, pubspec.yaml.

- Run 325: Standort-Betriebsmodus im Admin-Bereich. Neue
  Dropdown-Einstellung "Standort" (Admin-Kachel, PIN-
  geschützt): "Alle" oder ein fest eingestelltes Kino.
  Persistenz lokal auf dem Gerät via SharedPreferences
  (`LokalerSpeicher.ladeStandortModus()` /
  `speichereStandortModus()`, Key `standort_modus`). Ist ein
  Standort fest eingestellt, hat er beim App-Start Vorrang
  vor dem zuletzt manuell gewählten Kino
  (`StartzielBestimmenUsecase`, hält `activeCinemaId`
  synchron) — die Kinoauswahl-Seite entfällt dadurch für den
  MA. Der Textbutton "Kino wechseln" auf der Startseite wird
  in diesem Fall ausgeblendet (`FutureBuilder` um den Button
  in `startmenue_seite.dart`, da die Seite bislang
  StatelessWidget ist und keine größere Umstellung nötig
  sein sollte). Bekannte Grenze: eine Änderung des Standort-
  Modus während eine Startseite bereits offen ist, wirkt sich
  erst beim nächsten Öffnen/Neuladen der Startseite aus, nicht
  live in der offenen Instanz. Versionsstring r325.
  Dateien: lib/storage/lokaler_speicher.dart,
  lib/domain/usecases/startziel_bestimmen_usecase.dart,
  einstellungen_seite.dart, startmenue_seite.dart,
  kinoauswahl_seite.dart, pubspec.yaml.

- Run 324: Neu-Laden-Button in den Einstellungen ergänzt
  (außerhalb der Admin-Kachel, für alle MA sichtbar). Nutzt
  den bereits vorhandenen `reloadPage()`-Service
  (`sw_update_service.dart`, bisher nur für den
  automatischen Reload bei Service-Worker-Update genutzt) —
  ruft im Web schlicht `window.location.reload()` auf.
  Versionsstring r324.
  Dateien: einstellungen_seite.dart, startmenue_seite.dart,
  kinoauswahl_seite.dart, pubspec.yaml.

- Run 323b: Reine Doku-Änderung, kein App-Code betroffen.
  Pfeiltasten (▲▼) der iOS-Tastatur-Werkzeugleiste navigieren
  nicht zwischen Feldern — Ursache geklärt: native iOS-
  Safari-Chrome, unabhängig vom App-eigenen Next-Button
  (funktioniert seit Run 323a korrekt über
  `FeldNavigationHelper`). Flutter Web nutzt ohne
  `AutofillGroup` ein einziges verstecktes HTML-Inputfeld für
  alle Felder, wodurch der Browser kein "nächstes Feld" im DOM
  zum Springen findet. Nur mit größerer Architekturänderung
  behebbar, kein Blocker, da Zielplattform Android ist und
  diese Leiste iOS-Safari-spezifisch ist. In TODO.md als
  bekannt/kein Blocker dokumentiert. Versionsstring r323b.
  Dateien: TODO.md, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 323a: Korrektur aus Testfeedback zu Run 323 — Next-
  Button schloss Fokus und Tastatur statt zum nächsten Feld
  zu springen (Schritt 1 reproduziert, Getränke-Auffüllen
  identisch mit dem dort schon vorher komplett deaktivierten
  "next"-Button). Ursache: Flutter schließt die Tastatur
  automatisch, sobald außerhalb des fokussierten Feldes
  getippt wird — ein normaler Button zählt dafür als
  "außerhalb", auch wenn er nichts tut. Fix: Next-Button in
  allen vier Seiten mit TapRegion(groupId: EditableText, …)
  umschlossen, damit er zur selben Tastatur-Zone wie die
  Eingabefelder gehört und die automatische Schließung nicht
  mehr auslöst. Getränke-Auffüllen-Seite zusätzlich komplett
  neu verdrahtet (hatte bisher gar keine Feld-Navigation):
  beide "next"-Buttons aktiviert, FeldNavigationHelper
  eingebunden, Reihenfolge berücksichtigt den "nur benötigte
  anzeigen"-Filter (ausgeblendete Zeilen werden übersprungen,
  da ihr Feld nicht gebaut ist). Versionsstring r323a.
  Dateien: tagesabschluss_schritt1_seite.dart,
  tagesabschluss_schritt2_seite.dart,
  wechselgeld_pruefen_seite.dart, getraenke_auffuellen_seite.dart,
  startmenue_seite.dart, kinoauswahl_seite.dart, pubspec.yaml.

- Run 323: Next-Button in Schritt 1, Schritt 2 und
  Wechselgeld-Prüfen funktioniert jetzt — er sprang zuvor nur
  eine Platzhalter-SnackBar an ("funktioniert noch nicht"),
  obwohl er nicht ausgegraut aussah. Zusätzlich springt der
  Fokus jetzt auch per Tab/Shift+Tab und Pfeil-runter/-hoch
  zum logisch nächsten/vorherigen Feld, einheitlich über alle
  drei Seiten. Neue gemeinsame Klasse
  `lib/utils/feld_navigation_helper.dart`
  (`FeldNavigationHelper`) kapselt das Schema (nächstes/
  vorheriges Feld ermitteln, Next-Button und Tastatur-Events
  darauf abbilden); jede Seite liefert nur ihre eigene
  Feld-Reihenfolge und Fokussier-Methode. Betroffen sind nur
  Felder, die schon vorher Teil der "nächstes Feld"-Kette
  waren (Scheine, Münzen, Rollen, Umschläge, Ausgaben,
  EC-Belege, Kino-/Bistro-Soll, Differenz Anfangsbestand).
  `Schritt1InitialisierungHelper` bekam dafür einen neuen
  Konstruktor-Parameter `verknuepfeFeldNavigation`. Next-Button
  optisch von Grau auf Kino-Rot umgestellt (war nur noch aus
  historischen Gründen grau, obwohl tippbar). Versionsstring
  r323. Dateien: feld_navigation_helper.dart (neu),
  tagesabschluss_schritt1_seite.dart,
  tagesabschluss_schritt2_seite.dart, wechselgeld_pruefen_seite.dart,
  schritt1_initialisierung_helper.dart, startmenue_seite.dart,
  kinoauswahl_seite.dart, pubspec.yaml.

- Run 322: Grauen "Original-Name"-Hinweis auf der Seite
  "Getränke auffüllen" entfernt (`getraenke_auffuellen_seite.dart`).
  Dieser wurde eingeblendet, wenn ein Getränk in der Zentrale
  umbenannt wurde und die App noch den alten Namen kannte —
  Feld war zweitrangig und verwirrte optisch. Dazugehöriger toter
  Code entfernt: `_originalNamen`-Feld sowie
  `GetraenkeConfigService.ladeOriginalNamen()`. Versionsstring
  r322. Dateien: getraenke_auffuellen_seite.dart,
  getraenke_config_service.dart, startmenue_seite.dart,
  kinoauswahl_seite.dart, pubspec.yaml.

- Run 321b2: Korrektur aus Testfeedback zu Run 321b (t1). Das
  automatische Öffnen des Bearbeitungsmodus hatte ALLE Kartenart-
  Zeilen editierbar gemacht, auch die ohne Umsatz — dadurch
  standen leere/0-gefüllte Felder für nicht auf dem Beleg
  vorhandene Kartenarten in der Kachel, UND das "Kartenart?"-
  Auswahl-Dropdown (für die "unbekannte Kartenart"-Zeile) blieb
  leer/funktionslos, weil keine Zeile mehr im Zustand `hidden` war,
  aus dem die Dropdown-Optionen gespeist werden. Jetzt gezielt: nur
  Zeilen mit unlesbarem Betrag und die "unbekannte Kartenart"-Zeile
  werden automatisch editierbar; Kartenarten ohne Umsatz bleiben
  ausgeblendet (weiterhin nur über "+"-Chip erreichbar). Neue
  Methode `_kartenartBereitsAlsUnbekannteZugeordnet()`: sobald im
  Dropdown eine Kartenart gewählt wird, verschwindet der zugehörige
  "+"-Chip automatisch. 1-Beleg-Modus: TID-Feld jetzt auch dann
  editierbar, wenn nur die TID unlesbar war (unabhängig vom Zustand
  der Kartenart-Zeilen). Platzhaltertext zeigt bei unlesbarer TID
  "Terminal-ID?" statt "Terminal-ID" (analog "Kartenart?").
  Zusätzlich: manuelle Korrektur des Labels "Flurbocash-Upload
  (Test)" → "Flurbocash-Anbindung" in `einstellungen_seite.dart`
  (von Paco direkt vorgenommen, mit committet). Versionsstring
  r321b2. Dateien: tagesabschluss_schritt2_seite.dart,
  einstellungen_seite.dart, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 321b: Belegscan-Popup erweitert + EC-Kachel öffnet sich nach
  unlesbaren Daten automatisch zur Bearbeitung. (1)
  `beleg_scan_bestaetigen_dialog.dart`: neue Funktion
  `belegScanHatUnlesbareDaten()`; im Popup erscheint jetzt unter der
  Gesamtsumme ein Hinweistext, dass fehlende/unlesbare Werte nach
  der Übernahme nachgetragen/korrigiert oder der Beleg neu
  gescannt werden kann — nur wenn tatsächlich unlesbare Daten
  vorliegen. (2) `tagesabschluss_schritt2_seite.dart`: Wenn nach
  "übernehmen" unlesbare Daten vorlagen, werden alle Kartenart-
  Zeilen automatisch auf Bearbeitungsmodus gesetzt (im Mehr-Belege-
  Modus zusätzlich `_ecUnterkachelEditModus`) — der Zustand, den
  sonst der Button "Belegdaten bearbeiten" auslöst (korrigiert in
  321b2, s.o.). TID-Feld-Platzhalter "Terminal-ID" wird rot
  dargestellt, wenn die TID laut Scan nicht lesbar war
  (`_subKachelTidUnleserlich()`, beide Kachel-Modi). Markierung für
  nicht zuordenbare Kartenart ("?" in der Anzeige, "Kartenart?" im
  Auswahl-Dropdown) von Orange auf Rot geändert, konsistent mit der
  Popup-Farbe. Versionsstring r321b. Dateien:
  beleg_scan_bestaetigen_dialog.dart,
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 321a: Datenschutzhinweise-Link auf `startmenue_seite.dart`
  von unterhalb des QR-Codes direkt unter den "Verlauf"-Button
  verschoben — dort ging er vor dem grafisch unruhigen
  Hintergrundbild (`demo_people.png`) unter. Versionsstring
  r321a. Dateien: startmenue_seite.dart, kinoauswahl_seite.dart,
  pubspec.yaml.

- Run 321: Datenschutzhinweise-Link zusätzlich auf
  `startmenue_seite.dart` ergänzt (bisher nur auf
  `kinoauswahl_seite.dart` sichtbar). Grund: Sobald der geplante
  Standort-Betriebsmodus für MA-Geräte die Kinoauswahl-Seite
  überspringt, wäre der Link sonst nirgends mehr erreichbar.
  Versionsstring r321. Dateien: startmenue_seite.dart,
  kinoauswahl_seite.dart, pubspec.yaml.

- Run 320: Sicherheitslücke Admin-Bereich behoben —
  `_devAufgeklappt` in `einstellungen_seite.dart` war fälschlich
  als `static` deklariert, wodurch der PIN-geschützte
  Verwaltungsbereich für die gesamte laufende App-Sitzung
  entsperrt blieb, auch nach Verlassen und erneutem Öffnen der
  Einstellungen-Seite. Jetzt normales Instanzfeld — jeder erneute
  Aufruf der Seite erzeugt einen neuen State mit
  `_devAufgeklappt = false`, PIN wird wieder verlangt. Bewusst
  kein zusätzlicher AppLifecycleState-Listener für
  Hintergrund/Vordergrund (Edge-Case zurückgestellt, siehe
  TODO.md). Versionsstring r320. Dateien: einstellungen_seite.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 319d: Widerspruch in den Datenschutzhinweisen behoben
  (`datenschutz_seite.dart`, Abschnitt „Ausnahme: BelegScan
  (optional)"): Satz „Das Foto verlässt dabei nie die interne
  Kino-IT" widersprach dem vorherigen Satz zur Anthropic-API (USA)
  und wurde entfernt. Stattdessen Hinweis ergänzt, dass die
  Anthropic-Übermittlung über EU-Standardvertragsklauseln rechtlich
  abgesichert ist. Versionsstring r319d. Dateien:
  datenschutz_seite.dart, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 319c: Korrekturen aus Testfeedback zu Run 319a/319b. (1)
  Belegscan-Prüf-Popup (`beleg_scan_bestaetigen_dialog.dart`): TID
  wurde bei unlesbarem Wert bisher komplett ausgeblendet (zeigte
  gar nichts an, obwohl Pflichtfeld) — zeigt jetzt "nicht lesbar"
  in Rot. Neues Feld `nameNichtLesbar` auf `BelegScanZeilenVorschau`:
  "Unbekannte Kartenart" wird jetzt rot hervorgehoben statt normal
  dargestellt. Bugfix in `_baueScanVorschauZeilen`
  (tagesabschluss_schritt2_seite.dart): Zahlungsart-Zeilen, bei
  denen sowohl Kartenart als auch Betrag unlesbar waren, wurden
  bisher komplett übersprungen (unsichtbar im Popup) — werden jetzt
  als Zeile mit "nicht lesbar" angezeigt. Das manuelle Nachtragen
  war bereits vorher möglich (Kachel-Felder bleiben nach
  "übernehmen" leer und editierbar) — das eigentliche Problem war
  die fehlende Sichtbarkeit im Popup selbst, nicht eine fehlende
  Editiermöglichkeit. (2) TODO.md "Kein Screen-Flip" wieder auf
  offen gesetzt: Test auf Pacos iPhone-PWA zeigt weiterhin Rotation
  trotz Manifest-Sperre (iOS/WebKit unterstützt das bekanntermaßen
  unzuverlässig) — Verifikation auf echtem Android-Gerät (Zielplattform)
  noch ausstehend. Versionsstring r319c. Dateien:
  beleg_scan_bestaetigen_dialog.dart, tagesabschluss_schritt2_seite.dart,
  TODO.md.

- Run 319b: TODO.md-Gesamtaudit + 4 neue Punkte aus Nutzer-Feedback.
  Geprüft und abgehakt: "Kein Screen-Flip" (bereits per
  SystemChrome + web/manifest.json portrait-primary umgesetzt, mit
  Einschränkung für nicht-installierte Browser-Tabs), "Eingabe mit
  Komma"-Einstellung (bereits seit Run 317 vollständig entfernt),
  "KI-Prompt verbessern" (aktueller System-Prompt erfüllt bereits
  alle genannten Punkte). Neu gefunden und ergänzt: Sicherheitslücke
  im Verwaltungsbereich — `_devAufgeklappt` in
  `einstellungen_seite.dart` ist fälschlich `static`, wodurch die
  PIN-Entsperrung für die gesamte App-Sitzung bestehen bleibt statt
  nur für den aktuellen Seitenaufruf (noch nicht behoben, nur
  dokumentiert). "Standort vorauswählen (Admin)" um die neue
  Anforderung erweitert (Betriebsmodus Alle/SB/CO/AT/GO/BT,
  "Kino wechseln"-Button nur bei "Alle" sichtbar). Neuer Punkt:
  Getränkeliste soll im Filter "nur benötigte anzeigen" Checkboxen
  bekommen, abgehakte Einträge wandern ans Listenende, Reihenfolge
  wird beim Zurückschalten auf "alle anzeigen" zurückgesetzt. Keine
  App-Code-Änderung. Versionsstring r319b. Datei: TODO.md.

- Run 319a: Korrekturen aus Review der Kunden-Übersicht
  (kassenabrechnung-validierungen.html). (1) Dokument korrigiert:
  Ziffernfilter gilt für alle Zähl- UND Betragsfelder (nicht nur
  Stückzahl); "Umschlag nicht deckbar" erklärt jetzt, dass Rollen/
  Umschläge nicht in den Vorschlag einfließen; Personalgetränke-
  Bestätigung von "Rückfrage" auf "Stopp" korrigiert (kein
  Bypass-Button); Scan-Fehlermeldung erwähnt jetzt manuelle
  Eingabe. (2) wechselgeld_pruefen_seite.dart: Differenz-Prüfung
  in `_pruefeDifferenzUndBestaetigeVerlassen()` extrahiert und per
  `PopScope` + geprüftem Haus-Button auf alle drei Ausgänge der
  Seite gelegt (Zurück-Pfeil und Haus-Button umgingen die Prüfung
  bisher komplett, nur Fertig-Button war abgedeckt). (3)
  tagesabschluss_schritt2_seite.dart: Scan-Fehlermeldungen
  (Netzwerkfehler, unscharfes Foto) weisen zusätzlich auf die
  Möglichkeit zur manuellen Eingabe hin. (4)
  stueckelung_vorschlag_seite.dart: "Nicht abdeckbar"-Zeile zeigt
  jetzt einen Erklärungssatz (Rollen/Umschläge nachzählen). (5)
  Sicherheitsnetz gegen stillen Datenverlust bei mehreren
  Abrechnungen pro Tag: neues Feld `Kino.maxAbrechnungenProTag`
  (Standard 1, Bar Tabak 2); `SpeichereTagesabschlussUsecase` gibt
  `weitereAbrechnungMoeglich` zurück statt automatisch zu
  überschreiben; Schritt 3 fragt bei Kinos mit >1 Abrechnung/Tag
  "Ersetzen" vs. "Zusätzliche Abrechnung" ab, statt still zu
  überschreiben; `LokalerSpeicher.ersetzeFinalenTagesabschluss`
  ersetzt nur noch den jüngsten gleichentags-Eintrag statt aller
  (verhindert Verlust einer bereits gespeicherten zweiten
  Abrechnung). Betrifft nur Bar Tabak — Verhalten für alle anderen
  Standorte unverändert. Ersetzt NICHT die eigentliche "1./2.
  Abrechnung"-Buttons-Umstellung (TODO.md "Größere Umbauten"),
  reduziert nur das Datenverlust-Risiko bis dahin. Grundlage für
  (5): Yannik/Flurbocash-Doku bestätigt, dass BT serverseitig
  bereits über auto-nummerierte `settlement_number` unterstützt
  wird — die App-lokale Seite hatte dafür bisher keine
  Absicherung. Versionsstring r319a. Dateien:
  kassenabrechnung-validierungen.html, wechselgeld_pruefen_seite.dart,
  tagesabschluss_schritt2_seite.dart, stueckelung_vorschlag_seite.dart,
  kino.dart, speichere_tagesabschluss_usecase.dart,
  lokaler_speicher.dart, tagesabschluss_schritt3_seite.dart, TODO.md.

- Run 319: Datenschutzhinweise vorgezogen an den geplanten
  Flurbocash-Belegfoto-Versand angepasst (Abschnitt „Ausnahme:
  BelegScan (optional)"): Belegfoto wird künftig zusätzlich zur
  KI-Auswertung an den kino-internen Server (Flurbocash) zur
  rechtskonformen Archivierung übertragen; Satz „kein Foto wird
  gespeichert oder weitergeleitet" entfernt. TODO.md-Punkt
  „Belegfoto als base64 an Flurbocash" ergänzt (wartet auf
  Yannik-API-Vertrag). Versionsstring r319. Dateien:
  datenschutz_seite.dart, TODO.md, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 318b: Kunden-Übersicht "Eingabeprüfungen & Fehlervermeidung"
  als HTML-Dokument angelegt (gleiches Design wie die bestehenden
  Verkaufsunterlagen: DM-Serif/DM-Sans, Tags Stopp/Rückfrage/
  Hinweis/Automatik). Keine App-Code-Änderung. Datei:
  .dev/verkauf/kassenabrechnung-validierungen.html.

- Run 318: Bestätigungs-Popup nach EC-Beleg-Scan eingeführt (neue
  Datei `beleg_scan_bestaetigen_dialog.dart`): zeigt Datum, TID,
  alle erkannten Kartenarten mit Beträgen sowie die vom Beleg
  gelesene Gesamtsumme, mit den Aktionen "nochmal" (Kamera-Icon)
  und "übernehmen". Die Formularübernahme (Beträge, TID, Datum,
  Kartenart-Tabelle) in `_starteEcBelegScan()`
  (tagesabschluss_schritt2_seite.dart) passiert jetzt erst nach
  "übernehmen" statt automatisch direkt nach dem Scan — Ziel: den
  Reflex verhindern, Scan-Ergebnisse unkontrolliert zu übernehmen.
  Neue read-only Methode `_baueScanVorschauZeilen()` baut die
  Popup-Vorschau, ohne die eigentlichen Formularfelder zu
  verändern. Der bestehende "Kein Terminal-Beleg"-Fehlerdialog
  bleibt unverändert und läuft weiterhin davor. Kein Bezug zum
  alten `BelegScanGegenpruefDialog` (bereits in Run 307 aus
  anderem Grund entfernt — dort ging es um Fehler-/
  Plausibilitätshinweise, hier um eine bewusste Bestätigung vor
  der Übernahme). Versionsstring r318. Dateien:
  beleg_scan_bestaetigen_dialog.dart (neu),
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 317a: TODO.md-Punkt "CORS-Header" abgehakt. Yannik hat
  X-API-Key zu access-control-allow-headers ergänzt ("x-api-keys
  sind nun erlaubt", 2026-07-14). Erster echter Live-Test des
  Flurbocash-Uploads für Schauburg (location_id 1) erfolgreich —
  Tagesbericht im Flurbocash-Dashboard korrekt angekommen, Bargeld-
  und EC-Kartenwerte stimmen exakt mit der App-Eingabe überein.
  Keine App-Code-Änderung. Versionsstring r317a. Datei: TODO.md.

- Run 317: Validierungen Schritt 2 + „Eingabe mit Komma"-Einstellung
  entfernt. Pflichtfeld-Fehler zeigen jetzt AlertDialog statt Snackbar.
  Neue Validierungen: Ausgaben mit Label aber Betrag = 0 (V3, harter
  Fehler), Kino-Soll = 0 (V5, Bestätigung), EC = 0 (V7, Bestätigung).
  Eingabemodus fix auf Ziffern-Modus (wie EC-Terminal). Unit-Tests für
  hatAusgabeMitFehlendemBetrag und istEcNull. Geänderte Dateien:
  tagesabschluss_berechnung.dart, tagesabschluss_berechnung_test.dart,
  einstellungen_seite.dart, tagesabschluss_schritt1_seite.dart,
  tagesabschluss_schritt2_seite.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 316d: TODO.md-Punkte im Block "Blockiert — wartet auf IT
  (Yannik)" mit aktuellem Wissensstand (2026-07-12) abgeglichen.
  Beantwortet/abgehakt: location_id (SB=1, Atlantis=3,
  BarTabac=4; Gondel/CO weiterhin offen, aber laut Plan erst
  nach SB relevant), X-API-Key-Modell (ein eigener Key pro
  Standort, kein gemeinsamer — Key-Werte selbst nicht in der
  Datei, nur in den App-Einstellungen), Testumgebung (Sandbox-
  URL bekannt). CORS-Header-Punkt präzisiert: Origin ist
  gesetzt, einziger noch offener Blocker ist X-API-Key in
  access-control-allow-headers (Anfrage an Yannik läuft). Keine
  App-Code-Änderung. Versionsstring r316d. Datei: TODO.md.

- Run 316c: Flurbocash-Fehlermeldungen präzisiert. Bisher zeigte
  ApiUploadService._pruefeStatus bei einem Fehler (400/401/403/
  404/500) nur eine fest einprogrammierte, generische deutsche
  Meldung — der tatsächliche Klartext-Grund aus der Server-Antwort
  wurde verworfen. Jetzt wird response.body (falls vorhanden) in
  Klammern an die bestehende Meldung angehängt, sodass z. B. bei
  einem 400 sichtbar wird, ob der Grund "unknown tid", "maximum
  of 4 settlements per day reached" oder "report is finalized"
  war, statt nur der pauschalen Vermutung "Ungültige Daten oder
  Terminal-ID unbekannt". Versionsstring r316c. Datei:
  api_upload_service.dart.

- Run 316b: TODO.md-Kopfzeile war seit Run 313h nicht mehr
  aktualisiert worden (stand noch auf "Run 313") — auf aktuellen
  Stand (Run 316b) korrigiert. Neue Regel in CLAUDE.md und
  AGENTS.md ergänzt, damit die Kopfzeile künftig bei jedem Run
  (auch Sub-Runs) mitgezogen wird. Keine App-Code-Änderung.
  Dateien: TODO.md, CLAUDE.md, AGENTS.md.

- Run 316a: Korrektur von Run 316 — Hinweis "Bistro SOLL ist
  höher als Kino SOLL" wieder entfernt. Grund: Prämisse gilt
  nicht standortübergreifend (Gondel hat Restaurant-Umsatz, dort
  kann Bistro-Soll legitim höher sein als Kino-Soll). Bewusst
  vorerst weggelassen; TODO.md-Punkt wieder auf offen gesetzt
  mit Begründung. Dateien: tagesabschluss_berechnung.dart,
  tagesabschluss_schritt2_seite.dart,
  tagesabschluss_berechnung_test.dart, TODO.md.

- Run 316: Weicher Hinweis "Bistro SOLL ist höher als Kino SOLL"
  in Schritt 2, sobald beide Felder befüllt sind und keines
  fokussiert ist (Wiederverwendung des bestehenden
  Hinweistext-Musters). Neue reine Funktion
  `TagesabschlussBerechnung.bistroSollUeberschreitetKinoSollCent()`
  mit Unit-Test. TODO.md: Punkt abgehakt; zusätzlich "Soll-Felder
  leer"-Punkt als bereits umgesetzt markiert (war veraltet).
  Dateien: tagesabschluss_berechnung.dart,
  tagesabschluss_schritt2_seite.dart,
  tagesabschluss_berechnung_test.dart, TODO.md.

- Run 315a: Zeilenabstand bei "nur benötigte anzeigen" von 1 auf
  0.7 verkleinert (Feinjustierung durch Paco); dabei versehentlich
  eingefügten Tippfehler (`TableRow(flutt`) behoben. TODO.md-Notiz
  zur Differenz-Anfangsbestand-Prüfung um die Timing-Korrektur aus
  Run 314a2 ergänzt (fehlte bisher). Datei:
  getraenke_auffuellen_seite.dart, TODO.md.

- Run 315: Getränke-Auffüllen-Seite — Unterstreichung der
  Mengenfelder wird nur noch gezeigt, wenn "alle anzeigen" aktiv
  ist; bei aktivem Filter "nur benötigte anzeigen" verschwindet die
  Unterstreichung (`border: InputBorder.none`) und der vertikale
  Zeilenabstand verkleinert sich (3 → 1), damit mehr Getränke ohne
  Scrollen auf eine Seite passen. Datei:
  getraenke_auffuellen_seite.dart.

- Run 314a2: Korrektur von Run 314a (T1) — Die Differenz-Prüfung
  lief bisher erst NACH dem Öffnen des Menüs "Was möchtest du als
  nächstes tun?" (Nutzer wählte z. B. "Fertig / Startseite", dann
  erst kam der Bestätigungsdialog). Jetzt läuft die Prüfung VOR
  dem Öffnen dieses Menüs: `_versucheAbschlussDialogZuOeffnen()`
  ersetzt den direkten Aufruf von `_zeigeAbschlussDialog()` am
  Footer-Button. Bei Differenz ≠ 0 erscheint zuerst der
  Bestätigungsdialog; das Menü öffnet sich erst danach (bzw. sofort
  bei Differenz = 0). Betrifft sowohl "Fertig / Startseite" als
  auch "Getränke auffüllen", da beide nur über dieses eine Menü
  erreichbar sind. Versionsstring r314a2. Datei:
  wechselgeld_pruefen_seite.dart.

- Run 314a: Korrektur von Run 314 — "Differenz Anfangsbestand"
  von passivem Hinweis-beim-Zählen auf Bestätigungssperre-beim-
  Verlassen umgestellt. Grund: Ein Text in der Zusammenfassungs-
  Karte hätte das eigentliche Problem (MA übersieht/ignoriert die
  Differenz) nicht gelöst — dieselbe Schwäche wie die schon vorher
  sichtbare rote Differenz-Zeile. Neue Methode
  `_pruefeDifferenzVorVerlassen()` in `wechselgeld_pruefen_seite.dart`
  prüft beim Tap auf "Fertig / Startseite" ODER "Getränke
  auffüllen", ob die Differenz zum Wechselgeld-Sollwert exakt 0
  ist (kein Schwellwert mehr — jede Abweichung zählt, da der
  Wechselgeldbestand für den nächsten Tag exakt stimmen muss).
  Bei Abweichung: Bestätigungsdialog "Wechselgeld stimmt nicht —
  Differenz: X,XX €. Trotzdem fortfahren?", erst nach "Ja,
  trotzdem weiter" geht's weiter. Die in Run 314 dafür angelegte
  20-€-Schwellwert-Methode
  (`istAnfangsbestandDifferenzAuffaellig`) samt Unit-Test wieder
  entfernt, da ohne Restnutzen. Versionsstring r314a. Dateien:
  tagesabschluss_berechnung.dart, tagesabschluss_berechnung_test.dart,
  wechselgeld_pruefen_seite.dart.

- Run 314: Erste Validierungspunkte aus TODO.md abgearbeitet.
  (1) "Negativer Betrag im Zählfeld" als entfällt markiert —
  `GanzzahlEingabefeld` filtert Eingaben bereits mit
  `FilteringTextInputFormatter.digitsOnly`, ein Minuszeichen kann
  dort technisch nicht eingegeben werden. (2) "500 €/200 €-Scheine
  vorhanden" ebenfalls entfällt — die App kennt diese
  Denominationen in `StueckelungKonfiguration.scheine` gar nicht
  (max. 100 €). (3) "Differenz Anfangsbestand > 20 €" umgesetzt:
  neue Methode `TagesabschlussBerechnung
  .istAnfangsbestandDifferenzAuffaellig()` (Schwellwert 2000 Cent)
  mit Unit-Test, dazu weicher Hinweistext (nicht blockierend) in
  der Zusammenfassung von `wechselgeld_pruefen_seite.dart`, wenn
  die Differenz zum Wechselgeld-Sollwert die 20-€-Marke
  überschreitet. Ab diesem Run werden neue Validierungsregeln aus
  TODO.md grundsätzlich zusammen mit einem Unit-Test im selben Run
  umgesetzt. Versionsstring r314. Dateien:
  tagesabschluss_berechnung.dart,
  tagesabschluss_berechnung_test.dart, wechselgeld_pruefen_seite.dart.

- Run 313j: Regression aus Run 313i behoben — Beleg-Scan brach mit
  "Keine Internetverbindung" ab, sobald ein Anthropic-API-Key in den
  Einstellungen eingetragen war. Ursache: Der zusätzlich gesendete
  x-api-key-Header löste im Browser eine CORS-Preflight-Anfrage aus,
  die der Cloudflare-Worker nicht erlaubt — der Browser blockierte
  die Anfrage komplett, bevor sie das Netzwerk verließ, was als
  "keine Verbindung" erschien. x-api-key-Header-Versand wieder
  entfernt, `scan()` sendet wie vor Run 313i nur `content-type`.
  Das Einstellungen-Feld bleibt bestehen, ist aber wie zuvor (seit
  Run 272) ohne Wirkung auf den Scan, bis eine passende
  Worker-seitige CORS-/Header-Anpassung vorliegt (nicht Teil dieses
  Repos). Versionsstring r313j. Datei: beleg_scan_service.dart.

- Run 313i: Anthropic-API-Key aus den Einstellungen wieder aktiv
  genutzt. Seit Run 272 war das Feld funktionslos (Umstellung des
  Beleg-Scans auf einen Cloudflare-Worker als Proxy, dabei wurde die
  Key-Verwendung im Client bewusst entfernt — "kein API-Key im
  Client"). `BelegScanService.scan()` liest den gespeicherten Key
  jetzt wieder aus SharedPreferences und schickt ihn, falls
  vorhanden, als `x-api-key`-Header an den Worker mit.
  **Wichtig:** Das allein reicht noch nicht — der Cloudflare-Worker
  (kartenzahlungsbelegscan.pacodemant.workers.dev, Code liegt nicht
  in diesem Repo) muss zusätzlich so angepasst werden, dass er einen
  eingehenden `x-api-key`-Header als Override für seinen eigenen
  serverseitigen Key verwendet — sonst wird der Header zwar
  gesendet, aber vom Worker ignoriert. Bis dahin bleibt der
  Sicherheits-Kompromiss aus Run 272 (Key nicht im Netzwerkverkehr
  sichtbar) nur teilweise aufgehoben: der Header wird jetzt
  mitgeschickt, hat aber ohne Worker-Anpassung keine Wirkung.
  Versionsstring r313i. Datei: beleg_scan_service.dart.

- Run 313h: Einstellungen-Admin-Bereich aufgeräumt.
  (1) Wechselgeldbestand-Karte war bisher frei zugänglich (vor dem
  PIN-geschützten Admin-Bereich) — jetzt in den Admin-Bereich
  verschoben, nur noch nach PIN-Eingabe sichtbar/änderbar.
  (2) "Google Sheets Upload" komplett entfernt (Google Sheets wird
  nicht mehr genutzt, Test läuft jetzt über Flurbocash): Switch in
  den Einstellungen, GoogleSheetsService/-Config (Dateien gelöscht),
  Upload-Aufruf in tagesabschluss_schritt3_seite.dart,
  FeatureFlags.googleSheetsAktiv()/-Setzen(), Dependency
  google_sign_in aus pubspec.yaml, GIDClientID/CFBundleURLTypes aus
  ios/Runner/Info.plist, lokale Dev-Dateien (Client-Secret-JSON,
  Test-Skript) aus secrets/ (nie eingecheckt, nur lokal). (3) Switch
  "API Upload (Test)" umbenannt in "Flurbocash-Upload (Test)".
  Versionsstring r313h. Dateien: einstellungen_seite.dart,
  tagesabschluss_schritt3_seite.dart, feature_flags.dart,
  pubspec.yaml, ios/Runner/Info.plist,
  lib/services/google_sheets_service.dart (gelöscht),
  lib/services/google_sheets_config.dart (gelöscht).

- Run 313g: Admin-PIN-Dialog (Einstellungen) — Fokus/Tastatur
  erscheint jetzt wieder zuverlässig automatisch beim Öffnen (100ms-
  Delay + requestFocus() nach Run-294-Vorbild, war seit Run 294c
  wieder unzuverlässig weil showGeneralDialog+Duration.zero zugunsten
  der Öffnungs-Animation zurückgebaut wurde). Zusätzlich: Eingabe
  wird bei 4 Ziffern automatisch bestätigt (kein Tippen auf "OK"
  mehr nötig, auch bei korrekter PIN nicht) — wie bei Enter/
  onSubmitted, nur automatisch nach der letzten Ziffer. Versionsstring
  r313g. Datei: einstellungen_seite.dart.

- Run 313f: Wechselgeld-Prüfen-Seite — Differenz-Zeile in der
  Zusammenfassung zeigt jetzt ein Vorzeichen (+/−) vor dem Betrag,
  damit auf einen Blick erkennbar ist, ob zu viel oder zu wenig Geld
  in der Wechselgeldkasse liegt. Rote Hervorhebung bei jeder
  Abweichung ≠ 0 bleibt unverändert (bewusst so gewünscht). Nutzt
  die bereits vorhandene `TagesabschlussFormatierung.
  formatiereEuroMitVorzeichen()` statt der vorzeichenlosen
  `formatiereEuro()`. Versionsstring r313f. Datei:
  wechselgeld_pruefen_seite.dart.

- Run 313e: Pflichtfeld-Prüfung vor "Weiter" zu Schritt 3
  (`_pruefePflichtfelderVorSchritt3()`) prüfte Terminal-ID und
  Gesamt-Betrag bisher nur für den ersten EC-Beleg (`.first`) — im
  Mehrbeleg-Modus (2+ EC-Belege) konnten weitere Belege mit leerer
  TID/leerem Gesamt-Betrag unbemerkt zu Schritt 3 durchrutschen.
  Prüfung läuft jetzt über alle vorhandenen EC-Belege, klappt die
  jeweilige Unterkachel auf und fokussiert das erste fehlerhafte
  Feld. Gesamt-Betrag-Fehlertext ("Pflichtfeld") wird jetzt auch für
  Beleg 2+ angezeigt statt nur für Beleg 1. TODO.md:
  "Fertig-Button-Gate" mit angepasster Umsetzung abgehakt (Button-
  Ausgrauen entfiel als redundant, echte Lücke stattdessen
  geschlossen). Versionsstring r313e. Datei:
  tagesabschluss_schritt2_seite.dart.

- Run 313d: BelegScan-KI-Prompt um zwei Regeln ergänzt —
  (1) Kartenbeträge müssen anhand der Zeilenposition auf dem Beleg
  der richtigen Kartenart zugeordnet werden (nicht nach Reihenfolge/
  Erfahrungswerten), (2) gesamt_betrag_cent muss vom gedruckten
  Gesamtfeld abgelesen werden statt aus den Zahlungsart-Beträgen
  berechnet zu werden — sonst liefe der bestehende Summen-Abgleich
  ("hinweis"-Regel) ins Leere. TODO.md: Punkt "Scheinfeld nicht durch
  Nennwert teilbar" als entfallen markiert (Scheine/Rollen sind
  Stückzahl-Felder, das beschriebene Problem kann dort nicht
  auftreten). Dateien: beleg_scan_service.dart, TODO.md.

- Run 313c: SB-Auto-Fill (Dev-Tools) auf Belege-Seite befüllt jetzt
  auch die Terminal-ID der Schauburg (54017635) sowie das editierbare
  Summenfeld "Gesamt (laut Beleg)" in der Kartenarten-Tabelle
  (`_kartenartenGesamtBetragCent`/-Controller) — bisher wurde die
  Summe nur im Titel der EC-Belege-Kachel angezeigt, TID-Feld und
  Gesamt-Feld blieben leer. Versionsstring r313c. Datei:
  tagesabschluss_schritt2_seite.dart.

- Run 313b: Stückzahl-Eingabefelder (Scheine/Rollen) erlauben jetzt
  dreistellige Werte — bisher war bei 99 Schluss (`maxLaenge: 2`),
  wodurch sich z. B. 102 Zehner-Scheine nicht eintragen ließen.
  `Schritt1ZeilenEintrag` (gemeinsames Widget für Schritt 1 und die
  Wechselgeld-Prüfen-Seite) setzt `maxLaenge: 3` auf dem
  `GanzzahlEingabefeld`. Versionsstring r313b. Dateien:
  schritt1_ui_builder.dart, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 313a: TODO.md nach Besprechung offener Punkte aktualisiert —
  „Fallback-Export bei fehlgeschlagenem Upload" als nicht nötig
  markiert (bereits durch automatisches Geräte-Backup abgedeckt),
  „Plausibilitätsprüfung deaktivierbar" als nicht nötig markiert
  (Prüfung ist bereits nur weicher Hinweis), „Admin-Passwort" bleibt
  PIN 1929, „Standort vorauswählen" und „Safari-iOS: Lokale
  Speicherung" als zurückgestellt vermerkt. Datei: TODO.md.

- Run 313: Ladesplash-Overlay über die komplette EC-Belege-Kachel
  während eines Scans — zusätzlich zum bestehenden Spinner im
  Kamera-Button wird jetzt die gesamte Kachel (Header + Terminal-ID +
  Kartenarten-Tabelle, egal ob ein- oder mehrere Belege) mit einem
  halbtransparenten Scrim (`Colors.white`, Alpha 0.85) und zentriertem
  `CircularProgressIndicator` in Kino-Rot überdeckt, solange
  `_scanLaeuft` aktiv ist — nutzt denselben `Stack`, der bereits den
  Scroll-Pfeil-Gradient trägt. Der Overlay blockiert dabei auch
  Eingaben in der Kachel während des Scans (kein `IgnorePointer`).
  Mit Playwright gegen einen lokalen Release-Build visuell geprüft
  (Overlay temporär erzwungen, Screenshots im ein- und
  aufgeklappten Zustand angesehen, danach vollständig zurückgesetzt).
  Versionsstring r313. Dateien: tagesabschluss_schritt2_seite.dart,
  pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 312: Lade-Splash in web/index.html — `#splash`-Div (Hintergrund
  Kino-Rot `#5C0A0A`, zentriertes App-Icon `icons/Icon-192.png`)
  direkt im `<body>` vor dem Flutter-Bootstrap-Script ersetzt den
  weißen Blitzer beim App-Start. Wird per `flutter-first-frame`-
  Browser-Event automatisch ausgeblendet (300ms Fade) und entfernt,
  sobald Flutter den ersten Frame gerendert hat — reines HTML/CSS/JS,
  kein Dart-Code nötig (der Blitzer entsteht, bevor die Flutter-Engine
  überhaupt läuft). Mit Playwright gegen einen lokalen Release-Build
  getestet: Splash sichtbar direkt nach domcontentloaded, sauber
  entfernt nach dem ersten Frame, keine Konsolenfehler. Versionsstring
  r312. Dateien: web/index.html, pubspec.yaml, startmenue_seite.dart,
  kinoauswahl_seite.dart.

- Run 311: Verlauf-30-Tage-Bereinigung — neue Methode
  `LokalerSpeicher.bereinigeAlteTagesabschluesse(kinoId, {maxAlterTage
  = 30})` entfernt beim App-Start abgeschlossene Tagesabrechnungen,
  deren Kalendertag mehr als 30 Tage zurückliegt (Datenschutz); wird
  nur geschrieben, wenn sich tatsächlich etwas ändert. In `main.dart`
  in die bestehende Kino-Schleife beim Start eingehängt (analog zur
  GetraenkeConfigService-Initialisierung), läuft still ohne
  Nutzer-Interaktion. Versionsstring r311. Dateien:
  lokaler_speicher.dart, main.dart, pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 310: TODO.md korrigiert — Punkt "Automatisches Geräte-Backup
  beim Senden" abgehakt. War bereits erledigt:
  `_autoSaveImHintergrund()` in tagesabschluss_schritt3_seite.dart
  speichert die Abrechnung automatisch beim Erreichen von Schritt 3
  lokal (Hive box_tagesabschluesse), unabhängig vom späteren
  API-Upload-Ergebnis; Schritt 3 hat keine editierbaren Felder, die
  danach noch verloren gehen könnten. Kein App-Code geändert. Datei:
  TODO.md.

- Run 309: TODO.md korrigiert — Punkt "Belegscan Metadaten
  zuklappbar machen" abgehakt. War bereits erledigt:
  `_baueMetadatenBlock()` in tagesabschluss_schritt2_seite.dart hat
  bereits einen Klapp-Mechanismus über `_metadatenAufgeklappt`. Kein
  App-Code geändert. Datei: TODO.md.

- Run 308: TODO.md ergänzt um Klärungspunkt "Terminals bei doppelter
  TID am selben Tag" unter "Blockiert — wartet auf IT". Anlass: Beim
  Testen von Run 307 stellte sich heraus, dass zwei EC-Belege
  derselben TID im JSON-Preview nur als eine (summierte)
  Terminal-Zeile erscheinen. Prüfung der IT-Spezifikation
  (`EXTERNAL_API_Schauburg_de.md`) zeigt: die Upsert-Semantik bei
  Korrekturen legt nahe, dass TID der eindeutige Schlüssel je
  Abrechnung ist — ein rein lokaler Fix (zwei Terminal-Zeilen mit
  gleicher TID senden) hätte bei Flurbocash vermutlich nichts
  bewirkt. Kein Code geändert, Klärung mit Yannik nötig. Datei:
  TODO.md.

- Run 307: Prüf-Popup nach EC-Beleg-Scan entfernt — nach einem
  erfolgreichen Scan wird das Ergebnis jetzt direkt in die EC-Kachel
  übernommen, ohne den bisherigen Zwischenschritt „EC-Beleg-Scan
  prüfen" (Übernehmen/nochmal). Die Warnhinweise aus dem Popup waren
  seit Run 304d3/304d4 redundant, da unplausible/unlesbare Werte
  bereits direkt in der Kachel rot/orange markiert und korrigierbar
  sind. Erneutes Fotografieren bleibt jederzeit über den
  Kamera-Button pro Beleg-Zeile möglich (überschreibt die bisherigen
  Werte). Der separate „Kein Terminal-Beleg"-Fehlerdialog bleibt
  unverändert bestehen. `beleg_scan_gegenpruef_dialog.dart` gelöscht
  (nirgends mehr verwendet), Klasse `BelegScanDialogErgebnis` aus
  `beleg_scan_ergebnis.dart` entfernt. Versionsstring r307. Dateien:
  tagesabschluss_schritt2_seite.dart, beleg_scan_ergebnis.dart,
  beleg_scan_gegenpruef_dialog.dart (gelöscht), pubspec.yaml,
  startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 306: TODO.md korrigiert — Punkt „Getränke-Nachfüllliste
  persistieren" entfernt. War bereits erledigt:
  `getraenke_auffuellen_seite.dart` speichert Mengen bei jeder Eingabe
  über `LokalerSpeicher.speichereGetraenkeMengen()` in die Hive-Box
  `box_getraenke_mengen` und lädt sie beim Öffnen wieder. Kein App-Code
  geändert. Datei: TODO.md.

- Run 305: TODO.md aufgeräumt — drei erledigte/obsolete Punkte aus „Kleine
  Fixes" entfernt: „Desktop-Ansicht begrenzen" (bereits in Run 301
  umgesetzt), „Beleg-Eingabe: Textbuttons" (Button existiert bereits, kein
  Textlink mehr) und „PWA-Install-Button (iOS)" (obsolet, da Geräte an den
  Standorten vorkonfiguriert mit installierter PWA ausgeliefert werden).
  Kein App-Code geändert. Datei: TODO.md.

- Run 304d5: PWA lädt neue Version jetzt automatisch statt über Banner-Button — `web/index.html` bekommt einen `visibilitychange`-Listener, der beim Zurückkehren aus dem Hintergrund aktiv `reg.update()` auslöst (bei einer installierten PWA gibt es keinen "neuen Tab", der den bisherigen Check anstößt). `main.dart`: `initSwUpdateWatcher`-Callback ruft bei erkannter neuer Version direkt `reloadPage()` auf statt ein `MaterialBanner` mit "Jetzt laden"-Button zu zeigen; da alle Eingaben (Schritt 1, Schritt 2, Wechselgeld) laufend als Entwurf persistiert werden, geht dabei nichts verloren. `MeineApp.scaffoldMessengerKey` (nur für den Banner gebraucht) entfernt. Versionsstring r304d5. Dateien: web/index.html, main.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 304d4: Rote Hervorhebung des "Gesamt"-Betrags bei Summen-Mismatch entfernt — wenn die Kartenart-Summe nicht mit dem eingegebenen Gesamtbetrag übereinstimmt, bleibt der Betrag jetzt neutral gefärbt (nur der orange Hinweistext darunter bleibt), damit der MA nicht fälschlich glaubt, das Gesamt-Feld selbst sei falsch, statt den ganzen Beleg zu prüfen. Versionsstring r304d4. Datei: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 304d3: Leere EC-Kachel öffnet jetzt direkt alle Kartenart-Zeilen samt "Gesamt"-Feld zur Bearbeitung — sowohl per Tap auf den Kachel-Header als auch über "manuell eingeben" (neue Hilfsmethode `_ersterBelegIstLeer()`/`_oeffneErstenBelegZurBearbeitungFallsLeer()`). Gesamt-Zeile heißt bei manueller Eingabe (kein Scan) nur noch "Gesamt", nach einem Scan weiterhin "Gesamt (laut Beleg)"; neues Hilfe-Icon daneben erklärt per Dialog, dass die Summe nicht berechnet, sondern zur Kontrolle eingegeben wird. Rote Hervorhebung von Kartenart-Zeilen korrigiert: `_istZeileImplausibel` prüft jetzt `zeile.nichtPlausibel` (echter Scan-Problemfall: Kartenart laut Rohdaten erkannt, aber Betrag nicht lesbar) statt der bisherigen Pauschal-Regel "Wert leer und Zeile sichtbar", die auch nicht auf dem Beleg stehende oder frisch manuell eingeblendete Zeilen fälschlich rot markierte; `_preFillZahlungsartenFromScan` setzt `nichtPlausibel` bei nicht erkannten Kartenarten explizit zurück (keine veralteten Markierungen aus früheren Scans). Versionsstring r304d3. Datei: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 304d2: Korrektur nach Test von 304d — "+ Weiteren Beleg hinzufügen" wieder hinter `hatEcBelege` gesetzt (erscheint erst nach Eingabe/Scan im ersten Beleg). "Gesamt (laut Beleg)" wieder an den Kartenart-Bearbeiten-Modus gekoppelt (`editModus`-Ternary Text/TextField wiederhergestellt) statt immer editierbar; `_pruefePflichtfelderVorSchritt3` setzt Beleg-1-Zeilen bei Validierung explizit auf `editing`, damit das Pflichtfeld sichtbar/fokussierbar bleibt. Link "manuell eingeben" (Beleg 1) setzt jetzt alle Kartenart-Zeilen direkt auf `editing` (alle akzeptierten Kartenarten sofort als Eingabefeld, keine "+"-Buttons). Die "+"-Buttons zum Nachtragen einzelner Kartenarten erscheinen nur noch, wenn für den Beleg bereits gescannt wurde (`_scanHatStattgefunden`) und nur für die dabei nicht erkannten Kartenarten. Versionsstring r304d2. Datei: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 304d: Oberes Gesamtbetrag-Feld im 1-Beleg-Modus entfernt (nur Terminal-ID bleibt dort stehen); Pflichtfeld für den EC-Gesamtbetrag auf das Feld "Gesamt (laut Beleg)" in der Kartenart-Tabelle verlegt, das jetzt für jeden Beleg immer editierbar ist (nicht mehr an den Kartenart-Bearbeiten-Modus gekoppelt) und eine eigene FocusNode-Liste `_kartenartenGesamtBetragFocusNode` erhält; Fokus-Reihenfolge (`_fokusReihenfolgeSchritt2`, `_erstesLeeresFeld`) und `_pruefePflichtfelderVorSchritt3` entsprechend umgestellt; `_ecBeleg1Beruehrt` in `_kartenartenGesamt1Beruehrt` umbenannt. Button "+ Weiteren Beleg hinzufügen" in der aufgeklappten EC-Kachel ist jetzt immer sichtbar (vorher nur nach erster Eingabe/Scan im ersten Beleg, `hatEcBelege`-Gate entfernt). Neuer Beleg im Mehrbeleg-Modus startet direkt mit editierbarem Terminal-ID-Feld (`_ecUnterkachelEditModus` startet bei `_ecBelegHinzufuegen()` auf `true` statt `false`). Versionsstring r304d. Datei: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 304c: Anzahl-Felder komplett aus der EC-Belege-Erfassung entfernt — Flurbocash und Google Sheets benötigen die Anzahl der Zahlungsvorgänge nirgends, nur Beträge zählen. BelegScan-KI-Prompt fragt "anzahl"/"gesamt_anzahl" nicht mehr ab; ZahlungsartErgebnis.anzahl und BelegScanErgebnis.gesamtAnzahl/anzahlPlausibel entfernt (Plausibilität nur noch über Beträge); Scan-Gegenprüf-Dialog zeigt keine Anz.-Spalte mehr; Schritt 2: Anz.-Spalte in Kartenart-Tabelle und "Gesamt (laut Beleg)"-Zeile entfernt, kompletter zugehöriger State (_kartenartenGesamtAnzahl*, _ZahlungsartZeile.anzahlWert/-Controller/-FocusNode) entfernt, Entwurf-Persistenz speichert Anzahl nicht mehr (alte Entwürfe mit dem Key werden beim Laden ignoriert). Versionsstring r304c. Dateien: beleg_scan_service.dart, beleg_scan_ergebnis.dart, beleg_scan_gegenpruef_dialog.dart, tagesabschluss_schritt2_seite.dart, tagesabschluss_final.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 304b: Mehrere EC-Terminals/Belege korrekt an Flurbocash gemeldet — bisher wurden bei mehr als einem EC-Beleg pro Tag alle Kartenbeträge unter nur einer TID (der zuletzt gescannten) zusammengefasst, andere Terminals fielen komplett unter den Tisch. `ZahlungsartErgebnis` bekommt neues optionales Feld `tid`; `_baueZahlungsartenListe()` in Schritt 2 trägt die TID pro Beleg ein (`_ecBelegLabels[belegIndex]`). `ApiUploadService._terminalsListe()` gruppiert die Kartenbeträge jetzt pro TID und baut einen `terminals[]`-Eintrag pro Terminal (ersetzt `_kartenBetraege()`). Bei nur einem EC-Beleg (Normalfall) unverändertes Verhalten; alte gespeicherte Abrechnungen ohne `tid`-Feld fallen auf die bisherige Einzel-Terminal-TID zurück. Versionsstring r304b. Dateien: beleg_scan_ergebnis.dart, tagesabschluss_final.dart, tagesabschluss_schritt2_seite.dart, api_upload_service.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 304a: JSON-Dialog zeigt exakt die echten Sende-Bodies — ApiUploadService bekommt zwei neue Methoden `ensureBody()`/`settlementsBody()`, die den bisher inline in `_ensure()`/`_settlements()` gebauten Request-Body übernehmen (eine Quelle der Wahrheit). `_zeigeFlurbocashJson()` in Schritt 3 ruft dieselben Methoden auf `_abschlussVorschau` auf statt eigenes JSON aus `_baueEcTerminals()` nachzubauen — behebt dabei auch den Bug, dass Kartenbeträge (Visa, MasterCard etc.) im Dialog immer 0 zeigten (Namens-Mismatch in der alten Vergleichslogik). Struktur des Dialogs ändert sich: "terminals" zeigt jetzt einen aggregierten Eintrag statt einem pro EC-Beleg, wie beim echten Upload. Versionsstring r304a. Dateien: api_upload_service.dart, tagesabschluss_schritt3_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 304: Dev-Dialog „JSON anzeigen" nutzt echte location_id — `_zeigeFlurbocashJson()` lädt den Wert jetzt aus SharedPreferences (Key `flurbocash_location_id_[kinoId]`, Parsing analog `ApiUploadService._ladeKonfigWerte()`) statt hartcodierter 0. Methode ist jetzt async mit mounted-Check vor dem Dialog. Veralteten TODO-Kommentar entfernt. Versionsstring r304. Dateien: tagesabschluss_schritt3_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart, pubspec.yaml.

- Run 303: Textlink „Alle zuklappen"/„Alle aufklappen" für Schritt 1 (Bargeld zählen) und Wechselgeld-Prüfen-Seite — rechtsbündig über den vier Kacheln (Scheine, lose Münzen, Rollen, Sonstiges). Ein Tap setzt alle vier Sections auf denselben aufgeklappt-Zustand; Linktext wechselt je nachdem ob mindestens eine Kachel offen ist. Neuer Widget-Parameter `alleZuklappenLink` in Schritt1BodyContent. Versionsstring r303. Dateien: tagesabschluss_schritt1_seite.dart, wechselgeld_pruefen_seite.dart, schritt1_body_content.dart, startmenue_seite.dart, kinoauswahl_seite.dart, pubspec.yaml.

- Run 302d: Kino-Rot für Label-Felder in Schritt 2 — Ausgaben-Label, EC-Label single-Beleg und EC-Label multi-Beleg auf AppFarben.appBarRot-Fill + weiße Schrift + transparenter Hint bei Fokus umgestellt; focusedBorder TID-multi-Beleg von blau auf appBarRot. border-Fallback in Ausgaben- und EC-Label-Feldern ebenfalls auf appBarRot. Versionsstring r302d. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 302c: Hint-Text bei Fokus ausblenden — hintStyle mit transparenter Farbe wenn hatFokus=true in ganzzahl_eingabefeld.dart und betrag_cent_eingabefeld.dart. Versionsstring r302c. Dateien: ganzzahl_eingabefeld.dart, betrag_cent_eingabefeld.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 302b: fillColor fokussierter Felder → Kino-Rot — Colors.black87 in ganzzahl_eingabefeld.dart (fillColor) und betrag_cent_eingabefeld.dart (fuellFarbe) auf AppFarben.appBarRot geändert. Versionsstring r302b. Dateien: ganzzahl_eingabefeld.dart, betrag_cent_eingabefeld.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 302: Schwarze Borders → Kino-Rot — alle OutlineInputBorder() ohne Farbe in ganzzahl_eingabefeld.dart (Normal-Zustand) und betrag_cent_eingabefeld.dart (gruenWert/rotWert/Default-Zustand, je grenzeLinie) auf AppFarben.appBarRot umgestellt. ganzzahl_eingabefeld.dart: AppFarben-Import ergänzt. Versionsstring r302. Dateien: ganzzahl_eingabefeld.dart, betrag_cent_eingabefeld.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 301: Desktop-Ansicht begrenzen — `MaterialApp.builder` mit `Center` + `ConstrainedBox(maxWidth: 430)` hinzugefügt; auf Bildschirmen > 430 px wird der Inhalt zentriert dargestellt. Versionsstring r301. Dateien: main.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 300a: TODO.md aufgeräumt — abgehakte [x]-Einträge entfernt, *(Run NNN)*-Planungsmarker aus offenen Punkten gelöscht, Duplikate zusammengeführt (Standort vorauswählen + Admin-Passwort je einmal in Phase C; BT-2-Abrechnungen in Größere Umbauten), Spontan-Ideen-Abschnitt entfernt, EC-Kachel State-Refactor (Run 297, war fälschlich noch offen) entfernt. Datei: TODO.md.

- Run 299: Stückelung-Legende + Anmerkungsfeld in Schritt 2. Legende: grüner Hinweiskasten unter der Stückelungstabelle. Anmerkungsfeld: neue Kachel „Hinweis / Kommentar (optional)" am Ende von Schritt 2 (nach EC-Belegen); wird im Entwurf gespeichert und im Verlauf angezeigt. Versionsstring r299. Dateien: stueckelung_vorschlag_seite.dart, tagesabschluss_schritt2_seite.dart, tagesabschluss_schritt3_seite.dart, tagesabschluss_finalisieren_usecase.dart, tagesabschluss_final.dart, verlauf_detail_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 298a: Mitarbeitername-Kachel aus Einstellungen entfernt — Feature entfällt komplett. Einstellungs-Card "Persönliche Einstellungen" zeigt jetzt nur noch den Komma-Eingabe-Switch. Versionsstring r298a. Dateien: einstellungen_seite.dart, tagesabschluss_schritt3_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 298: Kupfer-Bereich auto-aufklappen beim Laden — wenn beim Initialisieren von Schritt 1 Kupfer-Werte vorhanden sind (lose Münzen oder Rollen), werden die zugehörigen Bereiche automatisch aufgeklappt. Datei: tagesabschluss_schritt1_seite.dart.

- Run 297: EC-Kachel State-Refactor — `nichtImScan` (bool per Zeile) und `_kartenartenNurAnzeige` (List<bool> per Beleg) durch `ZeilenZustand`-Enum (`hidden`/`shown`/`editing`) ersetzt. Pro Zeile exakt ein Zustand; `editModus` per Beleg als berechnetes Prädikat (`.any(z => editing)`). Neues `_kartenartenFertig()`-Hilfsmethode. Alle Render-/Lade-/Speicher-/Scan-Pfade auf den Enum umgestellt. Versionsstring r297. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 296c: Bugfixes EC-Kachel Kartenarten — reset() setzt nichtImScan wieder auf true (unfilled Zeilen bleiben in Read-Mode unsichtbar); Change 3 aus 296b revertiert (1-Beleg-Modus startet wieder im Read-Mode mit Add-Buttons statt Edit-Mode). Auto-Fill füllt jetzt auch per-Kartenart-Beträge (Girocard/MasterCard/Visa aus Standardwerten) und schaltet nach Fill in Read-Mode. Versionsstring r296c. Dateien: tagesabschluss_schritt2_seite.dart, lokaler_speicher.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 296b: EC-Kachel Kartenzahlungen — Edit-Modus zeigt jetzt alle Kartenarten als Eingabefelder (nicht mehr nur per Add-Button erschließbar). Add-Buttons nur noch im Read-Modus. Werte im Edit-Modus setzen nichtImScan=false automatisch → bleiben nach "Fertig" in der Read-Ansicht. 1-Beleg-Modus ohne Daten startet direkt im Edit-Modus. settings.json: Bash(git -C *) erlaubt, deny-Liste für destruktive Git-Befehle. Versionsstring r296b. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart, .claude/settings.json.

- Run 296a: Personalgetränke-Checkbox für alle Standorte (hatGetraenke-Gate entfernt). Weiter-Button bleibt sichtbar und ausgegraut (grey.shade600/300); Tap ohne Haken zeigt SnackBar "Personalgetränke gebont?". Versionsstring r296a. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 296: Personalgetränke-Checkbox in Schritt 2 — über der Kachel "Differenz im Anfangsbestand" erscheint für Standorte mit Getränken (Atlantis, Schauburg, CO) eine Card-Kachel "Personalgetränke gebont?" mit runder grüner Checkbox. Weiter-Button bleibt gesperrt bis Checkbox abgehakt. Banner "Perso-Getränke nicht vergessen!" auf Startmenü-Kachel entfernt. Version 0.9.2+296. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart, pubspec.yaml.

- Run 295b: Echte Terminal-IDs (AT, SB, CO, BT) in config/terminal_ids.json eingetragen. FlurbocashConfigService (lib/services/flurbocash_config_service.dart) entfernt — war nicht mehr referenziert. Dummy-Dateien unter .dev/kassenberichte dummies/ in html/-Unterordner reorganisiert; Scan-Beispielbilder hinzugefügt. Dateien: config/terminal_ids.json, lib/services/flurbocash_config_service.dart (gelöscht), .dev/kassenberichte dummies/.

- Run 295a: Bugfix EC-Belege: nichtImScan wird beim Laden jetzt wiederhergestellt — Kartenart-Zeilen mit gespeicherten Werten erscheinen nach Seitenwechsel korrekt in der Tabelle (neues + altes Persistenzformat). Datei: tagesabschluss_schritt2_seite.dart.

- Run 295: Auto-Reload bei Tab-Öffnung (web/index.html): sessionStorage-Guard (_swFreshLoaded) — beim ersten Öffnen eines neuen Tabs werden alle SW-Caches gelöscht, alle SWs deregistriert und die Seite einmalig neu geladen; danach normaler Betrieb. Garantiert immer die neueste deployed Version beim App-Start. CLAUDE.md: Lösungsansatz-Check-Abschnitt ergänzt. Versionsstring auf r295. Dateien: web/index.html, CLAUDE.md, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 294c2: SW-Update-setInterval auf 1 Stunde korrigiert (war versehentlich 30 Sekunden). Datei: web/index.html.

- Run 294c: SW-Update-Banner (index.html): setInterval alle 1 Stunde → reg.update(), damit ein offener Tab eine neue Version erkennt ohne dass die Seite neu geladen werden muss. Admin-PIN-Session (einstellungen_seite.dart): _devAufgeklappt als static — bleibt über Navigationswechsel hinweg bis zum Tab-Schließen erhalten. showGeneralDialog → showDialog zurückgebaut (Animation wiederhergestellt). Versionsstring auf r294c. Dateien: web/index.html, einstellungen_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 294b: SW-Update-Detection (index.html): controllerchange-Listener als primären Mechanismus ergänzt (feuert wenn Flutter-SW via skipWaiting() die Kontrolle übernimmt); _hadController-Guard verhindert falsches Banner bei Erst-Installation. PIN-Dialog: showDialog → showGeneralDialog mit transitionDuration: Duration.zero; Future.delayed entfernt; autofocus: true bleibt (Tastatur erscheint nun im selben Frame wie der Tap). Versionsstring auf r294b. Dateien: web/index.html, einstellungen_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 294a: SW-Update-Detection (index.html): reg.waiting-Check als Race-Condition-Fix; reg.update() für sofortigen Update-Check; null-Guard auf newWorker. Admin-Kachel (Einstellungen): Zahnrad-Icon (Icons.settings) als leading-Widget. Versionsstring auf r294a. Dateien: web/index.html, einstellungen_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 294: PIN-Dialog (Einstellungen): FocusNode vor showDialog angelegt, dem TextField zugewiesen, nach Dialog-Öffnung via Future.delayed(100ms) requestFocus() aufgerufen, anschließend dispose(). Tastatur erscheint nun zuverlässig auf Flutter Web/iOS. Dateien: einstellungen_seite.dart.

- Run 293: ApiUploadService: catch (_) → catch (e) in _ensure() und _settlements(); ursprünglicher Browser-Fehlertext (z. B. "Load failed") wird als ($e) in die Exception eingebettet, damit isCorsArtFehler() in der UI greift und CORS-Fehler korrekt als "Empfang nicht bestätigbar" angezeigt werden. Dateien: api_upload_service.dart.

- Run 292: FlurbocashConfigService gelöscht; ApiUploadService._ladeKonfigWerte() liest ausschließlich SharedPreferences (api_upload_url, flurbocash_location_id_{kinoId}, flurbocash_api_key_{kinoId}, Fallback api_upload_key). Einstellungen Dev-Bereich: "Config: –"-Zeilen und "Zurücksetzen"-Buttons entfernt; Hints auf "location_id eingeben"/"API-Key eingeben"; orangefarbene "Manuell überschrieben: X"-Zeile zeigt gespeicherten Wert. config/flurbocash_anbindung.json nach secrets/ verschoben (lokal, kein Commit). Version 0.9.2+292. Dateien: flurbocash_config_service.dart (gelöscht), api_upload_service.dart, einstellungen_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 291: FlurbocashConfigService (neu) liest config/flurbocash_anbindung.json und liefert sandboxUrl, locationId und apiKey pro kinoId. ApiUploadService.upload() nimmt keine url/apiKey-Parameter mehr — lädt alles intern via FlurbocashConfigService, mit SharedPrefs-Override-Logik (flurbocash_location_id_{kinoId}, flurbocash_api_key_{kinoId}). Einstellungen-Seite (Dev-Bereich): location_id-Feld zeigt Config-Wert + Override-Status; neues API-Key-Feld mit Speichern/Zurücksetzen. verlauf_detail_seite.dart und tagesabschluss_schritt3_seite.dart auf neue upload()-Signatur aktualisiert. Version 0.9.1+291. Dateien: flurbocash_config_service.dart (neu), api_upload_service.dart, einstellungen_seite.dart, tagesabschluss_schritt3_seite.dart, verlauf_detail_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 290: ApiUploadService vollständig auf Flurbocash-2-Call-Flow umgebaut. Schritt 1: POST /api/daily-reports/ensure (location_id aus SharedPreferences, date aus abrechnung.datum) → report_id; wird unter `flurbocash_report_id_{kinoId}_{yyyy_mm_dd}` gespeichert. Schritt 2: PUT /api/daily-reports/{report_id}/settlements (cash_total + terminals mit 6 Kartenfeldern). Explizites Kartenart-Mapping (Display-Strings und Lowercase-Keys). apiKey wird als X-API-Key-Header gesendet. Deutsche Fehlertexte für 400/401/403/404/500/Netzwerk. Alte form-encoded Logik entfernt. Version 0.9.0+290. Dateien: api_upload_service.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 287: PIN-Schutz für Entwicklermodus (PIN 1929, nur Session); location_id-Feld (SharedPreferences-Key `flurbocash_location_id_[kinoId]`) im Entwicklermodus-Bereich. Dateien: einstellungen_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 281: EcTerminalErgebnis-Modell (tid + 6 Kartenfelder in Cent). In Schritt 2: _baueEcTerminals() baut pro Beleg ein EcTerminalErgebnis aus _ecBelegLabels[i] (TID) und _zahlungsartZeilen[i] (Kartenbeträge); wird in _weiterZuSchritt3() als ecTerminals übergeben. TagesabschlussSchritt3Argumente um optionales ecTerminals-Feld erweitert. _zeigeFlurbocashJson() wertet ecTerminals aus statt des alten Einzelwerts terminalId + zahlungsartenAufschluesselung. Dateien: lib/models/ec_terminal_ergebnis.dart (neu), tagesabschluss_schritt2_seite.dart, tagesabschluss_schritt3_seite.dart.

- Run 280: Dev-Modus-Button „JSON anzeigen" auf der Übertrag-Seite (Schritt 3). Unterhalb des „Kassenabrechnung senden"-Buttons wird im Dev-Modus ein TextButton „JSON anzeigen" eingeblendet. Tap öffnet Dialog „Flurbocash JSON" mit scrollbarem Monospace-Bereich: Call 1 (ensure: location_id=0 TODO + logisches ISO-Datum via DatumsHelper) und Call 2 (settlements: cash_total in Cent, terminals-Array mit allen 6 Kartentypen; leer wenn keine EC-Belege). Dateien: tagesabschluss_schritt3_seite.dart.

- Run 279e: 1-Beleg-Modus: TID und Betrag nach Scan im Read-Modus (Text statt Eingabefelder); werden beim Tippen auf "Belegdaten bearbeiten" wieder editierbar. Zeile-Anzeige (_baueKartenartenZeileAnzeige): null-Felder werden rot dargestellt wenn _istZeileImplausibel — unleserliche Werte damit im Read-Modus sichtbar. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 279d: Drei Bugfixes in der Zahlungsarten-Darstellung. (1) nichtImScan-Default von false auf true — neue, ungescannte Kartenart-Zeilen starten jetzt unsichtbar; erst nach Scan mit _preFillZahlungsartenFromScan werden erkannte Karten auf false gesetzt und tauchen in der Tabelle auf. (2) _kartenartenNurAnzeige-Default von false auf true — neue Belege starten in Read-Modus statt Edit-Modus; verhindert, dass leere Kacheln sofort alle Karten als Eingabefelder zeigen. (3) "Fertig."-Gate entfernt — _kartenartenImplausibel-Methode vollständig gelöscht; "Fertig." ist immer tappbar. Außerdem: BetragCentEingabefeld im Sub-Kachel-Header (fälschlicherweise in 279c eingebaut) entfernt; Betrag bleibt immer reiner Text. Version 0.11.1 · r279d. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 279: Architektur-Refactor – per-Beleg-State für Zahlungsarten. Alle Zahlungsarten-Felder (_zahlungsartZeilen, _scanHatStattgefunden, _kartenartenGesamtAnzahl/_BetragCent, Controller, _metadatenAufgeklappt/_NurAnzeige, _kartenartenNurAnzeige) von global auf List<...> pro Beleg umgestellt. _ecZahlungsartenBelegIndex entfernt. _baueZahlungsartenTabelle, _baueMetadatenBlock, _baueKartenartenZeile/_Anzeige, _baueKartenartenEditButton bekommen belegIndex-Parameter. Persistenz: zahlungsartAnzahlWerte/BetragCentWerte als List<List<int?>> gespeichert; Rückwärtskompatibilität beim Laden (altes flaches Format → Beleg 0). build(): hatEcBelege prüft per-Beleg, 1-Beleg-Modus mit [0]-Index, 2+-Beleg-Modus mit [i]-Index. Jede Sub-Kachel zeigt jetzt die volle Kartendaten-Aufschlüsselung ihres eigenen Belegs. Version 0.11.1+279. Dateien: tagesabschluss_schritt2_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 278d: Sub-Kachel-Body vereinfacht. `_manuellBearbeitenAktivieren` setzt nur noch editModus=true (kein zahlungsartZeilen-Reset mehr). Body-Logik: aktiver Beleg zeigt Kartendaten-Tabelle; nicht-aktiver Beleg mit Daten zeigt Hinweis "Betrag gespeichert. Für Umsatz-Aufschlüsselung Beleg erneut scannen."; leerer Beleg zeigt "Noch kein Beleg – Kamera verwenden."; immer sichtbar: "Fertig." (editModus=true) oder "Manuell bearbeiten" (editModus=false). "Weiteren Beleg hinzufügen" → voller OutlinedButton. Version 0.11.0+278d. Dateien: tagesabschluss_schritt2_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart. Hinweis: Die Darstellung der Zahlungsarten-Aufschlüsselung pro Beleg ist NOCH UNVOLLSTÄNDIG — architektonische Änderung (per-Beleg-zahlungsartZeilen) in der nächsten Session geplant.

- Run 278c: Sub-Kachel TID-Bearbeitung. Neues Feld _ecBelegScanGescannt pro Beleg. Helper _subKachelTidUnleserlich(i). TID im Sub-Kachel-Header editierbar wenn editModus (TextField mit rotem Rahmen wenn unleserlich); Text mit roter Farbe wenn unleserlich und !editModus. Neue Belege starten mit editModus=false. Body gated auf _ecZahlungsartenBelegIndex==i. "Manuell bearbeiten" aktivierte TID-Editing. Version 0.11.0+278c. Dateien: tagesabschluss_schritt2_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 278b3: HTML-Musterbeleg um dritten Beleg ergänzt (Girocard-Anzahl + Gesamtbetrag unleserlich); alle Belege vertikal gestapelt (flex-direction: column). Dateien: .dev/kassenberichte dummies/html/ec_tagesabschluss_beleg.html.

- Run 278b2: HTML-Musterbeleg um zweiten Beleg mit unleserlicher Terminal-ID und unleserlichem Maestro-Betrag ergänzt. Dateien: .dev/kassenberichte dummies/html/ec_tagesabschluss_beleg.html.

- Run 278b: Mehrere EC-Kachel-Fixes. TID-Feld im Sub-Kachel-Body immer editierbar (TextField). "Weiteren Beleg hinzufügen" als TextButton vor dem 1/2+-Modus-if-else. "Fertig."-TextButton bold+underline+12px. Papierkorb in Sub-Kacheln immer sichtbar; Lösch-Bestätigung (AlertDialog). Beleganzahl im Hauptkachel-Titel zählt nur Belege mit Daten. HTML-Musterbeleg (Ingenico iCT250 Tagesabschluss) neu. Version 0.11.0+278b. Dateien: beleg_scan_gegenpruef_dialog.dart, tagesabschluss_schritt2_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart, .dev/kassenberichte dummies/html/ec_tagesabschluss_beleg.html.

- Run 278a: Prüf-Popup Inline-Edit entfernt (Korrektur erfolgt nach Übernehmen in der EC-Kachel). Rote Hervorhebung präzisiert: nur das konkret null-Feld wird rot (nicht gesamte Zeile). Hinweistext geändert auf "Rote Felder nach dem Übernehmen bitte korrigieren." Amber-Warnbox nur noch wenn keine unleserlichen Felder, aber Plausibilität scheitert. Doppelte Warnung in Zahlungsarten-Tabelle bereinigt (summePasstNicht nur wenn nicht betragMismatch). Scan-Metadaten-Block default eingeklappt, per Tap aufklappbar. Weiterer-Beleg-Button im 2+-Beleg-Modus nun über den Sub-Kacheln (klein, fontSize 12). Sub-Kachel-Body-Wiederholung (TID+Betrag) entfernt. Kartenart-Buttons flacher (minimumSize 24, shrinkWrap). Betrag→Titel-Sync: Änderung im Gesamt-Betrag-Feld der Zahlungsarten-Tabelle aktualisiert im 2+-Beleg-Modus den Sub-Kachel-Header-Betrag. Version 0.11.0+278a. Dateien: beleg_scan_gegenpruef_dialog.dart, tagesabschluss_schritt2_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 278: Prüf-Popup Inline-Korrektur. Unleserliche Felder (null / "unleserlich") werden rot hervorgehoben. Hinweistext "Rote Felder bitte korrigieren." erscheint oben und verschwindet nach vollständiger Korrektur. Tap auf rotes Feld → kompaktes Inline-Eingabefeld (roter Rahmen, gleiche Zeilenhöhe); Enter oder Fokus-Verlust übernimmt den Wert, Zeile kehrt zur normalen Darstellung zurück. Editierbare Felder: Terminal-ID, Gesamt-Betrag, Anzahl und Betrag je Zahlungsart. "Übernehmen" gibt korrigiertes BelegScanErgebnis zurück. Version 0.11.0+278. Dateien: beleg_scan_gegenpruef_dialog.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 277a5: Sub-Kachel-Header-Titel zeigt „In Arbeit …" während KI-Scan läuft (_scanBelegIndex == i). Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 277a4: EC-Kachel Betrag-Vergleich + Button-Rename. Bugfix: _baueZahlungsartenTabelle verglich Kartensumme bisher mit der Summe ALLER Belege (.fold); neues State-Feld _ecZahlungsartenBelegIndex merkt, welcher Beleg die Zahlungsarten gehören (wird in _starteEcBelegScan gesetzt, in _loescheKartenDaten auf 0 zurückgesetzt, in _speichereEntwurf/_ladeEntwurf persistiert). Vergleich jetzt: _ecBelegeCent[_ecZahlungsartenBelegIndex] statt fold-Summe; Warnung erscheint nur noch wenn ecGesamtCent > 0 (kein Falsch-Alarm bei leerem Beleg). Rename: Zahlungsarten-Button „Belegdaten manuell bearbeiten" → „Umsätze manuell bearbeiten"; Metadaten-Button → „Metadaten manuell bearbeiten". Version 0.10.1+277a4. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 277a3: EC-Kachel Sub-Kacheln — Fixes & UX Runde 2. Leere Sub-Kachel zeigt nur Hinweistext (kein Zahlungsarten/Metadaten-Datenüberlauf). Kamera-Icon in Sub-Kachel-Header: Kino-Rot wenn leer, ausgegraut wenn Daten vorhanden. „manuell eingeben"-Link im äußeren Kachel-Header während Scan ausgeblendet (!_scanLaeuft). Sub-Kachel Edit-Modus entfernt — TID/Betrag immer als Text (Read-Darstellung). Neue Sub-Kachel erscheint oben (umgekehrte Render-Reihenfolge). Beim Hinzufügen eines Belegs werden alle Sub-Kacheln geschlossen. Metadaten-Block: „manuell bearbeiten"-Link jetzt in Titelzeile rechts neben „Scan-Metadaten". Umbenennung: „manuell editieren" → „Belegdaten manuell bearbeiten" (Zahlungsarten + Metadaten). _baueMetadatenEditButton() entfernt (inlined). Kamera-Bug nach Reload: kein Code-Fehler gefunden; wahrscheinlich UX (1-Beleg-Modus: Kamera liegt im Body, erst nach Aufklappen sichtbar). Version 0.10.1+277a3. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 277a2: EC-Kachel Sub-Kacheln — Fixes + Zahlungsarten + UX. Kamera-Icon in Sub-Kachel-Header: gefüllt (Icons.camera_alt) + Kino-Rot statt Outline; Camera-Button aus Edit-Body entfernt (nur noch im Header). Papierkorb in Sub-Kachel-Header erst sichtbar wenn Beleg Daten hat (_ecBelegeCent[i]>0 || _ecBelegLabels[i].isNotEmpty). Erster Beleg startet nun korrekt im Read-Modus wenn bereits Daten vorhanden: _ecBelegHinzufuegen setzt vorherigen Beleg auf false wenn Daten vorhanden. TextButton umbenannt: „Felder bearbeiten" → „Beleg-Daten manuell bearbeiten". Neuer „Fertig."-Button im Edit-Body (schaltet in Read-Modus zurück, sichtbar wenn Beleg Daten hat). In jeder Sub-Kachel (Read + Edit Body) werden Zahlungsarten (_baueZahlungsartenTabelle) und Scan-Metadaten (_baueMetadatenBlock) angezeigt. Äußerer Kacheltitel: „x Beleg(e) / xx,xx €" statt nur Summe. „Weiteren Beleg hinzufügen" auch unterhalb zugeklappter EC-Kachel sichtbar (klappt Kachel auf + fügt Beleg hinzu). Version 0.10.1+277a2. Dateien: tagesabschluss_schritt2_seite.dart, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 277a: EC-Kachel Redesign — Modus-Logik 1-Beleg vs. 2+-Belege. 1-Beleg: flaches Layout (TID-Feld + Betrag + Metadaten + Zahlungsarten direkt in der Kachel, keine Sub-Kachel). 2+-Belege: Sub-Kacheln mit neuem Edit/Read-Modus (_ecUnterkachelEditModus): Read-Body zeigt TID + Betrag als Text + „Felder bearbeiten"; Edit-Body zeigt kleinen Kamera-Button + TID-TextField + Betrag-Input. Default bei Hinzufügen: Edit-Modus (true); nach Scan: Read-Modus (false). Papierkorb im äußeren Header: `if (hatEcBelege)` statt `if (_scanHatStattgefunden && aufgeklappt)` → ruft _loescheKartenDaten auf; Papierkorb in Sub-Kacheln immer sichtbar (length>1 Check entfällt). Gesamtsumme im äußeren Header: `if (hatEcBelege)` auch im aufgeklappten Zustand. _baueZahlungsartenTabelle nur noch im 1-Beleg-Modus. Version 0.10.1+277a. Dateien: tagesabschluss_schritt2_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 277: EC-Kachel Unterkacheln pro Beleg. Jeder EC-Beleg wird als klappbare Sub-Card (Unterkachel) dargestellt mit eigenem Header (TID-Label + Betrag + Scan-Button + Löschen-Button + Auf-/Zuklapp-Pfeil); Sub-Card-Body enthält Terminal-ID- und Betrag-Felder. „Weiteren Beleg hinzufügen" klappt letzte Sub-Card zu und fügt neue aufgeklappt an. Äußerer Kamera-Button nur noch sichtbar wenn noch kein Beleg existiert. Scan schreibt in korrekten Beleg-Index statt immer in Index 0. `_scanLaeuft` durch `_scanBelegIndex: int?` + Getter ersetzt; Spinner pro Sub-Card-Button nur beim aktiven Scan. Validierung klappt Sub-Card 0 vor Pflichtfeldprüfung auf. Version 0.10.0+277. Dateien: tagesabschluss_schritt2_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 276: EC-Kachel: Gesamtsumme rechts statt Kamera-Icon wenn zugeklappt + Belege vorhanden; Kamera-Button bleibt bei aufgeklappter Kachel oder ohne Belege sichtbar; „Weiteren Beleg hinzufügen"-TextButton erscheint erst nach dem ersten erfassten Beleg. Version 0.9.13+276. Dateien: tagesabschluss_schritt2_seite.dart, pubspec.yaml, startmenue_seite.dart, kinoauswahl_seite.dart.

- Run 275a10: „in Arbeit …"-Text im EC-Kachel-Header während Scan (_scanLaeuft); „unbekannt" im Prüf-Popup orange + kursiv; fester Hinweistext statt KI-Freitext wenn hinweis != null: „Die Kartenbeträge summieren sich nicht zum Gesamtbetrag – bitte nach Übernehmen prüfen."; _istZeileImplausibel: nach Scan sollen sichtbare leere Zeilen als implausibel gelten (_scanHatStattgefunden && !nichtImScan && beide null → true). Dateien: beleg_scan_gegenpruef_dialog.dart, tagesabschluss_schritt2_seite.dart.

- Run 275a6: Prüf-Popup als StatefulWidget mit Scroll-Indikator (↓-Pfeil wenn Inhalt scrollbar); zeile.reset() vor _preFillZahlungsartenFromScan (Bug: alte Werte blieben nach neuem Scan); _istZeileImplausibel vereinfacht (nichtPlausibel-Flag entfernt, nur noch strukturelle Prüfung: ein Feld leer, Anzahl = 0); Warnungen in Kartenarten-Tabelle werden unterdrückt wenn eine Zeile inkonsistent ist (irgendEineZeileInkonsistent); alle Warnfarben auf orange vereinheitlicht. Dateien: beleg_scan_gegenpruef_dialog.dart, tagesabschluss_schritt2_seite.dart.

- Run 275a5: Prüf-Popup vereinfacht (Edit-Modus entfernt, rein Anzeige, „Übernehmen" immer aktiv) + Tipp-Text mit fettem „Übernehmen"; EC-Kachel startet zugeklappt, öffnet nach Scan automatisch; Bug-Fix _istZeileImplausibel (leere Zeile = erlaubt); kein Datenlöschen beim Foto-Tippen mehr; „manuell eingeben"-Link aus Expanded herausgelöst, rechtsbündig vor Foto-Icon; Warnungen in Kartenarten-Tabelle erst nach Fokus-Verlust (FocusNodes in _ZahlungsartZeile). Version 0.9.12 · r275a5. Dateien: beleg_scan_gegenpruef_dialog.dart, tagesabschluss_schritt2_seite.dart.

- Run 275: EC-Kachel Layout & Terminal-ID. Scan-Metadaten-Block (Datum/Uhrzeit/Beleg-Nr.) kompakter (Zeilenabstand 4→2, Containerpadding 10→8); redundante read-only "Terminal-ID"-Zeile im Metadaten-Block entfernt; Kartenarten-Tabelle luftiger (Zeilenabstand 6→14, Eingabefeld-Innenabstand vertikal 5→10, Divider vor "Gesamt Karten" 10→18). EC-Beleg-Feld "Bezeichnung (optional)" → "Terminal-ID" umbenannt und zu Pflichtfeld für den ersten EC-Beleg (analog zum Betrags-Pflichtfeld); leeres Feld zeigt "Terminal-ID eingeben"; _pflichtfeldFehlertext um optionalen fehlertext-Parameter erweitert; bei BelegScan wird die erkannte Terminal-ID jetzt automatisch in dieses Feld eingetragen (vorher nur im read-only Metadaten-Block angezeigt); "Scan-Daten löschen" leert das Feld wieder mit. Version 0.9.12 · r275.

- Run 274f4: Kartenarten-Tabelle zeigt nach einem Scan nur noch die auf dem Beleg gefundenen Kartenarten; nicht gefundene werden ausgeblendet statt leer angezeigt; neues Feld _ZahlungsartZeile.nichtImScan; "+ Kartenart"-Buttonreihe unterhalb der Tabelle erlaubt das Wieder-Einblenden einzelner ausgeblendeter Kartenarten zum manuellen Nachtragen; vor einem Scan weiterhin alle Kartenarten sichtbar; r274f4.

- Run 274l: TODO.md grundlegend überarbeitet (Roadmap mit Run-Nummern 275–292, neue Blöcke „Blockiert – wartet auf IT" und „Flurbocash API-Integration"); neue Doku .dev/KI stuff/ (EXTERNAL_API_Schauburg.md/_de.md, kassenabrechnung-flurbocash-integration.html); .dev/kassenabrechnung-konzept-belegscan.html nach .dev/verkauf/ verschoben; config/kartenzahlungsanbieter.txt befüllt (girocard, lastschrift, mastercard, visa, maestro, vpay); config/terminal_ids.json um Hinweis-Kommentar ergänzt; generierte Plugin-Dateien (ios/macos/windows) durch flutter pub get aktualisiert; r274l.

- Run 274k: config/terminal_ids.json befüllt – Terminal-IDs je Standort (AT, SB, CO, GO je 1, BT 2), Werte als Platzhalter "XXXX" bis Yannik die echten TIDs liefert (TODO: „Registrierte TIDs pro Standort"); r274k.

- Run 274fc: Architektur-Refactor Zahlungsarten-Tabelle: 6 Parallel-Arrays (_zahlungsartenListe, _zahlungsartAnzahlController, _zahlungsartBetragController, _zahlungsartAnzahlWerte, _zahlungsartBetragCentWerte, _zahlungsartNichtPlausibel) ersetzt durch eine Liste von _ZahlungsartZeile-Objekten (name, anzahlController, betragController, anzahlWert, betragCentWert, nichtPlausibel, jeweils mit dispose()/reset()); betrifft initState, dispose, _ladeEntwurf, _speichereEntwurf, alle Reset-Stellen, _sortiereZahlungsartenNachBeleg, _preFillZahlungsartenFromScan, _baueZahlungsartenListe, _baueKartenartenZeile, _baueZahlungsartenTabelle; keine Verhaltens- oder UI-Änderung; r274fc.

- Run 274fb: Substring-Matching für Kartenanbieter-Erkennung: neue Hilfsmethode _matchKartenart prüft in beide Richtungen (belegArt.contains(configName) || configName.contains(belegArt), case-insensitiv); ersetzt exakten Stringvergleich in _sortiereZahlungsartenNachBeleg und _preFillZahlungsartenFromScan (inkl. Original-Scan-Prüfung); r274fb.

- Run 274f: Nach Scan-Bestätigung ("Übernehmen"): Kartenarten-Liste wird nach Beleg-Reihenfolge umsortiert – vom AI erkannte Zahlungsarten stehen oben (in Reihenfolge wie auf dem Beleg), alle anderen dahinter; neue Methode _sortiereZahlungsartenNachBeleg; alle 6 Parallel-Arrays werden synchron umsortiert; r274f.

- Run 274h: EC-Kachel-Header: Kamera-Button rund + rot (AppFarben.appBarRot, weißes Icon); Papierkorb-Icon rot; Papierkorb nur sichtbar wenn Kachel aufgeklappt; zugeklappter Titel zeigt Gesamtsumme aller EC-Belege in Rot; r274h.

- Run 274e4: Eingabefelder mit sichtbarem OutlineInputBorder (statt InputBorder.none); Felder Uhrzeit, Beleg-Nr. von/bis erscheinen nicht mehr im Manuell-Modus (kein zeigeInManuell); _hatUnleserlicheFelder nur noch terminalId, gesamtBetragCent, zahlungsarten.betragCent; nochmal-Button: Kamera-Icon jetzt hinter dem Text; r274e4.

- Run 274e3: CLAUDE.md: kinoauswahl_seite.dart in Versionierung ergänzt; beide Versionsstrings r274e3; Zeilenumbruch nach "dunkel" im Kein-Beleg-Dialog entfernt; Dialog: "Bestätigen" → "Übernehmen"; gelbe Box zeigt immer wenn Felder fehlen (auch ohne AI-hinweis); Null-Felder orange statt grau (Terminal-ID, Zahlungsart-Beträge, Gesamt); Betrag-Eingabe in Cent (int, kein Euro-Format); Hint-Text "z. B. 1490"; keyboard-aware maxHeight in ConstrainedBox (scrollt zu fokussiertem Feld); _parseCentEingabe statt _parseEuroToCent; r274e3.

- Run 274e2: Snackbar-Filter in _starteEcBelegScan: technischer Text wird nie angezeigt; Netz-Fehler bleibt spezifisch, alle anderen Scan-Fehler → "Scan nicht lesbar – bitte erneut versuchen (z.B. unscharf, zu dunkel oder kein Beleg)"; Kein-Terminal-Beleg-Dialog: "zu dunkel" ergänzt; Dialog-TextFields: inline statt ganzzeilig (UnderlineInputBorder, InputBorder.none, scrollPadding 200), Betrag-Felder in Zahlungsart- und Gesamt-Zeile jetzt direkt in der Spalte statt darunter; r274e2.

- Run 274e: BelegScanService: Prompt-Einstieg mit explizitem JSON-only-Gebot; hinweis nur noch bei rechnerischer Summen-Abweichung (keine visuellen Einschätzungen); parse-Fehler: Nicht-JSON-Antwort (kein '{'-Start) → sprechende BelegScanException statt technischer FormatException; alle anderen Catch-Zweige auf nutzerfreundlichen Text vereinheitlicht; r274e.

- Run 274d: Kein-Terminal-Beleg-Dialog zeigt fixen Text statt AI-hinweis; AI-Prompt: hinweis nur bei echter Summen-Abweichung oder abgeschnittenem Beleg (max. 8 Wörter, keine Zahlen, kein Loben was stimmt); Terminal-ID immer im Prüf-Popup sichtbar (erforderlich:true), bei leer → "nicht vorhanden/unleserlich" als Fallback-String (auch im JSON); r274d.

- Run 274c: Kein-Terminal-Beleg-Erkennung: AI-Prompt erweitert mit kein_terminal_beleg-Flag; bei positivem Flag einfacher Dialog ("Kein Terminal-Beleg") mit "nochmal"-Button statt Vollprüfung; BelegScanErgebnis.keinTerminalBeleg-Feld; null-Felder im Prüf-Popup werden ausgeblendet (statt "unleserlich"); gleiches Verhalten in _baueMetadatenInfoZeile (EC-Kachel); ApiUploadService: null-Metadaten als "nicht vorhanden" übermitteln wenn Scan stattgefunden; r274c.

- Run 274b: Löschen-Button löscht jetzt auch EC-Betrag[0] (ergibt Sinn nach Fehlscan); Dialog-Button "Korrigieren" umbenannt in "nochmal" mit Kamera-Icon.

- Run 274a: Persistenz von Kartenarten-Tabelle und Scan-Metadaten in _speichereEntwurf/_ladeEntwurf (Hive); initState: zahlungsarten-Laden vor _ladeEntwurf gekettet; Anzahl-Summe in Gesamt-Zeile der Kartenarten-Tabelle; Löschen-Button (delete_sweep) im EC-Kachel-Header; AppBar-Clear + Dev-Alles-leeren setzen Kartenarten zurück; Scroll-Indikator (Pfeil nach unten) wenn EC-Kachel über Viewport hinausragt; Dialog: „Korrigieren" löst neue Kamera-Aufnahme aus (do-while-Loop in _starteEcBelegScan); Gelbe Box nur bei unleserlichen Feldern oder Betrag-Fehler; „Manuell eintragen (optional)" TextButton klappt Eingabefelder auf; r274a.

- Run 274: ZahlungsartenConfigService + config/zahlungsarten.txt (girocard, SEPA Lastschrift, Mastercard, Visa); BelegScanGegenpruefDialog: Buttons auf „Korrigieren" (kachelOeffnen:true) + „Bestätigen" (kachelOeffnen:false), ✕ im Header, BelegScanDialogErgebnis als Rückgabewert; TagesabschlussFinal: 5 neue nullable Felder (terminalId, belegNrVon, belegNrBis, ecUhrzeit, zahlungsartenAufschluesselung) mit toJson/fromJson; Chain Finalisieren­Eingabe→Usecase→Schritt3Argumente aktualisiert; EC-Belege-Kachel in Schritt2 kollapsierbar mit Scan-Metadaten-Block (3a) und Kartenarten-Tabelle (3b); _starteEcBelegScan füllt EC-Gesamtbetrag, Metadata und Kartenarten-Felder; ApiUploadService exportiert neue Felder; Version 0.9.11 · r274.

- Run 273: Gegenprüf-Popup nach erfolgreichem BelegScan; BelegScanGegenpruefDialog zeigt Terminal-ID, Datum, Uhrzeit, Beleg-Nr. von/bis, Zahlungsarten mit Betrag, Gesamtbetrag; null-Felder (abrechnungsrelevant) als „unleserlich" mit Pflicht-Eingabefeld; Bestätigen-Button deaktiviert bis alle Pflichtfelder ausgefüllt; Plausibilitäts-Warnung (rot) bei istPlausibel==false; KI-Hinweis-Box (gelb) bei hinweis!=null; ZahlungsartErgebnis.betragCent auf int? umgestellt.

- Run 272: BelegScanService auf Cloudflare Worker als Proxy umgestellt (kartenzahlungsbelegscan.pacodemant.workers.dev); x-api-key- und anthropic-version-Header entfernt; SharedPreferences-API-Key-Prüfung entfernt; Version auf 0.9.10.

- Run 271: Kamera-Button in der EC-Belege-Kachel von Schritt 2; ruft BelegScanService.scan() auf und gibt Ergebnis per debugPrint aus; _scanLaeuft-State mit CircularProgressIndicator und deaktiviertem Button während des Scans; Version auf 0.9.9.

