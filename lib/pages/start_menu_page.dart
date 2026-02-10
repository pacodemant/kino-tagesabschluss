import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/cinema.dart';
import 'package:kino_bar_app/pages/cash_count_step1_page.dart';
import 'package:kino_bar_app/pages/cinema_selection_page.dart';
import 'package:kino_bar_app/pages/placeholder_page.dart';

class StartMenuPage extends StatelessWidget {
  const StartMenuPage({super.key, required this.cinema});

  static const String routeName = '/start-menu';

  final Cinema cinema;

  void _openClosureStep1(BuildContext context) {
    Navigator.of(context).pushNamed(
      CashCountStepPage.routeName,
      arguments: CashCountStep1Args(
        cinemaId: cinema.id,
        cinemaName: cinema.name,
      ),
    );
  }

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.of(
      context,
    ).pushNamed(PlaceholderPage.routeName, arguments: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(cinema.name),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(CinemaSelectionPage.routeName);
            },
            child: const Text('Kino wechseln'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _openClosureStep1(context),
              child: const Text('Tagesabschluss'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openPlaceholder(context, 'Getränke auffüllen'),
              child: const Text('Getränke auffüllen'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openPlaceholder(context, 'Einstellungen'),
              child: const Text('Einstellungen'),
            ),
          ],
        ),
      ),
    );
  }
}
