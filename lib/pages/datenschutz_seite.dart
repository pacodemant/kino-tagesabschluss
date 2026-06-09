import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class DatenschutzSeite extends StatelessWidget {
  const DatenschutzSeite({super.key});

  static const String routenName = '/datenschutz';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: const Text('Datenschutzhinweise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Dein Name bleibt auf deinem Handy. Die Abrechnung geht nur ans Kino-Büro — sonst nirgendwo hin. Kein Account, kein Cloud-Speicher, kein Tracking. Fotografierst du einen EC-Beleg, liest eine KI kurz die Zahlen aus — das Foto selbst wird nicht gespeichert.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text(
                'Für alle, die es genau wissen wollen',
                style: TextStyle(fontSize: 15),
              ),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              children: const <Widget>[
                _DatenschutzAbschnitt(
                  titel: 'Verantwortlicher',
                  text:
                      'Schauburg GmbH, Bremen. Zuständig für Information der Mitarbeitenden gemäß Art. 13/14 DSGVO sowie ggf. Abschluss einer Betriebsvereinbarung.',
                ),
                _DatenschutzAbschnitt(
                  titel: 'Verarbeitete Daten',
                  text:
                      'Mitarbeitername (gerätespezifisch, selbst eingetragen) · Abrechnungsdatum und -uhrzeit · Kassenwerte (Beträge, Differenzen) · Gerätespezifische Einstellungen (Händigkeit, bevorzugtes Kino). Keine Passwörter, keine Bankdaten, keine Authentifizierung.',
                ),
                _DatenschutzAbschnitt(
                  titel: 'Datenspeicherung',
                  text:
                      'Lokal im Browser-LocalStorage des jeweiligen Geräts. Kein zentraler Nutzer-Account, kein Cloud-Speicher. Abgeschlossene Abrechnungen werden zusätzlich an den Kino-Server der Schauburg GmbH übertragen — ausschließlich intern.',
                ),
                _DatenschutzAbschnitt(
                  titel: 'Keine Weitergabe an Dritte',
                  text:
                      'Abrechnungsdaten verlassen das System ausschließlich über die definierte Schnittstelle zur Kino-IT der Schauburg GmbH. Kein Tracking, keine Analyse-Dienste, keine Weitergabe an externe Anbieter.',
                ),
                _DatenschutzAbschnitt(
                  titel: 'Ausnahme: BelegScan (optional)',
                  text:
                      'Wird der optionale BelegScan verwendet, wird das aufgenommene Belegfoto zur Auswertung an die Anthropic API (USA) übermittelt. An die Buchhaltung werden ausschließlich die ausgelesenen Zahlenwerte übergeben — kein Foto wird gespeichert oder weitergeleitet. Die Funktion ist deaktivierbar.',
                ),
                _DatenschutzAbschnitt(
                  titel: 'Empfehlung an die Schauburg GmbH',
                  text:
                      'Mitarbeitende vor Inbetriebnahme schriftlich über die Datenverarbeitung informieren (Art. 13 DSGVO). Bei Einsatz von BelegScan: AVV mit Anthropic abschließen (über console.anthropic.com verfügbar).',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatenschutzAbschnitt extends StatelessWidget {
  const _DatenschutzAbschnitt({required this.titel, required this.text});

  final String titel;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
