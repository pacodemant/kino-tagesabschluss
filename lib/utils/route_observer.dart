import 'package:flutter/material.dart';

/// Global verfügbar, damit Seiten per RouteAware erkennen können, wenn sie
/// nach einem `pop()` einer darüberliegenden Route wieder sichtbar werden
/// (z. B. StartmenueSeite nach Rückkehr aus dem Verlauf) — ohne das reicht
/// initState() nicht, da die Widget-Instanz beim bloßen Zurücknavigieren
/// nicht neu erzeugt wird.
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();
