from fastapi import APIRouter
from app.log_store import api_request_logs, error_logs

router = APIRouter(prefix="/analytics", tags=["Analytics"])


def _percentile(sorted_data: list, pct: float) -> float:
    if not sorted_data:
        return 0.0
    k = (len(sorted_data) - 1) * pct / 100
    lo = int(k)
    hi = min(lo + 1, len(sorted_data) - 1)
    return round(sorted_data[lo] + (sorted_data[hi] - sorted_data[lo]) * (k - lo), 1)


@router.get("/")
def stats():
    total = len(api_request_logs)
    errors_count = sum(1 for r in api_request_logs if r["status_code"] >= 400)
    latencies = sorted(r["latency_ms"] for r in api_request_logs)
    p95 = _percentile(latencies, 95)
    error_rate = round(errors_count / total * 100, 2) if total > 0 else 0.0
    return {
        "utilization_rate": "72%",
        "error_rate": f"{error_rate}%",
        "latency": f"{p95}ms",
    }


@router.get("/latency")
def latency_stats():
    latencies = sorted(r["latency_ms"] for r in api_request_logs)
    if not latencies:
        return {"p50": 0, "p95": 0, "p99": 0, "avg": 0, "total_requests": 0}
    return {
        "p50": _percentile(latencies, 50),
        "p95": _percentile(latencies, 95),
        "p99": _percentile(latencies, 99),
        "avg": round(sum(latencies) / len(latencies), 1),
        "total_requests": len(latencies),
    }


@router.get("/errors")
def error_stats():
    total = len(api_request_logs)
    error_reqs = [r for r in api_request_logs if r["status_code"] >= 400]
    error_rate = round(len(error_reqs) / total * 100, 2) if total > 0 else 0.0

    by_endpoint: dict = {}
    for r in error_reqs:
        key = f"{r['method']} {r['endpoint']}"
        by_endpoint[key] = by_endpoint.get(key, 0) + 1

    return {
        "total_requests": total,
        "total_errors": len(error_reqs),
        "error_rate_pct": error_rate,
        "by_endpoint": [{"endpoint": k, "count": v} for k, v in by_endpoint.items()],
        "recent_errors": list(reversed(error_logs[-10:])),
    }


@router.get("/failed-bookings")
def failed_bookings():
    conflicts = [e for e in error_logs if e["error_code"] == "BOOKING_CONFLICT"]
    return {
        "total_conflicts": len(conflicts),
        "conflicts": list(reversed(conflicts[-20:])),
    }


@router.get("/health")
def health():
    recent = api_request_logs[-50:] if api_request_logs else []
    server_errors = [r for r in recent if r["status_code"] >= 500]

    if len(server_errors) > 5:
        status = "DEGRADED"
    elif len(server_errors) > 0:
        status = "WARNING"
    else:
        status = "HEALTHY"

    latencies = [r["latency_ms"] for r in recent]
    avg_latency = round(sum(latencies) / len(latencies), 1) if latencies else 0.0

    return {
        "status": status,
        "total_requests": len(api_request_logs),
        "recent_error_count": len(server_errors),
        "avg_latency_ms": avg_latency,
        "error_log_count": len(error_logs),
    }
