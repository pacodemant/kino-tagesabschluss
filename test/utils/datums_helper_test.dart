import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';

void main() {
  group('DatumsHelper.logischerAbrechnungsTag', () {
    test('zaehlt 00:01 Uhr noch als Vortag (Cutoff 6 Uhr)', () {
      expect(
        DatumsHelper.logischerAbrechnungsTag(
          jetzt: DateTime(2026, 3, 16, 0, 1),
        ),
        DateTime(2026, 3, 15),
      );
    });

    test('zaehlt 05:59 Uhr noch als Vortag', () {
      expect(
        DatumsHelper.logischerAbrechnungsTag(
          jetzt: DateTime(2026, 3, 16, 5, 59),
        ),
        DateTime(2026, 3, 15),
      );
    });

    test('zaehlt 06:00 Uhr als aktuellen Tag', () {
      expect(
        DatumsHelper.logischerAbrechnungsTag(
          jetzt: DateTime(2026, 3, 16, 6, 0),
        ),
        DateTime(2026, 3, 16),
      );
    });

    test('zaehlt 23:50 Uhr als aktuellen Tag', () {
      expect(
        DatumsHelper.logischerAbrechnungsTag(
          jetzt: DateTime(2026, 3, 15, 23, 50),
        ),
        DateTime(2026, 3, 15),
      );
    });

    test('behandelt den Cutoff korrekt ueber einen Jahreswechsel', () {
      expect(
        DatumsHelper.logischerAbrechnungsTag(
          jetzt: DateTime(2026, 1, 1, 0, 1),
        ),
        DateTime(2025, 12, 31),
      );
    });

    test('liefert ohne jetzt-Parameter einen plausiblen Tag um now()', () {
      final DateTime ergebnis = DatumsHelper.logischerAbrechnungsTag();
      final DateTime heute = DateTime.now();
      final Duration differenz = DateTime(
        heute.year,
        heute.month,
        heute.day,
      ).difference(ergebnis);

      expect(differenz.inDays, anyOf(0, 1));
    });
  });

  group('DatumsHelper.isoDatum', () {
    test('formatiert als YYYY-MM-DD mit fuehrenden Nullen', () {
      expect(DatumsHelper.isoDatum(DateTime(2026, 3, 5)), '2026-03-05');
    });
  });

  group('DatumsHelper.logischesIsoDatum', () {
    test('kombiniert Cutoff-Logik und ISO-Formatierung', () {
      expect(
        DatumsHelper.logischesIsoDatum(jetzt: DateTime(2026, 3, 16, 0, 1)),
        '2026-03-15',
      );
    });
  });
}
