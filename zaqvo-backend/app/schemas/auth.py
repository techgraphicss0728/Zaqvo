from typing import Literal

from pydantic import BaseModel, Field, field_validator

from app.schemas.common import NonEmptyStr
from app.models.customer import CustomerCreate
from app.models.driver import DriverCreate
from app.models.admin import AdminCreate


RoleLiteral = Literal["customer", "driver", "admin"]


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = Field(default="bearer", description="Token type")


class AdminAuthUser(BaseModel):
    id: str
    name: str
    mobile_number: str
    is_super_admin: bool
    role_id: str | None = None
    role_slug: str | None = None
    role_name: str | None = None
    permissions: dict = Field(default_factory=dict)


class AdminAuthResponse(TokenResponse):
    admin: AdminAuthUser


class RefreshTokenRequest(BaseModel):
    """Send the refresh_token from the last login/signup or refresh response."""

    refresh_token: NonEmptyStr | None = None

    @field_validator("refresh_token")
    @classmethod
    def strip_refresh(cls, v: str | None) -> str | None:
        if v is None:
            return None
        return v.strip()


class OTPRequestBase(BaseModel):
    mobile_number: NonEmptyStr

    @field_validator("mobile_number")
    @classmethod
    def normalize_mobile(cls, v: str) -> str:
        return v.strip()


class CustomerSignupRequest(OTPRequestBase, CustomerCreate):
    """Customer signup body: includes profile + mobile for OTP."""


class DriverSignupRequest(OTPRequestBase, DriverCreate):
    """Driver signup body: includes profile + mobile for OTP."""


class AdminSignupRequest(OTPRequestBase, AdminCreate):
    """Admin signup body: includes profile + mobile for OTP."""


class AdminRegisterRequest(BaseModel):
    name: NonEmptyStr
    mobile_number: NonEmptyStr
    password: NonEmptyStr = Field(min_length=6, max_length=128)
    is_super_admin: bool = False
    super_admin_setup_key: NonEmptyStr | None = None

    @field_validator("name", "mobile_number", "password", "super_admin_setup_key")
    @classmethod
    def normalize_str(cls, v: str | None) -> str | None:
        if v is None:
            return None
        return v.strip()


class AdminLoginRequest(BaseModel):
    mobile_number: NonEmptyStr
    password: NonEmptyStr = Field(min_length=6, max_length=128)

    @field_validator("mobile_number", "password")
    @classmethod
    def normalize_str(cls, v: str) -> str:
        return v.strip()


class OTPVerifyRequest(BaseModel):
    mobile_number: NonEmptyStr
    otp: NonEmptyStr

    @field_validator("mobile_number")
    @classmethod
    def normalize_mobile(cls, v: str) -> str:
        return v.strip()

    @field_validator("otp")
    @classmethod
    def normalize_otp(cls, v: str) -> str:
        return v.strip()


class LoginOTPRequest(BaseModel):
    mobile_number: NonEmptyStr

    @field_validator("mobile_number")
    @classmethod
    def normalize_mobile(cls, v: str) -> str:
        return v.strip()


class OtpMessageResponse(BaseModel):
    """Standard API response after an OTP has been sent."""

    message: str = Field(default="OTP sent to mobile number")
    dev_mode: bool = Field(
        default=False,
        description="True when SMS was skipped in development (OTP only in server logs / DB)",
    )

