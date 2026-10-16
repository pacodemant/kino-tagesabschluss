class Kino {
  const Kino({
    required this.id,
    required this.name,
    required this.kuerzel,
    this.hatGetraenke = false,
    this.hatWechselgeld = false,
    this.hatBistro = false,
    this.maxAbrechnungenProTag = 1,
    this.anzahlTerminals = 4,
    this.fcLocationIdSandbox,
    this.fcLocationIdLive,
  });

  final String id;
  final String name;
  final String kuerzel;
  final bool hatGetraenke;
  final bool hatWechselgeld;
  /// Ob dieses Kino ein eigenes Bistro-SOLL in Schritt 2 der
  /// Tagesabrechnung hat (seit Run 424 zentral hier, vorher als
  /// `kinoId != 'kino_04'`-Vergleich an mehreren Stellen dupliziert).
  final bool hatBistro;
  final int maxAbrechnungenProTag;

  /// Anzahl Kartenterminals am Standort = Zeilen der Einstellungs-Kachel
  /// "TIDs" (Run 490, Stand Paco 2026-10-16). BT/GO noch unklar -> 4.
  /// Die TIDs selbst stehen nur in den Geräte-Einstellungen.
  final int anzahlTerminals;

  /// Flurbocash-location_id dieses Kinos in der Sandbox bzw. im
  /// Livesystem (Run 493). Die IDs sind in beiden Systemen verschieden
  /// und unabhängig von der App-internen [id]. Quelle: Yannik-Mails
  /// 16.06.2026 (Sandbox SB/AT/BT) und 08.10.2026 (GO/CO). null = noch
  /// nicht bekannt -> nur per Override in den Einstellungen nutzbar.
  final int? fcLocationIdSandbox;
  final int? fcLocationIdLive;
}

class KinoRepository {
  static const List<Kino> kinos = <Kino>[
    Kino(id: 'kino_03', name: 'Atlantis',         kuerzel: 'AT', hatGetraenke: true, hatWechselgeld: true, hatBistro: true, anzahlTerminals: 1, fcLocationIdSandbox: 3),
    Kino(id: 'kino_01', name: 'Schauburg',        kuerzel: 'SB', hatGetraenke: true, hatWechselgeld: true, hatBistro: true, anzahlTerminals: 3, fcLocationIdSandbox: 1),
    Kino(id: 'kino_04', name: 'Cinema Ostertor',  kuerzel: 'CO', hatGetraenke: true, hatWechselgeld: true, anzahlTerminals: 1, fcLocationIdSandbox: 6, fcLocationIdLive: 5),
    Kino(id: 'kino_02', name: 'Gondel',           kuerzel: 'GO', hatBistro: true, fcLocationIdSandbox: 5, fcLocationIdLive: 3),
    Kino(id: 'kino_05', name: 'Bar Tabak',        kuerzel: 'BT', hatBistro: true, maxAbrechnungenProTag: 2, fcLocationIdSandbox: 4),
  ];

  static Kino? nachId(String id) {
    for (final Kino kino in kinos) {
      if (kino.id == id) {
        return kino;
      }
    }
    return null;
  }
}
