class ZahlungsartErgebnis {
  ZahlungsartErgebnis({
    required this.art,
    required this.anzahl,
    required this.betragCent,
  });

  factory ZahlungsartErgebnis.fromJson(Map<String, dynamic> json) {
    return ZahlungsartErgebnis(
      art: json['art'] as String? ?? '',
      anzahl: (json['anzahl'] as num?)?.toInt() ?? 0,
      betragCent: (json['betrag_cent'] as num?)?.toInt(),
    );
  }

  final String art;
  final int anzahl;
  final int? betragCent;
}

class BelegScanErgebnis {
  BelegScanErgebnis({
    this.terminalId,
    this.datum,
    this.uhrzeit,
    this.belegNrVon,
    this.belegNrBis,
    this.zahlungsarten = const <ZahlungsartErgebnis>[],
    this.gesamtAnzahl,
    this.gesamtBetragCent,
    this.hinweis,
  });

  factory BelegScanErgebnis.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? zahlungsartenRoh =
        json['zahlungsarten'] as List<dynamic>?;
    return BelegScanErgebnis(
      terminalId: json['terminal_id'] as String?,
      datum: json['datum'] as String?,
      uhrzeit: json['uhrzeit'] as String?,
      belegNrVon: json['beleg_nr_von'] as String?,
      belegNrBis: json['beleg_nr_bis'] as String?,
      zahlungsarten: zahlungsartenRoh
              ?.map((dynamic e) =>
                  ZahlungsartErgebnis.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ZahlungsartErgebnis>[],
      gesamtAnzahl: (json['gesamt_anzahl'] as num?)?.toInt(),
      gesamtBetragCent: (json['gesamt_betrag_cent'] as num?)?.toInt(),
      hinweis: json['hinweis'] as String?,
    );
  }

  final String? terminalId;
  final String? datum;
  final String? uhrzeit;
  final String? belegNrVon;
  final String? belegNrBis;
  final List<ZahlungsartErgebnis> zahlungsarten;
  final int? gesamtAnzahl;
  final int? gesamtBetragCent;
  final String? hinweis;

  bool get betraegePlausibel {
    if (gesamtBetragCent == null) return false;
    if (zahlungsarten.any((ZahlungsartErgebnis z) => z.betragCent == null)) {
      return false;
    }
    final int summe = zahlungsarten.fold(
        0, (int s, ZahlungsartErgebnis z) => s + (z.betragCent ?? 0));
    return summe == gesamtBetragCent;
  }

  bool get anzahlPlausibel {
    if (gesamtAnzahl == null) return false;
    final int summe =
        zahlungsarten.fold(0, (int s, ZahlungsartErgebnis z) => s + z.anzahl);
    return summe == gesamtAnzahl;
  }

  bool get istPlausibel => betraegePlausibel && anzahlPlausibel;
}
