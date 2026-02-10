import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntInputField extends StatelessWidget {
  const IntInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = '0',
    this.fontSize = 20,
    this.textAlign = TextAlign.center,
    this.textInputAction = TextInputAction.done,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final double fontSize;
  final TextAlign textAlign;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      textAlign: textAlign,
      style: TextStyle(fontSize: fontSize),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
