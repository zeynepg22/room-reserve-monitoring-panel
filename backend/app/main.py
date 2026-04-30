from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.rooms import router as rooms_router
from app.routes.reservations import router as reservations_router
from app.routes.analytics import router as analytics_router

app = FastAPI(title="RoomReserve Backend")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(rooms_router)
app.include_router(reservations_router)
app.include_router(analytics_router)

@app.get("/")
def home():
    return {"message": "Backend Running"}