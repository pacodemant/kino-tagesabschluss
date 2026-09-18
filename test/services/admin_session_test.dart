import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/services/admin_session.dart';

void main() {
  setUp(() {
    AdminSession.entsperrt = false;
  });

  group('AdminSession', () {
    test('ohne Entsperren gesperrt', () {
      expect(AdminSession.istEntsperrt(), isFalse);
    });

    test('nach Entsperren am selben Geschäftstag weiter entsperrt', () {
      AdminSession.entsperren(jetzt: DateTime(2026, 9, 18, 14, 0));
      expect(AdminSession.istEntsperrt(jetzt: DateTime(2026, 9, 18, 23, 59)),
          isTrue);
      // Nach Mitternacht, aber vor dem 5-Uhr-Cutoff: noch derselbe Geschäftstag.
      expect(AdminSession.istEntsperrt(jetzt: DateTime(2026, 9, 19, 4, 59)),
          isTrue);
    });

    test('ab dem Tagesknick um 5 Uhr wieder gesperrt', () {
      AdminSession.entsperren(jetzt: DateTime(2026, 9, 18, 14, 0));
      expect(AdminSession.istEntsperrt(jetzt: DateTime(2026, 9, 19, 5, 0)),
          isFalse);
    });

    test('Entsperren nach Mitternacht gilt bis zum selben 5-Uhr-Cutoff', () {
      AdminSession.entsperren(jetzt: DateTime(2026, 9, 19, 1, 0));
      expect(AdminSession.istEntsperrt(jetzt: DateTime(2026, 9, 19, 4, 30)),
          isTrue);
      expect(AdminSession.istEntsperrt(jetzt: DateTime(2026, 9, 19, 5, 0)),
          isFalse);
    });

    test('Setter entsperrt = false sperrt sofort', () {
      AdminSession.entsperren();
      expect(AdminSession.entsperrt, isTrue);
      AdminSession.entsperrt = false;
      expect(AdminSession.entsperrt, isFalse);
    });
  });
}
