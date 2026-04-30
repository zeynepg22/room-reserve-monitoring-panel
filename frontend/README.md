# 🚀 RoomReserve Frontend

A modern React-based frontend for a **Room Reservation and Monitoring Panel**.  
Built with **React + Vite** and integrated with a **FastAPI backend**.

---

## 📌 Overview

This frontend converts static UI screens into an interactive reservation system using:

- React state management
- API integration
- Reservation creation and cancellation logic
- Input validation and user feedback
- Real-time UI updates

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 Login Validation | Prevents login with empty email or password fields |
| 🏢 Room Listing | Fetches room data from the backend API |
| 📅 Reservation Flow | Allows users to select a room, date, and available time slot |
| ⛔ Slot Control | Disables unavailable or reserved slots |
| ⚠️ Double Booking Handling | Displays backend conflict errors when the same slot is reserved twice |
| ➕ Create Reservation | Sends reservation data to the backend API |
| ❌ Cancel Reservation | Cancels reservations and updates the UI status |
| 📊 Dashboard Metrics | Displays reservation count, usage rate, and cancellation data |
| ⚡ Dynamic UI Updates | Updates the interface instantly using React state |

---

## 🧱 Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React |
| Build Tool | Vite |
| Language | JavaScript |
| Styling | CSS-in-JS |
| API Communication | Fetch API |
| Backend Integration | FastAPI |

---

## 📁 Project Structure

```text
frontend/
├── public/
├── src/
│   ├── App.jsx
│   ├── main.jsx
│   ├── services/
│   │   └── reservationService.js
│   ├── data/
│   └── assets/
├── package.json
├── vite.config.js
└── README.md
```

---

## 🔌 API Integration

The frontend communicates with the backend using the following endpoints:

| Method | Endpoint | Description |
|---|---|---|
| GET | `/rooms/` | Fetch room list |
| GET | `/reservations/` | Fetch reservation list |
| POST | `/reservations/` | Create a new reservation |
| DELETE | `/reservations/{id}` | Cancel an existing reservation |
| GET | `/analytics/` | Fetch dashboard-related metrics |

**Base URL**

```text
http://127.0.0.1:8000
```

---

## 🔄 Application Flow

1. User logs in.
2. Empty login fields are blocked with a validation message.
3. Rooms are loaded dynamically from the backend.
4. User selects an available room.
5. User selects a reservation date.
6. User selects an available time slot.
7. Reservation request is sent to the backend.
8. Backend checks double-booking conflicts.
9. Successful reservation is added to **My Reservations**.
10. Conflict or validation errors are shown to the user.
11. User can cancel an active reservation.

---

## ⚠️ Validation & Error Handling

| Scenario | Behavior |
|---|---|
| Empty login | Login is blocked and an error message is displayed |
| No date selected | Reservation is blocked |
| No slot selected | Reservation is blocked |
| Reserved slot selected | Slot is disabled |
| Double booking attempt | Backend returns conflict error and UI displays message |
| API error | User is notified through UI feedback |

---

## 🧠 State Management

The application uses React hooks for state and data flow:

| Hook | Purpose |
|---|---|
| `useState` | Stores active page, login state, rooms, reservations, selected room, selected slot, and form values |
| `useEffect` | Fetches room and reservation data from the backend when the app loads |

Derived dashboard values include:

- Total reservations
- Active reservations
- Cancelled reservations
- Room usage rate

---

## 🎨 UI Behavior

| Status | Visual Behavior |
|---|---|
| Available | Green slot/card styling |
| Reserved | Red disabled slot |
| Cleaning | Yellow disabled slot |
| Selected slot | Highlighted with border |
| Disabled buttons | Not clickable |
| Cancelled reservation | Cancel button becomes disabled |

---

## ▶️ Running the Project

Install dependencies:

```bash
npm install
```

Start the frontend development server:

```bash
npm run dev
```

Open the application:

```text
http://localhost:5173
```

---

## 🔗 Running with Backend

Start the backend first:

```bash
cd ../backend
PYTHONPATH=. uvicorn app.main:app --reload
```

Then start the frontend:

```bash
cd ../frontend
npm run dev
```

---

## 📝 Notes

- The frontend is integrated with the backend API.
- Room data is fetched from the backend.
- Reservation creation and cancellation are handled through API requests.
- Double booking errors are handled and displayed to the user.
- The UI is structured to support maintainability and future extension.