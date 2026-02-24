import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/kassenstand_entwurf.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';

/// Usecase fuer Laden/Speichern des Tagesabschluss-Entwurfs.
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
      isoDatum: heutigesIsoDatum(),
    );
  }

  /// Speichert den Entwurf fuer das heutige Datum im ISO-Format.
  Future<void> speichereHeutigenEntwurf({
    required String kinoId,
    required KassenstandEntwurf entwurf,
  }) async {
    await LokalerSpeicher.speichereKassenstandEntwurf(
      kinoId: kinoId,
      isoDatum: heutigesIsoDatum(),
      entwurf: entwurf,
    );
  }

  /// Kapselt die Regel, ob bei 0 EUR eine Bestaetigung noetig ist.
  bool bestaetigungNoetigFuerNullbetrag(int gesamtCent) {
    return gesamtCent == 0;
  }

  /// Ermittelt das heutige Datum im benoetigten Speicher-Key-Format.
  String heutigesIsoDatum() {
    return TagesabschlussFormatierung.heutigesIsoDatum(DateTime.now());
  }
}
