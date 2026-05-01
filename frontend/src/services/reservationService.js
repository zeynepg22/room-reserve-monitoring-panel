const API_BASE_URL = "http://127.0.0.1:8001";

const fallbackReservations = [
  {
    id: 1,
    room: "Study Room A",
    room_id: 1,
    userName: "Demo User",
    date: "2026-05-01",
    time: "09:00 - 10:00",
    purpose: "Team Meeting",
    status: "Confirmed",
  },
];

export const getRooms = async () => {
  const response = await fetch(`${API_BASE_URL}/rooms/`);
  const data = await response.json();

  return data.rooms.map((roomName, index) => ({
    id: index + 1,
    name: roomName,
    capacity: index === 0 ? 4 : index === 1 ? 8 : 20,
    equipment:
      index === 0
        ? "Whiteboard"
        : index === 1
        ? "TV Screen, Whiteboard"
        : "Projector, Sound System",
    status: index === 1 ? "Reserved" : "Available",
  }));
};

export const getReservations = async () => {
  try {
    const response = await fetch(`${API_BASE_URL}/reservations/`);

    if (!response.ok) {
      return fallbackReservations;
    }

    const data = await response.json();
    return data.reservations || fallbackReservations;
  } catch {
    return fallbackReservations;
  }
};

export const createReservation = async (newReservation) => {
  const response = await fetch(`${API_BASE_URL}/reservations/`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(newReservation),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.detail || "Reservation could not be created.");
  }

  return data.reservation || data;
};

export const cancelReservation = async (id) => {
  const response = await fetch(`${API_BASE_URL}/reservations/${id}`, {
    method: "DELETE",
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.detail || "Reservation could not be cancelled.");
  }

  return data.reservation || data;
};

export const getHealthStats = async () => {
  try {
    const res = await fetch(`${API_BASE_URL}/analytics/health`);
    return await res.json();
  } catch {
    return { status: "UNKNOWN", total_requests: 0, avg_latency_ms: 0, error_log_count: 0, recent_error_count: 0 };
  }
};

export const getLatencyStats = async () => {
  try {
    const res = await fetch(`${API_BASE_URL}/analytics/latency`);
    return await res.json();
  } catch {
    return { p50: 0, p95: 0, p99: 0, avg: 0, total_requests: 0 };
  }
};

export const getErrorStats = async () => {
  try {
    const res = await fetch(`${API_BASE_URL}/analytics/errors`);
    return await res.json();
  } catch {
    return { total_requests: 0, total_errors: 0, error_rate_pct: 0, by_endpoint: [], recent_errors: [] };
  }
};

export const getFailedBookings = async () => {
  try {
    const res = await fetch(`${API_BASE_URL}/analytics/failed-bookings`);
    return await res.json();
  } catch {
    return { total_conflicts: 0, conflicts: [] };
  }
};