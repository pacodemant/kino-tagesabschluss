import 'package:flutter/material.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

/// Bebilderte Bedienungsanleitung hinter dem "Hilfe"-Button der Startseite.
/// Inhalt und Screenshots stammen aus der vom Kino erstellten Anleitung
/// "Kassenabrechnung mit der Kassen-App".
class KurzeinstiegSeite extends StatefulWidget {
  const KurzeinstiegSeite({super.key});

  static const String routenName = '/kurzeinstieg';

  static const TextStyle _absatzStil = TextStyle(fontSize: 15, height: 1.5);
  static const TextStyle _fussnotenStil = TextStyle(
    fontSize: 13,
    height: 1.5,
    fontStyle: FontStyle.italic,
    color: AppFarben.subtilerText,
  );

  @override
  State<KurzeinstiegSeite> createState() => _KurzeinstiegSeiteState();
}

/// Index des aktuell aufgeklappten Abschnitts (0 = "Die App" bis
/// 6 = "Weitere Funktionen"); null = alle zu. Nur ein Abschnitt kann
/// gleichzeitig offen sein — das Öffnen eines anderen klappt den
/// vorherigen automatisch wieder zu.
class _KurzeinstiegSeiteState extends State<KurzeinstiegSeite> {
  int? _offenerIndex;
  final List<GlobalKey> _abschnittKeys =
      List<GlobalKey>.generate(7, (_) => GlobalKey());

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppFarben.appBarRot,
        foregroundColor: Colors.white,
        title: const Text('Hilfe'),
      ),
      body: SingleChildScrollView(
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
                  'Wenn Ihr alles gezählt habt, tippt ihr ganz unten auf '
                  'den orangenen Button „Umsätze eingeben" …',
                ),
                SizedBox(height: 16),
                _Screenshot(
                  'assets/images/hilfe/schritt1_kupfermuenzen.png',
                  breite: 260,
                ),
                SizedBox(height: 12),
                _Absatz(
                  '**Kupfermünzen** kommen selten vor. Wenn das aber mal '
                  'der Fall ist, tippt an der entsprechenden Stelle auf '
                  '„Kupfermünzen hinzufügen" und tragt die Beträge ein. '
                  '(Das benötigt die App später für die Stückelung des '
                  'Bargelds für den Umschlag.)',
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
                  'Dazu legt ihr den Beleg möglichst plan auf den Tisch, '
                  '**zieht den Beleg, wenn nötig, glatt** und fotografiert '
                  'ihn. Achtet darauf, dass das Foto scharf ist. Wenn das '
                  'Foto scharf und deutlich ist, bestätigt das Foto. Die '
                  'App arbeitet kurz und zeigt dann an, was sie vom Beleg '
                  'eingelesen hat.',
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
                  'Für weitere Kassenschnitt-Belege tippt einfach auf '
                  '„Weiteren Beleg hinzufügen" usw. Schließlich tippt ihr '
                  'auf den orangefarbenen Button „Übertrag auf Umschlag".',
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
                  'Das Ausfüllen des Abrechnungsumschlages wird weiterhin '
                  'beibehalten. Diese Seite zeigt an, was auf dem '
                  'Umschlag einzutragen ist.',
                ),
                SizedBox(height: 10),
                _Absatz(
                  'Wenn Ihr das getan habt, ist es wichtig, dass die '
                  'Abrechnung **ans Büro gesendet** wird: tippt auf den '
                  'orangefarbenen Button. Erst, wenn Ihr die Abrechnung '
                  'gesendet habt, kommt Ihr weiter zum nächsten Schritt, '
                  'der Stückelung …',
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
                  '• **Wechselgeld prüfen**: für die Frühschicht, erklärt '
                  'sich von selbst\n'
                  '• **Getränke auffüllen**: nice-to-have, für jeden '
                  'Standort vorkonfiguriert – die Liste ist in der '
                  'Reihenfolge sortiert, wie die Getränke im Regal '
                  'stehen. Einfach ausprobieren oder wie gewohnt mit '
                  'Kellnerblock und Kuli …\n'
                  '• **Einstellungen**, **Verlauf** und **Hilfe** erklären '
                  'sich auch von selbst.',
                  stil: KurzeinstiegSeite._fussnotenStil,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
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
        InkWell(
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
        ),
        if (offen) ...<Widget>[const SizedBox(height: 12), ...kinder],
      ],
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
  const _Absatz(this.text, {this.stil = KurzeinstiegSeite._absatzStil});

  final String text;
  final TextStyle stil;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(style: stil, children: _fettSpans(text)));
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
