-- =============================================================================
-- RoomReserve Monitoring Panel
-- SEED / SAMPLE DATA  |  02_seed_data.sql
-- Run after: 01_schema.sql
-- =============================================================================

USE roomreserve;

-- ─────────────────────────────────────────────────────────────────────────────
-- time_slots  (11 bookable slots per day: 08:00 – 20:00)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO time_slots (label, start_time, end_time, sort_order) VALUES
  ('08:00 - 09:00', '08:00:00', '09:00:00',  1),
  ('09:00 - 10:00', '09:00:00', '10:00:00',  2),
  ('10:00 - 11:00', '10:00:00', '11:00:00',  3),
  ('11:00 - 12:00', '11:00:00', '12:00:00',  4),
  ('13:00 - 14:00', '13:00:00', '14:00:00',  5),
  ('14:00 - 15:00', '14:00:00', '15:00:00',  6),
  ('15:00 - 16:00', '15:00:00', '16:00:00',  7),
  ('16:00 - 17:00', '16:00:00', '17:00:00',  8),
  ('17:00 - 18:00', '17:00:00', '18:00:00',  9),
  ('18:00 - 19:00', '18:00:00', '19:00:00', 10),
  ('19:00 - 20:00', '19:00:00', '20:00:00', 11);

-- ─────────────────────────────────────────────────────────────────────────────
-- rooms
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO rooms (room_code, name, capacity, location, room_type, floor, description) VALUES
  ('A101', 'Alpha Study Room',         4,  'Building A – Floor 1', 'study_room',   1, 'Quiet individual/small group study room.'),
  ('A201', 'Beta Study Room',          6,  'Building A – Floor 2', 'study_room',   2, 'Group study room with whiteboard.'),
  ('B301', 'Conference Room Delta',   12,  'Building B – Floor 3', 'meeting_room', 3, 'Standard meeting room with projector and video conferencing.'),
  ('B401', 'Seminar Hall Gamma',      40,  'Building B – Floor 4', 'seminar_hall', 4, 'Large seminar hall for lectures and events.'),
  ('C101', 'Computer Lab Epsilon',    20,  'Building C – Floor 1', 'lab',          1, '20-seat computer lab with dual monitors.'),
  ('C201', 'Innovation Hub Zeta',      8,  'Building C – Floor 2', 'meeting_room', 2, 'Creative collaboration space with standing desks.');

-- ─────────────────────────────────────────────────────────────────────────────
-- room_amenities
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO room_amenities (room_id, amenity_type, quantity) VALUES
  -- A101
  (1, 'whiteboard', 1), (1, 'ac', 1),
  -- A201
  (2, 'whiteboard', 2), (2, 'ac', 1), (2, 'projector', 1),
  -- B301
  (3, 'projector', 1), (3, 'video_conf', 1), (3, 'whiteboard', 2), (3, 'ac', 1),
  -- B401
  (4, 'projector', 2), (4, 'ac', 2), (4, 'tv_screen', 1),
  -- C101
  (5, 'projector', 5), (5, 'printer', 2), (5, 'ac', 2),
  -- C201
  (6, 'whiteboard', 1), (6, 'video_conf', 1), (6, 'standing_desk', 4), (6, 'ac', 1);

