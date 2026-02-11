class Kino {
  const Kino({required this.id, required this.name});

  final String id;
  final String name;
}

class KinoRepository {
  static const List<Kino> kinos = <Kino>[
    Kino(id: 'kino_01', name: 'Schauburg'),
    Kino(id: 'kino_02', name: 'Gondel'),
    Kino(id: 'kino_03', name: 'Atlantis'),
    Kino(id: 'kino_04', name: 'Cinema Ostertor'),
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
