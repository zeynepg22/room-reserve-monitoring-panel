from fastapi import APIRouter

router = APIRouter(prefix="/analytics", tags=["Analytics"])

@router.get("/")
def stats():
    return {
        "utilization_rate": "72%",
        "error_rate": "0.4%",
        "latency": "320ms"
    }