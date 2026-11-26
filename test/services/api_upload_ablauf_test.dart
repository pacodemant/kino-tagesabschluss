import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/flurbocash_zuordnung.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/models/terminal_eintrag.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Run 510 (Audit G1): der komplette Sendeablauf ApiUploadService.upload()
// gegen einen nachgebauten Flurbocash-Server (MockClient) — Erstversand,
// Korrektur per settlement_number, Fallback bei gelöschter Abrechnung,
// Antwort ohne Nummer, HTTP-Fehler, Netzwerkfehler, fehlende Konfiguration,
// TID-Prüfung und Livemodus. Vorher lief keiner dieser Pfade in einem Test.

const String _url = 'https://fc.test';
const String _tid = '11112222';
final DateTime _tag = DateTime(2026, 11, 20);

TagesabschlussFinal _abrechnung({
  String kinoId = 'kino_01',
  String kinoName = 'Schauburg',
  String? anmerkung,
}) {
  return TagesabschlussFinal(
    kinoId: kinoId,
    kinoName: kinoName,
    datum: _tag,
    createdAt: DateTime(2026, 11, 20, 23, 0),
    scheineCent: 100000,
    loseMuenzenCent: 0,
    rollenCent: 0,
    umschlaegeCent: 0,
    kassenbestandGesamtCent: 100000,
    wechselgeldSollwertCent: 0,
    barBestandAbzglWechselgeldCent: 100000,
    kinoSollCent: 130000,
    bistroSollCent: 0,
    ausgabenCent: 0,
    ecBelegeCent: const <int>[30000],
    ecUmsatzGesamtCent: 30000,
    gesamtSollCent: 130000,
    gesamtIstCent: 130000,
    differenzGesamtCent: 0,
    differenzAnfangsbestandCent: 0,
    terminalId: _tid,
    anmerkung: anmerkung,
    zahlungsartenAufschluesselung: <ZahlungsartErgebnis>[
      ZahlungsartErgebnis(art: 'Girocard', betragCent: 30000),
    ],
  );
}

/// Nachgebauter FC-Server. [ensure] und [settlements] liefern die Antwort
/// je Aufruf (Index = wievielter Aufruf dieser Art), alle Anfragen landen
/// in [anfragen].
class _FcServer {
  _FcServer({
    List<http.Response Function(http.Request)>? settlements,
    http.Response Function(http.Request)? ensure,
  })  : _settlements = settlements ??
            <http.Response Function(http.Request)>[
              (_) => _json(<String, dynamic>{
                    'settlements': <Map<String, dynamic>>[
                      <String, dynamic>{'settlement_number': 1},
                    ],
                  }),
            ],
        _ensure = ensure;

  int reportId = 42;
  final List<http.Response Function(http.Request)> _settlements;
  final http.Response Function(http.Request)? _ensure;
  final List<http.Request> anfragen = <http.Request>[];
  int _settlementsAufrufe = 0;

  MockClient get client => MockClient((http.Request req) async {
        anfragen.add(req);
        if (req.url.path.endsWith('/ensure')) {
          return _ensure?.call(req) ??
              _json(<String, dynamic>{'report_id': reportId});
        }
        final int i = _settlementsAufrufe++;
        return _settlements[i < _settlements.length
            ? i
            : _settlements.length - 1](req);
      });

  Map<String, dynamic> settlementVon(int anfrageIndex) {
    final Map<String, dynamic> body =
        jsonDecode(anfragen[anfrageIndex].body) as Map<String, dynamic>;
    return (body['settlements'] as List<dynamic>).first
        as Map<String, dynamic>;
  }
}

http.Response _json(Map<String, dynamic> daten, [int code = 200]) =>
    http.Response(jsonEncode(daten), code,
        headers: <String, String>{'content-type': 'application/json'});

