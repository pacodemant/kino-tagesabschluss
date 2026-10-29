import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Komprimiert ein Base64-kodiertes Belegfoto ausschließlich für die
/// lokale Verlaufs-Ablage (Run 451) — diese Methode wird nur beim
/// Schreiben in den lokalen Verlauf aufgerufen (LokalerSpeicher.
/// speichereFinalenTagesabschluss() / ersetzeFinalenTagesabschluss()),
/// nie vorher. Seit Run 495 wird das Foto zusätzlich schon bei der
/// Aufnahme verkleinert (siehe [aufnahmeMaxKantenlaengePixel]); diese
/// Fassung geht an Belegscan und Flurbocash (Paco-Entscheidung
/// 2026-10-23: lesbares, verkleinertes Foto genügt).
class BelegFotoKomprimierung {
  BelegFotoKomprimierung._();

  /// Grenzen für `ImagePicker().pickImage()` bei der Aufnahme (Run 495).
  /// Die Verkleinerung macht der Browser bzw. das OS selbst (schnell,
  /// nicht im Dart-Thread). 2000 px an der langen Kante halten Kassenbon-
  /// Text für KI und Menschen gut lesbar; falls Flurbocash mehr braucht,
  /// nur hier anpassen.
  static const double aufnahmeMaxKantenlaengePixel = 2000;
  static const int aufnahmeJpegQualitaet = 85;

  static const int _maxKantenlaengePixel = 1000;
  static const int _jpegQualitaet = 70;

  /// Bereits verkleinerte Fotos (Original -> Verlaufsfassung), Run 500.
  /// Im Browser läuft die Verkleinerung im einzigen Dart-Thread und kostet
  /// je Foto mehrere Sekunden (gemessen); sie wird deshalb schon während
  /// des Beleg-Scans erledigt (BelegScanService.scan) und beim Speichern
  /// in den Verlauf (Schritt 3) nur noch nachgeschlagen.
  static final Map<String, String> _cache = <String, String>{};
  static const int _cacheMax = 12;

  /// Gibt bei Dekodier-/Kodierfehlern (oder wenn die Komprimierung nicht
  /// kleiner wird als das Original) das Original unverändert zurück, damit
  /// ein Kompressionsfehler nie eine Speicherung verhindert.
  static String komprimiereFuerVerlauf(String base64Original) {
    final String? bekannt = _cache[base64Original];
    if (bekannt != null) return bekannt;
    final String ergebnis = _komprimiere(base64Original);
    if (_cache.length >= _cacheMax) _cache.remove(_cache.keys.first);
    _cache[base64Original] = ergebnis;
    return ergebnis;
  }

  @visibleForTesting
  static void leereCache() => _cache.clear();

  @visibleForTesting
  static bool istVorbereitet(String base64Original) =>
      _cache.containsKey(base64Original);

  static String _komprimiere(String base64Original) {
    try {
      final Uint8List bytes = base64Decode(base64Original);
      final img.Image? bild = img.decodeImage(bytes);
      if (bild == null) {
        return base64Original;
      }
      final bool zuGross = bild.width > _maxKantenlaengePixel ||
          bild.height > _maxKantenlaengePixel;
      final img.Image skaliert = zuGross
          ? img.copyResize(
              bild,
              width: bild.width >= bild.height ? _maxKantenlaengePixel : null,
              height: bild.height > bild.width ? _maxKantenlaengePixel : null,
            )
          : bild;
      final List<int> jpeg = img.encodeJpg(skaliert, quality: _jpegQualitaet);
      final String komprimiert = base64Encode(jpeg);
      return komprimiert.length < base64Original.length
          ? komprimiert
          : base64Original;
    } catch (_) {
      return base64Original;
    }
  }
}
