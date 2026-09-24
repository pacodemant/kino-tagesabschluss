// Szenario: komplette Abrechnung (Schritt 1 bis 4) mit Wechselgeldentnahme,
// danach die Wechselgeldprüfung am selben Tag (Abend-Modus) und am nächsten
// Morgen (Morgen-Modus mit Schalter, inkl. Neuladen des Browsers).
//
// Testdaten (Standort Schauburg, Wechselgeld-Sollwert 1.400 € aus der
// Konfiguration; ändert sich der Sollwert, müssen die Zahlen hier angepasst
// werden):
//   Zählung 9×100 + 8×50 + 20×20 + 10×10        = 1.800 €
//   Wechselgeldentnahme                          =   600 €
//   Barumsatz (bereinigt) 1.800 + 600 − 1.400    = 1.000 €
//   Kino 900 + Bistro 400 = Soll 1.300 = EC 300 + bar 1.000
//   Stückelung Umschlag: 9×100 + 2×50; in der Kasse bleiben 800 €
//   (0×100, 6×50, 20×20, 10×10, 0×5)

const L = require('./lib');

// Klickpunkte für Textfelder (Flutter-Web bietet sie nicht als klickbare
// Knoten an). Gelten für das feste Fenster 390×844 aus lib.js. Stimmt ein
// Punkt nicht mehr (Layout geändert), schlägt die folgende Prüfung fehl.
const KLICK = {
  entnahmeBetrag: [290, 420],  // Schritt 1, ganz unten gescrollt, Schalter an
  entnahmeGrund: [195, 455],
  ecGesamt: [308, 705],        // Schritt 2, EC-Belege manuell, Feld "Gesamt"
  morgenBetrag: [290, 630],    // Prüfseite oben, Schalter "Notiz gefunden" an
};

async function oeffneWechselgeldPruefen(page) {
  try {
    await L.klicke(page, 'Schauburg (SB)');
  } catch (e) {
    // Kino ist nach dem Neuladen schon gewählt, Startmenü ist offen.
  }
  await L.klicke(page, 'Wechselgeld prüfen', { warte: 3000 });
}

async function zaehleWechselgeldkasse(page) {
  for (const anzahl of ['0', '6', '20', '10', '0']) {
    await L.tippeWeiter(page, anzahl);
  }
  await page.waitForTimeout(1200);
}

