import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:kino_bar_app/services/dev_modus.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

class TagesabschlussSchritt2Argumente {
  const TagesabschlussSchritt2Argumente({
    required this.kinoId,
    required this.kinoName,
    required this.scheineCent,
    required this.loseMuenzenCent,
    required this.rollenCent,
    required this.umschlaegeCent,
    required this.wechselgeldSollwertCent,
    required this.barBestandAbzglWechselgeldCent,
    required this.stueckzahlen,
    required this.loseMuenzenNachArtCent,
    this.umschlaege,
  });

  final String kinoId;
  final String kinoName;
  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int wechselgeldSollwertCent;
  final int barBestandAbzglWechselgeldCent;
  final Map<String, int> stueckzahlen;
  final Map<String, int> loseMuenzenNachArtCent;
  final List<UmschlagEintrag>? umschlaege;
}

class TagesabschlussSchritt2Seite extends StatefulWidget {
  const TagesabschlussSchritt2Seite({
    super.key,
    required this.kinoId,
    required this.kinoName,
    required this.scheineCent,
    required this.loseMuenzenCent,
    required this.rollenCent,
    required this.umschlaegeCent,
    required this.wechselgeldSollwertCent,
    required this.barBestandAbzglWechselgeldCent,
    required this.stueckzahlen,
    required this.loseMuenzenNachArtCent,
    this.umschlaege,
  });

  static const String routenName = '/closure-step-2';

  final String kinoId;
  final String kinoName;
  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int wechselgeldSollwertCent;
  final int barBestandAbzglWechselgeldCent;
  final Map<String, int> stueckzahlen;
  final Map<String, int> loseMuenzenNachArtCent;
  final List<UmschlagEintrag>? umschlaege;

  @override
  State<TagesabschlussSchritt2Seite> createState() =>
      _TagesabschlussSchritt2SeiteState();
}

