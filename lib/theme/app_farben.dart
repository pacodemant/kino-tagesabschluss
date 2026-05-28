import 'package:flutter/material.dart';

class AppFarben {
  const AppFarben._();
  static const Color appBarRot = Color(0xFF5C0A0A);
  static const Color seitenHintergrund = Color(0xFFFCE7E7);

  // Differenz-Ampel (Verlauf)
  static const Color differenzPositiv = Color(0xFF388E3C);       // green.shade700
  static const Color differenzNegativ = Color(0xFFD32F2F);       // red.shade700

  // "Heute"-Badge (Verlauf)
  static const Color heuteBadgeHintergrund = Color(0xFFE53935);  // red.shade600

  // Validierungs-Hintergründe (Eingabefelder)
  static const Color validierungFehlerHintergrund = Color(0xFFFFEBEE);  // red.shade50
  static const Color validierungErfolgsHintergrund = Color(0xFFF1F8E9); // green.shade50

  // Stückelung Erfolgs-Rahmen
  static const Color stueckelungErfolgsRand = Color(0xFF81C784); // green.shade300

  // Subtiler Text
  static const Color subtilerText = Color(0x8A000000);           // black54

  static final ButtonStyle footerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppFarben.appBarRot,
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
