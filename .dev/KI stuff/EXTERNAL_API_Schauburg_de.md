# Flurbocash External API

## Konventionen

- **Basis-URL:** `https://<your-host>` (Standardport `8080`).
- **Content-Type:** `application/json` für alle Anfrage- und Antwortkörper.
- **Geldbeträge immer als Integer-Cents.** Jeder Geldbetrag in Anfragen und Antworten ist eine ganze Zahl in Cent, z. B. bedeutet `123456` den Betrag `1234,56 EUR`. Niemals Dezimalzahlen oder Floats senden.
- **Datumsformat:** `YYYY-MM-DD` (z. B. `2026-06-10`).

## Authentifizierung

Alle externen Endpunkte sind per **API-Key** gesichert, der im Header `X-API-Key` übermittelt wird:

```
X-API-Key: fck_2a843e19...
```

Jeder API-Key ist **einem oder mehreren Standorten zugeordnet**. Ein Key darf nur Daten der ihm zugewiesenen Standorte lesen/schreiben. Anfragen für andere Standorte werden mit `403 Forbidden` abgelehnt.


## Typischer Ablauf

1. **Sicherstellen, dass ein Tagesbericht existiert** für Standort und Datum, und dessen `report_id` abrufen → `POST /api/daily-reports/ensure`.
2. **Abrechnungen einreichen** (Kassengesamtbeträge + Terminal-Abschlüsse) für diese `report_id` → `PUT /api/daily-reports/{id}/settlements`.

Externe Daten treffen oft ein, bevor Flurbocashs eigene Import-Mechanismen den Bericht angelegt haben; Schritt 1 erstellt ihn bei Bedarf.

---

## `POST /api/daily-reports/ensure`

Gibt die ID des Tagesberichts für einen Standort und ein Datum zurück und **erstellt den Bericht, falls er noch nicht existiert**. Idempotent: Ein erneuter Aufruf für denselben Standort und dasselbe Datum liefert dieselbe `report_id`.

**Anfrage**

```json
{
  "location_id": 9,
  "date": "2026-06-10"
}
```

**Antwort** `200 OK`

```json
{
  "report_id": 3044,
  "location_id": 9,
  "report_date": "2026-06-10",
  "finalized": false
}
```

Ist `finalized` gleich `true`, wurde der Bericht abgeschlossen und kann keine weiteren Abrechnungen mehr annehmen (siehe Fehlertabelle unten).

---

## `PUT /api/daily-reports/{id}/settlements`

Übermittelt die Kassengesamtbeträge und die Terminal-Einzelabrechnungen für einen Tagesbericht. `{id}` ist die `report_id` aus dem Ensure-Aufruf.

Eine **Abrechnung (Settlement)** ist eine Kassenabrechnung innerhalb des Tages. Jede Abrechnung enthält einen Kassengesamtbetrag sowie die Kartenumsätze jedes in ihr abgerechneten Terminals. Terminals werden über ihre **TID** (Terminal-ID des Zahlungsanbieters) identifiziert und müssen für den Standort des Berichts bereits registriert sein.

`settlement_number` ist **optional** und steuert, ob eine neue Abrechnung angelegt oder eine bestehende überschrieben wird:

- **Weglassen** → **neue Abrechnung hinzufügen**. Der Server vergibt die nächste freie Nummer für den Tag (erste wird 1, dann 2, …). Pro Tag sind maximal **4** Abrechnungen erlaubt; eine Anfrage, die diese Grenze überschreiten würde, wird mit `400` abgelehnt ohne etwas zu schreiben.
- **Wert `1`–`4` setzen** → **diese bestehende Abrechnung überschreiben** (Korrektur). Die Zielabrechnung muss bereits existieren — eine Nummer anzugeben, die noch nicht existiert, wird mit `400` abgelehnt (`settlement N does not exist; omit settlement_number to create a new settlement`). Erst per Weglassen anlegen, dann per Nummer korrigieren.

