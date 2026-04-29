from fastapi import APIRouter, HTTPException
from app.schemas import ReservationCreate

router = APIRouter(prefix="/reservations", tags=["Reservations"])

reserved_slots = []

@router.post("/")
def create_reservation(data: ReservationCreate):
    for reservation in reserved_slots:
        if (
            reservation["room_id"] == data.room_id
            and reservation["slot_id"] == data.slot_id
            and reservation["reservation_date"] == data.reservation_date
        ):
            raise HTTPException(
                status_code=409,
                detail="Double booking conflict: this room is already reserved for the selected time slot."
            )

    new_reservation = {
        "user_id": data.user_id,
        "room_id": data.room_id,
        "slot_id": data.slot_id,
        "reservation_date": data.reservation_date
    }

    reserved_slots.append(new_reservation)

    return {
        "message": "Reservation created successfully",
        "reservation": new_reservation
    }

@router.delete("/{reservation_id}")
def cancel_reservation(reservation_id: int):
    return {
        "message": f"Reservation {reservation_id} cancelled successfully"
    }