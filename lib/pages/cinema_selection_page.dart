import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/cinema.dart';
import 'package:kino_bar_app/pages/start_menu_page.dart';
import 'package:kino_bar_app/storage/local_store.dart';

class CinemaSelectionPage extends StatefulWidget {
  const CinemaSelectionPage({super.key});

  static const String routeName = '/cinema-selection';

  @override
  State<CinemaSelectionPage> createState() => _CinemaSelectionPageState();
}

class _CinemaSelectionPageState extends State<CinemaSelectionPage> {
  Future<void> _selectCinema(String cinemaId) async {
    await LocalStore.saveActiveCinemaId(cinemaId);
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushReplacementNamed(StartMenuPage.routeName, arguments: cinemaId);
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
            for (final Cinema cinema in CinemaRepository.cinemas) ...<Widget>[
              ElevatedButton(
                onPressed: () => _selectCinema(cinema.id),
                child: Text(cinema.name),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
