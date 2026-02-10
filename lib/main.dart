import 'package:flutter/material.dart';
import 'package:kino_bar_app/models/cinema.dart';
import 'package:kino_bar_app/pages/cash_count_step1_page.dart';
import 'package:kino_bar_app/pages/cinema_selection_page.dart';
import 'package:kino_bar_app/pages/placeholder_page.dart';
import 'package:kino_bar_app/pages/start_menu_page.dart';
import 'package:kino_bar_app/pages/startup_gate_page.dart';

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

          final Cinema? cinema = CinemaRepository.byId(arg);
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

        if (settings.name == PlaceholderPage.routeName) {
          final String title = settings.arguments as String? ?? 'Platzhalter';
          return MaterialPageRoute<void>(
            builder: (_) => PlaceholderPage(title: title),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}