Siehe [Korrekturen](#korrekturen) unten.

**Anfrage**

```json
{
  "settlements": [
    {
      "cash_total": 123456,
      "terminals": [
        {
          "tid": "TID-ALPHA",
          "girocard": 10000,
          "lastschrift": 0,
          "mastercard": 5000,
          "visa": 0,
          "maestro": 0,
          "vpay": 0
        }
      ]
    }
  ]
}
```

Feldreferenz (alle Beträge in Cent):

| Feld                      | Typ    | Hinweise                                                              |
|---------------------------|--------|-----------------------------------------------------------------------|
| `settlement_number`       | int    | Optional. Weglassen = neue Abrechnung; `1`–`4` = diese überschreiben |
| `cash_total`              | int    | Gezählter Kassenbestand dieser Abrechnung                             |
| `terminals[].tid`         | string | Terminal-ID, muss für den Standort registriert sein                   |
| `terminals[].girocard`    | int    | EC-Karte: Girocard                                                    |
| `terminals[].lastschrift` | int    | EC-Karte: Lastschrift                                                 |
| `terminals[].mastercard`  | int    | Kreditkarte: Mastercard                                               |
| `terminals[].visa`        | int    | Kreditkarte: Visa                                                     |
| `terminals[].maestro`     | int    | Kreditkarte: Maestro                                                  |
| `terminals[].vpay`        | int    | Kreditkarte: V-Pay                                                    |

Nicht angegebene Kartenfelder werden als `0` interpretiert. Das `terminals`-Array darf für eine reine Bargeldabrechnung leer sein. In der Regel wird pro Aufruf eine Abrechnung übermittelt.

**Antwort** `200 OK`

```json
{
  "report_id": 3044,
  "location_id": 9,
  "report_date": "2026-06-10",
  "finalized": false,
  "system_total_cents": 0,
  "entered_total_cents": 138456,
  "discrepancy_cents": 138456
}
```

- `system_total_cents` — Gesamtbetrag, den Flurbocash aus den Kassensystemdaten errechnet.
- `entered_total_cents` — Gesamtbetrag, der sich aus den eingereichten Abrechnungen ergibt.
- `discrepancy_cents` — `entered_total_cents − system_total_cents`.

---

## Fehler

Fehler verwenden standardisierte HTTP-Statuscodes; der Body enthält eine kurze Klartextnachricht.

| Status | Bedeutung                                                                                    |
|--------|----------------------------------------------------------------------------------------------|
| `400`  | Fehlerhafter Body, unbekannte/fehlende `tid`, ungültiges Datum, `settlement_number` außerhalb 1–4 |
| `400`  | Mehr als 4 Abrechnungen für den Tag (`maximum of 4 settlements per day reached`)            |
| `400`  | `settlement_number` verweist auf eine nicht existierende Abrechnung                         |
| `400`  | Bericht ist abgeschlossen und kann nicht mehr geändert werden                               |
| `401`  | Fehlender oder ungültiger/widerrufener API-Key (`X-API-Key`)                                |
| `403`  | API-Key ist für den angefragten Standort nicht autorisiert                                  |
| `404`  | Tagesbericht `{id}` nicht gefunden                                                           |
| `500`  | Serverfehler                                                                                 |

Bei `400` werden keine Daten geschrieben — die Anfrage wird vollständig validiert, bevor Änderungen gespeichert werden; ein abgelehnter Aufruf lässt den Bericht unverändert.

---

## Korrekturen

Um eine bereits eingereichte Abrechnung zu korrigieren, erneut mit der entsprechenden **`settlement_number`** (1–4) senden. Dadurch wird diese Abrechnung an Ort und Stelle überschrieben (Kassengesamtbetrag und die übermittelten Terminal-Umsätze werden ersetzt).

```json
{ "settlements": [ { "settlement_number": 2, "cash_total": 98765,
                     "terminals": [ { "tid": "TID-ALPHA", "girocard": 9000 } ] } ] }
```

Regeln:

- Die angegebene `settlement_number` muss bereits existieren (zuvor ohne Nummer angelegt). Eine nicht existierende Nummer liefert `400`.
- Das Überschreiben ersetzt `cash_total` und aktualisiert die angegebenen Terminals (Upsert). Nicht aufgeführte Terminals bleiben unverändert — um ein Terminal auf null zu setzen, explizit mit `0`-Beträgen mitsenden.
- Korrekturen sind nur möglich, solange der Bericht **nicht abgeschlossen** ist. Nach dem Abschluss werden alle Schreibzugriffe mit `400` abgelehnt.

---

## Beispiel (curl)

```bash
HOST="https://flurbocash.example.com"
KEY="fck_2a843e19..."

# 1) Bericht sicherstellen, ID erfassen
RID=$(curl -s -X POST "$HOST/api/daily-reports/ensure" \
  -H "X-API-Key: $KEY" -H "Content-Type: application/json" \
  -d '{"location_id":9,"date":"2026-06-10"}' \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["report_id"])')

# 2) Abrechnungen einreichen (Beträge in Cent)
curl -s -X PUT "$HOST/api/daily-reports/$RID/settlements" \
  -H "X-API-Key: $KEY" -H "Content-Type: application/json" \
  -d '{
        "settlements": [
          {
            "cash_total": 123456,
            "terminals": [
              { "tid": "TID-ALPHA", "girocard": 10000, "mastercard": 5000 }
            ]
          }
        ]
      }'
```
