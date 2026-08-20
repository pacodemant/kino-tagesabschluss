import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class KurzeinstiegSeite extends StatelessWidget {
  const KurzeinstiegSeite({super.key});

  static const String routenName = '/kurzeinstieg';

  static const List<_KurzeinstiegSchritt> _schritte = <_KurzeinstiegSchritt>[
    _KurzeinstiegSchritt(
      nummer: 1,
      titel: 'Bargeld zählen',
      text: 'Zähle das gesamte Bargeld in der Kasse. Trage für jede '
          'Stückelung (Scheine, Münzrollen, lose Münzen, Umschläge) die '
          'gezählte Anzahl ein. Die Summe wird automatisch berechnet.',
    ),
    _KurzeinstiegSchritt(
      nummer: 2,
      titel: 'Belege',
      text: 'Trage alle Belege ein: Kino- und Bistro-Soll aus dem '
          'Kassensystem, Ausgaben mit Quittung sowie EC-Belege. Daraus '
          'errechnet sich die Differenz zum gezählten Bargeld.',
    ),
    _KurzeinstiegSchritt(
      nummer: 3,
      titel: 'Übertrag auf Umschlag',
      text: 'Hier wird der Betrag errechnet, der auf den Umschlag gehört. '
          'Prüfe die Differenz zwischen Soll und Ist. Bei Abweichungen '
          'zuerst die Ursache klären, dann den Umschlag befüllen.',
    ),
    _KurzeinstiegSchritt(
      nummer: 4,
      titel: 'Stückelung Barumsatz',
      text: 'Hier siehst du, wie du den Barumsatz optimal mit den '
          'verfügbaren Scheinen und Münzen stückeln kannst. Grün markierte '
          'Einheiten werden vollständig in den Umschlag gegeben.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: const Text('Kurzeinstieg'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Die Kassenabrechnung läuft in 4 Schritten ab:',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),
            for (final _KurzeinstiegSchritt schritt in _schritte)
              _KurzeinstiegSchrittZeile(schritt: schritt),
          ],
        ),
      ),
    );
  }
}

class _KurzeinstiegSchritt {
  const _KurzeinstiegSchritt({
    required this.nummer,
    required this.titel,
    required this.text,
  });

  final int nummer;
  final String titel;
  final String text;
}

class _KurzeinstiegSchrittZeile extends StatelessWidget {
  const _KurzeinstiegSchrittZeile({required this.schritt});

  final _KurzeinstiegSchritt schritt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 14,
            backgroundColor: AppFarben.appBarRot,
            foregroundColor: Colors.white,
            child: Text(
              '${schritt.nummer}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  schritt.titel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schritt.text,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
