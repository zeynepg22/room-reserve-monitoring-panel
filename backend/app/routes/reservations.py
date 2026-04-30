from fastapi import APIRouter, HTTPException
from app.schemas import ReservationCreate

router = APIRouter(prefix="/reservations", tags=["Reservations"])

reserved_slots = []
reservation_id_counter = 1

room_names = {
    1: "Study Room A",
    2: "Meeting Room B",
    3: "Conference Room C"
}

slot_times = {
    1: "09:00 - 10:00",
    2: "10:00 - 11:00",
    3: "11:00 - 12:00",
    4: "13:00 - 14:00",
    5: "14:00 - 15:00",
    6: "15:00 - 16:00"
}


@router.get("/")
def get_reservations():
    return {"reservations": reserved_slots}


@router.post("/")
def create_reservation(data: ReservationCreate):
    global reservation_id_counter

    for reservation in reserved_slots:
        if (
            reservation["room_id"] == data.room_id
            and reservation["slot_id"] == data.slot_id
            and reservation["reservation_date"] == str(data.reservation_date)
            and reservation["status"] != "Cancelled"
        ):
            raise HTTPException(
                status_code=409,
                detail="Double booking conflict: this room is already reserved for the selected time slot."
            )

    new_reservation = {
        "id": reservation_id_counter,
        "user_id": data.user_id,
        "userName": f"User {data.user_id}",
        "room_id": data.room_id,
        "room": room_names.get(data.room_id, "Unknown Room"),
        "slot_id": data.slot_id,
        "time": slot_times.get(data.slot_id, "Unknown Time"),
        "reservation_date": str(data.reservation_date),
        "date": str(data.reservation_date),
        "purpose": "Meeting",
        "status": "Confirmed"
    }

    reserved_slots.append(new_reservation)
    reservation_id_counter += 1

    return new_reservation


@router.delete("/{reservation_id}")
def cancel_reservation(reservation_id: int):
    for reservation in reserved_slots:
        if reservation["id"] == reservation_id:
            reservation["status"] = "Cancelled"
            return {
                "message": f"Reservation {reservation_id} cancelled successfully",
                "reservation": reservation
            }

    raise HTTPException(status_code=404, detail="Reservation not found")