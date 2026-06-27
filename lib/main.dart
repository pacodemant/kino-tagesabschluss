import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/services/getraenke_config_service.dart';
import 'package:kino_bar_app/services/wechselgeld_config_service.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/pages/startpruefung_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt2_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt3_seite.dart';
import 'package:kino_bar_app/pages/stueckelung_vorschlag_seite.dart';
import 'package:kino_bar_app/pages/einstellungen_seite.dart';
import 'package:kino_bar_app/pages/getraenke_auffuellen_seite.dart';
import 'package:kino_bar_app/pages/verlauf_detail_seite.dart';
import 'package:kino_bar_app/pages/verlauf_seite.dart';
import 'package:kino_bar_app/pages/wechselgeld_pruefen_seite.dart';
import 'package:kino_bar_app/pages/datenschutz_seite.dart';
import 'package:kino_bar_app/pages/ueber_entwickler_seite.dart';
import 'package:kino_bar_app/services/sw_update_service.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Wichtig für DateFormat(..., 'de_DE') in Schritt 2 (sonst LocaleDataException).
  await initializeDateFormatting('de_DE', null);

  await Hive.initFlutter();
  await Future.wait(<Future<Box<dynamic>>>[
    Hive.openBox('box_tagesabschluesse'),
    Hive.openBox('box_abrechnung_entwuerfe'),
    Hive.openBox('box_schritt2_entwuerfe'),
    Hive.openBox('box_getraenke_mengen'),
    Hive.openBox('box_wechselgeld_entwuerfe'),
    Hive.openBox('box_getraenkeliste'),
    Hive.openBox('box_einstellungen'),
  ]);

  for (final Kino kino in KinoRepository.kinos) {
    if (kino.hatGetraenke) {
      await GetraenkeConfigService(kinoId: kino.id).initOnAppStart();
    }
  }
  await WechselgeldConfigService().initOnAppStart();

  runApp(const MeineApp());
  initSwUpdateWatcher(() {
    MeineApp.scaffoldMessengerKey.currentState?.showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: const Row(
          children: <Widget>[
            Icon(Icons.system_update, color: Colors.deepOrange),
            SizedBox(width: 12),
            Text(
              'Neue Version verfügbar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              MeineApp.scaffoldMessengerKey.currentState
                  ?.hideCurrentMaterialBanner();
              reloadPage();
            },
            child: const Text('Jetzt laden'),
          ),
        ],
      ),
    );
  });
}

class MeineApp extends StatelessWidget {
  const MeineApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: MeineApp.scaffoldMessengerKey,
      title: 'Kassenabrechnung',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: AppFarben.seitenHintergrund,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppFarben.appBarRot,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppFarben.appBarRot,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppFarben.appBarRot,
          ),
        ),
      ),
      initialRoute: StartpruefungSeite.routenName,
      onGenerateInitialRoutes: (String _) => <Route<void>>[
        MaterialPageRoute<void>(
          builder: (_) => const StartpruefungSeite(),
          settings: const RouteSettings(name: StartpruefungSeite.routenName),
        ),
      ],
      routes: <String, WidgetBuilder>{
        StartpruefungSeite.routenName: (_) => const StartpruefungSeite(),
        KinoauswahlSeite.routenName: (_) => const KinoauswahlSeite(),
        UeberEntwicklerSeite.routenName: (_) => const UeberEntwicklerSeite(),
      },
      onUnknownRoute: (RouteSettings settings) => MaterialPageRoute<void>(
        builder: (_) => const KinoauswahlSeite(),
        settings: const RouteSettings(name: KinoauswahlSeite.routenName),
      ),
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
              stueckzahlen: argument.stueckzahlen,
              loseMuenzenNachArtCent: argument.loseMuenzenNachArtCent,
              umschlaege: argument.umschlaege,
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

        if (settings.name == StueckelungVorschlagSeite.routenName) {
          final Object? argument = settings.arguments;
          if (argument is! StueckelungVorschlagArgumente) {
            return MaterialPageRoute<void>(
              builder: (_) => const KinoauswahlSeite(),
              settings:
                  const RouteSettings(name: KinoauswahlSeite.routenName),
            );
          }
          return MaterialPageRoute<void>(
            builder: (_) => StueckelungVorschlagSeite(argumente: argument),
            settings: settings,
          );
        }

        if (settings.name == EinstellungenSeite.routenName) {
          return MaterialPageRoute<void>(
            builder: (_) => const EinstellungenSeite(),
            settings: settings,
          );
        }

        if (settings.name == VerlaufSeite.routenName) {
          final String? kinoId = settings.arguments as String?;
          if (kinoId == null) {
            return null;
          }
          return MaterialPageRoute<void>(
            builder: (_) => VerlaufSeite(kinoId: kinoId),
            settings: settings,
          );
        }

        if (settings.name == VerlaufDetailSeite.routenName) {
          final Object? argument = settings.arguments;
          if (argument is! TagesabschlussFinal) {
            return null;
          }
          return MaterialPageRoute<bool>(
            builder: (_) => VerlaufDetailSeite(abschluss: argument),
            settings: settings,
          );
        }

        if (settings.name == WechselgeldPruefenSeite.routenName) {
          final String kinoId = (settings.arguments as String?) ?? '';
          return MaterialPageRoute<void>(
            builder: (_) => WechselgeldPruefenSeite(kinoId: kinoId),
            settings: settings,
          );
        }

        if (settings.name == GetraenkeAuffuellenSeite.routenName) {
          final String kinoId = (settings.arguments as String?) ?? '';
          return MaterialPageRoute<void>(
            builder: (_) => GetraenkeAuffuellenSeite(kinoId: kinoId),
            settings: settings,
          );
        }

        if (settings.name == DatenschutzSeite.routenName) {
          return MaterialPageRoute<void>(
            builder: (_) => const DatenschutzSeite(),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}
