class Kino {
  const Kino({
    required this.id,
    required this.name,
    this.hatGetraenke = false,
    this.hatWechselgeld = false,
  });

  final String id;
  final String name;
  final bool hatGetraenke;
  final bool hatWechselgeld;
}

class KinoRepository {
  static const List<Kino> kinos = <Kino>[
    Kino(id: 'kino_01', name: 'Schauburg', hatGetraenke: true, hatWechselgeld: true),
    Kino(id: 'kino_02', name: 'Gondel'),
    Kino(id: 'kino_03', name: 'Atlantis', hatGetraenke: true, hatWechselgeld: true),
    Kino(id: 'kino_04', name: 'Cinema Ostertor', hatGetraenke: true, hatWechselgeld: true),
    Kino(id: 'kino_05', name: 'Bar Tabak'),
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
