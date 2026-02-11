import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/kassenstand_entwurf.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/ganzzahl_eingabefeld.dart';

class TagesabschlussSchritt1Argumente {
  const TagesabschlussSchritt1Argumente({
    required this.kinoId,
    required this.kinoName,
  });

  final String kinoId;
  final String kinoName;
}

class TagesabschlussSchritt1Seite extends StatefulWidget {
  const TagesabschlussSchritt1Seite({
    super.key,
    required this.kinoId,
    required this.kinoName,
  });

  static const String routenName = '/closure-step-1';

  final String kinoId;
  final String kinoName;

  @override
  State<TagesabschlussSchritt1Seite> createState() =>
      _TagesabschlussSchritt1SeiteState();
}

class _TagesabschlussSchritt1SeiteState
    extends State<TagesabschlussSchritt1Seite> {
  static const List<Kassenzeile> _scheine = <Kassenzeile>[
    Kassenzeile(id: 'note_100', bezeichnung: '100 €', einzelwertCent: 10000),
    Kassenzeile(id: 'note_50', bezeichnung: '50 €', einzelwertCent: 5000),
    Kassenzeile(id: 'note_20', bezeichnung: '20 €', einzelwertCent: 2000),
    Kassenzeile(id: 'note_10', bezeichnung: '10 €', einzelwertCent: 1000),
    Kassenzeile(id: 'note_5', bezeichnung: '5 €', einzelwertCent: 500),
  ];

  static const List<Kassenzeile> _rollen = <Kassenzeile>[
    Kassenzeile(
      id: 'roll_2e',
      bezeichnung: 'Rolle 2 € (50,00 €)',
      einzelwertCent: 5000,
    ),
    Kassenzeile(
      id: 'roll_1e',
      bezeichnung: 'Rolle 1 € (25,00 €)',
      einzelwertCent: 2500,
    ),
    Kassenzeile(
      id: 'roll_50c',
      bezeichnung: 'Rolle 50 ct (20,00 €)',
      einzelwertCent: 2000,
    ),
    Kassenzeile(
      id: 'roll_20c',
      bezeichnung: 'Rolle 20 ct (8,00 €)',
      einzelwertCent: 800,
    ),
    Kassenzeile(
      id: 'roll_10c',
      bezeichnung: 'Rolle 10 ct (4,00 €)',
      einzelwertCent: 400,
    ),
    Kassenzeile(
      id: 'roll_5c',
      bezeichnung: 'Rolle 5 ct (2,00 €)',
      einzelwertCent: 200,
    ),
    Kassenzeile(
      id: 'roll_2c',
      bezeichnung: 'Rolle 2 ct (1,00 €)',
      einzelwertCent: 100,
    ),
    Kassenzeile(
      id: 'roll_1c',
      bezeichnung: 'Rolle 1 ct (0,50 €)',
      einzelwertCent: 50,
    ),
  ];

  final Map<String, int> _stueckzahlen = <String, int>{};
  final Map<String, TextEditingController> _stueckzahlController =
      <String, TextEditingController>{};
  final TextEditingController _loseMuenzenController = TextEditingController();

  final List<UmschlagEintrag> _umschlaege = <UmschlagEintrag>[];
  final List<TextEditingController> _umschlagBetragController =
      <TextEditingController>[];
  final List<TextEditingController> _umschlagBezeichnungController =
      <TextEditingController>[];

  int _wechselgeldSollwertCent = 20000;
  int _loseMuenzenCent = 0;
  bool _laedt = true;

  List<Kassenzeile> get _alleStueckzahlZeilen => <Kassenzeile>[
    ..._scheine,
    ..._rollen,
  ];

  @override
  void initState() {
    super.initState();
    for (final Kassenzeile zeile in _alleStueckzahlZeilen) {
      _stueckzahlen[zeile.id] = 0;
      _stueckzahlController[zeile.id] = TextEditingController();
    }
    _ladeInitialeDaten();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _stueckzahlController.values) {
      controller.dispose();
    }
    _loseMuenzenController.dispose();
    for (final TextEditingController controller in _umschlagBetragController) {
      controller.dispose();
    }
    for (final TextEditingController controller in _umschlagBezeichnungController) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _ladeInitialeDaten() async {
    final int geladenerWechselgeldSollwert =
        await LokalerSpeicher.ladeWechselgeldSollwertCent(widget.kinoId);

    final KassenstandEntwurf? entwurf = await LokalerSpeicher
        .ladeKassenstandEntwurf(
          kinoId: widget.kinoId,
          isoDatum: _heutigesIsoDatum(),
        );

    if (entwurf != null) {
      for (final Kassenzeile zeile in _alleStueckzahlZeilen) {
        _stueckzahlen[zeile.id] = entwurf.stueckzahlen[zeile.id] ?? 0;
      }
      _loseMuenzenCent = entwurf.loseMuenzenCent;
      _uebernehmeUmschlagEntwurf(entwurf.umschlaege);
    }

    _synchronisiereControllerAusState();

    if (!mounted) {
      return;
    }

    setState(() {
      _wechselgeldSollwertCent = geladenerWechselgeldSollwert;
      _laedt = false;
    });
  }

  void _leereUmschlagFelder() {
    for (final TextEditingController controller in _umschlagBetragController) {
      controller.dispose();
    }
    for (final TextEditingController controller in _umschlagBezeichnungController) {
      controller.dispose();
    }
    _umschlaege.clear();
    _umschlagBetragController.clear();
    _umschlagBezeichnungController.clear();
  }

  void _uebernehmeUmschlagEntwurf(List<UmschlagEintrag> umschlagEntwurf) {
    _leereUmschlagFelder();
    for (final UmschlagEintrag eintrag in umschlagEntwurf) {
      _umschlaege.add(eintrag);
      _umschlagBetragController.add(
        TextEditingController(text: _formatiereEuro(eintrag.betragCent)),
      );
      _umschlagBezeichnungController.add(
        TextEditingController(text: eintrag.bezeichnung),
      );
    }
  }

  void _synchronisiereControllerAusState() {
    for (final Kassenzeile zeile in _alleStueckzahlZeilen) {
      final int stueckzahl = _stueckzahlen[zeile.id] ?? 0;
      final TextEditingController controller = _stueckzahlController[zeile.id]!;
      final String naechsterText = stueckzahl == 0 ? '' : stueckzahl.toString();
      if (controller.text != naechsterText) {
        controller.text = naechsterText;
      }
    }

    final String loseMuenzenText =
        _loseMuenzenCent == 0 ? '' : _formatiereEuro(_loseMuenzenCent);
    if (_loseMuenzenController.text != loseMuenzenText) {
      _loseMuenzenController.text = loseMuenzenText;
    }
  }

  String _heutigesIsoDatum() {
    final DateTime jetzt = DateTime.now();
    final String jahr = jetzt.year.toString().padLeft(4, '0');
    final String monat = jetzt.month.toString().padLeft(2, '0');
    final String tag = jetzt.day.toString().padLeft(2, '0');
    return '$jahr-$monat-$tag';
  }

  Future<void> _speichereEntwurf() async {
    final KassenstandEntwurf entwurf = KassenstandEntwurf(
      stueckzahlen: Map<String, int>.from(_stueckzahlen),
      umschlaege: List<UmschlagEintrag>.from(_umschlaege),
      loseMuenzenCent: _loseMuenzenCent,
    );

    await LokalerSpeicher.speichereKassenstandEntwurf(
      kinoId: widget.kinoId,
      isoDatum: _heutigesIsoDatum(),
      entwurf: entwurf,
    );
  }

  void _beiStueckzahlGeaendert(Kassenzeile zeile, String wert) {
    final int geparsterWert = int.tryParse(wert) ?? 0;
    setState(() {
      _stueckzahlen[zeile.id] = geparsterWert;
    });
    _speichereEntwurf();
  }

  void _beiLoseMuenzenGeaendert(String wert) {
    setState(() {
      _loseMuenzenCent = _parseCentZiffern(wert);
    });
    _speichereEntwurf();
  }

  void _umschlagHinzufuegen() {
    setState(() {
      _umschlaege.add(const UmschlagEintrag(bezeichnung: '', betragCent: 0));
      _umschlagBetragController.add(TextEditingController());
      _umschlagBezeichnungController.add(TextEditingController());
    });
    _speichereEntwurf();
  }

  void _umschlagEntfernen(int index) {
    if (index < 0 || index >= _umschlaege.length) {
      return;
    }

    setState(() {
      _umschlaege.removeAt(index);
      _umschlagBetragController.removeAt(index).dispose();
      _umschlagBezeichnungController.removeAt(index).dispose();
    });
    _speichereEntwurf();
  }

  void _beiUmschlagBezeichnungGeaendert(int index, String wert) {
    if (index < 0 || index >= _umschlaege.length) {
      return;
    }

    setState(() {
      _umschlaege[index] = UmschlagEintrag(
        bezeichnung: wert,
        betragCent: _umschlaege[index].betragCent,
      );
    });
    _speichereEntwurf();
  }

  void _beiUmschlagBetragGeaendert(int index, String wert) {
    if (index < 0 || index >= _umschlaege.length) {
      return;
    }

    final int betragCent = _parseCentZiffern(wert);
    setState(() {
      _umschlaege[index] = UmschlagEintrag(
        bezeichnung: _umschlaege[index].bezeichnung,
        betragCent: betragCent,
      );
    });
    _speichereEntwurf();
  }

  int _parseCentZiffern(String wert) {
    final String nurZiffern = wert.replaceAll(RegExp(r'[^0-9]'), '');
    if (nurZiffern.isEmpty) {
      return 0;
    }
    return int.tryParse(nurZiffern) ?? 0;
  }

  int _summeGruppe(List<Kassenzeile> zeilen) {
    int summe = 0;
    for (final Kassenzeile zeile in zeilen) {
      final int stueckzahl = _stueckzahlen[zeile.id] ?? 0;
      summe += stueckzahl * zeile.einzelwertCent;
    }
    return summe;
  }

  int get _umschlagSummeCent {
    int summe = 0;
    for (final UmschlagEintrag eintrag in _umschlaege) {
      summe += eintrag.betragCent;
    }
    return summe;
  }

  int get _kassenbestandGesamtCent {
    return _summeGruppe(_scheine) +
        _loseMuenzenCent +
        _summeGruppe(_rollen) +
        _umschlagSummeCent;
  }

  int get _barumsatzBereinigtCent =>
      _kassenbestandGesamtCent - _wechselgeldSollwertCent;

  String _formatiereEuro(int cent) {
    final String vorzeichen = cent < 0 ? '-' : '';
    final int absolut = cent.abs();
    final int euro = absolut ~/ 100;
    final String centTeil = (absolut % 100).toString().padLeft(2, '0');
    return '$vorzeichen$euro,$centTeil €';
  }

  Future<void> _weiterZuSchritt2() async {
    if (_kassenbestandGesamtCent == 0) {
      final bool? bestaetigt = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('0 € übernehmen?'),
            content: const Text(
              'Es wurde noch kein Betrag erfasst. Willst du mit 0 € fortfahren?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Fortfahren'),
              ),
            ],
          );
        },
      );

      if (bestaetigt != true) {
        return;
      }
    }

    await _speichereEntwurf();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamed(TagesabschlussSchritt2PlatzhalterSeite.routenName);
  }

  Widget _baueGruppe(String titel, List<Kassenzeile> zeilen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(titel, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final Kassenzeile zeile in zeilen) ...<Widget>[
              _baueZeilenEintrag(zeile),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            Text(
              'Zwischensumme: ${_formatiereEuro(_summeGruppe(zeilen))}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _baueZeilenEintrag(Kassenzeile zeile) {
    final int stueckzahl = _stueckzahlen[zeile.id] ?? 0;
    final int zwischensumme = stueckzahl * zeile.einzelwertCent;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(zeile.bezeichnung, style: const TextStyle(fontSize: 16)),
        ),
        SizedBox(
          width: 110,
          child: GanzzahlEingabefeld(
            textController: _stueckzahlController[zeile.id]!,
            onChanged: (String wert) => _beiStueckzahlGeaendert(zeile, wert),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 95,
          child: Text(
            _formatiereEuro(zwischensumme),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _baueLoseMuenzenGruppe() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'B) Lose Münzen',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Betrag',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: BetragCentEingabefeld(
                    textController: _loseMuenzenController,
                    onChanged: _beiLoseMuenzenGeaendert,
                    schriftgroesse: 20,
                    hinweisText: '0,00 €',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Zwischensumme: ${_formatiereEuro(_loseMuenzenCent)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _baueUmschlagGruppe() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'D) Umschläge',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (_umschlaege.isEmpty) const Text('Noch keine Umschläge erfasst.'),
            for (int i = 0; i < _umschlaege.length; i++) ...<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _umschlagBezeichnungController[i],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Label (optional)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (String wert) =>
                          _beiUmschlagBezeichnungGeaendert(i, wert),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: BetragCentEingabefeld(
                      textController: _umschlagBetragController[i],
                      onChanged: (String wert) =>
                          _beiUmschlagBetragGeaendert(i, wert),
                      schriftgroesse: 18,
                      hinweisText: '0,00 €',
                      labelText: 'Betrag €',
                    ),
                  ),
                  IconButton(
                    onPressed: () => _umschlagEntfernen(i),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Umschlag entfernen',
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _umschlagHinzufuegen,
                icon: const Icon(Icons.add),
                label: const Text('Umschlag hinzufügen'),
              ),
            ),
            Text(
              'Zwischensumme: ${_formatiereEuro(_umschlagSummeCent)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _baueZusammenfassung() {
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
            _baueZusammenfassungsZeile(
              'Kassenbestand gesamt',
              _formatiereEuro(_kassenbestandGesamtCent),
            ),
            _baueZusammenfassungsZeile(
              'Wechselgeld-Sollwert',
              _formatiereEuro(_wechselgeldSollwertCent),
            ),
            _baueZusammenfassungsZeile(
              'Barumsatz (bereinigt)',
              _formatiereEuro(_barumsatzBereinigtCent),
              hervorheben: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _baueZusammenfassungsZeile(
    String label,
    String wert, {
    bool hervorheben = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(
            wert,
            style: TextStyle(
              fontWeight: hervorheben ? FontWeight.w700 : FontWeight.w500,
              color: hervorheben && _barumsatzBereinigtCent < 0
                  ? Colors.red
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_laedt) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tagesabschluss – Schritt 1/4: Bargeldzählung'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: <Widget>[
                  _baueGruppe('A) Scheine', _scheine),
                  _baueLoseMuenzenGruppe(),
                  _baueGruppe('C) Rollen', _rollen),
                  _baueUmschlagGruppe(),
                  _baueZusammenfassung(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _weiterZuSchritt2,
                  child: const Text('Weiter zu Schritt 2'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagesabschlussSchritt2PlatzhalterSeite extends StatelessWidget {
  const TagesabschlussSchritt2PlatzhalterSeite({super.key});

  static const String routenName = '/closure-step-2-placeholder';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tagesabschluss – Schritt 2/4'),
      ),
      body: const Center(child: Text('Schritt 2 folgt')),
    );
  }
}
