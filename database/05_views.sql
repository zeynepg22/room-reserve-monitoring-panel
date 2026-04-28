-- =============================================================================
-- RoomReserve Monitoring Panel
-- VIEWS  |  05_views.sql
-- Convenience views used by FastAPI endpoints and the dashboard.
-- =============================================================================

USE roomreserve;

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW: v_active_reservations
-- Used by: GET /api/v1/reservations  (current and future active bookings)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_active_reservations AS
SELECT
    res.reservation_id,
    res.reservation_date,
    res.status,
    res.notes,
    res.created_at,
    u.user_id,
    u.full_name                  AS user_name,
    u.email,
    u.department,
    r.room_id,
    r.room_code,
    r.name                       AS room_name,
    r.capacity,
    r.location,
    r.room_type,
    ts.slot_id,
    ts.label                     AS time_slot,
    ts.start_time,
    ts.end_time
FROM reservations res
JOIN users      u  ON u.user_id  = res.user_id
JOIN rooms      r  ON r.room_id  = res.room_id
JOIN time_slots ts ON ts.slot_id = res.slot_id
WHERE res.status IN ('confirmed', 'pending')
  AND res.reservation_date >= CURDATE();

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW: v_room_daily_availability
-- Used by: GET /api/v1/rooms/availability
-- Shows all room+slot combinations for today
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_room_daily_availability AS
SELECT
    r.room_id,
    r.room_code,
    r.name                                   AS room_name,
    r.capacity,
    r.room_type,
    r.location,
    ts.slot_id,
    ts.label                                 AS time_slot,
    ts.start_time,
    ts.end_time,
    CASE
        WHEN res.reservation_id IS NOT NULL THEN 'BOOKED'
        ELSE 'AVAILABLE'
    END                                      AS status,
    res.user_id                              AS booked_by_user_id,
    u.full_name                              AS booked_by_name
FROM rooms r
CROSS JOIN time_slots ts
LEFT JOIN reservations res
       ON res.room_id          = r.room_id
      AND res.slot_id          = ts.slot_id
      AND res.reservation_date = CURDATE()
      AND res.status IN ('confirmed', 'pending')
LEFT JOIN users u ON u.user_id = res.user_id
WHERE r.is_active   = 1
  AND ts.is_bookable = 1
ORDER BY r.room_code, ts.sort_order;

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW: v_dashboard_summary
-- Used by: Dashboard KPI cards (utilization, bookings, errors today)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_dashboard_summary AS
SELECT
    -- Today's bookings
    (SELECT COUNT(*) FROM reservations
     WHERE reservation_date = CURDATE()
       AND status = 'confirmed')                                  AS bookings_today,

    -- This week's bookings
    (SELECT COUNT(*) FROM reservations
     WHERE reservation_date BETWEEN
           DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY)
           AND CURDATE()
       AND status = 'confirmed')                                  AS bookings_this_week,

    -- Overall utilization today (all rooms)
    (SELECT ROUND(
        COUNT(CASE WHEN status = 'confirmed' THEN 1 END)
        / (11 * (SELECT COUNT(*) FROM rooms WHERE is_active = 1)) * 100, 1
     )
     FROM reservations
     WHERE reservation_date = CURDATE())                          AS utilization_pct_today,

    -- Cancellations today
    (SELECT COUNT(*) FROM reservations
     WHERE reservation_date = CURDATE()
       AND status = 'cancelled')                                  AS cancellations_today,

    -- Errors (ERROR+FATAL) in last hour
    (SELECT COUNT(*) FROM error_logs
     WHERE logged_at >= NOW() - INTERVAL 1 HOUR
       AND severity IN ('ERROR','FATAL'))                         AS critical_errors_last_hour,

    -- Average API latency last hour (ms)
    (SELECT ROUND(AVG(latency_ms), 0) FROM api_request_logs
     WHERE requested_at >= NOW() - INTERVAL 1 HOUR)              AS avg_latency_ms_last_hour,

    -- Active rooms
    (SELECT COUNT(*) FROM rooms WHERE is_active = 1)             AS active_rooms,

    -- Registered users
    (SELECT COUNT(*) FROM users WHERE is_active = 1)             AS registered_users;

-- ─────────────────────────────────────────────────────────────────────────────
-- VIEW: v_recent_errors
-- Used by: Technical monitoring error feed (last 50 errors)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_recent_errors AS
SELECT
    el.log_id,
    el.severity,
    el.error_code,
    el.error_message,
    el.endpoint,
    el.http_method,
    el.logged_at,
    u.full_name   AS user_name,
    u.email,
    r.room_code,
    r.name        AS room_name
FROM error_logs el
LEFT JOIN users        u  ON u.user_id        = el.user_id
LEFT JOIN reservations rs ON rs.reservation_id = el.reservation_id
LEFT JOIN rooms        r  ON r.room_id         = rs.room_id
ORDER BY el.logged_at DESC
LIMIT 50;
