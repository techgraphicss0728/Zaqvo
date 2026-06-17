"""Request helpers. JWT validation runs in AuthMiddleware; routes use request.state.user."""
from typing import Literal

from fastapi import HTTPException, Request, status


def get_request_user(request: Request) -> dict:
    """User dict from AuthMiddleware (sub, role, payload)."""
    user = getattr(request.state, "user", None)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    return user


def ensure_role(user: dict, expected: Literal["customer", "driver", "admin"]) -> None:
    if user.get("role") != expected:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden for this role")


def ensure_super_admin(user: dict) -> None:
    if user.get("role") != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin role required")
    payload = user.get("payload") or {}
    if not bool(payload.get("is_super_admin", False)):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Super admin access required")
