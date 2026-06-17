from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field, ConfigDict, field_validator

from app.schemas.common import NameStr, NonEmptyStr


class AdminBase(BaseModel):
    """Shared admin fields."""

    name: NameStr
    mobile_number: NonEmptyStr
    otp_verified: bool = False
    is_super_admin: bool = False
    is_active: bool = True
    role_id: str | None = None
    role_slug: str | None = None
    role_name: str | None = None

    @field_validator("mobile_number")
    @classmethod
    def normalize_mobile(cls, v: str) -> str:
        return v.strip()


class AdminInDB(AdminBase):
    """Admin document as stored in MongoDB."""

    model_config = ConfigDict(populate_by_name=True)

    id: Optional[str] = Field(alias="_id", default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    last_login: Optional[datetime] = None
    password_hash: Optional[str] = None


class AdminCreate(BaseModel):
    """Payload for creating an admin during signup."""

    name: NameStr
    mobile_number: NonEmptyStr

    @field_validator("mobile_number")
    @classmethod
    def normalize_mobile(cls, v: str) -> str:
        return v.strip()


class AdminResponse(AdminBase):
    """Response model returned to client."""

    model_config = ConfigDict(populate_by_name=True)

    id: str
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime] = None
    created_by: Optional[str] = None