class _TagesabschlussSchritt2SeiteState
    extends State<TagesabschlussSchritt2Seite> {
  static const double _devToolsPanelHoehe = 68;

  final TextEditingController _kinoSollController = TextEditingController();
  final TextEditingController _bistroSollController = TextEditingController();
  final TextEditingController _differenzAnfangsbestandController =
      TextEditingController();
  final FocusNode _kinoSollFocusNode = FocusNode();
  final FocusNode _bistroSollFocusNode = FocusNode();
  final FocusNode _differenzAnfangsbestandFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<TextEditingController> _ecBelegController =
      <TextEditingController>[TextEditingController()];
  final List<TextEditingController> _ecBelegLabelController =
      <TextEditingController>[TextEditingController()];
  final List<FocusNode> _ecBelegFocusNode = <FocusNode>[];
  final List<FocusNode> _ecBelegLabelFocusNode = <FocusNode>[];
  final List<int> _ecBelegIds = <int>[0];
  int _naechsteEcBelegId = 1;
  final List<String> _ecBelegLabels = <String>[''];

  final List<TextEditingController> _ausgabenBetragController =
      <TextEditingController>[TextEditingController()];
  final List<TextEditingController> _ausgabenLabelController =
      <TextEditingController>[TextEditingController()];
  final List<FocusNode> _ausgabenBetragFocusNode = <FocusNode>[];
  final List<FocusNode> _ausgabenLabelFocusNode = <FocusNode>[];
  final List<int> _ausgabenBetrageCent = <int>[0];
  final List<String> _ausgabenLabels = <String>[''];
  final List<int> _ausgabenIds = <int>[0];
  int _naechsteAusgabeId = 1;

  int _kinoSollCent = 0;
  int _bistroSollCent = 0;
  int _differenzAnfangsbestandCent = 0;
  final List<int> _ecBelegeCent = <int>[0];
  bool _devToolsOffen = false;
  bool _devModusAktiv = false;
  bool _validierungAusgeloest = false;
  bool _kinoSollBeruehrt = false;
  bool _bistroSollBeruehrt = false;
  bool _ecBeleg1Beruehrt = false;
  @override
  void initState() {
    super.initState();
    final FocusNode ersterEcFocusNode = FocusNode();
    _ecBelegFocusNode.add(ersterEcFocusNode);
    _ecBelegLabelFocusNode.add(FocusNode());
    _ausgabenLabelFocusNode.add(FocusNode());
    _ausgabenBetragFocusNode.add(FocusNode());
    DevModus.istAktiv().then((bool aktiv) {
      setState(() {
        _devModusAktiv = aktiv;
      });
    });
    _ladeEntwurf();
  }

  @override
  void dispose() {
    _kinoSollController.dispose();
    _bistroSollController.dispose();
    _differenzAnfangsbestandController.dispose();
    _kinoSollFocusNode.dispose();
    _bistroSollFocusNode.dispose();
    _differenzAnfangsbestandFocusNode.dispose();
    _scrollController.dispose();
    for (final TextEditingController c in _ecBelegController) {
      c.dispose();
    }
    for (final TextEditingController c in _ecBelegLabelController) {
      c.dispose();
    }
    for (final FocusNode fn in _ecBelegFocusNode) {
      fn.dispose();
    }
    for (final FocusNode fn in _ecBelegLabelFocusNode) {
      fn.dispose();
    }
    for (final TextEditingController c in _ausgabenBetragController) {
      c.dispose();
    }
    for (final TextEditingController c in _ausgabenLabelController) {
      c.dispose();
    }
    for (final FocusNode fn in _ausgabenBetragFocusNode) {
      fn.dispose();
    }
    for (final FocusNode fn in _ausgabenLabelFocusNode) {
      fn.dispose();
    }
    super.dispose();
  }

  Future<void> _ladeEntwurf() async {
    final Map<String, dynamic>? daten =
        await LokalerSpeicher.ladeSchritt2Entwurf(widget.kinoId);
    if (daten == null || !mounted) {
      return;
    }
    final String? gespeichertesDatum = daten['isoDatum'] as String?;
    if (gespeichertesDatum != DatumsHelper.logischesIsoDatum()) {
      return;
    }

    final int kinoSollCent = (daten['kinoSollCent'] as num?)?.toInt() ?? 0;
    final int bistroSollCent = (daten['bistroSollCent'] as num?)?.toInt() ?? 0;
    final int differenzAnfangsbestandCent =
        (daten['differenzAnfangsbestandCent'] as num?)?.toInt() ?? 0;

    final List<int> ecBelege = <int>[];
    final Object? ecRoh = daten['ecBelegeCent'];
    if (ecRoh is List<dynamic>) {
      for (final dynamic wert in ecRoh) {
        ecBelege.add((wert as num?)?.toInt() ?? 0);
      }
    }
    if (ecBelege.isEmpty) {
      ecBelege.add(0);
    }

    final List<String> ecBelegeLabelsListe = <String>[];
    final Object? ecLabelsRoh = daten['ecBelegeLabels'];
    if (ecLabelsRoh is List<dynamic>) {
      for (final dynamic wert in ecLabelsRoh) {
        ecBelegeLabelsListe.add(wert?.toString() ?? '');
      }
    }
    while (ecBelegeLabelsListe.length < ecBelege.length) {
      ecBelegeLabelsListe.add('');
    }

    // Ausgaben-Einzelposten laden; Fallback auf altes ausgabenCent-Feld
    List<int> ausgabenBetraege = <int>[];
    List<String> ausgabenLabelListe = <String>[];
    final Object? ausgabenBetraegeRoh = daten['ausgabenBetraegeCent'];
    if (ausgabenBetraegeRoh is List<dynamic>) {
      for (final dynamic wert in ausgabenBetraegeRoh) {
        ausgabenBetraege.add((wert as num?)?.toInt() ?? 0);
      }
    }
    final Object? ausgabenLabelsRoh = daten['ausgabenLabels'];
    if (ausgabenLabelsRoh is List<dynamic>) {
      for (final dynamic wert in ausgabenLabelsRoh) {
        ausgabenLabelListe.add(wert?.toString() ?? '');
      }
    }
    if (ausgabenBetraege.isEmpty) {
      final int altCent = (daten['ausgabenCent'] as num?)?.toInt() ?? 0;
      ausgabenBetraege.add(altCent);
      ausgabenLabelListe.add('');
    }
    while (ausgabenLabelListe.length < ausgabenBetraege.length) {
      ausgabenLabelListe.add('');
    }

    setState(() {
      _setzeEcBelegAnzahl(ecBelege.length);
      _setzeAusgabenAnzahl(ausgabenBetraege.length);
      _kinoSollCent = kinoSollCent;
      _bistroSollCent = bistroSollCent;
      _differenzAnfangsbestandCent = differenzAnfangsbestandCent;
      for (int i = 0; i < ecBelege.length; i++) {
        _ecBelegeCent[i] = ecBelege[i];
        _ecBelegLabels[i] = ecBelegeLabelsListe[i];
      }
      for (int i = 0; i < ausgabenBetraege.length; i++) {
        _ausgabenBetrageCent[i] = ausgabenBetraege[i];
        _ausgabenLabels[i] = ausgabenLabelListe[i];
      }
    });

    if (kinoSollCent != 0) {
      _setzeControllerText(
        _kinoSollController,
        TagesabschlussFormatierung.formatiereEuroEingabe(kinoSollCent),
      );
    }
    if (bistroSollCent != 0) {
      _setzeControllerText(
        _bistroSollController,
        TagesabschlussFormatierung.formatiereEuroEingabe(bistroSollCent),
      );
    }
    if (differenzAnfangsbestandCent != 0) {
      _setzeControllerText(
        _differenzAnfangsbestandController,
        _differenzAnzeigeText(differenzAnfangsbestandCent),
      );
    }
    for (int i = 0; i < ecBelege.length; i++) {
      _setzeControllerText(
        _ecBelegController[i],
        TagesabschlussFormatierung.formatiereEuroEingabe(ecBelege[i]),
      );
      if (ecBelegeLabelsListe[i].isNotEmpty) {
        _setzeControllerText(_ecBelegLabelController[i], ecBelegeLabelsListe[i]);
      }
    }
    for (int i = 0; i < ausgabenBetraege.length; i++) {
      if (ausgabenBetraege[i] != 0) {
        _setzeControllerText(
          _ausgabenBetragController[i],
          TagesabschlussFormatierung.formatiereEuroEingabe(ausgabenBetraege[i]),
        );
      }
      if (ausgabenLabelListe[i].isNotEmpty) {
        _setzeControllerText(_ausgabenLabelController[i], ausgabenLabelListe[i]);
      }
    }
  }

  Future<void> _speichereEntwurf() async {
    await LokalerSpeicher.speichereSchritt2Entwurf(
      widget.kinoId,
      <String, dynamic>{
        'kinoId': widget.kinoId,
        'isoDatum': DatumsHelper.logischesIsoDatum(),
        'kinoSollCent': _kinoSollCent,
        'bistroSollCent': _bistroSollCent,
        'ausgabenCent': _ausgabenBetrageCent.fold(0, (int a, int b) => a + b),
        'ausgabenBetraegeCent': List<int>.from(_ausgabenBetrageCent),
        'ausgabenLabels': List<String>.from(_ausgabenLabels),
        'differenzAnfangsbestandCent': _differenzAnfangsbestandCent,
        'ecBelegeCent': List<int>.from(_ecBelegeCent),
        'ecBelegeLabels': List<String>.from(_ecBelegLabels),
      },
    );
  }

  int _parseCentZiffern(String wert) {
    return TagesabschlussBerechnung.parseCentZiffern(wert);
  }

  /// Gibt den Anzeigetext für das Differenz-Feld zurück (mit Minuszeichen wenn negativ).
  String _differenzAnzeigeText(int cent) {
    if (cent == 0) return '';
    final int abs = cent.abs();
    final String betrag =
        '${abs ~/ 100},${(abs % 100).toString().padLeft(2, '0')}';
    return cent < 0 ? '-$betrag' : betrag;
  }

  /// Negiert den Differenz-Anfangsbestand-Wert; ignoriert 0; aktualisiert Controller-Anzeige.
  void _vorzeichenToggleDifferenz() {
    if (_differenzAnfangsbestandCent == 0) return;
    setState(() {
      _differenzAnfangsbestandCent = -_differenzAnfangsbestandCent;
    });
    _setzeControllerText(
      _differenzAnfangsbestandController,
      _differenzAnzeigeText(_differenzAnfangsbestandCent),
    );
    _speichereEntwurf();
  }

  String _kopfDatumUhrzeit() {
    return DateFormat(
      "EEEE, d.M.yy (H:mm 'Uhr')",
      'de_DE',
    ).format(DateTime.now());
  }

  void _weiterZuSchritt3() {
    if (!_pruefePflichtfelderVorSchritt3()) {
      return;
    }
    Navigator.of(context).pushNamed(
      TagesabschlussSchritt3Seite.routenName,
      arguments: TagesabschlussSchritt3Argumente(
        kinoId: widget.kinoId,
        kinoName: widget.kinoName,
        scheineCent: widget.scheineCent,
        loseMuenzenCent: widget.loseMuenzenCent,
        rollenCent: widget.rollenCent,
        umschlaegeCent: widget.umschlaegeCent,
        wechselgeldSollwertCent: widget.wechselgeldSollwertCent,
        kinoSollCent: _kinoSollCent,
        bistroSollCent: _bistroSollCent,
        ausgabenCent: _ausgabenBetrageCent.fold(0, (int a, int b) => a + b),
        ecBelegeCent: List<int>.from(_ecBelegeCent),
        differenzAnfangsbestandCent: _differenzAnfangsbestandCent,
        stueckzahlen: widget.stueckzahlen,
        loseMuenzenNachArtCent: widget.loseMuenzenNachArtCent,
        umschlaege: widget.umschlaege,
        ausgabenBetraegeCent: List<int>.from(_ausgabenBetrageCent),
        ausgabenLabels: List<String>.from(_ausgabenLabels),
        ecBelegeLabels: List<String>.from(_ecBelegLabels),
      ),
    );
  }

  /// Prueft nur die fachlich noetigen Pflichtfelder vor dem finalen Abschluss.
  bool _pruefePflichtfelderVorSchritt3() {
    setState(() {
      _validierungAusgeloest = true;
    });

    final List<({TextEditingController controller, FocusNode fokus})>
    pflichtfelder = <({TextEditingController controller, FocusNode fokus})>[
      (controller: _kinoSollController, fokus: _kinoSollFocusNode),
      (controller: _bistroSollController, fokus: _bistroSollFocusNode),
      (controller: _ecBelegController.first, fokus: _ecBelegFocusNode.first),
    ];

    for (final ({TextEditingController controller, FocusNode fokus}) feld
        in pflichtfelder) {
      if (feld.controller.text.trim().isEmpty) {
        _zeigeValidierungsfehlerUndFokussiere(fokusNode: feld.fokus);
        return false;
      }
    }
    return true;
  }

  bool _istPflichtfeldLeer(TextEditingController controller) {
    return controller.text.trim().isEmpty;
  }

  String? _pflichtfeldFehlertext({
    required bool feldBeruehrt,
    required TextEditingController controller,
  }) {
    final bool fehlerSichtbar = _validierungAusgeloest || feldBeruehrt;
    if (!fehlerSichtbar || !_istPflichtfeldLeer(controller)) {
      return null;
    }
    return 'Pflichtfeld';
  }

  /// Zeigt eine knappe Rueckmeldung und macht das erste fehlerhafte Feld sichtbar.
  void _zeigeValidierungsfehlerUndFokussiere({required FocusNode fokusNode}) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bitte Pflichtfelder ausfüllen.')),
    );
    FocusScope.of(context).requestFocus(fokusNode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _macheFehlerfeldSichtbar(fokusNode);
    });
  }

  void _macheFehlerfeldSichtbar(FocusNode fokusNode) {
    final BuildContext? feldKontext = fokusNode.context;
    if (feldKontext == null) {
      return;
    }
    Scrollable.ensureVisible(
      feldKontext,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _ecBelegHinzufuegen() {
    setState(() {
      _ecBelegController.add(TextEditingController());
      _ecBelegLabelController.add(TextEditingController());
      _ecBelegFocusNode.add(FocusNode());
      _ecBelegLabelFocusNode.add(FocusNode());
      _ecBelegeCent.add(0);
      _ecBelegLabels.add('');
      _ecBelegIds.add(_naechsteEcBelegId++);
    });
    _speichereEntwurf();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _ecBelegLabelFocusNode.isNotEmpty) {
        FocusScope.of(context).requestFocus(_ecBelegLabelFocusNode.last);
      }
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
      _ecBelegLabelController.removeAt(index).dispose();
      _ecBelegFocusNode.removeAt(index).dispose();
      _ecBelegLabelFocusNode.removeAt(index).dispose();
      _ecBelegeCent.removeAt(index);
      _ecBelegLabels.removeAt(index);
      _ecBelegIds.removeAt(index);
    });
    _speichereEntwurf();
  }

  void _setzeControllerText(TextEditingController controller, String text) {
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _setzeEcBelegAnzahl(int anzahl) {
    while (_ecBelegController.length > anzahl) {
      _ecBelegController.removeLast().dispose();
      _ecBelegLabelController.removeLast().dispose();
      _ecBelegFocusNode.removeLast().dispose();
      _ecBelegLabelFocusNode.removeLast().dispose();
      _ecBelegeCent.removeLast();
      _ecBelegLabels.removeLast();
      _ecBelegIds.removeLast();
    }
    while (_ecBelegController.length < anzahl) {
      _ecBelegController.add(TextEditingController());
      _ecBelegLabelController.add(TextEditingController());
      _ecBelegFocusNode.add(FocusNode());
      _ecBelegLabelFocusNode.add(FocusNode());
      _ecBelegeCent.add(0);
      _ecBelegLabels.add('');
      _ecBelegIds.add(_naechsteEcBelegId++);
    }
  }

  void _ausgabeHinzufuegen() {
    setState(() {
      _ausgabenBetragController.add(TextEditingController());
      _ausgabenLabelController.add(TextEditingController());
      _ausgabenBetragFocusNode.add(FocusNode());
      _ausgabenLabelFocusNode.add(FocusNode());
      _ausgabenBetrageCent.add(0);
      _ausgabenLabels.add('');
      _ausgabenIds.add(_naechsteAusgabeId++);
    });
    _speichereEntwurf();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _ausgabenLabelFocusNode.isNotEmpty) {
        FocusScope.of(context).requestFocus(_ausgabenLabelFocusNode.last);
      }
    });
  }

  void _ausgabeEntfernen(int index) {
    if (_ausgabenBetragController.length <= 1 ||
        index < 0 ||
        index >= _ausgabenBetragController.length) {
      return;
    }
    setState(() {
      _ausgabenBetragController.removeAt(index).dispose();
      _ausgabenLabelController.removeAt(index).dispose();
      _ausgabenBetragFocusNode.removeAt(index).dispose();
      _ausgabenLabelFocusNode.removeAt(index).dispose();
      _ausgabenBetrageCent.removeAt(index);
      _ausgabenLabels.removeAt(index);
      _ausgabenIds.removeAt(index);
    });
    _speichereEntwurf();
  }

  void _setzeAusgabenAnzahl(int anzahl) {
    while (_ausgabenBetragController.length > anzahl) {
      _ausgabenBetragController.removeLast().dispose();
      _ausgabenLabelController.removeLast().dispose();
      _ausgabenBetragFocusNode.removeLast().dispose();
      _ausgabenLabelFocusNode.removeLast().dispose();
      _ausgabenBetrageCent.removeLast();
      _ausgabenLabels.removeLast();
      _ausgabenIds.removeLast();
    }
    while (_ausgabenBetragController.length < anzahl) {
      _ausgabenBetragController.add(TextEditingController());
      _ausgabenLabelController.add(TextEditingController());
      _ausgabenBetragFocusNode.add(FocusNode());
      _ausgabenLabelFocusNode.add(FocusNode());
      _ausgabenBetrageCent.add(0);
      _ausgabenLabels.add('');
      _ausgabenIds.add(_naechsteAusgabeId++);
    }
  }

  Future<void> _autoFillDev() async {
    final Map<String, dynamic>? daten =
        await LokalerSpeicher.ladeAutoFillSchritt2();
    if (!mounted) {
      return;
    }
    final int kinoSoll =
        (daten?['kinoSollCent'] as num?)?.toInt() ?? 74900;
    final int bistroSoll =
        (daten?['bistroSollCent'] as num?)?.toInt() ?? 20280;
    final int ausgaben =
        (daten?['ausgabenCent'] as num?)?.toInt() ?? 0;
    final int ecBeleg =
        (daten?['ecBelegCent'] as num?)?.toInt() ?? 51390;
    final int differenz =
        (daten?['differenzAnfangsbestandCent'] as num?)?.toInt() ?? 0;

    setState(() {
      _kinoSollCent = kinoSoll;
      _bistroSollCent = bistroSoll;
      _differenzAnfangsbestandCent = differenz;

      _setzeEcBelegAnzahl(1);
      _ecBelegeCent[0] = ecBeleg;
      _ecBelegLabels[0] = '';

      _setzeAusgabenAnzahl(1);
      _ausgabenBetrageCent[0] = ausgaben;
      _ausgabenLabels[0] = '';

      _setzeControllerText(
        _kinoSollController,
        kinoSoll != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(kinoSoll)
            : '',
      );
      _setzeControllerText(
        _bistroSollController,
        bistroSoll != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(bistroSoll)
            : '',
      );
      _setzeControllerText(
        _ausgabenBetragController[0],
        ausgaben != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(ausgaben)
            : '',
      );
      _setzeControllerText(_ausgabenLabelController[0], '');
      _setzeControllerText(_differenzAnfangsbestandController, '');
      _setzeControllerText(
        _ecBelegController[0],
        ecBeleg != 0
            ? TagesabschlussFormatierung.formatiereEuroEingabe(ecBeleg)
            : '',
      );
      _setzeControllerText(_ecBelegLabelController[0], '');
    });
    _speichereEntwurf();
  }

  void _leereAlleFelderDev() {
    FocusScope.of(context).unfocus();
    setState(() {
      _kinoSollCent = 0;
      _bistroSollCent = 0;
      _differenzAnfangsbestandCent = 0;

      _setzeEcBelegAnzahl(1);
      _ecBelegeCent[0] = 0;
      _ecBelegLabels[0] = '';

      _setzeAusgabenAnzahl(1);
      _ausgabenBetrageCent[0] = 0;
      _ausgabenLabels[0] = '';

      _setzeControllerText(_kinoSollController, '');
      _setzeControllerText(_bistroSollController, '');
      _setzeControllerText(_ausgabenBetragController[0], '');
      _setzeControllerText(_ausgabenLabelController[0], '');
      _setzeControllerText(_differenzAnfangsbestandController, '');
      _setzeControllerText(_ecBelegController[0], '');
      _setzeControllerText(_ecBelegLabelController[0], '');
    });
  }

  Widget _baueDevToolsPanel() {
    return Card(
      color: const Color(0xFFFFF8E1),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'DEV-Tools (nur Debug/Profile)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton(
              onPressed: _autoFillDev,
              child: const Text('Auto-Fill'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _leereAlleFelderDev,
              child: const Text('Alles leeren'),
            ),
          ],
        ),
      ),
    );
  }

  List<FocusNode> _fokusReihenfolgeSchritt2() {
    final List<FocusNode> ausgabenFokus = <FocusNode>[];
    for (int i = 0; i < _ausgabenLabelFocusNode.length; i++) {
      ausgabenFokus.add(_ausgabenLabelFocusNode[i]);
      if (i < _ausgabenBetragFocusNode.length) {
        ausgabenFokus.add(_ausgabenBetragFocusNode[i]);
      }
    }
    final List<FocusNode> ecBelegFokus = <FocusNode>[];
    for (int i = 0; i < _ecBelegLabelFocusNode.length; i++) {
      ecBelegFokus.add(_ecBelegLabelFocusNode[i]);
      if (i < _ecBelegFocusNode.length) {
        ecBelegFokus.add(_ecBelegFocusNode[i]);
      }
    }
    return <FocusNode>[
      _kinoSollFocusNode,
      _bistroSollFocusNode,
      ...ausgabenFokus,
      ...ecBelegFokus,
      _differenzAnfangsbestandFocusNode,
    ];
  }

  bool _istLetztesFeldSchritt2(FocusNode focusNode) {
    final List<FocusNode> reihenfolge = _fokusReihenfolgeSchritt2();
    return reihenfolge.isNotEmpty && identical(reihenfolge.last, focusNode);
  }

  FocusNode? _naechstesFeldSchritt2(FocusNode focusNode) {
    final List<FocusNode> reihenfolge = _fokusReihenfolgeSchritt2();
    final int index = reihenfolge.indexWhere(
      (FocusNode kandidat) => identical(kandidat, focusNode),
    );
    if (index < 0 || index >= reihenfolge.length - 1) {
      return null;
    }
    return reihenfolge[index + 1];
  }

  TextInputAction _textInputActionFuerSchritt2(FocusNode focusNode) {
    return _istLetztesFeldSchritt2(focusNode)
        ? TextInputAction.done
        : TextInputAction.next;
  }

  void _beiEingabeAbgeschlossenSchritt2(FocusNode focusNode) {
    final FocusNode? naechstesFeld = _naechstesFeldSchritt2(focusNode);
    if (naechstesFeld == null) {
      FocusScope.of(context).unfocus();
      return;
    }
    FocusScope.of(context).requestFocus(naechstesFeld);
  }

  /// Uebernimmt das bekannte Footer-Verhalten: ein Klick springt zum naechsten Feld.
  void _weiterZumNaechstenFeldUnten() {
    final FocusNode? aktivesFeld = _aktivesFeldSchritt2();
    if (aktivesFeld == null) {
      return;
    }
    _beiEingabeAbgeschlossenSchritt2(aktivesFeld);
  }

  FocusNode? _aktivesFeldSchritt2() {
    for (final FocusNode focusNode in _fokusReihenfolgeSchritt2()) {
      if (focusNode.hasFocus) {
        return focusNode;
      }
    }
    return null;
  }

  Widget _baueEingabeZeile({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required FocusNode focusNode,
    String? fehlermeldungText,
    bool optional = false,
    bool zeigeLoeschen = false,
    VoidCallback? onLoeschen,
    int? farbeNachWert,
    bool zeigeLabel = true,
  }) {
    // Ohne Label: nur das Eingabefeld zurückgeben (Breite kommt vom Eltern-Widget).
    if (!zeigeLabel) {
      return BetragCentEingabefeld(
        textController: controller,
        focusNode: focusNode,
        textInputAction: _textInputActionFuerSchritt2(focusNode),
        onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt2(focusNode),
        onChanged: onChanged,
        schriftgroesse: 15,
        hinweisText: '0,00 €',
        fehlermeldungText: fehlermeldungText,
        farbeNachWert: farbeNachWert,
      );
    }

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
            width: 148,
            child: BetragCentEingabefeld(
              textController: controller,
              focusNode: focusNode,
              textInputAction: _textInputActionFuerSchritt2(focusNode),
              onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt2(focusNode),
              onChanged: onChanged,
              schriftgroesse: 15,
              hinweisText: '0,00 €',
              fehlermeldungText: fehlermeldungText,
              farbeNachWert: farbeNachWert,
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

  @override
  Widget build(BuildContext context) {
    final bool tastaturOffen = MediaQuery.of(context).viewInsets.bottom > 0;
    return TagesabschlussScaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: TagesabschlussHeader(
        schrittNummer: 2,
        schrittTitel: 'Einnahmen/Abschluss',
        actions: <Widget>[
          if (_devModusAktiv)
            IconButton(
              tooltip: 'DEV-Tools',
              onPressed: () {
                setState(() {
                  _devToolsOffen = !_devToolsOffen;
                });
              },
              icon: Icon(
                _devToolsOffen
                    ? Icons.developer_mode
                    : Icons.developer_mode_outlined,
              ),
            ),
        ],
      ),
      footerChild: SizedBox(
        height: 36,
        child: Row(
          children: <Widget>[
            if (tastaturOffen) ...<Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: _weiterZumNaechstenFeldUnten,
                  style: AppFarben.footerButtonStyle,
                  child: const Text('nächstes Feld'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: _weiterZuSchritt3,
                style: AppFarben.footerButtonStyle,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.arrow_forward),
                    SizedBox(width: 6),
                    Text('3. Übertrag (Umschlag)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
          ),
        ),
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: <Widget>[
                IgnorePointer(
                  ignoring: !_devModusAktiv || !_devToolsOffen,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    opacity: _devModusAktiv && _devToolsOffen ? 1 : 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      height: _devModusAktiv && _devToolsOffen ? _devToolsPanelHoehe : 0,
                      child: _baueDevToolsPanel(),
                    ),
                  ),
                ),
                Text(
                  'Tagesabschluss ${widget.kinoName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _kopfDatumUhrzeit(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Differenz im Anfangsbestand',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              IntrinsicHeight(
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  SizedBox(
                                    width: 148,
                                    child: _baueEingabeZeile(
                                      label: 'Differenz im Anfangsbestand',
                                      controller:
                                          _differenzAnfangsbestandController,
                                      focusNode:
                                          _differenzAnfangsbestandFocusNode,
                                      zeigeLabel: false,
                                      farbeNachWert:
                                          _differenzAnfangsbestandCent,
                                      onChanged: (String wert) {
                                        setState(() {
                                          final int absolutWert =
                                              _parseCentZiffern(wert);
                                          final bool istNegativ =
                                              _differenzAnfangsbestandCent < 0;
                                          _differenzAnfangsbestandCent =
                                              istNegativ
                                                  ? -absolutWert
                                                  : absolutWert;
                                        });
                                        _speichereEntwurf();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: _vorzeichenToggleDifferenz,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(48, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      '±',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ),
                            ],
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
                          _baueEingabeZeile(
                            label: 'Kino SOLL',
                            controller: _kinoSollController,
                            focusNode: _kinoSollFocusNode,
                            fehlermeldungText: _pflichtfeldFehlertext(
                              feldBeruehrt: _kinoSollBeruehrt,
                              controller: _kinoSollController,
                            ),
                            onChanged: (String wert) {
                              setState(() {
                                _kinoSollBeruehrt = true;
                                _kinoSollCent = _parseCentZiffern(wert);
                              });
                              _speichereEntwurf();
                            },
                          ),
                          _baueEingabeZeile(
                            label: 'Bistro SOLL',
                            controller: _bistroSollController,
                            focusNode: _bistroSollFocusNode,
                            fehlermeldungText: _pflichtfeldFehlertext(
                              feldBeruehrt: _bistroSollBeruehrt,
                              controller: _bistroSollController,
                            ),
                            onChanged: (String wert) {
                              setState(() {
                                _bistroSollBeruehrt = true;
                                _bistroSollCent = _parseCentZiffern(wert);
                              });
                              _speichereEntwurf();
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text(
                              'Ausgaben (optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          for (int i = 0;
                              i < _ausgabenBetragController.length;
                              i++)
                            KeyedSubtree(
                              key: ValueKey<int>(_ausgabenIds[i]),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        controller: _ausgabenLabelController[i],
                                        focusNode: _ausgabenLabelFocusNode[i],
                                        style:
                                            const TextStyle(fontSize: 15),
                                        textInputAction:
                                            _textInputActionFuerSchritt2(
                                          _ausgabenLabelFocusNode[i],
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Bezeichnung (optional)',
                                          hintStyle: const TextStyle(
                                            fontSize: 15,
                                          ),
                                          border: const OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                                          suffixIcon: _ausgabenLabelController[i].text.isEmpty
                                              ? null
                                              : IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    _ausgabenLabelController[i].clear();
                                                    setState(() {
                                                      _ausgabenLabels[i] = '';
                                                    });
                                                    _speichereEntwurf();
                                                  },
                                                ),
                                        ),
                                        onSubmitted: (_) =>
                                            _beiEingabeAbgeschlossenSchritt2(
                                          _ausgabenLabelFocusNode[i],
                                        ),
                                        onChanged: (String wert) {
                                          setState(() {
                                            _ausgabenLabels[i] = wert;
                                          });
                                          _speichereEntwurf();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 120,
                                      child: BetragCentEingabefeld(
                                        textController:
                                            _ausgabenBetragController[i],
                                        focusNode: _ausgabenBetragFocusNode[i],
                                        textInputAction:
                                            _textInputActionFuerSchritt2(
                                          _ausgabenBetragFocusNode[i],
                                        ),
                                        onSubmitted: (_) =>
                                            _beiEingabeAbgeschlossenSchritt2(
                                          _ausgabenBetragFocusNode[i],
                                        ),
                                        onChanged: (String wert) {
                                          setState(() {
                                            _ausgabenBetrageCent[i] =
                                                _parseCentZiffern(wert);
                                          });
                                          _speichereEntwurf();
                                        },
                                        schriftgroesse: 15,
                                        hinweisText: '0,00 €',
                                      ),
                                    ),
                                    if (_ausgabenBetragController.length >
                                        1) ...<Widget>[
                                      const SizedBox(width: 6),
                                      IconButton(
                                        onPressed: () =>
                                            _ausgabeEntfernen(i),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                        ),
                                        tooltip: 'Ausgabe entfernen',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: _ausgabeHinzufuegen,
                              icon: const Icon(Icons.add),
                              label: const Text('+ Ausgabe hinzufügen'),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'EC-Belege',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          for (int i = 0; i < _ecBelegController.length; i++)
                            KeyedSubtree(
                              key: ValueKey<int>(_ecBelegIds[i]),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        controller: _ecBelegLabelController[i],
                                        focusNode: _ecBelegLabelFocusNode[i],
                                        style: const TextStyle(fontSize: 15),
                                        textInputAction:
                                            _textInputActionFuerSchritt2(
                                          _ecBelegLabelFocusNode[i],
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Bezeichnung (optional)',
                                          hintStyle: const TextStyle(
                                            fontSize: 15,
                                          ),
                                          border: const OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                          suffixIcon: _ecBelegLabelController[i].text.isEmpty
                                              ? null
                                              : IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    _ecBelegLabelController[i].clear();
                                                    setState(() {
                                                      _ecBelegLabels[i] = '';
                                                    });
                                                    _speichereEntwurf();
                                                  },
                                                ),
                                        ),
                                        onSubmitted: (_) =>
                                            _beiEingabeAbgeschlossenSchritt2(
                                          _ecBelegLabelFocusNode[i],
                                        ),
                                        onChanged: (String wert) {
                                          setState(() {
                                            _ecBelegLabels[i] = wert;
                                          });
                                          _speichereEntwurf();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 120,
                                      child: BetragCentEingabefeld(
                                        textController: _ecBelegController[i],
                                        focusNode: _ecBelegFocusNode[i],
                                        textInputAction:
                                            _textInputActionFuerSchritt2(
                                          _ecBelegFocusNode[i],
                                        ),
                                        onSubmitted: (_) =>
                                            _beiEingabeAbgeschlossenSchritt2(
                                          _ecBelegFocusNode[i],
                                        ),
                                        onChanged: (String wert) {
                                          setState(() {
                                            if (i == 0) {
                                              _ecBeleg1Beruehrt = true;
                                            }
                                            _ecBelegeCent[i] =
                                                _parseCentZiffern(wert);
                                          });
                                          _speichereEntwurf();
                                        },
                                        schriftgroesse: 15,
                                        hinweisText: '0,00 €',
                                        fehlermeldungText: i == 0
                                            ? _pflichtfeldFehlertext(
                                                feldBeruehrt: _ecBeleg1Beruehrt,
                                                controller:
                                                    _ecBelegController.first,
                                              )
                                            : null,
                                      ),
                                    ),
                                    if (_ecBelegController.length > 1) ...<Widget>[
                                      const SizedBox(width: 6),
                                      IconButton(
                                        onPressed: () => _ecBelegEntfernen(i),
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: 'EC-Beleg entfernen',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
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
                const SizedBox(height: 8),
              ],
        ),
      ),
    );
  }
}
