"""Shared dependencies: auth, DB session, etc."""
from typing import Annotated, Literal

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from app.core.security import decode_token

security = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security)]
):
    if not credentials:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    payload = decode_token(credentials.credentials)
    if not payload or payload.get("type") != "access":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    return payload


async def get_current_user_optional(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security)]
):
    if not credentials:
        return None
    payload = decode_token(credentials.credentials)
    if not payload or payload.get("type") != "access":
        return None
    return payload


def _ensure_role(payload: dict, expected_role: Literal["customer", "driver", "admin"]) -> None:
    role = payload.get("role")
    if role != expected_role:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden for this role")


async def get_current_customer(
    payload: Annotated[dict, Depends(get_current_user)],
):
    _ensure_role(payload, "customer")
    return payload


async def get_current_driver(
    payload: Annotated[dict, Depends(get_current_user)],
):
    _ensure_role(payload, "driver")
    return payload


async def get_current_admin(
    payload: Annotated[dict, Depends(get_current_user)],
):
    _ensure_role(payload, "admin")
    return payload
