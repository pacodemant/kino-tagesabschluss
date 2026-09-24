import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';

/// Usecase zum Speichern einer finalen Tagesabrechnung mit Duplikat-Pruefung.
class SpeichereTagesabschlussUsecase {
  const SpeichereTagesabschlussUsecase();

  /// Duplikat-Regel: Pro Kino und Kalendertag darf es maximal
  /// `Kino.maxAbrechnungenProTag` Abschluesse geben (Standard: 1).
  /// Ist fuer das Kino mehr als eine Abrechnung pro Tag vorgesehen (z.B.
  /// Bar Tabak) und das Tageslimit noch nicht erreicht, kann ein weiterer
  /// Abschluss statt eines Ueberschreibens explizit als zusaetzliche
  /// Abrechnung gespeichert werden (alsZusaetzlicheAbrechnung).
  ///
  /// Abschluesse mit "testdaten" in der Anmerkung zaehlen seit Run 477
  /// normal mit (vorher ausgenommen): Tests sollen sich wie der
  /// Echtbetrieb verhalten, eine erneute Abrechnung desselben Tages
  /// ersetzt also auch einen Testdaten-Eintrag.
  Future<SpeichereTagesabschlussErgebnis> ausfuehren(
    TagesabschlussFinal abschluss, {
    bool ueberschreiben = false,
    bool alsZusaetzlicheAbrechnung = false,
  }) async {
    final List<TagesabschlussFinal> vorhandeneAbschluesse =
        await LokalerSpeicher.ladeFinaleTagesabschluesse(abschluss.kinoId);

    final int anzahlHeute = vorhandeneAbschluesse
        .where(
          (TagesabschlussFinal eintrag) =>
              DatumsHelper.istGleicherKalendertag(
                eintrag.datum,
                abschluss.datum,
              ),
        )
        .length;

    if (anzahlHeute == 0 || alsZusaetzlicheAbrechnung) {
      await LokalerSpeicher.speichereFinalenTagesabschluss(abschluss);
      return const SpeichereTagesabschlussErgebnis(bereitsVorhanden: false);
    }

    if (!ueberschreiben) {
      final int maxProTag = KinoRepository.nachId(abschluss.kinoId)
              ?.maxAbrechnungenProTag ??
          1;
      return SpeichereTagesabschlussErgebnis(
        bereitsVorhanden: true,
        weitereAbrechnungMoeglich: maxProTag > 1 && anzahlHeute < maxProTag,
      );
    }

    await LokalerSpeicher.ersetzeFinalenTagesabschluss(abschluss);
    return const SpeichereTagesabschlussErgebnis(bereitsVorhanden: false);
  }
}

class SpeichereTagesabschlussErgebnis {
  const SpeichereTagesabschlussErgebnis({
    required this.bereitsVorhanden,
    this.weitereAbrechnungMoeglich = false,
  });

  final bool bereitsVorhanden;

  /// true, wenn fuer dieses Kino am selben Tag noch eine weitere
  /// (zusaetzliche) Abrechnung erlaubt ist, statt die vorhandene zu
  /// ueberschreiben.
  final bool weitereAbrechnungMoeglich;
}
