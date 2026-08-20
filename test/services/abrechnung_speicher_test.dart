import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/services/abrechnung_speicher.dart';

void main() {
  group('AbrechnungSpeicher.abrechnungsDatumKey', () {
    test('baut den Key aus kinoId und logischem ISO-Datum', () {
      expect(
        AbrechnungSpeicher.abrechnungsDatumKey(
          'kino_01',
          jetzt: DateTime(2026, 3, 15, 14, 0),
        ),
        'abrechnung_kino_01_2026-03-15',
      );
    });

    test('nutzt bei 00:01 Uhr den Vortag (Cutoff-Regel greift auch hier)', () {
      expect(
        AbrechnungSpeicher.abrechnungsDatumKey(
          'kino_01',
          jetzt: DateTime(2026, 3, 16, 0, 1),
        ),
        'abrechnung_kino_01_2026-03-15',
      );
    });

    test('unterschiedliche Kinos ergeben unterschiedliche Keys', () {
      final DateTime jetzt = DateTime(2026, 3, 15, 14, 0);
      expect(
        AbrechnungSpeicher.abrechnungsDatumKey('kino_01', jetzt: jetzt),
        isNot(AbrechnungSpeicher.abrechnungsDatumKey('kino_05', jetzt: jetzt)),
      );
    });
  });
}
