import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

/// Ergebnisobjekt fuer die Startziel-Entscheidung beim App-Start.
class StartzielBestimmungErgebnis {
  const StartzielBestimmungErgebnis({
    required this.aktivesKinoId,
    required this.hatGueltigesKino,
  });

  final String? aktivesKinoId;
  final bool hatGueltigesKino;
}

/// Usecase fuer den Startflow: gespeichertes Kino laden und validieren.
class StartzielBestimmenUsecase {
  const StartzielBestimmenUsecase();

  /// Liefert, ob die gespeicherte Kino-ID im Repository bekannt ist.
  /// Ein per Standort-Betriebsmodus (Admin) fest eingestelltes Kino hat
  /// Vorrang vor dem zuletzt manuell gewählten Kino.
  Future<StartzielBestimmungErgebnis> bestimmeStartziel() async {
    final String? standortModus = await LokalerSpeicher.ladeStandortModus();
    if (standortModus != null &&
        KinoRepository.nachId(standortModus) != null) {
      await LokalerSpeicher.speichereAktiveKinoId(standortModus);
      return StartzielBestimmungErgebnis(
        aktivesKinoId: standortModus,
        hatGueltigesKino: true,
      );
    }

    final String? aktivesKinoId = await LokalerSpeicher.ladeAktiveKinoId();
    final bool hatGueltigesKino =
        KinoRepository.nachId(aktivesKinoId ?? '') != null;

    return StartzielBestimmungErgebnis(
      aktivesKinoId: aktivesKinoId,
      hatGueltigesKino: hatGueltigesKino,
    );
  }
}
