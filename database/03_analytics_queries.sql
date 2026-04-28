-- =============================================================================
-- RoomReserve Monitoring Panel
-- ANALYTICS QUERIES  |  03_analytics_queries.sql
-- Powers the management & monitoring dashboards.
-- =============================================================================

USE roomreserve;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q1: Room Utilization Rate – Last 30 Days
-- Dashboard: Bar chart "Utilization by Room"
-- KPI: utilization_pct  |  Target: > 60%
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    r.room_code,
    r.name                                                      AS room_name,
    r.room_type,
    r.capacity,
    COUNT(res.reservation_id)                                   AS total_bookings,
    COUNT(CASE WHEN res.status = 'confirmed' THEN 1 END)        AS confirmed,
    COUNT(CASE WHEN res.status = 'cancelled' THEN 1 END)        AS cancelled,
    COUNT(CASE WHEN res.status = 'no_show'   THEN 1 END)        AS no_shows,
    ROUND(
        COUNT(CASE WHEN res.status = 'confirmed' THEN 1 END)
        / (11 * 30) * 100, 2
    )                                                           AS utilization_pct
FROM rooms r
LEFT JOIN reservations res
       ON res.room_id = r.room_id
      AND res.reservation_date BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE()
WHERE r.is_active = 1
GROUP BY r.room_id, r.room_code, r.name, r.room_type, r.capacity
ORDER BY utilization_pct DESC;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q2: Peak Hour Analysis – Reservations by Time Slot
-- Dashboard: Heatmap "Demand by Hour"
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    ts.label                                                    AS time_slot,
    ts.start_time,
    COUNT(res.reservation_id)                                   AS total_reservations,
    COUNT(CASE WHEN res.status = 'confirmed' THEN 1 END)        AS confirmed,
    COUNT(CASE WHEN res.status = 'cancelled' THEN 1 END)        AS cancelled,
    ROUND(
        COUNT(CASE WHEN res.status = 'confirmed' THEN 1 END)
        / NULLIF(COUNT(res.reservation_id), 0) * 100, 1
    )                                                           AS confirmation_rate_pct
FROM time_slots ts
LEFT JOIN reservations res
       ON res.slot_id = ts.slot_id
      AND res.reservation_date >= CURDATE() - INTERVAL 90 DAY
GROUP BY ts.slot_id, ts.label, ts.start_time
ORDER BY ts.sort_order;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q3: Daily Cancellation Rate – Last 60 Days
-- Dashboard: Line chart "Cancellation Trend"
-- KPI: cancellation_rate  |  Alert if > 25%
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    res.reservation_date,
    COUNT(res.reservation_id)                                    AS total_bookings,
    COUNT(CASE WHEN res.status = 'cancelled' THEN 1 END)         AS cancellations,
    ROUND(
        COUNT(CASE WHEN res.status = 'cancelled' THEN 1 END)
        / NULLIF(COUNT(res.reservation_id), 0) * 100, 2
    )                                                            AS cancellation_rate_pct
FROM reservations res
WHERE res.reservation_date BETWEEN CURDATE() - INTERVAL 60 DAY AND CURDATE()
GROUP BY res.reservation_date
ORDER BY res.reservation_date;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q4: Most Popular Rooms – Ranked by Confirmed Bookings (All Time)
-- Dashboard: Leaderboard "Top Rooms"
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    r.room_code,
    r.name,
    r.room_type,
    r.capacity,
    COUNT(res.reservation_id)                                    AS confirmed_bookings,
    RANK() OVER (ORDER BY COUNT(res.reservation_id) DESC)        AS popularity_rank
FROM rooms r
JOIN reservations res
  ON res.room_id = r.room_id
 AND res.status = 'confirmed'
GROUP BY r.room_id, r.room_code, r.name, r.room_type, r.capacity
ORDER BY popularity_rank
LIMIT 10;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q5: User Activity – Top Bookers This Month
-- Dashboard: User leaderboard. KPI: active_users_monthly
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    u.user_id,
    u.full_name,
    u.role,
    u.department,
    COUNT(res.reservation_id)                                    AS total_reservations,
    COUNT(CASE WHEN res.status = 'confirmed' THEN 1 END)         AS confirmed,
    COUNT(CASE WHEN res.status = 'cancelled' THEN 1 END)         AS cancelled,
    COUNT(CASE WHEN res.status = 'no_show'   THEN 1 END)         AS no_shows
FROM users u
JOIN reservations res ON res.user_id = u.user_id
WHERE YEAR(res.reservation_date)  = YEAR(CURDATE())
  AND MONTH(res.reservation_date) = MONTH(CURDATE())
