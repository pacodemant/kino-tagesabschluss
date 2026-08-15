import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Einheitlicher Hinweis-Snackbar (oranger Hintergrund, roter Text) — seit
/// Run 372a projektweite Konvention für alle Snackbars, auch
/// Fehlermeldungen (Sichtbarkeit geht vor der bisherigen Konvention
/// "Orange nur für den glatten Ablauf").
void zeigeHinweisSnackBar(
  BuildContext context,
  String text, {
  Duration? duration,
  bool vorherigeLoeschen = false,
}) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  if (vorherigeLoeschen) {
    messenger.clearSnackBars();
  }
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: AppFarben.fokusFarbe,
      content: Text(text, style: const TextStyle(color: AppFarben.appBarRot)),
      duration: duration ?? const Duration(seconds: 4),
    ),
  );
}
