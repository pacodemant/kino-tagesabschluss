// Hilfsfunktionen für den E2E-Test: kleiner Webserver für build/web, Browser
// starten, Flutter-Web-Semantik ansteuern, prüfen und Screenshots ablegen.
//
// Hintergrund: Flutter Web (CanvasKit) zeichnet auf ein Canvas. Bedienbar wird
// die App erst über die "Semantik"-Ebene (versteckte DOM-Knoten <flt-semantics>
// mit Text und Rollen), die hier eingeschaltet wird.

const fs = require('fs');
const http = require('http');
const path = require('path');
const { chromium } = require('playwright');

const AUSGABE = path.join(__dirname, 'output');

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
};

/** Startet einen statischen Webserver für [wurzel] auf einem freien Port. */
function starteServer(wurzel) {
  return new Promise((resolve, reject) => {
    const server = http.createServer((anfrage, antwort) => {
      const pfad = decodeURIComponent(anfrage.url.split('?')[0]);
      let datei = path.join(wurzel, pfad === '/' ? 'index.html' : pfad);
      if (!datei.startsWith(wurzel) || !fs.existsSync(datei) || fs.statSync(datei).isDirectory()) {
        datei = path.join(wurzel, 'index.html');
      }
      antwort.writeHead(200, {
        'Content-Type': MIME[path.extname(datei)] || 'application/octet-stream',
        'Cache-Control': 'no-store',
      });
      fs.createReadStream(datei).pipe(antwort);
    });
    server.on('error', reject);
    server.listen(0, '127.0.0.1', () => resolve({ server, url: `http://127.0.0.1:${server.address().port}/` }));
  });
}

/** Startet den Browser in Handy-Größe. Standard: installiertes Google Chrome. */
async function starteBrowser(url, { sichtbar = false } = {}) {
  const optionen = { headless: !sichtbar };
  if ((process.env.E2E_BROWSER || 'chrome') !== 'chromium') {
    optionen.channel = 'chrome';
  }
  const browser = await chromium.launch(optionen);
  const ctx = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 });
  const page = await ctx.newPage();
  page.on('pageerror', (e) => console.log('   [Seitenfehler]', e.message));
  await page.goto(url);
  await page.waitForTimeout(5000);
  await schalteSemantikEin(page);
  return { browser, ctx, page };
}

async function schalteSemantikEin(page) {
  await page.evaluate(() => {
    const knopf = document.querySelector('flt-semantics-placeholder');
    if (knopf) knopf.click();
  });
  await page.waitForTimeout(1200);
}

/** Lädt die Seite neu (Speicher bleibt erhalten) und schaltet die Semantik wieder ein. */
async function ladeNeu(page) {
  await page.reload();
  await page.waitForTimeout(5000);
  await schalteSemantikEin(page);
}

function maskiere(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/** Klickt einen Knoten, dessen Text GENAU [text] ist (z. B. Buttons und Dialog-Buttons). */
async function klicke(page, text, { warte = 900 } = {}) {
  const genau = new RegExp(`^\\s*${maskiere(text)}\\s*$`);
  const ort = page
    .locator('flt-semantics', { hasText: genau })
    .filter({ hasNot: page.locator('flt-semantics') });
  if ((await ort.count()) === 0) {
    throw new Error(`Knopf nicht gefunden: "${text}"`);
  }
  await ort.first().click({ force: true });
  await page.waitForTimeout(warte);
}

/** Klickt einen Knoten, dessen Text/Beschriftung [text] ENTHÄLT (z. B. Zeilen mit Schalter). */
async function klickeEnthaelt(page, text, { warte = 900 } = {}) {
  const ort = page
    .locator('flt-semantics', { hasText: text })
    .or(page.locator(`flt-semantics[aria-label*="${text}"]`));
  if ((await ort.count()) === 0) {
    throw new Error(`Element nicht gefunden: "${text}"`);
  }
  await ort.first().click({ force: true });
  await page.waitForTimeout(warte);
}

/** Gesamter sichtbarer Text der Seite (Semantik-Knoten inkl. Beschriftungen). */
async function seitenText(page) {
  return page.evaluate(() =>
    Array.from(document.querySelectorAll('flt-semantics'))
      .map((n) => `${n.getAttribute('aria-label') || ''} ${n.textContent}`)
      .join(' ')
      .replace(/\s+/g, ' '),
  );
}

let bildNummer = 0;
async function foto(page, name) {
  fs.mkdirSync(AUSGABE, { recursive: true });
  const datei = path.join(AUSGABE, `${String(++bildNummer).padStart(2, '0')}_${name}.png`);
  await page.screenshot({ path: datei });
  return datei;
}

/** Prüft, dass ALLE [erwartet] und KEINES von [nichtErwartet] auf der Seite steht. */
async function pruefe(page, beschreibung, erwartet = [], nichtErwartet = []) {
  const text = await seitenText(page);
  const fehlt = erwartet.filter((t) => !text.includes(t));
  const zuviel = nichtErwartet.filter((t) => text.includes(t));
  if (fehlt.length === 0 && zuviel.length === 0) {
    console.log(`   OK   ${beschreibung}`);
    return;
  }
  const bild = await foto(page, `FEHLER_${beschreibung.replace(/\W+/g, '_').slice(0, 40)}`);
  const teile = [];
  if (fehlt.length) teile.push(`fehlt: ${fehlt.map((t) => `"${t}"`).join(', ')}`);
  if (zuviel.length) teile.push(`unerwartet: ${zuviel.map((t) => `"${t}"`).join(', ')}`);
  throw new Error(`${beschreibung} - ${teile.join('; ')} (Bild: ${bild})`);
}

/** Scrollt die Seite ganz nach unten (Mausrad in der Mitte des Bildschirms). */
async function scrolleNachUnten(page) {
  for (let i = 0; i < 14; i++) {
    await page.mouse.move(200, 400);
    await page.mouse.wheel(0, 800);
    await page.waitForTimeout(120);
  }
  await page.waitForTimeout(500);
}

/** Tippt [wert] ins fokussierte Feld und springt mit Enter zum nächsten. */
async function tippeWeiter(page, wert) {
  await page.keyboard.type(wert);
  await page.keyboard.press('Enter');
  await page.waitForTimeout(450);
}

module.exports = {
  starteServer, starteBrowser, ladeNeu, klicke, klickeEnthaelt, seitenText,
  foto, pruefe, scrolleNachUnten, tippeWeiter,
};
