import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GanzzahlEingabefeld extends StatelessWidget {
  const GanzzahlEingabefeld({
    super.key,
    required this.textController,
    required this.onChanged,
    this.hinweisText = '0',
    this.schriftgroesse = 20,
    this.textAusrichtung = TextAlign.center,
    this.textInputAction = TextInputAction.done,
  });

  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final String hinweisText;
  final double schriftgroesse;
  final TextAlign textAusrichtung;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      textAlign: textAusrichtung,
      style: TextStyle(fontSize: schriftgroesse),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        hintText: hinweisText,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
