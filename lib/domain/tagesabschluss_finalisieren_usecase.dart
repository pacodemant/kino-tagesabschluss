import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/utils/tid_eingabe.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';

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
    this.wechselgeldEntnahmeCent,
    this.wechselgeldEntnahmeGrund,
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
    this.mitarbeiterName,
    this.anmerkung,
    // EC-Belegscan-Metadaten aus Schritt 2
    this.terminalId,
    this.belegNrVon,
    this.belegNrBis,
    this.ecUhrzeit,
    this.zahlungsartenAufschluesselung,
    this.ecBelegeFotosBase64,
    this.ecBelegeFotosMediaTypen,
    // TID des am Kino-Kassensystem angeschlossenen Terminals (Run 486)
    this.kinokasseTid,
    // SB: Kartenbetrag laut Kinokasse statt Terminalbetrag (Run 503)
    this.kinokasseKarteKorrekturCent,
    // TIDs mit "heute keine Umsätze" (Run 492)
    this.keineUmsaetzeTids,
    // TIDs mit "Kein Beleg möglich" + Vermerke nur für den Versand (Run 498)
    this.keinBelegMoeglichTids,
    this.sendeVermerke,
  });

  final String kinoId;
  final String kinoName;
  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int wechselgeldSollwertCent;
  // Entnahme aus der Wechselgeldkasse (z. B. Rollengeld-Vorschuss) – wird
  // dem gezählten Bestand vor dem Sollwert-Abzug wieder hinzugerechnet.
  final int? wechselgeldEntnahmeCent;
  final String? wechselgeldEntnahmeGrund;
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
  final String? mitarbeiterName;
  final String? anmerkung;
  // EC-Belegscan-Metadaten aus Schritt 2
  final String? terminalId;
  final String? belegNrVon;
  final String? belegNrBis;
  final String? ecUhrzeit;
  final List<ZahlungsartErgebnis>? zahlungsartenAufschluesselung;
  // EC-Belegfotos (base64 + media_type) je Beleg-Index aus Schritt 2
  final List<String>? ecBelegeFotosBase64;
  final List<String>? ecBelegeFotosMediaTypen;
  // TID des am Kino-Kassensystem angeschlossenen Terminals (Einstellung
  // pro Kino, Run 486) – dessen Kartenumsatz kommt zum Kino SOLL dazu.
  final String? kinokasseTid;
  // Kartenbetrag laut Kinokasse (Run 503): ersetzt im Kino SOLL den
  // Terminalbetrag, wenn am Terminal auch Getränke bezahlt wurden (die
  // stecken schon im Bistro SOLL). null = Terminalbetrag gilt.
  final int? kinokasseKarteKorrekturCent;
  final List<String>? keineUmsaetzeTids;
  final List<String>? keinBelegMoeglichTids;
  final List<String>? sendeVermerke;
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
          wechselgeldEntnahmeCent: eingabe.wechselgeldEntnahmeCent ?? 0,
        );

    final int ecUmsatzGesamtCent = TagesabschlussBerechnung.summeCentBetraege(
      eingabe.ecBelegeCent,
    );

    final int kinokasseKarteTerminalCent =
        TagesabschlussBerechnung.kinokasseKarteCent(
          ecBelegeCent: eingabe.ecBelegeCent,
          ecBelegeLabels: eingabe.ecBelegeLabels,
          kinokasseTid: eingabe.kinokasseTid,
        );
    // Korrektur gleich dem Terminalbetrag zählt nicht als Korrektur.
    final int? korrektur = eingabe.kinokasseKarteKorrekturCent;
    final bool karteKorrigiert =
        korrektur != null && korrektur != kinokasseKarteTerminalCent;
    final int kinokasseKarteCent =
        karteKorrigiert ? korrektur : kinokasseKarteTerminalCent;

    final int gesamtSollCent = TagesabschlussBerechnung.gesamtSollCent(
      kinoSollCent: eingabe.kinoSollCent,
      bistroSollCent: eingabe.bistroSollCent,
      ausgabenCent: eingabe.ausgabenCent,
      kinokasseKarteCent: kinokasseKarteCent,
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
    final DateTime geschaeftstag =
        DatumsHelper.logischerAbrechnungsTag(jetzt: zeitstempel);

    return TagesabschlussFinal(
      kinoId: eingabe.kinoId,
      kinoName: eingabe.kinoName,
      datum: geschaeftstag,
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
      wechselgeldEntnahmeCent:
          (eingabe.wechselgeldEntnahmeCent ?? 0) > 0
              ? eingabe.wechselgeldEntnahmeCent
              : null,
      wechselgeldEntnahmeGrund: eingabe.wechselgeldEntnahmeGrund?.isNotEmpty ==
              true
          ? eingabe.wechselgeldEntnahmeGrund
          : null,
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
      mitarbeiterName: eingabe.mitarbeiterName?.isNotEmpty == true
          ? eingabe.mitarbeiterName
          : null,
      anmerkung: eingabe.anmerkung?.isNotEmpty == true
          ? eingabe.anmerkung
          : null,
      terminalId: eingabe.terminalId,
      belegNrVon: eingabe.belegNrVon,
      belegNrBis: eingabe.belegNrBis,
      ecUhrzeit: eingabe.ecUhrzeit,
      zahlungsartenAufschluesselung: eingabe.zahlungsartenAufschluesselung,
      ecBelegeFotosBase64: eingabe.ecBelegeFotosBase64 != null &&
              eingabe.ecBelegeFotosBase64!.isNotEmpty
          ? List<String>.from(eingabe.ecBelegeFotosBase64!)
          : null,
      ecBelegeFotosMediaTypen: eingabe.ecBelegeFotosMediaTypen != null &&
              eingabe.ecBelegeFotosMediaTypen!.isNotEmpty
          ? List<String>.from(eingabe.ecBelegeFotosMediaTypen!)
          : null,
      kinokasseKarteCent: kinokasseKarteCent,
      kinokasseKarteTerminalCent:
          karteKorrigiert ? kinokasseKarteTerminalCent : null,
      keineUmsaetzeTids: _keineUmsaetzeTidsOhneBetrag(eingabe),
      keinBelegMoeglichTids: _nichtLeerOderNull(eingabe.keinBelegMoeglichTids),
      sendeVermerke: _nichtLeerOderNull(<String>[
        ...?eingabe.sendeVermerke,
        if (karteKorrigiert)
          kinokasseKarteVermerk(
            korrigiertCent: korrektur,
            terminalCent: kinokasseKarteTerminalCent,
            tid: eingabe.kinokasseTid,
          ),
      ]),
    );
  }

  /// Vermerk für den Kommentar an Flurbocash (Run 503), für die MA
  /// unsichtbar (siehe sendeVermerke).
  static String kinokasseKarteVermerk({
    required int korrigiertCent,
    required int terminalCent,
    String? tid,
  }) {
    final String bereinigt = TidEingabe.bereinige(tid ?? '');
    return 'Kino-Karte lt. Kinokasse '
        '${TagesabschlussFormatierung.formatiereEuro(korrigiertCent)} statt '
        'Terminal${bereinigt.isEmpty ? '' : ' $bereinigt'} '
        '${TagesabschlussFormatierung.formatiereEuro(terminalCent)}';
  }

  static List<String>? _nichtLeerOderNull(List<String>? liste) {
    if (liste == null || liste.isEmpty) return null;
    return List<String>.from(liste);
  }

  /// Nur TIDs, für die tatsächlich 0 € erfasst sind (Run 492) — wurde
  /// nach "keine Umsätze" doch ein Beleg erfasst, gilt der Beleg.
  static List<String>? _keineUmsaetzeTidsOhneBetrag(
    TagesabschlussFinalisierenEingabe eingabe,
  ) {
    final List<String>? tids = eingabe.keineUmsaetzeTids;
    if (tids == null || tids.isEmpty) return null;
    final List<String> labels = eingabe.ecBelegeLabels ?? const <String>[];
    final List<String> ergebnis = <String>[
      for (final String roh in tids)
        if (TidEingabe.bereinige(roh).isNotEmpty &&
            !<int>[
              for (int i = 0; i < eingabe.ecBelegeCent.length; i++)
                if (i < labels.length &&
                    TidEingabe.bereinige(labels[i]) == TidEingabe.bereinige(roh))
                  eingabe.ecBelegeCent[i],
            ].any((int c) => c != 0))
          TidEingabe.bereinige(roh),
    ];
    return ergebnis.isEmpty ? null : ergebnis;
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
    final int wechselgeldEntnahmeCent = eingabe.wechselgeldEntnahmeCent ?? 0;
    if (wechselgeldEntnahmeCent < 0) {
      throw const TagesabschlussValidierungsFehler(
        'Wechselgeldentnahme darf nicht negativ sein.',
      );
    }
    final bool hatGrund =
        eingabe.wechselgeldEntnahmeGrund?.trim().isNotEmpty == true;
    if (wechselgeldEntnahmeCent > 0 && !hatGrund) {
      throw const TagesabschlussValidierungsFehler(
        'Bitte einen Grund für die Wechselgeldentnahme angeben.',
      );
    }
    if (wechselgeldEntnahmeCent == 0 && hatGrund) {
      throw const TagesabschlussValidierungsFehler(
        'Bitte einen Betrag für die Wechselgeldentnahme angeben.',
      );
    }
  }
}
