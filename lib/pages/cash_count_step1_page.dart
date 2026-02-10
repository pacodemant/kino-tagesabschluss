import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/cash_count_draft.dart';
import 'package:kino_bar_app/models/cash_line_item.dart';
import 'package:kino_bar_app/storage/local_store.dart';
import 'package:kino_bar_app/widgets/int_input_field.dart';
import 'package:kino_bar_app/widgets/money_cents_field.dart';

class CashCountStep1Args {
  const CashCountStep1Args({required this.cinemaId, required this.cinemaName});

  final String cinemaId;
  final String cinemaName;
}

class CashCountStepPage extends StatefulWidget {
  const CashCountStepPage({
    super.key,
    required this.cinemaId,
    required this.cinemaName,
  });

  static const String routeName = '/closure-step-1';

  final String cinemaId;
  final String cinemaName;

  @override
  State<CashCountStepPage> createState() => _CashCountStepPageState();
}

class _CashCountStepPageState extends State<CashCountStepPage> {
  static const List<CashLineItem> _banknotes = <CashLineItem>[
    CashLineItem(id: 'note_100', label: '100 €', unitValueCents: 10000),
    CashLineItem(id: 'note_50', label: '50 €', unitValueCents: 5000),
    CashLineItem(id: 'note_20', label: '20 €', unitValueCents: 2000),
    CashLineItem(id: 'note_10', label: '10 €', unitValueCents: 1000),
    CashLineItem(id: 'note_5', label: '5 €', unitValueCents: 500),
  ];

  static const List<CashLineItem> _rolls = <CashLineItem>[
    CashLineItem(id: 'roll_2e', label: 'Rolle 2 € (50,00 €)', unitValueCents: 5000),
    CashLineItem(id: 'roll_1e', label: 'Rolle 1 € (25,00 €)', unitValueCents: 2500),
    CashLineItem(id: 'roll_50c', label: 'Rolle 50 ct (20,00 €)', unitValueCents: 2000),
    CashLineItem(id: 'roll_20c', label: 'Rolle 20 ct (8,00 €)', unitValueCents: 800),
    CashLineItem(id: 'roll_10c', label: 'Rolle 10 ct (4,00 €)', unitValueCents: 400),
    CashLineItem(id: 'roll_5c', label: 'Rolle 5 ct (2,00 €)', unitValueCents: 200),
    CashLineItem(id: 'roll_2c', label: 'Rolle 2 ct (1,00 €)', unitValueCents: 100),
    CashLineItem(id: 'roll_1c', label: 'Rolle 1 ct (0,50 €)', unitValueCents: 50),
  ];

  final Map<String, int> _quantities = <String, int>{};
  final Map<String, TextEditingController> _quantityControllers =
      <String, TextEditingController>{};
  final TextEditingController _looseCoinsController = TextEditingController();

  final List<EnvelopeEntry> _envelopes = <EnvelopeEntry>[];
  final List<TextEditingController> _envelopeAmountControllers =
      <TextEditingController>[];
  final List<TextEditingController> _envelopeLabelControllers =
      <TextEditingController>[];

  int _changeTargetCents = 20000;
  int _looseCoinsCents = 0;
  bool _isLoading = true;

  List<CashLineItem> get _allCountItems => <CashLineItem>[..._banknotes, ..._rolls];

