import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/config/feature_flags.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/pages/einstellungen/ui/einstellungen_gruppen_orchestrierung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/services/abrechnung_speicher.dart';
import 'package:kino_bar_app/services/admin_session.dart';
import 'package:kino_bar_app/services/beleg_scan_service.dart';
import 'package:kino_bar_app/services/dev_modus.dart';
import 'package:kino_bar_app/services/getraenke_config_service.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:kino_bar_app/services/pwa_install_service.dart';
import 'package:kino_bar_app/services/sw_update_service.dart';
import 'package:kino_bar_app/services/wechselgeld_config_service.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/hinweis_snackbar.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EinstellungenSeite extends StatefulWidget {
  const EinstellungenSeite({super.key});

  static const String routenName = '/einstellungen';

  @override
  State<EinstellungenSeite> createState() => _EinstellungenSeiteState();
}

class _EinstellungenSeiteState extends State<EinstellungenSeite> {
  /// Vorbelegung fürs Dev-Autofill (Schritt 1, Scheine + Rollen).
  /// Reine Testdaten — id/bezeichnung kommen zentral aus
  /// StueckelungKonfiguration, nur diese Default-Stückzahlen sind
  /// hier lokal (kein Teil der eigentlichen Stückelungs-Konfiguration).
  static const Map<String, int> _s1StueckzahlAutoFillDefault = <String, int>{
    'note_100': 1,
    'note_50': 13,
    'note_20': 17,
    'note_10': 65,
    'note_5': 20,
    'roll_2e': 5,
    'roll_1e': 8,
  };

  /// Vorbelegung fürs Dev-Autofill (Schritt 1, lose Münzen in Cent).
  static const Map<String, int> _s1LoseMuenzAutoFillDefault = <String, int>{
    'coin_2e': 6400,
    'coin_1e': 5400,
    'coin_50c': 1900,
    'coin_20c': 1340,
    'coin_10c': 390,
  };

  static const int _umschlagSlots = 3;

  final EinstellungenGruppenOrchestrierung _gruppenOrchestrierung =
      const EinstellungenGruppenOrchestrierung();

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
  bool _apiUploadAktiv = false;
  bool _wechselgeldAufgeklappt = false;
  bool _getraenkelisteAufgeklappt = false;
  bool _devAufgeklappt = false;
  bool _devModusAktiv = true;
  bool _testwertAufgeklappt = false;
  bool _pwaInstallVerfuegbar = false;

  String? _standortModusKinoId;
  bool _adminStatusHaltenAktiv = false;

  String get _aktiveKinoKuerzel => _aktiveKinoIndex >= 0
      ? KinoRepository.kinos[_aktiveKinoIndex].kuerzel
      : '';

  /// Seit Run 424 aus Kino.hatBistro (vorher als
  /// kinoId!='kino_04'-Vergleich dupliziert, siehe auch
  /// tagesabschluss_schritt2_seite.dart._hatBistro).
  bool get _aktivesKinoHatBistro => _aktiveKinoIndex >= 0
      ? KinoRepository.kinos[_aktiveKinoIndex].hatBistro
      : true;

  List<String> _getraenkeliste = <String>[];
  final List<TextEditingController> _getraenkeController =
      <TextEditingController>[];
  final TextEditingController _neuesGetraenkCtrl = TextEditingController();
  final TextEditingController _apiUploadUrlCtrl = TextEditingController();
  final TextEditingController _belegScanUrlCtrl = TextEditingController();
  final TextEditingController _anthropicApiKeyCtrl = TextEditingController();
  final TextEditingController _locationIdCtrl = TextEditingController();
  final TextEditingController _flurbocashApiKeyCtrl = TextEditingController();
  late final FocusNode _neuesGetraenkFocus;
  late final FocusNode _locationIdFocus;
  late final FocusNode _flurbocashApiKeyFocus;

