import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/eingabefeld_clear_helper.dart';

// Begrenzt jedes "+"-getrennte Segment einzeln auf maxLaenge, statt (wie
// LengthLimitingTextInputFormatter) die Gesamtlänge zu deckeln — sonst
// würde z.B. bei maxLaenge 3 "12+3" nach "12+" abgeschnitten.
class GanzzahlSegmentLaengeFormatter extends TextInputFormatter {
  const GanzzahlSegmentLaengeFormatter(this.maxLaengeProSegment);

  final int maxLaengeProSegment;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final List<String> segmente = newValue.text.split('+');
    final bool ueberschritten = segmente.any(
      (String segment) => segment.length > maxLaengeProSegment,
    );
    if (!ueberschritten) {
      return newValue;
    }
    final String formatiert = segmente
        .map(
          (String segment) => segment.length > maxLaengeProSegment
              ? segment.substring(0, maxLaengeProSegment)
              : segment,
        )
        .join('+');
    return TextEditingValue(
      text: formatiert,
      selection: TextSelection.collapsed(offset: formatiert.length),
    );
  }
}

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
    this.maxLaenge,
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
  final int? maxLaenge;

  @override
  State<GanzzahlEingabefeld> createState() => _GanzzahlEingabefeldState();
}

class _GanzzahlEingabefeldState extends State<GanzzahlEingabefeld> {
  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_beiFokuswechsel);
    widget.textController.addListener(_beiTextAenderung);
  }

  @override
  void didUpdateWidget(covariant GanzzahlEingabefeld oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_beiFokuswechsel);
      widget.focusNode?.addListener(_beiFokuswechsel);
    }
    if (oldWidget.textController != widget.textController) {
      oldWidget.textController.removeListener(_beiTextAenderung);
      widget.textController.addListener(_beiTextAenderung);
    }
  }

  void _beiFokuswechsel() {
    if (!mounted) {
      return;
    }
    final bool hatFokusJetzt = widget.focusNode?.hasFocus ?? false;
    if (!hatFokusJetzt) {
      _sammleAdditionBeiFokusverlust();
    }
    setState(() {});
  }

  // "+"-Summe (z.B. "5+3"): nach Fokusverlust zum Endwert zusammenfassen.
  void _sammleAdditionBeiFokusverlust() {
    final String text = widget.textController.text;
    if (!text.contains('+')) {
      return;
    }
    final String formatiert = TagesabschlussBerechnung.parseGanzzahlSumme(
      text,
    ).toString();
    if (widget.textController.text != formatiert) {
      widget.textController.value = TextEditingValue(
        text: formatiert,
        selection: TextSelection.collapsed(offset: formatiert.length),
      );
      widget.onChanged(formatiert);
    }
  }

  // Hängt "+" an, damit ein weiterer Wert addiert werden kann (z.B. beim
  // Nachzählen weiterer Scheine). Funktioniert unabhängig davon, ob die
  // Tastatur ein "+"-Zeichen anbietet.
  void _fuegeAdditionHinzu() {
    final String aktuellerText = widget.textController.text;
    if (aktuellerText.isEmpty || aktuellerText.endsWith('+')) {
      widget.focusNode?.requestFocus();
      return;
    }
    final String neuerText = '$aktuellerText+';
    widget.textController.value = TextEditingValue(
      text: neuerText,
      selection: TextSelection.collapsed(offset: neuerText.length),
    );
    widget.focusNode?.requestFocus();
    widget.onChanged(neuerText);
    // Fokuswechsel setzt die Selektion browserseitig teils auf "alles
    // markiert" zurück; Cursor nach dem Frame erneut ans Ende setzen,
    // damit direkt weitergetippt werden kann statt den Betrag zu ersetzen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.textController.selection = TextSelection.collapsed(
          offset: widget.textController.text.length,
        );
      }
    });
  }

  void _beiTextAenderung() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_beiFokuswechsel);
    widget.textController.removeListener(_beiTextAenderung);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hatFokus = widget.focusNode?.hasFocus ?? false;
    final bool rotRahmen = widget.istHervorgehoben;
    final bool rotFuellung = rotRahmen && !hatFokus;
    final bool hatText = widget.textController.text.isNotEmpty;

    return TextField(
      controller: widget.textController,
      focusNode: widget.focusNode,
      // Telefon-Tastenfeld statt reinem Zifferblock, da dieses meist ein
      // "+" zeigt (für Additions-Eingaben wie "5+3").
      keyboardType: TextInputType.phone,
      textInputAction: widget.textInputAction,
      textAlign: widget.textAusrichtung,
      cursorColor: hatFokus ? Colors.black : null,
      style: TextStyle(
        fontSize: widget.schriftgroesse,
        color: hatFokus ? Colors.black : null,
        fontWeight: hatFokus ? FontWeight.w700 : FontWeight.normal,
      ),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
        if (widget.maxLaenge != null)
          GanzzahlSegmentLaengeFormatter(widget.maxLaenge!),
      ],
      decoration: InputDecoration(
        hintText: widget.hinweisText,
        hintStyle: TextStyle(color: hatFokus ? Colors.transparent : null),
        isDense: true,
        filled: hatFokus || rotFuellung,
        fillColor: hatFokus
            ? AppFarben.fokusFarbe
            : (rotFuellung ? Colors.red.shade50 : null),
        border: rotRahmen
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              )
            : const OutlineInputBorder(
                borderSide: BorderSide(color: AppFarben.appBarRot),
              ),
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
        suffix: hatText
            ? SizedBox(
                height: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: _fuegeAdditionHinzu,
                      child: Icon(
                        Icons.add,
                        size: 18,
                        color: clearIconFarbe(hatFokus),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: baueClearAktion(
                        controller: widget.textController,
                        onChanged: widget.onChanged,
                        focusNode: widget.focusNode,
                      ),
                      child: Icon(
                        Icons.clear,
                        size: 18,
                        color: clearIconFarbe(hatFokus),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
