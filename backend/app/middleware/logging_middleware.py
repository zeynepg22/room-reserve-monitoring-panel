import time
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from app.log_store import add_error_log, add_request_log


class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start = time.time()
        try:
            response = await call_next(request)
            latency_ms = (time.time() - start) * 1000
            add_request_log(request.method, request.url.path, response.status_code, latency_ms)
            if response.status_code >= 500:
                add_error_log(
                    error_code=f"HTTP_{response.status_code}",
                    error_message=f"{request.method} {request.url.path} returned {response.status_code}",
                    endpoint=request.url.path,
                    http_method=request.method,
                    severity="FATAL",
                )
            return response
        except Exception as exc:
            latency_ms = (time.time() - start) * 1000
            add_request_log(request.method, request.url.path, 500, latency_ms)
            add_error_log(
                error_code="UNHANDLED_EXCEPTION",
                error_message=str(exc),
                endpoint=request.url.path,
                http_method=request.method,
                severity="FATAL",
            )
            raise