  @override
  void initState() {
    super.initState();
    for (final CashLineItem item in _allCountItems) {
      _quantities[item.id] = 0;
      _quantityControllers[item.id] = TextEditingController();
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _quantityControllers.values) {
      controller.dispose();
    }
    _looseCoinsController.dispose();
    for (final TextEditingController controller in _envelopeAmountControllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in _envelopeLabelControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final int loadedChangeTarget = await LocalStore.loadChangeTargetCents(
      widget.cinemaId,
    );

    final CashCountDraft? draft = await LocalStore.loadCashCountDraft(
      cinemaId: widget.cinemaId,
      isoDate: _isoDateToday(),
    );

    if (draft != null) {
      for (final CashLineItem item in _allCountItems) {
        _quantities[item.id] = draft.quantities[item.id] ?? 0;
      }
      _looseCoinsCents = draft.looseCoinsCents;
      _applyEnvelopeDraft(draft.envelopes);
    }

    _syncControllersFromState();

    if (!mounted) {
      return;
    }

    setState(() {
      _changeTargetCents = loadedChangeTarget;
      _isLoading = false;
    });
  }

  void _clearEnvelopeFields() {
    for (final TextEditingController controller in _envelopeAmountControllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in _envelopeLabelControllers) {
      controller.dispose();
    }
    _envelopes.clear();
    _envelopeAmountControllers.clear();
    _envelopeLabelControllers.clear();
  }

  void _applyEnvelopeDraft(List<EnvelopeEntry> envelopeDraft) {
    _clearEnvelopeFields();
    for (final EnvelopeEntry envelope in envelopeDraft) {
      _envelopes.add(envelope);
      _envelopeAmountControllers.add(
        TextEditingController(text: _formatEuro(envelope.amountCents)),
      );
      _envelopeLabelControllers.add(TextEditingController(text: envelope.label));
    }
  }

  void _syncControllersFromState() {
    for (final CashLineItem item in _allCountItems) {
      final int quantity = _quantities[item.id] ?? 0;
      final TextEditingController controller = _quantityControllers[item.id]!;
      final String nextText = quantity == 0 ? '' : quantity.toString();
      if (controller.text != nextText) {
        controller.text = nextText;
      }
    }

    final String looseCoinsText =
        _looseCoinsCents == 0 ? '' : _formatEuro(_looseCoinsCents);
    if (_looseCoinsController.text != looseCoinsText) {
      _looseCoinsController.text = looseCoinsText;
    }
  }

  String _isoDateToday() {
    final DateTime now = DateTime.now();
    final String year = now.year.toString().padLeft(4, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _saveDraft() async {
    final CashCountDraft draft = CashCountDraft(
      quantities: Map<String, int>.from(_quantities),
      envelopes: List<EnvelopeEntry>.from(_envelopes),
      looseCoinsCents: _looseCoinsCents,
    );

    await LocalStore.saveCashCountDraft(
      cinemaId: widget.cinemaId,
      isoDate: _isoDateToday(),
      draft: draft,
    );
  }

  void _onQuantityChanged(CashLineItem item, String value) {
    final int parsedValue = int.tryParse(value) ?? 0;
    setState(() {
      _quantities[item.id] = parsedValue;
    });
    _saveDraft();
  }

  void _onLooseCoinsChanged(String value) {
    setState(() {
      _looseCoinsCents = _parseCentDigits(value);
    });
    _saveDraft();
  }

  void _addEnvelope() {
    setState(() {
      _envelopes.add(const EnvelopeEntry(label: '', amountCents: 0));
      _envelopeAmountControllers.add(TextEditingController());
      _envelopeLabelControllers.add(TextEditingController());
    });
    _saveDraft();
  }

  void _removeEnvelope(int index) {
    if (index < 0 || index >= _envelopes.length) {
      return;
    }

    setState(() {
      _envelopes.removeAt(index);
      _envelopeAmountControllers.removeAt(index).dispose();
      _envelopeLabelControllers.removeAt(index).dispose();
    });
    _saveDraft();
  }

  void _onEnvelopeLabelChanged(int index, String value) {
    if (index < 0 || index >= _envelopes.length) {
      return;
    }

    setState(() {
      _envelopes[index] = EnvelopeEntry(
        label: value,
        amountCents: _envelopes[index].amountCents,
      );
    });
    _saveDraft();
  }

  void _onEnvelopeAmountChanged(int index, String value) {
    if (index < 0 || index >= _envelopes.length) {
      return;
    }

    final int amountCents = _parseCentDigits(value);
    setState(() {
      _envelopes[index] = EnvelopeEntry(
        label: _envelopes[index].label,
        amountCents: amountCents,
      );
    });
    _saveDraft();
  }

  int _parseCentDigits(String value) {
    final String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return 0;
    }
    return int.tryParse(digitsOnly) ?? 0;
  }

  int _sumGroup(List<CashLineItem> items) {
    int sum = 0;
    for (final CashLineItem item in items) {
      final int quantity = _quantities[item.id] ?? 0;
      sum += quantity * item.unitValueCents;
    }
    return sum;
  }

  int get _envelopeSumCents {
    int sum = 0;
    for (final EnvelopeEntry envelope in _envelopes) {
      sum += envelope.amountCents;
    }
    return sum;
  }

  int get _cashTotalCents {
    return _sumGroup(_banknotes) +
        _looseCoinsCents +
        _sumGroup(_rolls) +
        _envelopeSumCents;
  }

  int get _barRevenueCents => _cashTotalCents - _changeTargetCents;

  String _formatEuro(int cents) {
    final String sign = cents < 0 ? '-' : '';
    final int abs = cents.abs();
    final int euros = abs ~/ 100;
    final String centsPart = (abs % 100).toString().padLeft(2, '0');
    return '$sign$euros,$centsPart €';
  }

  Future<void> _goToStep2() async {
    if (_cashTotalCents == 0) {
      final bool? confirmed = await showDialog<bool>(
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

      if (confirmed != true) {
        return;
      }
    }

    await _saveDraft();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamed(CashCountStep2PlaceholderPage.routeName);
  }

  Widget _buildGroup(String title, List<CashLineItem> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final CashLineItem item in items) ...<Widget>[
              _buildItemRow(item),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            Text(
              'Zwischensumme: ${_formatEuro(_sumGroup(items))}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(CashLineItem item) {
    final int quantity = _quantities[item.id] ?? 0;
    final int subtotal = quantity * item.unitValueCents;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(item.label, style: const TextStyle(fontSize: 16)),
        ),
        SizedBox(
          width: 110,
          child: IntInputField(
            controller: _quantityControllers[item.id]!,
            onChanged: (String value) => _onQuantityChanged(item, value),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 95,
          child: Text(
            _formatEuro(subtotal),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildLooseCoinsGroup() {
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
                  child: MoneyCentsField(
                    controller: _looseCoinsController,
                    onChanged: _onLooseCoinsChanged,
                    fontSize: 20,
                    hintText: '0,00 €',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Zwischensumme: ${_formatEuro(_looseCoinsCents)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvelopesGroup() {
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
            if (_envelopes.isEmpty) const Text('Noch keine Umschläge erfasst.'),
            for (int i = 0; i < _envelopes.length; i++) ...<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _envelopeLabelControllers[i],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Label (optional)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (String value) =>
                          _onEnvelopeLabelChanged(i, value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: MoneyCentsField(
                      controller: _envelopeAmountControllers[i],
                      onChanged: (String value) =>
                          _onEnvelopeAmountChanged(i, value),
                      fontSize: 18,
                      hintText: '0,00 €',
                      labelText: 'Betrag €',
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeEnvelope(i),
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
                onPressed: _addEnvelope,
                icon: const Icon(Icons.add),
                label: const Text('Umschlag hinzufügen'),
              ),
            ),
            Text(
              'Zwischensumme: ${_formatEuro(_envelopeSumCents)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
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
            _buildSummaryLine('Kassenbestand gesamt', _formatEuro(_cashTotalCents)),
            _buildSummaryLine(
              'Wechselgeld-Sollwert',
              _formatEuro(_changeTargetCents),
            ),
            _buildSummaryLine(
              'Barumsatz (bereinigt)',
              _formatEuro(_barRevenueCents),
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              color: highlight && _barRevenueCents < 0 ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
                  _buildGroup('A) Scheine', _banknotes),
                  _buildLooseCoinsGroup(),
                  _buildGroup('C) Rollen', _rolls),
                  _buildEnvelopesGroup(),
                  _buildSummary(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToStep2,
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

class CashCountStep2PlaceholderPage extends StatelessWidget {
  const CashCountStep2PlaceholderPage({super.key});

  static const String routeName = '/closure-step-2-placeholder';

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
