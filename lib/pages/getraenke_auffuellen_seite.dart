import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/services/getraenke_config_service.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

class GetraenkeAuffuellenSeite extends StatefulWidget {
  const GetraenkeAuffuellenSeite({super.key, required this.kinoId});

  static const String routenName = '/getraenke-auffuellen';

  final String kinoId;

  @override
  State<GetraenkeAuffuellenSeite> createState() =>
      _GetraenkeAuffuellenSeiteState();
}

class _GetraenkeAuffuellenSeiteState extends State<GetraenkeAuffuellenSeite> {
  List<String> _getraenkeliste = <String>[];
  final List<TextEditingController> _mengeController =
      <TextEditingController>[];
  final List<FocusNode> _mengeFocusNode = <FocusNode>[];
  bool _geladen = false;
  bool _istLinkshaender = false;
  bool _nurBenoetigte = false;

  @override
  void initState() {
    super.initState();
    _ladeAlles();
  }

  @override
  void dispose() {
    for (final TextEditingController c in _mengeController) {
      c.dispose();
    }
    for (final FocusNode fn in _mengeFocusNode) {
      fn.dispose();
    }
    super.dispose();
  }

  Future<void> _ladeAlles() async {
    final List<String> liste = await GetraenkeConfigService(kinoId: widget.kinoId).loadLocal();
    if (!mounted) return;
    final Map<String, dynamic>? gespeichert =
        await LokalerSpeicher.ladeGetraenkeMengen(widget.kinoId);
    if (!mounted) return;
    final List<dynamic>? mengenRoh =
        gespeichert?['mengen'] as List<dynamic>?;
    for (int i = 0; i < liste.length; i++) {
      final String menge =
          (mengenRoh != null && i < mengenRoh.length)
              ? (mengenRoh[i] as String? ?? '')
              : '';
      final TextEditingController ctrl = TextEditingController(text: menge);
      final FocusNode fn = FocusNode();
      fn.addListener(() {
        if (fn.hasFocus) {
          ctrl.clear();
        }
        setState(() {});
      });
      _mengeController.add(ctrl);
      _mengeFocusNode.add(fn);
    }
    final bool linkshaender = await LokalerSpeicher.ladeLinkshaenderModus();
    if (!mounted) return;
    setState(() {
      _getraenkeliste = liste;
      _istLinkshaender = linkshaender;
      _geladen = true;
    });
  }

  int get _gesamtmenge {
    int summe = 0;
    for (final TextEditingController c in _mengeController) {
      summe += int.tryParse(c.text) ?? 0;
    }
    return summe;
  }

  void _leereAlleFelder() {
    for (final TextEditingController c in _mengeController) {
      c.clear();
    }
    setState(() {
      _nurBenoetigte = false;
    });
    _speichereMengen();
  }

  void _speichereMengen() {
    final List<String> mengen =
        _mengeController.map((TextEditingController c) => c.text).toList();
    LokalerSpeicher.speichereGetraenkeMengen(
      widget.kinoId,
      <String, dynamic>{'mengen': mengen},
    );
  }

  List<int> get _gezeigteIndizes {
    if (!_nurBenoetigte) {
      return List<int>.generate(_getraenkeliste.length, (int i) => i);
    }
    return List<int>.generate(_getraenkeliste.length, (int i) => i)
        .where((int i) => (int.tryParse(_mengeController[i].text) ?? 0) > 0)
        .toList();
  }

  Future<void> _toggleHandedness() async {
    final bool neuerWert = !_istLinkshaender;
    await LokalerSpeicher.speichereLinkshaenderModus(neuerWert);
    if (!mounted) return;
    setState(() {
      _istLinkshaender = neuerWert;
    });
  }

  Widget _baueFilterTaste() {
    final bool hatBenoetigte =
        _mengeController.any((TextEditingController c) => (int.tryParse(c.text) ?? 0) > 0);
    return TextButton(
      onPressed: hatBenoetigte
          ? () => setState(() => _nurBenoetigte = !_nurBenoetigte)
          : null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        _nurBenoetigte ? 'alle anzeigen' : 'nur benötigte anzeigen',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _baueHandednessTaste() {
    return TextButton(
      onPressed: _toggleHandedness,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: AppFarben.appBarRot),
          children: _istLinkshaender
              ? <TextSpan>[
                  const TextSpan(
                    text: 'Links',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '-/Rechtshänder'),
                ]
              : <TextSpan>[
                  const TextSpan(text: 'Links-/'),
                  const TextSpan(
                    text: 'Rechts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: 'händer'),
                ],
        ),
      ),
    );
  }

