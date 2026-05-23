import 'package:flutter/material.dart';

class Schritt1UebersichtSection extends StatelessWidget {
  const Schritt1UebersichtSection({
    super.key,
    required this.kassenbestandGesamt,
    required this.wechselgeldSollwert,
    required this.barumsatzBereinigt,
    required this.barumsatzNegativ,
  });

  final String kassenbestandGesamt;
  final String wechselgeldSollwert;
  final String barumsatzBereinigt;
  final bool barumsatzNegativ;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Zusammenfassung',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _UebersichtZeile(
              label: 'Kassenbestand gesamt',
              wert: kassenbestandGesamt,
            ),
            _UebersichtZeile(
              label: 'Wechselgeld',
              wert: wechselgeldSollwert,
            ),
            _UebersichtZeile(
              label: 'Barumsatz (bereinigt)',
              wert: barumsatzBereinigt,
              hervorheben: true,
              negativ: barumsatzNegativ,
            ),
          ],
        ),
      ),
    );
  }
}

class _UebersichtZeile extends StatelessWidget {
  const _UebersichtZeile({
    required this.label,
    required this.wert,
    this.hervorheben = false,
    this.negativ = false,
  });

  final String label;
  final String wert;
  final bool hervorheben;
  final bool negativ;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(
            wert,
            style: TextStyle(
              fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w500,
              color: hervorheben && negativ ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
