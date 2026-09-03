import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kino_bar_app/domain/tagesabschluss_berechnung.dart';
import 'package:kino_bar_app/domain/usecases/stueckelung_konfiguration.dart';
import 'package:kino_bar_app/models/kassenzeile.dart';
import 'package:kino_bar_app/models/kino.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/models/tagesabschluss_final.dart';
import 'package:kino_bar_app/services/admin_session.dart';
import 'package:kino_bar_app/services/api_upload_service.dart';
import 'package:kino_bar_app/storage/lokaler_speicher.dart';
import 'package:kino_bar_app/utils/datums_helper.dart';
import 'package:kino_bar_app/widgets/heute_badge.dart';
import 'package:kino_bar_app/widgets/hinweis_snackbar.dart';
import 'package:kino_bar_app/widgets/info_zeile.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';
import 'package:kino_bar_app/widgets/nicht_gesendet_badge.dart';
import 'package:kino_bar_app/widgets/tagesabschluss_scaffold.dart';

class VerlaufDetailSeite extends StatefulWidget {
  const VerlaufDetailSeite({super.key, required this.abschluss});

  static const String routenName = '/verlauf-detail';

  final TagesabschlussFinal abschluss;

  @override
  State<VerlaufDetailSeite> createState() => _VerlaufDetailSeiteState();
}

class _VerlaufDetailSeiteState extends State<VerlaufDetailSeite> {
  bool _loescht = false;
  bool _sendet = false;
  late DateTime? _gesendetAm = widget.abschluss.gesendetAm;

  // Lookup-Maps aus StueckelungKonfiguration, einmalig gebaut
  static final Map<String, Kassenzeile> _scheineLookup = <String, Kassenzeile>{
    for (final Kassenzeile z in StueckelungKonfiguration.scheine) z.id: z,
  };
  static final Map<String, Kassenzeile> _rollenLookup = <String, Kassenzeile>{
    for (final Kassenzeile z in StueckelungKonfiguration.rollen) z.id: z,
  };

  String _euro(int cent) => TagesabschlussFormatierung.formatiereEuro(cent);
  String _euroMitVorzeichen(int cent) =>
      TagesabschlussFormatierung.formatiereEuroMitVorzeichen(cent);
  String _deutschesDatum(DateTime datum) =>
      TagesabschlussFormatierung.deutschesDatum(datum);

