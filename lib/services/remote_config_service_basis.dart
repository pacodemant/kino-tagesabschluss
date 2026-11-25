import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Gemeinsamer Ablauf für die Geräte-Konfigs Getränkelisten und
// Wechselgeldbeträge: Ist auf dem Gerät noch nichts gespeichert, wird
// beim App-Start die mit der App ausgelieferte Startliste (Asset)
// übernommen; ein vorhandener Stand (z. B. vor Ort von Hand
// eingetragen) wird nie überschrieben.
//
// Bis Run 508 wurde bei leerem Stand zuerst die Datei aus dem GitHub-
// Repo geholt (raw.githubusercontent.com) und bei vorhandenem Stand bei
// jedem Start ein Update-Datum verglichen — ohne Zeitlimit und vor
// runApp(), d. h. bei schlechtem Netz blieb die App weiß (Audit D2).
// Seit Run 509 kein Netzabruf mehr: Die Werte werden im Live-Betrieb vor
// Ort im Smartphone eingetragen (Paco, 25.11.2026), und das Repo soll
// später privat werden. Der Klassenname bleibt aus Kompatibilität.
abstract class RemoteConfigServiceBasis<T> {
  const RemoteConfigServiceBasis();

  String get localKey;
  String get localDateKey;
  String get logTag;

  T get leererWert;
  bool datenSindLeer(T daten);
  (String datum, T daten) parseInhalt(String inhalt);
  String kodiere(T daten);
  T dekodiere(String rohwert);

  /// Mitgelieferte Startliste (Asset). Wird nur genutzt, wenn auf dem
  /// Gerät noch kein Stand gespeichert ist. Default: keine vorhanden.
  Future<(String datum, T daten)?> assetFallback() async => null;

  Future<void> initOnAppStart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final T vorhanden = await _ladeLokal(prefs);
    if (!datenSindLeer(vorhanden)) {
      return;
    }
    final (String, T)? startliste = await assetFallback();
    if (startliste == null) {
      debugPrint('[$logTag] Keine Startliste vorhanden');
      return;
    }
    final (String datum, T daten) = startliste;
    await prefs.setString(localKey, kodiere(daten));
    await prefs.setString(localDateKey, datum);
    debugPrint('[$logTag] Startliste übernommen, Datum: $datum');
  }

  Future<T> ladeGespeichertenWert() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return _ladeLokal(prefs);
  }

  Future<void> speichereWert(T daten) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(localKey, kodiere(daten));
  }

  Future<T> _ladeLokal(SharedPreferences prefs) async {
    final String? rohwert = prefs.getString(localKey);
    if (rohwert == null || rohwert.isEmpty) {
      return leererWert;
    }
    try {
      return dekodiere(rohwert);
    } catch (_) {
      return leererWert;
    }
  }
}
