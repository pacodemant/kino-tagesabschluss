import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';

void main() {
  group('StueckelungKonfiguration', () {
    test('alleStueckzahlZeilen ist genau scheine + rollen, keine Dubletten', () {
      expect(
        StueckelungKonfiguration.alleStueckzahlZeilen,
        <Kassenzeile>[
          ...StueckelungKonfiguration.scheine,
          ...StueckelungKonfiguration.rollen,
        ],
      );

      final List<String> ids = StueckelungKonfiguration.alleStueckzahlZeilen
          .map((Kassenzeile z) => z.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('jede Kassenzeilen-ID kommt in genau einer Liste vor', () {
      final List<List<Kassenzeile>> listen = <List<Kassenzeile>>[
        StueckelungKonfiguration.scheine,
        StueckelungKonfiguration.rollen,
        StueckelungKonfiguration.loseMuenzarten,
      ];

      final List<String> alleIds = listen
          .expand((List<Kassenzeile> l) => l)
          .map((Kassenzeile z) => z.id)
          .toList();

      expect(alleIds.toSet().length, alleIds.length);
    });

    test('kupferRollenIds sind Teilmenge der rollen-IDs', () {
      final Set<String> rollenIds =
          StueckelungKonfiguration.rollen.map((Kassenzeile z) => z.id).toSet();
      expect(
        rollenIds.containsAll(StueckelungKonfiguration.kupferRollenIds),
        isTrue,
      );
    });

    test(
      'kupferMuenzenIds und silberMuenzenIds sind disjunkt und zusammen '
      'Teilmenge der loseMuenzarten-IDs',
      () {
        final Set<String> muenzIds = StueckelungKonfiguration.loseMuenzarten
            .map((Kassenzeile z) => z.id)
            .toSet();

        expect(
          StueckelungKonfiguration.kupferMuenzenIds
              .intersection(StueckelungKonfiguration.silberMuenzenIds),
          isEmpty,
        );
        expect(
          muenzIds.containsAll(StueckelungKonfiguration.kupferMuenzenIds),
          isTrue,
        );
        expect(
          muenzIds.containsAll(StueckelungKonfiguration.silberMuenzenIds),
          isTrue,
        );
      },
    );

    test('einzelwertCent ist fuer alle Zeilen positiv', () {
      final List<Kassenzeile> alle = <Kassenzeile>[
        ...StueckelungKonfiguration.scheine,
        ...StueckelungKonfiguration.rollen,
        ...StueckelungKonfiguration.loseMuenzarten,
      ];
      for (final Kassenzeile zeile in alle) {
        expect(
          zeile.einzelwertCent,
          greaterThan(0),
          reason: '${zeile.id} hat einzelwertCent <= 0',
        );
      }
    });
  });
}
