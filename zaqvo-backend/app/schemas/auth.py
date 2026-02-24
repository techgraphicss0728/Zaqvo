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

