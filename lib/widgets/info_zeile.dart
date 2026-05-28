import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum InfoZeileStil { unterstrichen, fuehrungslinie }

class InfoZeile extends StatelessWidget {
  const InfoZeile({
    super.key,
    required this.label,
    required this.wert,
    this.fett = false,
    this.farbe,
    this.stil = InfoZeileStil.unterstrichen,
  });

  final String label;
  final String wert;
  final bool fett;
  final Color? farbe;
  final InfoZeileStil stil;

  @override
  Widget build(BuildContext context) {
    final FontWeight gewicht = fett ? FontWeight.bold : FontWeight.normal;

    switch (stil) {
      case InfoZeileStil.unterstrichen:
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(label, style: TextStyle(fontWeight: gewicht)),
              ),
              Text(wert, style: TextStyle(fontWeight: gewicht, color: farbe)),
            ],
          ),
        );

      case InfoZeileStil.fuehrungslinie:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: <Widget>[
              Text(label, style: TextStyle(fontWeight: gewicht)),
              const SizedBox(width: 4),
              const Expanded(
                child: CustomPaint(painter: _FuehrungsLiniePainter()),
              ),
              const SizedBox(width: 4),
              Text(
                wert,
                style: GoogleFonts.caveat(
                  fontSize: 26,
                  fontWeight: gewicht,
                  color: farbe,
                  height: 1.0,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _FuehrungsLiniePainter extends CustomPainter {
  const _FuehrungsLiniePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    const double dash = 2.0;
    const double gap = 4.0;
    final double y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
