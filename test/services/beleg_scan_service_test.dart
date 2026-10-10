import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kino_bar_app/services/beleg_scan_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deckt die Fehlerpfade von BelegScanService.scan() ab — http.post() ist
/// direkt aufgerufen, es gibt ohne den Test-Seam httpPostUeberschreibung
/// keine Stelle, an der ein Test den Netzwerk-Call abfangen könnte.
void main() {
  XFile fakeBild() => XFile.fromData(
        Uint8List.fromList(<int>[1, 2, 3]),
        mimeType: 'image/jpeg',
      );

  String anthropicAntwortMitText(String text) => jsonEncode(
        <String, dynamic>{
          'content': <dynamic>[
            <String, dynamic>{'text': text},
          ],
        },
      );

  String anthropicAntwort(Map<String, dynamic> belegJson) =>
      anthropicAntwortMitText(jsonEncode(belegJson));

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      BelegScanService.belegScanUrlPrefKey: 'https://worker.example/scan',
    });
  });

  tearDown(() {
    // Seam immer zurücksetzen — sonst könnte ein vergessener Fake aus
    // diesem Test einen späteren Test (oder im schlimmsten Fall einen
    // echten Lauf in derselben Isolate) beeinflussen.
    BelegScanService.httpPostUeberschreibung = null;
  });

  test(
      'Service-URL nicht konfiguriert -> BelegScanException mit '
      'entsprechendem Hinweis', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    expect(
      () => BelegScanService.scan(fakeBild()),
      throwsA(
        isA<BelegScanException>().having(
          (BelegScanException e) => e.message,
          'message',
          contains('Service-URL nicht konfiguriert'),
        ),
      ),
    );
  });

  test(
      'Erfolgsfall: gueltige Antwort wird zu BelegScanErgebnis geparst, '
      'Foto wird unveraendert zurueckgegeben', () async {
    BelegScanService.httpPostUeberschreibung =
        (Uri url, Map<String, String> headers, String body) async =>
            http.Response(
              anthropicAntwort(<String, dynamic>{
                'kein_terminal_beleg': false,
                'terminal_id': '12345678',
                'gesamt_betrag_cent': 5000,
                'zahlungsarten': <dynamic>[
                  <String, dynamic>{'art': 'girocard', 'betrag_cent': 5000},
                ],
              }),
              200,
            );

    final ({
      dynamic ergebnis,
      String fotoBase64,
      String fotoMediaType,
    }) resultat = await BelegScanService.scan(fakeBild());

    expect(resultat.ergebnis.terminalId, '12345678');
    expect(resultat.ergebnis.gesamtBetragCent, 5000);
    expect(resultat.fotoMediaType, 'image/jpeg');
  });

  test(
      'Erfolgsfall mit Markdown-Codeblock (```json ... ```) um die '
      'Antwort wird trotzdem korrekt geparst', () async {
    const Map<String, dynamic> belegJson = <String, dynamic>{
      'kein_terminal_beleg': false,
    };
    BelegScanService.httpPostUeberschreibung =
        (Uri url, Map<String, String> headers, String body) async =>
            http.Response(
              anthropicAntwortMitText(
                '```json\n${jsonEncode(belegJson)}\n```',
              ),
              200,
            );

    final ({
      dynamic ergebnis,
      String fotoBase64,
      String fotoMediaType,
    }) resultat = await BelegScanService.scan(fakeBild());

    expect(resultat.ergebnis.keinTerminalBeleg, isFalse);
  });

  test(
      'Netzwerkfehler (httpPostUeberschreibung wirft) -> BelegScanException '
      '"Keine Internetverbindung"', () async {
    BelegScanService.httpPostUeberschreibung =
        (Uri url, Map<String, String> headers, String body) async =>
            throw Exception('Failed to fetch');

    expect(
      () => BelegScanService.scan(fakeBild()),
      throwsA(
        isA<BelegScanException>().having(
          (BelegScanException e) => e.message,
          'message',
          contains('Keine Internetverbindung'),
        ),
      ),
    );
  });

  test(
      'HTTP-Fehlercode (z.B. 500) -> BelegScanException mit Statuscode in '
      'der Meldung', () async {
    BelegScanService.httpPostUeberschreibung =
        (Uri url, Map<String, String> headers, String body) async =>
            http.Response('Internal Server Error', 500);

    expect(
      () => BelegScanService.scan(fakeBild()),
      throwsA(
        isA<BelegScanException>().having(
          (BelegScanException e) => e.message,
          'message',
          contains('HTTP 500'),
        ),
      ),
    );
  });

  test(
      'Antwort ohne erkennbares JSON (reiner Fliesstext) -> '
      'BelegScanException "nicht eindeutig erkennbar"', () async {
    BelegScanService.httpPostUeberschreibung =
        (Uri url, Map<String, String> headers, String body) async =>
            http.Response(
              anthropicAntwortMitText('Kein Beleg auf dem Foto erkennbar.'),
              200,
            );

    expect(
      () => BelegScanService.scan(fakeBild()),
      throwsA(
        isA<BelegScanException>().having(
          (BelegScanException e) => e.message,
          'message',
          contains('nicht eindeutig erkennbar'),
        ),
      ),
    );
  });

  test(
      'Kaputtes JSON innerhalb der Antwort -> BelegScanException '
      '"nicht eindeutig lesbar"', () async {
    BelegScanService.httpPostUeberschreibung =
        (Uri url, Map<String, String> headers, String body) async =>
            http.Response(
              jsonEncode(<String, dynamic>{
                'content': <dynamic>[
                  <String, dynamic>{'text': '{"kaputt": '},
                ],
              }),
              200,
            );

    expect(
      () => BelegScanService.scan(fakeBild()),
      throwsA(
        isA<BelegScanException>().having(
          (BelegScanException e) => e.message,
          'message',
          contains('nicht eindeutig lesbar'),
        ),
      ),
    );
  });
}
