part of 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';

// Zweck: Entkoppelt große UI-Build-Helfer aus Schritt 1.
extension _Schritt1UiBuilder on _TagesabschlussSchritt1SeiteState {
  Widget _baueGruppenInhalt(
    List<Kassenzeile> zeilen,
    String gesamtbetragLabel, {
    String Function(int cent)? formatierer,
  }) {
    final String Function(int cent) nutzeFormatierer =
        formatierer ?? _formatiereEuro;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in zeilen) ...<Widget>[
          _baueZeilenEintrag(zeile),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        Text(
          '$gesamtbetragLabel: ${nutzeFormatierer(_summeGruppe(zeilen))}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _baueZeilenEintrag(Kassenzeile zeile) {
    final int stueckzahl = _stueckzahlen[zeile.id] ?? 0;
    final int zwischensumme = stueckzahl * zeile.einzelwertCent;
    final FocusNode focusNode = _stueckzahlFocusNode[zeile.id]!;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            zeile.bezeichnung,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 96,
          child: _baueFeldMitKey(
            focusNode: focusNode,
            child: GanzzahlEingabefeld(
              textController: _stueckzahlController[zeile.id]!,
              focusNode: focusNode,
              schriftgroesse: 16,
              textInputAction: _textInputActionFuerSchritt1(focusNode),
              onChanged: (String wert) => _beiStueckzahlGeaendert(zeile, wert),
              onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt1(focusNode),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 95,
          child: Text(
            _formatiereEuro(zwischensumme),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _baueLoseMuenzenInhalt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in _loseMuenzarten) ...<Widget>[
          Builder(
            builder: (BuildContext _) {
              final FocusNode focusNode = _loseMuenzenFocusNode[zeile.id]!;
              return Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      zeile.bezeichnung,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 148,
                    child: _baueFeldMitKey(
                      focusNode: focusNode,
                      child: BetragCentEingabefeld(
                        textController: _loseMuenzenController[zeile.id]!,
                        focusNode: focusNode,
                        textInputAction: _textInputActionFuerSchritt1(
                          focusNode,
                        ),
                        onSubmitted: (_) =>
                            _beiEingabeAbgeschlossenSchritt1(focusNode),
                        onChanged: (String wert) =>
                            _beiLoseMuenzartBetragGeaendert(zeile.id, wert),
                        schriftgroesse: 15,
                        hinweisText: '0,00 €',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Text(
          'Gesamtbetrag Lose Münzen: ${_formatiereEuro(_loseMuenzenGesamtCent)}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _baueRollenInhalt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Kassenzeile zeile in _rollenOhneKupfer) ...<Widget>[
          _baueZeilenEintrag(zeile),
          const SizedBox(height: 8),
        ],
        if (!_kupferRollenSichtbar)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _zeigeKupferRollen,
              icon: const Icon(Icons.add),
              label: const Text('Kupfer-Rollen hinzufügen'),
            ),
          ),
        if (_kupferRollenSichtbar) ...<Widget>[
          const SizedBox(height: 8),
          for (final Kassenzeile zeile in _kupferRollen) ...<Widget>[
            _baueZeilenEintrag(zeile),
            const SizedBox(height: 8),
          ],
        ],
        const SizedBox(height: 4),
        Text(
          'Gesamtbetrag Rollen: ${_formatiereRollenAnzeige(_summeGruppe(_rollenSichtbar))}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatiereRollenAnzeige(int cent) {
    if (cent % 100 == 0) {
      return '${cent ~/ 100} €';
    }
    return _formatiereEuro(cent);
  }

  Widget _baueKartenzahlungenInhalt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < _kartenzahlungController.length; i++) ...<Widget>[
          Row(
            key: ValueKey<int>(_kartenzahlungIds[i]),
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Kartenzahlung',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 148,
                child: _baueFeldMitKey(
                  focusNode: _kartenzahlungFocusNode[i],
                  child: BetragCentEingabefeld(
                    textController: _kartenzahlungController[i],
                    focusNode: _kartenzahlungFocusNode[i],
                    textInputAction: _textInputActionFuerSchritt1(
                      _kartenzahlungFocusNode[i],
                    ),
                    onSubmitted: (_) => _beiEingabeAbgeschlossenSchritt1(
                      _kartenzahlungFocusNode[i],
                    ),
                    onChanged: (String wert) =>
                        _beiKartenzahlungBetragGeaendert(i, wert),
                    schriftgroesse: 15,
                    hinweisText: '0,00 €',
                  ),
                ),
              ),
              if (i > 0) ...<Widget>[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => _kartenzahlungEntfernen(i),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Kartenzahlung entfernen',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (_kartenzahlungenCent.first > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _kartenzahlungHinzufuegen,
              icon: const Icon(Icons.add),
              label: const Text('Kartenzahlung hinzufügen'),
            ),
          ),
        Text(
          'Gesamt Kartenzahlungen: ${_formatiereEuro(_kartenzahlungenSummeCent)}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
