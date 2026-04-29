# RoomReserve Backend Service

FastAPI-based backend service for the RoomReserve Monitoring Panel, designed to manage room reservations, support monitoring dashboards, and integrate with the MySQL database layer.

## Overview
This backend provides REST API endpoints for:

- Viewing available rooms
- Creating reservations
- Cancelling reservations
- Serving analytics and monitoring metrics

It acts as the bridge between the React frontend and the MySQL database.

---

## Architecture

Frontend (React)
↓
Backend API (FastAPI)
↓
Database (MySQL)

---

## API Endpoints

### Rooms
- GET /rooms/
Returns available room data.

### Reservations
- POST /reservations/
Creates a reservation.

- DELETE /reservations/{reservation_id}
Cancels an existing reservation.

### Analytics
- GET /analytics/
Returns KPI and monitoring metrics such as:
- Utilization Rate
- Error Rate
- API Latency

---

## Example Response

### GET /rooms/

```json
{
  "rooms": [
    "Study Room A",
    "Meeting Room B",
    "Conference Room C"
  ]
}
```

---

## Tech Stack

- Python
- FastAPI
- Uvicorn
- MySQL (database integration ready)

---

## Monitoring KPIs Supported

- Room Utilization
- Reservation Success Rate
- Cancellation Rate
- API Response Latency

---

## Testing

Endpoints were validated using FastAPI Swagger documentation:

http://127.0.0.1:8000/docs

---

## Developer Notes

Current version includes:
- Working prototype endpoints
- Modular route structure
- Database-ready backend architecture