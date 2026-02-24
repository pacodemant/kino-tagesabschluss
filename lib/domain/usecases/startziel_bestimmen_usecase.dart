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
  Future<StartzielBestimmungErgebnis> bestimmeStartziel() async {
    final String? aktivesKinoId = await LokalerSpeicher.ladeAktiveKinoId();
    final bool hatGueltigesKino =
        KinoRepository.nachId(aktivesKinoId ?? '') != null;

    return StartzielBestimmungErgebnis(
      aktivesKinoId: aktivesKinoId,
      hatGueltigesKino: hatGueltigesKino,
    );
  }
}
