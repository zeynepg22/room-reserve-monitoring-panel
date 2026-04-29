from pydantic import BaseModel
from datetime import date

class ReservationCreate(BaseModel):
    user_id: int
    room_id: int
    slot_id: int
    reservation_date: date