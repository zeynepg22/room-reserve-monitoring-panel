export const rooms = [
  {
    id: 1,
    name: "Meeting Room A",
    capacity: 10,
    equipment: "Projector, Whiteboard",
    status: "Available",
  },
  {
    id: 2,
    name: "Meeting Room B",
    capacity: 6,
    equipment: "TV Screen, Whiteboard",
    status: "Reserved",
  },
  {
    id: 3,
    name: "Study Room 1",
    capacity: 4,
    equipment: "Whiteboard",
    status: "Cleaning",
  },
  {
    id: 4,
    name: "Seminar Room",
    capacity: 20,
    equipment: "Projector, Sound System",
    status: "Available",
  },
];

export const reservations = [
  {
    id: 1,
    room: "Meeting Room A",
    roomId: 1,
    userName: "Demo User",
    date: "2026-06-28",
    time: "09:00 - 10:00",
    purpose: "Team Meeting",
    status: "Confirmed",
  },
];