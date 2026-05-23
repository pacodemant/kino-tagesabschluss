import 'package:kino_bar_app/models/kassenstand_entwurf.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';

/// Usecase fuer Laden/Speichern des Tagesabrechnungs-Entwurfs.
class KassenstandEntwurfUsecase {
  const KassenstandEntwurfUsecase();

  /// Liefert den gespeicherten Wechselgeld-Sollwert fuer ein Kino.
  Future<int> ladeWechselgeldSollwertCent(String kinoId) async {
    return LokalerSpeicher.ladeWechselgeldSollwertCent(kinoId);
  }

  /// Laedt den Entwurf fuer das heutige Datum im ISO-Format.
  Future<KassenstandEntwurf?> ladeHeutigenEntwurf(String kinoId) async {
    return LokalerSpeicher.ladeKassenstandEntwurf(
      kinoId: kinoId,
      isoDatum: DatumsHelper.logischesIsoDatum(),
    );
  }

  /// Speichert den Entwurf fuer das heutige Datum im ISO-Format.
  Future<void> speichereHeutigenEntwurf({
    required String kinoId,
    required KassenstandEntwurf entwurf,
  }) async {
    await LokalerSpeicher.speichereKassenstandEntwurf(
      kinoId: kinoId,
      isoDatum: DatumsHelper.logischesIsoDatum(),
      entwurf: entwurf,
    );
  }

  /// Kapselt die Regel, ob bei 0 EUR eine Bestaetigung noetig ist.
  bool bestaetigungNoetigFuerNullbetrag(int gesamtCent) {
    return gesamtCent == 0;
  }
}
