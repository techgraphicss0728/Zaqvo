"""HTTP-only auth cookie helpers for router layer (no business logic)."""
from fastapi import Response

from app.core.config import settings


def set_auth_cookies(response: Response, *, access_token: str, refresh_token: str) -> None:
    response.set_cookie(
        key=settings.AUTH_ACCESS_COOKIE_NAME,
        value=access_token,
        httponly=True,
        secure=settings.AUTH_COOKIE_SECURE,
        samesite=settings.AUTH_COOKIE_SAMESITE,
        max_age=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        path="/",
    )
    response.set_cookie(
        key=settings.AUTH_REFRESH_COOKIE_NAME,
        value=refresh_token,
        httponly=True,
        secure=settings.AUTH_COOKIE_SECURE,
        samesite=settings.AUTH_COOKIE_SAMESITE,
        max_age=settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 60 * 60,
        path="/",
    )


def clear_auth_cookies(response: Response) -> None:
    response.delete_cookie(key=settings.AUTH_ACCESS_COOKIE_NAME, path="/")
    response.delete_cookie(key=settings.AUTH_REFRESH_COOKIE_NAME, path="/")
