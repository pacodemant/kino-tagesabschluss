import 'package:kino_bar_app/models/kassenzeile.dart';

class TagesabschlussBerechnung {
  const TagesabschlussBerechnung._();

  static int parseCentZiffern(String wert) {
    final String nurZiffern = wert.replaceAll(RegExp(r'[^0-9]'), '');
    if (nurZiffern.isEmpty) {
      return 0;
    }
    return int.tryParse(nurZiffern) ?? 0;
  }

  static int summeStueckzahlGruppeCent({
    required List<Kassenzeile> zeilen,
    required Map<String, int> stueckzahlen,
  }) {
    int summe = 0;
    for (final Kassenzeile zeile in zeilen) {
      final int stueckzahl = stueckzahlen[zeile.id] ?? 0;
      summe += stueckzahl * zeile.einzelwertCent;
    }
    return summe;
  }

  static int summeCentBetraege(Iterable<int> betraegeCent) {
    int summe = 0;
    for (final int betragCent in betraegeCent) {
      summe += betragCent;
    }
    return summe;
  }

  static int summeUmschlaegeCent(List<UmschlagEintrag> umschlaege) {
    int summe = 0;
    for (final UmschlagEintrag eintrag in umschlaege) {
      summe += eintrag.betragCent;
    }
    return summe;
  }

  static int kassenbestandGesamtCent({
    required int scheineCent,
    required int loseMuenzenCent,
    required int rollenCent,
    required int umschlaegeCent,
  }) {
    return scheineCent + loseMuenzenCent + rollenCent + umschlaegeCent;
  }

  static int barumsatzBereinigtCent({
    required int kassenbestandGesamtCent,
    required int wechselgeldSollwertCent,
  }) {
    return kassenbestandGesamtCent - wechselgeldSollwertCent;
  }

  static int gesamtSollCent({
    required int kinoSollCent,
    required int bistroSollCent,
    required int ausgabenCent,
  }) {
    return kinoSollCent + bistroSollCent - ausgabenCent;
  }

  static int gesamtIstCent({
    required int ecUmsatzGesamtCent,
    required int barBestandAbzglWechselgeldCent,
  }) {
    return ecUmsatzGesamtCent + barBestandAbzglWechselgeldCent;
  }

  static int differenzTagesabschlussCent({
    required int gesamtIstCent,
    required int gesamtSollCent,
  }) {
    return gesamtIstCent - gesamtSollCent;
  }
}

class TagesabschlussFormatierung {
  const TagesabschlussFormatierung._();

  static String formatiereEuro(int cent) {
    final String vorzeichen = cent < 0 ? '-' : '';
    final int absolut = cent.abs();
    final int euro = absolut ~/ 100;
    final String centTeil = (absolut % 100).toString().padLeft(2, '0');
    return '$vorzeichen$euro,$centTeil €';
  }

  static String formatiereEuroEingabe(int cent) {
    final String vorzeichen = cent < 0 ? '-' : '';
    final int absolut = cent.abs();
    final int euro = absolut ~/ 100;
    final String centTeil = (absolut % 100).toString().padLeft(2, '0');
    return '$vorzeichen$euro,$centTeil';
  }

  static String formatiereEuroMitVorzeichen(int cent) {
    if (cent > 0) {
      final int euro = cent ~/ 100;
      final String centTeil = (cent % 100).toString().padLeft(2, '0');
      return '+$euro,$centTeil €';
    }
    return formatiereEuro(cent);
  }

  static String heutigesIsoDatum(DateTime jetzt) {
    final String jahr = jetzt.year.toString().padLeft(4, '0');
    final String monat = jetzt.month.toString().padLeft(2, '0');
    final String tag = jetzt.day.toString().padLeft(2, '0');
    return '$jahr-$monat-$tag';
  }

  static String deutschesDatum(DateTime jetzt) {
    final String tag = jetzt.day.toString().padLeft(2, '0');
    final String monat = jetzt.month.toString().padLeft(2, '0');
    final String jahr = jetzt.year.toString();
    return '$tag.$monat.$jahr';
  }
}
