-- =============================================================================
-- RoomReserve Monitoring Panel
-- DATABASE SCHEMA  |  01_schema.sql
-- Author  : Database & Data Engineer
-- Engine  : MySQL 8.x  |  InnoDB  |  utf8mb4
-- Run     : mysql -u root -p < 01_schema.sql
-- =============================================================================

CREATE DATABASE IF NOT EXISTS roomreserve
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE roomreserve;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: users
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    user_id        INT           NOT NULL AUTO_INCREMENT,
    email          VARCHAR(255)  NOT NULL,
    full_name      VARCHAR(150)  NOT NULL,
    role           ENUM('student','staff','admin') NOT NULL DEFAULT 'student',
    password_hash  VARCHAR(255)  NOT NULL,
    phone          VARCHAR(20)   NULL,
    department     VARCHAR(100)  NULL,
    is_active      TINYINT(1)   NOT NULL DEFAULT 1,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_users   PRIMARY KEY (user_id),
    CONSTRAINT uq_email   UNIQUE      (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: rooms
-- min_role_required : student / staff / admin — who can book this room
-- image_url         : CDN/storage path for room photo (used by frontend cards)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rooms (
    room_id              INT          NOT NULL AUTO_INCREMENT,
    room_code            VARCHAR(20)  NOT NULL,
    name                 VARCHAR(120) NOT NULL,
    capacity             SMALLINT     NOT NULL,
    location             VARCHAR(120) NOT NULL,
    room_type            ENUM('study_room','meeting_room','lab','seminar_hall') NOT NULL,
    min_role_required    ENUM('student','staff','admin') NOT NULL DEFAULT 'student',
    floor                TINYINT      NOT NULL DEFAULT 1,
    is_active            TINYINT(1)  NOT NULL DEFAULT 1,
    image_url            VARCHAR(500) NULL,
    description          TEXT         NULL,
    created_at           DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_rooms      PRIMARY KEY (room_id),
    CONSTRAINT uq_room_code  UNIQUE      (room_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: room_amenities
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS room_amenities (
    amenity_id    INT         NOT NULL AUTO_INCREMENT,
    room_id       INT         NOT NULL,
    amenity_type  ENUM('projector','whiteboard','ac','tv_screen',
                       'video_conf','printer','standing_desk') NOT NULL,
    quantity      TINYINT     NOT NULL DEFAULT 1,
    notes         VARCHAR(255) NULL,
    CONSTRAINT pk_amenities       PRIMARY KEY (amenity_id),
    CONSTRAINT fk_amenity_room    FOREIGN KEY (room_id)
                                  REFERENCES rooms(room_id) ON DELETE CASCADE,
    CONSTRAINT uq_room_amenity    UNIQUE (room_id, amenity_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: time_slots
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS time_slots (
    slot_id       INT         NOT NULL AUTO_INCREMENT,
    label         VARCHAR(30) NOT NULL,
    start_time    TIME        NOT NULL,
    end_time      TIME        NOT NULL,
    is_bookable   TINYINT(1) NOT NULL DEFAULT 1,
    sort_order    TINYINT    NOT NULL DEFAULT 0,
    CONSTRAINT pk_slots      PRIMARY KEY (slot_id),
    CONSTRAINT uq_slot       UNIQUE (start_time, end_time),
    CONSTRAINT chk_slot_time CHECK  (end_time > start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: reservations
-- active_flag      : virtual column — 1 for confirmed/pending, NULL otherwise
--                    enables partial unique index for double-booking prevention
-- actual_start_time: set when user presses "Check In" — used for no-show logic
-- actual_end_time  : set when user presses "End" or auto-set by scheduler
-- checkin_device   : how the user checked in (app / qr / kiosk)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reservations (
    reservation_id    INT          NOT NULL AUTO_INCREMENT,
    user_id           INT          NOT NULL,
    room_id           INT          NOT NULL,
    slot_id           INT          NOT NULL,
    reservation_date  DATE         NOT NULL,
    status            ENUM('pending','confirmed','cancelled','no_show')
                                   NOT NULL DEFAULT 'confirmed',
    notes             TEXT         NULL,
    actual_start_time DATETIME     NULL,
    actual_end_time   DATETIME     NULL,
    checkin_device    ENUM('app','qr','kiosk') NULL,
    created_at        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,

    active_flag       TINYINT(1)  GENERATED ALWAYS AS (
                        IF(status IN ('confirmed','pending'), 1, NULL)
                      ) VIRTUAL,

    CONSTRAINT pk_reservations     PRIMARY KEY (reservation_id),
    CONSTRAINT fk_res_user         FOREIGN KEY (user_id)
                                   REFERENCES users(user_id)       ON DELETE RESTRICT,
    CONSTRAINT fk_res_room         FOREIGN KEY (room_id)
                                   REFERENCES rooms(room_id)       ON DELETE RESTRICT,
    CONSTRAINT fk_res_slot         FOREIGN KEY (slot_id)
                                   REFERENCES time_slots(slot_id)  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX uq_active_booking
    ON reservations (room_id, slot_id, reservation_date, active_flag);

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: cancellations
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cancellations (
    cancel_id        INT          NOT NULL AUTO_INCREMENT,
    reservation_id   INT          NOT NULL,
    cancelled_by     INT          NOT NULL,
    reason           VARCHAR(500) NULL,
    cancelled_at     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    refund_eligible  TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT pk_cancel       PRIMARY KEY (cancel_id),
    CONSTRAINT uq_cancel_res   UNIQUE      (reservation_id),
    CONSTRAINT fk_cancel_res   FOREIGN KEY (reservation_id)
                               REFERENCES reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT fk_cancel_user  FOREIGN KEY (cancelled_by)
                               REFERENCES users(user_id)              ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: error_logs   (Technical Monitoring)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS error_logs (
    log_id           BIGINT        NOT NULL AUTO_INCREMENT,
    user_id          INT           NULL,
    reservation_id   INT           NULL,
    error_code       VARCHAR(50)   NOT NULL,
    error_message    VARCHAR(1000) NOT NULL,
    stack_trace      TEXT          NULL,
    endpoint         VARCHAR(255)  NULL,
    http_method      ENUM('GET','POST','PUT','PATCH','DELETE') NULL,
    severity         ENUM('INFO','WARN','ERROR','FATAL') NOT NULL DEFAULT 'ERROR',
    environment      ENUM('dev','staging','production')  NOT NULL DEFAULT 'production',
    logged_at        DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT pk_error_logs   PRIMARY KEY (log_id),
    CONSTRAINT fk_log_user     FOREIGN KEY (user_id)
                               REFERENCES users(user_id)        ON DELETE SET NULL,
    CONSTRAINT fk_log_res      FOREIGN KEY (reservation_id)
                               REFERENCES reservations(reservation_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: api_request_logs   (Latency / Performance Tracking)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS api_request_logs (
    req_id               BIGINT       NOT NULL AUTO_INCREMENT,
    user_id              INT          NULL,
    session_id           VARCHAR(64)  NULL,
    method               ENUM('GET','POST','PUT','PATCH','DELETE') NOT NULL,
    endpoint             VARCHAR(255) NOT NULL,
    status_code          SMALLINT    NOT NULL,
    latency_ms           MEDIUMINT   NOT NULL,
    request_size_bytes   INT         NULL,
    response_size_bytes  INT         NULL,
    ip_address           VARCHAR(45) NULL,
    user_agent           VARCHAR(512) NULL,
    requested_at         DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT pk_api_logs   PRIMARY KEY (req_id),
    CONSTRAINT fk_req_user   FOREIGN KEY (user_id)
                             REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE: usage_snapshots   (Pre-aggregated daily stats per room)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS usage_snapshots (
    snapshot_id           INT           NOT NULL AUTO_INCREMENT,
    room_id               INT           NOT NULL,
    snapshot_date         DATE          NOT NULL,
    total_slots           TINYINT      NOT NULL DEFAULT 11,
    booked_slots          TINYINT      NOT NULL DEFAULT 0,
    cancelled_slots       TINYINT      NOT NULL DEFAULT 0,
    no_show_slots         TINYINT      NOT NULL DEFAULT 0,
    utilization_pct       DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    avg_latency_ms        INT          NULL,
    total_api_requests    INT          NULL,
    error_count           INT          NOT NULL DEFAULT 0,
    snapshot_created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_snapshots    PRIMARY KEY (snapshot_id),
    CONSTRAINT uq_room_date    UNIQUE (room_id, snapshot_date),
    CONSTRAINT fk_snap_room    FOREIGN KEY (room_id)
                               REFERENCES rooms(room_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- INDEXES
-- =============================================================================

CREATE INDEX idx_res_user_date  ON reservations (user_id, reservation_date);
CREATE INDEX idx_res_room_date  ON reservations (room_id, reservation_date);
CREATE INDEX idx_res_status     ON reservations (status);
CREATE INDEX idx_res_created    ON reservations (created_at);
CREATE INDEX idx_res_checkin    ON reservations (actual_start_time);

CREATE INDEX idx_err_severity   ON error_logs (severity, logged_at);
CREATE INDEX idx_err_endpoint   ON error_logs (endpoint, logged_at);
CREATE INDEX idx_err_user       ON error_logs (user_id, logged_at);

CREATE INDEX idx_req_endpoint   ON api_request_logs (endpoint, requested_at);
CREATE INDEX idx_req_latency    ON api_request_logs (latency_ms);
CREATE INDEX idx_req_status     ON api_request_logs (status_code, requested_at);
CREATE INDEX idx_req_user       ON api_request_logs (user_id, requested_at);

CREATE INDEX idx_snap_date      ON usage_snapshots (snapshot_date DESC);
CREATE INDEX idx_snap_util      ON usage_snapshots (utilization_pct DESC);

CREATE INDEX idx_room_type      ON rooms (room_type, is_active);
CREATE INDEX idx_room_capacity  ON rooms (capacity);
CREATE INDEX idx_room_role      ON rooms (min_role_required, is_active);