-- ─────────────────────────────────────────────────────────────────────────────
-- users  (passwords are bcrypt hashes of "Test1234!" for demo purposes)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO users (email, full_name, role, password_hash, phone, department) VALUES
  ('alice@uni.edu',   'Alice Johnson',   'student', '$2b$12$KIX5KqzpxQmRzqLvE7VhXuQ9hZ3gFq0pL1GnTnJpUYhKv6TlD8aYq', '555-0101', 'Computer Science'),
  ('bob@uni.edu',     'Bob Williams',    'student', '$2b$12$KIX5KqzpxQmRzqLvE7VhXuQ9hZ3gFq0pL1GnTnJpUYhKv6TlD8aYq', '555-0102', 'Electrical Engineering'),
  ('carol@uni.edu',   'Carol Martinez',  'staff',   '$2b$12$KIX5KqzpxQmRzqLvE7VhXuQ9hZ3gFq0pL1GnTnJpUYhKv6TlD8aYq', '555-0103', 'Administration'),
  ('david@uni.edu',   'David Lee',       'admin',   '$2b$12$KIX5KqzpxQmRzqLvE7VhXuQ9hZ3gFq0pL1GnTnJpUYhKv6TlD8aYq', '555-0104', 'IT Services'),
  ('eve@uni.edu',     'Eve Thompson',    'student', '$2b$12$KIX5KqzpxQmRzqLvE7VhXuQ9hZ3gFq0pL1GnTnJpUYhKv6TlD8aYq', '555-0105', 'Business Administration'),
  ('frank@uni.edu',   'Frank Garcia',    'student', '$2b$12$KIX5KqzpxQmRzqLvE7VhXuQ9hZ3gFq0pL1GnTnJpUYhKv6TlD8aYq', '555-0106', 'Mathematics'),
  ('grace@uni.edu',   'Grace Kim',       'student', '$2b$12$KIX5KqzpxQmRzqLvE7VhXuQ9hZ3gFq0pL1GnTnJpUYhKv6TlD8aYq', '555-0107', 'Physics'),
  ('henry@uni.edu',   'Henry Brown',     'staff',   '$2b$12$KIX5KqzpxQmRzqLvE7VhXuQ9hZ3gFq0pL1GnTnJpUYhKv6TlD8aYq', '555-0108', 'Library Services');

-- ─────────────────────────────────────────────────────────────────────────────
-- reservations  (mix of statuses for realistic demo data)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO reservations (user_id, room_id, slot_id, reservation_date, status, notes) VALUES
  -- Today
  (1, 1, 2,  CURDATE(), 'confirmed', 'Study session for finals'),
  (2, 1, 3,  CURDATE(), 'confirmed', NULL),
  (3, 3, 5,  CURDATE(), 'confirmed', 'Weekly team standup'),
  (5, 5, 2,  CURDATE(), 'confirmed', 'Lab work'),
  (6, 2, 4,  CURDATE(), 'cancelled', NULL),
  -- Tomorrow
  (1, 2, 1,  CURDATE() + INTERVAL 1 DAY, 'confirmed', 'Group project meeting'),
  (4, 4, 6,  CURDATE() + INTERVAL 1 DAY, 'confirmed', 'Department seminar'),
  (7, 6, 3,  CURDATE() + INTERVAL 1 DAY, 'confirmed', 'Research presentation'),
  -- Day after
  (2, 3, 4,  CURDATE() + INTERVAL 2 DAY, 'confirmed', NULL),
  (5, 5, 7,  CURDATE() + INTERVAL 2 DAY, 'confirmed', 'Data structures lab'),
  (8, 1, 5,  CURDATE() + INTERVAL 2 DAY, 'pending',   'Pending approval'),
  -- Next week
  (1, 3, 2,  CURDATE() + INTERVAL 7 DAY, 'confirmed', NULL),
  (3, 6, 8,  CURDATE() + INTERVAL 7 DAY, 'confirmed', 'Sprint review'),
  -- Past reservations (for analytics)
  (2, 1, 2,  CURDATE() - INTERVAL 1 DAY, 'confirmed', NULL),
  (1, 2, 3,  CURDATE() - INTERVAL 1 DAY, 'no_show',   NULL),
  (4, 3, 5,  CURDATE() - INTERVAL 2 DAY, 'confirmed', NULL),
  (5, 4, 6,  CURDATE() - INTERVAL 2 DAY, 'cancelled', NULL),
  (6, 5, 2,  CURDATE() - INTERVAL 3 DAY, 'confirmed', NULL),
  (7, 6, 4,  CURDATE() - INTERVAL 3 DAY, 'confirmed', NULL),
  (8, 1, 7,  CURDATE() - INTERVAL 4 DAY, 'confirmed', NULL),
  (1, 3, 1,  CURDATE() - INTERVAL 5 DAY, 'confirmed', NULL),
  (2, 5, 3,  CURDATE() - INTERVAL 5 DAY, 'cancelled', NULL),
  (3, 2, 9,  CURDATE() - INTERVAL 7 DAY, 'confirmed', NULL),
  (4, 4, 2,  CURDATE() - INTERVAL 7 DAY, 'confirmed', NULL),
  (5, 6, 5,  CURDATE() - INTERVAL 10 DAY, 'confirmed', NULL),
  (6, 3, 6,  CURDATE() - INTERVAL 10 DAY, 'no_show',   NULL),
  (7, 1, 8,  CURDATE() - INTERVAL 14 DAY, 'confirmed', NULL),
  (8, 2, 4,  CURDATE() - INTERVAL 14 DAY, 'confirmed', NULL),
  (1, 5, 10, CURDATE() - INTERVAL 14 DAY, 'cancelled', NULL),
  (2, 4, 3,  CURDATE() - INTERVAL 21 DAY, 'confirmed', NULL);

