from fastapi import APIRouter

router = APIRouter(prefix="/rooms", tags=["Rooms"])

@router.get("/")
def get_rooms():
    return {
        "rooms": [
            "Study Room A",
            "Meeting Room B",
            "Conference Room C"
        ]
    }