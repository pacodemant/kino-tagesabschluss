import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/platzhalter_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/pages/startpruefung_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wichtig für DateFormat(..., 'de_DE') in Schritt 2 (sonst LocaleDataException).
  await initializeDateFormatting('de_DE', null);

  runApp(const MeineApp());
}

class MeineApp extends StatelessWidget {
  const MeineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schauburg Tagesabschluss',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: StartpruefungSeite.routenName,
      routes: <String, WidgetBuilder>{
        StartpruefungSeite.routenName: (_) => const StartpruefungSeite(),
        KinoauswahlSeite.routenName: (_) => const KinoauswahlSeite(),
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == StartmenueSeite.routenName) {
          final Object? argument = settings.arguments;
          if (argument is! String) {
            return MaterialPageRoute<void>(
              builder: (_) => const KinoauswahlSeite(),
              settings: const RouteSettings(name: KinoauswahlSeite.routenName),
            );
          }

          final Kino? kino = KinoRepository.nachId(argument);
          if (kino == null) {
            return MaterialPageRoute<void>(
              builder: (_) => const KinoauswahlSeite(),
              settings: const RouteSettings(name: KinoauswahlSeite.routenName),
            );
          }

          return MaterialPageRoute<void>(
            builder: (_) => StartmenueSeite(kino: kino),
            settings: settings,
          );
        }

        if (settings.name == TagesabschlussSchritt1Seite.routenName) {
          final Object? argument = settings.arguments;
          if (argument is! TagesabschlussSchritt1Argumente) {
            return MaterialPageRoute<void>(
              builder: (_) => const KinoauswahlSeite(),
              settings: const RouteSettings(name: KinoauswahlSeite.routenName),
            );
          }

          return MaterialPageRoute<void>(
            builder: (_) => TagesabschlussSchritt1Seite(
              kinoId: argument.kinoId,
              kinoName: argument.kinoName,
            ),
            settings: settings,
          );
        }

        if (settings.name == TagesabschlussSchritt2Seite.routenName) {
          final Object? argument = settings.arguments;
          if (argument is! TagesabschlussSchritt2Argumente) {
            return MaterialPageRoute<void>(
              builder: (_) => const KinoauswahlSeite(),
              settings: const RouteSettings(name: KinoauswahlSeite.routenName),
            );
          }

          return MaterialPageRoute<void>(
            builder: (_) => TagesabschlussSchritt2Seite(
              kinoId: argument.kinoId,
              kinoName: argument.kinoName,
              scheineCent: argument.scheineCent,
              loseMuenzenCent: argument.loseMuenzenCent,
              rollenCent: argument.rollenCent,
              umschlaegeCent: argument.umschlaegeCent,
              wechselgeldSollwertCent: argument.wechselgeldSollwertCent,
              barBestandAbzglWechselgeldCent:
                  argument.barBestandAbzglWechselgeldCent,
            ),
            settings: settings,
          );
        }

        if (settings.name == TagesabschlussSchritt3Seite.routenName) {
          final Object? argument = settings.arguments;
          if (argument is! TagesabschlussSchritt3Argumente) {
            return MaterialPageRoute<void>(
              builder: (_) => const KinoauswahlSeite(),
              settings: const RouteSettings(name: KinoauswahlSeite.routenName),
            );
          }

          return MaterialPageRoute<void>(
            builder: (_) => TagesabschlussSchritt3Seite(argumente: argument),
            settings: settings,
          );
        }

        if (settings.name == PlatzhalterSeite.routenName) {
          final String titel = settings.arguments as String? ?? 'Platzhalter';
          return MaterialPageRoute<void>(
            builder: (_) => PlatzhalterSeite(titel: titel),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}