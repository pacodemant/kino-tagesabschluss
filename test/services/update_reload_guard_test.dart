import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kino_bar_app/pages/kinoauswahl_seite.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/pages/tagesabschluss_schritt1_seite.dart';
import 'package:kino_bar_app/services/update_reload_guard.dart';

/// Reiner Unit-Test ohne Widget-Pumping/Hive: UpdateReloadGuard ist eine
/// simple, rein lesende NavigatorObserver-Klasse ohne I/O — die
/// `Route<dynamic>`-Objekte lassen sich synchron konstruieren, ein
/// pumpWidget()/echtes Navigator-Setup ist dafür nicht nötig.
void main() {
  Route<dynamic> route(String name) => MaterialPageRoute<void>(
        settings: RouteSettings(name: name),
        builder: (BuildContext _) => const SizedBox.shrink(),
      );

  final UpdateReloadGuard guard = UpdateReloadGuard();

  test(
      'didPush auf Kinoauswahl/Startmenü -> istAufSichererSeite true '
      '(Update-Reload dort erlaubt)', () {
    guard.didPush(route(KinoauswahlSeite.routenName), null);
    expect(UpdateReloadGuard.istAufSichererSeite, isTrue);

    guard.didPush(route(StartmenueSeite.routenName), route('irgendwas'));
    expect(UpdateReloadGuard.istAufSichererSeite, isTrue);
  });

  test(
      'didPush auf eine Abrechnungs-Seite -> istAufSichererSeite false '
      '(Update-Reload dort NICHT erlaubt, TODO "nicht mitten in der '
      'Abrechnung")', () {
    guard.didPush(
      route(TagesabschlussSchritt1Seite.routenName),
      route(StartmenueSeite.routenName),
    );
    expect(UpdateReloadGuard.istAufSichererSeite, isFalse);
  });

  test(
      'didPop setzt die aktuelle Route auf previousRoute zurück, NICHT auf '
      'die gerade gepoppte Route (sonst bliebe istAufSichererSeite auf der '
      'verlassenen Abrechnungs-Seite stehen)', () {
    guard.didPush(
      route(TagesabschlussSchritt1Seite.routenName),
      route(StartmenueSeite.routenName),
    );
    expect(UpdateReloadGuard.istAufSichererSeite, isFalse);

    guard.didPop(
      route(TagesabschlussSchritt1Seite.routenName),
      route(StartmenueSeite.routenName),
    );
    expect(UpdateReloadGuard.istAufSichererSeite, isTrue);
  });

  test(
      'didReplace setzt die aktuelle Route auf newRoute', () {
    guard.didReplace(
      newRoute: route(KinoauswahlSeite.routenName),
      oldRoute: route(TagesabschlussSchritt1Seite.routenName),
    );
    expect(UpdateReloadGuard.istAufSichererSeite, isTrue);

    guard.didReplace(
      newRoute: route(TagesabschlussSchritt1Seite.routenName),
      oldRoute: route(KinoauswahlSeite.routenName),
    );
    expect(UpdateReloadGuard.istAufSichererSeite, isFalse);
  });
}
