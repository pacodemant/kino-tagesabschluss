import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';

class BelegScanException implements Exception {
  BelegScanException(this.message);

  final String message;

  @override
  String toString() => 'BelegScanException: $message';
}

class BelegScanService {
  BelegScanService._();

  static const String _workerUrl =
      'https://kartenzahlungsbelegscan.pacodemant.workers.dev';

  static const String _systemPrompt =
      'Du bist ein Belegscanner für Kassensysteme. '
      'Antworte IMMER und ausschließlich mit reinem JSON – '
      'kein Fließtext, keine Erklärungen, kein Satz außerhalb des JSON.\n'
      '\n'
      'Du bekommst ein Foto. Prüfe zuerst: Zeigt es einen EC-Terminal-Beleg\n'
      '(Kassenschnitt, Tagessaldo, Händler-Abschlussbeleg)?\n'
      '\n'
      'Wenn NEIN – antworte NUR mit diesem JSON:\n'
      '{"kein_terminal_beleg": true, "hinweis": "..."}\n'
      '\n'
      'Wenn JA – antworte NUR mit diesem JSON (keine Backticks, kein Markdown):\n'
      '{\n'
      '  "kein_terminal_beleg": false,\n'
      '  "terminal_id": "...",\n'
      '  "datum": "...",\n'
      '  "uhrzeit": "...",\n'
      '  "beleg_nr_von": "...",\n'
      '  "beleg_nr_bis": "...",\n'
      '  "zahlungsarten": [\n'
      '    { "art": "...", "anzahl": ..., "betrag_cent": ... }\n'
      '  ],\n'
      '  "gesamt_anzahl": ...,\n'
      '  "gesamt_betrag_cent": ...,\n'
      '  "hinweis": null\n'
      '}\n'
      '\n'
      'Regeln:\n'
      '- Beträge immer in Cent (ganzzahlig, kein Komma, kein Punkt als Tausender).\n'
      '- Kartenarten auf Hauptart summieren: "girocard Online" und "girocard PIN"\n'
      '  werden zu einer Zeile "girocard" zusammengefasst. Gleiches gilt für\n'
      '  MasterCard, SEPA Lastschrift, Visa und alle weiteren Kartenarten.\n'
      '- Nur Kartenarten ausgeben die auf dem Beleg stehen.\n'
      '- Wenn ein Feld nicht lesbar oder nicht auf dem Beleg vorhanden ist: null.\n'
      '- Schätzen, Interpolieren und Ergänzen ist strikt verboten. Gib nur\n'
      '  Werte aus, die auf dem Foto zweifelsfrei und vollständig lesbar sind.\n'
      '  Ist ein Feld auch nur teilweise unleserlich, verdeckt, unscharf oder\n'
      '  abgeschnitten: null – auch wenn ein Wert plausibel erscheint.\n'
      '- "hinweis" NUR setzen wenn die Summe der einzelnen Zahlungsart-Beträge\n'
      '  rechnerisch NICHT mit gesamt_betrag_cent übereinstimmt: dann einen kurzen\n'
      '  deutschen Satz (max. 8 Wörter, keine Zahlen). In ALLEN anderen Fällen: null.\n'
      '  Keine visuellen Einschätzungen, keine Warnungen, kein Freitext in hinweis.';

  static Future<BelegScanErgebnis> scan(XFile bild) async {
    final List<int> bytes = await bild.readAsBytes();
    final String base64Bild = base64Encode(bytes);
    final String mimeType = bild.mimeType ?? 'image/jpeg';

    final Map<String, dynamic> requestBody = <String, dynamic>{
      'model': 'claude-sonnet-4-6',
      'max_tokens': 1024,
      'system': _systemPrompt,
      'messages': <dynamic>[
        <String, dynamic>{
          'role': 'user',
          'content': <dynamic>[
            <String, dynamic>{
              'type': 'image',
              'source': <String, dynamic>{
                'type': 'base64',
                'media_type': mimeType,
                'data': base64Bild,
              },
            },
          ],
        },
      ],
    };

    final http.Response response;
    try {
      response = await http.post(
        Uri.parse(_workerUrl),
        headers: <String, String>{
          'content-type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
    } catch (_) {
      throw BelegScanException(
          'Keine Internetverbindung. Bitte Verbindung prüfen.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BelegScanException(
          'HTTP ${response.statusCode}: ${response.body}');
    }

    try {
      final Map<String, dynamic> responseJson =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> content =
          responseJson['content'] as List<dynamic>;
      String text =
          (content[0] as Map<String, dynamic>)['text'] as String;
      final Match? block =
          RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(text);
      if (block != null) text = block.group(1)!;
      text = text.trim();
      if (!text.startsWith('{')) {
        throw BelegScanException(
            'Bitte erneut scannen – Beleg war nicht eindeutig erkennbar.');
      }
      final Map<String, dynamic> ergebnisJson =
          jsonDecode(text) as Map<String, dynamic>;
      return BelegScanErgebnis.fromJson(ergebnisJson);
    } on BelegScanException {
      rethrow;
    } on FormatException {
      throw BelegScanException(
          'Beleg war nicht eindeutig lesbar – bitte erneut scannen.');
    } catch (_) {
      throw BelegScanException(
          'Scan fehlgeschlagen – bitte erneut versuchen.');
    }
  }
}
