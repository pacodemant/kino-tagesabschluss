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

class BetragCentEingabefeld extends StatelessWidget {
  const BetragCentEingabefeld({
    super.key,
    required this.textController,
    required this.onChanged,
    required this.schriftgroesse,
    required this.hinweisText,
    this.labelText,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final double schriftgroesse;
  final String hinweisText;
  final String? labelText;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final String bereinigterHinweisText = hinweisText
        .replaceAll(' €', '')
        .replaceAll('€', '');

    return TextField(
      controller: textController,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: schriftgroesse),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        CentWaehrungsEingabeFormatter(),
      ],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: bereinigterHinweisText,
        suffixText: '€',
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
