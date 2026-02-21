"""User schemas with Pydantic validations."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, EmailStr, Field, field_validator

from app.schemas.common import password_validator, PasswordStr

RoleLiteral = Literal["customer", "delivery", "admin"]


class UserBase(BaseModel):
    email: EmailStr
    full_name: str | None = Field(default=None, max_length=255)
    role: RoleLiteral = "customer"

    @field_validator("full_name")
    @classmethod
    def strip_full_name(cls, v: str | None) -> str | None:
        if v is None or v == "":
            return None
        return v.strip() or None


class UserCreate(UserBase):
    password: PasswordStr

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        return password_validator(v)


class UserUpdate(BaseModel):
    full_name: str | None = Field(default=None, max_length=255)
    role: RoleLiteral | None = None

    @field_validator("full_name")
    @classmethod
    def strip_full_name(cls, v: str | None) -> str | None:
        if v is None or v == "":
            return None
        return v.strip() or None


class UserInDB(UserBase):
    id: str
    hashed_password: str
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class UserResponse(UserBase):
    id: str
    created_at: datetime

    model_config = {"from_attributes": True}
