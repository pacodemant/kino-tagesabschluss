import 'package:flutter/material.dart';

class Schritt1BodyContent extends StatelessWidget {
  const Schritt1BodyContent({
    super.key,
    required this.scrollController,
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
  });

  final ScrollController scrollController;
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

  @override
  Widget build(BuildContext context) {
    const double bottomPadding = 72;
    const double downButtonBottom = 12;

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
            child: CustomScrollView(
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
        if (downButtonSichtbar)
          Positioned(
            left: 0,
            right: 0,
            bottom: downButtonBottom,
            child: Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: FloatingActionButton(
                  heroTag: 'step1DownFab',
                  mini: true,
                  elevation: 2,
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  onPressed: scrolleNachUnten,
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
            ),
          ),
      ],
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
