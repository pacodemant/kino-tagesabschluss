# CHANGELOG

Alle relevanten Änderungen am Projekt werden hier kurz dokumentiert.

## Unreleased
- Prompt-System auf standardisierte Struktur umgestellt (`AGENTS.md`, `.dev/CONTRIBUTING.md`, `.dev/run_template.md`, `.dev/run_counter.txt`, `CHANGELOG.md`).
- Run 63: Scroll-/Abschnittsnavigation in Schritt 1 vereinheitlicht und Down-FAB-Scrollpfad über den bestehenden Scroll-Helper robuster gebündelt.
- Run 64: Regressionsfix in Schritt 1 für Down-FAB-Sichtbarkeit bei Scroll-Metrikänderungen, Fokusverhalten und Rollensummenanzeige mit Cent.
- Run 65: Keyboard-/Footer-Übergang in Schritt 1 geglättet, um kurzzeitiges Absacken bei Fokuswechseln zu vermeiden.
- Run 66: Ursache für Keyboard-/Footer-Springen in Schritt 1 behoben durch Entfernen des globalen Tap-Unfocus im Body und stabileres Keyboard-Dismiss nur per Drag.
- Run 67: Doppelte Fokus-/Keyboard-Anstöße in Schritt 1 reduziert (zusätzliches Feld-`requestFocus` beim Tap und iOS-`TextInput.show` nach `requestFocus` entfernt).
- Run 69: Keyboard-Layout-State in Schritt 1 lokal entkoppelt (didChangeMetrics als führende Inset-Quelle, Footer-/Bottom-Layout über lokalen Listenable-State stabilisiert, Fokus-Rebuilds für Footer reduziert).
- Run 70: Scroll-Ensure bei Fokuswechsel in Schritt 1 kontrolliert entschärft (kurze lokale Verzögerung mit Keyboard-Inset-/Fokus-Stabilitätscheck), um konkurrierende Scrolls während Keyboard-Übergängen zu reduzieren.
