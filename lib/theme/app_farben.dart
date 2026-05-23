import 'package:flutter/material.dart';

class AppFarben {
  const AppFarben._();
  static const Color appBarRot = Color(0xFF5C0A0A);
  static const Color seitenHintergrund = Color(0xFFFCE7E7);

  static final ButtonStyle footerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppFarben.appBarRot,
  );
}