  @override
  void initState() {
    super.initState();
    for (final Kassenzeile z in StueckelungKonfiguration.alleStueckzahlZeilen) {
      _s1StueckzahlCtrl[z.id] = TextEditingController();
    }
    for (final Kassenzeile z in StueckelungKonfiguration.loseMuenzarten) {
      _s1LoseMuenzCtrl[z.id] = TextEditingController();
    }
    _neuesGetraenkFocus = FocusNode();
    _neuesGetraenkFocus.addListener(() {
      if (!_neuesGetraenkFocus.hasFocus) {
        _fuegeNeuesGetraenkEin();
      }
    });
    _locationIdFocus = FocusNode();
    _flurbocashApiKeyFocus = FocusNode();
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
    _apiUploadUrlCtrl.dispose();
    _belegScanUrlCtrl.dispose();
    _anthropicApiKeyCtrl.dispose();
    _locationIdCtrl.dispose();
    _locationIdFocus.dispose();
    _flurbocashApiKeyCtrl.dispose();
    _flurbocashApiKeyFocus.dispose();
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
    final bool apiUploadAktiv = await FeatureFlags.apiUploadAktiv();
    final bool devModusAktiv = await DevModus.istAktiv();
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
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String apiUploadUrl =
        speicher.getString(ApiUploadService.apiUploadUrlPrefKey) ?? '';
    final String belegScanUrl =
        speicher.getString(BelegScanService.belegScanUrlPrefKey) ?? '';
    final String anthropicApiKey =
        speicher.getString('anthropic_api_key') ?? '';
    final String? overrideLocationId = speicher.getString(
      ApiUploadService.locationIdPrefKey(_aktiveKinoId),
    );
    final String? overrideApiKey = speicher.getString(
      ApiUploadService.apiKeyPrefKey(_aktiveKinoId),
    );
    final String? standortModus = await LokalerSpeicher.ladeStandortModus();
    final bool adminStatusHaltenAktiv =
        speicher.getBool('admin_status_halten_aktiv') ?? false;
    if (!mounted) return;
    _apiUploadUrlCtrl.text = apiUploadUrl;
    _belegScanUrlCtrl.text = belegScanUrl;
    _anthropicApiKeyCtrl.text = anthropicApiKey;
    _locationIdCtrl.text = overrideLocationId ?? '';
    _flurbocashApiKeyCtrl.text = overrideApiKey ?? '';

    setState(() {
      _apiUploadAktiv = apiUploadAktiv;
      _devModusAktiv = devModusAktiv;
      _getraenkeliste = getraenkeliste;
      _geladen = true;
      _standortModusKinoId = standortModus;
      _adminStatusHaltenAktiv = adminStatusHaltenAktiv;
      if (adminStatusHaltenAktiv && AdminSession.entsperrt) {
        _devAufgeklappt = true;
      }
    });
  }

  Future<void> _onStandortModusGeaendert(String? kinoId) async {
    await LokalerSpeicher.speichereStandortModus(kinoId);
    if (!mounted) return;
    setState(() => _standortModusKinoId = kinoId);
  }

