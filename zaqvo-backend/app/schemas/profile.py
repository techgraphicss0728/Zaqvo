"""Authenticated user profile responses."""
from typing import Any, Literal

from pydantic import BaseModel, Field


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
