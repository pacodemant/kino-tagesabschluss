/// Vom Flurbocash-Server bestätigte Abrechnung eines Kinos an einem
/// Abrechnungstag (seit Run 476, seit Run 477 pro Kino + Tag gespeichert,
/// siehe ApiUploadService): [reportId] ist der Tagesbericht (Standort +
/// Datum), [settlementNummer] die Abrechnung darin (1-4). Jeder weitere
/// Versand für denselben Tag schickt diese Nummer mit — Flurbocash
/// überschreibt dann (Korrektur), statt eine zusätzliche anzulegen.
///
/// [tids] sind die zuletzt gesendeten Terminal-IDs — Flurbocash
/// aktualisiert Terminals bei einer Korrektur per Upsert, ein nicht mehr
/// mitgesendetes Terminal bliebe dort sonst mit den alten Beträgen
/// stehen (siehe ApiUploadService.settlementsBody).
class FlurbocashZuordnung {
  const FlurbocashZuordnung({
    required this.reportId,
    required this.settlementNummer,
    this.tids = const <String>[],
  });

  final int reportId;
  final int settlementNummer;
  final List<String> tids;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'reportId': reportId,
      'settlementNummer': settlementNummer,
      'tids': tids,
    };
  }

  /// null bei fehlenden/ungültigen Pflichtwerten (defensiv, alte oder
  /// beschädigte Einträge dürfen das Laden des Verlaufs nicht stören).
  static FlurbocashZuordnung? fromJson(Object? json) {
    if (json is! Map) return null;
    final Object? reportId = json['reportId'];
    final Object? nummer = json['settlementNummer'];
    if (reportId is! num || nummer is! num) return null;
    final Object? tidsRoh = json['tids'];
    return FlurbocashZuordnung(
      reportId: reportId.toInt(),
      settlementNummer: nummer.toInt(),
      tids: tidsRoh is List ? tidsRoh.whereType<String>().toList() : <String>[],
    );
  }
}
