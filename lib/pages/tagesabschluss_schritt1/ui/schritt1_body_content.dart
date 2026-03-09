import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Schritt1BodyContent extends StatelessWidget {
  const Schritt1BodyContent({
    super.key,
    required this.scrollController,
    required this.keyboardAnimationZiel,
    required this.footerAnimationDauer,
    required this.footerAnimationKurve,
    required this.footerContentHoeheNormal,
    required this.footerContentHoeheKeyboard,
    required this.footerPaddingNormal,
    required this.footerPaddingKeyboard,
    required this.keyboardInset,
    required this.bottomInset,
    required this.devToolsStickySichtbar,
    required this.devToolsStickyHoehe,
    required this.devToolsPanel,
    required this.scheineGruppe,
    required this.loseMuenzenGruppe,
    required this.rollenGruppe,
    required this.hinweiseSection,
    required this.zusammenfassung,
    required this.downButtonSichtbar,
    required this.scrolleNachUnten,
    required this.beiScrollMetrikAenderung,
    required this.footerBuilder,
  });

  final ScrollController scrollController;
  final double keyboardAnimationZiel;
  final Duration footerAnimationDauer;
  final Curve footerAnimationKurve;
  final double footerContentHoeheNormal;
  final double footerContentHoeheKeyboard;
  final EdgeInsets footerPaddingNormal;
  final EdgeInsets footerPaddingKeyboard;
  final double keyboardInset;
  final double bottomInset;
  final bool devToolsStickySichtbar;
  final double devToolsStickyHoehe;
  final Widget devToolsPanel;
  final Widget scheineGruppe;
  final Widget loseMuenzenGruppe;
  final Widget rollenGruppe;
  final Widget hinweiseSection;
  final Widget zusammenfassung;
  final bool downButtonSichtbar;
  final VoidCallback scrolleNachUnten;
  final VoidCallback beiScrollMetrikAenderung;
  final Widget Function({
    required EdgeInsets footerPadding,
    required double footerBottomInset,
  })
  footerBuilder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: keyboardAnimationZiel),
      duration: footerAnimationDauer,
      curve: footerAnimationKurve,
      builder: (BuildContext context, double faktor, _) {
        final double footerBottom = keyboardInset * faktor;
        final double footerContentHoehe = ui.lerpDouble(
          footerContentHoeheNormal,
          footerContentHoeheKeyboard,
          faktor,
        )!;
        final double footerBottomInset = ui.lerpDouble(bottomInset, 0, faktor)!;
        final EdgeInsets footerPadding = EdgeInsets.lerp(
          footerPaddingNormal,
          footerPaddingKeyboard,
          faktor,
        )!;
        final double footerTotalHoehe = footerContentHoehe + footerBottomInset;
        final double bottomPadding = keyboardInset + footerTotalHoehe + 16;
        return Stack(
          children: <Widget>[
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                ),
              ),
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: (ScrollMetricsNotification notification) {
                  beiScrollMetrikAenderung();
                  return false;
                },
                child: CustomScrollView(
                  controller: scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPadding),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(<Widget>[
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
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: footerBottom,
              child: SizedBox(
                height: footerTotalHoehe,
                child: footerBuilder(
                  footerPadding: footerPadding,
                  footerBottomInset: footerBottomInset,
                ),
              ),
            ),
            if (downButtonSichtbar)
              Positioned(
                left: 0,
                right: 0,
                bottom: footerBottom + footerTotalHoehe + 10,
                child: Center(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: FloatingActionButton(
                      heroTag: 'step1DownFab',
                      mini: true,
                      elevation: 2,
                      onPressed: scrolleNachUnten,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
