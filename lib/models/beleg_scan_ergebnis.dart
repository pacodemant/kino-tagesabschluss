class ZahlungsartErgebnis {
  ZahlungsartErgebnis({
    required this.art,
    required this.betragCent,
    this.tid,
    this.belegIndex,
  });

  factory ZahlungsartErgebnis.fromJson(Map<String, dynamic> json) {
    return ZahlungsartErgebnis(
      art: json['art'] as String? ?? '',
      betragCent: (json['betrag_cent'] as num?)?.toInt(),
      tid: json['tid'] as String?,
      belegIndex: (json['belegIndex'] as num?)?.toInt(),
    );
  }

  final String art;
  final int? betragCent;
  final String? tid;

  /// Index des Belegs (EC-Kachel) in Schritt 2, aus dem diese Zeile
  /// stammt — seit Run 399a3. Getrennt von [tid], weil zwei Belege
  /// dieselbe TID tragen können (z. B. zwei Abrechnungen desselben
  /// Terminals am selben Tag) und trotzdem als eigenständige
  /// terminals[]-Einträge an Flurbocash gehen sollen, siehe
  /// ApiUploadService._terminalsListe(). Für vor Run 399a3 gespeicherte
  /// Abrechnungen (z. B. erneuter Versand aus dem Verlauf) null — dort
  /// greift weiterhin die alte Gruppierung nach TID als Fallback.
  final int? belegIndex;
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
