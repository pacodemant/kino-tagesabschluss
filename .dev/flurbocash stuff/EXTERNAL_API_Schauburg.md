# Flurbocash External API

## Conventions

- **Base URL:** `https://<your-host>` (default port `8080`).
- **Content type:** `application/json` for all request and response bodies.
- **Money is always integer cents.** Every monetary amount in requests and
  responses is an integer number of cents, e.g. `123456` means `1234.56 EUR`.
  Never send floats/decimals.
- **Dates** are `YYYY-MM-DD` (e.g. `2026-06-10`).

## Authentication

All external endpoints are authenticated with an **API key**, sent in the
`X-API-Key` header:

```
X-API-Key: fck_2a843e19...
```

Each API key is **scoped to one or more locations**. A key may only read/write
data for the locations it is assigned to. Requests for any other location are
rejected with `403 Forbidden`.


## Typical flow

1. **Ensure a daily report exists** for the location and date, and obtain its
   `report_id` → `POST /api/daily-reports/ensure`.
2. **Submit the settlements** (cash totals + terminal closings) for that
   `report_id` → `PUT /api/daily-reports/{id}/settlements`.

External data often arrives before Flurbocash's own import watchers have created
the report, so step 1 creates it on demand.

---

## `POST /api/daily-reports/ensure`

Returns the daily report ID for a location and date, **creating the report if it
does not exist yet**. Idempotent: calling it again for the same location+date
returns the same `report_id`.

**Request**

```json
{
  "location_id": 9,
  "date": "2026-06-10"
}
```

**Response** `200 OK`

```json
{
  "report_id": 3044,
  "location_id": 9,
  "report_date": "2026-06-10",
  "finalized": false
}
```

If `finalized` is `true`, the report has been closed and can no longer accept
settlements (see error table below).

---

## `PUT /api/daily-reports/{id}/settlements`

Submits the cash totals and per-terminal card closings for a daily report.
`{id}` is the `report_id` from the ensure call.

A **settlement** is one cash-up within the day. Each settlement carries one cash
total plus the card breakdown of every terminal that was settled in it. Terminals
are identified by their **TID** (terminal ID from the payment provider), which
must already be registered for the report's location.

`settlement_number` is **optional** and controls append vs. overwrite:

- **Omit it** to **add a new settlement**. The server assigns the next free
  number for the day (first becomes 1, then 2, …). A day allows at most **4**
  settlements; a request that would exceed 4 is rejected with `400` and nothing
  is written.
- **Set it to `1`–`4`** to **overwrite that existing settlement** (correction).
  The targeted settlement must already exist — sending a number that does not
  exist yet is rejected with `400` (`settlement N does not exist; omit
  settlement_number to create a new settlement`). Use omit-to-create first, then
  the number to correct.

See [Corrections](#corrections) below.

**Request**

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

Field reference (all amounts in cents):

| Field               | Type   | Notes                                  |
|---------------------|--------|----------------------------------------|
| `settlement_number` | int    | Optional. Omit to append a new settlement; `1`–`4` overwrites that existing one |
| `cash_total`        | int    | Counted cash for this settlement       |
| `terminals[].tid`   | string | Terminal ID, must exist for the location |
| `terminals[].girocard`    | int | EC-Karte: Girocard                  |
| `terminals[].lastschrift` | int | EC-Karte: Lastschrift               |
| `terminals[].mastercard`  | int | Kreditkarte: Mastercard             |
| `terminals[].visa`        | int | Kreditkarte: Visa                   |
| `terminals[].maestro`     | int | Kreditkarte: Maestro                |
| `terminals[].vpay`        | int | Kreditkarte: V-Pay                  |

Omitted card fields default to `0`. The `terminals` array may be empty for a
cash-only settlement. Usually you submit one settlement per call.

**Response** `200 OK`

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

- `system_total_cents` — total computed by Flurbocash from the cash-register
  reports.
- `entered_total_cents` — total derived from the settlements you submitted.
- `discrepancy_cents` — `entered_total_cents − system_total_cents`.

---

## Errors

Errors use standard HTTP status codes; the body is a short plain-text message.

| Status | Meaning                                                            |
|--------|-------------------------------------------------------------------|
| `400`  | Malformed body, missing/unknown `tid`, bad date, `settlement_number` outside 1–4 |
| `400`  | More than 4 settlements for the day (`maximum of 4 settlements per day reached`) |
| `400`  | `settlement_number` targets a settlement that does not exist       |
| `400`  | Report is finalized and can no longer be modified                 |
| `401`  | Missing or invalid/revoked API key (`X-API-Key`)                  |
| `403`  | API key is not authorized for the requested location              |
| `404`  | Daily report `{id}` not found                                     |
| `500`  | Server error                                                      |

On a `400`, no data is written — the request is validated before any changes are
persisted, so a rejected call leaves the report unchanged.

---

## Corrections

To correct a settlement you already submitted, send it again **with its
`settlement_number`** (1–4). This overwrites that settlement in place (cash total
and the listed terminal payments are replaced).

```json
{ "settlements": [ { "settlement_number": 2, "cash_total": 98765,
                     "terminals": [ { "tid": "TID-ALPHA", "girocard": 9000 } ] } ] }
```

Rules:

- The targeted `settlement_number` must already exist (created earlier by an
  omit-the-number call). Targeting a non-existent number returns `400`.
- Overwriting replaces the settlement's `cash_total` and upserts the terminals
  you send. Terminals you do **not** list are left untouched — to zero a terminal
  out, send it explicitly with `0` amounts.
- Corrections are only possible while the report is **not finalized**. After
  finalization all writes are rejected with `400`.

---

## Example (curl)

```bash
HOST="https://flurbocash.example.com"
KEY="fck_2a843e19..."

# 1) Ensure the report exists, capture its id
RID=$(curl -s -X POST "$HOST/api/daily-reports/ensure" \
  -H "X-API-Key: $KEY" -H "Content-Type: application/json" \
  -d '{"location_id":9,"date":"2026-06-10"}' \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["report_id"])')

# 2) Submit settlements (amounts in cents)
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