  Future<void> _onAdminStatusHaltenGeaendert(bool wert) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setBool('admin_status_halten_aktiv', wert);
    if (!mounted) return;
    setState(() => _adminStatusHaltenAktiv = wert);
  }

  Future<void> _onDevModusGeaendert(bool wert) async {
    await DevModus.setzen(wert);
    if (!mounted) return;
    setState(() => _devModusAktiv = wert);
  }

  void _setzeAutoFillSchritt1Controller(Map<String, dynamic>? daten) {
    final Map<String, dynamic>? stMap =
        daten?['stueckzahlen'] as Map<String, dynamic>?;
    final Map<String, dynamic>? lmMap =
        daten?['loseMuenzenNachArtCent'] as Map<String, dynamic>?;

    for (final Kassenzeile z in StueckelungKonfiguration.alleStueckzahlZeilen) {
      final int def = _s1StueckzahlAutoFillDefault[z.id] ?? 0;
      final int wert = (stMap?[z.id] as num?)?.toInt() ?? def;
      _s1StueckzahlCtrl[z.id]!.text = wert != 0 ? wert.toString() : '';
    }

    for (final Kassenzeile z in StueckelungKonfiguration.loseMuenzarten) {
      final int def = _s1LoseMuenzAutoFillDefault[z.id] ?? 0;
      final int cent = (lmMap?[z.id] as num?)?.toInt() ?? def;
      _s1LoseMuenzCtrl[z.id]!.text = cent != 0
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

  Future<void> _onApiUploadGeaendert(bool wert) async {
    await FeatureFlags.apiUploadSetzen(wert);
    if (!mounted) return;
    setState(() {
      _apiUploadAktiv = wert;
    });
  }

  Future<void> _speichereApiUploadKonfig() async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString(
      ApiUploadService.apiUploadUrlPrefKey,
      _apiUploadUrlCtrl.text.trim(),
    );
  }

  Future<void> _speichereBelegScanUrl() async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString(
        BelegScanService.belegScanUrlPrefKey, _belegScanUrlCtrl.text.trim());
  }

  Future<void> _speichereAnthropicApiKey() async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString(
        'anthropic_api_key', _anthropicApiKeyCtrl.text.trim());
  }

  Future<void> _speichereLocationId() async {
    final String wert = _locationIdCtrl.text.trim();
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String key = ApiUploadService.locationIdPrefKey(_aktiveKinoId);
    if (wert.isEmpty) {
      await speicher.remove(key);
    } else {
      await speicher.setString(key, wert);
    }
  }

  Future<void> _speichereFlurbocashApiKey() async {
    final String wert = _flurbocashApiKeyCtrl.text.trim();
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String key = ApiUploadService.apiKeyPrefKey(_aktiveKinoId);
    if (wert.isEmpty) {
      await speicher.remove(key);
    } else {
      await speicher.setString(key, wert);
    }
  }

  Future<void> _zeigePinDialog() async {
    final String? eingegebenerPin = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => const _PinDialog(),
    );
    if (!mounted) return;
    if (eingegebenerPin == null) return;
    if (eingegebenerPin == '1929') {
      AdminSession.entsperrt = true;
      setState(() => _devAufgeklappt = true);
    } else {
      zeigeHinweisSnackBar(context, 'Falscher PIN');
    }
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
    final Map<String, dynamic>? bestehend =
        await LokalerSpeicher.ladeAutoFillSchritt2(_aktiveKinoId);
    final Map<String, dynamic> neu = <String, dynamic>{
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
    };
    await LokalerSpeicher.speichereAutoFillSchritt2(
      _aktiveKinoId,
      LokalerSpeicher.autoFillSchritt2MitBestehendenZahlungsarten(
        neu,
        bestehend,
      ),
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
    zeigeHinweisSnackBar(context, 'Standardwerte gesetzt.');
  }

  static const InputDecoration _zeilenDeko = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.only(bottom: 4),
  );

  Widget _baueZahlenZeile({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
    required double feldBreite,
    required List<TextInputFormatter> inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          SizedBox(
            width: feldBreite,
            child: Focus(
              onFocusChange: (bool hasFocus) {
                if (hasFocus) controller.clear();
              },
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: inputFormatters,
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

  Widget _baueStueckzahlZeile({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    return _baueZahlenZeile(
      label: label,
      controller: controller,
      onChanged: onChanged,
      feldBreite: 60,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Widget _baueCentZeile({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    return _baueZahlenZeile(
      label: label,
      controller: controller,
      onChanged: onChanged,
      feldBreite: 80,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        CentWaehrungsEingabeFormatter(),
      ],
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
            for (final Kassenzeile z in StueckelungKonfiguration.scheine)
              _baueStueckzahlZeile(
                label: z.bezeichnung,
                controller: _s1StueckzahlCtrl[z.id]!,
                onChanged: _speichereAutoFillSchritt1,
              ),
            const Divider(height: 16),
            Text(
              'Münzrollen (Anzahl)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            for (final Kassenzeile z in StueckelungKonfiguration.rollen)
              _baueStueckzahlZeile(
                label: z.bezeichnung,
                controller: _s1StueckzahlCtrl[z.id]!,
                onChanged: _speichereAutoFillSchritt1,
              ),
            const Divider(height: 16),
            Text(
              'Lose Münzen (Betrag, Eingabe in Cent)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            for (final Kassenzeile z in StueckelungKonfiguration.loseMuenzarten)
              _baueCentZeile(
                label: z.bezeichnung,
                controller: _s1LoseMuenzCtrl[z.id]!,
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
              label: _aktivesKinoHatBistro ? 'Kino SOLL' : 'Gesamt SOLL',
              controller: _s2KinoSollCtrl,
              onChanged: _speichereAutoFillSchritt2,
            ),
            if (_aktivesKinoHatBistro)
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

  void _fuegeGetraenkNachIndexEin(int index) {
    setState(() {
      _getraenkeliste.insert(index + 1, '');
      _getraenkeController.insert(index + 1, TextEditingController());
    });
    _speichereGetraenkeliste();
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
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _getraenkeliste.length,
          onReorderItem: _onGetraenkeReorder,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              key: ObjectKey(_getraenkeController[index]),
              children: <Widget>[
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle, color: Colors.grey),
                ),
                Expanded(
                  child: TextField(
                    controller: _getraenkeController[index],
                    maxLength: 25,
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
                  icon: const Icon(Icons.add),
                  tooltip: 'Getränk darunter einfügen',
                  onPressed: () => _fuegeGetraenkNachIndexEin(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _loescheGetraenk(index),
                ),
              ],
            );
          },
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

    final EinstellungenSectionWidgets einstellungenSections =
        _gruppenOrchestrierung.baueSections(
      kinoKuerzel: _aktiveKinoKuerzel,
      getraenkelisteAufgeklappt: _getraenkelisteAufgeklappt,
      onToggleGetraenkelisteAufgeklappt: () => setState(
        () => _getraenkelisteAufgeklappt = !_getraenkelisteAufgeklappt,
      ),
      getraenkelisteInhalt: _baueGetraenkelisteInhalt(),
      pwaInstallVerfuegbar: _pwaInstallVerfuegbar,
      onPwaInstall: _starteInstallation,
      belegScanUrlController: _belegScanUrlCtrl,
      anthropicApiKeyController: _anthropicApiKeyCtrl,
      onBelegScanUrlGeaendert: _speichereBelegScanUrl,
      onAnthropicApiKeyGeaendert: _speichereAnthropicApiKey,
      standortModusKinoId: _standortModusKinoId,
      onStandortModusGeaendert: _onStandortModusGeaendert,
      adminStatusHaltenAktiv: _adminStatusHaltenAktiv,
      onAdminStatusHaltenGeaendert: _onAdminStatusHaltenGeaendert,
      wgController: _wgCtrl,
      wechselgeldAufgeklappt: _wechselgeldAufgeklappt,
      onToggleWechselgeldAufgeklappt: () => setState(
        () => _wechselgeldAufgeklappt = !_wechselgeldAufgeklappt,
      ),
      aktiveKinoIndex: _aktiveKinoIndex,
      aktiveKinoName: _aktiveKinoName,
      onWgChanged: _onWgChanged,
      apiUploadAktiv: _apiUploadAktiv,
      onApiUploadGeaendert: _onApiUploadGeaendert,
      apiUploadUrlController: _apiUploadUrlCtrl,
      onApiUploadUrlGeaendert: _speichereApiUploadKonfig,
      locationIdController: _locationIdCtrl,
      locationIdFocusNode: _locationIdFocus,
      onLocationIdGeaendert: _speichereLocationId,
      flurbocashApiKeyController: _flurbocashApiKeyCtrl,
      flurbocashApiKeyFocusNode: _flurbocashApiKeyFocus,
      onFlurbocashApiKeyGeaendert: _speichereFlurbocashApiKey,
      devModusAktiv: _devModusAktiv,
      onDevModusGeaendert: _onDevModusGeaendert,
      testwertAufgeklappt: _testwertAufgeklappt,
      onToggleTestwertAufgeklappt: () => setState(
        () => _testwertAufgeklappt = !_testwertAufgeklappt,
      ),
      onSetzeStandardTestwerte: _setzeStandardTestwerte,
      autoFillInhalt: _baueAutoFillInhalt(),
    );

    return TagesabschlussScaffold(
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
      child: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: <Widget>[
          einstellungenSections.getraenkeliste,
          if (einstellungenSections.pwaInstall != null) ...<Widget>[
            const SizedBox(height: 4),
            einstellungenSections.pwaInstall!,
          ],
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text(
                    'Admin',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(
                    _devAufgeklappt
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                  onTap: () {
                    if (_devAufgeklappt) {
                      setState(() => _devAufgeklappt = false);
                    } else {
                      _zeigePinDialog();
                    }
                  },
                ),
                if (_devAufgeklappt) ...<Widget>[
                  const Divider(height: 1),
                  einstellungenSections.standortAdmin,
                  einstellungenSections.wechselgeld,
                  einstellungenSections.flurbocash,
                  einstellungenSections.belegscan,
                  einstellungenSections.devModus,
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: reloadPage,
              child: const Text('App neu laden'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppFarben.differenzNegativ,
                foregroundColor: Colors.white,
              ),
              onPressed: _resetHeutigeAbrechnung,
              child: const Text('Heutige Abrechnung zurücksetzen (Test)'),
            ),
          ),
        ],
      ),
    );
  }

  /// Testphase: löscht alle heutigen Abrechnungsdaten (alle drei Schritte
  /// sowie eine bereits finalisierte Abrechnung) des aktuell gewählten
  /// Standorts, inklusive Gesendet-Status. Absichtlich ungeschützt neben
  /// "App neu laden" statt im PIN-Admin-Bereich, siehe Run-397-Absprache.
  Future<void> _resetHeutigeAbrechnung() async {
    final bool? bestaetigt = await zeigeBestaetigungsDialog(
      context,
      titel: 'Heutige Abrechnung zurücksetzen?',
      inhalt:
          'Löscht unwiderruflich alle heutigen Abrechnungsdaten '
          '(Schritt 1–3) sowie den Gesendet-Status für '
          '$_aktiveKinoKuerzel. Nur für die Testphase gedacht.',
      bestaetigenText: 'Zurücksetzen',
    );
    if (bestaetigt != true || !mounted) {
      return;
    }
    final String kinoId = _aktiveKinoId;
    await AbrechnungSpeicher.loesche(kinoId);
    await LokalerSpeicher.loescheSchritt2Entwurf(kinoId);
    await LokalerSpeicher.loescheWechselgeldZaehlEntwurf(kinoId);
    await LokalerSpeicher.loescheFinalenTagesabschluss(
      kinoId,
      DatumsHelper.logischerAbrechnungsTag(),
    );
    await LokalerSpeicher.loescheSendeBestaetigung(kinoId);
    if (!mounted) {
      return;
    }
    zeigeHinweisSnackBar(context, 'Heutige Abrechnung zurückgesetzt.');
  }
}

// Eigenes StatefulWidget statt lokaler TextEditingController in
// _zeigePinDialog(): der Controller muss in genau dem Element-Dispose
// entsorgt werden, das auch das Feld erzeugt hat. showDialog() liefert
// seinen Rückgabewert bereits mit Navigator.pop() zurück, bevor die
// Schließen-Animation des Dialogs fertig ist — ein sofortiges
// pinCtrl.dispose() direkt nach dem await lief dem noch aktiven
// TextField hinterher und führte zu "TextEditingController was used
// after being disposed" mit Folgeabsturz ('_dependents.isEmpty').
class _PinDialog extends StatefulWidget {
  const _PinDialog();

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final TextEditingController _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Admin'),
      content: TextField(
        controller: _pinCtrl,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 4,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'PIN', counterText: ''),
        onChanged: (String value) {
          if (value.length == 4) {
            Navigator.of(context).pop(value);
          }
        },
        onSubmitted: (String value) => Navigator.of(context).pop(value),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_pinCtrl.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
