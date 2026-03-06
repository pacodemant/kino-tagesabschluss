part of 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';

// Zweck: Enthält ausgelagerte State-/Controller-Helfer für Schritt 1.
int _schritt1ParseGanzzahl(String wert) {
  return int.tryParse(wert) ?? 0;
}

void _schritt1SetzeStueckzahl(
  _TagesabschlussSchritt1SeiteState state,
  String zeilenId,
  int wert,
) {
  state._stueckzahlen[zeilenId] = wert;
}

void _schritt1SetzeLoseMuenzartBetrag(
  _TagesabschlussSchritt1SeiteState state,
  String muenzartId,
  int betragCent,
) {
  state._loseMuenzenNachArtCent[muenzartId] = betragCent;
}

void _schritt1FuegeUmschlagEintragHinzu(
  _TagesabschlussSchritt1SeiteState state,
) {
  state._fuegeUmschlagEintragOhneSpeichernHinzu(
    const UmschlagEintrag(bezeichnung: '', betragCent: 0),
  );
}

bool _schritt1KannUmschlagEntfernen(
  _TagesabschlussSchritt1SeiteState state,
  int index,
) {
  return index > 0 && index < state._umschlaege.length;
}

bool _schritt1IstUmschlagIndexGueltig(
  _TagesabschlussSchritt1SeiteState state,
  int index,
) {
  return index >= 0 && index < state._umschlaege.length;
}

void _schritt1EntferneUmschlag(
  _TagesabschlussSchritt1SeiteState state,
  int index,
) {
  state._umschlaege.removeAt(index);
  state._umschlagBetragController.removeAt(index).dispose();
  state._umschlagBezeichnungController.removeAt(index).dispose();
  final FocusNode betragFocusNode = state._umschlagBetragFocusNode.removeAt(
    index,
  );
  final FocusNode bezeichnungFocusNode = state._umschlagBezeichnungFocusNode
      .removeAt(index);
  state._scrollHelper.entferneFeldKey(betragFocusNode);
  state._scrollHelper.entferneFeldKey(bezeichnungFocusNode);
  betragFocusNode.dispose();
  bezeichnungFocusNode.dispose();
  state._umschlagIds.removeAt(index);
}

void _schritt1SetzeUmschlagBezeichnung(
  _TagesabschlussSchritt1SeiteState state,
  int index,
  String wert,
) {
  state._umschlaege[index] = UmschlagEintrag(
    bezeichnung: wert,
    betragCent: state._umschlaege[index].betragCent,
  );
}

void _schritt1SetzeUmschlagBetrag(
  _TagesabschlussSchritt1SeiteState state,
  int index,
  int betragCent,
) {
  state._umschlaege[index] = UmschlagEintrag(
    bezeichnung: state._umschlaege[index].bezeichnung,
    betragCent: betragCent,
  );
}

void _schritt1SetzeKartenzahlungAnzahl(
  _TagesabschlussSchritt1SeiteState state,
  int anzahl,
) {
  while (state._kartenzahlungController.length > anzahl) {
    state._kartenzahlungController.removeLast().dispose();
    final FocusNode focusNode = state._kartenzahlungFocusNode.removeLast();
    state._scrollHelper.entferneFeldKey(focusNode);
    focusNode.dispose();
    state._kartenzahlungenCent.removeLast();
    state._kartenzahlungIds.removeLast();
  }
  while (state._kartenzahlungController.length < anzahl) {
    state._kartenzahlungController.add(TextEditingController());
    state._kartenzahlungFocusNode.add(FocusNode());
    state._kartenzahlungenCent.add(0);
    state._kartenzahlungIds.add(state._naechsteKartenzahlungId++);
  }
}

bool _schritt1KannKartenzahlungEntfernen(
  _TagesabschlussSchritt1SeiteState state,
  int index,
) {
  return index > 0 && index < state._kartenzahlungController.length;
}

void _schritt1EntferneKartenzahlung(
  _TagesabschlussSchritt1SeiteState state,
  int index,
) {
  state._kartenzahlungController.removeAt(index).dispose();
  final FocusNode focusNode = state._kartenzahlungFocusNode.removeAt(index);
  state._scrollHelper.entferneFeldKey(focusNode);
  focusNode.dispose();
  state._kartenzahlungenCent.removeAt(index);
  state._kartenzahlungIds.removeAt(index);
}

int _schritt1ParseCentZiffern(String wert) {
  return TagesabschlussBerechnung.parseCentZiffern(wert);
}

