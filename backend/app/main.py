from fastapi import FastAPI

from app.routes.rooms import router as rooms_router
from app.routes.reservations import router as reservations_router
from app.routes.analytics import router as analytics_router

app = FastAPI(title="RoomReserve Backend")

app.include_router(rooms_router)
app.include_router(reservations_router)
app.include_router(analytics_router)

@app.get("/")
def home():
    return {"message": "Backend Running"}