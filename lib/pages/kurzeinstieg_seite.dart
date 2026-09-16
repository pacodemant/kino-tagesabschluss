import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';
import 'package:kino_bar_app/widgets/loeschen_dialog.dart';

/// Sprachen fürs Flaggen-Menü der Hilfe-Seite (Auswahl noch ohne
/// Funktion, siehe _zeigeSprachHinweis() — Übersetzung folgt später).
class _Sprache {
  const _Sprache(this.flagge, this.name);

  final String flagge;
  final String name;
}

const List<_Sprache> _verfuegbareSprachen = <_Sprache>[
  _Sprache('🇹🇷', 'Türkçe'),
  _Sprache('🇺🇦', 'Українська'),
  _Sprache('🇪🇸', 'Español'),
  _Sprache('🇮🇹', 'Italiano'),
  _Sprache('🇮🇳', 'हिन्दी'),
  _Sprache('🇬🇧', 'English'),
  _Sprache('🇫🇷', 'Français'),
];

/// Bebilderte Bedienungsanleitung hinter dem "Hilfe"-Button der Startseite.
/// Inhalt und Screenshots stammen aus der vom Kino erstellten Anleitung
/// "Kassenabrechnung mit der Kassen-App".
class KurzeinstiegSeite extends StatefulWidget {
  const KurzeinstiegSeite({super.key});

  static const String routenName = '/kurzeinstieg';

  static const TextStyle _absatzStil = TextStyle(fontSize: 15, height: 1.5);

  @override
  State<KurzeinstiegSeite> createState() => _KurzeinstiegSeiteState();
}

/// Index des aktuell aufgeklappten Abschnitts (0 = "Die App" bis
/// 6 = "Weitere Funktionen"); null = alle zu. Nur ein Abschnitt kann
/// gleichzeitig offen sein — das Öffnen eines anderen klappt den
/// vorherigen automatisch wieder zu.
class _KurzeinstiegSeiteState extends State<KurzeinstiegSeite> {
  static const List<String> _abschnittTitel = <String>[
    'Die App',
    '0. Start',
    'Schritt 1: Bargeld zählen',
    'Schritt 2: Umsätze ermitteln',
    'Schritt 3: Übertrag auf Umschlag',
    'Schritt 4: Stückelung des Bargeldes',
    'Weitere Funktionen',
  ];