List<FocusNode> _schritt1FokusReihenfolge(
  _TagesabschlussSchritt1SeiteState state,
) {
  final List<FocusNode> reihenfolge = <FocusNode>[
    ...state._scheine.map(
      (Kassenzeile zeile) => state._stueckzahlFocusNode[zeile.id]!,
    ),
    ...state._loseMuenzarten.map(
      (Kassenzeile zeile) => state._loseMuenzenFocusNode[zeile.id]!,
    ),
    ...state._rollenSichtbar.map(
      (Kassenzeile zeile) => state._stueckzahlFocusNode[zeile.id]!,
    ),
    ...state._kartenzahlungFocusNode,
  ];

  for (int i = 0; i < state._umschlaege.length; i++) {
    reihenfolge.add(state._umschlagBezeichnungFocusNode[i]);
    reihenfolge.add(state._umschlagBetragFocusNode[i]);
  }
  return reihenfolge;
}

bool _schritt1IstLetztesFeld(
  _TagesabschlussSchritt1SeiteState state,
  FocusNode focusNode,
) {
  final List<FocusNode> reihenfolge = state._fokusReihenfolgeSchritt1();
  return reihenfolge.isNotEmpty && identical(reihenfolge.last, focusNode);
}

FocusNode? _schritt1NaechstesFeld(
  _TagesabschlussSchritt1SeiteState state,
  FocusNode focusNode,
) {
  final List<FocusNode> reihenfolge = state._fokusReihenfolgeSchritt1();
  final int index = reihenfolge.indexWhere(
    (FocusNode kandidat) => identical(kandidat, focusNode),
  );
  if (index < 0 || index >= reihenfolge.length - 1) {
    return null;
  }
  return reihenfolge[index + 1];
}

TextInputAction _schritt1TextInputActionFuerSchritt1(
  _TagesabschlussSchritt1SeiteState state,
  FocusNode focusNode,
) {
  return state._istLetztesFeldSchritt1(focusNode)
      ? TextInputAction.done
      : TextInputAction.next;
}

void _schritt1BeiEingabeAbgeschlossen(
  _TagesabschlussSchritt1SeiteState state,
  FocusNode focusNode,
) {
  final FocusNode? naechstesFeld = state._naechstesFeldSchritt1(focusNode);
  if (naechstesFeld == null) {
    FocusScope.of(state.context).unfocus();
    return;
  }
  FocusScope.of(state.context).requestFocus(naechstesFeld);
}

FocusNode? _schritt1AktivesFeld(_TagesabschlussSchritt1SeiteState state) {
  for (final FocusNode focusNode in state._fokusReihenfolgeSchritt1()) {
    if (focusNode.hasFocus) {
      return focusNode;
    }
  }
  return null;
}

void _schritt1WeiterZumNaechstenFeld(_TagesabschlussSchritt1SeiteState state) {
  final List<FocusNode> reihenfolge = state._fokusReihenfolgeSchritt1();
  if (reihenfolge.isEmpty) {
    return;
  }
  final FocusNode? aktivesFeld = state._aktivesFeldSchritt1();
  if (aktivesFeld == null) {
    state._fokussiereTextfeld(reihenfolge.first);
    return;
  }
  final FocusNode? naechstesFeld = state._naechstesFeldSchritt1(aktivesFeld);
  if (naechstesFeld == null) {
    FocusScope.of(state.context).unfocus();
    return;
  }
  state._fokussiereTextfeld(naechstesFeld);
}

void _schritt1FokussiereTextfeld(
  _TagesabschlussSchritt1SeiteState state,
  FocusNode fokusNode,
) {
  state._scrollHelper.markiereProgrammatischenFokuswechsel();
  final bool sectionWurdeGeoeffnet = state._oeffneSectionFuerFokusfeld(
    fokusNode,
  );
  if (sectionWurdeGeoeffnet) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.mounted) {
        return;
      }
      state._fokussiereTextfeld(fokusNode);
    });
    return;
  }
  FocusScope.of(state.context).requestFocus(fokusNode);
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }
}

int _schritt1SummeGruppe(Map<String, int> stueckzahlen, List<Kassenzeile> zeilen) {
  return TagesabschlussBerechnung.summeStueckzahlGruppeCent(
    zeilen: zeilen,
    stueckzahlen: stueckzahlen,
  );
}

String _schritt1FormatiereEuro(int cent) {
  return TagesabschlussFormatierung.formatiereEuro(cent);
}

String _schritt1FormatiereEuroEingabe(int cent) {
  return TagesabschlussFormatierung.formatiereEuroEingabe(cent);
}
