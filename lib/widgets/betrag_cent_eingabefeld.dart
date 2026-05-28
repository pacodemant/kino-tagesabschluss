import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/eingabefeld_clear_helper.dart';

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
    this.nennwertCent,
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
  /// Wenn gesetzt, wird nach Fokusverlust geprüft ob der Betrag durch diesen
  /// Nennwert teilbar ist. Bei Verstoß: rotes Feld + AlertDialog.
  final int? nennwertCent;

  @override
  State<BetragCentEingabefeld> createState() => _BetragCentEingabefeldState();
}

class _BetragCentEingabefeldState extends State<BetragCentEingabefeld> {
  bool _nennwertFehler = false;

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
    final bool hatFokusJetzt = widget.focusNode?.hasFocus ?? false;
    if (hatFokusJetzt) {
      // Fokus erhalten → internen Nennwert-Fehler zurücksetzen
      setState(() => _nennwertFehler = false);
    } else if (widget.nennwertCent != null && widget.nennwertCent! > 0) {
      _pruefeNennwert();
    } else {
      setState(() {});
    }
  }

  void _pruefeNennwert() {
    final int cent = _parseCentAusText(widget.textController.text);
    final bool fehler = cent > 0 && cent % widget.nennwertCent! != 0;
    setState(() => _nennwertFehler = fehler);
    if (fehler) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog<void>(
            context: context,
            builder: (BuildContext dialogCtx) => AlertDialog(
              title: const Text('Betrag prüfen'),
              content: Text(
                'Dieser Betrag lässt sich nicht durch '
                '${_formatiereNennwert(widget.nennwertCent!)} teilen – '
                'hast du dich vielleicht vertippt?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Verstanden'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  static int _parseCentAusText(String text) {
    return int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  static String _formatiereNennwert(int cent) {
    if (cent < 100) return '$cent Ct';
    return '${cent ~/ 100} €';
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

    // istHervorgehoben (Validierungsfehler) und Nennwert-Fehler färben rot.
    final bool rotValidierung = widget.istHervorgehoben || _nennwertFehler;
    final bool zeigeWertfarbe =
        !hatFokus && !rotValidierung && widget.farbeNachWert != null;
    final bool gruenWert = zeigeWertfarbe && widget.farbeNachWert! > 0;
    final bool rotWert = zeigeWertfarbe && widget.farbeNachWert! < 0;

    final Color? fuellFarbe;
    if (hatFokus) {
      fuellFarbe = Colors.black87;
    } else if (rotValidierung) {
      fuellFarbe = AppFarben.validierungFehlerHintergrund;
    } else if (gruenWert) {
      fuellFarbe = AppFarben.validierungErfolgsHintergrund;
    } else if (rotWert) {
      fuellFarbe = AppFarben.validierungFehlerHintergrund;
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
                  onTap: baueClearAktion(
                    controller: widget.textController,
                    onChanged: widget.onChanged,
                    focusNode: widget.focusNode,
                  ),
                  child: Icon(
                    Icons.clear,
                    size: 16,
                    color: clearIconFarbe(hatFokus),
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
