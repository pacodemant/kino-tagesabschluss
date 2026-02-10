import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CentCurrencyInputFormatter extends TextInputFormatter {
  static final RegExp _nonDigits = RegExp(r'[^0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(_nonDigits, '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final int cents = int.tryParse(digits) ?? 0;
    final int euros = cents ~/ 100;
    final String centsPart = (cents % 100).toString().padLeft(2, '0');
    final String formatted = '$euros,$centsPart €';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class MoneyCentsField extends StatelessWidget {
  const MoneyCentsField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.fontSize,
    required this.hintText,
    this.labelText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final double fontSize;
  final String hintText;
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: fontSize),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        CentCurrencyInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