-- ─────────────────────────────────────────────────────────────────────────────
-- cancellations  (for every reservation with status='cancelled')
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO cancellations (reservation_id, cancelled_by, reason, refund_eligible)
SELECT
    r.reservation_id,
    r.user_id,
    ELT(FLOOR(1 + RAND() * 4),
        'Schedule conflict',
        'Room no longer needed',
        'Event rescheduled',
        'Personal reasons'),
    IF(TIMEDIFF(
        TIMESTAMP(r.reservation_date, ts.start_time),
        NOW()
    ) > '02:00:00', 1, 0)
FROM reservations r
JOIN time_slots ts ON ts.slot_id = r.slot_id
WHERE r.status = 'cancelled';

-- ─────────────────────────────────────────────────────────────────────────────
-- error_logs  (sample technical errors)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO error_logs (user_id, reservation_id, error_code, error_message, endpoint, http_method, severity, environment) VALUES
  (2,    NULL, 'BOOKING_CONFLICT',  'Slot already reserved: room_id=1, slot_id=2, date=' || CURDATE(),             '/api/v1/reservations',          'POST',   'ERROR', 'production'),
  (5,    NULL, 'VALIDATION_ERROR',  'reservation_date must be a future date',                                      '/api/v1/reservations',          'POST',   'WARN',  'production'),
  (NULL, NULL, 'DB_TIMEOUT',        'Query exceeded 5000ms threshold on table api_request_logs',                   '/api/v1/analytics/utilization', 'GET',    'FATAL', 'production'),
  (1,    NULL, 'AUTH_EXPIRED',      'JWT token expired for user_id=1',                                            '/api/v1/reservations',          'GET',    'WARN',  'production'),
  (3,    NULL, 'ROOM_INACTIVE',     'Attempted booking on inactive room_id=7',                                    '/api/v1/reservations',          'POST',   'ERROR', 'production'),
  (NULL, NULL, 'SNAPSHOT_FAIL',     'Daily snapshot procedure sp_refresh_daily_snapshot returned error code 1',   '/internal/cron/snapshot',        NULL,     'ERROR', 'production'),
  (7,    NULL, 'RATE_LIMIT',        'Too many requests: user_id=7 exceeded 60 req/min threshold',                 '/api/v1/reservations',          'POST',   'WARN',  'production'),
  (NULL, NULL, 'CONNECTION_POOL',   'SQLAlchemy pool exhausted: all 20 connections in use',                       '/api/v1/rooms/availability',    'GET',    'FATAL', 'production');

