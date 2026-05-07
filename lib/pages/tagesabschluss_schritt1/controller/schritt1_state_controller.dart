import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';

// Zweck: Eigenstaendiger Controller fuer State-/Fokus-Helfer in Schritt 1.
class Schritt1StateController {
  const Schritt1StateController();

  int parseGanzzahl(String wert) {
    return int.tryParse(wert) ?? 0;
  }

  void setzeStueckzahl(
    Map<String, int> stueckzahlen,
    String zeilenId,
    int wert,
  ) {
    stueckzahlen[zeilenId] = wert;
  }

  void setzeLoseMuenzartBetrag(
    Map<String, int> loseMuenzenNachArtCent,
    String muenzartId,
    int betragCent,
  ) {
    loseMuenzenNachArtCent[muenzartId] = betragCent;
  }

  void fuegeUmschlagEintragHinzu(VoidCallback fuegeDefaultUmschlagHinzu) {
    fuegeDefaultUmschlagHinzu();
  }

  bool kannUmschlagEntfernen(List<UmschlagEintrag> umschlaege, int index) {
    return index > 0 && index < umschlaege.length;
  }

  bool istUmschlagIndexGueltig(List<UmschlagEintrag> umschlaege, int index) {
    return index >= 0 && index < umschlaege.length;
  }

  void entferneUmschlag({
    required List<UmschlagEintrag> umschlaege,
    required List<TextEditingController> umschlagBetragController,
    required List<TextEditingController> umschlagBezeichnungController,
    required List<FocusNode> umschlagBetragFocusNode,
    required List<FocusNode> umschlagBezeichnungFocusNode,
    required List<int> umschlagIds,
    required int index,
    required void Function(FocusNode focusNode) entferneFeldKey,
  }) {
    umschlaege.removeAt(index);
    umschlagBetragController.removeAt(index).dispose();
    umschlagBezeichnungController.removeAt(index).dispose();
    final FocusNode betragFocusNode = umschlagBetragFocusNode.removeAt(index);
    final FocusNode bezeichnungFocusNode = umschlagBezeichnungFocusNode
        .removeAt(index);
    entferneFeldKey(betragFocusNode);
    entferneFeldKey(bezeichnungFocusNode);
    betragFocusNode.dispose();
    bezeichnungFocusNode.dispose();
    umschlagIds.removeAt(index);
  }

  void setzeUmschlagBezeichnung(
    List<UmschlagEintrag> umschlaege,
    int index,
    String wert,
  ) {
    umschlaege[index] = UmschlagEintrag(
      bezeichnung: wert,
      betragCent: umschlaege[index].betragCent,
    );
  }

  void setzeUmschlagBetrag(
    List<UmschlagEintrag> umschlaege,
    int index,
    int betragCent,
  ) {
    umschlaege[index] = UmschlagEintrag(
      bezeichnung: umschlaege[index].bezeichnung,
      betragCent: betragCent,
    );
  }

  int parseCentZiffern(String wert) {
    return TagesabschlussBerechnung.parseCentZiffern(wert);
  }

  List<FocusNode> fokusReihenfolge({
    required List<Kassenzeile> scheine,
    required Map<String, FocusNode> stueckzahlFocusNode,
    required List<Kassenzeile> loseMuenzarten,
    required Map<String, FocusNode> loseMuenzenFocusNode,
    required List<Kassenzeile> rollenSichtbar,
    required List<UmschlagEintrag> umschlaege,
    required List<FocusNode> umschlagBezeichnungFocusNode,
    required List<FocusNode> umschlagBetragFocusNode,
  }) {
    final List<FocusNode> reihenfolge = <FocusNode>[
      ...scheine.map((Kassenzeile zeile) => stueckzahlFocusNode[zeile.id]!),
      ...loseMuenzarten.map(
        (Kassenzeile zeile) => loseMuenzenFocusNode[zeile.id]!,
      ),
      ...rollenSichtbar.map(
        (Kassenzeile zeile) => stueckzahlFocusNode[zeile.id]!,
      ),
    ];

    for (int i = 0; i < umschlaege.length; i++) {
      reihenfolge.add(umschlagBezeichnungFocusNode[i]);
      reihenfolge.add(umschlagBetragFocusNode[i]);
    }
    return reihenfolge;
  }

  bool istLetztesFeld(List<FocusNode> reihenfolge, FocusNode focusNode) {
    return reihenfolge.isNotEmpty && identical(reihenfolge.last, focusNode);
  }

  FocusNode? naechstesFeld(List<FocusNode> reihenfolge, FocusNode focusNode) {
    final int index = reihenfolge.indexWhere(
      (FocusNode kandidat) => identical(kandidat, focusNode),
    );
    if (index < 0 || index >= reihenfolge.length - 1) {
      return null;
    }
    return reihenfolge[index + 1];
  }

  TextInputAction textInputActionFuerSchritt1(bool istLetztesFeld) {
    return istLetztesFeld ? TextInputAction.done : TextInputAction.next;
  }

  void beiEingabeAbgeschlossen(BuildContext context, FocusNode? naechstesFeld) {
    if (naechstesFeld == null) {
      FocusScope.of(context).unfocus();
      return;
    }
    FocusScope.of(context).requestFocus(naechstesFeld);
  }

  FocusNode? aktivesFeld(List<FocusNode> reihenfolge) {
    for (final FocusNode focusNode in reihenfolge) {
      if (focusNode.hasFocus) {
        return focusNode;
      }
    }
    return null;
  }

  void weiterZumNaechstenFeld({
    required BuildContext context,
    required List<FocusNode> reihenfolge,
    required FocusNode? aktivesFeld,
    required FocusNode? Function(FocusNode focusNode) naechstesFeld,
    required void Function(FocusNode fokusNode) fokussiereTextfeld,
  }) {
    if (reihenfolge.isEmpty) {
      return;
    }
    if (aktivesFeld == null) {
      fokussiereTextfeld(reihenfolge.first);
      return;
    }
    final FocusNode? naechstes = naechstesFeld(aktivesFeld);
    if (naechstes == null) {
      FocusScope.of(context).unfocus();
      return;
    }
    fokussiereTextfeld(naechstes);
  }

  void fokussiereTextfeld({
    required BuildContext context,
    required FocusNode fokusNode,
    required FocusNode? Function() aktivesFeld,
    required bool Function(
      FocusNode zielFokusNode, {
      FocusNode? vorherigesFokusfeld,
    })
    oeffneSectionFuerFokusfeld,
    required void Function(FocusNode fokusNode) fokussiereTextfeldRekursiv,
    required bool mounted,
  }) {
    final FocusNode? vorherigesFokusfeld = aktivesFeld();
    final bool sectionWurdeGeoeffnet = oeffneSectionFuerFokusfeld(
      fokusNode,
      vorherigesFokusfeld: vorherigesFokusfeld,
    );
    if (sectionWurdeGeoeffnet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        fokussiereTextfeldRekursiv(fokusNode);
      });
      return;
    }
    FocusScope.of(context).requestFocus(fokusNode);
  }

  int summeGruppe(Map<String, int> stueckzahlen, List<Kassenzeile> zeilen) {
    return TagesabschlussBerechnung.summeStueckzahlGruppeCent(
      zeilen: zeilen,
      stueckzahlen: stueckzahlen,
    );
  }

  String formatiereEuro(int cent) {
    return TagesabschlussFormatierung.formatiereEuro(cent);
  }

  String formatiereEuroEingabe(int cent) {
    return TagesabschlussFormatierung.formatiereEuroEingabe(cent);
  }
}
