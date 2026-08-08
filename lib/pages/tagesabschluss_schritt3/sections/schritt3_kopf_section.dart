import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Schritt3KopfSection extends StatelessWidget {
  const Schritt3KopfSection({
    super.key,
    required this.kinoName,
    required this.datum,
  });

  final String kinoName;
  final String datum;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Expanded(
            child: Text(
              kinoName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          Text(
            datum,
            style: GoogleFonts.caveat(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
