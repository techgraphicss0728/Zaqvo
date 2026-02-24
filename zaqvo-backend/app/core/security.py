"""JWT and password hashing."""
from datetime import datetime, timedelta
from typing import Any, Literal, TypedDict

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings


class TokenPayload(TypedDict, total=False):
    """Typed JWT payload for access and refresh tokens."""

    exp: int
    sub: str
    type: Literal["access", "refresh"]
    role: Literal["customer", "driver", "admin"]

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(
    subject: str | Any,
    *,
    role: Literal["customer", "driver", "admin"],
    expires_delta: timedelta | None = None,
) -> str:
    if expires_delta is None:
        expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    expire = datetime.utcnow() + expires_delta
    to_encode: TokenPayload = {
        "exp": int(expire.timestamp()),
        "sub": str(subject),
        "type": "access",
        "role": role,
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def create_refresh_token(
    subject: str | Any,
    *,
    role: Literal["customer", "driver", "admin"],
) -> str:
    expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode: TokenPayload = {
        "exp": int(expire.timestamp()),
        "sub": str(subject),
        "type": "refresh",
        "role": role,
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def decode_token(token: str) -> dict | None:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
    except JWTError:
        return None
