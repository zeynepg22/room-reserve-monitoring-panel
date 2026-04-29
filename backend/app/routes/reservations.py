from fastapi import APIRouter

router = APIRouter(prefix="/reservations", tags=["Reservations"])

@router.post("/")
def create():
    return {"message": "Reservation Created"}

@router.delete("/{reservation_id}")
def cancel(reservation_id: int):
    return {"message": f"Reservation {reservation_id} Cancelled"}