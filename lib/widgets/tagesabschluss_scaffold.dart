import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class TagesabschlussScaffold extends StatelessWidget {
  const TagesabschlussScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footerChild,
    this.actions,
    this.backgroundColor,
  });

  final String title;
  final Widget child;
  final Widget? footerChild;
  final List<Widget>? actions;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final double viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: Text(title),
        actions: actions,
      ),
      bottomNavigationBar: footerChild == null
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Colors.black87,
                border: Border(top: BorderSide(color: Color(0x52FFFFFF))),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x4D000000),
                    offset: Offset(0, -2),
                    blurRadius: 12,
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(12, 6, 12, 6 + viewPaddingBottom),
              child: footerChild,
            ),
      body: child,
    );
  }
}
