import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/services/dev_modus.dart';
import 'package:kino_bar_app/services/getraenke_config_service.dart';
import 'package:kino_bar_app/services/pwa_install_service.dart';
import 'package:kino_bar_app/services/wechselgeld_config_service.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/haus_button.dart';

class EinstellungenSeite extends StatefulWidget {
  const EinstellungenSeite({super.key});

  static const String routenName = '/einstellungen';

  @override
  State<EinstellungenSeite> createState() => _EinstellungenSeiteState();
}

class _EinstellungenSeiteState extends State<EinstellungenSeite> {
  static const List<(String, String, int)> _s1ScheineFelder =
      <(String, String, int)>[
    ('note_100', '100 €', 1),
    ('note_50', '50 €', 13),
    ('note_20', '20 €', 17),
    ('note_10', '10 €', 65),
    ('note_5', '5 €', 20),
  ];

  static const List<(String, String, int)> _s1RollenFelder =
      <(String, String, int)>[
    ('roll_2e', '2 €', 5),
    ('roll_1e', '1 €', 8),
    ('roll_50c', '50 ct', 0),
    ('roll_20c', '20 ct', 0),
    ('roll_10c', '10 ct', 0),
    ('roll_5c', '5 ct', 0),
    ('roll_2c', '2 ct', 0),
    ('roll_1c', '1 ct', 0),
  ];

  static const List<(String, String, int)> _s1LoseMuenzFelder =
      <(String, String, int)>[
    ('coin_2e', '2 €', 6400),
    ('coin_1e', '1 €', 5400),
    ('coin_50c', '50 ct', 1900),
    ('coin_20c', '20 ct', 1340),
    ('coin_10c', '10 ct', 390),
    ('coin_5c', '5 ct', 0),
    ('coin_2c', '2 ct', 0),
    ('coin_1c', '1 ct', 0),
  ];

  static const int _umschlagSlots = 3;

  final TextEditingController _wgCtrl = TextEditingController();
  int _aktiveKinoIndex = -1;
  String _aktiveKinoName = '';
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

  String _aktiveKinoId = 'kino_01';
  bool _geladen = false;
  bool _devModusAktiv = false;
  bool _wechselgeldAufgeklappt = false;
  bool _getraenkelisteAufgeklappt = false;
  bool _testwertAufgeklappt = false;
  bool _pwaInstallVerfuegbar = false;

  List<String> _getraenkeliste = <String>[];
  final List<TextEditingController> _getraenkeController =
      <TextEditingController>[];
  final TextEditingController _neuesGetraenkCtrl = TextEditingController();
  late final FocusNode _neuesGetraenkFocus;

  @override
  void initState() {
    super.initState();
    for (final (String id, _, _) in [
      ..._s1ScheineFelder,
      ..._s1RollenFelder,
    ]) {
      _s1StueckzahlCtrl[id] = TextEditingController();
    }
    for (final (String id, _, _) in _s1LoseMuenzFelder) {
      _s1LoseMuenzCtrl[id] = TextEditingController();
    }
    _neuesGetraenkFocus = FocusNode();
    _neuesGetraenkFocus.addListener(() {
      if (!_neuesGetraenkFocus.hasFocus) {
        _fuegeNeuesGetraenkEin();
      }
    });
    _pwaInstallVerfuegbar = pwaInstallVerfuegbar;
    _ladeWerte();
  }

  @override
  void dispose() {
    _wgCtrl.dispose();
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
    for (final TextEditingController c in _getraenkeController) {
      c.dispose();
    }
    _neuesGetraenkCtrl.dispose();
    _neuesGetraenkFocus.dispose();
    super.dispose();
  }

