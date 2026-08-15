import 'package:flutter/material.dart';

import '../../../widgets/tagesabschluss_body_wrapper.dart';

class Schritt1BodyContent extends StatelessWidget {
  const Schritt1BodyContent({
    super.key,
    required this.scrollController,
    required this.devToolsStickySichtbar,
    required this.devToolsStickyHoehe,
    required this.devToolsPanel,
    required this.alleZuklappenLink,
    required this.scheineGruppe,
    required this.loseMuenzenGruppe,
    required this.rollenGruppe,
    required this.hinweiseSection,
    required this.zusammenfassung,
    required this.downButtonSichtbar,
    required this.scrolleNachUnten,
    required this.beiScrollMetrikAenderung,
  });

  final ScrollController scrollController;
  final bool devToolsStickySichtbar;
  final double devToolsStickyHoehe;
  final Widget devToolsPanel;
  final Widget alleZuklappenLink;
  final Widget scheineGruppe;
  final Widget loseMuenzenGruppe;
  final Widget rollenGruppe;
  final Widget hinweiseSection;
  final Widget zusammenfassung;
  final bool downButtonSichtbar;
  final VoidCallback scrolleNachUnten;
  final VoidCallback beiScrollMetrikAenderung;

  @override
  Widget build(BuildContext context) {
    const double bottomPadding = 72;

    return TagesabschlussBodyWrapper(
      downButtonSichtbar: downButtonSichtbar,
      downButtonHeroTag: 'step1DownFab',
      scrolleNachUnten: scrolleNachUnten,
      beiScrollMetrikAenderung: beiScrollMetrikAenderung,
      scrollable: CustomScrollView(
        controller: scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: <Widget>[
          if (devToolsStickySichtbar)
            SliverPersistentHeader(
              pinned: true,
              delegate: _DevToolsStickyHeaderDelegate(
                extent: devToolsStickyHoehe,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: devToolsPanel,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, bottomPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                alleZuklappenLink,
                scheineGruppe,
                loseMuenzenGruppe,
                rollenGruppe,
                hinweiseSection,
                zusammenfassung,
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevToolsStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DevToolsStickyHeaderDelegate({required this.extent, required this.child});

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _DevToolsStickyHeaderDelegate oldDelegate) {
    return extent != oldDelegate.extent || child != oldDelegate.child;
  }
}
