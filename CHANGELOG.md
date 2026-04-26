# CHANGELOG

Alle relevanten Änderungen am Projekt werden hier kurz dokumentiert.

## Unreleased
- Prompt-System auf standardisierte Struktur umgestellt (`AGENTS.md`, `.dev/CONTRIBUTING.md`, `.dev/run_template.md`, `.dev/run_counter.txt`, `CHANGELOG.md`).
- Run 98: Zufallswertebereiche in `_autoFillDev()` von Schritt 2 angepasst – Kino/Bistro SOLL 200–1.000 €, Differenz Anfangsbestand -10–+10 €.
- Run 97: Down-FAB in Schritt 1 fest links positioniert (left: 12) – Center-Wrapper und right: 0 entfernt, sodass Eingabefelder nicht mehr verdeckt werden.
- Run 96: (revertiert) ListView-Padding erhöhen damit fokussierte Felder nicht hinter Down-FAB verschwinden.
- Run 95: Rote Hervorhebung bleibt bis Wert eingegeben wurde – bei „Korrigieren" wird `_rotHervorgehoben` nicht geleert; Hervorhebung verschwindet pro Feld sobald Mitarbeiter einen Wert einträgt; bei „Bestätigen" wird Set wie bisher komplett geleert.
- Run 94: Startanweisungen aus claude_code_startprompt.md in CLAUDE.md integriert (Abschnitt „Automatischer Chat-Start"); startprompt-Datei entfernt.
- Run 93: Rote Hervorhebung leerer Felder bei Eingabeprüfung – GanzzahlEingabefeld und BetragCentEingabefeld erhalten istHervorgehoben-Parameter; rotHervorgehoben-Set durch Orchestrierungsschicht weitergereicht; Prüflogik setzt/löscht Hervorhebung vor/nach Dialog.
- Run 92: CLAUDE.md um Bericht-Formatierungsregeln ergaenzt (Ueberschrift und Codeblock-Pflicht fuer Abschlussberichte).
- Run 91: Sequenzielle Eingabeprüfung beim Übergang Schritt 1 → 2 eingebaut – Dialog fuer leere Scheine, lose Münzen und fehlende Kartenzahlung; Fokus springt bei Korrigieren auf erstes leeres Feld.
- Run 90: Projektdokumentation auf Claude Code umgestellt – Snapshot-Regel in CLAUDE.md ergaenzt, `.dev/claude_code_startprompt.md` neu erstellt.
- Run 89: Obsoleten Schritt-1-Scroll-Ensure-Code vollstaendig entfernt; nativer iOS-Fokus-Scroll bleibt aktiv, Down-FAB-/Scroll-Metrik-Helfer bleiben bestehen.
- Run 88: Fokuszustand in `GanzzahlEingabefeld` und `BetragCentEingabefeld` visuell hervorgehoben mit schwarzem Hintergrund, weißer fetter Schrift und weißem Cursor.
- Run 87: Eigenen Schritt-1-Scroll-Ensure per Diagnose-Flag deaktiviert, damit natives iOS-Scrollverhalten isoliert getestet werden kann.
- Run 86: `triggerEnsureBeiEingabe` aus dem Schritt-1-`onChanged`-Pfad entfernt, damit Eingabefelder nach dem Fokus-Scroll beim Tippen stabil stehen bleiben.
- Run 85: Schritt-2-Footer und Tastaturverhalten an Schritt 1 angeglichen – `resizeToAvoidBottomInset` auf `true`, `keyboardDismissBehavior` auf `onDrag`, `SafeArea` um `ListView` entfernt, `footerBottomInset` auf `viewPadding.bottom` umgestellt; Down-FAB in Schritt 1 schwarz mit weisser Schrift.
- Run 84: keyboardInset in `_ensureAktivesFeldSichtbar()` und `_triggerEnsureBeiEingabe()` korrigiert – statt hartcodierter `0` wird `MediaQuery.of(context).viewInsets.bottom` uebergeben; `triggerEnsureBeiEingabe()` ist damit kein toter Code mehr.
- Run 83: Footer-Flackern in Schritt 1 behoben – tastaturOffen wird nicht mehr ueber didChangeMetrics + setState gesetzt, sondern direkt im build-Kontext aus mediaQuery.viewInsets.bottom > 0 abgeleitet; _tastaturOffen, _tastaturSchliessGeneration und didChangeMetrics vollstaendig entfernt.
- Run 82: iOS-Keyboard-Swap-Bug in `didChangeMetrics` mit Generation Counter geloest; jeder `inset > 0`-Aufruf inkrementiert `_tastaturSchliessGeneration` und macht laufende Schliessen-Delays ungueltig, die Fokus-Bedingung aus Run 81 wurde vollstaendig entfernt.
- Run 81: iOS-Keyboard-Swap-Bug in `didChangeMetrics` weiter abgesichert, Delay auf 200ms erhoeht und den Fokus-Zustand als zweite Bedingung ergaenzt, damit `tastaturOffen` bei Same-Type-Swap nicht faelschlich auf false faellt.
- Run 80: Schritt-1-Keyboard-Swap auf iOS beim Fokuswechsel zwischen gleichen Keyboard-Typen in `didChangeMetrics` mit 120ms Delay statt Post-Frame-Check abgefangen, damit der Footer nicht kurz wegfaellt.
- Run 79: Schritt-1-Footer beim Fokuswechsel stabilisiert, indem `tastaturOffen` wieder ueber `didChangeMetrics` mit kurzem Post-Frame-Check gegen iOS-Null-Insets gefuehrt wird.
- Run 78: Schritt-1-Footer-Hoehe an den nativen Keyboard-Inset angepasst und Footer-Uebergaenge beim Fokuswechsel lokal ueber `AnimatedSize` geglaettet.
- Run 77: Schritt-1-Footer aus `Scaffold.bottomNavigationBar` in eine `Column` im Body verlagert, damit er mit dem verkleinerten Inhalt oberhalb der Tastatur sichtbar und antippbar bleibt.
- Run 76: Manuellen Keyboard-Inset-Mechanismus in Schritt 1 entfernt und `resizeToAvoidBottomInset` wieder auf das native Scaffold-Verhalten mit statischem Footer umgestellt.
- Run 75: Schritt-1-Footer-Tween mit stabilem `ValueKey` versehen, damit Rebuilds die laufende Footer-Animation nicht neu starten.
- Run 74: Schritt-1-Footer im `bottomNavigationBar` in ein `Material` mit eigener Ebene gewrappt, damit er stabil ueber dem Keyboard-Overlay bleibt.
- Run 73: Doppelte Footer-Animation in Schritt 1 entfernt, sodass der Footer nur noch ueber den bestehenden `TweenAnimationBuilder` fuer Safe-Area und Padding uebergaenge animiert.
- Run 72: Bottom-Layout in Schritt 1 vereinheitlicht, Footer allein auf `Scaffold.bottomNavigationBar` belassen und konkurrierende Footer-/Inset-Logik aus dem Body sowie dem Down-FAB-Pfad entfernt.
- Run 63: Scroll-/Abschnittsnavigation in Schritt 1 vereinheitlicht und Down-FAB-Scrollpfad über den bestehenden Scroll-Helper robuster gebündelt.
- Run 64: Regressionsfix in Schritt 1 für Down-FAB-Sichtbarkeit bei Scroll-Metrikänderungen, Fokusverhalten und Rollensummenanzeige mit Cent.
- Run 65: Keyboard-/Footer-Übergang in Schritt 1 geglättet, um kurzzeitiges Absacken bei Fokuswechseln zu vermeiden.
- Run 66: Ursache für Keyboard-/Footer-Springen in Schritt 1 behoben durch Entfernen des globalen Tap-Unfocus im Body und stabileres Keyboard-Dismiss nur per Drag.
- Run 67: Doppelte Fokus-/Keyboard-Anstöße in Schritt 1 reduziert (zusätzliches Feld-`requestFocus` beim Tap und iOS-`TextInput.show` nach `requestFocus` entfernt).
- Run 69: Keyboard-Layout-State in Schritt 1 lokal entkoppelt (didChangeMetrics als führende Inset-Quelle, Footer-/Bottom-Layout über lokalen Listenable-State stabilisiert, Fokus-Rebuilds für Footer reduziert).
- Run 70: Scroll-Ensure bei Fokuswechsel in Schritt 1 kontrolliert entschärft (kurze lokale Verzögerung mit Keyboard-Inset-/Fokus-Stabilitätscheck), um konkurrierende Scrolls während Keyboard-Übergängen zu reduzieren.
- Run 71: Schritt-1-Footer aus dem Stack-/Scroll-Layoutpfad auf `Scaffold.bottomNavigationBar` verlagert, damit er stabiler oberhalb der Tastatur bleibt und nicht mehr im Content-Stack mitläuft.
