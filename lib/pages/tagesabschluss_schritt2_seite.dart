import 'package:flutter/material.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';

class TagesabschlussSchritt2Argumente {
  const TagesabschlussSchritt2Argumente({
    required this.kinoId,
    required this.kinoName,
    required this.barBestandAbzglWechselgeldCent,
  });

  final String kinoId;
  final String kinoName;
  final int barBestandAbzglWechselgeldCent;
}

class TagesabschlussSchritt2Seite extends StatefulWidget {
  const TagesabschlussSchritt2Seite({
    super.key,
    required this.kinoId,
    required this.kinoName,
    required this.barBestandAbzglWechselgeldCent,
  });

  static const String routenName = '/closure-step-2';

  final String kinoId;
  final String kinoName;
  final int barBestandAbzglWechselgeldCent;

  @override
  State<TagesabschlussSchritt2Seite> createState() =>
      _TagesabschlussSchritt2SeiteState();
}

class _TagesabschlussSchritt2SeiteState
    extends State<TagesabschlussSchritt2Seite> {
  final TextEditingController _kinoSollController = TextEditingController();
  final TextEditingController _bistroSollController = TextEditingController();
  final TextEditingController _ausgabenController = TextEditingController();
  final TextEditingController _differenzAnfangsbestandController =
      TextEditingController();
  final List<TextEditingController> _ecBelegController = <TextEditingController>[
    TextEditingController(),
  ];

  int _kinoSollCent = 0;
  int _bistroSollCent = 0;
  int _ausgabenCent = 0;
  int _differenzAnfangsbestandCent = 0;
  final List<int> _ecBelegeCent = <int>[0];

  @override
  void dispose() {
    _kinoSollController.dispose();
    _bistroSollController.dispose();
    _ausgabenController.dispose();
    _differenzAnfangsbestandController.dispose();
    for (final TextEditingController controller in _ecBelegController) {
      controller.dispose();
    }
    super.dispose();
  }

  int _parseCentZiffern(String wert) {
    final String nurZiffern = wert.replaceAll(RegExp(r'[^0-9]'), '');
    if (nurZiffern.isEmpty) {
      return 0;
    }
    return int.tryParse(nurZiffern) ?? 0;
  }

  String _formatiereEuro(int cent) {
    final String vorzeichen = cent < 0 ? '-' : '';
    final int absolut = cent.abs();
    final int euro = absolut ~/ 100;
    final String centTeil = (absolut % 100).toString().padLeft(2, '0');
    return '$vorzeichen$euro,$centTeil €';
  }

  String _formatiereEuroMitVorzeichen(int cent) {
    if (cent > 0) {
      final int euro = cent ~/ 100;
      final String centTeil = (cent % 100).toString().padLeft(2, '0');
      return '+$euro,$centTeil €';
    }
    return _formatiereEuro(cent);
  }

  int get _ecUmsatzGesamtCent {
    int summe = 0;
    for (final int beleg in _ecBelegeCent) {
      summe += beleg;
    }
    return summe;
  }

  int get _gesamtSollCent => _kinoSollCent + _bistroSollCent - _ausgabenCent;

  int get _gesamtIstCent =>
      _ecUmsatzGesamtCent + widget.barBestandAbzglWechselgeldCent;

  int get _differenzTagesabschlussCent => _gesamtIstCent - _gesamtSollCent;

  void _ecBelegHinzufuegen() {
    setState(() {
      _ecBelegController.add(TextEditingController());
      _ecBelegeCent.add(0);
    });
  }

  void _ecBelegEntfernen(int index) {
    if (_ecBelegController.length <= 1 ||
        index < 0 ||
        index >= _ecBelegController.length) {
      return;
    }
    setState(() {
      _ecBelegController.removeAt(index).dispose();
      _ecBelegeCent.removeAt(index);
    });
  }

  Widget _baueEingabeZeile({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    bool optional = false,
    bool zeigeLoeschen = false,
    VoidCallback? onLoeschen,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              optional ? '$label (optional)' : label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 170,
            child: BetragCentEingabefeld(
              textController: controller,
              onChanged: onChanged,
              schriftgroesse: 20,
              hinweisText: '0,00 €',
            ),
          ),
          if (zeigeLoeschen) ...<Widget>[
            const SizedBox(width: 6),
            IconButton(
              onPressed: onLoeschen,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'EC-Beleg entfernen',
            ),
          ],
        ],
      ),
    );
  }

  Widget _baueBerechneteZeile({
    required String label,
    required String wert,
    bool hervorheben = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              wert,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20,
                fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w600,
                color: hervorheben && _differenzTagesabschlussCent < 0
                    ? Colors.red
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tagesabschluss – Schritt 2/4: Einnahmen/Abschluss'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: <Widget>[
            Text(
              'Kino: ${widget.kinoName} (${widget.kinoId})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hinweis: „SOLL“ ist hier nur eine Bezeichnung für abgelesene Umsätze.',
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _baueEingabeZeile(
                      label: 'Kino SOLL',
                      controller: _kinoSollController,
                      onChanged: (String wert) {
                        setState(() {
                          _kinoSollCent = _parseCentZiffern(wert);
                        });
                      },
                    ),
                    _baueEingabeZeile(
                      label: 'Bistro SOLL',
                      controller: _bistroSollController,
                      onChanged: (String wert) {
                        setState(() {
                          _bistroSollCent = _parseCentZiffern(wert);
                        });
                      },
                    ),
                    _baueEingabeZeile(
                      label: 'Ausgaben',
                      controller: _ausgabenController,
                      optional: true,
                      onChanged: (String wert) {
                        setState(() {
                          _ausgabenCent = _parseCentZiffern(wert);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (int i = 0; i < _ecBelegController.length; i++)
                      _baueEingabeZeile(
                        label: 'EC Beleg ${i + 1}',
                        controller: _ecBelegController[i],
                        optional: i > 0,
                        zeigeLoeschen: i > 0,
                        onLoeschen: () => _ecBelegEntfernen(i),
                        onChanged: (String wert) {
                          setState(() {
                            _ecBelegeCent[i] = _parseCentZiffern(wert);
                          });
                        },
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _ecBelegHinzufuegen,
                        icon: const Icon(Icons.add),
                        label: const Text('+ EC-Beleg hinzufügen'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    _baueBerechneteZeile(
                      label: 'Gesamt SOLL',
                      wert: _formatiereEuro(_gesamtSollCent),
                    ),
                    _baueBerechneteZeile(
                      label: 'EC Umsatz',
                      wert: _formatiereEuro(_ecUmsatzGesamtCent),
                    ),
                    _baueBerechneteZeile(
                      label: 'BAR Bestand abzgl. Wechselgeld',
                      wert: _formatiereEuro(widget.barBestandAbzglWechselgeldCent),
                    ),
                    _baueBerechneteZeile(
                      label: 'Gesamt IST',
                      wert: _formatiereEuro(_gesamtIstCent),
                    ),
                    _baueBerechneteZeile(
                      label: 'Differenz Tagesabschluss',
                      wert: _formatiereEuroMitVorzeichen(_differenzTagesabschlussCent),
                      hervorheben: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    _baueEingabeZeile(
                      label: 'Differenz im Anfangsbestand',
                      controller: _differenzAnfangsbestandController,
                      optional: true,
                      onChanged: (String wert) {
                        setState(() {
                          _differenzAnfangsbestandCent = _parseCentZiffern(wert);
                        });
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Info: ${_formatiereEuro(_differenzAnfangsbestandCent)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
