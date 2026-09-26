import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/models/beleg_scan_ergebnis.dart';
import 'package:kino_bar_app/models/flurbocash_zuordnung.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/services/terminal_ids_config_service.dart';
import 'package:kino_bar_app/storage/sende_protokoll.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/utils/tid_eingabe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiUploadService {
  ApiUploadService._();

  static const String apiUploadUrlPrefKey = 'api_upload_url';

  /// Einzige Quelle fuer den SharedPreferences-Key der Flurbocash-
  /// Location-ID eines Kinos (seit Run 421 zentralisiert, vorher an
  /// mehreren Stellen als rohes String-Literal dupliziert).
  static String locationIdPrefKey(String kinoId) =>
      'flurbocash_location_id_$kinoId';

  /// Einzige Quelle fuer den SharedPreferences-Key des Flurbocash-API-Keys
  /// eines Kinos (seit Run 421 zentralisiert, siehe [locationIdPrefKey]).
  static String apiKeyPrefKey(String kinoId) => 'flurbocash_api_key_$kinoId';

  /// Kanonische Kartenarten-Namen, wie sie in Betrags-Maps und im an
  /// Flurbocash gesendeten JSON verwendet werden. Einzige Quelle seit
  /// Run 423 (vorher als drei unabhaengige Kopien in dieser Klasse
  /// gepflegt: Mapping-Zielwerte, Summenpruefungs-Liste, JSON-Ausgabe
  /// in _terminalEintrag — eine vergessene Stelle haette bei einer
  /// neuen Kartenart einen Betrag stillschweigend verloren).
  static const List<String> _kartenarten = <String>[
    'girocard',
    'lastschrift',
    'mastercard',
    'visa',
    'maestro',
    'vpay',
  ];

  /// Nicht-kanonische Eingabe-Varianten, die auf eine kanonische
  /// Kartenart aus [_kartenarten] gemappt werden (z. B. Beleg-Scan
  /// liefert "SEPA Lastschrift" oder "V Pay").
  static const Map<String, String> _kartenartAliase = <String, String>{
    'sepa lastschrift': 'lastschrift',
    'v pay': 'vpay',
  };

  // Schluessel normalisiert (getrimmt + kleingeschrieben) — der Lookup in
  // _terminalsListe() normalisiert z.art genauso, damit vom Beleg-Scan
  // gelieferte Varianten wie "MASTERCARD" oder " Girocard" nicht am reinen
  // String-Vergleich scheitern und den Betrag stillschweigend verlieren.
  static final Map<String, String> _kartenartMapping = <String, String>{
    for (final String art in _kartenarten) art: art,
    ..._kartenartAliase,
  };

  /// Wirft, falls eine der zu sendenden TIDs nicht zu
  /// config/terminal_ids.json passt (siehe [_pruefeTerminalIds]) — bewusste
  /// Paco-Entscheidung (2026-09-01): die TID ist eindeutig, eine falsche
  /// Ziffer soll den Versand verhindern statt nur eine Warnung zu zeigen.
  /// Wirft VOR dem eigentlichen Netzwerk-Versand (_ensure()/_settlements()),
  /// damit bei einer ungueltigen TID gar nichts an Flurbocash geschickt
  /// wird. Aeltere Doku-Note (bis Run 413a2, jetzt ueberholt): die
  /// Referenzliste war laut TODO.md fuer manche Standorte noch nicht von
  /// Yannik bestaetigt — das Risiko einer falschen Referenzliste wird
  /// jetzt bewusst in Kauf genommen.
  ///
  /// Liefert beide Server-Antworten (ensure + settlements, seit Run 476
  /// fuer den Dev-Modus-Dialog).
  ///
  /// Korrektur-Regel (Run 477): Pro Kino und Abrechnungstag gibt es EINE
  /// Abrechnung bei Flurbocash. Die vom Server bestaetigte
  /// settlement_number wird nach dem Versand pro Kino + Tag gemerkt
  /// ([_tagesZuordnungKey]); jeder weitere Versand fuer denselben Tag —
  /// aus Schritt 3 oder "Erneut senden" im Verlauf — schickt sie mit,
  /// Flurbocash ueberschreibt dann statt eine neue Abrechnung anzulegen.
  /// Bewusst unabhaengig von Verlauf/Auto-Save (Run 476 hing daran und
  /// scheiterte an Testdaten-Eintraegen). Bar Tabak (2 Abrechnungen/Tag)
  /// muss beim spaeteren Umbau pro 1./2. Abrechnung getrennt gefuehrt
  /// werden.
  static Future<FlurbocashUploadErgebnis> upload(
    TagesabschlussFinal abrechnung,
  ) async {
    final ({String url, int locationId, String apiKey}) konfig =
        await _ladeKonfigWerte(abrechnung.kinoId);

    final List<String> warnungen = await _pruefeTerminalIds(abrechnung);
    if (warnungen.isNotEmpty) {
      throw Exception('TID-Pruefung fehlgeschlagen: ${warnungen.join(' ')}');
    }

    final Map<String, dynamic> ensureAntwort = await _ensure(
      konfig.url,
      konfig.apiKey,
      konfig.locationId,
      abrechnung,
    );
    final int reportId = (ensureAntwort['report_id'] as num).toInt();
    await _speichereReportId(abrechnung.kinoId, abrechnung.datum, reportId);

    // Gemerkte Abrechnung nur verwenden, wenn sie zum selben Tagesbericht
    // gehoert — sonst koennte eine fremde Abrechnung ueberschrieben werden
    // (z. B. Sandbox zurueckgesetzt, anderer Standort konfiguriert).
    final FlurbocashZuordnung? gemerkt =
        await ladeTagesZuordnung(abrechnung.kinoId, abrechnung.datum);
    final FlurbocashZuordnung? korrekturVon =
        gemerkt != null && gemerkt.reportId == reportId ? gemerkt : null;
    if (korrekturVon != null) {
      await SendeProtokoll.eintragen(
        'Korrektur: FC-Abrechnung Nr. ${korrekturVon.settlementNummer} '
        '(report_id $reportId) wird überschrieben',
      );
    }

    Map<String, dynamic> body =
        settlementsBody(abrechnung, korrekturVon: korrekturVon);
    Map<String, dynamic>? settlementsAntwort;
    bool warKorrektur = korrekturVon != null;
    try {
      settlementsAntwort =
          await _settlements(konfig.url, konfig.apiKey, reportId, body);
    } catch (e) {
      // Run 478: Die gemerkte Abrechnung gibt es bei FC nicht mehr (z. B.
      // in FC geloescht — moeglich ausser fuer Nr. 1). Ohne diesen
      // Fallback kaeme die MA fuer diesen Tag nicht mehr weiter. Dann wie
      // ein Erstversand ohne Nummer neu anlegen, die neue Nummer wird
      // unten gemerkt.
      if (korrekturVon == null || !istUnbekannteSettlementNummer(e)) rethrow;
      await SendeProtokoll.eintragen(
        'FC-Abrechnung Nr. ${korrekturVon.settlementNummer} existiert '
        'nicht mehr -> wird neu angelegt',
      );
      body = settlementsBody(abrechnung);
      warKorrektur = false;
      settlementsAntwort =
          await _settlements(konfig.url, konfig.apiKey, reportId, body);
    }

    final FlurbocashZuordnung? zuordnung = zuordnungAusAntwort(
      reportId: reportId,
      gesendeterBody: body,
      antwort: settlementsAntwort,
    );
    if (zuordnung != null) {
      // Eigener try/catch: der Versand war bereits erfolgreich, ein Fehler
      // beim lokalen Merken darf das nicht als Fehlschlag melden.
      try {
        await _speichereTagesZuordnung(
          abrechnung.kinoId,
          abrechnung.datum,
          zuordnung,
        );
        await SendeProtokoll.eintragen(
          'FC-Abrechnung Nr. ${zuordnung.settlementNummer} für '
          '${_datumKey(abrechnung.datum)} gemerkt',
        );
      } catch (e) {
        await SendeProtokoll.eintragen('FC-Abrechnung merken FEHLGESCHLAGEN: $e');
      }
    }

    return FlurbocashUploadErgebnis(
      ensureAntwort: ensureAntwort,
      settlementsAntwort: settlementsAntwort,
      warKorrektur: warKorrektur,
    );
  }

  /// Erkennt die FC-Ablehnung einer Korrektur, deren settlement_number
  /// es nicht (mehr) gibt: 400 "settlement N does not exist; omit
  /// settlement_number to create a new settlement"
  /// (EXTERNAL_API_Schauburg_de.md). Der Text steckt in der von
  /// [_pruefeStatus] geworfenen Exception.
  static bool istUnbekannteSettlementNummer(Object e) {
    final String text = e.toString().toLowerCase();
    return text.contains('settlement') && text.contains('does not exist');
  }

  static String _tagesZuordnungKey(String kinoId, DateTime datum) =>
      'flurbocash_settlement_${kinoId}_${_datumKey(datum)}';

  /// Die fuer Kino + Abrechnungstag gemerkte, von Flurbocash bestaetigte
  /// Abrechnung, oder null wenn fuer diesen Tag noch nie bestaetigt
  /// gesendet wurde. Auch fuer den Hinweis "wird ersetzt" im
  /// Bestaetigungsdialog vor dem Senden.
  static Future<FlurbocashZuordnung?> ladeTagesZuordnung(
    String kinoId,
    DateTime datum,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    final String? roh = speicher.getString(_tagesZuordnungKey(kinoId, datum));
    if (roh == null) return null;
    try {
      return FlurbocashZuordnung.fromJson(jsonDecode(roh));
    } catch (_) {
      return null;
    }
  }

  static Future<void> _speichereTagesZuordnung(
    String kinoId,
    DateTime datum,
    FlurbocashZuordnung zuordnung,
  ) async {
    final SharedPreferences speicher = await SharedPreferences.getInstance();
    await speicher.setString(
      _tagesZuordnungKey(kinoId, datum),
      jsonEncode(zuordnung.toJson()),
    );
  }

  /// Liest die vom Server vergebene settlement_number aus der
  /// settlements-Antwort (settlements[0].settlement_number, von Paco am
  /// 2026-09-24 in der Sandbox bestaetigt: enthaelt nur die gerade
  /// geschriebene Abrechnung). Fehlt sie dort, gilt die selbst
  /// mitgeschickte Nummer (Korrektur); gibt es keine von beiden: null.
  static FlurbocashZuordnung? zuordnungAusAntwort({
    required int reportId,
    required Map<String, dynamic> gesendeterBody,
    required Map<String, dynamic>? antwort,
  }) {
    int? nummer;
    final Object? settlements = antwort?['settlements'];
    if (settlements is List && settlements.isNotEmpty) {
      final Object? erstes = settlements.first;
      if (erstes is Map && erstes['settlement_number'] is num) {
        nummer = (erstes['settlement_number'] as num).toInt();
      }
    }
    final Map<String, dynamic> gesendet = (gesendeterBody['settlements']
        as List<dynamic>).first as Map<String, dynamic>;
    nummer ??= (gesendet['settlement_number'] as num?)?.toInt();
    if (nummer == null) return null;
    return FlurbocashZuordnung(
      reportId: reportId,
      settlementNummer: nummer,
      tids: tidsAusSettlementsBody(gesendeterBody).toSet().toList(),
    );
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
        speicher.getString(locationIdPrefKey(kinoId));
    final int locationId =
        (locationIdStr != null && locationIdStr.isNotEmpty)
            ? (int.tryParse(locationIdStr) ?? 0)
            : 0;

    final String? perKinoKey = speicher.getString(apiKeyPrefKey(kinoId));
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
  ///
  /// Korrektur (Run 477): Mit [korrekturVon] (die fuer diesen Tag
  /// gemerkte Abrechnung, siehe [upload]) wird deren settlement_number
  /// mitgeschickt — FC ueberschreibt dann diese Abrechnung statt eine
  /// neue anzulegen. Terminals, die beim letzten Versand dabei waren und
  /// jetzt fehlen (z. B. falsch gescannten Beleg geloescht), werden mit
  /// 0-Betraegen mitgeschickt: FC aktualisiert Terminals per Upsert,
  /// ein weggelassenes bliebe dort sonst mit den alten Betraegen stehen
  /// (EXTERNAL_API_Schauburg_de.md, "Korrekturen").
  static Map<String, dynamic> settlementsBody(
    TagesabschlussFinal abrechnung, {
    DateTime? jetzt,
    FlurbocashZuordnung? korrekturVon,
  }) {
    final List<Map<String, dynamic>> terminals = _terminalsListe(abrechnung);
    if (korrekturVon != null) {
      final Set<String> aktuelleTids = terminals
          .map((Map<String, dynamic> t) => t['tid'] as String)
          .toSet();
      for (final String tid in korrekturVon.tids) {
        if (!aktuelleTids.contains(tid)) {
          terminals.add(_terminalEintrag(tid, const <String, int>{}, null));
          aktuelleTids.add(tid);
        }
      }
    }
    return <String, dynamic>{
      'settlements': <Map<String, dynamic>>[
        <String, dynamic>{
          if (korrekturVon != null)
            'settlement_number': korrekturVon.settlementNummer,
          'cash_total': abrechnung.barBestandAbzglWechselgeldCent,
          if (abrechnung.anmerkung != null && abrechnung.anmerkung!.isNotEmpty)
            'note': abrechnung.anmerkung,
          // Yannik: unbekannte/nicht benötigte Felder werden serverseitig
          // ignoriert, kein Vertragsbruch falls FC "sent_at" (noch) nicht
          // auswertet.
          'sent_at': (jetzt ?? DateTime.now()).toIso8601String(),
          'terminals': terminals,
        },
      ],
    };
  }

  static Future<Map<String, dynamic>> _ensure(
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
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> _settlements(
    String baseUrl,
    String apiKey,
    int reportId,
    Map<String, dynamic> body,
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
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Keine Verbindung zur Flurbocash-API. ($e)');
    }
    _pruefeStatus(response);
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
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
      // Leerzeichen entfernen (Run 474): auch Alt-Daten/Verlauf-Einträge mit
      // einer per Hand getippten " 60561997" muessen beim Vergleich gegen
      // config/terminal_ids.json und bei Flurbocash als "60561997" ankommen.
      final String tid =
          TidEingabe.bereinige(z.tid ?? abrechnung.terminalId ?? '');
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
          _kartenarten.fold<int>(
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
        final String tid = TidEingabe.bereinige(tids[i]);
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
      for (final String art in _kartenarten) art: karten[art] ?? 0,
      if (foto != null) 'receipt_photo': foto.base64,
      if (foto != null) 'receipt_media_type': foto.mediaType,
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

  // Erkennt die generischen Browser-Fehlertexte ("Failed to fetch" u. Ä.),
  // die sowohl bei einem CORS-blockierten Request (POST kam beim Server
  // an, Antwort darf aber nicht gelesen werden) als auch bei völlig
  // fehlendem Netz (Flugmodus, WLAN weg, Server nicht erreichbar)
  // auftreten. Browser unterscheiden diese beiden Fälle absichtlich
  // nicht (Sicherheitsgrenze, sonst liesse sich per CORS-Fehler
  // Netzwerktopologie erschnüffeln) — von hier aus NICHT zuverlässig
  // feststellbar, ob der Request den Server tatsächlich erreicht hat.
  // Aufrufer dürfen aus true deshalb NICHT "wahrscheinlich doch
  // gesendet" folgern (das war der Bug hinter dem CHANGELOG-Eintrag
  // Run 448) — nur, dass der Ausgang unklar ist.
  static bool isCorsArtFehler(Object e) {
    final String text = e.toString().toLowerCase();
    return text.contains('failed to fetch') ||
        text.contains('networkerror') ||
        text.contains('load failed');
  }
}

/// Ergebnis eines erfolgreichen [ApiUploadService.upload] (seit Run 476).
class FlurbocashUploadErgebnis {
  const FlurbocashUploadErgebnis({
    this.ensureAntwort,
    this.settlementsAntwort,
    this.warKorrektur = false,
  });

  /// true, wenn eine bereits gesendete Abrechnung des Tages bei FC
  /// ueberschrieben wurde (Run 478) — steuert "Korrektur gesendet" statt
  /// "Abrechnung gesendet" in der Erfolgsmeldung.
  final bool warKorrektur;

  /// Geparste Antworten beider Aufrufe, nur fuer den Dev-Modus-Dialog
  /// "Server-Antwort anzeigen". settlementsAntwort ist null, falls die
  /// Antwort kein gueltiges JSON war.
  final Map<String, dynamic>? ensureAntwort;
  final Map<String, dynamic>? settlementsAntwort;
}
