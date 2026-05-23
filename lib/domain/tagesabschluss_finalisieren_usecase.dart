import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
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
    // Rohdaten aus Schritt 1 – optional, damit bestehende Aufrufer unverändert bleiben
    this.stueckzahlen,
    this.loseMuenzenNachArtCent,
    this.umschlaege,
    // Ausgaben-Einzelposten aus Schritt 2
    this.ausgabenBetraegeCent,
    this.ausgabenLabels,
    // EC-Beleg-Labels aus Schritt 2
    this.ecBelegeLabels,
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

  // Stückzahlen/Beträge je Denomination aus Schritt 1 (IDs: note_xxx, roll_xxx, coin_xxx)
  final Map<String, int>? stueckzahlen;
  final Map<String, int>? loseMuenzenNachArtCent;
  // Umschlag-Einzeleinträge aus Schritt 1
  final List<UmschlagEintrag>? umschlaege;
  // Ausgaben-Einzelposten aus Schritt 2
  final List<int>? ausgabenBetraegeCent;
  final List<String>? ausgabenLabels;
  // EC-Beleg-Labels aus Schritt 2
  final List<String>? ecBelegeLabels;
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

  static const Set<String> _kupferCoinIds = <String>{
    'coin_1c',
    'coin_2c',
    'coin_5c',
  };

  /// Finalisiert die Tagesabrechnung und berechnet alle Summen zentral.
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

    // Rohdaten Geldzählung aus stueckzahlen-Map ableiten
    Map<String, int>? scheineStueckzahlen;
    Map<String, int>? rollenStueckzahlen;
    if (eingabe.stueckzahlen != null) {
      scheineStueckzahlen = <String, int>{};
      rollenStueckzahlen = <String, int>{};
      for (final MapEntry<String, int> e in eingabe.stueckzahlen!.entries) {
        if (e.value <= 0) continue;
        if (e.key.startsWith('note_')) {
          scheineStueckzahlen[e.key] = e.value;
        } else if (e.key.startsWith('roll_')) {
          rollenStueckzahlen[e.key] = e.value;
        }
      }
    }

    // Silber- und Kupfermünzen aus Betrag-Map summieren
    int? silberMuenzenCent;
    int? kupferMuenzenCent;
    if (eingabe.loseMuenzenNachArtCent != null) {
      int silber = 0;
      int kupfer = 0;
      for (final MapEntry<String, int> e
          in eingabe.loseMuenzenNachArtCent!.entries) {
        if (_kupferCoinIds.contains(e.key)) {
          kupfer += e.value;
        } else {
          silber += e.value;
        }
      }
      silberMuenzenCent = silber;
      kupferMuenzenCent = kupfer;
    }

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
      scheineStueckzahlen:
          scheineStueckzahlen?.isNotEmpty == true ? scheineStueckzahlen : null,
      rollenStueckzahlen:
          rollenStueckzahlen?.isNotEmpty == true ? rollenStueckzahlen : null,
      silberMuenzenCent: silberMuenzenCent,
      kupferMuenzenCent: kupferMuenzenCent,
      umschlagBetraegeCent: eingabe.umschlaege
          ?.map((UmschlagEintrag e) => e.betragCent)
          .toList(),
      ausgabenBetraegeCent: eingabe.ausgabenBetraegeCent != null &&
              eingabe.ausgabenBetraegeCent!.isNotEmpty
          ? List<int>.from(eingabe.ausgabenBetraegeCent!)
          : null,
      ausgabenLabels: eingabe.ausgabenLabels != null &&
              eingabe.ausgabenLabels!.isNotEmpty
          ? List<String>.from(eingabe.ausgabenLabels!)
          : null,
      ecBelegeLabels: eingabe.ecBelegeLabels != null &&
              eingabe.ecBelegeLabels!.isNotEmpty
          ? List<String>.from(eingabe.ecBelegeLabels!)
          : null,
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
    if (eingabe.ausgabenCent < 0) {
      throw const TagesabschlussValidierungsFehler(
        'Ausgaben duerfen nicht negativ sein.',
      );
    }
    if (eingabe.ecBelegeCent.any((int wert) => wert < 0)) {
      throw const TagesabschlussValidierungsFehler(
        'EC-Belege duerfen nicht negativ sein.',
      );
    }
  }
}
