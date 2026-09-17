import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kino_bar_app/utils/beleg_foto_komprimierung.dart';

void main() {
  group('BelegFotoKomprimierung.komprimiereFuerVerlauf (Run 451)', () {
    // Echtes Rauschen (fester Seed fuer Reproduzierbarkeit) statt
    // Flaechenfarbe oder eines regelmaessigen Musters: beides laesst sich
    // verlustfrei (PNG) so klein komprimieren, dass ein erneutes
    // verlustbehaftetes JPEG-Encoding es nicht mehr unterbieten kann —
    // untypisch fuer ein echtes, detailreiches Kamerafoto. Zufallsrauschen
    // ist der Worst-Case fuer PNG (keine Redundanz) und macht die
    // Groessen-Erwartung der Kompression realistisch testbar.
    String base64BildMit({required int breite, required int hoehe}) {
      final img.Image bild = img.Image(width: breite, height: hoehe);
      final Random rnd = Random(42);
      for (int y = 0; y < hoehe; y++) {
        for (int x = 0; x < breite; x++) {
          bild.setPixelRgb(
            x,
            y,
            rnd.nextInt(256),
            rnd.nextInt(256),
            rnd.nextInt(256),
          );
        }
      }
      return base64Encode(img.encodePng(bild));
    }

    test(
      'ein zu grosses Foto (> 1000px Kante) wird verkleinert',
      () {
        final String original = base64BildMit(breite: 2000, hoehe: 1500);

        final String komprimiert =
            BelegFotoKomprimierung.komprimiereFuerVerlauf(original);

        final img.Image? dekodiert = img.decodeImage(
          base64Decode(komprimiert),
        );
        expect(dekodiert, isNotNull);
        expect(dekodiert!.width, lessThanOrEqualTo(1000));
        expect(dekodiert.height, lessThanOrEqualTo(1000));
      },
    );

    test(
      'ein zu grosses Foto wird durch die Kompression kleiner (Base64-'
      'Laenge sinkt) — das ist der eigentliche Zweck (Speicherplatz)',
      () {
        final String original = base64BildMit(breite: 2000, hoehe: 1500);

        final String komprimiert =
            BelegFotoKomprimierung.komprimiereFuerVerlauf(original);

        expect(komprimiert.length, lessThan(original.length));
      },
    );

    test(
      'ungueltige Base64-Eingabe (kein dekodierbares Bild) liefert das '
      'Original unveraendert zurueck statt zu werfen — ein Kompressions-'
      'fehler darf die Speicherung nie verhindern',
      () {
        const String kaputterInhalt = 'das-ist-kein-bild';

        final String ergebnis = BelegFotoKomprimierung.komprimiereFuerVerlauf(
          kaputterInhalt,
        );

        expect(ergebnis, kaputterInhalt);
      },
    );

    test(
      'ein bereits kleines Foto (unter der Kantenlaenge) bleibt in der '
      'Groessenordnung, wird nicht ohne Grund vergroessert',
      () {
        final String original = base64BildMit(breite: 50, hoehe: 50);

        final String ergebnis = BelegFotoKomprimierung.komprimiereFuerVerlauf(
          original,
        );

        final img.Image? dekodiert = img.decodeImage(
          base64Decode(ergebnis),
        );
        expect(dekodiert, isNotNull);
        expect(dekodiert!.width, 50);
        expect(dekodiert.height, 50);
      },
    );
  });
}
