import 'package:flutter/material.dart';

// Zweck: Gemeinsame äußere Hülle für die scrollbaren Body-Bereiche von
// Schritt 1 und Schritt 2 (Theme-Override für dichte Eingabefelder,
// Scroll-Metrik-Benachrichtigung, Stack mit Scroll-nach-unten-FAB). War
// bisher 1:1 dupliziert zwischen schritt1_body_content.dart und
// schritt2_body_content.dart — nur der eigentliche scrollbare Inhalt
// (CustomScrollView mit Slivern vs. ListView) unterscheidet sich zu Recht
// und bleibt daher bei den jeweiligen BodyContent-Widgets.
class TagesabschlussBodyWrapper extends StatelessWidget {
  const TagesabschlussBodyWrapper({
    super.key,
    required this.scrollable,
    required this.downButtonSichtbar,
    required this.downButtonHeroTag,
    required this.scrolleNachUnten,
    required this.beiScrollMetrikAenderung,
  });

  final Widget scrollable;
  final bool downButtonSichtbar;
  final String downButtonHeroTag;
  final VoidCallback scrolleNachUnten;
  final VoidCallback beiScrollMetrikAenderung;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ),
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (ScrollMetricsNotification notification) {
              beiScrollMetrikAenderung();
              return false;
            },
            child: scrollable,
          ),
        ),
        if (downButtonSichtbar)
          Positioned(
            left: 12,
            bottom: 12,
            child: SizedBox(
              width: 36,
              height: 36,
              child: FloatingActionButton(
                heroTag: downButtonHeroTag,
                mini: true,
                elevation: 2,
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                onPressed: scrolleNachUnten,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ),
          ),
      ],
    );
  }
}
