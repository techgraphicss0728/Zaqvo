"""Auth: login, refresh, register (placeholder)."""
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel, EmailStr, Field, field_validator

from app.core.limiter import limiter
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    decode_token,
)
from app.schemas.common import password_validator

router = APIRouter()


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=1, max_length=128)

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Password is required")
        return v


class RefreshRequest(BaseModel):
    refresh_token: str = Field(..., min_length=1)

    @field_validator("refresh_token")
    @classmethod
    def token_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Refresh token is required")
        return v.strip()


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = Field(default="bearer", description="Token type")


@router.post("/login", response_model=TokenResponse)
@limiter.limit("10/minute")
async def login(request: Request, body: LoginRequest):
    # TODO: load user from DB by email, verify password, return tokens
    # Placeholder: accept any and return dummy tokens for structure
    raise HTTPException(status_code=501, detail="Auth not implemented yet")


@router.post("/refresh", response_model=TokenResponse)
@limiter.limit("30/minute")
async def refresh(request: Request, body: RefreshRequest):
    # TODO: validate body.refresh_token, issue new access + refresh
    raise HTTPException(status_code=501, detail="Refresh not implemented yet")
