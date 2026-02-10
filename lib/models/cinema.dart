class Cinema {
  const Cinema({required this.id, required this.name});

  final String id;
  final String name;
}

class CinemaRepository {
  static const List<Cinema> cinemas = <Cinema>[
    Cinema(id: 'kino_01', name: 'Schauburg'),
    Cinema(id: 'kino_02', name: 'Gondel'),
    Cinema(id: 'kino_03', name: 'Atlantis'),
    Cinema(id: 'kino_04', name: 'Cinema Ostertor'),
  ];

  static Cinema? byId(String id) {
    for (final Cinema cinema in cinemas) {
      if (cinema.id == id) {
        return cinema;
      }
    }
    return null;
  }
}
