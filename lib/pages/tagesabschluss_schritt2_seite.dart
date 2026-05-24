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
  final List<TextEditingController> _ecBelegController = <TextEditingController>[];
  final List<TextEditingController> _ecBelegLabelController = <TextEditingController>[];
  final List<FocusNode> _ecBelegFocusNode = <FocusNode>[];
  final List<FocusNode> _ecBelegLabelFocusNode = <FocusNode>[];
  final List<int> _ecBelegIds = <int>[];
  int _naechsteEcBelegId = 1;
  final List<String> _ecBelegLabels = <String>[];

  final List<TextEditingController> _ausgabenBetragController = <TextEditingController>[];
  final List<TextEditingController> _ausgabenLabelController = <TextEditingController>[];
  final List<FocusNode> _ausgabenBetragFocusNode = <FocusNode>[];
  final List<FocusNode> _ausgabenLabelFocusNode = <FocusNode>[];
  final List<int> _ausgabenBetrageCent = <int>[];
  final List<String> _ausgabenLabels = <String>[];
  final List<int> _ausgabenIds = <int>[];
  int _naechsteAusgabeId = 1;

  int _kinoSollCent = 0;
  int _bistroSollCent = 0;
  int _differenzAnfangsbestandCent = 0;
  final List<int> _ecBelegeCent = <int>[];
  bool _devToolsOffen = false;
  bool _devModusAktiv = false;
  bool _validierungAusgeloest = false;
  bool _kinoSollBeruehrt = false;
  bool _bistroSollBeruehrt = false;
  bool _ecBeleg1Beruehrt = false;
  bool _laedt = true;
  DateTime _letzteAenderung = DateTime.now();
  @override
  void initState() {
    super.initState();
    _setzeEcBelegAnzahl(1);
    _setzeAusgabenAnzahl(1);
    DevModus.istAktiv().then((bool aktiv) {
      setState(() {
        _devModusAktiv = aktiv;
      });
    });
    _ladeEntwurf().then((_) {
      if (mounted) {
        _autoFokussiereNachLaden();
      }
    });
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
      if (mounted) setState(() { _laedt = false; });
      return;
    }
    final String? gespeichertesDatum = daten['isoDatum'] as String?;
    if (gespeichertesDatum != DatumsHelper.logischesIsoDatum()) {
      setState(() { _laedt = false; });
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
      _laedt = false;
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
      _letzteAenderung = DateTime.now();
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
      "EEEE, d.M.yy, 'Stand' H:mm 'Uhr'",
      'de_DE',
    ).format(_letzteAenderung);
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
      if (widget.kinoId != 'kino_04')
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
      _letzteAenderung = DateTime.now();
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
      _letzteAenderung = DateTime.now();
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
      _letzteAenderung = DateTime.now();
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
      _letzteAenderung = DateTime.now();
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
        await LokalerSpeicher.ladeAutoFillSchritt2(widget.kinoId);
    if (!mounted) {
      return;
    }
    await _leereAlleFelder();
    if (!mounted) {
      return;
    }
    final int kinoSoll =
        (daten?['kinoSollCent'] as num?)?.toInt() ?? 0;
    final int bistroSoll =
        (daten?['bistroSollCent'] as num?)?.toInt() ?? 0;
    final int ausgaben =
        (daten?['ausgabenCent'] as num?)?.toInt() ?? 0;
    final int ecBeleg =
        (daten?['ecBelegCent'] as num?)?.toInt() ?? 0;
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

  Future<void> _leereAlleFelder() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _kinoSollCent = 0;
      _bistroSollCent = 0;
      _differenzAnfangsbestandCent = 0;
      _kinoSollBeruehrt = false;
      _bistroSollBeruehrt = false;
      _ecBeleg1Beruehrt = false;
      _validierungAusgeloest = false;

      _setzeEcBelegAnzahl(1);
      _ecBelegeCent[0] = 0;
      _ecBelegLabels[0] = '';

      _setzeAusgabenAnzahl(1);
      _ausgabenBetrageCent[0] = 0;
      _ausgabenLabels[0] = '';

      _setzeControllerText(_kinoSollController, '');
      _setzeControllerText(_bistroSollController, '');
      _setzeControllerText(_differenzAnfangsbestandController, '');
      _setzeControllerText(_ecBelegController[0], '');
      _setzeControllerText(_ecBelegLabelController[0], '');
      _setzeControllerText(_ausgabenBetragController[0], '');
      _setzeControllerText(_ausgabenLabelController[0], '');
    });
    await LokalerSpeicher.loescheSchritt2Entwurf(widget.kinoId);
  }

  Future<void> _bestaetigeUndLeereEingaben() async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Eingaben löschen?'),
        content: const Text('Alle Felder in Schritt 2 werden zurückgesetzt.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (bestaetigt != true || !mounted) {
      return;
    }
    await _leereAlleFelder();
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

  void _weiterZumNaechstenFeldUnten() {
    final FocusNode? aktivesFeld = _aktivesFeldSchritt2();
    if (aktivesFeld == null) {
      final List<FocusNode> reihenfolge = _fokusReihenfolgeSchritt2();
      if (reihenfolge.isNotEmpty) {
        FocusScope.of(context).requestFocus(reihenfolge.first);
      }
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

  FocusNode? _erstesLeeresFeld() {
    final Map<FocusNode, TextEditingController> lookup =
        <FocusNode, TextEditingController>{
      _kinoSollFocusNode: _kinoSollController,
      _bistroSollFocusNode: _bistroSollController,
      _differenzAnfangsbestandFocusNode: _differenzAnfangsbestandController,
      for (int i = 0; i < _ausgabenLabelFocusNode.length; i++)
        _ausgabenLabelFocusNode[i]: _ausgabenLabelController[i],
      for (int i = 0; i < _ausgabenBetragFocusNode.length; i++)
        _ausgabenBetragFocusNode[i]: _ausgabenBetragController[i],
      for (int i = 0; i < _ecBelegLabelFocusNode.length; i++)
        _ecBelegLabelFocusNode[i]: _ecBelegLabelController[i],
      for (int i = 0; i < _ecBelegFocusNode.length; i++)
        _ecBelegFocusNode[i]: _ecBelegController[i],
    };
    for (final FocusNode fn in _fokusReihenfolgeSchritt2()) {
      if (lookup[fn]?.text.isEmpty ?? true) {
        return fn;
      }
    }
    return null;
  }

  void _autoFokussiereNachLaden() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final FocusNode? ziel = _erstesLeeresFeld();
      if (ziel != null) {
        FocusScope.of(context).requestFocus(ziel);
      }
    });
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

  void _zeigeSchrittSlider() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('1/4 · Bargeldzählung'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/closure-step-1'));
                },
              ),
              const ListTile(
                leading: Icon(Icons.check_circle),
                title: Text(
                  '2/4 · Belege',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Aktueller Schritt'),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.arrow_forward),
                title: const Text('3/4 · Finalisieren'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _weiterZuSchritt3();
                },
              ),
              const ListTile(
                title: Text('4/4 · Stückelung Barumsatz'),
                enabled: false,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_laedt) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bool tastaturOffen = MediaQuery.of(context).viewInsets.bottom > 0;
    final FocusNode? aktuellesFeld = _aktivesFeldSchritt2();
    final bool nextButtonAktiv =
        aktuellesFeld == null || !_istLetztesFeldSchritt2(aktuellesFeld);
    return TagesabschlussScaffold(
      backgroundColor: AppFarben.seitenHintergrund,
      appBar: TagesabschlussHeader(
        schrittNummer: 2,
        schrittTitel: 'Belege',
        kinoName: widget.kinoName,
        onTap: _zeigeSchrittSlider,
        actions: <Widget>[
          TextButton(
            onPressed: _bestaetigeUndLeereEingaben,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Clear'),
          ),
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
                  onPressed:
                      nextButtonAktiv ? _weiterZumNaechstenFeldUnten : null,
                  style: AppFarben.footerButtonStyle,
                  child: const Text('Next'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: _weiterZuSchritt3,
                style: AppFarben.footerButtonStyle,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 6),
                      Text('3. Übertrag (Umschlag)'),
                    ],
                  ),
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
                  'Tagesabrechnung ${widget.kinoName}',
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
                                          _letzteAenderung = DateTime.now();
                                          final int absolutWert =
                                              TagesabschlussBerechnung.parseCentZiffern(wert);
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
                                _letzteAenderung = DateTime.now();
                                _kinoSollBeruehrt = true;
                                _kinoSollCent = TagesabschlussBerechnung.parseCentZiffern(wert);
                              });
                              _speichereEntwurf();
                            },
                          ),
                          if (widget.kinoId != 'kino_04')
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
                                  _letzteAenderung = DateTime.now();
                                  _bistroSollBeruehrt = true;
                                  _bistroSollCent = TagesabschlussBerechnung.parseCentZiffern(wert);
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
                                                          suffixIconConstraints: const BoxConstraints(
                                            minWidth: 0,
                                            minHeight: 0,
                                            maxWidth: 32,
                                            maxHeight: 32,
                                          ),
                                          suffixIcon: _ausgabenLabelController[i].text.isEmpty
                                              ? null
                                              : IconButton(
                                                  constraints: const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
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
                                            _letzteAenderung = DateTime.now();
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
                                            _letzteAenderung = DateTime.now();
                                            _ausgabenBetrageCent[i] =
                                                TagesabschlussBerechnung.parseCentZiffern(wert);
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
                                          suffixIconConstraints: const BoxConstraints(
                                            minWidth: 0,
                                            minHeight: 0,
                                            maxWidth: 32,
                                            maxHeight: 32,
                                          ),
                                          suffixIcon: _ecBelegLabelController[i].text.isEmpty
                                              ? null
                                              : IconButton(
                                                  constraints: const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
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
                                            _letzteAenderung = DateTime.now();
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
                                            _letzteAenderung = DateTime.now();
                                            if (i == 0) {
                                              _ecBeleg1Beruehrt = true;
                                            }
                                            _ecBelegeCent[i] =
                                                TagesabschlussBerechnung.parseCentZiffern(wert);
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
