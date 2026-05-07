import 'package:flutter/material.dart';

class Schritt1HinweiseSection extends StatelessWidget {
  const Schritt1HinweiseSection({
    super.key,
    required this.umschlaegeInhalt,
  });

  final Widget umschlaegeInhalt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[umschlaegeInhalt],
    );
  }
}
