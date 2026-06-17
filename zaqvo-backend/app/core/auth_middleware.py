"""JWT authentication and role authorization before route handlers run."""
from typing import Literal

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse

from app.core.config import settings
from app.core.security import decode_token

Role = Literal["admin", "customer", "driver"]


def _is_public_path(path: str) -> bool:
    if path in ("/health", "/ready"):
        return True
    if path.startswith("/docs") or path.startswith("/redoc"):
        return True
    if path.endswith("/openapi.json"):
        return True
    if path.startswith("/api/v1/auth"):
        return True
    if path.startswith("/api/v1/health"):
        return True
    return False


def _required_role_for_api_path(path: str) -> Role | Literal["any"]:
    if path.startswith("/api/v1/admin"):
        return "admin"
    if path.startswith("/api/v1/customer"):
        return "customer"
    if path.startswith("/api/v1/driver"):
        return "driver"
    if path.startswith("/api/v1/users"):
        return "any"
    return "any"


class AuthMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        if request.method == "OPTIONS":
            return await call_next(request)

        path = request.url.path

        if _is_public_path(path):
            return await call_next(request)

        if not path.startswith("/api/v1/"):
            return await call_next(request)

        required = _required_role_for_api_path(path)

        auth_header = request.headers.get("authorization")
        token = ""
        if auth_header and auth_header.lower().startswith("bearer "):
            token = auth_header.split(" ", 1)[1].strip()
        elif request.cookies.get(settings.AUTH_ACCESS_COOKIE_NAME):
            token = request.cookies.get(settings.AUTH_ACCESS_COOKIE_NAME, "").strip()

        if not token:
            return JSONResponse(status_code=401, content={"detail": "Not authenticated"})

        payload = decode_token(token)
        if not payload or payload.get("type") != "access":
            return JSONResponse(
                status_code=401,
                content={"detail": "Invalid or expired token"},
            )

        role = payload.get("role")
        if role not in ("admin", "customer", "driver"):
            return JSONResponse(
                status_code=401,
                content={"detail": "Invalid token payload"},
            )

        if required != "any" and role != required:
            return JSONResponse(
                status_code=403,
                content={"detail": "Forbidden for this role"},
            )

        request.state.user = {
            "sub": payload.get("sub"),
            "role": role,
            "payload": payload,
        }
        return await call_next(request)
