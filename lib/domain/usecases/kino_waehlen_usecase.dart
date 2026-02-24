import 'package:kino_bar_app/storage/lokaler_speicher.dart';

/// Usecase zum Persistieren der aktuellen Kino-Auswahl.
class KinoWaehlenUsecase {
  const KinoWaehlenUsecase();

  /// Speichert die aktive Kino-ID im lokalen Speicher.
  Future<void> speichereAktivesKino(String kinoId) async {
    await LokalerSpeicher.speichereAktiveKinoId(kinoId);
  }
}
