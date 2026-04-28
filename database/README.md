# RoomReserve — Database Layer

**Role:** Database & Data Engineer  
**Tech Stack:** MySQL 8.x · InnoDB · utf8mb4

---

## Files — Run in Order

| File | Description |
|------|-------------|
| `01_schema.sql` | Full DDL: all 9 tables, constraints, indexes |
| `02_seed_data.sql` | Time slots, rooms, users, sample reservations, error & API logs |
| `03_analytics_queries.sql` | 10 analytics queries powering the dashboard |
| `04_stored_procedures.sql` | SP for reservation creation, cancellation, daily snapshot, no-show marking + MySQL Events |
| `05_views.sql` | Convenience views used by FastAPI and the dashboard |

---

## Quick Start

```bash
mysql -u root -p < 01_schema.sql
mysql -u root -p < 02_seed_data.sql
mysql -u root -p < 03_analytics_queries.sql
mysql -u root -p < 04_stored_procedures.sql
mysql -u root -p < 05_views.sql
```

---

## Schema Overview

```
users ──────────< reservations >────────── rooms
                       │                     │
                  cancellations         room_amenities
                       │
                   error_logs          api_request_logs
                                        usage_snapshots
                                          time_slots
```

### Tables

| Table | Rows/Year (est.) | Purpose |
|-------|-----------------|---------|
| `users` | ~500 | Auth & profile |
| `rooms` | ~50 | Room master data |
| `room_amenities` | ~200 | Equipment per room |
| `time_slots` | 11 (static) | Bookable hour slots |
| `reservations` | ~43,800 | Core booking data |
| `cancellations` | ~8,760 | Cancellation audit |
| `error_logs` | ~500,000 | Technical error events |
| `api_request_logs` | ~5,000,000 | Latency & traffic data |
| `usage_snapshots` | ~3,650 | Pre-aggregated daily stats |

---

## Key Design Decisions

### Double-Booking Prevention
A **virtual generated column** `active_flag` is `1` for `confirmed`/`pending` rows and `NULL` for `cancelled`/`no_show`. A **partial unique index** on `(room_id, slot_id, reservation_date, active_flag)` ensures only one active booking per slot per date — allowing a cancelled slot to be re-booked without removing the cancelled row.

### Normalization
Schema is **3NF** throughout. `usage_snapshots` is intentionally denormalized (controlled pre-aggregation) and refreshed nightly via `sp_refresh_daily_snapshot`.

### Latency Tracking
`api_request_logs.latency_ms` stores end-to-end HTTP response time with millisecond-precision timestamps (`DATETIME(3)`). Analytics query Q7 computes P50/P95/P99 percentiles using `PERCENTILE_CONT`.

---

## Stored Procedure Reference

| Procedure | Called By | Returns |
|-----------|-----------|---------|
| `sp_create_reservation` | POST /api/v1/reservations | result_code (0=ok, 1=conflict, 2=inactive, 3=not bookable) |
| `sp_cancel_reservation` | DELETE /api/v1/reservations/:id | result_code (0=ok, 1=not found, 2=already cancelled) |
| `sp_refresh_daily_snapshot` | MySQL Event 00:05 UTC | — |
| `sp_mark_no_shows` | MySQL Event 20:15 UTC | — |

---

## KPIs Tracked from Database

| KPI | Source | Target |
|-----|--------|--------|
| Utilization Rate | `usage_snapshots.utilization_pct` | > 60% |
| Cancellation Rate | `reservations` (status=cancelled) | < 25% |
| No-Show Rate | `reservations` (status=no_show) | < 10% |
| P95 API Latency | `api_request_logs.latency_ms` | < 500 ms |
| Error Rate | `error_logs` / `api_request_logs` | < 1% |
