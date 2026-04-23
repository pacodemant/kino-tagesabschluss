import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CentWaehrungsEingabeFormatter extends TextInputFormatter {
  static final RegExp _nichtZiffern = RegExp(r'[^0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String ziffern = newValue.text.replaceAll(_nichtZiffern, '');
    if (ziffern.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final int cent = int.tryParse(ziffern) ?? 0;
    final int euro = cent ~/ 100;
    final String centTeil = (cent % 100).toString().padLeft(2, '0');
    final String formatiert = '$euro,$centTeil';

    return TextEditingValue(
      text: formatiert,
      selection: TextSelection.collapsed(offset: formatiert.length),
    );
  }
}

class BetragCentEingabefeld extends StatefulWidget {
  const BetragCentEingabefeld({
    super.key,
    required this.textController,
    required this.onChanged,
    required this.schriftgroesse,
    required this.hinweisText,
    this.labelText,
    this.fehlermeldungText,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final double schriftgroesse;
  final String hinweisText;
  final String? labelText;
  final String? fehlermeldungText;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<BetragCentEingabefeld> createState() => _BetragCentEingabefeldState();
}

class _BetragCentEingabefeldState extends State<BetragCentEingabefeld> {
  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_beiFokuswechsel);
  }

  @override
  void didUpdateWidget(covariant BetragCentEingabefeld oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == widget.focusNode) {
      return;
    }
    oldWidget.focusNode?.removeListener(_beiFokuswechsel);
    widget.focusNode?.addListener(_beiFokuswechsel);
  }

  void _beiFokuswechsel() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_beiFokuswechsel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hatFokus = widget.focusNode?.hasFocus ?? false;
    final String bereinigterHinweisText = widget.hinweisText
        .replaceAll(' €', '')
        .replaceAll('€', '');

    return TextField(
      controller: widget.textController,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.number,
      textInputAction: widget.textInputAction,
      textAlign: TextAlign.center,
      cursorColor: hatFokus ? Colors.white : null,
      style: TextStyle(
        fontSize: widget.schriftgroesse,
        color: hatFokus ? Colors.white : null,
        fontWeight: hatFokus ? FontWeight.w700 : FontWeight.normal,
      ),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        CentWaehrungsEingabeFormatter(),
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: bereinigterHinweisText,
        suffixText: '€',
        isDense: true,
        filled: hatFokus,
        fillColor: hatFokus ? Colors.black87 : null,
        border: const OutlineInputBorder(),
        errorText: widget.fehlermeldungText,
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
