-- =============================================================================
-- RoomReserve Monitoring Panel
-- STORED PROCEDURES & EVENTS  |  04_stored_procedures.sql
-- =============================================================================

USE roomreserve;

-- ─────────────────────────────────────────────────────────────────────────────
-- SP 1: Create a reservation with double-booking protection
-- Called by: FastAPI POST /api/v1/reservations
-- Returns: 0 = success, 1 = conflict, 2 = room inactive, 3 = slot not bookable
-- ─────────────────────────────────────────────────────────────────────────────
DELIMITER $$

CREATE PROCEDURE sp_create_reservation(
    IN  p_user_id          INT,
    IN  p_room_id          INT,
    IN  p_slot_id          INT,
    IN  p_reservation_date DATE,
    IN  p_notes            TEXT,
    OUT p_result_code      TINYINT,
    OUT p_reservation_id   INT
)
BEGIN
    DECLARE v_room_active   TINYINT DEFAULT 0;
    DECLARE v_slot_bookable TINYINT DEFAULT 0;
    DECLARE v_conflict      INT     DEFAULT 0;

    -- Check room is active
    SELECT is_active INTO v_room_active
    FROM rooms WHERE room_id = p_room_id;

    IF v_room_active = 0 THEN
        SET p_result_code = 2, p_reservation_id = NULL;
        LEAVE sp_create_reservation;
    END IF;

    -- Check slot is bookable
    SELECT is_bookable INTO v_slot_bookable
    FROM time_slots WHERE slot_id = p_slot_id;

    IF v_slot_bookable = 0 THEN
        SET p_result_code = 3, p_reservation_id = NULL;
        LEAVE sp_create_reservation;
    END IF;

    -- Check for existing active booking (double-booking prevention)
    SELECT COUNT(*) INTO v_conflict
    FROM reservations
    WHERE room_id          = p_room_id
      AND slot_id          = p_slot_id
      AND reservation_date = p_reservation_date
      AND status IN ('confirmed', 'pending');

    IF v_conflict > 0 THEN
        -- Log the failed attempt
        INSERT INTO error_logs
            (user_id, error_code, error_message, endpoint, http_method, severity)
        VALUES
            (p_user_id,
             'BOOKING_CONFLICT',
             CONCAT('Slot already reserved: room_id=', p_room_id,
                    ', slot_id=', p_slot_id,
                    ', date=', p_reservation_date),
             '/api/v1/reservations',
             'POST',
             'ERROR');

        SET p_result_code = 1, p_reservation_id = NULL;
        LEAVE sp_create_reservation;
    END IF;

    -- All checks passed — insert reservation
    INSERT INTO reservations (user_id, room_id, slot_id, reservation_date, status, notes)
    VALUES (p_user_id, p_room_id, p_slot_id, p_reservation_date, 'confirmed', p_notes);

    SET p_result_code    = 0;
    SET p_reservation_id = LAST_INSERT_ID();
END$$

DELIMITER ;

-- Usage example:
-- CALL sp_create_reservation(1, 1, 2, '2025-05-01', 'Study session', @rc, @rid);
-- SELECT @rc AS result_code, @rid AS reservation_id;

-- ─────────────────────────────────────────────────────────────────────────────
-- SP 2: Cancel a reservation
-- Called by: FastAPI DELETE /api/v1/reservations/:id
-- Returns: 0 = success, 1 = not found, 2 = already cancelled
-- ─────────────────────────────────────────────────────────────────────────────
DELIMITER $$

CREATE PROCEDURE sp_cancel_reservation(
    IN  p_reservation_id INT,
    IN  p_cancelled_by   INT,
    IN  p_reason         VARCHAR(500),
    OUT p_result_code    TINYINT
)
BEGIN
    DECLARE v_current_status ENUM('pending','confirmed','cancelled','no_show');
    DECLARE v_slot_start     DATETIME;
    DECLARE v_refund         TINYINT DEFAULT 0;

    SELECT res.status,
           TIMESTAMP(res.reservation_date, ts.start_time)
    INTO   v_current_status, v_slot_start
    FROM   reservations res
    JOIN   time_slots ts ON ts.slot_id = res.slot_id
    WHERE  res.reservation_id = p_reservation_id;

    IF v_current_status IS NULL THEN
        SET p_result_code = 1;
        LEAVE sp_cancel_reservation;
    END IF;

    IF v_current_status = 'cancelled' THEN
        SET p_result_code = 2;
        LEAVE sp_cancel_reservation;
    END IF;

    -- Refund eligible if > 2 hours before slot
    IF TIMESTAMPDIFF(HOUR, NOW(), v_slot_start) >= 2 THEN
        SET v_refund = 1;
    END IF;

    -- Update reservation status
    UPDATE reservations
    SET    status = 'cancelled'
    WHERE  reservation_id = p_reservation_id;

    -- Insert cancellation record
    INSERT INTO cancellations (reservation_id, cancelled_by, reason, refund_eligible)
    VALUES (p_reservation_id, p_cancelled_by, p_reason, v_refund);

    SET p_result_code = 0;
