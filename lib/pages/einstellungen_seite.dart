import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/services/dev_modus.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';

class EinstellungenSeite extends StatefulWidget {
  const EinstellungenSeite({super.key});

  static const String routenName = '/einstellungen';

  @override
  State<EinstellungenSeite> createState() => _EinstellungenSeiteState();
}

class _EinstellungenSeiteState extends State<EinstellungenSeite> {
  static const List<(String, String, int)> _s1ScheineFelder =
      <(String, String, int)>[
    ('note_100', '100 €', 0),
    ('note_50', '50 €', 8),
    ('note_20', '20 €', 4),
    ('note_10', '10 €', 29),
    ('note_5', '5 €', 13),
  ];

  static const List<(String, String, int)> _s1RollenFelder =
      <(String, String, int)>[
    ('roll_2e', '2 €', 0),
    ('roll_1e', '1 €', 0),
    ('roll_50c', '50 ct', 1),
    ('roll_20c', '20 ct', 1),
    ('roll_10c', '10 ct', 1),
    ('roll_5c', '5 ct', 0),
    ('roll_2c', '2 ct', 0),
    ('roll_1c', '1 ct', 0),
  ];

  static const List<(String, String, int)> _s1LoseMuenzFelder =
      <(String, String, int)>[
    ('coin_2e', '2 €', 3800),
    ('coin_1e', '1 €', 2500),
    ('coin_50c', '50 ct', 700),
    ('coin_20c', '20 ct', 40),
    ('coin_10c', '10 ct', 50),
    ('coin_5c', '5 ct', 0),
    ('coin_2c', '2 ct', 0),
    ('coin_1c', '1 ct', 0),
  ];

  static const int _umschlagSlots = 3;

