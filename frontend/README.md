# 🚀 RoomReserve Frontend

A modern React-based frontend for a **Room Reservation and Monitoring Panel**.  
Built with Vite and integrated with a FastAPI backend.

---

## 📌 Overview

This frontend converts static UI into a dynamic system using:

- React state management
- API integration
- Reservation logic
- Real-time UI updates

---

## ✨ Features

| Feature | Description |
|--------|------------|
| 🔐 Login Validation | Prevents empty login |
| 🏢 Room Listing | Fetches rooms from backend |
| 📅 Reservation Flow | Room → Date → Slot selection |
| ⛔ Slot Control | Only available slots are selectable |
| ⚠️ Double Booking | Backend conflict handled (409 error) |
| ➕ Create Reservation | API-based reservation creation |
| ❌ Cancel Reservation | Updates reservation status |
| 📊 Dashboard | Real-time statistics |
| ⚡ Dynamic UI | Instant updates with React state |

---

## 🧱 Tech Stack

| Layer | Technology |
|------|----------|
| Frontend | React |
| Build Tool | Vite |
| Language | JavaScript (ES6+) |
| Styling | CSS-in-JS |
| API | Fetch API |

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

| Scenario| Behavior|
|-----------|-----------|
Empty login | 	Blocked | 
No date | 	Blocked | 
No slot	|  Blocked | 
Reserved slot | 	Disabled | 
Double booking | 	Error shown | 
API error	|  User notified | 

## 🎨 UI Behavior
- Available → Green
- Reserved → Red
- Cleaning → Yellow
- Selected slot → Highlighted
- Disabled buttons → Not clickable
- Cancelled reservation → Button disabled

### Running the Project

Install dependencies:
```bash
npm install
```
Start frontend:
```bash
npm run dev
```
Open:
```bash
http://localhost:5173
```

### Running with Backend
```bash
cd ../backend
PYTHONPATH=. uvicorn app.main:app --reload
```
Then:
```bash
cd ../frontend
npm run dev
```