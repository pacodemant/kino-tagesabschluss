import 'package:flutter/material.dart';

// Zweck: Kapselt den aeusseren Body-Aufbau von Schritt 2 (Theme/Scroll-
// Benachrichtigung/ListView/Down-Button), analog zu schritt1_body_content.dart.
// Abschnitte, die noch nicht in eigene Sections ausgelagert sind, werden als
// fertige Widgets/Widget-Listen durchgereicht und in kommenden Sub-Runs der
// build()-Zerlegungs-Serie schrittweise ersetzt.
class Schritt2BodyContent extends StatelessWidget {
  const Schritt2BodyContent({
    super.key,
    required this.scrollController,
    required this.devToolsBereich,
    required this.kopfSection,
    required this.personalgetraenkeSection,
    required this.differenzAnfangsbestandSection,
    required this.kinoSollUndAusgabenBereich,
    required this.ecBelegeBereich,
    required this.anmerkungSection,
    required this.downButtonSichtbar,
    required this.scrolleNachUnten,
    required this.beiScrollMetrikAenderung,
  });

  final ScrollController scrollController;
  final Widget devToolsBereich;
  final Widget kopfSection;
  final Widget personalgetraenkeSection;
  final Widget differenzAnfangsbestandSection;
  final Widget kinoSollUndAusgabenBereich;
  final List<Widget> ecBelegeBereich;
  final Widget anmerkungSection;
  final bool downButtonSichtbar;
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
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: <Widget>[
                devToolsBereich,
                kopfSection,
                const SizedBox(height: 12),
                personalgetraenkeSection,
                const SizedBox(height: 12),
                differenzAnfangsbestandSection,
                const SizedBox(height: 10),
                kinoSollUndAusgabenBereich,
                const SizedBox(height: 10),
                ...ecBelegeBereich,
                const SizedBox(height: 8),
                anmerkungSection,
                const SizedBox(height: 8),
              ],
            ),
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
                heroTag: 'step2DownFab',
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
