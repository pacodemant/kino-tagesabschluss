import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

class VerlaufDetailSeite extends StatefulWidget {
  const VerlaufDetailSeite({super.key, required this.abschluss});

  static const String routenName = '/verlauf-detail';

  final TagesabschlussFinal abschluss;

  @override
  State<VerlaufDetailSeite> createState() => _VerlaufDetailSeiteState();
}

class _VerlaufDetailSeiteState extends State<VerlaufDetailSeite> {
  bool _loescht = false;

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);
  String _euroMitVorzeichen(int cent) =>
      TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);
  String _deutschesDatum(DateTime datum) =>
      TagesabschlussFormatierung.deutschesDatum(datum);

  Future<void> _loescheEintrag() async {
    if (_loescht) {
      return;
    }

    final NavigatorState navigator = Navigator.of(context);

    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text('Diesen Tagesabschluss wirklich löschen?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (bestaetigt != true || !mounted) {
      return;
    }

    setState(() {
      _loescht = true;
    });

    await LokalerSpeicher.loescheFinalenTagesabschluss(
      widget.abschluss.kinoId,
      widget.abschluss.datum,
    );

    if (!mounted) {
      return;
    }
    navigator.pop(true);
  }

  Widget _abschnittsTitel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _zeile(String label, String wert, {Color? farbe, bool fett = false}) {
    final FontWeight gewicht = fett ? FontWeight.bold : FontWeight.normal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label, style: TextStyle(fontWeight: gewicht)),
          ),
          Text(wert, style: TextStyle(fontWeight: gewicht, color: farbe)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TagesabschlussFinal a = widget.abschluss;
    final Color differenzFarbe =
        a.differenzGesamtCent >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${_deutschesDatum(a.datum)} – ${a.kinoName}',
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: <Widget>[
                // Abschnitt 1 – Geldzählung
                _abschnittsTitel('Geldzählung'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        _zeile('Scheine', _euro(a.scheineCent)),
                        _zeile('Rollen', _euro(a.rollenCent)),
                        _zeile('Lose Münzen', _euro(a.loseMuenzenCent)),
                        _zeile('Umschläge', _euro(a.umschlaegeCent)),
                        const Divider(height: 16),
                        _zeile(
                          'Kassenbestand gesamt',
                          _euro(a.kassenbestandGesamtCent),
                          fett: true,
                        ),
                        _zeile(
                          'Wechselgeld-Sollwert',
                          _euro(a.wechselgeldSollwertCent),
                        ),
                        _zeile(
                          'Bar-Bestand bereinigt',
                          _euro(a.barBestandAbzglWechselgeldCent),
                          fett: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // Abschnitt 2 – Einnahmen
                _abschnittsTitel('Einnahmen'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        _zeile('Kino SOLL', _euro(a.kinoSollCent)),
                        _zeile('Bistro SOLL', _euro(a.bistroSollCent)),
                        _zeile('Ausgaben', _euro(a.ausgabenCent)),
                        _zeile('EC-Umsatz gesamt', _euro(a.ecUmsatzGesamtCent)),
                      ],
                    ),
                  ),
                ),

                // Abschnitt 3 – Ergebnis
                _abschnittsTitel('Ergebnis'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        _zeile(
                          'Gesamt SOLL',
                          _euro(a.gesamtSollCent),
                          fett: true,
                        ),
                        _zeile(
                          'Gesamt IST',
                          _euro(a.gesamtIstCent),
                          fett: true,
                        ),
                        const Divider(height: 16),
                        _zeile(
                          'Differenz Tagesabschluss',
                          _euroMitVorzeichen(a.differenzGesamtCent),
                          fett: true,
                          farbe: differenzFarbe,
                        ),
                        _zeile(
                          'Differenz Anfangsbestand',
                          _euro(a.differenzAnfangsbestandCent),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loescht ? null : _loescheEintrag,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                    child: Text(
                      _loescht ? 'Wird gelöscht...' : 'Eintrag löschen',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
