import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';

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
    final String formatiert =
        TagesabschlussFormatierung.formatiereEuroEingabe(cent);

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
    this.istHervorgehoben = false,
    this.farbeNachWert,
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
  final bool istHervorgehoben;
  /// Farbliche Hervorhebung nach Wert im unfokussierten Zustand:
  /// > 0 → grün, < 0 → rot, == 0 → neutral. Nur sichtbar wenn nicht fokussiert.
  final int? farbeNachWert;

  @override
  State<BetragCentEingabefeld> createState() => _BetragCentEingabefeldState();
}

class _BetragCentEingabefeldState extends State<BetragCentEingabefeld> {
  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_beiFokuswechsel);
    widget.textController.addListener(_beiTextAenderung);
  }

  @override
  void didUpdateWidget(covariant BetragCentEingabefeld oldWidget) {
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
    setState(() {});
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
    final bool hatText = widget.textController.text.isNotEmpty;

    // istHervorgehoben (Validierungsfehler) hat Vorrang vor Wertfarbe.
    final bool rotValidierung = widget.istHervorgehoben;
    final bool zeigeWertfarbe =
        !hatFokus && !rotValidierung && widget.farbeNachWert != null;
    final bool gruenWert = zeigeWertfarbe && widget.farbeNachWert! > 0;
    final bool rotWert = zeigeWertfarbe && widget.farbeNachWert! < 0;

    final Color? fuellFarbe;
    if (hatFokus) {
      fuellFarbe = Colors.black87;
    } else if (rotValidierung) {
      fuellFarbe = Colors.red.shade50;
    } else if (gruenWert) {
      fuellFarbe = Colors.green.shade50;
    } else if (rotWert) {
      fuellFarbe = Colors.red.shade50;
    } else {
      fuellFarbe = null;
    }

    final InputBorder grenzeLinie;
    final InputBorder? grenzeAktiviert;
    final InputBorder? grenzeFokussiert;
    if (rotValidierung) {
      const BorderSide seite = BorderSide(color: Colors.red, width: 2);
      grenzeLinie = const OutlineInputBorder(borderSide: seite);
      grenzeAktiviert = const OutlineInputBorder(borderSide: seite);
      grenzeFokussiert = const OutlineInputBorder(borderSide: seite);
    } else if (gruenWert) {
      grenzeLinie = const OutlineInputBorder();
      grenzeAktiviert = const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2),
      );
      grenzeFokussiert = null;
    } else if (rotWert) {
      grenzeLinie = const OutlineInputBorder();
      grenzeAktiviert = const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      );
      grenzeFokussiert = null;
    } else {
      grenzeLinie = const OutlineInputBorder();
      grenzeAktiviert = null;
      grenzeFokussiert = null;
    }

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
        suffix: SizedBox(
          height: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (hatText) ...<Widget>[
                GestureDetector(
                  onTap: () {
                    widget.textController.clear();
                    widget.onChanged('');
                    widget.focusNode?.requestFocus();
                  },
                  child: Icon(
                    Icons.clear,
                    size: 16,
                    color: hatFokus ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 2),
              ],
              Text(
                '€',
                style: TextStyle(
                  color: hatFokus ? Colors.white : null,
                ),
              ),
            ],
          ),
        ),
        isDense: true,
        filled: fuellFarbe != null,
        fillColor: fuellFarbe,
        border: grenzeLinie,
        enabledBorder: grenzeAktiviert,
        focusedBorder: grenzeFokussiert,
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
