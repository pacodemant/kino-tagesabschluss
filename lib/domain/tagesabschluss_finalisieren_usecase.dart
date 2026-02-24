import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';

/// Eingabedaten aus Schritt 1 und 2 fuer den finalen Abschluss.
class TagesabschlussFinalisierenEingabe {
  const TagesabschlussFinalisierenEingabe({
    required this.kinoId,
    required this.kinoName,
    required this.scheineCent,
    required this.loseMuenzenCent,
    required this.rollenCent,
    required this.umschlaegeCent,
    required this.wechselgeldSollwertCent,
    required this.kinoSollCent,
    required this.bistroSollCent,
    required this.ausgabenCent,
    required this.ecBelegeCent,
    required this.differenzAnfangsbestandCent,
  });

  final String kinoId;
  final String kinoName;
  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int wechselgeldSollwertCent;
  final int kinoSollCent;
  final int bistroSollCent;
  final int ausgabenCent;
  final List<int> ecBelegeCent;
  final int differenzAnfangsbestandCent;
}

/// Fehler fuer einfache Validierungsprobleme beim Finalisieren.
class TagesabschlussValidierungsFehler implements Exception {
  const TagesabschlussValidierungsFehler(this.nachricht);

  final String nachricht;

  @override
  String toString() => nachricht;
}

/// Erstellt das finale Abschluss-Objekt aus den gesammelten Schritten.
class TagesabschlussFinalisierenUsecase {
  const TagesabschlussFinalisierenUsecase();

  /// Finalisiert den Tagesabschluss und berechnet alle Summen zentral.
  TagesabschlussFinal finalisieren({
    required TagesabschlussFinalisierenEingabe eingabe,
    DateTime? jetzt,
  }) {
    _validiere(eingabe);

    final int kassenbestandGesamtCent =
        TagesabschlussBerechnung.kassenbestandGesamtCent(
          scheineCent: eingabe.scheineCent,
          loseMuenzenCent: eingabe.loseMuenzenCent,
          rollenCent: eingabe.rollenCent,
          umschlaegeCent: eingabe.umschlaegeCent,
        );

    final int barBestandAbzglWechselgeldCent =
        TagesabschlussBerechnung.barumsatzBereinigtCent(
          kassenbestandGesamtCent: kassenbestandGesamtCent,
          wechselgeldSollwertCent: eingabe.wechselgeldSollwertCent,
        );

    final int ecUmsatzGesamtCent = TagesabschlussBerechnung.summeCentBetraege(
      eingabe.ecBelegeCent,
    );

    final int gesamtSollCent = TagesabschlussBerechnung.gesamtSollCent(
      kinoSollCent: eingabe.kinoSollCent,
      bistroSollCent: eingabe.bistroSollCent,
      ausgabenCent: eingabe.ausgabenCent,
    );

    final int gesamtIstCent = TagesabschlussBerechnung.gesamtIstCent(
      ecUmsatzGesamtCent: ecUmsatzGesamtCent,
      barBestandAbzglWechselgeldCent: barBestandAbzglWechselgeldCent,
    );

    final int differenzGesamtCent =
        TagesabschlussBerechnung.differenzTagesabschlussCent(
          gesamtIstCent: gesamtIstCent,
          gesamtSollCent: gesamtSollCent,
        );

    final DateTime zeitstempel = jetzt ?? DateTime.now();

    return TagesabschlussFinal(
      kinoId: eingabe.kinoId,
      kinoName: eingabe.kinoName,
      datum: DateTime(zeitstempel.year, zeitstempel.month, zeitstempel.day),
      createdAt: zeitstempel,
      scheineCent: eingabe.scheineCent,
      loseMuenzenCent: eingabe.loseMuenzenCent,
      rollenCent: eingabe.rollenCent,
      umschlaegeCent: eingabe.umschlaegeCent,
      kassenbestandGesamtCent: kassenbestandGesamtCent,
      wechselgeldSollwertCent: eingabe.wechselgeldSollwertCent,
      barBestandAbzglWechselgeldCent: barBestandAbzglWechselgeldCent,
      kinoSollCent: eingabe.kinoSollCent,
      bistroSollCent: eingabe.bistroSollCent,
      ausgabenCent: eingabe.ausgabenCent,
      ecBelegeCent: List<int>.from(eingabe.ecBelegeCent),
      ecUmsatzGesamtCent: ecUmsatzGesamtCent,
      gesamtSollCent: gesamtSollCent,
      gesamtIstCent: gesamtIstCent,
      differenzGesamtCent: differenzGesamtCent,
      differenzAnfangsbestandCent: eingabe.differenzAnfangsbestandCent,
    );
  }

  /// Prueft nur minimale Pflichtbedingungen ohne optionale Felder zu erzwingen.
  void _validiere(TagesabschlussFinalisierenEingabe eingabe) {
    if (eingabe.kinoId.trim().isEmpty) {
      throw const TagesabschlussValidierungsFehler('Kino-ID fehlt.');
    }
    if (eingabe.kinoSollCent < 0 || eingabe.bistroSollCent < 0) {
      throw const TagesabschlussValidierungsFehler(
        'SOLL-Werte duerfen nicht negativ sein.',
      );
    }
    if (eingabe.ausgabenCent < 0 || eingabe.differenzAnfangsbestandCent < 0) {
      throw const TagesabschlussValidierungsFehler(
        'Ausgaben oder Anfangsbestandsdifferenz sind ungueltig.',
      );
    }
    if (eingabe.ecBelegeCent.any((int wert) => wert < 0)) {
      throw const TagesabschlussValidierungsFehler(
        'EC-Belege duerfen nicht negativ sein.',
      );
    }
  }
}
