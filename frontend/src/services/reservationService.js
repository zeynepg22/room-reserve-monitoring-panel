import { rooms, reservations } from "../data/mockData";

export const getRooms = () => {
  return rooms;
};

export const getReservations = () => {
  return reservations;
};

export const createReservation = (newReservation) => {
  return {
    id: Date.now(),
    ...newReservation,
    status: "Active"
  };
};

export const cancelReservation = (id, list) => {
  return list.map((r) =>
    r.id === id ? { ...r, status: "Cancelled" } : r
  );
};