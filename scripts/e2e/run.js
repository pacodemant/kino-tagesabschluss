// Startet die gebaute Web-App (build/web) in Chrome und spielt die Szenarien
// durch. Aufruf: siehe README.md.

const fs = require('fs');
const path = require('path');
const L = require('./lib');

const buildOrdner = path.resolve(
  process.argv.find((a) => a.startsWith('--build='))?.split('=')[1] || path.join(__dirname, '..', '..', 'build', 'web'),
);
const sichtbar = process.argv.includes('--sichtbar');

const SZENARIEN = [
  { name: 'Abrechnung mit Wechselgeldentnahme und Wechselgeldprüfung', datei: './szenario_wechselgeldentnahme' },
];

(async () => {
  if (!fs.existsSync(path.join(buildOrdner, 'index.html'))) {
    console.error(`Kein Web-Build gefunden: ${buildOrdner}\nErst bauen:  flutter build web --release`);
    process.exit(2);
  }
  fs.rmSync(path.join(__dirname, 'output'), { recursive: true, force: true });
  const { server, url } = await L.starteServer(buildOrdner);
  const start = Date.now();
  let fehler = null;
  let umgebung = null;
  try {
    for (const szenario of SZENARIEN) {
      console.log(`\n=== ${szenario.name} ===`);
      umgebung = await L.starteBrowser(url, { sichtbar });
      await require(szenario.datei)(umgebung);
      await umgebung.browser.close();
      umgebung = null;
    }
  } catch (e) {
    fehler = e;
    if (umgebung) {
      try {
        await L.foto(umgebung.page, 'FEHLERSTAND');
      } catch (_) { /* egal */ }
      await umgebung.browser.close();
    }
  }
  server.close();
  const sekunden = Math.round((Date.now() - start) / 1000);
  if (fehler) {
    console.error(`\nFEHLGESCHLAGEN nach ${sekunden}s: ${fehler.message}`);
    console.error(`Screenshots: ${path.join(__dirname, 'output')}`);
    process.exit(1);
  }
  console.log(`\nAlle Prüfungen bestanden (${sekunden}s). Screenshots: ${path.join(__dirname, 'output')}`);
})();
