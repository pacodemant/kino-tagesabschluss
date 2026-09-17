import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Komprimiert ein Base64-kodiertes Belegfoto ausschließlich für die
/// lokale Verlaufs-Ablage (Run 451). Der volle Auflösung/Original-Base64
/// wird weiterhin für den Versand an Flurbocash sowie für den Belegscan
/// verwendet (siehe TagesabschlussSchritt3Seite._doApiUpload(),
/// ApiUploadService.upload()) — diese Klasse wird nur beim Schreiben in
/// den lokalen Verlauf aufgerufen (LokalerSpeicher.
/// speichereFinalenTagesabschluss() / ersetzeFinalenTagesabschluss()),
/// nie vorher.
class BelegFotoKomprimierung {
  BelegFotoKomprimierung._();

  static const int _maxKantenlaengePixel = 1000;
  static const int _jpegQualitaet = 70;

  /// Gibt bei Dekodier-/Kodierfehlern (oder wenn die Komprimierung nicht
  /// kleiner wird als das Original) das Original unverändert zurück, damit
  /// ein Kompressionsfehler nie eine Speicherung verhindert.
  static String komprimiereFuerVerlauf(String base64Original) {
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
