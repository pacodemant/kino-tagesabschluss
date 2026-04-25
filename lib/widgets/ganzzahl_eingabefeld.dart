import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GanzzahlEingabefeld extends StatefulWidget {
  const GanzzahlEingabefeld({
    super.key,
    required this.textController,
    required this.onChanged,
    this.hinweisText = '0',
    this.schriftgroesse = 20,
    this.textAusrichtung = TextAlign.center,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.onSubmitted,
    this.istHervorgehoben = false,
  });

  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final String hinweisText;
  final double schriftgroesse;
  final TextAlign textAusrichtung;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final bool istHervorgehoben;

  @override
  State<GanzzahlEingabefeld> createState() => _GanzzahlEingabefeldState();
}

class _GanzzahlEingabefeldState extends State<GanzzahlEingabefeld> {
  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_beiFokuswechsel);
  }

  @override
  void didUpdateWidget(covariant GanzzahlEingabefeld oldWidget) {
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
    final bool rotRahmen = widget.istHervorgehoben;
    final bool rotFuellung = rotRahmen && !hatFokus;

    return TextField(
      controller: widget.textController,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.number,
      textInputAction: widget.textInputAction,
      textAlign: widget.textAusrichtung,
      cursorColor: hatFokus ? Colors.white : null,
      style: TextStyle(
        fontSize: widget.schriftgroesse,
        color: hatFokus ? Colors.white : null,
        fontWeight: hatFokus ? FontWeight.w700 : FontWeight.normal,
      ),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        hintText: widget.hinweisText,
        isDense: true,
        filled: hatFokus || rotFuellung,
        fillColor: hatFokus
            ? Colors.black87
            : (rotFuellung ? Colors.red.shade50 : null),
        border: rotRahmen
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              )
            : const OutlineInputBorder(),
        enabledBorder: rotRahmen
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              )
            : null,
        focusedBorder: rotRahmen
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              )
            : null,
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
