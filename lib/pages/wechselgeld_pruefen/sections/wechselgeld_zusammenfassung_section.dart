import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/widgets/zettel_hinweis.dart';

class WechselgeldZusammenfassungSection extends StatelessWidget {
  const WechselgeldZusammenfassungSection({
    super.key,
    required this.gezaehlterBetragCent,
    required this.wechselgeldSollwertCent,
    required this.differenzCent,
    required this.formatiereEuro,
    this.wechselgeldentnahmeCent = 0,
    this.wechselgeldentnahmeGrund,
    this.zettelHinweisZeigen = false,
  });

  final int gezaehlterBetragCent;
  final int wechselgeldSollwertCent;
  final int differenzCent;
  final String Function(int cent) formatiereEuro;

  /// Wechselgeldentnahme, die in den Vergleich einfließt. Die Zeile
  /// erscheint nur bei Betrag > 0.
  final int wechselgeldentnahmeCent;
  final String? wechselgeldentnahmeGrund;

  /// Orangener Zettel-Hinweis (nur in der Abend-Prüfung sinnvoll: dort
  /// steht der MA an der Kasse, der den Zettel hineinlegen muss).
  final bool zettelHinweisZeigen;

  @override
  Widget build(BuildContext context) {
    final bool differenzNull = differenzCent == 0;
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
            _ZusammenfassungsZeile(
              label: 'Gezählter Betrag',
              wert: formatiereEuro(gezaehlterBetragCent),
            ),
            _ZusammenfassungsZeile(
              label: 'Wechselgeld',
              wert: '− ${formatiereEuro(wechselgeldSollwertCent)}',
            ),
            if (wechselgeldentnahmeCent > 0)
              _ZusammenfassungsZeile(
                label:
                    'Wechselgeldentnahme'
                    '${(wechselgeldentnahmeGrund ?? '').trim().isNotEmpty ? ' (${wechselgeldentnahmeGrund!.trim()})' : ''}',
                wert: '+ ${formatiereEuro(wechselgeldentnahmeCent)}',
              ),
            _ZusammenfassungsZeile(
              label: 'Differenz',
              wert: TagesabschlussFormatierung.formatiereEuroMitVorzeichen(
                differenzCent,
              ),
              hervorheben: true,
              farbe: differenzNull ? Colors.green.shade700 : Colors.red,
            ),
            if (wechselgeldentnahmeCent > 0 && zettelHinweisZeigen) ...<Widget>[
              const SizedBox(height: 4),
              const ZettelHinweis(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ZusammenfassungsZeile extends StatelessWidget {
  const _ZusammenfassungsZeile({
    required this.label,
    required this.wert,
    this.hervorheben = false,
    this.farbe,
  });

  final String label;
  final String wert;
  final bool hervorheben;
  final Color? farbe;

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
              color: farbe,
            ),
          ),
        ],
      ),
    );
  }
}
