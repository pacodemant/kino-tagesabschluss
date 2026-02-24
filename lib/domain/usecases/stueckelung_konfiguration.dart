import 'package:kino_bar_app/models/kassenzeile.dart';

/// Zentrale Konfiguration der Kassen-Stueckelungen fuer Schritt 1.
class StueckelungKonfiguration {
  const StueckelungKonfiguration._();

  /// Definiert alle Schein-Stueckelungen inkl. Einzelwert in Cent.
  static const List<Kassenzeile> scheine = <Kassenzeile>[
    Kassenzeile(id: 'note_100', bezeichnung: '100 €', einzelwertCent: 10000),
    Kassenzeile(id: 'note_50', bezeichnung: '50 €', einzelwertCent: 5000),
    Kassenzeile(id: 'note_20', bezeichnung: '20 €', einzelwertCent: 2000),
    Kassenzeile(id: 'note_10', bezeichnung: '10 €', einzelwertCent: 1000),
    Kassenzeile(id: 'note_5', bezeichnung: '5 €', einzelwertCent: 500),
  ];

  /// Definiert alle Rollen-Stueckelungen inkl. Gesamtwert je Rolle in Cent.
  static const List<Kassenzeile> rollen = <Kassenzeile>[
    Kassenzeile(
      id: 'roll_2e',
      bezeichnung: 'Rolle 2 € (50,00 €)',
      einzelwertCent: 5000,
    ),
    Kassenzeile(
      id: 'roll_1e',
      bezeichnung: 'Rolle 1 € (25,00 €)',
      einzelwertCent: 2500,
    ),
    Kassenzeile(
      id: 'roll_50c',
      bezeichnung: 'Rolle 50 ct (20,00 €)',
      einzelwertCent: 2000,
    ),
    Kassenzeile(
      id: 'roll_20c',
      bezeichnung: 'Rolle 20 ct (8,00 €)',
      einzelwertCent: 800,
    ),
    Kassenzeile(
      id: 'roll_10c',
      bezeichnung: 'Rolle 10 ct (4,00 €)',
      einzelwertCent: 400,
    ),
    Kassenzeile(
      id: 'roll_5c',
      bezeichnung: 'Rolle 5 ct (2,00 €)',
      einzelwertCent: 200,
    ),
    Kassenzeile(
      id: 'roll_2c',
      bezeichnung: 'Rolle 2 ct (1,00 €)',
      einzelwertCent: 100,
    ),
    Kassenzeile(
      id: 'roll_1c',
      bezeichnung: 'Rolle 1 ct (0,50 €)',
      einzelwertCent: 50,
    ),
  ];

  /// Definiert Muenzarten fuer lose Muenzen als Betragseingabe.
  static const List<Kassenzeile> loseMuenzarten = <Kassenzeile>[
    Kassenzeile(id: 'coin_2e', bezeichnung: '2 €', einzelwertCent: 0),
    Kassenzeile(id: 'coin_1e', bezeichnung: '1 €', einzelwertCent: 0),
    Kassenzeile(id: 'coin_50c', bezeichnung: '50 ct', einzelwertCent: 0),
    Kassenzeile(id: 'coin_20c', bezeichnung: '20 ct', einzelwertCent: 0),
    Kassenzeile(id: 'coin_10c', bezeichnung: '10 ct', einzelwertCent: 0),
    Kassenzeile(id: 'coin_5c', bezeichnung: '5 ct', einzelwertCent: 0),
    Kassenzeile(id: 'coin_2c', bezeichnung: '2 ct', einzelwertCent: 0),
    Kassenzeile(id: 'coin_1c', bezeichnung: '1 ct', einzelwertCent: 0),
  ];

  /// Kombinierte Liste aller Eingabefelder mit Stueckzahl (Scheine + Rollen).
  static const List<Kassenzeile> alleStueckzahlZeilen = <Kassenzeile>[
    ...scheine,
    ...rollen,
  ];
}
