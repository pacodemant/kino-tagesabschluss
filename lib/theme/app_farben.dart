import 'package:flutter/material.dart';

class AppFarben {
  const AppFarben._();
  static const Color appBarRot = Color(0xFF5C0A0A);
  static const Color seitenHintergrund = Color(0xFFFCE7E7);

  // Fokus-Füllfarbe für Eingabefelder (Splash-Ladebalken-Orange).
  static const Color fokusFarbe = Color(0xFFFF9800);

  // Differenz-Ampel (Verlauf)
  static const Color differenzPositiv = Color(0xFF388E3C);       // green.shade700
  static const Color differenzNegativ = Color(0xFFD32F2F);       // red.shade700

  // "Heute"-Badge (Verlauf)
  static const Color heuteBadgeHintergrund = Color(0xFFE53935);  // red.shade600

  // DEV-Tools-Panel-Hintergrund (Schritt 1 + Schritt 2)
  static const Color devToolsHintergrund = Color(0xFFFFF8E1);

  // Validierungs-Hintergründe (Eingabefelder)
  static const Color validierungFehlerHintergrund = Color(0xFFFFEBEE);  // red.shade50
  static const Color validierungErfolgsHintergrund = Color(0xFFF1F8E9); // green.shade50

  // Stückelung Erfolgs-Rahmen
  static const Color stueckelungErfolgsRand = Color(0xFF81C784); // green.shade300

  // Subtiler Text
  static const Color subtilerText = Color(0x8A000000);           // black54

  // 50%-Rot für nachrangige Buttons (Startseite: Einstellungen/Verlauf).
  static const Color appBarRotGedaempft = Color(0x805C0A0A);

  // Gruppierung zusammengehöriger Einstellungen (Admin-Bereich),
  // abwechselnde Bänder ähnlich Tabellenkalkulations-Zeilenfarben.
  static const Color gruppierungBandA = Colors.white;
  static const Color gruppierungBandB = Color(0xFFF6EFEF);

  // Kennzeichnet Dev-Modus-Bypässe (z. B. Weiter-Buttons, die normalerweise
  // eine echte Aktion voraussetzen, im Dev-Modus aber ohne diese
  // freigeschaltet sind) — bewusst eine Farbe, die sonst nirgends
  // vorkommt, damit ein Bypass immer eindeutig erkennbar ist.
  static const Color devBypassLila = Color(0xFF8E24AA); // purple.shade600

  static final ButtonStyle footerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppFarben.fokusFarbe,
    foregroundColor: AppFarben.appBarRot,
  );

  static final ButtonStyle devBypassButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppFarben.devBypassLila,
    foregroundColor: Colors.white,
  );

  static const BoxDecoration footerDecoration = BoxDecoration(
    color: Colors.black87,
    border: Border(top: BorderSide(color: Color(0x52FFFFFF))),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Color(0x4D000000),
        offset: Offset(0, -2),
        blurRadius: 12,
      ),
    ],
  );
}