  Future<void> _erneuthSenden() async {
    if (_sendet) return;
    setState(() => _sendet = true);

    try {
      await ApiUploadService.upload(widget.abschluss); // .serverAntwort hier ungenutzt
      await LokalerSpeicher.markiereAlsGesendet(
        widget.abschluss.kinoId,
        widget.abschluss.createdAt,
        DateTime.now(),
      );

      if (mounted) {
        setState(() => _gesendetAm = DateTime.now());
        zeigeHinweisSnackBar(context, 'API Upload erfolgreich ✓');
      }
    } catch (e) {
      if (ApiUploadService.isCorsArtFehler(e)) {
        await LokalerSpeicher.markiereAlsGesendet(
          widget.abschluss.kinoId,
          widget.abschluss.createdAt,
          DateTime.now(),
        );
        if (mounted) {
          setState(() => _gesendetAm = DateTime.now());
          zeigeHinweisSnackBar(
            context,
            'Upload gesendet — Empfang nicht bestätigbar',
          );
        }
      } else {
        if (mounted) {
          final String fehler = e.toString();
          final String anzeige =
              fehler.length > 120 ? '${fehler.substring(0, 120)}…' : fehler;
          zeigeHinweisSnackBar(
            context,
            'API Upload fehlgeschlagen\n$anzeige',
            duration: const Duration(seconds: 8),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _sendet = false);
      }
    }
  }

  Future<void> _loescheEintrag() async {
    if (_loescht) {
      return;
    }

    final NavigatorState navigator = Navigator.of(context);

    final bool? bestaetigt = await zeigeLoeschenDialog(context);

    if (bestaetigt != true || !mounted) {
      return;
    }

    setState(() {
      _loescht = true;
    });

    await LokalerSpeicher.loescheFinalenTagesabschluss(
      widget.abschluss.kinoId,
      widget.abschluss.datum,
    );

    if (!mounted) {
      return;
    }
    navigator.pop(true);
  }

  // Eingerückte Unterzeile ohne Trennlinie
  Widget _unterzeile(String label, String wert) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Text(
            wert,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  List<Widget> _scheinUnterzeilen(TagesabschlussFinal a) {
    final Map<String, int>? sz = a.scheineStueckzahlen;
    if (sz == null || sz.isEmpty) {
      return <Widget>[];
    }
    final List<MapEntry<String, int>> eintraege = sz.entries.toList()
      ..sort(
        (MapEntry<String, int> x, MapEntry<String, int> y) =>
            (_scheineLookup[y.key]?.einzelwertCent ?? 0).compareTo(
              _scheineLookup[x.key]?.einzelwertCent ?? 0,
            ),
      );
    return eintraege.map((MapEntry<String, int> e) {
      final Kassenzeile? zeile = _scheineLookup[e.key];
      if (zeile == null) {
        return const SizedBox.shrink();
      }
      return _unterzeile(
        '${zeile.bezeichnung}  ×  ${e.value}',
        _euro(zeile.einzelwertCent * e.value),
      );
    }).toList();
  }

  List<Widget> _rollenUnterzeilen(TagesabschlussFinal a) {
    final Map<String, int>? sz = a.rollenStueckzahlen;
    if (sz == null || sz.isEmpty) {
      return <Widget>[];
    }
    final List<MapEntry<String, int>> eintraege = sz.entries.toList()
      ..sort(
        (MapEntry<String, int> x, MapEntry<String, int> y) =>
            (_rollenLookup[y.key]?.einzelwertCent ?? 0).compareTo(
              _rollenLookup[x.key]?.einzelwertCent ?? 0,
            ),
      );
    return eintraege.map((MapEntry<String, int> e) {
      final Kassenzeile? zeile = _rollenLookup[e.key];
      if (zeile == null) {
        return const SizedBox.shrink();
      }
      // Bezeichnung kürzen: "2 € (50,00 €)" → "2 €"
      final String kurzLabel = zeile.bezeichnung.split(' (').first;
      return _unterzeile(
        '$kurzLabel  ×  ${e.value}',
        _euro(zeile.einzelwertCent * e.value),
      );
    }).toList();
  }

  List<Widget> _loseMuenzenUnterzeilen(TagesabschlussFinal a) {
    final List<Widget> result = <Widget>[];
    if (a.silberMuenzenCent != null) {
      result.add(_unterzeile('Silber', _euro(a.silberMuenzenCent!)));
    }
    if (a.kupferMuenzenCent != null) {
      result.add(_unterzeile('Kupfer', _euro(a.kupferMuenzenCent!)));
    }
    return result;
  }

  List<Widget> _umschlagUnterzeilen(TagesabschlussFinal a) {
    final List<int>? betraege = a.umschlagBetraegeCent;
    if (betraege != null && betraege.isNotEmpty) {
      return betraege.map((int c) => _unterzeile('', _euro(c))).toList();
    }
    if (a.umschlaegeCent > 0) {
      return <Widget>[_unterzeile('Gesamt', _euro(a.umschlaegeCent))];
    }
    return <Widget>[];
  }

  List<Widget> _ecBelegUnterzeilen(TagesabschlussFinal a) {
    final List<int> betraege = a.ecBelegeCent;
    if (betraege.length <= 1) {
      return <Widget>[];
    }
    return List<Widget>.generate(betraege.length, (int i) {
      final String label =
          a.ecBelegeLabels != null && i < a.ecBelegeLabels!.length && a.ecBelegeLabels![i].isNotEmpty
              ? a.ecBelegeLabels![i]
              : 'Beleg ${i + 1}';
      return _unterzeile(label, _euro(betraege[i]));
    });
  }

  /// Beleg-Foto-Miniaturen (falls beim Beleg-Scan vorhanden) — antippbar
  /// für die Vollbild-Ansicht. Unabhängig von der Beleg-Anzahl, im
  /// Gegensatz zu [_ecBelegUnterzeilen] (die nur ab 2 Belegen greift).
  Widget _belegFotoZeilen(TagesabschlussFinal a) {
    final List<String>? fotos = a.ecBelegeFotosBase64;
    if (fotos == null || fotos.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<String>? mediaTypen = a.ecBelegeFotosMediaTypen;
    final List<Widget> thumbnails = <Widget>[];
    for (int i = 0; i < fotos.length; i++) {
      if (fotos[i].isEmpty) continue;
      final String mediaType =
          (mediaTypen != null && i < mediaTypen.length && mediaTypen[i].isNotEmpty)
              ? mediaTypen[i]
              : 'image/jpeg';
      final String label =
          a.ecBelegeLabels != null &&
                  i < a.ecBelegeLabels!.length &&
                  a.ecBelegeLabels![i].isNotEmpty
              ? a.ecBelegeLabels![i]
              : 'Beleg ${i + 1}';
      thumbnails.add(_belegFotoThumbnail(fotos[i], mediaType, label));
    }
    if (thumbnails.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Wrap(spacing: 8, runSpacing: 8, children: thumbnails),
    );
  }

  Widget _belegFotoThumbnail(String base64Foto, String mediaType, String label) {
    final Uint8List bytes = base64Decode(base64Foto);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _zeigeBelegFotoVollbild(bytes, label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _zeigeBelegFotoVollbild(Uint8List bytes, String titel) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(titel),
          ),
          body: Center(
            child: InteractiveViewer(
              maxScale: 5,
              child: Image.memory(bytes),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _ausgabenUnterzeilen(TagesabschlussFinal a) {
    final List<int>? betraege = a.ausgabenBetraegeCent;
    if (betraege != null && betraege.isNotEmpty) {
      return List<Widget>.generate(betraege.length, (int i) {
        final String label =
            a.ausgabenLabels != null && i < a.ausgabenLabels!.length
                ? a.ausgabenLabels![i]
                : 'Ausgabe ${i + 1}';
        return _unterzeile(label, _euro(betraege[i]));
      });
    }
    if (a.ausgabenCent > 0) {
      return <Widget>[_unterzeile('Gesamt', _euro(a.ausgabenCent))];
    }
    return <Widget>[];
  }

  @override
  Widget build(BuildContext context) {
    final TagesabschlussFinal a = widget.abschluss;
    final Color differenzFarbe =
        a.differenzGesamtCent >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    final String isoDatum = DatumsHelper.isoDatum(a.datum);
    final bool istHeute = isoDatum == DatumsHelper.logischesIsoDatum();
    final String kuerzel = KinoRepository.nachId(a.kinoId)?.kuerzel ?? a.kinoName;

    return TagesabschlussScaffold(
      backgroundColor: AppFarben.seitenHintergrund,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Abrechnungs-Verlauf $kuerzel',
                style: const TextStyle(fontSize: 14),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      _deutschesDatum(a.datum),
                      style: const TextStyle(fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (istHeute) ...<Widget>[
                    const SizedBox(width: 8),
                    const HeuteBadge(),
                  ],
                  if (_gesendetAm == null) ...<Widget>[
                    const SizedBox(width: 8),
                    const NichtGesendetBadge(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: <Widget>[
                if (a.mitarbeiterName != null &&
                    a.mitarbeiterName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: Text(
                      a.mitarbeiterName!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                if (a.anmerkung != null && a.anmerkung!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                    child: Text(
                      'Hinweis: ${a.anmerkung!}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                // Hinweis-Card – nur für vergangene Einträge
                if (!istHeute)
                  Card(
                    color: Colors.black,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Text(
                        'Diese Abrechnung kann nicht mehr geändert werden.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),

                // Abschnitt 1 – Geldzählung
                Card(
                  child: ExpansionTile(
                    title: const Text(
                      'Bargeld',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_euro(a.barBestandAbzglWechselgeldCent)),
                    initiallyExpanded: false,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: <Widget>[
                      InfoZeile(label: 'Scheine', wert: _euro(a.scheineCent)),
                      ..._scheinUnterzeilen(a),
                      InfoZeile(label: 'Münzrollen', wert: _euro(a.rollenCent)),
                      ..._rollenUnterzeilen(a),
                      InfoZeile(label: 'Lose Münzen', wert: _euro(a.loseMuenzenCent)),
                      ..._loseMuenzenUnterzeilen(a),
                      InfoZeile(label: 'Umschläge', wert: _euro(a.umschlaegeCent)),
                      ..._umschlagUnterzeilen(a),
                      InfoZeile(
                        label: 'Kassenbestand gesamt',
                        wert: _euro(a.kassenbestandGesamtCent),
                        fett: true,
                      ),
                      InfoZeile(
                        label: 'Wechselgeld',
                        wert: '− ${_euro(a.wechselgeldSollwertCent)}',
                      ),
                      InfoZeile(
                        label: 'Bar-Bestand bereinigt',
                        wert: _euro(a.barBestandAbzglWechselgeldCent),
                        fett: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Abschnitt 2 – Einnahmen
                Card(
                  child: ExpansionTile(
                    title: const Text(
                      'Umsätze',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_euro(a.gesamtIstCent)),
                    initiallyExpanded: false,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: <Widget>[
                      InfoZeile(label: 'Kino SOLL', wert: _euro(a.kinoSollCent)),
                      if (KinoRepository.nachId(a.kinoId)?.hatBistro ?? true)
                        InfoZeile(label: 'Bistro SOLL', wert: _euro(a.bistroSollCent)),
                      InfoZeile(label: 'Ausgaben', wert: _euro(a.ausgabenCent)),
                      ..._ausgabenUnterzeilen(a),
                      InfoZeile(label: 'EC-Umsatz gesamt', wert: _euro(a.ecUmsatzGesamtCent)),
                      ..._ecBelegUnterzeilen(a),
                      _belegFotoZeilen(a),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Abschnitt 3 – Ergebnis
                Card(
                  child: ExpansionTile(
                    title: const Text(
                      'Ergebnis',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _euroMitVorzeichen(a.differenzGesamtCent),
                      style: TextStyle(
                        color: a.differenzGesamtCent > 0
                            ? Colors.green.shade700
                            : a.differenzGesamtCent < 0
                                ? Colors.red.shade700
                                : Colors.black87,
                      ),
                    ),
                    initiallyExpanded: true,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: <Widget>[
                      InfoZeile(
                        label: 'Gesamt SOLL',
                        wert: _euro(a.gesamtSollCent),
                        fett: true,
                      ),
                      InfoZeile(
                        label: 'Gesamt IST',
                        wert: _euro(a.gesamtIstCent),
                        fett: true,
                      ),
                      InfoZeile(
                        label: 'Differenz Kassenabrechnung',
                        wert: _euroMitVorzeichen(a.differenzGesamtCent),
                        fett: true,
                        farbe: differenzFarbe,
                      ),
                      InfoZeile(
                        label: 'Differenz Anfangsbestand',
                        wert: _euro(a.differenzAnfangsbestandCent),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendet ? null : _erneuthSenden,
                    child: _sendet
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Wird gesendet...'),
                            ],
                          )
                        : Text(
                            _gesendetAm == null
                                ? 'Jetzt senden'
                                : 'Erneut senden',
                          ),
                  ),
                ),
                if (AdminSession.entsperrt) ...<Widget>[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _loescht ? null : _loescheEintrag,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      child: Text(
                        _loescht ? 'Wird gelöscht...' : 'Eintrag löschen',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
