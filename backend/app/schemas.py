from pydantic import BaseModel

class ReservationCreate(BaseModel):
    user_id: int
    room_id: int
    slot_id: int