GROUP BY u.user_id, u.full_name, u.role, u.department
ORDER BY total_reservations DESC
LIMIT 20;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q6: Weekly Occupancy Heatmap (Room × Day-of-Week, last 90 days)
-- Dashboard: Calendar heatmap
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    r.room_code,
    DAYNAME(res.reservation_date)                               AS day_of_week,
    DAYOFWEEK(res.reservation_date)                             AS dow_num,
    COUNT(res.reservation_id)                                   AS booking_count
FROM rooms r
JOIN reservations res
  ON res.room_id = r.room_id
 AND res.status = 'confirmed'
 AND res.reservation_date >= CURDATE() - INTERVAL 90 DAY
GROUP BY r.room_id, r.room_code,
         DAYOFWEEK(res.reservation_date),
         DAYNAME(res.reservation_date)
ORDER BY r.room_code, dow_num;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q7: API Latency Statistics – Last 24 Hours
-- Dashboard: Monitoring panel — Latency gauges (P50 / P95 / P99)
-- KPI: p95_latency_ms  |  SLA target: < 500 ms
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    endpoint,
    method,
    COUNT(*)                                                     AS request_count,
    ROUND(AVG(latency_ms), 0)                                    AS avg_latency_ms,
    MIN(latency_ms)                                              AS min_latency_ms,
    MAX(latency_ms)                                              AS max_latency_ms,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY latency_ms) OVER (PARTITION BY endpoint, method), 0)
                                                                 AS p50_ms,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP
          (ORDER BY latency_ms) OVER (PARTITION BY endpoint, method), 0)
                                                                 AS p95_ms,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP
          (ORDER BY latency_ms) OVER (PARTITION BY endpoint, method), 0)
                                                                 AS p99_ms,
    SUM(CASE WHEN status_code >= 500 THEN 1 ELSE 0 END)         AS server_errors,
    SUM(CASE WHEN status_code = 429  THEN 1 ELSE 0 END)         AS rate_limit_hits
FROM api_request_logs
WHERE requested_at >= NOW() - INTERVAL 24 HOUR
GROUP BY endpoint, method
ORDER BY avg_latency_ms DESC
LIMIT 20;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q8: Error Rate by Endpoint – Last 24 Hours
-- Dashboard: Error panel. Alert if error_count >= 3 in 1 hour.
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    el.endpoint,
    el.http_method,
    el.severity,
    COUNT(*)                                                     AS error_count,
    COUNT(DISTINCT el.user_id)                                   AS affected_users,
    MIN(el.logged_at)                                            AS first_occurrence,
    MAX(el.logged_at)                                            AS last_occurrence,
    GROUP_CONCAT(DISTINCT el.error_code
                 ORDER BY el.error_code SEPARATOR ', ')          AS error_codes
FROM error_logs el
WHERE el.logged_at >= NOW() - INTERVAL 24 HOUR
GROUP BY el.endpoint, el.http_method, el.severity
HAVING error_count >= 1
ORDER BY error_count DESC;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q9: Failed Reservation Attempts (double-booking conflicts)
-- Dashboard: Technical monitoring – "Conflict Log"
-- ─────────────────────────────────────────────────────────────────────────────
SELECT
    el.log_id,
    el.user_id,
    u.full_name,
    el.error_code,
    el.error_message,
    el.endpoint,
    el.logged_at
FROM error_logs el
LEFT JOIN users u ON u.user_id = el.user_id
WHERE el.error_code = 'BOOKING_CONFLICT'
ORDER BY el.logged_at DESC
LIMIT 50;

-- ─────────────────────────────────────────────────────────────────────────────
-- Q10: Room Availability Check for a Specific Date
-- Used by: Backend /api/v1/rooms/availability?date=XXXX
-- ─────────────────────────────────────────────────────────────────────────────
-- Replace @check_date with the desired date
SET @check_date = CURDATE();

SELECT
    r.room_id,
    r.room_code,
    r.name,
    r.capacity,
    ts.slot_id,
    ts.label                                                     AS time_slot,
    CASE
        WHEN res.reservation_id IS NOT NULL THEN 'BOOKED'
        ELSE 'AVAILABLE'
    END                                                          AS availability_status,
    res.user_id                                                  AS booked_by_user_id
FROM rooms r
CROSS JOIN time_slots ts
LEFT JOIN reservations res
       ON res.room_id = r.room_id
      AND res.slot_id = ts.slot_id
      AND res.reservation_date = @check_date
      AND res.status IN ('confirmed', 'pending')
WHERE r.is_active = 1
  AND ts.is_bookable = 1
ORDER BY r.room_code, ts.sort_order;
