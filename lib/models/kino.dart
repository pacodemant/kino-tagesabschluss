class Kino {
  const Kino({
    required this.id,
    required this.name,
    required this.kuerzel,
    this.hatGetraenke = false,
    this.hatWechselgeld = false,
  });

  final String id;
  final String name;
  final String kuerzel;
  final bool hatGetraenke;
  final bool hatWechselgeld;
}

class KinoRepository {
  static const List<Kino> kinos = <Kino>[
    Kino(id: 'kino_01', name: 'Schauburg',       kuerzel: 'SB', hatGetraenke: true, hatWechselgeld: true),
    Kino(id: 'kino_02', name: 'Gondel',           kuerzel: 'GO'),
    Kino(id: 'kino_03', name: 'Atlantis',         kuerzel: 'AT', hatGetraenke: true, hatWechselgeld: true),
    Kino(id: 'kino_04', name: 'Cinema Ostertor',  kuerzel: 'CO', hatGetraenke: true, hatWechselgeld: true),
    Kino(id: 'kino_05', name: 'Bar Tabak',        kuerzel: 'BT'),
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
