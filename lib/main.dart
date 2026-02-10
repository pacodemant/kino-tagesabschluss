import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kino_bar_app/cash_count_step1_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: StartupGatePage.routeName,
      routes: <String, WidgetBuilder>{
        StartupGatePage.routeName: (_) => const StartupGatePage(),
        CinemaSelectionPage.routeName: (_) => const CinemaSelectionPage(),
        CashCountStep2PlaceholderPage.routeName: (_) =>
            const CashCountStep2PlaceholderPage(),
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == StartMenuPage.routeName) {
          final Object? arg = settings.arguments;
          if (arg is! String) {
            return MaterialPageRoute<void>(
              builder: (_) => const CinemaSelectionPage(),
              settings: const RouteSettings(
                name: CinemaSelectionPage.routeName,
              ),
            );
          }

          final String cinemaId = arg;
          final Cinema? cinema = CinemaRepository.byId(cinemaId);

          if (cinema == null) {
            return MaterialPageRoute<void>(
              builder: (_) => const CinemaSelectionPage(),
              settings: const RouteSettings(
                name: CinemaSelectionPage.routeName,
              ),
            );
          }

          return MaterialPageRoute<void>(
            builder: (_) => StartMenuPage(cinema: cinema),
            settings: settings,
          );
        }

        if (settings.name == PlaceholderPage.routeName) {
          final String title = settings.arguments as String? ?? 'Platzhalter';
          return MaterialPageRoute<void>(
            builder: (_) => PlaceholderPage(title: title),
            settings: settings,
          );
        }

        if (settings.name == CashCountStepPage.routeName) {
          final Object? arg = settings.arguments;
          if (arg is! CashCountStep1Args) {
            return MaterialPageRoute<void>(
              builder: (_) => const CinemaSelectionPage(),
              settings: const RouteSettings(
                name: CinemaSelectionPage.routeName,
              ),
            );
          }
          return MaterialPageRoute<void>(
            builder: (_) => CashCountStepPage(
              cinemaId: arg.cinemaId,
              cinemaName: arg.cinemaName,
            ),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}

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

class AppStorage {
  static const String activeCinemaIdKey = 'activeCinemaId';

  static Future<String?> loadActiveCinemaId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(activeCinemaIdKey);
  }

  static Future<void> saveActiveCinemaId(String cinemaId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(activeCinemaIdKey, cinemaId);
  }
}

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
    final String? activeCinemaId = await AppStorage.loadActiveCinemaId();
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

class CinemaSelectionPage extends StatefulWidget {
  const CinemaSelectionPage({super.key});

  static const String routeName = '/cinema-selection';

  @override
  State<CinemaSelectionPage> createState() => _CinemaSelectionPageState();
}

class _CinemaSelectionPageState extends State<CinemaSelectionPage> {
  Future<void> _selectCinema(String cinemaId) async {
    await AppStorage.saveActiveCinemaId(cinemaId);
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

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  static const String routeName = '/placeholder';

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(child: Text('$title folgt im nächsten Schritt.')),
    );
  }
}
