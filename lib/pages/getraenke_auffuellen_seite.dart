import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/services/getraenke_config_service.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_header.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

class GetraenkeAuffuellenSeite extends StatefulWidget {
  const GetraenkeAuffuellenSeite({super.key});

  static const String routenName = '/getraenke-auffuellen';

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
  int _aktuellerFokusIndex = -1;

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
    final List<String> liste = await GetraenkeConfigService().loadLocal();
    if (!mounted) return;
    final Map<String, dynamic>? gespeichert =
        await LokalerSpeicher.ladeGetraenkeMengen('kino_01');
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
          setState(() {
            _aktuellerFokusIndex = i;
          });
        }
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
    setState(() {});
    _speichereMengen();
  }

  void _springeZumNaechstfeld() {
    final int naechster = _aktuellerFokusIndex + 1;
    if (naechster < _mengeFocusNode.length) {
      _mengeFocusNode[naechster].requestFocus();
    }
  }

  void _speichereMengen() {
    final List<String> mengen =
        _mengeController.map((TextEditingController c) => c.text).toList();
    LokalerSpeicher.speichereGetraenkeMengen(
      'kino_01',
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

  Widget _baueFilterZeile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            onPressed: () =>
                setState(() => _nurBenoetigte = !_nurBenoetigte),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _nurBenoetigte ? 'alle anzeigen' : 'nur benötigte anzeigen',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _toggleHandedness,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppFarben.appBarRot,
                ),
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
          ),
        ],
      ),
    );
  }

  Widget _baueZeile(int realIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 72,
            child: TextField(
              controller: _mengeController[realIndex],
              focusNode: _mengeFocusNode[realIndex],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
              ),
              onChanged: (_) {
                setState(() {});
                _speichereMengen();
              },
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              _getraenkeliste[realIndex],
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _baueGesamtZeile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 72,
            child: Text(
              _gesamtmenge.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Gesamt',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
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
                    onPressed:
                        _aktuellerFokusIndex < _getraenkeliste.length - 1
                            ? _springeZumNaechstfeld
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppFarben.appBarRot,
                      disabledForegroundColor: Colors.grey.shade400,
                      disabledBackgroundColor: Colors.grey.shade200,
                    ),
                    child: const Text('next'),
                  ),
                ]
              : <Widget>[
                  ElevatedButton(
                    onPressed:
                        _aktuellerFokusIndex < _getraenkeliste.length - 1
                            ? _springeZumNaechstfeld
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppFarben.appBarRot,
                      disabledForegroundColor: Colors.grey.shade400,
                      disabledBackgroundColor: Colors.grey.shade200,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: _istLinkshaender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: <Widget>[
                        IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              for (final int idx in _gezeigteIndizes)
                                _baueZeile(idx),
                              _baueGesamtZeile(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