module.exports = async function szenario({ page, ctx }) {
  // ---- Schritt 1 -----------------------------------------------------------
  console.log('Schritt 1: Bargeld zählen, Wechselgeldentnahme');
  await L.klicke(page, 'Schauburg (SB)');
  await L.klicke(page, 'Kassenabrechnung (4 Schritte)');
  await L.pruefe(page, 'Schritt 1 ist offen', ['Bargeld zählen', 'Kupfermünzen (1, 2, 5 ct)']);
  for (const anzahl of ['9', '8', '20', '10', '0']) {
    await L.tippeWeiter(page, anzahl);
  }
  await page.keyboard.press('Escape');
  await L.scrolleNachUnten(page);
  await L.klickeEnthaelt(page, 'Wechselgeldentnahme');
  await L.scrolleNachUnten(page);
  await page.mouse.click(...KLICK.entnahmeBetrag);
  await page.waitForTimeout(500);
  await page.keyboard.type('60000');
  await page.keyboard.press('Enter');
  await page.waitForTimeout(500);
  await page.mouse.click(...KLICK.entnahmeGrund);
  await page.waitForTimeout(500);
  await page.keyboard.type('Rollengeld-Vorschuss');
  await page.keyboard.press('Enter');
  await page.keyboard.press('Escape');
  await L.scrolleNachUnten(page);
  await L.foto(page, 'schritt1_entnahme');
  await L.pruefe(
    page,
    'Schritt 1: Zusammenfassung rechnet die Wechselgeldentnahme ein',
    ['1.800,00 €', 'Wechselgeldentnahme', '+ 600,00 €', '− 1.400,00 €', '1.000,00 €',
      'Notiz mit Betrag und Grund nach der Abrechnung gut sichtbar in die Wechselgeldkasse legen'],
  );

  // ---- Schritt 2 -----------------------------------------------------------
  console.log('Schritt 2: Umsätze');
  await L.klicke(page, 'Umsätze eingeben (2/4)', { warte: 1500 });
  await L.klicke(page, 'Bestätigen', { warte: 2500 });   // Rückfrage "Eingaben unvollständig"
  await page.keyboard.type('90000');                     // Kino SOLL
  await page.keyboard.press('Enter');
  await page.waitForTimeout(500);
  await page.keyboard.type('40000');                     // Bistro SOLL
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);
  await L.klickeEnthaelt(page, 'Personalgetränke gebont?');
  await L.klicke(page, 'Übertrag auf Umschlag (3/4)', { warte: 1500 });
  await L.pruefe(page, 'Schritt 2: Terminal-ID ist Pflicht', ['Terminal-ID']);
  await L.klicke(page, 'Ändern', { warte: 1500 });       // EC-Belege manuell
  await L.tippeWeiter(page, '54017635');                 // Terminal-ID
  await L.tippeWeiter(page, '30000');                    // Girocard 300 €
  await page.mouse.click(...KLICK.ecGesamt);
  await page.waitForTimeout(400);
  await page.keyboard.type('30000');                     // Gesamt 300 €
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);

  // ---- Schritt 3 -----------------------------------------------------------
  console.log('Schritt 3: Übertrag auf Umschlag');
  await L.klicke(page, 'Übertrag auf Umschlag (3/4)', { warte: 2500 });
  await L.foto(page, 'schritt3');
  await L.pruefe(
    page,
    'Schritt 3: bar IST enthält die Wechselgeldentnahme, Differenz 0',
    ['Gesamt Soll', '1.300,00 €', 'bar IST', '1.000,00 €', 'Gesamt IST', 'Differenz Kassenabrechnung', '0,00 €'],
  );
  await L.klicke(page, 'Abrechnung an Büro senden', { warte: 2000 });
  await L.pruefe(page, 'Schritt 3: Senden-Rückfrage', ['Abrechnung senden?', 'Gesamt SOLL', '1.300,00 €']);
  await L.klicke(page, 'Senden', { warte: 4500 });
  await L.pruefe(page, 'Schritt 3: nach dem Senden erscheint die Auswahl', [
    'Was möchtest du als nächstes tun?', 'Wechselgeldkasse prüfen', 'Barumsatz f. Umschlag stückeln',
  ]);

  // ---- Schritt 4 -----------------------------------------------------------
  console.log('Schritt 4: Stückelung');
  await L.klicke(page, 'Barumsatz f. Umschlag stückeln', { warte: 2500 });
  await L.foto(page, 'schritt4');
  await L.pruefe(page, 'Schritt 4: Stückelung teilt 1.000 € Barumsatz auf', [
    'Bareinnahmen Stückelung: 1.000,00 €',
  ]);
  await L.klicke(page, '… fertig.', { warte: 2500 });
  await L.pruefe(page, 'Startmenü nach der Abrechnung', ['Kassenabrechnung (4 Schritte)', 'Wechselgeld prüfen']);

  // ---- Wechselgeldprüfung am selben Tag (Abend-Modus) ---------------------
  console.log('Wechselgeldprüfung nach der Abrechnung (Abend)');
  await oeffneWechselgeldPruefen(page);
  await L.foto(page, 'pruefung_abend');
  await L.pruefe(
    page,
    'Abend: Infokasten und Zeile zeigen die Wechselgeldentnahme',
    ['Die Wechselgeldentnahme (600,00 €) wird berücksichtigt', 'nur noch 800,00 €',
      'weil die Entnahme morgen wieder zurückgelegt wird', 'Wechselgeldentnahme (Rollengeld-Vorschuss)'],
    ['Notiz über Wechselgeldentnahme gefunden'],
  );
  await zaehleWechselgeldkasse(page);
  await L.pruefe(page, 'Abend: 800 € gezählt ergeben "Wechselgeld stimmt!"', ['Wechselgeld stimmt!']);
  await L.klicke(page, 'Fertig / Startseite', { warte: 2000 });

  // ---- Nächster Morgen (Morgen-Modus) -------------------------------------
  console.log('Wechselgeldprüfung am nächsten Morgen');
  const morgen = new Date();
  morgen.setDate(morgen.getDate() + 1);
  morgen.setHours(10, 0, 0, 0);
  await ctx.clock.install({ time: morgen });   // Browser-Uhr auf morgen 10 Uhr, Speicher bleibt
  await L.ladeNeu(page);
  await ctx.clock.resume();
  await oeffneWechselgeldPruefen(page);
  await L.pruefe(
    page,
    'Morgen: Schalter statt Automatik, voller Sollwert',
    ['Notiz über Wechselgeldentnahme gefunden', '1.400,00 €'],
    ['wird berücksichtigt', 'Wechselgeldentnahme (Rollengeld-Vorschuss)'],
  );
  await zaehleWechselgeldkasse(page);
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);
  await L.pruefe(page, 'Morgen: ohne Notiz-Schalter fehlen 600 €', ['-600,00 €']);
  await L.klickeEnthaelt(page, 'Notiz über Wechselgeldentnahme gefunden');
  await page.mouse.click(...KLICK.morgenBetrag);
  await page.waitForTimeout(400);
  await page.keyboard.type('60000');
  await page.keyboard.press('Enter');
  await page.waitForTimeout(1500);
  await L.pruefe(page, 'Morgen: Notiz-Schalter + 600 € ergeben "Wechselgeld stimmt!"', ['Wechselgeld stimmt!']);

  // ---- Neuladen: Schalter, Betrag und Zählung bleiben erhalten ------------
  console.log('Neuladen (echter Browser-Speicher)');
  await L.ladeNeu(page);
  await oeffneWechselgeldPruefen(page);
  await L.foto(page, 'pruefung_morgen_nach_neuladen');
  // Der Dialog "Wechselgeld stimmt!" erscheint nur, wenn Schalter, Betrag und
  // Zählung wiederhergestellt sind (sonst fehlten 600 €). Er verdeckt die
  // Seite dahinter, deshalb erst schließen und dann den Infokasten prüfen.
  await L.pruefe(page, 'Nach Neuladen: Zählung, Schalter und Betrag sind wieder da', ['Wechselgeld stimmt!']);
  await L.klicke(page, 'Weiter zählen', { warte: 1200 });
  await L.pruefe(page, 'Nach Neuladen: Notiz-Schalter und Infokasten', [
    'Notiz über Wechselgeldentnahme gefunden', 'Bis sie zurückgelegt ist, müssen nur noch 800,00 €',
  ]);
};
