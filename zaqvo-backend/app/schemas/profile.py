"""Authenticated user profile responses."""
from typing import Any, Literal

from pydantic import BaseModel, Field, field_validator


class FcmTokenRequest(BaseModel):
    """Body for registering the logged-in user's FCM device token."""

    fcm_token: str = Field(..., min_length=1, max_length=4096)

    @field_validator("fcm_token")
    @classmethod
    def strip_token(cls, v: str) -> str:
        return v.strip()


class ProfileMeResponse(BaseModel):
    id: str
    role: Literal["customer", "driver", "admin"]
    name: str | None = None
    mobile_number: str | None = None
    is_super_admin: bool = False
    role_id: str | None = None
    role_slug: str | None = None
    role_name: str | None = None
    permissions: dict[str, Any] = Field(default_factory=dict)