END$$

DELIMITER ;

-- ─────────────────────────────────────────────────────────────────────────────
-- SP 3: Daily snapshot refresh (scheduled via Event Scheduler)
-- Called by: MySQL Event Scheduler at 00:05 UTC daily
-- ─────────────────────────────────────────────────────────────────────────────
DELIMITER $$

CREATE PROCEDURE sp_refresh_daily_snapshot(IN p_date DATE)
BEGIN
    DECLARE v_target_date DATE DEFAULT IFNULL(p_date, CURDATE() - INTERVAL 1 DAY);

    INSERT INTO usage_snapshots
        (room_id, snapshot_date, total_slots,
         booked_slots, cancelled_slots, no_show_slots,
         utilization_pct, avg_latency_ms, total_api_requests, error_count)
    SELECT
        r.room_id,
        v_target_date,
        11                                                               AS total_slots,
        COUNT(CASE WHEN res.status = 'confirmed' THEN 1 END)             AS booked_slots,
        COUNT(CASE WHEN res.status = 'cancelled' THEN 1 END)             AS cancelled_slots,
        COUNT(CASE WHEN res.status = 'no_show'   THEN 1 END)             AS no_show_slots,
        ROUND(COUNT(CASE WHEN res.status = 'confirmed' THEN 1 END)
              / 11 * 100, 2)                                             AS utilization_pct,
        (SELECT ROUND(AVG(latency_ms), 0)
         FROM   api_request_logs
         WHERE  DATE(requested_at) = v_target_date)                      AS avg_latency_ms,
        (SELECT COUNT(*)
         FROM   api_request_logs
         WHERE  DATE(requested_at) = v_target_date)                      AS total_api_requests,
        (SELECT COUNT(*)
         FROM   error_logs
         WHERE  DATE(logged_at) = v_target_date
           AND  severity IN ('ERROR','FATAL'))                            AS error_count
    FROM  rooms r
    LEFT JOIN reservations res
           ON res.room_id          = r.room_id
          AND res.reservation_date = v_target_date
    WHERE  r.is_active = 1
    GROUP BY r.room_id
    ON DUPLICATE KEY UPDATE
        booked_slots         = VALUES(booked_slots),
        cancelled_slots      = VALUES(cancelled_slots),
        no_show_slots        = VALUES(no_show_slots),
        utilization_pct      = VALUES(utilization_pct),
        avg_latency_ms       = VALUES(avg_latency_ms),
        total_api_requests   = VALUES(total_api_requests),
        error_count          = VALUES(error_count),
        snapshot_created_at  = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

-- ─────────────────────────────────────────────────────────────────────────────
-- SP 4: Mark no-shows (run at end of each day)
-- Marks confirmed reservations where the slot has passed as no_show
-- ─────────────────────────────────────────────────────────────────────────────
DELIMITER $$

CREATE PROCEDURE sp_mark_no_shows()
BEGIN
    UPDATE reservations res
    JOIN   time_slots ts ON ts.slot_id = res.slot_id
    SET    res.status = 'no_show'
    WHERE  res.status = 'confirmed'
      AND  TIMESTAMP(res.reservation_date, ts.end_time) < NOW();
END$$

DELIMITER ;

-- ─────────────────────────────────────────────────────────────────────────────
-- EVENTS  (requires: SET GLOBAL event_scheduler = ON;)
-- ─────────────────────────────────────────────────────────────────────────────
SET GLOBAL event_scheduler = ON;

-- Daily snapshot at 00:05 UTC
CREATE EVENT IF NOT EXISTS ev_daily_snapshot
    ON SCHEDULE EVERY 1 DAY
    STARTS '2025-01-01 00:05:00'
    DO CALL sp_refresh_daily_snapshot(NULL);

-- Mark no-shows at 20:15 (after last slot ends at 20:00)
CREATE EVENT IF NOT EXISTS ev_mark_no_shows
    ON SCHEDULE EVERY 1 DAY
    STARTS '2025-01-01 20:15:00'
    DO CALL sp_mark_no_shows();

-- Purge INFO/WARN logs older than 30 days (runs weekly on Sunday)
CREATE EVENT IF NOT EXISTS ev_purge_old_logs
    ON SCHEDULE EVERY 1 WEEK
    STARTS '2025-01-05 02:00:00'
    DO
        DELETE FROM error_logs
        WHERE severity IN ('INFO', 'WARN')
          AND logged_at < NOW() - INTERVAL 30 DAY;
