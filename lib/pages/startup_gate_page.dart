import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/cinema.dart';
import 'package:kino_bar_app/pages/cinema_selection_page.dart';
import 'package:kino_bar_app/pages/start_menu_page.dart';
import 'package:kino_bar_app/storage/local_store.dart';

class StartupGatePage extends StatefulWidget {
  const StartupGatePage({super.key});

  static const String routeName = '/';

  @override
  State<StartupGatePage> createState() => _StartupGatePageState();
}

class _StartupGatePageState extends State<StartupGatePage> {
  @override
  void initState() {
    super.initState();
    _routeFromStoredCinema();
  }

  Future<void> _routeFromStoredCinema() async {
    final String? activeCinemaId = await LocalStore.loadActiveCinemaId();
    if (!mounted) {
      return;
    }

    final String targetRoute =
        CinemaRepository.byId(activeCinemaId ?? '') == null
        ? CinemaSelectionPage.routeName
        : StartMenuPage.routeName;

    Navigator.of(
      context,
    ).pushReplacementNamed(targetRoute, arguments: activeCinemaId);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
