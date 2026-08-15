import 'package:flutter/material.dart';

import '../../../widgets/tagesabschluss_body_wrapper.dart';

// Zweck: Baut den ListView-Inhalt von Schritt 2 und reicht ihn an die
// gemeinsame TagesabschlussBodyWrapper (Theme/Scroll-Benachrichtigung/
// Down-Button), analog zu schritt1_body_content.dart. Abschnitte, die noch
// nicht in eigene Sections ausgelagert sind, werden als fertige Widgets/
// Widget-Listen durchgereicht und in kommenden Sub-Runs der
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
    return TagesabschlussBodyWrapper(
      downButtonSichtbar: downButtonSichtbar,
      downButtonHeroTag: 'step2DownFab',
      scrolleNachUnten: scrolleNachUnten,
      beiScrollMetrikAenderung: beiScrollMetrikAenderung,
      scrollable: ListView(
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
    );
  }
}