-- ─────────────────────────────────────────────────────────────────────────────
-- api_request_logs  (sample latency data)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO api_request_logs (user_id, method, endpoint, status_code, latency_ms, request_size_bytes, response_size_bytes, ip_address) VALUES
  (1,    'GET',    '/api/v1/rooms',             200,  45,   NULL, 2048,  '192.168.1.10'),
  (1,    'GET',    '/api/v1/rooms/availability',200,  88,   NULL, 4096,  '192.168.1.10'),
  (1,    'POST',   '/api/v1/reservations',      201, 142,   512,  256,   '192.168.1.10'),
  (2,    'POST',   '/api/v1/reservations',      409, 210,   512,  128,   '192.168.1.11'),
  (3,    'GET',    '/api/v1/reservations',      200,  67,  NULL,  8192,  '192.168.1.12'),
  (3,    'DELETE', '/api/v1/reservations/3',    200,  95,  NULL,   64,   '192.168.1.12'),
  (4,    'GET',    '/api/v1/analytics/utilization', 200, 4320, NULL, 16384, '192.168.1.13'),
  (5,    'GET',    '/api/v1/rooms/availability',200,  73,  NULL,  4096,  '192.168.1.14'),
  (5,    'POST',   '/api/v1/reservations',      201, 155,   512,   256,  '192.168.1.14'),
  (NULL, 'GET',    '/api/v1/health',            200,   8,  NULL,    64,  '10.0.0.1'),
  (6,    'GET',    '/api/v1/rooms',             200,  41,  NULL,  2048,  '192.168.1.15'),
  (7,    'POST',   '/api/v1/reservations',      429,  22,   512,   128,  '192.168.1.16'),
  (8,    'GET',    '/api/v1/analytics/utilization', 200, 5100, NULL, 16384, '192.168.1.17'),
  (1,    'PATCH',  '/api/v1/reservations/1',    200, 188,   256,   256,  '192.168.1.10'),
  (2,    'GET',    '/api/v1/rooms/availability',200,  92,  NULL,  4096,  '192.168.1.11');

-- ─────────────────────────────────────────────────────────────────────────────
-- usage_snapshots  (last 7 days — normally populated by stored procedure)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO usage_snapshots
  (room_id, snapshot_date, booked_slots, cancelled_slots, no_show_slots, utilization_pct, avg_latency_ms, total_api_requests, error_count)
VALUES
  (1, CURDATE()-7, 8, 1, 0,  72.73, 112, 340, 2),
  (2, CURDATE()-7, 6, 2, 1,  54.55, 118, 340, 2),
  (3, CURDATE()-7, 9, 0, 0,  81.82, 112, 340, 2),
  (4, CURDATE()-7, 5, 1, 1,  45.45, 112, 340, 2),
  (5, CURDATE()-7, 10, 0, 0, 90.91, 112, 340, 2),
  (6, CURDATE()-7, 7, 1, 0,  63.64, 112, 340, 2),
  (1, CURDATE()-6, 7, 2, 0,  63.64, 105, 310, 1),
  (2, CURDATE()-6, 9, 0, 0,  81.82, 105, 310, 1),
  (3, CURDATE()-6, 6, 1, 1,  54.55, 105, 310, 1),
  (4, CURDATE()-6, 4, 3, 0,  36.36, 105, 310, 1),
  (5, CURDATE()-6, 11, 0, 0,100.00, 105, 310, 1),
  (6, CURDATE()-6, 8, 0, 1,  72.73, 105, 310, 1),
  (1, CURDATE()-5, 9, 0, 0,  81.82, 98,  295, 0),
  (2, CURDATE()-5, 7, 1, 0,  63.64, 98,  295, 0),
  (3, CURDATE()-5, 10, 1, 0, 90.91, 98,  295, 0),
  (4, CURDATE()-5, 6, 0, 2,  54.55, 98,  295, 0),
  (5, CURDATE()-5, 9, 2, 0,  81.82, 98,  295, 0),
  (6, CURDATE()-5, 5, 2, 1,  45.45, 98,  295, 0),
  (1, CURDATE()-1, 10, 1, 0, 90.91, 134, 420, 3),
  (2, CURDATE()-1, 8, 0, 0,  72.73, 134, 420, 3),
  (3, CURDATE()-1, 11, 0, 0,100.00, 134, 420, 3),
  (4, CURDATE()-1, 7, 2, 1,  63.64, 134, 420, 3),
  (5, CURDATE()-1, 9, 0, 0,  81.82, 134, 420, 3),
  (6, CURDATE()-1, 6, 1, 0,  54.55, 134, 420, 3);
