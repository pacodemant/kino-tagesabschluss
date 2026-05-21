import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
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
    final List<String> liste =
        await LokalerSpeicher.ladeGetraenkeliste('kino_01');
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
      _mengeController.add(TextEditingController(text: menge));
      _mengeFocusNode.add(FocusNode());
    }
    setState(() {
      _getraenkeliste = liste;
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

  void _speichereMengen() {
    final List<String> mengen =
        _mengeController.map((TextEditingController c) => c.text).toList();
    LokalerSpeicher.speichereGetraenkeMengen(
      'kino_01',
      <String, dynamic>{'mengen': mengen},
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
      title: 'Getränke auffüllen',
      footerChild: SizedBox(
        height: 36,
        child: Row(
          children: <Widget>[
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
          : ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: _getraenkeliste.length + 1,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                if (index == _getraenkeliste.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Gesamt',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            _gesamtmenge.toString(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _getraenkeliste[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _mengeController[index],
                          focusNode: _mengeFocusNode[index],
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
                    ],
                  ),
                );
              },
            ),
    );
  }
}