  int? _offenerIndex;
  final List<GlobalKey> _abschnittKeys = List<GlobalKey>.generate(
    7,
    (_) => GlobalKey(),
  );
  final GlobalKey _scrollBereichKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  /// true, sobald der Titel der geöffneten Kachel beim Scrollen über den
  /// oberen Rand des sichtbaren Bereichs hinausgewandert wäre — dann zeigen
  /// wir stattdessen den fixierten Titel-Balken, damit immer erkennbar
  /// bleibt, zu welchem Abschnitt der gerade sichtbare Text gehört.
  bool _zeigeFixiertenTitel = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_beiScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_beiScroll)
      ..dispose();
    super.dispose();
  }

  void _beiScroll() {
    if (_offenerIndex == null) {
      if (_zeigeFixiertenTitel) {
        setState(() => _zeigeFixiertenTitel = false);
      }
      return;
    }
    final BuildContext? kopfContext =
        _abschnittKeys[_offenerIndex!].currentContext;
    final BuildContext? bereichContext = _scrollBereichKey.currentContext;
    if (kopfContext == null || bereichContext == null) {
      return;
    }
    final RenderBox kopfBox = kopfContext.findRenderObject()! as RenderBox;
    final RenderBox bereichBox =
        bereichContext.findRenderObject()! as RenderBox;
    final double kopfY = kopfBox.localToGlobal(Offset.zero).dy;
    final double bereichY = bereichBox.localToGlobal(Offset.zero).dy;
    final bool sollZeigen = kopfY < bereichY;
    if (sollZeigen != _zeigeFixiertenTitel) {
      setState(() => _zeigeFixiertenTitel = sollZeigen);
    }
  }

  void _zeigeSprachauswahl(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sprache wählen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            for (final _Sprache sprache in _verfuegbareSprachen)
              ListTile(
                leading: Text(
                  sprache.flagge,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(sprache.name),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _zeigeSprachHinweis(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _zeigeSprachHinweis(BuildContext context) {
    zeigeInfoDialog(
      context,
      titel: 'Bald verfügbar',
      inhalt: const Text(
        'Diese Sprache kommt in einer der nächsten Versionen der '
        'Hilfe. Aktuell ist die Hilfe nur auf Deutsch verfügbar.',
      ),
    );
  }

  void _umschalten(int index) {
    final bool wirdGeoeffnet = _offenerIndex != index;
    setState(() {
      _offenerIndex = wirdGeoeffnet ? index : null;
    });
    if (wirdGeoeffnet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final BuildContext? ctx = _abschnittKeys[index].currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: 0,
          );
        }
      });
    } else {
      setState(() => _zeigeFixiertenTitel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: const Text('Hilfe'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Sprache',
            onPressed: () => _zeigeSprachauswahl(context),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            key: _scrollBereichKey,
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _KlappAbschnitt(
                  key: _abschnittKeys[0],
                  titel: 'Die App',
                  offen: _offenerIndex == 0,
                  onToggle: () => _umschalten(0),
                  kinder: const <Widget>[
                    _Absatz(
                      'Die App soll euch die '
                      '**Kassenabrechnung einfacher, schneller und '
                      'fehlerresistenter** machen. Außerdem müssen '
                      'die Kartenzahlungsbelege künftig nicht mehr nur '
                      'als Gesamtbetrag, sondern **nach Kartenart '
                      'einzeln aufgeschlüsselt** an die Buchhaltung '
                      'gesendet werden. Das müsst ihr nicht händisch '
                      'machen: Ihr **fotografiert die '
                      'Kassenschnitt-Belege einfach**, die App liest '
                      'sie aus und rechnet alles für euch – das '
                      'erspart euch und der Buchhaltung eine Menge '
                      'unangenehmer Rechenarbeit.',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Die App ist für jedes Kino bzw. Bistro '
                      'individuell eingerichtet und größtenteils '
                      'selbsterklärend. Die Abrechnung ist in vier '
                      'Schritten eingeteilt – wenn ihr den Schritten '
                      'folgt, ist es schwer, etwas falsch zu machen. '
                      '(Aktuell ist die App noch in der Testphase.)',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Und falls doch mal etwas nicht klappen will: '
                      'Nichts geht dabei kaputt oder verloren, eure '
                      'Eingaben bleiben gespeichert. Meldet euch '
                      'einfach im Büro, gemeinsam lässt sich jedes '
                      'Problem lösen.',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _KlappAbschnitt(
                  key: _abschnittKeys[1],
                  titel: '0. Start',
                  offen: _offenerIndex == 1,
                  onToggle: () => _umschalten(1),
                  kinder: const <Widget>[
                    _Screenshot('assets/images/hilfe/start.png'),
                    SizedBox(height: 12),
                    _Absatz(
                      'Nach dem Öffnen der App seht ihr diesen Screen. Tippt auf '
                      '**Kassenabrechnung (4 Schritte)** und die App wird Euch '
                      'durch diese vier Schritte führen:',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      '**1.** Alles **Bargeld zählen** (Personalgetränke '
                      'bonieren, ggf. Produkte stunden, Kellnerportemonnaie '
                      'nicht vergessen)\n'
                      '**2.** **Umsätze eingeben** (Kino, Bistro, Ausgaben, '
                      'Kassenschnitte aller Terminals)\n'
                      '**3.** Die von der App errechneten Daten wie gewohnt '
                      'auf den Abrechnungs**umschlag** schreiben und alles '
                      'mit einem Tap **an die Buchhaltung senden** (der '
                      'Umschlag bleibt für die Abrechnung übrigens weiterhin '
                      'bestehen).\n'
                      '**4.** Tages-**Barumsatz stückeln**, und zwar so, '
                      'dass keine großen Scheine oder Kupfermünzen im '
                      'Wechselgeld für den nächsten Tag landen. Die '
                      'Stückelung schlägt die App vor, ihr müsst nicht mehr '
                      'rechnen und mit Geldscheinen jonglieren.',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _KlappAbschnitt(
                  key: _abschnittKeys[2],
                  titel: 'Schritt 1: Bargeld zählen',
                  offen: _offenerIndex == 2,
                  onToggle: () => _umschalten(2),
                  kinder: const <Widget>[
                    _Screenshot('assets/images/hilfe/schritt1_bargeld.png'),
                    SizedBox(height: 12),
                    _Absatz(
                      'Zuerst zählt ihr das Bargeld. Denkt an das '
                      '**Kellnerportemonnaie**, das Bonieren der '
                      '**Personalgetränke** und ein etwaiges **Stunden** von '
                      'Produkten sowie an eventuelle Umschläge mit losem '
                      'Kleingeld (unter Sonstiges).',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Für Scheine und Geldrollen tragt ihr nur die **Anzahl** '
                      'ein, die App errechnet die Summen. Für die losen Münzen '
                      'und etwaiges Geld in Umschlägen tragt Ihr die '
                      'tatsächlichen **Beträge** ein. Die Beträge gebt Ihr in '
                      '**Cent** ein, also ohne Komma, genau so, wie auch an den '
                      'Kartenzahlungsterminals: für 2,20 € tippt ihr „220" ein, '
                      'die App setzt das Komma automatisch.',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Eventuell vorhandene Umschläge mit losen Münzen und '
                      'evtl. anderem gebt ihr unter **Sonstiges** ein.',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      '**Kupfermünzen** kommen selten vor. Wenn das aber mal '
                      'der Fall ist, tippt an der entsprechenden Stelle auf '
                      '„Kupfermünzen hinzufügen" und tragt die Beträge ein. '
                      '(Das benötigt die App später für die Stückelung des '
                      'Bargelds für den Umschlag.)',
                    ),
                    SizedBox(height: 16),
                    _Screenshot(
                      'assets/images/hilfe/schritt1_kupfermuenzen.png',
                      breite: 260,
                    ),
                    SizedBox(height: 12),
                    _Absatz(
                      'Wenn Ihr alles gezählt habt, tippt ihr ganz unten auf '
                      'den orangenen Button „Umsätze eingeben" …',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _KlappAbschnitt(
                  key: _abschnittKeys[3],
                  titel: 'Schritt 2: Umsätze ermitteln',
                  offen: _offenerIndex == 3,
                  onToggle: () => _umschalten(3),
                  kinder: const <Widget>[
                    _Screenshot('assets/images/hilfe/schritt2_umsaetze.png'),
                    SizedBox(height: 12),
                    _Absatz(
                      'Im nächsten Schritt ermittelt Ihr wie bisher die '
                      '**Umsätze** für Kino und ggf. Bistro, etwaige '
                      '**Ausgaben** und die **Kassenschnitte** der '
                      'Kartenzahlungsterminals.',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Zunächst zieht ihr von allen Kartenterminals den '
                      'Kassenschnitt. Statt nun alle Beträge manuell '
                      'einzugeben, **fotografiert ihr die Belege einfach**, '
                      'die App liest die Daten und trägt sie automatisch ein.',
                    ),
                    SizedBox(height: 16),
                    _Screenshot(
                      'assets/images/hilfe/schritt2_ec_beleg.png',
                      breite: 280,
                    ),
                    SizedBox(height: 12),
                    _Absatz(
                      'Dazu legt ihr die Belege möglichst plan auf den Tisch, '
                      '**zieht sie, wenn nötig, glatt** und fotografiert '
                      'jeden Beleg einzeln. Achtet darauf, dass das Foto '
                      'scharf und deutlich ist und wenn das der Fall ist, '
                      'bestätigt das Foto. Die App arbeitet kurz und zeigt '
                      'dann an, was sie vom Beleg eingelesen hat.',
                    ),
                    SizedBox(height: 16),
                    _Screenshot(
                      'assets/images/hilfe/schritt2_scan_ergebnis.png',
                      breite: 220,
                    ),
                    SizedBox(height: 12),
                    _Absatz(
                      'Überprüft die Beträge und tippt dann auf „übernehmen". '
                      'Falls irgendetwas nicht stimmt, fotografiert den Beleg '
                      'einfach noch mal. **Wenn der Beleg zu uneben, gewellt '
                      'oder geknickt ist, werden einige Bereiche des Beleges '
                      'unscharf und ggf. nicht korrekt erkannt.**',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Für jeden weiteren Beleg tippt einfach auf '
                      '„Weiteren Beleg hinzufügen" usw. Schließlich tippt ihr '
                      'auf den orangefarbenen Button „Übertrag auf Umschlag".',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Wenn das Scannen mal nicht klappen will (z. B. '
                      'kein Internet), könnt ihr die Beträge auch '
                      'jederzeit manuell eingeben: Tippt dazu links '
                      'neben dem Foto-Button auf „manuell eingeben".',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _KlappAbschnitt(
                  key: _abschnittKeys[4],
                  titel: 'Schritt 3: Übertrag auf Umschlag',
                  offen: _offenerIndex == 4,
                  onToggle: () => _umschalten(4),
                  kinder: const <Widget>[
                    _Screenshot('assets/images/hilfe/schritt3_umschlag.png'),
                    SizedBox(height: 12),
                    _Absatz(
                      'Das Ausfüllen des Abrechnungsumschlages wird '
                      'weiterhin beibehalten. Diese Seite zeigt die von '
                      'der App errechneten Beträge an, die ihr einfach '
                      'auf den Umschlag eintragt.',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Wenn Ihr das getan habt, müsst ihr die Abrechnung '
                      '**ans Büro senden**. Dazu tippt ihr auf den '
                      'orangefarbenen Button. Erst, wenn Ihr die '
                      'Abrechnung gesendet habt, kommt Ihr weiter zum '
                      'nächsten Schritt, der Stückelung …',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _KlappAbschnitt(
                  key: _abschnittKeys[5],
                  titel: 'Schritt 4: Stückelung des Bargeldes',
                  offen: _offenerIndex == 5,
                  onToggle: () => _umschalten(5),
                  kinder: const <Widget>[
                    _Screenshot('assets/images/hilfe/schritt4_stueckelung.png'),
                    SizedBox(height: 12),
                    _Absatz(
                      'Zum Schluss legt Ihr den Barumsatz des Tages in den '
                      'Umschlag. Damit im Wechselgeld für den nächsten Tag '
                      'keine großen Scheine liegen, empfiehlt die App eine '
                      'entsprechende Stückelung. Wenn eine Zeile grün '
                      'hinterlegt ist, kann der komplette, kurz vorher '
                      'gezählte Stapel Scheine direkt in den Umschlag – ihr '
                      'müsst ihn nicht noch mal zählen.',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Jetzt noch Barumsatz und Belege in den Umschlag tun und '
                      '… fertig.',
                    ),
                    SizedBox(height: 10),
                    _Absatz(
                      'Wer sicher gehen will, prüft danach die '
                      'Wechselgeldkasse (Button „Wechselgeld prüfen" auf '
                      'der Startseite). Wenn die Wechselgeldkasse stimmt, '
                      'ist in der Regel auch die Abrechnung korrekt.',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _KlappAbschnitt(
                  key: _abschnittKeys[6],
                  titel: 'Weitere Funktionen',
                  offen: _offenerIndex == 6,
                  onToggle: () => _umschalten(6),
                  kinder: const <Widget>[
                    _Absatz(
                      'Die Funktionen unter dem orangefarbenen Button '
                      '„Kassenabrechnung" sind für die Konfiguration der App '
                      'bzw. Nice-to-haves und für den Hauptzweck Abrechnung '
                      'nicht wichtig:\n'
                      '• **Übertrag auf Umschlag**: wenn ihr die Daten für '
                      'den Umschlag noch mal prüfen wollt, ohne noch mal '
                      'durch die Abrechnung swipen zu müssen. Erst aktiv '
                      'nach einer abgeschlossenen Kassenabrechnung.\n'
                      '• **Wechselgeld prüfen**: Für die Frühschicht oder die '
                      'Überprüfung nach der Tagesabrechnung.\n'
                      '• **Getränke auffüllen**: nice-to-have, für jeden '
                      'Standort vorkonfiguriert – die Liste ist in der '
                      'Reihenfolge sortiert, wie die Getränke im Regal '
                      'stehen. Einfach ausprobieren oder wie gewohnt mit '
                      'Kellnerblock und Kuli …\n'
                      '• **Einstellungen**, **Verlauf** und **Hilfe** erklären '
                      'sich auch von selbst.',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (_zeigeFixiertenTitel && _offenerIndex != null)
            Positioned(
              top: 8,
              left: 20,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: _KachelKopf(
                  titel: _abschnittTitel[_offenerIndex!],
                  offen: true,
                  onToggle: () => _umschalten(_offenerIndex!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ein- und ausklappbarer Abschnitt der Hilfe-Seite: Kopfzeile im bisherigen
/// Design (fokusFarbe-Hintergrund) plus Chevron. Der Auf-/Zu-Zustand wird
/// vom Elternwidget (`_KurzeinstiegSeiteState`) gesteuert, damit stets nur
/// ein Abschnitt gleichzeitig offen sein kann.
class _KlappAbschnitt extends StatelessWidget {
  const _KlappAbschnitt({
    super.key,
    required this.titel,
    required this.kinder,
    required this.offen,
    required this.onToggle,
  });

  final String titel;
  final List<Widget> kinder;
  final bool offen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _KachelKopf(titel: titel, offen: offen, onToggle: onToggle),
        if (offen) ...<Widget>[const SizedBox(height: 12), ...kinder],
      ],
    );
  }
}

/// Kopfzeile einer Kachel (fokusFarbe-Hintergrund, Titel, Chevron).
/// Eigenständiges Widget, damit dieselbe Optik auch für den fixierten
/// Titel-Balken beim Scrollen wiederverwendet werden kann.
class _KachelKopf extends StatelessWidget {
  const _KachelKopf({
    required this.titel,
    required this.offen,
    required this.onToggle,
  });

  final String titel;
  final bool offen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppFarben.fokusFarbe,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                titel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              offen ? Icons.expand_less : Icons.expand_more,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}

class _Screenshot extends StatelessWidget {
  const _Screenshot(this.asset, {this.breite = 220});

  final String asset;
  final double breite;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(asset, width: breite, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// Absatz mit einfacher **Fett**-Auszeichnung (Markdown-Notation), damit die
/// Anleitungstexte oben lesbar bleiben statt aus einzelnen TextSpans
/// zusammengesetzt zu werden.
class _Absatz extends StatelessWidget {
  const _Absatz(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: KurzeinstiegSeite._absatzStil,
        children: _fettSpans(text),
      ),
    );
  }

  static List<InlineSpan> _fettSpans(String text) {
    final RegExp fettMuster = RegExp(r'\*\*(.+?)\*\*');
    final List<InlineSpan> spans = <InlineSpan>[];
    int position = 0;
    for (final RegExpMatch treffer in fettMuster.allMatches(text)) {
      if (treffer.start > position) {
        spans.add(TextSpan(text: text.substring(position, treffer.start)));
      }
      spans.add(
        TextSpan(
          text: treffer.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      position = treffer.end;
    }
    if (position < text.length) {
      spans.add(TextSpan(text: text.substring(position)));
    }
    return spans;
  }
}