  late final List<TextEditingController> _controllers;
  final Map<String, TextEditingController> _s1StueckzahlCtrl =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _s1LoseMuenzCtrl =
      <String, TextEditingController>{};
  final List<TextEditingController> _s1UmschlagBezeichnungCtrl =
      List<TextEditingController>.generate(
    _umschlagSlots,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _s1UmschlagBetragCtrl =
      List<TextEditingController>.generate(
    _umschlagSlots,
    (_) => TextEditingController(),
  );
  final TextEditingController _s2KinoSollCtrl = TextEditingController();
  final TextEditingController _s2BistroSollCtrl = TextEditingController();
  final TextEditingController _s2AusgabenCtrl = TextEditingController();
  final TextEditingController _s2EcBelegCtrl = TextEditingController();
  final TextEditingController _s2DifferenzCtrl = TextEditingController();

  bool _geladen = false;
  bool _devModusAktiv = false;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      KinoRepository.kinos.length,
      (_) => TextEditingController(),
    );
    for (final (String id, _, _) in [
      ..._s1ScheineFelder,
      ..._s1RollenFelder,
    ]) {
      _s1StueckzahlCtrl[id] = TextEditingController();
    }
    for (final (String id, _, _) in _s1LoseMuenzFelder) {
      _s1LoseMuenzCtrl[id] = TextEditingController();
    }
    _ladeWerte();
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final TextEditingController c in _s1StueckzahlCtrl.values) {
      c.dispose();
    }
    for (final TextEditingController c in _s1LoseMuenzCtrl.values) {
      c.dispose();
    }
    for (final TextEditingController c in _s1UmschlagBezeichnungCtrl) {
      c.dispose();
    }
    for (final TextEditingController c in _s1UmschlagBetragCtrl) {
      c.dispose();
    }
    _s2KinoSollCtrl.dispose();
    _s2BistroSollCtrl.dispose();
    _s2AusgabenCtrl.dispose();
    _s2EcBelegCtrl.dispose();
    _s2DifferenzCtrl.dispose();
    super.dispose();
  }

  Future<void> _ladeWerte() async {
    for (int i = 0; i < KinoRepository.kinos.length; i++) {
      final int cent = await LokalerSpeicher.ladeWechselgeldSollwertCent(
        KinoRepository.kinos[i].id,
      );
      if (!mounted) {
        return;
      }
      _controllers[i].text =
          TagesabschlussFormatierung.formatiereEuroEingabe(cent);
    }
    final bool devAktiv = await DevModus.istAktiv();
    if (!mounted) {
      return;
    }

    final Map<String, dynamic>? s1Daten =
        await LokalerSpeicher.ladeAutoFillSchritt1();
    if (!mounted) {
      return;
    }
    _setzeAutoFillSchritt1Controller(s1Daten);

    final Map<String, dynamic>? s2Daten =
        await LokalerSpeicher.ladeAutoFillSchritt2();
    if (!mounted) {
      return;
    }
    _setzeAutoFillSchritt2Controller(s2Daten);

    setState(() {
      _devModusAktiv = devAktiv;
      _geladen = true;
    });
  }

  void _setzeAutoFillSchritt1Controller(Map<String, dynamic>? daten) {
    final Map<String, dynamic>? stMap =
        daten?['stueckzahlen'] as Map<String, dynamic>?;
    final Map<String, dynamic>? lmMap =
        daten?['loseMuenzenNachArtCent'] as Map<String, dynamic>?;

    for (final (String id, _, int def) in [
      ..._s1ScheineFelder,
      ..._s1RollenFelder,
    ]) {
      final int wert = (stMap?[id] as num?)?.toInt() ?? def;
      _s1StueckzahlCtrl[id]!.text = wert != 0 ? wert.toString() : '';
    }

    for (final (String id, _, int def) in _s1LoseMuenzFelder) {
      final int cent = (lmMap?[id] as num?)?.toInt() ?? def;
      _s1LoseMuenzCtrl[id]!.text = cent != 0
          ? TagesabschlussFormatierung.formatiereEuroEingabe(cent)
          : '';
    }

    final List<dynamic>? umschlagRoh =
        daten?['umschlaege'] as List<dynamic>?;
    for (int i = 0; i < _umschlagSlots; i++) {
      final Map<String, dynamic>? slot =
          (umschlagRoh != null && i < umschlagRoh.length)
              ? umschlagRoh[i] as Map<String, dynamic>?
              : null;
      _s1UmschlagBezeichnungCtrl[i].text =
          (slot?['label'] as String?) ?? '';
      final int betrag = (slot?['amountCents'] as num?)?.toInt() ?? 0;
      _s1UmschlagBetragCtrl[i].text = betrag != 0
          ? TagesabschlussFormatierung.formatiereEuroEingabe(betrag)
          : '';
    }
  }

  void _setzeAutoFillSchritt2Controller(Map<String, dynamic>? daten) {
    final int kinoSoll = (daten?['kinoSollCent'] as num?)?.toInt() ?? 74900;
    final int bistroSoll =
        (daten?['bistroSollCent'] as num?)?.toInt() ?? 20280;
    final int ausgaben = (daten?['ausgabenCent'] as num?)?.toInt() ?? 0;
    final int ecBeleg = (daten?['ecBelegCent'] as num?)?.toInt() ?? 51390;
    final int differenz =
        (daten?['differenzAnfangsbestandCent'] as num?)?.toInt() ?? 0;

    _s2KinoSollCtrl.text = kinoSoll != 0
        ? TagesabschlussFormatierung.formatiereEuroEingabe(kinoSoll)
        : '';
    _s2BistroSollCtrl.text = bistroSoll != 0
        ? TagesabschlussFormatierung.formatiereEuroEingabe(bistroSoll)
        : '';
    _s2AusgabenCtrl.text = ausgaben != 0
        ? TagesabschlussFormatierung.formatiereEuroEingabe(ausgaben)
        : '';
    _s2EcBelegCtrl.text = ecBeleg != 0
        ? TagesabschlussFormatierung.formatiereEuroEingabe(ecBeleg)
        : '';
    _s2DifferenzCtrl.text = differenz != 0
        ? TagesabschlussFormatierung.formatiereEuroEingabe(differenz)
        : '';
  }

  Future<void> _onDevModusGeaendert(bool wert) async {
    await DevModus.setzen(wert);
    if (!mounted) {
      return;
    }
    setState(() {
      _devModusAktiv = wert;
    });
  }

  void _onChanged(int index, String text) {
    final String kinoId = KinoRepository.kinos[index].id;
    final int cent =
        int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    LokalerSpeicher.speichereWechselgeldSollwertCent(kinoId, cent);
  }

  Future<void> _speichereAutoFillSchritt1() async {
    final Map<String, int> stueckzahlen = <String, int>{};
    for (final String id in _s1StueckzahlCtrl.keys) {
      stueckzahlen[id] =
          int.tryParse(_s1StueckzahlCtrl[id]!.text.trim()) ?? 0;
    }
    final Map<String, int> loseMuenzen = <String, int>{};
    for (final String id in _s1LoseMuenzCtrl.keys) {
      loseMuenzen[id] = TagesabschlussBerechnung.parseCentZiffern(
        _s1LoseMuenzCtrl[id]!.text,
      );
    }
    final List<Map<String, dynamic>> umschlaege = <Map<String, dynamic>>[];
    for (int i = 0; i < _umschlagSlots; i++) {
      umschlaege.add(<String, dynamic>{
        'label': _s1UmschlagBezeichnungCtrl[i].text.trim(),
        'amountCents': TagesabschlussBerechnung.parseCentZiffern(
          _s1UmschlagBetragCtrl[i].text,
        ),
      });
    }
    await LokalerSpeicher.speichereAutoFillSchritt1(<String, dynamic>{
      'stueckzahlen': stueckzahlen,
      'loseMuenzenNachArtCent': loseMuenzen,
      'umschlaege': umschlaege,
    });
  }

  Future<void> _speichereAutoFillSchritt2() async {
    await LokalerSpeicher.speichereAutoFillSchritt2(<String, dynamic>{
      'kinoSollCent': TagesabschlussBerechnung.parseCentZiffern(
        _s2KinoSollCtrl.text,
      ),
      'bistroSollCent': TagesabschlussBerechnung.parseCentZiffern(
        _s2BistroSollCtrl.text,
      ),
      'ausgabenCent': TagesabschlussBerechnung.parseCentZiffern(
        _s2AusgabenCtrl.text,
      ),
      'ecBelegCent': TagesabschlussBerechnung.parseCentZiffern(
        _s2EcBelegCtrl.text,
      ),
      'differenzAnfangsbestandCent': TagesabschlussBerechnung.parseCentZiffern(
        _s2DifferenzCtrl.text,
      ),
    });
  }

  static const InputDecoration _zeilenDeko = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.only(bottom: 4),
  );

  Widget _baueStueckzahlZeile({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Focus(
              onFocusChange: (bool hasFocus) {
                if (hasFocus) controller.clear();
              },
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.right,
                decoration: _zeilenDeko,
                onChanged: (_) => onChanged(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueCentZeile({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Focus(
              onFocusChange: (bool hasFocus) {
                if (hasFocus) controller.clear();
              },
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  CentWaehrungsEingabeFormatter(),
                ],
                textAlign: TextAlign.right,
                decoration: _zeilenDeko,
                onChanged: (_) => onChanged(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueUmschlagZeile({
    required TextEditingController bezeichnungCtrl,
    required TextEditingController betragCtrl,
    required VoidCallback onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Focus(
              onFocusChange: (bool hasFocus) {
                if (hasFocus) bezeichnungCtrl.clear();
              },
              child: TextField(
                controller: bezeichnungCtrl,
                decoration: _zeilenDeko.copyWith(hintText: 'Bezeichnung'),
                onChanged: (_) => onChanged(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Focus(
              onFocusChange: (bool hasFocus) {
                if (hasFocus) betragCtrl.clear();
              },
              child: TextField(
                controller: betragCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  CentWaehrungsEingabeFormatter(),
                ],
                textAlign: TextAlign.right,
                decoration: _zeilenDeko,
                onChanged: (_) => onChanged(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueAutoFillInhalt() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Schritt 1',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Scheine (Anzahl)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            for (final (String id, String label, _) in _s1ScheineFelder)
              _baueStueckzahlZeile(
                label: label,
                controller: _s1StueckzahlCtrl[id]!,
                onChanged: _speichereAutoFillSchritt1,
              ),
            const Divider(height: 16),
            Text(
              'Münzrollen (Anzahl)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            for (final (String id, String label, _) in _s1RollenFelder)
              _baueStueckzahlZeile(
                label: label,
                controller: _s1StueckzahlCtrl[id]!,
                onChanged: _speichereAutoFillSchritt1,
              ),
            const Divider(height: 16),
            Text(
              'Lose Münzen (Betrag, Eingabe in Cent)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            for (final (String id, String label, _) in _s1LoseMuenzFelder)
              _baueCentZeile(
                label: label,
                controller: _s1LoseMuenzCtrl[id]!,
                onChanged: _speichereAutoFillSchritt1,
              ),
            const Divider(height: 16),
            Text(
              'Sonstige, z. B. Umschläge (Betrag, Eingabe in Cent)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            for (int i = 0; i < _umschlagSlots; i++)
              _baueUmschlagZeile(
                bezeichnungCtrl: _s1UmschlagBezeichnungCtrl[i],
                betragCtrl: _s1UmschlagBetragCtrl[i],
                onChanged: _speichereAutoFillSchritt1,
              ),
            const Divider(height: 20),
            const Text(
              'Schritt 2 (Betrag, Eingabe in Cent)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            _baueCentZeile(
              label: 'Kino SOLL',
              controller: _s2KinoSollCtrl,
              onChanged: _speichereAutoFillSchritt2,
            ),
            _baueCentZeile(
              label: 'Bistro SOLL',
              controller: _s2BistroSollCtrl,
              onChanged: _speichereAutoFillSchritt2,
            ),
            _baueCentZeile(
              label: 'Ausgaben',
              controller: _s2AusgabenCtrl,
              onChanged: _speichereAutoFillSchritt2,
            ),
            _baueCentZeile(
              label: 'EC-Beleg',
              controller: _s2EcBelegCtrl,
              onChanged: _speichereAutoFillSchritt2,
            ),
            _baueCentZeile(
              label: 'Differenz Anfangsbestand',
              controller: _s2DifferenzCtrl,
              onChanged: _speichereAutoFillSchritt2,
            ),
          ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_geladen) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: <Widget>[
          ...List<Widget>.generate(KinoRepository.kinos.length, (int i) {
            final Kino kino = KinoRepository.kinos[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        kino.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      BetragCentEingabefeld(
                        textController: _controllers[i],
                        onChanged: (String text) => _onChanged(i, text),
                        schriftgroesse: 18,
                        hinweisText: '200,00 €',
                        labelText: 'Wechselgeld-Sollwert',
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SwitchListTile(
                  title: const Text('Entwicklermodus'),
                  value: _devModusAktiv,
                  onChanged: _onDevModusGeaendert,
                  activeThumbColor: AppFarben.appBarRot,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'DEBUG devModusAktiv: $_devModusAktiv',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (_devModusAktiv) ...<Widget>[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _baueAutoFillInhalt(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
