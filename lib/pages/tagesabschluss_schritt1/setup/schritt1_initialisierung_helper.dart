import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/usecases/kassenstand_entwurf_usecase.dart';
import 'package:kino_bar_app/models/kassenstand_entwurf.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';

// Zweck: Kapselt Initialisierung, Laden und Controller-Synchronisierung von Schritt 1.
class Schritt1InitialisierungHelper {
  Schritt1InitialisierungHelper({
    required this.stueckzahlen,
    required this.loseMuenzenNachArtCent,
    required this.umschlaege,
    required this.umschlagBetragController,
    required this.umschlagBezeichnungController,
    required this.umschlagBetragFocusNode,
    required this.umschlagBezeichnungFocusNode,
    required this.umschlagIds,
    required this.stueckzahlController,
    required this.loseMuenzenController,
    required this.alleStueckzahlZeilen,
    required this.loseMuenzarten,
    required this.formatiereEuroEingabe,
    required this.entferneFeldKey,
    required this.naechsteUmschlagId,
  });

  final Map<String, int> stueckzahlen;
  final Map<String, int> loseMuenzenNachArtCent;
  final List<UmschlagEintrag> umschlaege;
  final List<TextEditingController> umschlagBetragController;
  final List<TextEditingController> umschlagBezeichnungController;
  final List<FocusNode> umschlagBetragFocusNode;
  final List<FocusNode> umschlagBezeichnungFocusNode;
  final List<int> umschlagIds;
  final Map<String, TextEditingController> stueckzahlController;
  final Map<String, TextEditingController> loseMuenzenController;
  final List<Kassenzeile> alleStueckzahlZeilen;
  final List<Kassenzeile> loseMuenzarten;
  final String Function(int cent) formatiereEuroEingabe;
  final void Function(FocusNode focusNode) entferneFeldKey;
  final int Function() naechsteUmschlagId;

  Future<int> ladeInitialeDaten({
    required KassenstandEntwurfUsecase usecase,
    required String kinoId,
  }) async {
    final int geladenerWechselgeldSollwert = await usecase
        .ladeWechselgeldSollwertCent(kinoId);
    final KassenstandEntwurf? entwurf = await usecase.ladeHeutigenEntwurf(kinoId);

    if (entwurf != null) {
      for (final Kassenzeile zeile in alleStueckzahlZeilen) {
        stueckzahlen[zeile.id] = entwurf.stueckzahlen[zeile.id] ?? 0;
      }
      for (final Kassenzeile zeile in loseMuenzarten) {
        loseMuenzenNachArtCent[zeile.id] =
            entwurf.loseMuenzenNachArtCent[zeile.id] ?? 0;
      }
      uebernehmeUmschlagEntwurf(entwurf.umschlaege);
    }
    sichereMindestensEinenUmschlag();
    synchronisiereControllerAusState();
    return geladenerWechselgeldSollwert;
  }

  void leereUmschlagFelder() {
    for (final TextEditingController controller in umschlagBetragController) {
      controller.dispose();
    }
    for (final TextEditingController controller in umschlagBezeichnungController) {
      controller.dispose();
    }
    for (final FocusNode focusNode in umschlagBetragFocusNode) {
      entferneFeldKey(focusNode);
      focusNode.dispose();
    }
    for (final FocusNode focusNode in umschlagBezeichnungFocusNode) {
      entferneFeldKey(focusNode);
      focusNode.dispose();
    }
    umschlaege.clear();
    umschlagBetragController.clear();
    umschlagBezeichnungController.clear();
    umschlagBetragFocusNode.clear();
    umschlagBezeichnungFocusNode.clear();
    umschlagIds.clear();
  }

  void uebernehmeUmschlagEntwurf(List<UmschlagEintrag> umschlagEntwurf) {
    leereUmschlagFelder();
    for (final UmschlagEintrag eintrag in umschlagEntwurf) {
      fuegeUmschlagEintragOhneSpeichernHinzu(eintrag);
    }
  }

  void fuegeUmschlagEintragOhneSpeichernHinzu(UmschlagEintrag eintrag) {
    umschlaege.add(eintrag);
    umschlagBetragController.add(
      TextEditingController(text: formatiereEuroEingabe(eintrag.betragCent)),
    );
    umschlagBezeichnungController.add(
      TextEditingController(text: eintrag.bezeichnung),
    );
    final FocusNode betragFocusNode = FocusNode();
    final FocusNode bezeichnungFocusNode = FocusNode();
    umschlagBetragFocusNode.add(betragFocusNode);
    umschlagBezeichnungFocusNode.add(bezeichnungFocusNode);
    umschlagIds.add(naechsteUmschlagId());
  }

  void sichereMindestensEinenUmschlag() {
    if (umschlaege.isNotEmpty) {
      return;
    }
    fuegeUmschlagEintragOhneSpeichernHinzu(
      const UmschlagEintrag(bezeichnung: '', betragCent: 0),
    );
  }

  void synchronisiereControllerAusState() {
    for (final Kassenzeile zeile in alleStueckzahlZeilen) {
      final int stueckzahl = stueckzahlen[zeile.id] ?? 0;
      final TextEditingController controller = stueckzahlController[zeile.id]!;
      final String naechsterText = stueckzahl == 0 ? '' : stueckzahl.toString();
      if (controller.text != naechsterText) {
        _setzeControllerText(controller, naechsterText);
      }
    }

    for (final Kassenzeile zeile in loseMuenzarten) {
      final int betragCent = loseMuenzenNachArtCent[zeile.id] ?? 0;
      final TextEditingController controller = loseMuenzenController[zeile.id]!;
      final String text = betragCent == 0 ? '' : formatiereEuroEingabe(betragCent);
      if (controller.text != text) {
        _setzeControllerText(controller, text);
      }
    }

  }

  void _setzeControllerText(TextEditingController controller, String text) {
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
