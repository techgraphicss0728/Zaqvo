from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field, ConfigDict, field_validator

from app.schemas.common import NameStr, NonEmptyStr


class CustomerBase(BaseModel):
    """Shared customer fields."""

    name: NameStr
    photo: Optional[str] = Field(default=None, description="URL of profile photo")
    mobile_number: NonEmptyStr
    otp_verified: bool = False
    is_active: bool = True
    address_id: Optional[str] = None

    @field_validator("mobile_number")
    @classmethod
    def normalize_mobile(cls, v: str) -> str:
        return v.strip()


class CustomerInDB(CustomerBase):
    """Customer document as stored in MongoDB."""

    model_config = ConfigDict(populate_by_name=True)

    id: Optional[str] = Field(alias="_id", default=None)
    password_hash: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class CustomerCreate(BaseModel):
    """Payload for creating a customer during signup."""

    name: NameStr
    mobile_number: NonEmptyStr
    photo: Optional[str] = None

    @field_validator("mobile_number")
    @classmethod
    def normalize_mobile(cls, v: str) -> str:
        return v.strip()


class CustomerResponse(CustomerBase):
    """Response model returned to client."""

    model_config = ConfigDict(populate_by_name=True)

    id: str
    created_at: datetime
    updated_at: datetime

