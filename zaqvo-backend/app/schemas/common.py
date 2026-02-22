"""Common field validators and constraints for reuse across schemas."""
import re
from typing import Annotated, Generic, TypeVar

from pydantic import BaseModel, Field

# Password: min 8, max 128, at least one letter and one digit
PASSWORD_MIN_LEN = 8
PASSWORD_MAX_LEN = 128
PASSWORD_PATTERN = re.compile(r"^(?=.*[A-Za-z])(?=.*\d).+$")


def password_validator(v: str) -> str:
    if len(v) < PASSWORD_MIN_LEN:
        raise ValueError(f"Password must be at least {PASSWORD_MIN_LEN} characters")
    if len(v) > PASSWORD_MAX_LEN:
        raise ValueError(f"Password must be at most {PASSWORD_MAX_LEN} characters")
    if not PASSWORD_PATTERN.match(v):
        raise ValueError("Password must contain at least one letter and one digit")
    return v


# Annotated types for consistent use
PasswordStr = Annotated[
    str,
    Field(min_length=PASSWORD_MIN_LEN, max_length=PASSWORD_MAX_LEN),
]
NameStr = Annotated[str, Field(min_length=1, max_length=255)]
NonEmptyStr = Annotated[str, Field(min_length=1)]


T = TypeVar("T")


class PaginatedResponse(BaseModel, Generic[T]):
    """Generic paginated list response with validation."""

    items: list[T]
    total: int = Field(..., ge=0)
    page: int = Field(..., ge=1)
    limit: int = Field(..., ge=1, le=100)
    pages: int = Field(..., ge=0)
