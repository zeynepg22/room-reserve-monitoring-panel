import time
from typing import Any, Dict, List, Optional

api_request_logs: List[Dict[str, Any]] = []
error_logs: List[Dict[str, Any]] = []

_req_counter = 0
_log_counter = 0


def add_request_log(method: str, endpoint: str, status_code: int, latency_ms: float) -> None:
    global _req_counter
    _req_counter += 1
    api_request_logs.append({
        "req_id": _req_counter,
        "method": method,
        "endpoint": endpoint,
        "status_code": status_code,
        "latency_ms": round(latency_ms, 2),
        "requested_at": time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime()),
    })


def add_error_log(
    error_code: str,
    error_message: str,
    endpoint: str,
    http_method: str,
    severity: str = "ERROR",
    user_id: Optional[int] = None,
    reservation_id: Optional[int] = None,
) -> None:
    global _log_counter
    _log_counter += 1
    error_logs.append({
        "log_id": _log_counter,
        "error_code": error_code,
        "error_message": error_message,
        "endpoint": endpoint,
        "http_method": http_method,
        "severity": severity,
        "user_id": user_id,
        "reservation_id": reservation_id,
        "logged_at": time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime()),
    })
