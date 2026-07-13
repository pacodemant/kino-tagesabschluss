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

  /// Parst Euro-Komma-Eingabe: "6,40" → 640, "380" → 38000, "0,0" → 0.
  static int parseCentKomma(String wert) {
    final String s = wert.trim().replaceAll('€', '').trim();
    if (s.isEmpty) return 0;
    final int kommaIdx = s.lastIndexOf(',');
    final int dotIdx = s.lastIndexOf('.');
    final int sepIdx = (kommaIdx < 0 && dotIdx < 0)
        ? -1
        : (kommaIdx < 0 ? dotIdx : (dotIdx < 0 ? kommaIdx : (kommaIdx > dotIdx ? kommaIdx : dotIdx)));
    if (sepIdx < 0) {
      final int euro = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return euro * 100;
    }
    final String euroTeil = s.substring(0, sepIdx).replaceAll(RegExp(r'[^0-9]'), '');
    final String centRoh = s.substring(sepIdx + 1).replaceAll(RegExp(r'[^0-9]'), '');
    final int euro = euroTeil.isEmpty ? 0 : (int.tryParse(euroTeil) ?? 0);
    final int cent;
    if (centRoh.isEmpty) {
      cent = 0;
    } else if (centRoh.length == 1) {
      cent = (int.tryParse(centRoh) ?? 0) * 10;
    } else {
      cent = int.tryParse(centRoh.substring(0, 2)) ?? 0;
    }
    return euro * 100 + cent;
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

  static String _tausenderPunkt(int euro) {
    final String s = euro.toString();
    if (s.length <= 3) return s;
    final int startMod = s.length % 3;
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && i % 3 == startMod) {
        buf.write('.');
      }
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String formatiereEuro(int cent) {
    final String vorzeichen = cent < 0 ? '-' : '';
    final int absolut = cent.abs();
    final String euroTeil = _tausenderPunkt(absolut ~/ 100);
    final String centTeil = (absolut % 100).toString().padLeft(2, '0');
    return '$vorzeichen$euroTeil,$centTeil €';
  }

  static String formatiereEuroEingabe(int cent) {
    final String vorzeichen = cent < 0 ? '-' : '';
    final int absolut = cent.abs();
    final String euroTeil = _tausenderPunkt(absolut ~/ 100);
    final String centTeil = (absolut % 100).toString().padLeft(2, '0');
    return '$vorzeichen$euroTeil,$centTeil';
  }

  static String formatiereEuroMitVorzeichen(int cent) {
    if (cent > 0) {
      final String euroTeil = _tausenderPunkt(cent ~/ 100);
      final String centTeil = (cent % 100).toString().padLeft(2, '0');
      return '+$euroTeil,$centTeil €';
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
