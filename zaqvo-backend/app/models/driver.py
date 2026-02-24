from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field, ConfigDict, field_validator

from app.schemas.common import NameStr, NonEmptyStr


class DriverStatus(str, Enum):
    AVAILABLE = "available"
    BUSY = "busy"
    OFFLINE = "offline"
    BLOCKED = "blocked"


class DriverBase(BaseModel):
    """Shared driver fields."""

    name: NameStr
    photo: str = Field(..., description="URL of profile photo")
    mobile_number: NonEmptyStr
    otp_verified: bool = False
    license_number: str
    vehicle_type: str
    vehicle_number: str
    status: DriverStatus = DriverStatus.OFFLINE
    is_verified: bool = False
    is_active: bool = True
    rating: float = 0.0
    total_deliveries: int = 0

    @field_validator("mobile_number")
    @classmethod
    def normalize_mobile(cls, v: str) -> str:
        return v.strip()


class DriverInDB(DriverBase):
    """Driver document as stored in MongoDB."""

    model_config = ConfigDict(populate_by_name=True)

    id: Optional[str] = Field(alias="_id", default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_online: Optional[datetime] = None


class DriverCreate(BaseModel):
    """Payload for creating a driver during signup."""

    name: NameStr
    photo: str
    mobile_number: NonEmptyStr
    license_number: str
    vehicle_type: str
    vehicle_number: str

    @field_validator("mobile_number")
    @classmethod
    def normalize_mobile(cls, v: str) -> str:
        return v.strip()


class DriverResponse(DriverBase):
    """Response model returned to client."""

    model_config = ConfigDict(populate_by_name=True)

    id: str
    created_at: datetime
    last_online: Optional[datetime] = None

