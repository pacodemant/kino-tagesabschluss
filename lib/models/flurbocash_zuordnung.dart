/// Vom Flurbocash-Server bestätigte Zuordnung einer lokal gespeicherten
/// Abrechnung (seit Run 476): [reportId] ist der Tagesbericht (Standort +
/// Datum), [settlementNummer] die einzelne Abrechnung darin (1-4). Ein
/// erneuter Versand mit dieser Nummer überschreibt die Abrechnung bei
/// Flurbocash (Korrektur), statt eine zusätzliche anzulegen.
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
