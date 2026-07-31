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
    // Jedes "+"-getrennte Segment wird unabhängig live formatiert, damit
    // z.B. "260+20" während der Eingabe als "2,60+0,20" angezeigt wird.
    final String formatiert = newValue.text
        .split('+')
        .map(_formatiereSegment)
        .join('+');

    return TextEditingValue(
      text: formatiert,
      selection: TextSelection.collapsed(offset: formatiert.length),
    );
  }

  static String _formatiereSegment(String segment) {
    final String ziffern = segment.replaceAll(_nichtZiffern, '');
    if (ziffern.isEmpty) {
      return '';
    }
    final int cent = int.tryParse(ziffern) ?? 0;
    return TagesabschlussFormatierung.formatiereEuroEingabe(cent);
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
    this.mitKomma = false,
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
  final bool mitKomma;

  @override
  State<BetragCentEingabefeld> createState() => _BetragCentEingabefeldState();
}

class _BetragCentEingabefeldState extends State<BetragCentEingabefeld> {
  bool _nennwertFehler = false;
  bool _kommaAnpassungAktiv = false;

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
    if (!mounted) return;
    final bool hatFokusJetzt = widget.focusNode?.hasFocus ?? false;
    if (hatFokusJetzt) {
      setState(() => _nennwertFehler = false);
      return;
    }
    _pruefeNachFokusverlust();
  }

  void _pruefeNachFokusverlust() {
    final String text = widget.textController.text.trim();
    final int cent = _parseCentAusText(widget.textController.text);
    if (text.isNotEmpty && cent == 0 && text != '0,00' && text != '0') {
      setState(() => _nennwertFehler = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog<void>(
            context: context,
            builder: (BuildContext dialogCtx) => AlertDialog(
              title: const Text('Ooops!'),
              content: const Text(
                'Der eingegebene Betrag ergibt 0 – bitte prüfen.',
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
      return;
    }
    // Komma-Modus: Ganzzahl oder kurze Dezimalzahl auf "X,XX" auffüllen
    if (widget.mitKomma && text.isNotEmpty && cent > 0) {
      final String formatiert =
          TagesabschlussFormatierung.formatiereEuroEingabe(cent);
      if (widget.textController.text != formatiert) {
        widget.textController.value = TextEditingValue(
          text: formatiert,
          selection: TextSelection.collapsed(offset: formatiert.length),
        );
      }
    }

    // "+"-Summe (z.B. "2,60+0,20"): nach Fokusverlust zum Endbetrag
    // zusammenfassen, damit das Feld den berechneten Wert zeigt.
    if (!widget.mitKomma && text.contains('+')) {
      final String formatiert =
          TagesabschlussFormatierung.formatiereEuroEingabe(cent);
      if (widget.textController.text != formatiert) {
        widget.textController.value = TextEditingValue(
          text: formatiert,
          selection: TextSelection.collapsed(offset: formatiert.length),
        );
        widget.onChanged(formatiert);
      }
    }

    if (widget.nennwertCent != null && widget.nennwertCent! > 0) {
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
              title: const Text('Ooops!'),
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

  int _parseCentAusText(String text) {
    if (widget.mitKomma) {
      return TagesabschlussBerechnung.parseCentKomma(text);
    }
    return TagesabschlussBerechnung.parseCentZiffern(text);
  }

  // Hängt "+" an, damit ein weiterer Betrag addiert werden kann (z.B. beim
  // Nachzählen gefundener Münzen). Funktioniert unabhängig davon, ob die
  // Tastatur ein "+"-Zeichen anbietet.
  void _fuegeAdditionHinzu() {
    final String aktuellerText = widget.textController.text;
    if (aktuellerText.isEmpty || aktuellerText.endsWith('+')) {
      widget.focusNode?.requestFocus();
      return;
    }
    final bool hatteBereitsFokus = widget.focusNode?.hasFocus ?? false;
    final String neuerText = '$aktuellerText+';
    widget.textController.value = TextEditingValue(
      text: neuerText,
      selection: TextSelection.collapsed(offset: neuerText.length),
    );
    // War das Feld schon fokussiert, würde ein erneuter requestFocus()-Aufruf
    // die Text-Input-Verbindung neu aufbauen — das lässt auf iOS Safari die
    // virtuelle Tastatur verschwinden. Nur bei fehlendem Fokus nötig.
    if (!hatteBereitsFokus) {
      widget.focusNode?.requestFocus();
    }
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

  static String _formatiereNennwert(int cent) {
    if (cent < 100) return '$cent Ct';
    return '${cent ~/ 100} €';
  }

  void _beiTextAenderung() {
    if (!mounted) return;
    if (widget.mitKomma && !_kommaAnpassungAktiv) {
      final String text = widget.textController.text;
      if (text.startsWith(',') || text.startsWith('.')) {
        _kommaAnpassungAktiv = true;
        try {
          final String neuerText = '0$text';
          widget.textController.value = TextEditingValue(
            text: neuerText,
            selection: TextSelection.collapsed(offset: neuerText.length),
          );
          widget.onChanged(neuerText);
        } finally {
          _kommaAnpassungAktiv = false;
        }
        setState(() => _nennwertFehler = false);
        return;
      }
    }
    setState(() => _nennwertFehler = false);
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
      fuellFarbe = AppFarben.fokusFarbe;
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
      grenzeLinie = const OutlineInputBorder(borderSide: BorderSide(color: AppFarben.appBarRot));
      grenzeAktiviert = const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2),
      );
      grenzeFokussiert = null;
    } else if (rotWert) {
      grenzeLinie = const OutlineInputBorder(borderSide: BorderSide(color: AppFarben.appBarRot));
      grenzeAktiviert = const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      );
      grenzeFokussiert = null;
    } else {
      grenzeLinie = const OutlineInputBorder(borderSide: BorderSide(color: AppFarben.appBarRot));
      grenzeAktiviert = null;
      grenzeFokussiert = null;
    }

    final String bereinigterHinweisText = widget.hinweisText
        .replaceAll(' €', '')
        .replaceAll('€', '');

    return TextField(
      controller: widget.textController,
      focusNode: widget.focusNode,
      keyboardType: widget.mitKomma
          ? const TextInputType.numberWithOptions(decimal: true)
          // Telefon-Tastenfeld statt reinem Zifferblock, da dieses meist
          // ein "+" zeigt (für Additions-Eingaben wie "260+20").
          : TextInputType.phone,
      textInputAction: widget.textInputAction,
      // Rechtsbündig statt zentriert, damit der Betrag direkt am
      // Eurozeichen anliegt statt durch die Zentrierung Abstand zu
      // bekommen.
      textAlign: TextAlign.right,
      cursorColor: hatFokus ? Colors.black : null,
      style: TextStyle(
        fontSize: widget.schriftgroesse,
        color: hatFokus ? Colors.black : null,
        fontWeight: hatFokus ? FontWeight.w700 : FontWeight.normal,
      ),
      inputFormatters: widget.mitKomma
          ? <TextInputFormatter>[]
          : <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              CentWaehrungsEingabeFormatter(),
            ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: bereinigterHinweisText,
        hintStyle: TextStyle(color: hatFokus ? Colors.transparent : null),
        suffix: SizedBox(
          height: 26,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '€',
                style: TextStyle(
                  color: hatFokus ? Colors.black : null,
                ),
              ),
              if (hatText && !widget.mitKomma) ...<Widget>[
                baueEingabefeldTrennlinie(),
                baueEingabefeldAktionsChip(
                  icon: Icons.add,
                  onTap: _fuegeAdditionHinzu,
                  hatFokus: hatFokus,
                ),
              ],
              if (hatText) ...<Widget>[
                baueEingabefeldTrennlinie(),
                baueEingabefeldAktionsChip(
                  icon: Icons.clear,
                  onTap: baueClearAktion(
                    controller: widget.textController,
                    onChanged: widget.onChanged,
                    focusNode: widget.focusNode,
                  ),
                  hatFokus: hatFokus,
                ),
              ],
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
