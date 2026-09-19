import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Infokasten ganz oben in der Wechselgeldprüfung, sobald eine
/// Wechselgeldentnahme berücksichtigt wird: sagt dem MA, wie viel jetzt
/// noch in der Wechselgeldkasse liegen muss (Sollwert minus Entnahme).
class WechselgeldEntnahmeInfoKasten extends StatelessWidget {
  const WechselgeldEntnahmeInfoKasten({
    super.key,
    required this.entnahmeCent,
    required this.wirksamerSollwertCent,
    required this.abend,
    required this.formatiereEuro,
  });

  final int entnahmeCent;
  final int wirksamerSollwertCent;

  /// Abend-Prüfung: die Entnahme wird morgen zurückgelegt. Morgen-Prüfung:
  /// sie liegt noch nicht wieder in der Kasse (Notiz gefunden).
  final bool abend;
  final String Function(int cent) formatiereEuro;

  @override
  Widget build(BuildContext context) {
    final String rest = formatiereEuro(wirksamerSollwertCent);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppFarben.stueckelungWechselgeldHintergrund,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppFarben.fokusFarbe),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: <InlineSpan>[
            TextSpan(
              text:
                  'Die Wechselgeldentnahme (${formatiereEuro(entnahmeCent)}) '
                  'wird berücksichtigt. ',
            ),
            TextSpan(
              text: abend
                  ? 'In der Wechselgeldkasse müssen nur noch '
                  : 'Bis sie zurückgelegt ist, müssen nur noch ',
            ),
            TextSpan(
              text: rest,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: abend
                  ? ' liegen, weil die Entnahme morgen wieder '
                        'zurückgelegt wird.'
                  : ' in der Wechselgeldkasse liegen.',
            ),
          ],
        ),
      ),
    );
  }
}
