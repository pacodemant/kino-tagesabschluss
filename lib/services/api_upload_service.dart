import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiUploadService {
  ApiUploadService._();

  static const String apiUploadUrlPrefKey = 'api_upload_url';

  // Schluessel normalisiert (getrimmt + kleingeschrieben) — der Lookup in
  // _terminalsListe() normalisiert z.art genauso, damit vom Beleg-Scan
  // gelieferte Varianten wie "MASTERCARD" oder " Girocard" nicht am reinen
  // String-Vergleich scheitern und den Betrag stillschweigend verlieren.
  static const Map<String, String> _kartenartMapping = <String, String>{
    'girocard': 'girocard',
    'sepa lastschrift': 'lastschrift',
    'lastschrift': 'lastschrift',
    'mastercard': 'mastercard',
    'visa': 'visa',
    'maestro': 'maestro',
    'v pay': 'vpay',
    'vpay': 'vpay',
  };

  static const List<String> _kartenfelder = <String>[
    'girocard',
    'lastschrift',
    'mastercard',
    'visa',
    'maestro',
    'vpay',
  ];

  /// Liefert Warnungen zu nicht erkannten TIDs zusaetzlich zum normalen
  /// Erfolg — siehe [_pruefeTerminalIds]: die Referenzliste in
  /// config/terminal_ids.json ist laut TODO.md fuer alle Standorte noch
  /// nicht von Yannik bestaetigt, ein harter Block waere daher riskant.
  static Future<List<String>> upload(TagesabschlussFinal abrechnung) async {
    final ({String url, int locationId, String apiKey}) konfig =
        await _ladeKonfigWerte(abrechnung.kinoId);

    final List<String> warnungen = await _pruefeTerminalIds(abrechnung);

    final int reportId = await _ensure(
      konfig.url,
      konfig.apiKey,
      konfig.locationId,
      abrechnung,
    );
    await _speichereReportId(abrechnung.kinoId, abrechnung.datum, reportId);

    await _settlements(konfig.url, konfig.apiKey, reportId, abrechnung);
    return warnungen;
  }

  /// Gleicht die tatsächlich zu sendenden TIDs gegen config/terminal_ids.json
  /// ab. Bewusst NICHT blockierend (siehe pruefeTerminalIdsGegenKonfiguration):
  /// solange Yannik die TIDs nicht bestaetigt hat, darf eine falsche
  /// Referenzliste keine echten Abrechnungen verhindern.
  static Future<List<String>> _pruefeTerminalIds(
    TagesabschlussFinal abrechnung,
  ) async {
    final List<String> tids =
        tidsAusSettlementsBody(settlementsBody(abrechnung));
    if (tids.isEmpty) return const <String>[];

    final Kino? kino = KinoRepository.nachId(abrechnung.kinoId);
    final Map<String, List<String>> konfiguration =
        await TerminalIdsConfigService.laden();
    return pruefeTerminalIdsGegenKonfiguration(tids, kino, konfiguration);
  }

  /// Extrahiert alle TIDs aus einem bereits gebauten settlementsBody().
  static List<String> tidsAusSettlementsBody(Map<String, dynamic> body) {
    final List<String> tids = <String>[];
    for (final dynamic settlement in body['settlements'] as List<dynamic>) {
      final List<dynamic> terminals =
          (settlement as Map<String, dynamic>)['terminals'] as List<dynamic>;
      for (final dynamic terminal in terminals) {
        tids.add((terminal as Map<String, dynamic>)['tid'] as String);
      }
    }
    return tids;
  }

  /// Reine, testbare Pruefung ohne Asset-Zugriff: liefert eine Warnmeldung
  /// pro TID, die leer ist oder nicht zu den fuer [kino] registrierten TIDs
  /// aus config/terminal_ids.json passt. Wirft bewusst NICHT — die
  /// Referenzliste ist laut TODO.md noch unbestaetigt, ein Fehlalarm darf
  /// den Versand nicht verhindern.
  static List<String> pruefeTerminalIdsGegenKonfiguration(
    List<String> verwendeteTids,
    Kino? kino,
    Map<String, List<String>> konfiguration,
  ) {
    if (kino == null) return const <String>[];
    final List<String> erlaubte =
        konfiguration[kino.kuerzel] ?? const <String>[];
    final List<String> warnungen = <String>[];
    for (final String tid in verwendeteTids) {
      if (tid.isEmpty) {
        warnungen.add(
          'Keine Terminal-ID (TID) angegeben, obwohl EC-Umsatz erfasst '
          'wurde.',
        );
        continue;
      }
      if (!erlaubte.contains(tid)) {
        final String erwartetText =
            erlaubte.isEmpty ? 'keine TID hinterlegt' : erlaubte.join(', ');
        warnungen.add(
          'TID "$tid" ist fuer ${kino.name} nicht als Terminal hinterlegt '
          '(erwartet: $erwartetText). Bitte pruefen.',
        );
      }
    }
    return warnungen;
  }

  static Future<({String url, int locationId, String apiKey})> _ladeKonfigWerte(
    String kinoId,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();

    final String baseUrl = speicher.getString(apiUploadUrlPrefKey) ?? '';
    if (baseUrl.isEmpty) {
      throw Exception(
        'Keine Flurbocash-URL konfiguriert. Bitte Upload-URL in den Einstellungen eintragen.',
      );
    }

    final String? locationIdStr =
        speicher.getString('flurbocash_location_id_$kinoId');
    final int locationId =
        (locationIdStr != null && locationIdStr.isNotEmpty)
            ? (int.tryParse(locationIdStr) ?? 0)
            : 0;

    final String? perKinoKey =
        speicher.getString('flurbocash_api_key_$kinoId');
    final String apiKey = (perKinoKey != null && perKinoKey.isNotEmpty)
        ? perKinoKey
        : (speicher.getString('api_upload_key') ?? '');

    return (url: baseUrl, locationId: locationId, apiKey: apiKey);
  }

  static Map<String, dynamic> ensureBody(
    TagesabschlussFinal abrechnung,
    int locationId,
  ) {
    return <String, dynamic>{
      'location_id': locationId,
      'date': DatumsHelper.isoDatum(abrechnung.datum),
    };
  }

  /// [jetzt] optional für Tests (sonst DateTime.now()) — bestimmt nur den
  /// mitgeschickten Sende-Zeitpunkt, keine fachliche Logik.
  static Map<String, dynamic> settlementsBody(
    TagesabschlussFinal abrechnung, {
    DateTime? jetzt,
  }) {
    return <String, dynamic>{
      'settlements': <Map<String, dynamic>>[
        <String, dynamic>{
          'cash_total': abrechnung.barBestandAbzglWechselgeldCent,
          if (abrechnung.anmerkung != null && abrechnung.anmerkung!.isNotEmpty)
            'note': abrechnung.anmerkung,
          // Yannik: unbekannte/nicht benötigte Felder werden serverseitig
          // ignoriert, kein Vertragsbruch falls FC "sent_at" (noch) nicht
          // auswertet.
          'sent_at': (jetzt ?? DateTime.now()).toIso8601String(),
          'terminals': _terminalsListe(abrechnung),
        },
      ],
    };
  }

  static Future<int> _ensure(
    String baseUrl,
    String apiKey,
    int locationId,
    TagesabschlussFinal abrechnung,
  ) async {
    final Uri uri = Uri.parse('$baseUrl/api/daily-reports/ensure');
    final http.Response response;
    try {
      response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode(ensureBody(abrechnung, locationId)),
      );
    } catch (e) {
      throw Exception('Keine Verbindung zur Flurbocash-API. ($e)');
    }
    _pruefeStatus(response);
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    return (body['report_id'] as num).toInt();
  }

  static Future<void> _settlements(
    String baseUrl,
    String apiKey,
    int reportId,
    TagesabschlussFinal abrechnung,
  ) async {
    final Uri uri =
        Uri.parse('$baseUrl/api/daily-reports/$reportId/settlements');
    final http.Response response;
    try {
      response = await http.put(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode(settlementsBody(abrechnung)),
      );
    } catch (e) {
      throw Exception('Keine Verbindung zur Flurbocash-API. ($e)');
    }
    _pruefeStatus(response);
  }

  static List<Map<String, dynamic>> _terminalsListe(
    TagesabschlussFinal abrechnung,
  ) {
    final List<ZahlungsartErgebnis>? liste =
        abrechnung.zahlungsartenAufschluesselung;
    if (liste == null || liste.isEmpty) {
      if (abrechnung.ecUmsatzGesamtCent > 0) {
        throw Exception(
          'EC-Umsatz '
          '${TagesabschlussFormatierung.formatiereEuro(abrechnung.ecUmsatzGesamtCent)} '
          'erfasst, aber keine Kartenart-Aufschlüsselung vorhanden. Bitte in '
          'Schritt 2 mindestens eine Kartenart mit Betrag eintragen.',
        );
      }
      return <Map<String, dynamic>>[];
    }

    // Gruppierung primär nach Beleg-Index: jeder erfasste Beleg wird ein
    // eigener terminals[]-Eintrag, AUCH wenn zwei Belege dieselbe TID
    // tragen (z. B. zwei Abrechnungen desselben Terminals am selben Tag).
    // Laut Yannik (.dev/flurbocash stuff/fragen_yannik.md, Frage 2.1,
    // 2026-08-26) will Flurbocash genau das: zwei separate Einträge
    // gleicher TID statt einem summierten. Für Alt-Daten ohne belegIndex
    // (gespeichert vor Run 399a3, z. B. erneuter Versand aus dem
    // Verlauf) Fallback auf die alte Gruppierung nach TID.
    final Map<String, Map<String, int>> gruppen = <String, Map<String, int>>{};
    final Map<String, String> tidProGruppe = <String, String>{};
    for (final ZahlungsartErgebnis z in liste) {
      if (z.betragCent == null) continue;
      final String? feldname = _kartenartMapping[z.art.trim().toLowerCase()];
      if (feldname == null) {
        throw Exception(
          'Unbekannte Kartenart "${z.art}" '
          '(${TagesabschlussFormatierung.formatiereEuro(z.betragCent!)}) in '
          'der EC-Aufschlüsselung. Bitte in Schritt 2 korrigieren oder IT '
          'kontaktieren.',
        );
      }
      final String tid = z.tid ?? abrechnung.terminalId ?? '';
      final String gruppenSchluessel =
          z.belegIndex != null ? 'i${z.belegIndex}' : 't$tid';
      final Map<String, int> betraege =
          gruppen.putIfAbsent(gruppenSchluessel, () => <String, int>{});
      betraege[feldname] = (betraege[feldname] ?? 0) + z.betragCent!;
      tidProGruppe[gruppenSchluessel] = tid;
    }

    final Map<String, ({String base64, String mediaType})> fotoProGruppe =
        _fotoProGruppe(abrechnung);
    final List<Map<String, dynamic>> terminals = gruppen.entries
        .map((MapEntry<String, Map<String, int>> e) => _terminalEintrag(
              tidProGruppe[e.key]!,
              e.value,
              fotoProGruppe[e.key],
            ))
        .toList();

    // ecUmsatzGesamtCent (Summe der Beleg-Gesamtbeträge) und
    // zahlungsartenAufschluesselung sind zwei unabhängige Datenquellen
    // (siehe tagesabschluss_finalisieren_usecase.dart) und können
    // auseinanderlaufen, z.B. wenn ein Beleg-Betrag nachträglich manuell
    // korrigiert wird, ohne die Kartenart-Zeilen anzupassen.
    final int summeTerminals = terminals.fold<int>(
      0,
      (int summe, Map<String, dynamic> t) => summe +
          _kartenfelder.fold<int>(
            0,
            (int s, String feld) => s + (t[feld] as int),
          ),
    );
    if (summeTerminals != abrechnung.ecUmsatzGesamtCent) {
      throw Exception(
        'Summe der Kartenart-Aufschlüsselung '
        '(${TagesabschlussFormatierung.formatiereEuro(summeTerminals)}) '
        'stimmt nicht mit dem erfassten EC-Umsatz '
        '(${TagesabschlussFormatierung.formatiereEuro(abrechnung.ecUmsatzGesamtCent)}) '
        'überein. Bitte Belege in Schritt 2 prüfen.',
      );
    }

    return terminals;
  }

  /// Ordnet jedem Gruppenschlüssel aus _terminalsListe() (Beleg-Index
  /// "i0", "i1", ... bzw. TID-Fallback `t<tid>` für Alt-Daten) das
  /// zugehörige Beleg-Foto zu (base64 + media_type). Ein Beleg-Index
  /// zählt nur dann als "hat belegIndex", wenn mindestens eine
  /// Kartenart-Zeile aus zahlungsartenAufschluesselung ihn trägt — sonst
  /// (Alt-Daten vor Run 399a3) Fallback auf TID, mit derselben
  /// "letzter Wert gewinnt"-Regel wie zuvor, falls zwei TID-lose Belege
  /// dieselbe TID teilen (ein Foto ist nicht summierbar wie ein Betrag).
  static Map<String, ({String base64, String mediaType})> _fotoProGruppe(
    TagesabschlussFinal abrechnung,
  ) {
    final List<String>? tids = abrechnung.ecBelegeLabels;
    final List<String>? fotos = abrechnung.ecBelegeFotosBase64;
    final List<String>? mediaTypen = abrechnung.ecBelegeFotosMediaTypen;
    final Map<String, ({String base64, String mediaType})> ergebnis =
        <String, ({String base64, String mediaType})>{};
    if (tids == null || fotos == null) return ergebnis;

    final Set<int> belegIndizesMitZeile = (abrechnung.zahlungsartenAufschluesselung ??
            const <ZahlungsartErgebnis>[])
        .map((ZahlungsartErgebnis z) => z.belegIndex)
        .whereType<int>()
        .toSet();

    for (int i = 0; i < tids.length && i < fotos.length; i++) {
      final String foto = fotos[i];
      if (foto.isEmpty) continue;
      final String mediaType =
          (mediaTypen != null && i < mediaTypen.length && mediaTypen[i].isNotEmpty)
              ? mediaTypen[i]
              : 'image/jpeg';
      if (belegIndizesMitZeile.contains(i)) {
        ergebnis['i$i'] = (base64: foto, mediaType: mediaType);
      } else {
        final String tid = tids[i];
        if (tid.isEmpty) continue;
        ergebnis['t$tid'] = (base64: foto, mediaType: mediaType);
      }
    }
    return ergebnis;
  }

  static Map<String, dynamic> _terminalEintrag(
    String tid,
    Map<String, int> karten,
    ({String base64, String mediaType})? foto,
  ) {
    return <String, dynamic>{
      'tid': tid,
      'girocard': karten['girocard'] ?? 0,
      'lastschrift': karten['lastschrift'] ?? 0,
      'mastercard': karten['mastercard'] ?? 0,
      'visa': karten['visa'] ?? 0,
      'maestro': karten['maestro'] ?? 0,
      if (foto != null) 'receipt_photo': foto.base64,
      if (foto != null) 'receipt_media_type': foto.mediaType,
      'vpay': karten['vpay'] ?? 0,
    };
  }

  static void _pruefeStatus(http.Response response) {
    final int code = response.statusCode;
    if (code >= 200 && code < 300) return;
    final String serverText = response.body.trim();
    final String hinweis = serverText.isEmpty ? '' : ' ($serverText)';
    switch (code) {
      case 400:
        throw Exception(
          'Übertragung fehlgeschlagen: Ungültige Daten oder Terminal-ID unbekannt.$hinweis',
        );
      case 401:
        throw Exception(
          'Zugang verweigert – API-Key ungültig. Bitte Einstellungen prüfen.$hinweis',
        );
      case 403:
        throw Exception(
          'API-Key nicht berechtigt für diesen Standort. Bitte IT kontaktieren.$hinweis',
        );
      case 404:
        throw Exception(
          'Tagesbericht nicht gefunden. Bitte erneut versuchen.$hinweis',
        );
      case 500:
        throw Exception(
          'Serverfehler bei Flurbocash. Bitte später erneut versuchen.$hinweis',
        );
      default:
        throw Exception('Unbekannter Fehler (HTTP $code).$hinweis');
    }
  }

  static Future<void> _speichereReportId(
    String kinoId,
    DateTime datum,
    int reportId,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setInt(
      'flurbocash_report_id_${kinoId}_${_datumKey(datum)}',
      reportId,
    );
  }

  static String _datumKey(DateTime datum) {
    final String monat = datum.month.toString().padLeft(2, '0');
    final String tag = datum.day.toString().padLeft(2, '0');
    return '${datum.year}_${monat}_$tag';
  }

  // Browser blockiert das Lesen der Antwort bei fehlendem CORS-Header,
  // obwohl der POST beim Server ankam. Diese Fehlertexte kommen vom Browser.
  static bool isCorsArtFehler(Object e) {
    final String text = e.toString().toLowerCase();
    return text.contains('failed to fetch') ||
        text.contains('networkerror') ||
        text.contains('load failed');
  }
}
