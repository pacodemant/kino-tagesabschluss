class ZahlungsartErgebnis {
  ZahlungsartErgebnis({
    required this.art,
    required this.betragCent,
    this.tid,
  });

  factory ZahlungsartErgebnis.fromJson(Map<String, dynamic> json) {
    return ZahlungsartErgebnis(
      art: json['art'] as String? ?? '',
      betragCent: (json['betrag_cent'] as num?)?.toInt(),
      tid: json['tid'] as String?,
    );
  }

  final String art;
  final int? betragCent;
  final String? tid;
}

class BelegScanErgebnis {
  BelegScanErgebnis({
    this.keinTerminalBeleg = false,
    this.terminalId,
    this.datum,
    this.uhrzeit,
    this.belegNrVon,
    this.belegNrBis,
    this.zahlungsarten = const <ZahlungsartErgebnis>[],
    this.gesamtBetragCent,
    this.hinweis,
  });

  factory BelegScanErgebnis.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? zahlungsartenRoh =
        json['zahlungsarten'] as List<dynamic>?;
    return BelegScanErgebnis(
      keinTerminalBeleg: (json['kein_terminal_beleg'] as bool?) ?? false,
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
      gesamtBetragCent: (json['gesamt_betrag_cent'] as num?)?.toInt(),
      hinweis: json['hinweis'] as String?,
    );
  }

  final bool keinTerminalBeleg;
  final String? terminalId;
  final String? datum;
  final String? uhrzeit;
  final String? belegNrVon;
  final String? belegNrBis;
  final List<ZahlungsartErgebnis> zahlungsarten;
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

  bool get istPlausibel => betraegePlausibel;
}

class BelegScanDialogErgebnis {
  const BelegScanDialogErgebnis({
    required BelegScanErgebnis this.ergebnis,
    required this.kachelOeffnen,
  });

  const BelegScanDialogErgebnis.nochmalScannen()
      : ergebnis = null,
        kachelOeffnen = false;

  final BelegScanErgebnis? ergebnis;
  final bool kachelOeffnen;

  bool get istNeueScanAnfrage => ergebnis == null;
}
