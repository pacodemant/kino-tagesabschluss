import 'package:flutter/material.dart';

class AppFarben {
  const AppFarben._();
  static const Color appBarRot = Color(0xFF7B0000);
  static const Color seitenHintergrund = Color(0xFFFFF0EE);

  static final ButtonStyle footerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppFarben.appBarRot,
  );
}
