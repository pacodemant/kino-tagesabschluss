import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schauburg Tagesabschluss',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const CinemaSelectionPage(),
    );
  }
}

class Cinema {
  const Cinema({required this.id, required this.name});

  final String id;
  final String name;
}

class CinemaSelectionPage extends StatefulWidget {
  const CinemaSelectionPage({super.key});

  @override
  State<CinemaSelectionPage> createState() => _CinemaSelectionPageState();
}

class _CinemaSelectionPageState extends State<CinemaSelectionPage> {
  static const List<Cinema> _cinemas = <Cinema>[
    Cinema(id: 'kino_01', name: 'Schauburg Karlsruhe'),
    Cinema(id: 'kino_02', name: 'Cinema Paradiso'),
    Cinema(id: 'kino_03', name: 'Lichtspielhaus Nord'),
    Cinema(id: 'kino_04', name: 'Filmforum West'),
  ];

  String? _selectedCinemaId;

  void _selectCinema(String cinemaId) {
    setState(() {
      _selectedCinemaId = cinemaId;
    });
  }

  Cinema? get _selectedCinema {
    for (final Cinema cinema in _cinemas) {
      if (cinema.id == _selectedCinemaId) {
        return cinema;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Schauburg Tagesabschluss'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Kino auswählen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            for (final Cinema cinema in _cinemas) ...<Widget>[
              ElevatedButton(
                onPressed: () => _selectCinema(cinema.id),
                child: Text('${cinema.name} (${cinema.id})'),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            Text(
              _selectedCinema == null
                  ? 'Noch kein Kino ausgewählt'
                  : 'Ausgewählt: ${_selectedCinema!.name} (${_selectedCinema!.id})',
            ),
          ],
        ),
      ),
    );
  }
}
