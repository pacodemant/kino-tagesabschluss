import 'package:kino_bar_app/pages/tagesabschluss_schritt2/models/zahlungsart_zeile.dart';

// Zweck: Kartenart-Betraege des Schritt-2-Entwurfs ueber den
// Kartenart-NAMEN speichern und wiederherstellen (Run 483).
//
// Vorher (seit Run 274a) wurden nur die Betraege als Positionsliste
// gespeichert, in der aktuellen Zeilen-Reihenfolge. Nach einem Scan
// sortiert Schritt 2 die Zeilen aber in Beleg-Reihenfolge um
// (_sortiereZahlungsartenNachBeleg), beim Neuaufbau entstehen sie wieder
// in Config-Reihenfolge. Die Betraege rutschten dadurch auf andere
// Kartenarten (06.10.2026 live bei Flurbocash: MasterCard -> Lastschrift,
// Visa -> MasterCard, Summe unveraendert und daher unbemerkt).
class Schritt2ZahlungsartEntwurf {
  const Schritt2ZahlungsartEntwurf._();

  /// Entwurf-Key fuer das Format nach Namen (seit Run 483).
  static const String entwurfKey = 'zahlungsartBetraegeNachName';

  /// Entwurf-Key des alten Positions-Formats (bis Run 482), nur noch
  /// gelesen.
  static const String altEntwurfKey = 'zahlungsartBetragCentWerte';

  /// Pro Beleg die bekannten Kartenart-Zeilen in Anzeige-Reihenfolge als
  /// {name, betragCent}. Die Reihenfolge wird mitgespeichert, damit die
  /// Tabelle nach dem Laden genauso aussieht wie vorher.
  static List<List<Map<String, Object?>>> zumSpeichern(
    List<List<ZahlungsartZeile>> zahlungsartZeilen,
  ) {
    return <List<Map<String, Object?>>>[
      for (final List<ZahlungsartZeile> belegZeilen in zahlungsartZeilen)
        <Map<String, Object?>>[
          for (final ZahlungsartZeile z in belegZeilen)
            if (!z.istUnbekannt)
              <String, Object?>{'name': z.name, 'betragCent': z.betragCentWert},
        ],
    ];
  }

  /// Ordnet die gespeicherten Betraege den Zeilen ueber den Namen zu und
  /// liefert die Zeilen in gespeicherter Reihenfolge zurueck (nicht
  /// gespeicherte Zeilen hinten, in ihrer bisherigen Reihenfolge).
  /// Unbekannte Namen (z. B. Config inzwischen geaendert) werden
  /// ignoriert, statt einen Betrag einer falschen Kartenart zuzuschlagen.
  static List<ZahlungsartZeile> wiederherstellen(
    List<ZahlungsartZeile> zeilen,
    List<dynamic> gespeichert,
  ) {
    final List<ZahlungsartZeile> sortiert = <ZahlungsartZeile>[];
    for (final dynamic eintrag in gespeichert) {
      if (eintrag is! Map) continue;
      final Object? name = eintrag['name'];
      if (name is! String) continue;
      for (final ZahlungsartZeile zeile in zeilen) {
        if (zeile.istUnbekannt || sortiert.contains(zeile)) continue;
        if (zeile.name == name) {
          zeile.betragCentWert = (eintrag['betragCent'] as num?)?.toInt();
          sortiert.add(zeile);
          break;
        }
      }
    }
    for (final ZahlungsartZeile zeile in zeilen) {
      if (!sortiert.contains(zeile)) sortiert.add(zeile);
    }
    return sortiert;
  }

  /// Altes Positions-Format: Die Positionen passen nur sicher, wenn fuer
  /// den Beleg nie gescannt wurde (dann wurde nicht umsortiert). Nach
  /// einem Scan ist die gespeicherte Reihenfolge unbekannt, die Betraege
  /// werden deshalb verworfen statt womoeglich verrutscht uebernommen.
  /// Liefert true, wenn Betraege uebernommen wurden.
  static bool wiederherstellenAltformat(
    List<ZahlungsartZeile> zeilen,
    List<dynamic> betraege, {
    required bool scanHatStattgefunden,
  }) {
    if (scanHatStattgefunden) return false;
    final List<ZahlungsartZeile> bekannte =
        zeilen.where((ZahlungsartZeile z) => !z.istUnbekannt).toList();
    for (int i = 0; i < bekannte.length && i < betraege.length; i++) {
      bekannte[i].betragCentWert = (betraege[i] as num?)?.toInt();
    }
    return true;
  }
}
