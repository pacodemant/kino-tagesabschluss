import 'package:flutter/material.dart';

class Schritt1Footer extends StatelessWidget {
  const Schritt1Footer({
    super.key,
    required this.tastaturOffen,
    required this.footerPadding,
    required this.footerBottomInset,
    required this.zeigeNaechstesFeld,
    required this.weiterZumNaechstenFeldUnten,
    required this.weiterZuSchritt2,
  });

  final bool tastaturOffen;
  final EdgeInsets footerPadding;
  final double footerBottomInset;
  final bool zeigeNaechstesFeld;
  final VoidCallback weiterZumNaechstenFeldUnten;
  final VoidCallback weiterZuSchritt2;

  @override
  Widget build(BuildContext context) {
    const Color footerBg = Colors.black87;
    final ButtonStyle kompaktButtonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(0, tastaturOffen ? 36 : 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return ColoredBox(
      color: footerBg,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x52FFFFFF))),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, -2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: footerPadding.add(
            EdgeInsets.only(bottom: footerBottomInset),
          ),
          child: Row(
            children: <Widget>[
              if (zeigeNaechstesFeld) ...<Widget>[
                TextButton(
                  onPressed: weiterZumNaechstenFeldUnten,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Next'),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: weiterZuSchritt2,
                  style: kompaktButtonStyle,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Icon(Icons.arrow_forward),
                        SizedBox(width: 6),
                        Text('Belege eingeben (2/4)'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
