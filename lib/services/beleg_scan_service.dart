import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BelegScanException implements Exception {
  BelegScanException(this.message);

  final String message;

  @override
  String toString() => 'BelegScanException: $message';
}

class BelegScanService {
  BelegScanService._();

  static const String _systemPrompt =
      'Du bist ein Belegscanner für Kassensysteme.\n'
      'Du bekommst ein Foto eines EC-Kartenbelegs (Kassenschnitt).\n'
      'Extrahiere folgende Felder und antworte NUR mit JSON,\n'
      'ohne Erklärung, ohne Markdown-Backticks:\n'
      '\n'
      '{\n'
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
      '- Wenn ein Feld nicht lesbar ist: null.\n'
      '- Wenn du eine Unstimmigkeit erkennst (Summe passt nicht, Beleg\n'
      '  abgeschnitten, Wert unleserlich): kurzen deutschen Hinweistext in\n'
      '  "hinweis" eintragen. Sonst: null.';

  static Future<BelegScanErgebnis> scan(XFile bild) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String apiKey = speicher.getString('anthropic_api_key') ?? '';
    if (apiKey.isEmpty) {
      throw BelegScanException(
        'Kein Anthropic API-Key hinterlegt. '
        'Bitte in den Einstellungen eintragen.',
      );
    }

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

    final http.Response response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: <String, String>{
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BelegScanException(
          'HTTP ${response.statusCode}: ${response.body}');
    }

    try {
      final Map<String, dynamic> responseJson =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> content =
          responseJson['content'] as List<dynamic>;
      final String text =
          (content[0] as Map<String, dynamic>)['text'] as String;
      final Map<String, dynamic> ergebnisJson =
          jsonDecode(text) as Map<String, dynamic>;
      return BelegScanErgebnis.fromJson(ergebnisJson);
    } catch (e) {
      throw BelegScanException(
          'Antwort konnte nicht geparst werden: $e');
    }
  }
}
