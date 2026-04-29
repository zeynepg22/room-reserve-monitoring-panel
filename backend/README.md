# RoomReserve Backend Service

FastAPI-based backend service developed for the RoomReserve Monitoring Panel to support room reservation management, technical monitoring, and business logic validation.

## Overview

This backend acts as the communication layer between:

- React Frontend
- MySQL Database Layer
- Monitoring Dashboard

It provides API endpoints for reservation workflows, analytics access, and conflict prevention.

---

## Core Backend Functions

### Room Management
- View available study rooms and meeting rooms
- Support room availability queries

Endpoint:
GET /rooms/

---

## Reservation Management
Supports:

- Create reservation
- Cancel reservation
- Reservation validation
- Double-booking prevention

Endpoints:

POST /reservations/

DELETE /reservations/{reservation_id}

---

## Double Booking Prevention Logic

The backend prevents two active reservations for:

- Same room
- Same date
- Same time slot

If a duplicate booking is attempted:

- HTTP 409 Conflict is returned

Example conflict response:

```json
{
  "detail": "Double booking conflict: this room is already reserved for the selected time slot."
}
```

---

## Analytics API

Provides monitoring-related metrics such as:

- Utilization Rate
- Cancellation Rate
- API Latency (P95 target)
- Error Rate

Endpoint:

GET /analytics/

---

## Technical Stack

- Python
- FastAPI
- Uvicorn
- Pydantic
- MySQL-ready integration

---

## Backend Architecture

Frontend (React)
↓
FastAPI Backend
↓
MySQL Database
↓
Monitoring Metrics

---

## Validation and Testing

Validated using Swagger API documentation:

http://127.0.0.1:8000/docs

Tested Scenarios:

✔ Successful reservation creation  
✔ Duplicate reservation conflict (409)  
✔ Room listing response  
✔ Analytics endpoint response

---

## Backend Deliverables Completed

✔ API Endpoint Structure  
✔ Business Logic Layer  
✔ Reservation Conflict Prevention  
✔ Schema Validation Layer  
✔ Database Configuration Layer  
✔ Monitoring Support Endpoints