  Future<void> _ladeWerte() async {
    final String? aktivId = await LokalerSpeicher.ladeAktiveKinoId();
    final int aktiveIndex = aktivId != null
        ? KinoRepository.kinos.indexWhere((Kino k) => k.id == aktivId)
        : -1;
    if (!mounted) return;
    if (aktivId != null) _aktiveKinoId = aktivId;
    if (aktiveIndex >= 0) {
      final Kino aktiveKino = KinoRepository.kinos[aktiveIndex];
      int wgCent =
          await LokalerSpeicher.ladeWechselgeldSollwertCent(aktiveKino.id);
      if (wgCent == 0) {
        wgCent =
            await WechselgeldConfigService().getWechselgeldBetrag(aktiveKino.name);
      }
      if (!mounted) return;
      _wgCtrl.text = wgCent != 0
          ? TagesabschlussFormatierung.formatiereEuroEingabe(wgCent)
          : '';
      _aktiveKinoIndex = aktiveIndex;
      _aktiveKinoName = aktiveKino.name;
    }
    final bool devAktiv = await DevModus.istAktiv();
    if (!mounted) {
      return;
    }

    final Map<String, dynamic>? s1Daten =
        await LokalerSpeicher.ladeAutoFillSchritt1(_aktiveKinoId);
    if (!mounted) {
      return;
    }
    _setzeAutoFillSchritt1Controller(s1Daten);

    final Map<String, dynamic>? s2Daten =
        await LokalerSpeicher.ladeAutoFillSchritt2(_aktiveKinoId);
    if (!mounted) {
      return;
    }
    _setzeAutoFillSchritt2Controller(s2Daten);

    final List<String> getraenkeliste =
        await GetraenkeConfigService(kinoId: _aktiveKinoId).loadLocal();
    if (!mounted) {
      return;
    }
    for (final TextEditingController c in _getraenkeController) {
      c.dispose();
    }
    _getraenkeController.clear();
    for (final String name in getraenkeliste) {
      _getraenkeController.add(TextEditingController(text: name));
    }
    setState(() {
      _devModusAktiv = devAktiv;
      _getraenkeliste = getraenkeliste;
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
    final int kinoSoll = (daten?['kinoSollCent'] as num?)?.toInt() ?? 110000;
    final int bistroSoll =
        (daten?['bistroSollCent'] as num?)?.toInt() ?? 52630;
    final int ausgaben = (daten?['ausgabenCent'] as num?)?.toInt() ?? 0;
    final int ecBeleg = (daten?['ecBelegCent'] as num?)?.toInt() ?? 57820;
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

  void _onWgChanged(String text) {
    if (_aktiveKinoIndex < 0) return;
    final String kinoId = KinoRepository.kinos[_aktiveKinoIndex].id;
    final int cent =
        int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    LokalerSpeicher.speichereWechselgeldSollwertCent(kinoId, cent);
    setState(() {});
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
    await LokalerSpeicher.speichereAutoFillSchritt1(
      _aktiveKinoId,
      <String, dynamic>{
        'stueckzahlen': stueckzahlen,
        'loseMuenzenNachArtCent': loseMuenzen,
        'umschlaege': umschlaege,
      },
    );
  }

  Future<void> _speichereAutoFillSchritt2() async {
    await LokalerSpeicher.speichereAutoFillSchritt2(
      _aktiveKinoId,
      <String, dynamic>{
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
      },
    );
  }

  Map<String, dynamic> _kinoSchritt1Testwerte() {
    switch (_aktiveKinoId) {
      case 'kino_03':
        return <String, dynamic>{
          'stueckzahlen': <String, dynamic>{
            'note_100': 0, 'note_50': 8, 'note_20': 7, 'note_10': 30,
            'note_5': 14,
            'roll_2e': 1, 'roll_1e': 1, 'roll_50c': 1, 'roll_20c': 0,
            'roll_10c': 1, 'roll_5c': 0, 'roll_2c': 0, 'roll_1c': 0,
          },
          'loseMuenzenNachArtCent': <String, dynamic>{
            'coin_2e': 1400, 'coin_1e': 1800, 'coin_50c': 700,
            'coin_20c': 680, 'coin_10c': 290,
            'coin_5c': 0, 'coin_2c': 0, 'coin_1c': 0,
          },
          'umschlaege': <dynamic>[
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
          ],
        };
      case 'kino_04':
        return <String, dynamic>{
          'stueckzahlen': <String, dynamic>{
            'note_100': 0, 'note_50': 1, 'note_20': 6, 'note_10': 9,
            'note_5': 11,
            'roll_2e': 2, 'roll_1e': 1, 'roll_50c': 1, 'roll_20c': 1,
            'roll_10c': 1, 'roll_5c': 0, 'roll_2c': 0, 'roll_1c': 0,
          },
          'loseMuenzenNachArtCent': <String, dynamic>{
            'coin_2e': 2200, 'coin_1e': 2900, 'coin_50c': 1550,
            'coin_20c': 360, 'coin_10c': 390,
            'coin_5c': 0, 'coin_2c': 0, 'coin_1c': 0,
          },
          'umschlaege': <dynamic>[
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
          ],
        };
      default:
        return <String, dynamic>{
          'stueckzahlen': <String, dynamic>{
            'note_100': 1, 'note_50': 13, 'note_20': 17, 'note_10': 65,
            'note_5': 20,
            'roll_2e': 5, 'roll_1e': 8, 'roll_50c': 0, 'roll_20c': 0,
            'roll_10c': 0, 'roll_5c': 0, 'roll_2c': 0, 'roll_1c': 0,
          },
          'loseMuenzenNachArtCent': <String, dynamic>{
            'coin_2e': 6400, 'coin_1e': 5400, 'coin_50c': 1900,
            'coin_20c': 1340, 'coin_10c': 390,
            'coin_5c': 0, 'coin_2c': 0, 'coin_1c': 0,
          },
          'umschlaege': <dynamic>[
            <String, dynamic>{'label': 'Couverts', 'amountCents': 380},
            <String, dynamic>{'label': '', 'amountCents': 0},
            <String, dynamic>{'label': '', 'amountCents': 0},
          ],
        };
    }
  }

  Map<String, dynamic> _kinoSchritt2Testwerte() {
    switch (_aktiveKinoId) {
      case 'kino_03':
        return <String, dynamic>{
          'kinoSollCent': 69000,
          'bistroSollCent': 24930,
          'ausgabenCent': 0,
          'ecBelegCent': 38160,
          'differenzAnfangsbestandCent': 0,
        };
      case 'kino_04':
        return <String, dynamic>{
          'kinoSollCent': 22350,
          'bistroSollCent': 0,
          'ausgabenCent': 0,
          'ecBelegCent': 7750,
          'differenzAnfangsbestandCent': 0,
        };
      default:
        return <String, dynamic>{
          'kinoSollCent': 110000,
          'bistroSollCent': 52630,
          'ausgabenCent': 0,
          'ecBelegCent': 57820,
          'differenzAnfangsbestandCent': 0,
        };
    }
  }

  int _kinoStandardWechselgeldCent() {
    switch (_aktiveKinoId) {
      case 'kino_03':
        return 50000;
      case 'kino_04':
        return 40000;
      default:
        return 140000;
    }
  }

  Future<void> _setzeStandardTestwerte() async {
    final Map<String, dynamic> s1 = _kinoSchritt1Testwerte();
    final Map<String, dynamic> stMap =
        s1['stueckzahlen'] as Map<String, dynamic>;
    for (final String id in _s1StueckzahlCtrl.keys) {
      final int wert = (stMap[id] as num?)?.toInt() ?? 0;
      _s1StueckzahlCtrl[id]!.text = wert != 0 ? wert.toString() : '';
    }

    final Map<String, dynamic> lmMap =
        s1['loseMuenzenNachArtCent'] as Map<String, dynamic>;
    for (final String id in _s1LoseMuenzCtrl.keys) {
      final int cent = (lmMap[id] as num?)?.toInt() ?? 0;
      _s1LoseMuenzCtrl[id]!.text = cent != 0
          ? TagesabschlussFormatierung.formatiereEuroEingabe(cent)
          : '';
    }

    final List<dynamic> umschlagListe =
        s1['umschlaege'] as List<dynamic>;
    for (int i = 0; i < _umschlagSlots; i++) {
      if (i < umschlagListe.length) {
        final Map<String, dynamic> slot =
            umschlagListe[i] as Map<String, dynamic>;
        _s1UmschlagBezeichnungCtrl[i].text = (slot['label'] as String?) ?? '';
        final int betrag = (slot['amountCents'] as num?)?.toInt() ?? 0;
        _s1UmschlagBetragCtrl[i].text = betrag != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(betrag)
            : '';
      } else {
        _s1UmschlagBezeichnungCtrl[i].text = '';
        _s1UmschlagBetragCtrl[i].text = '';
      }
    }

    final Map<String, dynamic> s2 = _kinoSchritt2Testwerte();
    final int kinoSoll = s2['kinoSollCent'] as int;
    final int bistroSoll = s2['bistroSollCent'] as int;
    final int ausgaben = s2['ausgabenCent'] as int;
    final int ecBeleg = s2['ecBelegCent'] as int;
    final int differenz = s2['differenzAnfangsbestandCent'] as int;

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

    final int wgCent = _kinoStandardWechselgeldCent();
    if (_aktiveKinoIndex >= 0) {
      _wgCtrl.text = TagesabschlussFormatierung.formatiereEuroEingabe(wgCent);
    }

    await _speichereAutoFillSchritt1();
    await _speichereAutoFillSchritt2();
    if (_aktiveKinoIndex >= 0) {
      await LokalerSpeicher.speichereWechselgeldSollwertCent(
        KinoRepository.kinos[_aktiveKinoIndex].id,
        wgCent,
      );
    }

    if (!mounted) {
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Standardwerte gesetzt.')),
    );
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
              'Scheine (Anzahl der Scheine)',
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
            if (_aktiveKinoId != 'kino_04')
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

  Future<void> _speichereGetraenkeliste() async {
    await GetraenkeConfigService(kinoId: _aktiveKinoId).saveLocal(_getraenkeliste);
  }

  void _fuegeGetraenkHinzu() {
    setState(() {
      _getraenkeliste.add('');
      _getraenkeController.add(TextEditingController());
    });
    _speichereGetraenkeliste();
  }

  Future<void> _zeigeStandardListeHilfe() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Standard-Liste herunterladen'),
          content: const Text(
            'Lädt die von der Kinoleitung gepflegte Getränkeliste herunter '
            'und ersetzt deine aktuelle Liste. Eigene Anpassungen gehen '
            'dabei verloren — du kannst sie danach hier wieder vornehmen.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _ladeStandardListe() async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Liste wirklich ersetzen?'),
          content: const Text(
            'Deine aktuelle Liste wird durch die Standard-Liste ersetzt. '
            'Eigene Bezeichnungen gehen dabei verloren.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Herunterladen'),
            ),
          ],
        );
      },
    );
    if (bestaetigt != true || !mounted) return;
    try {
      await GetraenkeConfigService(kinoId: _aktiveKinoId).updateFromRemote();
      if (!mounted) return;
      final List<String> neueListe = await GetraenkeConfigService(kinoId: _aktiveKinoId).loadLocal();
      if (!mounted) return;
      for (final TextEditingController c in _getraenkeController) {
        c.dispose();
      }
      _getraenkeController.clear();
      setState(() {
        _getraenkeliste = neueListe;
        for (final String name in neueListe) {
          _getraenkeController.add(TextEditingController(text: name));
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download fehlgeschlagen. Bitte Verbindung prüfen.'),
        ),
      );
    }
  }

  Future<void> _starteInstallation() async {
    await pwaInstallStarten();
    if (!mounted) return;
    setState(() {
      _pwaInstallVerfuegbar = pwaInstallVerfuegbar;
    });
  }

  void _fuegeNeuesGetraenkEin() {
    final String name = _neuesGetraenkCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _getraenkeliste.add(name);
      _getraenkeController.add(TextEditingController(text: name));
    });
    _neuesGetraenkCtrl.clear();
    _speichereGetraenkeliste();
  }

  void _loescheGetraenk(int index) {
    _getraenkeController[index].dispose();
    setState(() {
      _getraenkeliste.removeAt(index);
      _getraenkeController.removeAt(index);
    });
    _speichereGetraenkeliste();
  }

  void _onGetraenkeReorder(int oldIndex, int newIndex) {
    setState(() {
      final String item = _getraenkeliste.removeAt(oldIndex);
      _getraenkeliste.insert(newIndex, item);
      final TextEditingController ctrl =
          _getraenkeController.removeAt(oldIndex);
      _getraenkeController.insert(newIndex, ctrl);
    });
    _speichereGetraenkeliste();
  }

  Widget _baueGetraenkelisteInhalt() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            TextButton(
              onPressed: _ladeStandardListe,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Standard-Liste herunterladen'),
            ),
            IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _zeigeStandardListeHilfe,
              icon: const Icon(Icons.help_outline),
            ),
          ],
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _getraenkeliste.length,
          onReorderItem: _onGetraenkeReorder,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              key: ObjectKey(_getraenkeController[index]),
              children: <Widget>[
                const Icon(Icons.drag_handle, color: Colors.grey),
                Expanded(
                  child: TextField(
                    controller: _getraenkeController[index],
                    maxLength: 20,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      hintText: 'Getränk',
                      counterText: '',
                    ),
                    onChanged: (String value) {
                      _getraenkeliste[index] = value;
                      _speichereGetraenkeliste();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _loescheGetraenk(index),
                ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _fuegeGetraenkHinzu,
              child: const Text('+ Getränk hinzufügen'),
            ),
          ),
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
      backgroundColor: AppFarben.seitenHintergrund,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_aktiveKinoName.isNotEmpty)
              Text(
                _aktiveKinoName,
                style: const TextStyle(fontSize: 14),
              ),
            const Text(
              'Einstellungen',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _hausFooter(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'Wechselgeldbestand',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (_wgCtrl.text.isNotEmpty)
                          Text(
                            _wgCtrl.text,
                            style: const TextStyle(fontSize: 11),
                          ),
                        const SizedBox(width: 4),
                        Icon(
                          _wechselgeldAufgeklappt
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                      ],
                    ),
                    onTap: () => setState(
                      () => _wechselgeldAufgeklappt = !_wechselgeldAufgeklappt,
                    ),
                  ),
                  if (_wechselgeldAufgeklappt && _aktiveKinoIndex >= 0) ...<Widget>[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            'Wechselgeld $_aktiveKinoName',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _wgCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                suffixText: '€',
                              ),
                              onTap: () {
                                if (_wgCtrl.text == '0') _wgCtrl.clear();
                              },
                              onChanged: _onWgChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'Getränkeliste',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Icon(
                      _getraenkelisteAufgeklappt
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    onTap: () => setState(
                      () => _getraenkelisteAufgeklappt =
                          !_getraenkelisteAufgeklappt,
                    ),
                  ),
                  if (_getraenkelisteAufgeklappt) ...<Widget>[
                    const Divider(height: 1),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        'Reihenfolge = Regal-Reihenfolge',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: _baueGetraenkelisteInhalt(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_pwaInstallVerfuegbar) ...<Widget>[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'App installieren',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Füge die App zum Home-Bildschirm hinzu, um sie wie eine native App zu nutzen.',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _starteInstallation,
                          child: const Text('App installieren'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                if (_devModusAktiv)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton.icon(
                          onPressed: () => setState(
                            () =>
                                _testwertAufgeklappt = !_testwertAufgeklappt,
                          ),
                          icon: Icon(
                            _testwertAufgeklappt
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          label: const Text('Testwerte'),
                        ),
                      ],
                    ),
                  ),
                if (_devModusAktiv && _testwertAufgeklappt) ...<Widget>[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _setzeStandardTestwerte,
                        child: const Text('Standard-Testwerte übernehmen'),
                      ),
                    ),
                  ),
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

  Widget _hausFooter(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        border: Border(top: BorderSide(color: Color(0x52FFFFFF))),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(12, 4, 12, 4 + bottomPadding),
      child: const SizedBox(
        height: 36,
        child: Align(
          alignment: Alignment.centerLeft,
          child: HausButton(),
        ),
      ),
    );
  }
}