void _sandboxKonfig({String kinoId = 'kino_01'}) {
  SharedPreferences.setMockInitialValues(<String, Object>{
    ApiUploadService.apiUploadUrlPrefKey: _url,
    ApiUploadService.apiKeyPrefKey(kinoId): 'key-$kinoId',
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ApiUploadService.testClient = null;
    ApiUploadService.zeitlimit = const Duration(seconds: 90);
  });

  test('Erstversand: ensure + settlements, Nummer wird gemerkt', () async {
    _sandboxKonfig();
    final _FcServer fc = _FcServer();
    ApiUploadService.testClient = fc.client;

    final FlurbocashUploadErgebnis ergebnis =
        await ApiUploadService.upload(_abrechnung(anmerkung: 'alles ok'));

    expect(fc.anfragen, hasLength(2));
    final http.Request ensure = fc.anfragen[0];
    expect(ensure.method, 'POST');
    expect(ensure.url.toString(), '$_url/api/daily-reports/ensure');
    expect(ensure.headers['X-API-Key'], 'key-kino_01');
    expect(jsonDecode(ensure.body), <String, dynamic>{
      'location_id': 1, // SB Sandbox laut Kino-Modell
      'date': '2026-11-20',
    });

    final http.Request put = fc.anfragen[1];
    expect(put.method, 'PUT');
    expect(put.url.toString(), '$_url/api/daily-reports/42/settlements');
    final Map<String, dynamic> settlement = fc.settlementVon(1);
    expect(settlement.containsKey('settlement_number'), isFalse);
    expect(settlement['cash_total'], 100000);
    expect(settlement['note'], 'alles ok');
    final Map<String, dynamic> terminal =
        (settlement['terminals'] as List<dynamic>).single
            as Map<String, dynamic>;
    expect(terminal['tid'], _tid);
    expect(terminal['girocard'], 30000);

    expect(ergebnis.warKorrektur, isFalse);
    expect(ergebnis.ohneAbrechnungsnummer, isFalse);
    final FlurbocashZuordnung? gemerkt =
        await ApiUploadService.ladeTagesZuordnung('kino_01', _tag);
    expect(gemerkt?.settlementNummer, 1);
    expect(gemerkt?.reportId, 42);
    expect(gemerkt?.korrigiert, isFalse);
  });

  test('zweiter Versand am selben Tag: Korrektur mit settlement_number',
      () async {
    _sandboxKonfig();
    final _FcServer fc = _FcServer();
    ApiUploadService.testClient = fc.client;

    await ApiUploadService.upload(_abrechnung());
    final FlurbocashUploadErgebnis zweiter =
        await ApiUploadService.upload(_abrechnung(anmerkung: 'korrigiert'));

    expect(fc.anfragen, hasLength(4));
    expect(fc.settlementVon(3)['settlement_number'], 1);
    expect(zweiter.warKorrektur, isTrue);
    expect(
      (await ApiUploadService.ladeTagesZuordnung('kino_01', _tag))
          ?.korrigiert,
      isTrue,
    );
  });

  test('anderer Tagesbericht (report_id) → keine fremde Abrechnung '
      'überschreiben', () async {
    _sandboxKonfig();
    final _FcServer fc = _FcServer();
    ApiUploadService.testClient = fc.client;

    await ApiUploadService.upload(_abrechnung());
    fc.reportId = 99; // z. B. Sandbox zurückgesetzt
    final FlurbocashUploadErgebnis zweiter =
        await ApiUploadService.upload(_abrechnung());

    expect(fc.settlementVon(3).containsKey('settlement_number'), isFalse);
    expect(zweiter.warKorrektur, isFalse);
  });

  test('gemerkte Abrechnung bei FC gelöscht → neu anlegen, neue Nummer',
      () async {
    _sandboxKonfig();
    final _FcServer fc = _FcServer(
      settlements: <http.Response Function(http.Request)>[
        (_) => _json(<String, dynamic>{
              'settlements': <Map<String, dynamic>>[
                <String, dynamic>{'settlement_number': 1},
              ],
            }),
        (_) => http.Response(
              'settlement 1 does not exist; omit settlement_number to '
              'create a new settlement',
              400,
            ),
        (_) => _json(<String, dynamic>{
              'settlements': <Map<String, dynamic>>[
                <String, dynamic>{'settlement_number': 2},
              ],
            }),
      ],
    );
    ApiUploadService.testClient = fc.client;

    await ApiUploadService.upload(_abrechnung());
    final FlurbocashUploadErgebnis zweiter =
        await ApiUploadService.upload(_abrechnung());

    // ensure, PUT (Erstversand), ensure, PUT mit Nr. 1 (400), PUT ohne Nr.
    expect(fc.anfragen, hasLength(5));
    expect(fc.settlementVon(3)['settlement_number'], 1);
    expect(fc.settlementVon(4).containsKey('settlement_number'), isFalse);
    expect(zweiter.warKorrektur, isFalse);
    final FlurbocashZuordnung? gemerkt =
        await ApiUploadService.ladeTagesZuordnung('kino_01', _tag);
    expect(gemerkt?.settlementNummer, 2);
  });

  test('FC antwortet 2xx ohne Nummer → Erfolg, aber nichts gemerkt',
      () async {
    _sandboxKonfig();
    final _FcServer fc = _FcServer(
      settlements: <http.Response Function(http.Request)>[
        (_) => http.Response('', 204),
      ],
    );
    ApiUploadService.testClient = fc.client;

    final FlurbocashUploadErgebnis ergebnis =
        await ApiUploadService.upload(_abrechnung());

    expect(ergebnis.ohneAbrechnungsnummer, isTrue);
    expect(
      await ApiUploadService.ladeTagesZuordnung('kino_01', _tag),
      isNull,
    );
  });

  final Map<int, String> fehlerTexte = <int, String>{
    400: 'Ungültige Daten',
    401: 'API-Key ungültig',
    403: 'nicht berechtigt',
    404: 'Tagesbericht nicht gefunden',
    500: 'Serverfehler',
    502: 'HTTP 502',
  };
  for (final MapEntry<int, String> fall in fehlerTexte.entries) {
    test('HTTP ${fall.key} bei ensure → Fehler, kein settlements-Aufruf, '
        'nichts gemerkt', () async {
      _sandboxKonfig();
      final _FcServer fc = _FcServer(
        ensure: (_) => http.Response('nein', fall.key),
      );
      ApiUploadService.testClient = fc.client;

      await expectLater(
        ApiUploadService.upload(_abrechnung()),
        throwsA(predicate((Object e) => e.toString().contains(fall.value))),
      );
      expect(fc.anfragen, hasLength(1));
      expect(
        await ApiUploadService.ladeTagesZuordnung('kino_01', _tag),
        isNull,
      );
    });
  }

  test('Serverfehler bei settlements → Fehler, nichts gemerkt', () async {
    _sandboxKonfig();
    final _FcServer fc = _FcServer(
      settlements: <http.Response Function(http.Request)>[
        (_) => http.Response('kaputt', 500),
      ],
    );
    ApiUploadService.testClient = fc.client;

    await expectLater(
      ApiUploadService.upload(_abrechnung()),
      throwsA(predicate((Object e) => e.toString().contains('Serverfehler'))),
    );
    expect(
      await ApiUploadService.ladeTagesZuordnung('kino_01', _tag),
      isNull,
    );
  });

  test('kein Netz → "Keine Verbindung", nichts gemerkt', () async {
    _sandboxKonfig();
    ApiUploadService.testClient = MockClient(
      (http.Request req) async => throw http.ClientException('Failed to fetch'),
    );

    await expectLater(
      ApiUploadService.upload(_abrechnung()),
      throwsA(
        predicate((Object e) => e.toString().contains('Keine Verbindung')),
      ),
    );
    expect(
      await ApiUploadService.ladeTagesZuordnung('kino_01', _tag),
      isNull,
    );
  });

  test('Server antwortet nicht → Zeitlimit, Meldung wie bei fehlendem Netz',
      () async {
    _sandboxKonfig();
    ApiUploadService.zeitlimit = const Duration(milliseconds: 50);
    ApiUploadService.testClient = MockClient(
      (http.Request req) => Completer<http.Response>().future,
    );

    Object? fehler;
    try {
      await ApiUploadService.upload(_abrechnung());
    } catch (e) {
      fehler = e;
    }
    expect(fehler.toString(), contains('Zeitüberschreitung'));
    expect(ApiUploadService.isCorsArtFehler(fehler!), isTrue);
    expect(
      await ApiUploadService.ladeTagesZuordnung('kino_01', _tag),
      isNull,
    );
  });

  test('keine URL eingetragen → Abbruch vor jedem Netzwerkaufruf', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _FcServer fc = _FcServer();
    ApiUploadService.testClient = fc.client;

    await expectLater(
      ApiUploadService.upload(_abrechnung()),
      throwsA(predicate((Object e) => e.toString().contains('URL'))),
    );
    expect(fc.anfragen, isEmpty);
  });

  test('TID nicht in den Einstellungen → Abbruch vor jedem Netzwerkaufruf',
      () async {
    _sandboxKonfig();
    await TerminalIdsConfigService.speichereTerminals(
      'kino_01',
      const <TerminalEintrag>[TerminalEintrag(tid: '99998888')],
    );
    final _FcServer fc = _FcServer();
    ApiUploadService.testClient = fc.client;

    await expectLater(
      ApiUploadService.upload(_abrechnung()),
      throwsA(predicate((Object e) => e.toString().contains('TID'))),
    );
    expect(fc.anfragen, isEmpty);
  });

  test('Livemodus CO: Live-URL und Live-location_id 5', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ApiUploadService.apiUploadUrlPrefKey: 'https://sandbox.test',
      ApiUploadService.uploadUrlPrefKey(live: true): 'https://live.test',
      ApiUploadService.apiKeyPrefKey('kino_04'): 'key-co',
      ApiUploadService.liveModusPrefKey('kino_04'): true,
    });
    final _FcServer fc = _FcServer();
    ApiUploadService.testClient = fc.client;

    await ApiUploadService.upload(
      _abrechnung(kinoId: 'kino_04', kinoName: 'Cinema Ostertor'),
    );

    expect(
      fc.anfragen.first.url.toString(),
      'https://live.test/api/daily-reports/ensure',
    );
    expect(
      (jsonDecode(fc.anfragen.first.body) as Map<String, dynamic>)[
          'location_id'],
      5,
    );
  });

  test('Livemodus SB ohne Live-location_id → Abbruch mit Hinweis', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ApiUploadService.uploadUrlPrefKey(live: true): 'https://live.test',
      ApiUploadService.apiKeyPrefKey('kino_01'): 'key-sb',
      ApiUploadService.liveModusPrefKey('kino_01'): true,
    });
    final _FcServer fc = _FcServer();
    ApiUploadService.testClient = fc.client;

    await expectLater(
      ApiUploadService.upload(_abrechnung()),
      throwsA(predicate((Object e) => e.toString().contains('location_id'))),
    );
    expect(fc.anfragen, isEmpty);
  });
}
