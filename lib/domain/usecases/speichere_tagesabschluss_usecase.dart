import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

/// Usecase zum Speichern einer finalen Tagesabrechnung mit Duplikat-Pruefung.
class SpeichereTagesabschlussUsecase {
  const SpeichereTagesabschlussUsecase();

  /// Duplikat-Regel: Pro Kino und Kalendertag darf es maximal einen Abschluss geben.
  Future<SpeichereTagesabschlussErgebnis> ausfuehren(
    TagesabschlussFinal abschluss, {
    bool ueberschreiben = false,
  }) async {
    final List<TagesabschlussFinal> vorhandeneAbschluesse =
        await LokalerSpeicher.ladeFinaleTagesabschluesse(abschluss.kinoId);

    final bool bereitsVorhanden = vorhandeneAbschluesse.any(
      (TagesabschlussFinal eintrag) => _istGleicherKalendertag(
        eintrag.datum,
        abschluss.datum,
      ),
    );

    if (bereitsVorhanden && !ueberschreiben) {
      return const SpeichereTagesabschlussErgebnis(bereitsVorhanden: true);
    }

    if (bereitsVorhanden) {
      await LokalerSpeicher.ersetzeFinalenTagesabschluss(abschluss);
    } else {
      await LokalerSpeicher.speichereFinalenTagesabschluss(abschluss);
    }
    return const SpeichereTagesabschlussErgebnis(bereitsVorhanden: false);
  }

  bool _istGleicherKalendertag(DateTime links, DateTime rechts) {
    return links.year == rechts.year &&
        links.month == rechts.month &&
        links.day == rechts.day;
  }
}

class SpeichereTagesabschlussErgebnis {
  const SpeichereTagesabschlussErgebnis({required this.bereitsVorhanden});

  final bool bereitsVorhanden;
}