  Widget _baueFilterZeile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _istLinkshaender
            ? <Widget>[_baueHandednessTaste(), _baueFilterTaste()]
            : <Widget>[_baueFilterTaste(), _baueHandednessTaste()],
      ),
    );
  }

  Widget _baueTabelle() {
    final Map<int, TableColumnWidth> spaltenBreiten = _istLinkshaender
        ? const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(), // Namen
            1: FixedColumnWidth(8), // Abstand
            2: FixedColumnWidth(72), // Eingabe
          }
        : const <int, TableColumnWidth>{
            0: FixedColumnWidth(72), // Eingabe
            1: FixedColumnWidth(8), // Abstand
            2: IntrinsicColumnWidth(), // Namen
          };

    TableRow baueEintragZeile(int idx) {
      final bool feldHatFokus = _mengeFocusNode[idx].hasFocus;
      final Widget feld = TextField(
        controller: _mengeController[idx],
        focusNode: _mengeFocusNode[idx],
        keyboardType: TextInputType.number,
        textAlign: _istLinkshaender ? TextAlign.left : TextAlign.right,
        style: TextStyle(color: feldHatFokus ? Colors.white : null),
        cursorColor: feldHatFokus ? Colors.white : null,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          isDense: true,
          filled: feldHatFokus,
          fillColor: feldHatFokus ? Colors.black87 : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        onChanged: (_) {
          setState(() {});
          _speichereMengen();
        },
      );
      final Widget name = Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          _getraenkeliste[idx],
          style: const TextStyle(fontSize: 15),
          textAlign:
              _istLinkshaender ? TextAlign.right : TextAlign.left,
        ),
      );
      final Widget feldZelle = Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: feld,
      );
      return TableRow(
        children: _istLinkshaender
            ? <Widget>[name, const SizedBox(), feldZelle]
            : <Widget>[feldZelle, const SizedBox(), name],
      );
    }

    final Widget gesamtZahl = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        _gesamtmenge.toString(),
        textAlign: _istLinkshaender ? TextAlign.left : TextAlign.right,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
    const Widget gesamtLabel = Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text(
        'Gesamt',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
    final TableRow gesamtZeile = TableRow(
      children: _istLinkshaender
          ? <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Gesamt',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(),
              gesamtZahl,
            ]
          : <Widget>[gesamtZahl, const SizedBox(), gesamtLabel],
    );

    return Table(
      columnWidths: spaltenBreiten,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        for (final int idx in _gezeigteIndizes) baueEintragZeile(idx),
        gesamtZeile,
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

    return TagesabschlussScaffold(
      appBar: TagesabschlussHeader(
        schrittNummer: 0,
        schrittTitel: 'Getränke auffüllen',
        kinoName: KinoRepository.nachId(widget.kinoId)?.name ?? 'Schauburg',
        actions: <Widget>[
          TextButton(
            onPressed: _leereAlleFelder,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Clear'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      footerChild: SizedBox(
        height: 36,
        child: Row(
          children: _istLinkshaender
              ? <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: AppFarben.footerButtonStyle,
                      child: const Text('Fertig'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppFarben.appBarRot,
                      disabledForegroundColor: Colors.grey.shade400,
                      disabledBackgroundColor: Colors.grey.shade200,
                      minimumSize: const Size(130, 36),
                    ),
                    child: const Text('next'),
                  ),
                ]
              : <Widget>[
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppFarben.appBarRot,
                      disabledForegroundColor: Colors.grey.shade400,
                      disabledBackgroundColor: Colors.grey.shade200,
                      minimumSize: const Size(130, 36),
                    ),
                    child: const Text('next'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: AppFarben.footerButtonStyle,
                      child: const Text('Fertig'),
                    ),
                  ),
                ],
        ),
      ),
      child: _getraenkeliste.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Keine Getränke definiert. Bitte zuerst in den '
                  'Einstellungen eine Getränkeliste anlegen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : Column(
              children: <Widget>[
                _baueFilterZeile(context),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: _istLinkshaender
                        ? const EdgeInsets.fromLTRB(0, 4, 40, 4)
                        : const EdgeInsets.fromLTRB(40, 4, 0, 4),
                    child: Row(
                      mainAxisAlignment: _istLinkshaender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: <Widget>[
                        IntrinsicWidth(child: _baueTabelle()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
