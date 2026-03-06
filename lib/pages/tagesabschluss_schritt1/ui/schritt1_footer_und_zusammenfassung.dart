part of 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';

// Zweck: Kapselt Zusammenfassungs- und Footer-UI fuer Schritt 1.
extension _Schritt1FooterUndZusammenfassung on _TagesabschlussSchritt1SeiteState {
  Widget _baueZusammenfassung() {
    return Schritt1UebersichtSection(
      kassenbestandGesamt: _formatiereEuro(_kassenbestandGesamtCent),
      wechselgeldSollwert: _formatiereEuro(_wechselgeldSollwertCent),
      barumsatzBereinigt: _formatiereEuro(_barumsatzBereinigtCent),
      kartenzahlungen: _formatiereEuro(_kartenzahlungenSummeCent),
      gesamtInklKarte: _formatiereEuro(_gesamtUmsatzMitKarteCent),
      barumsatzNegativ: _barumsatzBereinigtCent < 0,
    );
  }

  Widget _baueFooterLeiste({
    required bool tastaturOffen,
    required EdgeInsets footerPadding,
    required double footerBottomInset,
    required bool zeigeNaechstesFeld,
  }) {
    const Color footerBg = Colors.black87;
    final ButtonStyle kompaktButtonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(0, tastaturOffen ? 36 : 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return ColoredBox(
      color: footerBg,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x52FFFFFF))),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, -2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: footerPadding.add(
            EdgeInsets.only(bottom: footerBottomInset),
          ),
          child: Row(
            children: <Widget>[
              if (zeigeNaechstesFeld) ...<Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _weiterZumNaechstenFeldUnten,
                    style: kompaktButtonStyle,
                    child: const Text('nächstes Feld'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _weiterZuSchritt2,
                  style: kompaktButtonStyle,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 6),
                      Text('Schritt 2'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
