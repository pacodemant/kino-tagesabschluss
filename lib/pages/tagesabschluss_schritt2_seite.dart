import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/betrag_cent_eingabefeld.dart';

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
  });

  final String kinoId;
  final String kinoName;
  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int wechselgeldSollwertCent;
  final int barBestandAbzglWechselgeldCent;
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

  @override
  State<TagesabschlussSchritt2Seite> createState() =>
      _TagesabschlussSchritt2SeiteState();
}

class _TagesabschlussSchritt2SeiteState
    extends State<TagesabschlussSchritt2Seite> {
  static const double _footerContentHoeheNormal = 44;
  static const double _footerContentHoeheKeyboard = 40;
  static const EdgeInsets _footerPaddingNormal = EdgeInsets.fromLTRB(
    12,
    4,
    12,
    4,
  );
  static const EdgeInsets _footerPaddingKeyboard = EdgeInsets.fromLTRB(
    12,
    2,
    12,
    2,
  );
  static const double _iosLeistenHoehe = 44;

  final TextEditingController _kinoSollController = TextEditingController();
  final TextEditingController _bistroSollController = TextEditingController();
  final TextEditingController _ausgabenController = TextEditingController();
  final TextEditingController _differenzAnfangsbestandController =
      TextEditingController();
  final FocusNode _kinoSollFocusNode = FocusNode();
  final FocusNode _bistroSollFocusNode = FocusNode();
  final FocusNode _ausgabenFocusNode = FocusNode();
  final FocusNode _differenzAnfangsbestandFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<TextEditingController> _ecBelegController =
      <TextEditingController>[TextEditingController()];
  final List<FocusNode> _ecBelegFocusNode = <FocusNode>[];
  final List<int> _ecBelegIds = <int>[0];
  int _naechsteEcBelegId = 1;

  int _kinoSollCent = 0;
  int _bistroSollCent = 0;
  int _ausgabenCent = 0;
  int _differenzAnfangsbestandCent = 0;
  final List<int> _ecBelegeCent = <int>[0];
  bool _devToolsOffen = false;
  bool _validierungAusgeloest = false;
  bool _kinoSollBeruehrt = false;
  bool _bistroSollBeruehrt = false;
  bool _ecBeleg1Beruehrt = false;
  final Random _zufall = Random();
  bool get _devToolsSichtbar => !kReleaseMode;

  @override
  void initState() {
    super.initState();
    _kinoSollFocusNode.addListener(_beiFokusAenderung);
    _bistroSollFocusNode.addListener(_beiFokusAenderung);
    _ausgabenFocusNode.addListener(_beiFokusAenderung);
    _differenzAnfangsbestandFocusNode.addListener(_beiFokusAenderung);
    final FocusNode ersterEcFocusNode = FocusNode();
    ersterEcFocusNode.addListener(_beiFokusAenderung);
    _ecBelegFocusNode.add(ersterEcFocusNode);
    _ladeEntwurf();
  }

  @override
  void dispose() {
    _kinoSollController.dispose();
    _bistroSollController.dispose();
    _ausgabenController.dispose();
    _differenzAnfangsbestandController.dispose();
    _kinoSollFocusNode.dispose();
    _bistroSollFocusNode.dispose();
    _ausgabenFocusNode.dispose();
    _differenzAnfangsbestandFocusNode.dispose();
    _scrollController.dispose();
    for (final TextEditingController controller in _ecBelegController) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _ecBelegFocusNode) {
      focusNode.removeListener(_beiFokusAenderung);
      focusNode.dispose();
    }
    super.dispose();
  }

  /// Aktualisiert den Footer-Zustand bei Fokuswechsel analog zu Schritt 1.
  void _beiFokusAenderung() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _ladeEntwurf() async {
    final Map<String, dynamic>? daten =
        await LokalerSpeicher.ladeSchritt2Entwurf(widget.kinoId);
    if (daten == null || !mounted) {
      return;
    }

    final int kinoSollCent = (daten['kinoSollCent'] as num?)?.toInt() ?? 0;
    final int bistroSollCent = (daten['bistroSollCent'] as num?)?.toInt() ?? 0;
    final int ausgabenCent = (daten['ausgabenCent'] as num?)?.toInt() ?? 0;
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

    setState(() {
      _setzeEcBelegAnzahl(ecBelege.length);
      _kinoSollCent = kinoSollCent;
      _bistroSollCent = bistroSollCent;
      _ausgabenCent = ausgabenCent;
      _differenzAnfangsbestandCent = differenzAnfangsbestandCent;
      for (int i = 0; i < ecBelege.length; i++) {
        _ecBelegeCent[i] = ecBelege[i];
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
    if (ausgabenCent != 0) {
      _setzeControllerText(
        _ausgabenController,
        TagesabschlussFormatierung.formatiereEuroEingabe(ausgabenCent),
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
    }
  }

  Future<void> _speichereEntwurf() async {
    await LokalerSpeicher.speichereSchritt2Entwurf(
      widget.kinoId,
      <String, dynamic>{
        'kinoId': widget.kinoId,
        'kinoSollCent': _kinoSollCent,
        'bistroSollCent': _bistroSollCent,
        'ausgabenCent': _ausgabenCent,
        'differenzAnfangsbestandCent': _differenzAnfangsbestandCent,
        'ecBelegeCent': List<int>.from(_ecBelegeCent),
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

  String _formatiereEuro(int cent) {
    return TagesabschlussFormatierung.formatiereEuro(cent);
  }

  String _formatiereEuroMitVorzeichen(int cent) {
    return TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);
  }

  int get _ecUmsatzGesamtCent {
    return TagesabschlussBerechnung.summeCentBetraege(_ecBelegeCent);
  }

  int get _gesamtSollCent => TagesabschlussBerechnung.gesamtSollCent(
    kinoSollCent: _kinoSollCent,
    bistroSollCent: _bistroSollCent,
    ausgabenCent: _ausgabenCent,
  );

  int get _gesamtIstCent => TagesabschlussBerechnung.gesamtIstCent(
    ecUmsatzGesamtCent: _ecUmsatzGesamtCent,
    barBestandAbzglWechselgeldCent: widget.barBestandAbzglWechselgeldCent,
  );

  int get _differenzTagesabschlussCent =>
      TagesabschlussBerechnung.differenzTagesabschlussCent(
        gesamtIstCent: _gesamtIstCent,
        gesamtSollCent: _gesamtSollCent,
      );

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
        ausgabenCent: _ausgabenCent,
        ecBelegeCent: List<int>.from(_ecBelegeCent),
        differenzAnfangsbestandCent: _differenzAnfangsbestandCent,
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

  /// Stellt sicher, dass Feld und Inline-Fehlertext oberhalb von Tastatur/Footer liegen.
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

    final RenderObject? renderObject = feldKontext.findRenderObject();
    if (renderObject is! RenderBox || !_scrollController.hasClients) {
      return;
    }

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool tastaturOffen = mediaQuery.viewInsets.bottom > 0;
    final bool iosLeisteSichtbar =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && tastaturOffen;

    final double footerContentHoehe = tastaturOffen
        ? _footerContentHoeheKeyboard
        : _footerContentHoeheNormal;
    final double footerBottomInset = tastaturOffen
        ? 0
        : mediaQuery.padding.bottom;
    final double footerGesamtHoehe = footerContentHoehe + footerBottomInset;
    final double footerBottom =
        mediaQuery.viewInsets.bottom +
        (iosLeisteSichtbar ? _iosLeistenHoehe : 0);
    final double ueberlagerungUnten = footerBottom + footerGesamtHoehe;

    final Offset feldPosition = renderObject.localToGlobal(Offset.zero);
    final double feldUnterkante = feldPosition.dy + renderObject.size.height;
    const double fehlerTextReserve = 30;
    final double sichtbarerBereichUnten =
        mediaQuery.size.height - ueberlagerungUnten - 8;

    if (feldUnterkante + fehlerTextReserve <= sichtbarerBereichUnten) {
      return;
    }

    final double delta =
        feldUnterkante + fehlerTextReserve - sichtbarerBereichUnten;
    final double zielOffset = (_scrollController.position.pixels + delta + 6)
        .clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        );
    _scrollController.animateTo(
      zielOffset,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
  }

  void _ecBelegHinzufuegen() {
    setState(() {
      _ecBelegController.add(TextEditingController());
      final FocusNode focusNode = FocusNode();
      focusNode.addListener(_beiFokusAenderung);
      _ecBelegFocusNode.add(focusNode);
      _ecBelegeCent.add(0);
      _ecBelegIds.add(_naechsteEcBelegId++);
    });
    _speichereEntwurf();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _ecBelegFocusNode.isNotEmpty) {
        FocusScope.of(context).requestFocus(_ecBelegFocusNode.last);
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
      final FocusNode focusNode = _ecBelegFocusNode.removeAt(index);
      focusNode.removeListener(_beiFokusAenderung);
      focusNode.dispose();
      _ecBelegeCent.removeAt(index);
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

  int _zufallszahl(int min, int max) {
    return min + _zufall.nextInt(max - min + 1);
  }

  void _setzeEcBelegAnzahl(int anzahl) {
    while (_ecBelegController.length > anzahl) {
      _ecBelegController.removeLast().dispose();
      final FocusNode focusNode = _ecBelegFocusNode.removeLast();
      focusNode.removeListener(_beiFokusAenderung);
      focusNode.dispose();
      _ecBelegeCent.removeLast();
      _ecBelegIds.removeLast();
    }
    while (_ecBelegController.length < anzahl) {
      _ecBelegController.add(TextEditingController());
      final FocusNode focusNode = FocusNode();
      focusNode.addListener(_beiFokusAenderung);
      _ecBelegFocusNode.add(focusNode);
      _ecBelegeCent.add(0);
      _ecBelegIds.add(_naechsteEcBelegId++);
    }
  }

  void _autoFillDev() {
    setState(() {
      _kinoSollCent = _zufallszahl(20000, 100000);
      _bistroSollCent = _zufallszahl(20000, 100000);
      _ausgabenCent = _zufallszahl(0, 10000);
      _differenzAnfangsbestandCent = _zufallszahl(-1000, 1000);

      final int ecAnzahl = _zufallszahl(1, 5);
      _setzeEcBelegAnzahl(ecAnzahl);
      for (int i = 0; i < _ecBelegeCent.length; i++) {
        _ecBelegeCent[i] = _zufallszahl(0, 50000);
      }

      _setzeControllerText(
        _kinoSollController,
        TagesabschlussFormatierung.formatiereEuroEingabe(_kinoSollCent),
      );
      _setzeControllerText(
        _bistroSollController,
        TagesabschlussFormatierung.formatiereEuroEingabe(_bistroSollCent),
      );
      _setzeControllerText(
        _ausgabenController,
        TagesabschlussFormatierung.formatiereEuroEingabe(_ausgabenCent),
      );
      _setzeControllerText(
        _differenzAnfangsbestandController,
        _differenzAnzeigeText(_differenzAnfangsbestandCent),
      );
      for (int i = 0; i < _ecBelegController.length; i++) {
        _setzeControllerText(
          _ecBelegController[i],
          TagesabschlussFormatierung.formatiereEuroEingabe(_ecBelegeCent[i]),
        );
      }
    });
  }

  void _leereAlleFelderDev() {
    FocusScope.of(context).unfocus();
    setState(() {
      _kinoSollCent = 0;
      _bistroSollCent = 0;
      _ausgabenCent = 0;
      _differenzAnfangsbestandCent = 0;

      _setzeEcBelegAnzahl(1);
      _ecBelegeCent[0] = 0;

      _setzeControllerText(_kinoSollController, '');
      _setzeControllerText(_bistroSollController, '');
      _setzeControllerText(_ausgabenController, '');
      _setzeControllerText(_differenzAnfangsbestandController, '');
      _setzeControllerText(_ecBelegController[0], '');
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
    return <FocusNode>[
      _kinoSollFocusNode,
      _bistroSollFocusNode,
      _ausgabenFocusNode,
      ..._ecBelegFocusNode,
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

  Widget _baueIosTastaturLeiste() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }
    final double tastaturHoehe = MediaQuery.of(context).viewInsets.bottom;
    if (tastaturHoehe <= 0) {
      return const SizedBox.shrink();
    }
    final FocusNode? aktivesFeld = _aktivesFeldSchritt2();
    if (aktivesFeld == null) {
      return const SizedBox.shrink();
    }
    final FocusNode? naechstesFeld = _naechstesFeldSchritt2(aktivesFeld);
    final bool istLetztesFeld = naechstesFeld == null;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        border: const Border(top: BorderSide(color: Color(0x14000000))),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            if (istLetztesFeld) {
              FocusScope.of(context).unfocus();
              return;
            }
            FocusScope.of(context).requestFocus(naechstesFeld);
          },
          child: Text(istLetztesFeld ? 'Fertig' : 'nächstes Feld'),
        ),
      ),
    );
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

  Color? _farbeFuerDifferenzTagesabschluss() {
    if (_differenzTagesabschlussCent > 0) {
      return Colors.green.shade700;
    }
    if (_differenzTagesabschlussCent < 0) {
      return Colors.red;
    }
    return null;
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
                color: hervorheben ? _farbeFuerDifferenzTagesabschluss() : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueFooterSchritt2({
    required bool tastaturOffen,
    required EdgeInsets footerPadding,
    required double footerBottomInset,
  }) {
    const Color footerBg = Colors.black87;
    final bool zeigeNaechstesFeld = _aktivesFeldSchritt2() != null;
    final ButtonStyle kompaktButtonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(0, tastaturOffen ? 36 : 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return ColoredBox(
      color: footerBg,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x52FFFFFF))),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, -2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: footerPadding.add(
            EdgeInsets.only(bottom: footerBottomInset),
          ),
          child: Row(
            children: <Widget>[
              if (zeigeNaechstesFeld) ...<Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _weiterZumNaechstenFeldUnten,
                    style: kompaktButtonStyle,
                    child: const Text('nächstes Feld'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _weiterZuSchritt3,
                  style: kompaktButtonStyle,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 6),
                      Text('Schritt 3'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool istTastaturSichtbar = mediaQuery.viewInsets.bottom > 0;
    final bool iosLeisteSichtbar =
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.iOS &&
        istTastaturSichtbar;
    final double footerContentHoehe = istTastaturSichtbar
        ? _footerContentHoeheKeyboard
        : _footerContentHoeheNormal;
    final double footerBottomInset = istTastaturSichtbar
        ? 0
        : mediaQuery.viewPadding.bottom;
    final EdgeInsets footerPadding = istTastaturSichtbar
        ? _footerPaddingKeyboard
        : _footerPaddingNormal;
    final double footerGesamtHoehe = footerContentHoehe + footerBottomInset;
    final double footerBottom =
        mediaQuery.viewInsets.bottom +
        (iosLeisteSichtbar ? _iosLeistenHoehe : 0);
    final double bottomPadding =
        mediaQuery.viewInsets.bottom +
        footerGesamtHoehe +
        16 +
        (iosLeisteSichtbar ? 56 : 16);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      resizeToAvoidBottomInset: true,
      appBar: TagesabschlussHeader(
        schrittNummer: 2,
        schrittTitel: 'Einnahmen/Abschluss',
        actions: <Widget>[
          if (_devToolsSichtbar)
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
      body: Stack(
        children: <Widget>[
          Theme(
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
              padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPadding),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              children: <Widget>[
                IgnorePointer(
                  ignoring: !_devToolsSichtbar || !_devToolsOffen,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    opacity: _devToolsSichtbar && _devToolsOffen ? 1 : 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      height: _devToolsSichtbar && _devToolsOffen ? null : 0,
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
                          _baueEingabeZeile(
                            label: 'Ausgaben',
                            controller: _ausgabenController,
                            focusNode: _ausgabenFocusNode,
                            optional: true,
                            onChanged: (String wert) {
                              setState(() {
                                _ausgabenCent = _parseCentZiffern(wert);
                              });
                              _speichereEntwurf();
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
                            KeyedSubtree(
                              key: ValueKey<int>(_ecBelegIds[i]),
                              child: _baueEingabeZeile(
                                label: 'EC Beleg ${i + 1}',
                                controller: _ecBelegController[i],
                                focusNode: _ecBelegFocusNode[i],
                                fehlermeldungText: i == 0
                                    ? _pflichtfeldFehlertext(
                                        feldBeruehrt: _ecBeleg1Beruehrt,
                                        controller: _ecBelegController.first,
                                      )
                                    : null,
                                optional: i > 0,
                                zeigeLoeschen: i > 0,
                                onLoeschen: () => _ecBelegEntfernen(i),
                                onChanged: (String wert) {
                                  setState(() {
                                    if (i == 0) {
                                      _ecBeleg1Beruehrt = true;
                                    }
                                    _ecBelegeCent[i] = _parseCentZiffern(wert);
                                  });
                                  _speichereEntwurf();
                                },
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
                            wert: _formatiereEuro(
                              widget.barBestandAbzglWechselgeldCent,
                            ),
                          ),
                          _baueBerechneteZeile(
                            label: 'Gesamt IST',
                            wert: _formatiereEuro(_gesamtIstCent),
                          ),
                          _baueBerechneteZeile(
                            label: 'Differenz Tagesabschluss',
                            wert: _formatiereEuroMitVorzeichen(
                              _differenzTagesabschlussCent,
                            ),
                            hervorheben: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: footerBottom,
            child: SizedBox(
              height: footerGesamtHoehe,
              child: _baueFooterSchritt2(
                tastaturOffen: istTastaturSichtbar,
                footerPadding: footerPadding,
                footerBottomInset: footerBottomInset,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _baueIosTastaturLeiste(),
          ),
        ],
      ),
    );
  }
}
