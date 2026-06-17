"""Admin user management schemas (super admin provisions dashboard users)."""
from datetime import datetime

from pydantic import BaseModel, Field, field_validator

from app.schemas.common import NameStr, NonEmptyStr


class AdminUserSummaryResponse(BaseModel):
    id: str
    name: str
    mobile_number: str
    role_id: str | None = None
    role_slug: str | None = None
    role_name: str | None = None
    is_super_admin: bool = False
    is_active: bool = True
    otp_verified: bool = False
    last_login: datetime | None = None
    created_at: datetime
    updated_at: datetime


class AdminUserListResponse(BaseModel):
    items: list[AdminUserSummaryResponse]
    page: int
    limit: int
    total: int
    pages: int


class AdminUserCreateSendOtpRequest(BaseModel):
    name: NameStr
    mobile_number: NonEmptyStr
    role_id: NonEmptyStr

    @field_validator("mobile_number", "role_id")
    @classmethod
    def strip_fields(cls, v: str) -> str:
        return v.strip()


class AdminUserCreateVerifyOtpRequest(BaseModel):
    mobile_number: NonEmptyStr
    otp: NonEmptyStr

    @field_validator("mobile_number")
    @classmethod
    def strip_mobile(cls, v: str) -> str:
        return v.strip()

    @field_validator("otp")
    @classmethod
    def strip_otp(cls, v: str) -> str:
        return v.strip()


class AdminUserUpdateRequest(BaseModel):
    name: NameStr | None = None
    role_id: NonEmptyStr | None = None

    @field_validator("name", "role_id")
    @classmethod
    def strip_optional(cls, v: str | None) -> str | None:
        if v is None:
            return None
        return v.strip()


class AdminUserStatusRequest(BaseModel):
    is_active: bool
