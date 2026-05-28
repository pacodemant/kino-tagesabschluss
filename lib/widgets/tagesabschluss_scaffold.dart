import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/haus_button.dart';

class TagesabschlussScaffold extends StatelessWidget {
  const TagesabschlussScaffold({
    super.key,
    this.title = '',
    required this.child,
    this.footerChild,
    this.actions,
    this.backgroundColor,
    this.appBar,
    this.zeigeHausButton = true,
  });

  final String title;
  final Widget child;
  final Widget? footerChild;
  final List<Widget>? actions;
  final Color? backgroundColor;
  // Optionaler Custom-AppBar; wenn gesetzt, wird der Default-AppBar nicht gebaut.
  final PreferredSizeWidget? appBar;
  final bool zeigeHausButton;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool tastaturOffen = mediaQuery.viewInsets.bottom > 0;
    final double footerBottomPadding =
        tastaturOffen ? 8.0 : mediaQuery.padding.bottom;

    final bool zeigeFooter = zeigeHausButton || footerChild != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: appBar ??
          AppBar(
            centerTitle: false,
            backgroundColor: AppFarben.appBarRot,
            foregroundColor: Colors.white,
            toolbarHeight: 48,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            actions: actions,
          ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: child),
          if (zeigeFooter)
            Container(
              decoration: AppFarben.footerDecoration,
              padding: EdgeInsets.fromLTRB(12, 4, 12, 4 + footerBottomPadding),
              child: SizedBox(
                height: 36,
                child: Row(
                  children: <Widget>[
                    if (zeigeHausButton) ...<Widget>[
                      const HausButton(),
                      const SizedBox(width: 8),
                    ],
                    if (footerChild != null)
                      Expanded(child: footerChild!),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
